local DeliveryService = {}
DeliveryService.__index = DeliveryService

function DeliveryService.new()
	local self = setmetatable({}, DeliveryService)
	self.Assignments = {}
	return self
end

function DeliveryService:Init(services)
	self.Services = services
end

function DeliveryService:GetAssignment(player)
	return self.Assignments[player.UserId]
end

function DeliveryService:CreateAssignment(player, contract, boardModifier)
	local stages = {}
	if contract.PickupNodeId then
		table.insert(stages, { NodeId = contract.PickupNodeId, Label = "Pickup", Role = "Pickup" })
	end
	if contract.HandoffNodeId then
		table.insert(stages, { NodeId = contract.HandoffNodeId, Label = "Handoff", Role = "Handoff" })
	end
	table.insert(stages, { NodeId = contract.FinalNodeId, Label = "Delivery", Role = "Delivery" })

	local assignment = {
		ContractId = contract.Id,
		Status = "Accepted",
		AcceptedAt = os.clock(),
		StartedAt = 0,
		CurrentStageIndex = 1,
		Stages = stages,
		BoardModifierId = boardModifier.Id,
		FeaturedDistrictId = contract.DistrictId,
		PartySlots = { player.UserId },
		Capacity = contract.Availability.Capacity or 1
	}

	self.Assignments[player.UserId] = assignment
	return assignment
end

function DeliveryService:BeginAssignment(player)
	local assignment = self:GetAssignment(player)
	if not assignment then
		return nil
	end
	assignment.Status = "Active"
	assignment.StartedAt = os.clock()
	return assignment
end

function DeliveryService:ReportNodeArrival(player, nodeId)
	local assignment = self:GetAssignment(player)
	if not assignment then
		return { ok = false, message = "No active assignment." }
	end

	local stage = assignment.Stages[assignment.CurrentStageIndex]
	if not stage then
		return { ok = false, message = "Assignment already resolved." }
	end
	if stage.NodeId ~= nodeId then
		return { ok = false, message = "Wrong stop for the current shift stage." }
	end

	assignment.CurrentStageIndex += 1
	if assignment.CurrentStageIndex > #assignment.Stages then
		assignment.Status = "Completed"
		return { ok = true, completed = true, stageLabel = stage.Label, assignment = assignment }
	end

	local nextStage = assignment.Stages[assignment.CurrentStageIndex]
	return { ok = true, completed = false, stageLabel = stage.Label, nextStage = nextStage, assignment = assignment }
end

function DeliveryService:ClearAssignment(player)
	self.Assignments[player.UserId] = nil
end

return DeliveryService
