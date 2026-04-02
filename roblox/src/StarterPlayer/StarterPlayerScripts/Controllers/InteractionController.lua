local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage.Net.RemoteNames)

local InteractionController = {}
InteractionController.__index = InteractionController

function InteractionController.new()
	return setmetatable({}, InteractionController)
end

function InteractionController:Init(controllers)
	self.Controllers = controllers
	self.Hud = controllers.HudController
	self.Remotes = ReplicatedStorage:WaitForChild(RemoteNames.Folder)

	ProximityPromptService.PromptShown:Connect(function(prompt)
		if prompt.Name == "DispatchBoardPrompt" then
			self.Hud:PushNotice("Dispatch board ready. Hold the prompt key or press B.", Color3.fromRGB(124, 176, 236))
		elseif prompt.Name == "VehicleSeatPrompt" then
			self.Hud:PushNotice("Truck ready. Use the prompt to hop in.", Color3.fromRGB(112, 211, 133))
		elseif prompt.Name == "LogisticsNodePrompt" then
			self.Hud:PushNotice(("Stop ready: %s"):format(prompt.ObjectText), Color3.fromRGB(244, 191, 96))
		end
	end)

	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		if prompt.Name == "DispatchBoardPrompt" then
			self.Controllers.DispatchController:OpenBoard()
			return
		end
		if prompt.Name == "VehicleSeatPrompt" then
			local ownerValue = prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent:FindFirstChild("OwnerUserId")
			if ownerValue then
				self.Remotes:WaitForChild(RemoteNames.RequestVehicleSeat):FireServer(ownerValue.Value)
			end
			return
		end
		if prompt.Name == "LogisticsNodePrompt" then
			local nodeId = prompt.Parent and prompt.Parent:GetAttribute("NodeId")
			if nodeId then
				local result = self.Remotes:WaitForChild(RemoteNames.ReportNodeArrival):InvokeServer(nodeId)
				if result and not result.ok then
					self.Hud:PushNotice(result.message, Color3.fromRGB(244, 191, 96))
				end
			end
		end
	end)
end

return InteractionController
