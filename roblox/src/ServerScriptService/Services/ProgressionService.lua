local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Contracts = require(ReplicatedStorage.Shared.Config.Contracts)
local ProgressionConfig = require(ReplicatedStorage.Shared.Config.Progression)

local ProgressionService = {}
ProgressionService.__index = ProgressionService

function ProgressionService.new()
	local self = setmetatable({}, ProgressionService)
	self.Profiles = {}
	return self
end

function ProgressionService:Init(services)
	self.Services = services
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerAdded(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.Profiles[player.UserId] = nil
		self:RefreshPublicBoards()
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		self:OnPlayerAdded(player)
	end
end

function ProgressionService:OnPlayerAdded(player)
	self.Profiles[player.UserId] = self:_defaultProfile()
	self:_ensureLeaderstats(player)
	self:_syncPlayerState(player)
	player.CharacterAdded:Connect(function(character)
		self:_attachProgressBillboard(player, character)
	end)
	self:RefreshPublicBoards()
end

function ProgressionService:GetProfile(player)
	return self.Profiles[player.UserId]
end

function ProgressionService:CanAccessContract(player, contract)
	local profile = self:GetProfile(player)
	return profile and profile.DeliveriesCompleted >= (contract.UnlockAfterShifts or 0)
end

function ProgressionService:ApplyDelivery(player, result)
	local profile = self:GetProfile(player)
	if not profile then
		return nil
	end

	profile.Credits += result.Payout
	profile.DeliveriesCompleted += 1
	profile.Reputation += result.ReputationDelta or 1
	profile.DispatchStreak += 1
	profile.DistrictMastery[result.DistrictId] = (profile.DistrictMastery[result.DistrictId] or 0) + 1
	profile.CompanyLevel = self:_companyLevelFor(profile)
	profile.VehicleTier = self:_vehicleTierFor(profile.CompanyLevel)

	self:_syncPlayerState(player)
	self:_refreshPublicBoards()
	return self:BuildProfilePacket(player)
end

function ProgressionService:BreakStreak(player)
	local profile = self:GetProfile(player)
	if not profile then
		return
	end
	profile.DispatchStreak = 0
	self:_syncPlayerState(player)
	self:_refreshPublicBoards()
end

function ProgressionService:BuildProfilePacket(player)
	local profile = self:GetProfile(player)
	if not profile then
		return nil
	end
	local nextCompanyLevel = self:_nextCompanyLevel(profile.CompanyLevel)
	local nextContract = self:_nextContractUnlock(profile.DeliveriesCompleted)
	return {
		DisplayName = player.DisplayName,
		Credits = profile.Credits,
		DeliveriesCompleted = profile.DeliveriesCompleted,
		Reputation = profile.Reputation,
		CompanyLevel = profile.CompanyLevel,
		VehicleTier = profile.VehicleTier,
		DispatchStreak = profile.DispatchStreak,
		PublicRank = self:_publicRankFor(profile.CompanyLevel),
		NextCompanyLevel = nextCompanyLevel,
		NextContract = nextContract
	}
end

function ProgressionService:GetPublicStandings(limit)
	local snapshots = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local profile = self:GetProfile(player)
		if profile then
			table.insert(snapshots, {
				DisplayName = player.DisplayName,
				Credits = profile.Credits,
				DeliveriesCompleted = profile.DeliveriesCompleted,
				CompanyLevel = profile.CompanyLevel,
				VehicleTier = profile.VehicleTier,
				Reputation = profile.Reputation,
				DispatchStreak = profile.DispatchStreak
			})
		end
	end

	table.sort(snapshots, function(a, b)
		if a.DeliveriesCompleted == b.DeliveriesCompleted then
			return a.Credits > b.Credits
		end
		return a.DeliveriesCompleted > b.DeliveriesCompleted
	end)

	local trimmed = {}
	for index, snapshot in ipairs(snapshots) do
		if limit and index > limit then
			break
		end
		table.insert(trimmed, snapshot)
	end
	return trimmed
end

function ProgressionService:_defaultProfile()
	return {
		Credits = 140,
		DeliveriesCompleted = 0,
		Reputation = 0,
		CompanyLevel = 1,
		VehicleTier = "Fleet 1",
		DispatchStreak = 0,
		DistrictMastery = {}
	}
end

function ProgressionService:_companyLevelFor(profile)
	local level = 1
	for _, spec in ipairs(ProgressionConfig.CompanyLevels) do
		if profile.Credits >= spec.MinCredits and profile.DeliveriesCompleted >= spec.MinDeliveries then
			level = spec.Level
		end
	end
	return level
end

function ProgressionService:_vehicleTierFor(level)
	local tier = "Fleet 1"
	for _, spec in ipairs(ProgressionConfig.VehicleTiers) do
		if level >= spec.Level then
			tier = spec.Label
		end
	end
	return tier
end

function ProgressionService:_ensureLeaderstats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end
	for _, name in ipairs({ "Credits", "Deliveries", "Rank", "Reputation", "Streak" }) do
		if not leaderstats:FindFirstChild(name) then
			local value = Instance.new("IntValue")
			value.Name = name
			value.Parent = leaderstats
		end
	end
end

function ProgressionService:RefreshPublicBoards()
	self:_refreshPublicBoards()
end

function ProgressionService:_syncPlayerState(player)
	local profile = self:GetProfile(player)
	if not profile then
		return
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.Credits.Value = profile.Credits
		leaderstats.Deliveries.Value = profile.DeliveriesCompleted
		leaderstats.Rank.Value = profile.CompanyLevel
		leaderstats.Reputation.Value = profile.Reputation
		leaderstats.Streak.Value = profile.DispatchStreak
	end
	player:SetAttribute("CompanyLevel", profile.CompanyLevel)
	player:SetAttribute("VehicleTier", profile.VehicleTier)
	player:SetAttribute("DeliveriesCompleted", profile.DeliveriesCompleted)
	player:SetAttribute("Credits", profile.Credits)
	player:SetAttribute("DispatchStreak", profile.DispatchStreak)
	if player.Character then
		self:_attachProgressBillboard(player, player.Character)
	end
end

function ProgressionService:_attachProgressBillboard(player, character)
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	local profile = self:GetProfile(player)
	if not profile then
		return
	end

	local billboard = head:FindFirstChild("CourierBillboard")
	if not billboard then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "CourierBillboard"
		billboard.Size = UDim2.fromOffset(190, 52)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head
	end

	local label = billboard:FindFirstChild("Label")
	if not label then
		label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 0.2
		label.BackgroundColor3 = Color3.fromRGB(18, 24, 34)
		label.TextColor3 = Color3.fromRGB(226, 235, 244)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = billboard
	end

	local assignment = self.Services and self.Services.DeliveryService and self.Services.DeliveryService:GetAssignment(player)
	if assignment then
		local stage = assignment.Stages[math.min(assignment.CurrentStageIndex, #assignment.Stages)]
		label.Text = ("%s\nL%d %s | %s"):format(
			player.DisplayName,
			profile.CompanyLevel,
			self:_publicRankFor(profile.CompanyLevel),
			stage and stage.Label or "Active Shift"
		)
	else
		label.Text = ("%s\nL%d %s | %s"):format(
			player.DisplayName,
			profile.CompanyLevel,
			self:_publicRankFor(profile.CompanyLevel),
			profile.VehicleTier
		)
	end
end

function ProgressionService:_refreshPublicBoards()
	local worldState = self.Services.WorldStateService
	if not worldState then
		return
	end
	local standings = self:GetPublicStandings(5)
	local lines = { ("Top Couriers | %d Online"):format(#Players:GetPlayers()) }
	for index, snapshot in ipairs(standings) do
		table.insert(lines, ("%d. %s | D%d | L%d | %dcr"):format(index, snapshot.DisplayName, snapshot.DeliveriesCompleted, snapshot.CompanyLevel, snapshot.Credits))
	end
	worldState:UpdateLeaderboard(lines)
	worldState:UpdateShowcasePads(standings)
end

function ProgressionService:_publicRankFor(companyLevel)
	local ranks = ProgressionConfig.PublicRanks
	return ranks[math.clamp(companyLevel, 1, #ranks)]
end

function ProgressionService:_nextCompanyLevel(currentLevel)
	for _, spec in ipairs(ProgressionConfig.CompanyLevels) do
		if spec.Level > currentLevel then
			return {
				Level = spec.Level,
				MinCredits = spec.MinCredits,
				MinDeliveries = spec.MinDeliveries
			}
		end
	end
	return nil
end

function ProgressionService:_nextContractUnlock(deliveriesCompleted)
	local bestCandidate = nil
	for _, contract in ipairs(Contracts) do
		local requirement = contract.UnlockAfterShifts or 0
		if requirement > deliveriesCompleted then
			if not bestCandidate or requirement < bestCandidate.UnlockAfterShifts then
				bestCandidate = contract
			end
		end
	end

	if not bestCandidate then
		return nil
	end

	return {
		ContractId = bestCandidate.Id,
		DisplayName = bestCandidate.DisplayName,
		UnlockAfterShifts = bestCandidate.UnlockAfterShifts
	}
end

return ProgressionService
