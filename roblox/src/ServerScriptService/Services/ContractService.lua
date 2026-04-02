local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Contracts = require(ReplicatedStorage.Shared.Config.Contracts)
local Districts = require(ReplicatedStorage.Shared.Config.Districts)
local Routes = require(ReplicatedStorage.Shared.Config.Routes)
local EconomyConfig = require(ReplicatedStorage.Shared.Config.Economy)
local RemoteNames = require(ReplicatedStorage.Net.RemoteNames)

local ContractService = {}
ContractService.__index = ContractService

function ContractService.new()
	local self = setmetatable({}, ContractService)
	self.BoardCycle = 1
	self.Remotes = {}
	self.ActiveByContractId = {}
	return self
end

function ContractService:Init(services)
	self.Services = services
	self:_createRemotes()
	if self.Services.VehicleService and self.Services.VehicleService.BindRemotes then
		self.Services.VehicleService:BindRemotes(self.Remotes)
	end
	self:_wireRemotes()
	self:_publishBoardSurfaces()
	Players.PlayerAdded:Connect(function()
		task.defer(function()
			self:_publishBoardSurfaces()
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:_releaseAssignmentSlot(player)
		task.defer(function()
			self:_publishBoardSurfaces()
		end)
	end)
end

function ContractService:GetBoardStateForPlayer(player)
	local modifier = self:_currentBoardModifier()
	local offers = {}
	for _, contract in ipairs(Contracts) do
		if self.Services.ProgressionService:CanAccessContract(player, contract) then
			local activeCount = self.ActiveByContractId[contract.Id] or 0
			table.insert(offers, self.Services.RouteService:BuildOffer(contract, modifier, activeCount))
		end
	end

	return {
		FeaturedDistrictId = self:_featuredDistrictId(),
		FeaturedDistrictName = Districts[self:_featuredDistrictId()] and Districts[self:_featuredDistrictId()].DisplayName or self:_featuredDistrictId(),
		BoardModifier = modifier,
		Offers = offers,
		ActiveCrews = self:_activeCrewSnapshot(),
		PublicProgress = self.Services.ProgressionService:GetPublicStandings(5),
		HubStats = self:_hubStats(),
		Profile = self.Services.ProgressionService:BuildProfilePacket(player)
	}
end

function ContractService:AcceptContract(player, contractId)
	if self.Services.DeliveryService:GetAssignment(player) then
		return { ok = false, message = "Finish or reset the current shift first." }
	end

	local contract = self:_findContract(contractId)
	if not contract then
		return { ok = false, message = "Unknown contract." }
	end
	if not self.Services.ProgressionService:CanAccessContract(player, contract) then
		return { ok = false, message = "This contract is still locked." }
	end

	local modifier = self:_currentBoardModifier()
	local assignment = self.Services.DeliveryService:CreateAssignment(player, contract, modifier)
	self.ActiveByContractId[contract.Id] = (self.ActiveByContractId[contract.Id] or 0) + 1
	if self.Services.VehicleService then
		self.Services.VehicleService:ApplyAssignmentLoad(player, contract)
		self.Services.VehicleService:RefreshVehicleStatus(player)
	end
	self:_sendSync(player, {
		Type = "assignment",
		Assignment = self:_buildAssignmentPacket(assignment, contract),
		Profile = self.Services.ProgressionService:BuildProfilePacket(player)
	})
	self:_publishBoardSurfaces()
	self:_broadcastBoardDirty()
	return { ok = true, message = ("Accepted %s. Crew lane reserved and shift ready."):format(contract.DisplayName) }
end

function ContractService:BeginShift(player)
	local assignment = self.Services.DeliveryService:BeginAssignment(player)
	if not assignment then
		return { ok = false, message = "No assignment accepted." }
	end
	local contract = self:_findContract(assignment.ContractId)
	self:_sendSync(player, { Type = "notice", Message = ("Shift live: %s"):format(contract.DisplayName) })
	return { ok = true, message = "Shift started." }
end

function ContractService:ReportNodeArrival(player, nodeId)
	local result = self.Services.DeliveryService:ReportNodeArrival(player, nodeId)
	if not result.ok then
		return result
	end

	local assignment = result.assignment
	local contract = self:_findContract(assignment.ContractId)
	if result.completed then
		local profile = self.Services.ProgressionService:GetProfile(player)
		local payoutResult = self.Services.EconomyService:CalculateDelivery(contract, assignment, profile, self:_currentBoardModifier())
		local profilePacket = self.Services.ProgressionService:ApplyDelivery(player, payoutResult)
		self:_releaseAssignmentSlot(player)
		if self.Services.VehicleService then
			self.Services.VehicleService:ClearAssignmentLoad(player)
			self.Services.VehicleService:ResetVehicleForPlayer(player)
			self.Services.VehicleService:RefreshVehicleStatus(player)
		end
		self.BoardCycle += 1
		self:_publishBoardSurfaces()
		self:_sendSync(player, {
			Type = "deliveryComplete",
			Message = ("%s complete. +%d credits. %s"):format(contract.DisplayName, payoutResult.Payout, payoutResult.ScheduleLabel),
			Profile = profilePacket
		})
		self:_broadcastBoardDirty()
	else
		if self.Services.VehicleService then
			self.Services.VehicleService:RefreshVehicleStatus(player)
		end
		self:_publishBoardSurfaces()
		self:_sendSync(player, {
			Type = "arrival",
			Message = ("%s complete. Next stop: %s"):format(result.stageLabel, result.nextStage.Label),
			Assignment = self:_buildAssignmentPacket(assignment, contract)
		})
		self:_broadcastBoardDirty()
	end

	return result
end

function ContractService:_buildAssignmentPacket(assignment, contract)
	return {
		ContractId = contract.Id,
		DisplayName = contract.DisplayName,
		DistrictId = contract.DistrictId,
		RouteId = contract.RouteId,
		ClientId = contract.ClientId,
		Objective = self.Services.RouteService:BuildObjectiveText(assignment, contract),
		Status = assignment.Status,
		CurrentStageIndex = assignment.CurrentStageIndex,
		CurrentStage = assignment.Stages[math.min(assignment.CurrentStageIndex, #assignment.Stages)],
		Info = self.Services.RouteService:BuildAssignmentInfo(contract, assignment)
	}
end

function ContractService:_wireRemotes()
	self.Remotes[RemoteNames.RequestBoardState].OnServerInvoke = function(player)
		return self:GetBoardStateForPlayer(player)
	end
	self.Remotes[RemoteNames.AcceptContract].OnServerInvoke = function(player, contractId)
		return self:AcceptContract(player, contractId)
	end
	self.Remotes[RemoteNames.BeginShift].OnServerInvoke = function(player)
		return self:BeginShift(player)
	end
	self.Remotes[RemoteNames.ReportNodeArrival].OnServerInvoke = function(player, nodeId)
		return self:ReportNodeArrival(player, nodeId)
	end
	self.Remotes[RemoteNames.RequestReset].OnServerEvent:Connect(function(player)
		self:_releaseAssignmentSlot(player)
		self.Services.ProgressionService:BreakStreak(player)
		if self.Services.VehicleService then
			self.Services.VehicleService:ClearAssignmentLoad(player)
			self.Services.VehicleService:ResetVehicleForPlayer(player)
			self.Services.VehicleService:RefreshVehicleStatus(player)
		end
		self.Services.WorldStateService:ResetPlayerToHub(player)
		self:_sendSync(player, { Type = "notice", Message = "Returned to depot hub." })
		self:_publishBoardSurfaces()
		self:_broadcastBoardDirty()
	end)
end

function ContractService:_createRemotes()
	local folder = ReplicatedStorage:FindFirstChild(RemoteNames.Folder)
	if folder then
		folder:Destroy()
	end
	folder = Instance.new("Folder")
	folder.Name = RemoteNames.Folder
	folder.Parent = ReplicatedStorage

	for _, remoteFunctionName in ipairs({
		RemoteNames.RequestBoardState,
		RemoteNames.AcceptContract,
		RemoteNames.BeginShift,
		RemoteNames.ReportNodeArrival
	}) do
		local remote = Instance.new("RemoteFunction")
		remote.Name = remoteFunctionName
		remote.Parent = folder
		self.Remotes[remoteFunctionName] = remote
	end

	local requestReset = Instance.new("RemoteEvent")
	requestReset.Name = RemoteNames.RequestReset
	requestReset.Parent = folder
	self.Remotes[RemoteNames.RequestReset] = requestReset

	local requestVehicleSeat = Instance.new("RemoteEvent")
	requestVehicleSeat.Name = RemoteNames.RequestVehicleSeat
	requestVehicleSeat.Parent = folder
	self.Remotes[RemoteNames.RequestVehicleSeat] = requestVehicleSeat

	local updateVehicleInput = Instance.new("RemoteEvent")
	updateVehicleInput.Name = RemoteNames.UpdateVehicleInput
	updateVehicleInput.Parent = folder
	self.Remotes[RemoteNames.UpdateVehicleInput] = updateVehicleInput

	local sync = Instance.new("RemoteEvent")
	sync.Name = RemoteNames.SyncPlayerProgress
	sync.Parent = folder
	self.Remotes[RemoteNames.SyncPlayerProgress] = sync
end

function ContractService:_sendSync(player, payload)
	self.Remotes[RemoteNames.SyncPlayerProgress]:FireClient(player, payload)
end

function ContractService:_broadcastBoardDirty()
	for _, player in ipairs(Players:GetPlayers()) do
		self:_sendSync(player, { Type = "boardDirty" })
	end
end

function ContractService:_featuredDistrictId()
	local rotation = { "MarketNine", "DocksideRing", "Floodline", "BrightlineCivic", "OldTransit" }
	return rotation[((self.BoardCycle - 1) % #rotation) + 1]
end

function ContractService:_currentBoardModifier()
	local order = {
		EconomyConfig.BoardModifiers.CalmWindow,
		EconomyConfig.BoardModifiers.RushBoard,
		EconomyConfig.BoardModifiers.WetStreets,
		EconomyConfig.BoardModifiers.PriorityFreight
	}
	return order[((self.BoardCycle - 1) % #order) + 1]
end

function ContractService:_publishBoardSurfaces()
	local modifier = self:_currentBoardModifier()
	self.Services.WorldStateService:UpdateDispatchBoard({
		"Dispatch Board",
		("Featured district: %s"):format(self:_featuredDistrictId()),
		("Board modifier: %s"):format(modifier.DisplayName),
		modifier.BoardNote,
		("Couriers online: %d | Active crews: %d"):format(#Players:GetPlayers(), #self:_activeCrewSnapshot()),
		("Shared-ready contracts: %d"):format(self:_sharedReadyCount())
	})
	self.Services.WorldStateService:UpdateCrewBoard(self:_buildCrewBoardLines())
	self.Services.ProgressionService:RefreshPublicBoards()
end

function ContractService:_activeCrewSnapshot()
	local crews = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local assignment = self.Services.DeliveryService:GetAssignment(player)
		local profile = self.Services.ProgressionService:GetProfile(player)
		if assignment and profile then
			local contract = self:_findContract(assignment.ContractId)
			table.insert(crews, {
				DisplayName = player.DisplayName,
				CompanyLevel = profile.CompanyLevel,
				VehicleTier = profile.VehicleTier,
				ContractName = contract and contract.DisplayName or assignment.ContractId,
				DistrictId = contract and contract.DistrictId or "Unknown",
				DistrictCode = contract and Districts[contract.DistrictId] and Districts[contract.DistrictId].ShortCode or "UNK",
				RouteId = contract and contract.RouteId or "Unknown",
				RouteName = contract and Routes.Named[contract.RouteId] and Routes.Named[contract.RouteId].DisplayName or (contract and contract.RouteId or "Unknown"),
				Stage = assignment.Stages[math.min(assignment.CurrentStageIndex, #assignment.Stages)].Label,
				CrewSlotsFilled = #assignment.PartySlots,
				CrewSlotsCapacity = assignment.Capacity
			})
		end
	end
	return crews
end

function ContractService:_sharedReadyCount()
	local count = 0
	for _, contract in ipairs(Contracts) do
		if contract.Availability and contract.Availability.SharedReady then
			count += 1
		end
	end
	return count
end

function ContractService:_hubStats()
	return {
		OnlineCouriers = #Players:GetPlayers(),
		ActiveCrews = #self:_activeCrewSnapshot(),
		SharedReadyContracts = self:_sharedReadyCount()
	}
end

function ContractService:_buildCrewBoardLines()
	local crews = self:_activeCrewSnapshot()
	local lines = {
		("Crew Board | %d Active"):format(#crews),
		"Shared depot lanes stay public."
	}
	if #crews == 0 then
		table.insert(lines, "No active crews yet. Grab a board job to light up the depot.")
		return lines
	end

	for index, crew in ipairs(crews) do
		if index > 5 then
			break
		end
		table.insert(
			lines,
			("%s | L%d | %s | %s (%d/%d)"):format(
				crew.DisplayName,
				crew.CompanyLevel,
				crew.ContractName,
				crew.Stage,
				crew.CrewSlotsFilled,
				crew.CrewSlotsCapacity
			)
		)
	end
	return lines
end

function ContractService:_releaseContractSlot(contractId)
	if not contractId then
		return
	end
	self.ActiveByContractId[contractId] = math.max(0, (self.ActiveByContractId[contractId] or 1) - 1)
end

function ContractService:_releaseAssignmentSlot(player)
	local assignment = self.Services.DeliveryService:GetAssignment(player)
	if not assignment then
		return
	end
	self:_releaseContractSlot(assignment.ContractId)
	self.Services.DeliveryService:ClearAssignment(player)
end

function ContractService:_findContract(contractId)
	for _, contract in ipairs(Contracts) do
		if contract.Id == contractId then
			return contract
		end
	end
	return nil
end

return ContractService
