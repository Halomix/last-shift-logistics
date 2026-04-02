local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cargo = require(ReplicatedStorage.Shared.Config.Cargo)
local EconomyConfig = require(ReplicatedStorage.Shared.Config.Economy)
local Routes = require(ReplicatedStorage.Shared.Config.Routes)

local EconomyService = {}
EconomyService.__index = EconomyService

function EconomyService.new()
	return setmetatable({}, EconomyService)
end

function EconomyService:Init(services)
	self.Services = services
end

function EconomyService:CalculateDelivery(contract, assignment, profile, boardModifier)
	local route = Routes.Named[contract.RouteId]
	local routeType = Routes.Types[route.Type]
	local cargo = Cargo[contract.CargoId]
	local streakBonus = 1 + math.min(profile.DispatchStreak * EconomyConfig.StreakBonusPerStep, EconomyConfig.MaxStreakBonus)
	local elapsed = 0
	if assignment.StartedAt > 0 then
		elapsed = os.clock() - assignment.StartedAt
	end

	local scheduleDelta = contract.OnTimeBonus
	local scheduleLabel = ("On time +%d"):format(contract.OnTimeBonus)
	if elapsed > 0 and elapsed > (contract.TargetTime + boardModifier.TargetTimeShift) then
		scheduleDelta = -contract.LatePenalty
		scheduleLabel = ("Late -%d"):format(contract.LatePenalty)
	end

	local payout = math.floor(contract.Reward * routeType.RewardMultiplier * cargo.PayoutMultiplier * boardModifier.RewardMultiplier * streakBonus)
	payout += scheduleDelta
	payout = math.max(math.floor(contract.Reward * EconomyConfig.MinimumPayoutFactor), payout)

	return {
		Payout = payout,
		Elapsed = elapsed,
		ScheduleLabel = scheduleLabel,
		ReputationDelta = EconomyConfig.DefaultReputationGain,
		DistrictId = contract.DistrictId
	}
end

return EconomyService
