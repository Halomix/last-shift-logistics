local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage.Net.RemoteNames)

local VehicleController = {}
VehicleController.__index = VehicleController

function VehicleController.new()
	local self = setmetatable({}, VehicleController)
	self.ActiveHumanoid = nil
	self.DriveInput = { Throttle = 0, Steer = 0 }
	self.IsDriving = false
	self.Remotes = nil
	return self
end

function VehicleController:Init(controllers)
	self.Controllers = controllers
	self.Hud = controllers.HudController
	self.Remotes = ReplicatedStorage:WaitForChild(RemoteNames.Folder)

	ContextActionService:BindAction("ResetCourierToHub", function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			self.Remotes:WaitForChild(RemoteNames.RequestReset):FireServer()
		end
	end, false, Enum.KeyCode.R)

	ContextActionService:BindAction("ExitCourierTruck", function(_, inputState)
		if inputState == Enum.UserInputState.Begin and self.ActiveHumanoid then
			self.ActiveHumanoid.Sit = false
			self.Hud:PushNotice("Exited company truck.", Color3.fromRGB(124, 176, 236))
		end
	end, false, Enum.KeyCode.F)

	ContextActionService:BindAction("CourierThrottleForward", function(_, inputState)
		return self:_handleThrottleInput(1, inputState)
	end, false, Enum.KeyCode.W)

	ContextActionService:BindAction("CourierThrottleReverse", function(_, inputState)
		return self:_handleThrottleInput(-1, inputState)
	end, false, Enum.KeyCode.S)

	ContextActionService:BindAction("CourierSteerLeft", function(_, inputState)
		return self:_handleSteerInput(-1, inputState)
	end, false, Enum.KeyCode.A)

	ContextActionService:BindAction("CourierSteerRight", function(_, inputState)
		return self:_handleSteerInput(1, inputState)
	end, false, Enum.KeyCode.D)

	local player = Players.LocalPlayer
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		self.ActiveHumanoid = humanoid
		humanoid.Seated:Connect(function(active, seatPart)
			local wasDriving = self.IsDriving
			self.IsDriving = active and seatPart and seatPart.Name == "DriverSeat"
			if wasDriving and not self.IsDriving then
				self.DriveInput = { Throttle = 0, Steer = 0 }
				self:_sendDriveInput(true)
			end
			if active then
				self.Hud:PushNotice("Vehicle seat engaged. W/S drive, A/D steer, F exit, R reset.", Color3.fromRGB(124, 176, 236))
			else
				self.Hud:PushNotice("On foot in the depot.", Color3.fromRGB(124, 176, 236))
			end
		end)
	end)
end

function VehicleController:_handleThrottleInput(direction, inputState)
	if inputState == Enum.UserInputState.Begin then
		self.DriveInput.Throttle = direction
	elseif self.DriveInput.Throttle == direction then
		self.DriveInput.Throttle = 0
	end
	self:_sendDriveInput()
	return Enum.ContextActionResult.Pass
end

function VehicleController:_handleSteerInput(direction, inputState)
	if inputState == Enum.UserInputState.Begin then
		self.DriveInput.Steer = direction
	elseif self.DriveInput.Steer == direction then
		self.DriveInput.Steer = 0
	end
	self:_sendDriveInput()
	return Enum.ContextActionResult.Pass
end

function VehicleController:_sendDriveInput(force)
	if (not self.IsDriving and not force) or not self.Remotes then
		return
	end
	self.Remotes:WaitForChild(RemoteNames.UpdateVehicleInput):FireServer(self.DriveInput)
end

return VehicleController
