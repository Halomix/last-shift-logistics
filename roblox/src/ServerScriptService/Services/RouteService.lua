local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Clients = require(ReplicatedStorage.Shared.Config.Clients)
local Cargo = require(ReplicatedStorage.Shared.Config.Cargo)
local Districts = require(ReplicatedStorage.Shared.Config.Districts)
local Routes = require(ReplicatedStorage.Shared.Config.Routes)

local RouteService = {}
RouteService.__index = RouteService

function RouteService.new()
	return setmetatable({}, RouteService)
end

function RouteService:Init(services)
	self.Services = services
end

function RouteService:BuildOffer(contract, boardModifier, activeCrewCount)
	local district = Districts[contract.DistrictId]
	local route = Routes.Named[contract.RouteId]
	local routeType = Routes.Types[route.Type]
	local cargo = Cargo[contract.CargoId]
	local client = Clients[contract.ClientId]
	local rewardPreview = math.floor(contract.Reward * routeType.RewardMultiplier * boardModifier.RewardMultiplier)

	return {
		ContractId = contract.Id,
		DisplayName = contract.DisplayName,
		ClientName = client.DisplayName,
		ClientTone = client.Tone,
		ClientBadge = client.Badge,
		CargoName = cargo.DisplayName,
		CargoFamily = cargo.Family,
		DistrictName = district.DisplayName,
		DistrictCode = district.ShortCode,
		RouteName = route.DisplayName,
		RouteType = routeType.DisplayName,
		RouteHandling = routeType.Handling,
		RouteVisual = routeType.Visual,
		RewardPreview = rewardPreview,
		TargetTimePreview = math.max(18, contract.TargetTime + boardModifier.TargetTimeShift),
		QueueCount = activeCrewCount,
		CrewCapacity = contract.Availability.Capacity or 1,
		FutureCapacity = contract.Availability.FutureCapacity or (contract.Availability.Capacity or 1),
		SharedReady = contract.Availability.SharedReady == true,
		DistrictNote = district.Note,
		RouteNote = route.Note,
		Summary = ("%s | %s | %s"):format(district.DisplayName, cargo.DisplayName, route.Note)
	}
end

function RouteService:BuildObjectiveText(assignment, contract)
	local labels = {}
	for _, stage in ipairs(assignment.Stages) do
		table.insert(labels, ("%s: %s"):format(stage.Role, stage.Label))
	end
	return ("%s\n%s"):format(contract.DisplayName, table.concat(labels, " -> "))
end

function RouteService:BuildAssignmentInfo(contract, assignment)
	local district = Districts[contract.DistrictId]
	local route = Routes.Named[contract.RouteId]
	local routeType = Routes.Types[route.Type]
	local cargo = Cargo[contract.CargoId]
	local client = Clients[contract.ClientId]
	local currentStage = assignment and assignment.Stages[math.min(assignment.CurrentStageIndex, #assignment.Stages)] or nil

	return {
		ClientName = client.DisplayName,
		ClientBadge = client.Badge,
		ClientTone = client.Tone,
		CargoName = cargo.DisplayName,
		CargoFamily = cargo.Family,
		DistrictName = district.DisplayName,
		DistrictCode = district.ShortCode,
		RouteName = route.DisplayName,
		RouteType = routeType.DisplayName,
		RouteHandling = routeType.Handling,
		StageLabel = currentStage and currentStage.Label or "Dispatch",
		StageRole = currentStage and currentStage.Role or "Idle"
	}
end

return RouteService
