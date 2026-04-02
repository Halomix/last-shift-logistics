local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage.Net.RemoteNames)

local DispatchController = {}
DispatchController.__index = DispatchController

function DispatchController.new()
	local self = setmetatable({}, DispatchController)
	self.Remotes = nil
	return self
end

function DispatchController:Init(controllers)
	self.Controllers = controllers
	self.Hud = controllers.HudController
	self.Audio = controllers.AudioController
	self.Remotes = ReplicatedStorage:WaitForChild(RemoteNames.Folder)
	self.Hud:SetAcceptCallback(function(contractId)
		self:_acceptContract(contractId)
	end)

	self.Remotes:WaitForChild(RemoteNames.SyncPlayerProgress).OnClientEvent:Connect(function(payload)
		self:_handleSync(payload)
	end)

	ContextActionService:BindAction("ToggleDispatchBoard", function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			self:ToggleBoard()
		end
	end, false, Enum.KeyCode.B)
end

function DispatchController:ToggleBoard()
	if self.Hud.BoardFrame.Visible then
		self.Hud:SetBoardVisible(false)
		self.Hud:PushNotice("Dispatch board closed. Head back any time with B.", Color3.fromRGB(124, 176, 236))
		return
	end
	self:OpenBoard(false)
end

function DispatchController:OpenBoard(silent)
	local boardState = self.Remotes:WaitForChild(RemoteNames.RequestBoardState):InvokeServer()
	self.Hud:RenderBoard(boardState)
	self.Hud:SetBoardVisible(true)
	if not silent then
		self.Hud:PushNotice("Dispatch board open. Pick a contract from the shared board.", Color3.fromRGB(124, 176, 236))
		self.Audio:PlayCue("board")
	end
end

function DispatchController:_acceptContract(contractId)
	local acceptResult = self.Remotes:WaitForChild(RemoteNames.AcceptContract):InvokeServer(contractId)
	if not acceptResult.ok then
		self.Hud:PushNotice(acceptResult.message, Color3.fromRGB(244, 191, 96))
		return
	end
	local beginResult = self.Remotes:WaitForChild(RemoteNames.BeginShift):InvokeServer()
	self.Hud:SetBoardVisible(false)
	self.Hud:PushNotice(beginResult.message or acceptResult.message, Color3.fromRGB(112, 211, 133))
	self.Audio:PlayCue("accept")
end

function DispatchController:_handleSync(payload)
	if payload.Type == "assignment" then
		if payload.Profile then
			self.Hud:RenderProfile(payload.Profile)
		end
		self.Hud:RenderAssignment(payload.Assignment)
		if payload.Assignment and payload.Assignment.Info then
			self.Hud:PushNotice(
				("%s manifest live. %s route into %s."):format(
					payload.Assignment.Info.ClientName,
					payload.Assignment.Info.RouteType,
					payload.Assignment.Info.DistrictName
				),
				Color3.fromRGB(112, 211, 133)
			)
		end
	elseif payload.Type == "arrival" then
		self.Hud:RenderAssignment(payload.Assignment)
		self.Hud:PushNotice(payload.Message, Color3.fromRGB(124, 176, 236))
		self.Audio:PlayCue("arrival")
	elseif payload.Type == "deliveryComplete" then
		self.Hud:RenderProfile(payload.Profile)
		self.Hud:RenderAssignment(nil)
		self.Hud:PushNotice(payload.Message, Color3.fromRGB(112, 211, 133))
		self.Audio:PlayCue("delivery")
	elseif payload.Type == "notice" then
		self.Hud:PushNotice(payload.Message, Color3.fromRGB(124, 176, 236))
	elseif payload.Type == "boardDirty" and self.Hud.BoardFrame.Visible then
		self:OpenBoard(true)
	end
end

return DispatchController
