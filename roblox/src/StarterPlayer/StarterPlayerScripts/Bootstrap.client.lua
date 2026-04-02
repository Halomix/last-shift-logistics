local controllersFolder = script.Parent:WaitForChild("Controllers")

local HudController = require(controllersFolder:WaitForChild("HudController"))
local AudioController = require(controllersFolder:WaitForChild("AudioController"))
local DispatchController = require(controllersFolder:WaitForChild("DispatchController"))
local InteractionController = require(controllersFolder:WaitForChild("InteractionController"))
local VehicleController = require(controllersFolder:WaitForChild("VehicleController"))

local controllers = {}
controllers.HudController = HudController.new()
controllers.AudioController = AudioController.new()
controllers.DispatchController = DispatchController.new()
controllers.InteractionController = InteractionController.new()
controllers.VehicleController = VehicleController.new()

for _, controller in pairs(controllers) do
	if controller.Init then
		controller:Init(controllers)
	end
end

_G.LastShiftLogisticsClient = controllers
