local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Cargo = require(ReplicatedStorage.Shared.Config.Cargo)
local Routes = require(ReplicatedStorage.Shared.Config.Routes)
local VehicleConfig = require(ReplicatedStorage.Shared.Config.VehicleConfig)
local RemoteNames = require(ReplicatedStorage.Net.RemoteNames)

local VehicleService = {}
VehicleService.__index = VehicleService

function VehicleService.new()
	local self = setmetatable({}, VehicleService)
	self.VehiclesByUserId = {}
	self.SeatRemote = nil
	self.InputRemote = nil
	self.UpdateConnection = nil
	return self
end

function VehicleService:Init(services)
	self.Services = services

	Players.PlayerAdded:Connect(function(player)
		self:_ensureVehicle(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:_destroyVehicle(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:_ensureVehicle(player)
	end

	self.UpdateConnection = RunService.Heartbeat:Connect(function(dt)
		self:_updateVehicles(dt)
	end)
end

function VehicleService:BindRemotes(remotes)
	local seatRemote = remotes[RemoteNames.RequestVehicleSeat]
	if seatRemote and not self.SeatRemote then
		self.SeatRemote = seatRemote
		self.SeatRemote.OnServerEvent:Connect(function(player, ownerUserId)
			self:SeatPlayer(player, ownerUserId)
		end)
	end

	local inputRemote = remotes[RemoteNames.UpdateVehicleInput]
	if inputRemote and not self.InputRemote then
		self.InputRemote = inputRemote
		self.InputRemote.OnServerEvent:Connect(function(player, payload)
			self:UpdateVehicleInput(player, payload)
		end)
	end
end

function VehicleService:ApplyAssignmentLoad(player, contract)
	local state = self.VehiclesByUserId[player.UserId]
	if not state or not contract then
		return
	end

	local cargo = Cargo[contract.CargoId]
	local route = Routes.Named[contract.RouteId]
	local routeType = route and route.Type or "safe"
	state.AssignmentHandling = self:_composeHandling(state.BaseHandling, cargo and cargo.Family or "stable", routeType)
	self:_refreshTruckLabel(state)
end

function VehicleService:ClearAssignmentLoad(player)
	local state = self.VehiclesByUserId[player.UserId]
	if not state then
		return
	end

	state.AssignmentHandling = table.clone(state.BaseHandling)
	self:_refreshTruckLabel(state)
end

function VehicleService:RefreshVehicleStatus(player)
	local state = self.VehiclesByUserId[player.UserId]
	if not state then
		return
	end
	self:_refreshTruckLabel(state)
end

function VehicleService:ResetVehicleForPlayer(player)
	local state = self.VehiclesByUserId[player.UserId]
	if not state or not state.Model then
		return
	end

	state.Speed = 0
	state.TargetYaw = select(2, state.BaseCFrame:ToOrientation())
	state.RootCFrame = state.BaseCFrame
	state.Input = { Throttle = 0, Steer = 0 }
	self:_syncTruckParts(state, 0)
	self:_updateTruckLights(state, false)
end

function VehicleService:UpdateVehicleInput(player, payload)
	local state = self.VehiclesByUserId[player.UserId]
	if not state then
		return
	end

	payload = payload or {}
	state.Input = {
		Throttle = math.clamp(tonumber(payload.Throttle) or 0, -1, 1),
		Steer = math.clamp(tonumber(payload.Steer) or 0, -1, 1)
	}
end

function VehicleService:SeatPlayer(player, ownerUserId)
	if ownerUserId ~= player.UserId then
		return
	end

	local state = self.VehiclesByUserId[player.UserId]
	if not state then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		state.Seat:Sit(humanoid)
	end
end

function VehicleService:_ensureVehicle(player)
	if self.VehiclesByUserId[player.UserId] then
		return
	end

	local ok, err = pcall(function()
		local profile = self.Services.ProgressionService:GetProfile(player)
		local fleetTier = profile and profile.VehicleTier or "Fleet 1"
		local bayCount = self.Services.WorldStateService:GetVehicleBayCount()
		local bayIndex = (player.UserId % bayCount) + 1
		local baseCFrame = self.Services.WorldStateService:GetVehicleBayCFrame(bayIndex)

		local model = Instance.new("Model")
		model.Name = ("CourierTruck_%d"):format(player.UserId)

		local ownerValue = Instance.new("IntValue")
		ownerValue.Name = "OwnerUserId"
		ownerValue.Value = player.UserId
		ownerValue.Parent = model

		local chassis = self:_makePart(model, "Chassis", Vector3.new(10, 2.4, 18), Color3.fromRGB(61, 83, 112), Enum.Material.Metal)
		local cab = self:_makePart(model, "Cab", Vector3.new(8, 5, 6), Color3.fromRGB(81, 109, 148), Enum.Material.Metal)
		local bed = self:_makePart(model, "CargoBed", Vector3.new(9, 4, 9), Color3.fromRGB(72, 78, 88), Enum.Material.Metal)
		local seat = Instance.new("VehicleSeat")
		seat.Name = "DriverSeat"
		seat.Size = Vector3.new(4, 1, 4)
		seat.Color = Color3.fromRGB(28, 31, 37)
		seat.Material = Enum.Material.SmoothPlastic
		seat.Anchored = true
		seat.MaxSpeed = 0
		seat.Torque = 0
		seat.TurnSpeed = 0
		seat.Parent = model

		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "VehicleSeatPrompt"
		prompt.ActionText = "Drive Truck"
		prompt.ObjectText = "Company Hauler"
		prompt.MaxActivationDistance = 10
		prompt.Parent = seat

		local ownerBillboard = Instance.new("BillboardGui")
		ownerBillboard.Name = "OwnerBillboard"
		ownerBillboard.Size = UDim2.fromOffset(180, 54)
		ownerBillboard.StudsOffset = Vector3.new(0, 6, 0)
		ownerBillboard.AlwaysOnTop = true
		ownerBillboard.Parent = cab

		local ownerLabel = Instance.new("TextLabel")
		ownerLabel.Name = "Label"
		ownerLabel.Size = UDim2.fromScale(1, 1)
		ownerLabel.BackgroundTransparency = 0.18
		ownerLabel.BackgroundColor3 = Color3.fromRGB(17, 22, 31)
		ownerLabel.TextColor3 = Color3.fromRGB(232, 239, 245)
		ownerLabel.Font = Enum.Font.GothamBold
		ownerLabel.TextScaled = true
		ownerLabel.Parent = ownerBillboard

		local frontLeft = self:_makeWheel(model, "WheelFrontLeft")
		local frontRight = self:_makeWheel(model, "WheelFrontRight")
		local rearLeft = self:_makeWheel(model, "WheelRearLeft")
		local rearRight = self:_makeWheel(model, "WheelRearRight")
		local headlightLeft = self:_makeLamp(model, "HeadlightLeft", Color3.fromRGB(238, 224, 165))
		local headlightRight = self:_makeLamp(model, "HeadlightRight", Color3.fromRGB(238, 224, 165))
		local brakeLeft = self:_makeLamp(model, "BrakeLeft", Color3.fromRGB(194, 64, 68))
		local brakeRight = self:_makeLamp(model, "BrakeRight", Color3.fromRGB(194, 64, 68))

		model.PrimaryPart = chassis
		model.Parent = Workspace

		local baseHandling = self:_tierHandling(fleetTier)
		local state = {
			Player = player,
			Model = model,
			BaseCFrame = baseCFrame,
			RootCFrame = baseCFrame,
			TargetYaw = select(2, baseCFrame:ToOrientation()),
			Speed = 0,
			BaseHandling = baseHandling,
			AssignmentHandling = table.clone(baseHandling),
			CollisionBox = VehicleConfig.DefaultCollisionBox,
			Input = { Throttle = 0, Steer = 0 },
			Chassis = chassis,
			Cab = cab,
			Bed = bed,
			Seat = seat,
			FrontLeft = frontLeft,
			FrontRight = frontRight,
			RearLeft = rearLeft,
			RearRight = rearRight,
			HeadlightLeft = headlightLeft,
			HeadlightRight = headlightRight,
			BrakeLeft = brakeLeft,
			BrakeRight = brakeRight,
			OwnerLabel = ownerLabel
		}

		self.VehiclesByUserId[player.UserId] = state
		self:_syncTruckParts(state, 0)
		self:_updateTruckLights(state, false)
		self:_refreshTruckLabel(state)
	end)

	if not ok then
		warn(("[VehicleService] Failed to create truck for %s (%d): %s"):format(player.Name, player.UserId, tostring(err)))
	end
end

function VehicleService:_destroyVehicle(player)
	local state = self.VehiclesByUserId[player.UserId]
	if not state then
		return
	end
	if state.Model then
		state.Model:Destroy()
	end
	self.VehiclesByUserId[player.UserId] = nil
end

function VehicleService:_updateVehicles(dt)
	for _, state in pairs(self.VehiclesByUserId) do
		self:_updateVehicle(state, dt)
	end
end

function VehicleService:_updateVehicle(state, dt)
	local occupantHumanoid = state.Seat.Occupant
	local occupantPlayer = occupantHumanoid and Players:GetPlayerFromCharacter(occupantHumanoid.Parent) or nil
	local input = state.Input or { Throttle = 0, Steer = 0 }
	local throttle = input.Throttle or 0
	local steer = input.Steer or 0

	local handling = state.AssignmentHandling
	local targetSpeed = 0
	if throttle > 0 then
		targetSpeed = handling.MaxForwardSpeed * throttle
	elseif throttle < 0 then
		targetSpeed = handling.MaxReverseSpeed * throttle
	end

	local speed = state.Speed
	local accelRate = handling.Coast
	if throttle ~= 0 then
		if speed ~= 0 and self:_sign(targetSpeed) ~= self:_sign(speed) then
			accelRate = handling.Brake
		else
			accelRate = handling.Acceleration
		end
	end

	speed = self:_approach(speed, targetSpeed, accelRate * dt)
	if math.abs(speed) < 0.15 and throttle == 0 then
		speed = 0
	end

	local currentPosition = state.RootCFrame.Position
	local yaw = state.TargetYaw
	if math.abs(speed) > 0.5 then
		local steerRate = handling.SteerRate * math.clamp(math.abs(speed) / math.max(handling.MaxForwardSpeed, 1), 0.32, 1)
		yaw += steer * steerRate * handling.TurnGrip * dt
	end

	local facing = CFrame.fromOrientation(0, yaw, 0)
	local lookVector = facing.LookVector
	local proposedPosition = currentPosition + (lookVector * speed * dt)
	local proposedCFrame = CFrame.lookAt(proposedPosition, proposedPosition + lookVector, Vector3.yAxis)

	local blocked = self:_isBlocked(state, proposedCFrame, occupantPlayer)
	if blocked then
		speed = 0
		proposedCFrame = CFrame.lookAt(currentPosition, currentPosition + lookVector, Vector3.yAxis)
	end

	state.Speed = speed
	state.TargetYaw = yaw
	state.RootCFrame = proposedCFrame
	self:_syncTruckParts(state, steer)
	self:_updateTruckLights(state, throttle < 0 or speed < -0.5)
end

function VehicleService:_syncTruckParts(state, steer)
	local root = state.RootCFrame or state.BaseCFrame
	local frontSteer = math.rad(24) * steer

	state.Chassis.CFrame = root * CFrame.new(0, 2.2, 0)
	state.Cab.CFrame = root * CFrame.new(0, 5.1, -4.4)
	state.Bed.CFrame = root * CFrame.new(0, 4.1, 4.2)
	state.Seat.CFrame = root * CFrame.new(0, 4.6, -4.5)
	state.FrontLeft.CFrame = root * CFrame.new(-5.2, 2, -5.5) * CFrame.Angles(0, frontSteer, math.rad(90))
	state.FrontRight.CFrame = root * CFrame.new(5.2, 2, -5.5) * CFrame.Angles(0, frontSteer, math.rad(90))
	state.RearLeft.CFrame = root * CFrame.new(-5.2, 2, 5.5) * CFrame.Angles(0, 0, math.rad(90))
	state.RearRight.CFrame = root * CFrame.new(5.2, 2, 5.5) * CFrame.Angles(0, 0, math.rad(90))
	state.HeadlightLeft.CFrame = root * CFrame.new(-2.5, 3.5, -9.35)
	state.HeadlightRight.CFrame = root * CFrame.new(2.5, 3.5, -9.35)
	state.BrakeLeft.CFrame = root * CFrame.new(-2.4, 3.2, 9.2)
	state.BrakeRight.CFrame = root * CFrame.new(2.4, 3.2, 9.2)
	if state.Model.PrimaryPart ~= state.Chassis then
		state.Model.PrimaryPart = state.Chassis
	end
	state.Model:PivotTo(root)
end

function VehicleService:_updateTruckLights(state, braking)
	for _, light in ipairs({ state.HeadlightLeft, state.HeadlightRight }) do
		light.Material = Enum.Material.Neon
		light.Transparency = 0
	end
	for _, light in ipairs({ state.BrakeLeft, state.BrakeRight }) do
		light.Material = Enum.Material.Neon
		light.Color = braking and Color3.fromRGB(255, 96, 88) or Color3.fromRGB(128, 53, 56)
		light.Transparency = braking and 0 or 0.15
	end
end

function VehicleService:_refreshTruckLabel(state)
	local profile = self.Services.ProgressionService:GetProfile(state.Player)
	local deliveries = profile and profile.DeliveriesCompleted or 0
	local tier = profile and profile.VehicleTier or "Fleet 1"
	local handling = state.AssignmentHandling or state.BaseHandling
	local assignment = self.Services.DeliveryService and self.Services.DeliveryService:GetAssignment(state.Player)
	local detailLine = ("%s | %dmph | D%d"):format(tier, math.floor(handling.MaxForwardSpeed), deliveries)
	if assignment then
		local contract = self.Services.ContractService and self.Services.ContractService:_findContract(assignment.ContractId)
		if contract then
			local info = self.Services.RouteService:BuildAssignmentInfo(contract, assignment)
			detailLine = ("%s %s | %s"):format(info.DistrictCode, info.RouteType, info.StageLabel)
		end
	end
	state.OwnerLabel.Text = ("%s\n%s"):format(state.Player.DisplayName, detailLine)
end

function VehicleService:_tierHandling(tierLabel)
	local tier = VehicleConfig.Tiers[tierLabel] or VehicleConfig.Tiers["Fleet 1"]
	return {
		MaxForwardSpeed = tier.MaxForwardSpeed,
		MaxReverseSpeed = tier.MaxReverseSpeed,
		Acceleration = tier.Acceleration,
		Brake = tier.Brake,
		Coast = tier.Coast,
		SteerRate = tier.SteerRate,
		TurnGrip = tier.TurnGrip
	}
end

function VehicleService:_composeHandling(baseHandling, cargoFamily, routeTypeId)
	local cargoMods = VehicleConfig.CargoFamilies[cargoFamily] or VehicleConfig.CargoFamilies.stable
	local routeMods = VehicleConfig.RouteTypes[routeTypeId] or VehicleConfig.RouteTypes.safe
	return {
		MaxForwardSpeed = baseHandling.MaxForwardSpeed * cargoMods.TopSpeedMultiplier * routeMods.TopSpeedMultiplier,
		MaxReverseSpeed = baseHandling.MaxReverseSpeed * cargoMods.TopSpeedMultiplier,
		Acceleration = baseHandling.Acceleration * cargoMods.AccelerationMultiplier * routeMods.AccelerationMultiplier,
		Brake = baseHandling.Brake * cargoMods.BrakeMultiplier * routeMods.BrakeMultiplier,
		Coast = baseHandling.Coast,
		SteerRate = baseHandling.SteerRate * cargoMods.SteerMultiplier * routeMods.SteerMultiplier,
		TurnGrip = baseHandling.TurnGrip * cargoMods.SteerMultiplier
	}
end

function VehicleService:_isBlocked(state, targetCFrame, occupantPlayer)
	local overlapParams = OverlapParams.new()
	local filter = { state.Model }
	if occupantPlayer and occupantPlayer.Character then
		table.insert(filter, occupantPlayer.Character)
	end
	if state.Player and state.Player.Character and state.Player.Character ~= (occupantPlayer and occupantPlayer.Character or nil) then
		table.insert(filter, state.Player.Character)
	end
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = filter

	local clearanceSize = Vector3.new(state.CollisionBox.X, math.min(state.CollisionBox.Y, 4.5), state.CollisionBox.Z * 0.92)
	local hits = Workspace:GetPartBoundsInBox(targetCFrame * CFrame.new(0, 5.4, 0), clearanceSize, overlapParams)
	for _, hit in ipairs(hits) do
		local hitName = hit.Name
		local ignoredFloor = hitName == "Ground" or string.sub(hitName, 1, 9) == "TruckBay_"
		if hit.CanCollide and not ignoredFloor and not hit:IsDescendantOf(state.Model) then
			return true
		end
	end
	return false
end

function VehicleService:_approach(current, target, delta)
	if current < target then
		return math.min(current + delta, target)
	elseif current > target then
		return math.max(current - delta, target)
	end
	return target
end

function VehicleService:_sign(value)
	if value > 0 then
		return 1
	elseif value < 0 then
		return -1
	end
	return 0
end

function VehicleService:_makePart(parent, name, size, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.Parent = parent
	return part
end

function VehicleService:_makeWheel(parent, name)
	local wheel = Instance.new("Part")
	wheel.Name = name
	wheel.Shape = Enum.PartType.Cylinder
	wheel.Size = Vector3.new(3.2, 3.2, 1.8)
	wheel.Color = Color3.fromRGB(32, 34, 39)
	wheel.Material = Enum.Material.SmoothPlastic
	wheel.Anchored = true
	wheel.Parent = parent
	return wheel
end

function VehicleService:_makeLamp(parent, name, color)
	local lamp = Instance.new("Part")
	lamp.Name = name
	lamp.Size = Vector3.new(1.2, 1.2, 0.6)
	lamp.Color = color
	lamp.Material = Enum.Material.Neon
	lamp.Anchored = true
	lamp.Parent = parent
	return lamp
end

return VehicleService
