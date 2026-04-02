local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Theme = require(StarterGui:WaitForChild("HUD"):WaitForChild("HUDTheme"))

local HudController = {}
HudController.__index = HudController

function HudController.new()
	local self = setmetatable({}, HudController)
	self.Gui = nil
	self.BoardFrame = nil
	self.NoticeLabel = nil
	self.ProgressLabel = nil
	self.ObjectiveLabel = nil
	self.ShiftLabel = nil
	self.SocialLabel = nil
	self.PresenceLabel = nil
	self.BoardList = nil
	self.ActiveList = nil
	self.TopList = nil
	self.AcceptCallback = nil
	return self
end

function HudController:Init(controllers)
	self.Controllers = controllers
	self:_buildGui()
end

function HudController:SetAcceptCallback(callback)
	self.AcceptCallback = callback
end

function HudController:SetBoardVisible(visible)
	if self.BoardFrame then
		self.BoardFrame.Visible = visible
	end
end

function HudController:RenderBoard(boardState)
	if not boardState then
		return
	end
	self:RenderProfile(boardState.Profile)
	self:RenderHubStats(boardState.HubStats)
	self:_clearChildren(self.BoardList)
	self:_clearChildren(self.ActiveList)
	self:_clearChildren(self.TopList)

	self:_addTextRow(self.BoardList, ("Featured district: %s"):format(boardState.FeaturedDistrictName or boardState.FeaturedDistrictId), Theme.Colors.Warning)
	self:_addTextRow(self.BoardList, ("Board modifier: %s | %s"):format(boardState.BoardModifier.DisplayName, boardState.BoardModifier.BoardNote), Theme.Colors.Info)

	for _, offer in ipairs(boardState.Offers or {}) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, -10, 0, 96)
		button.BackgroundColor3 = Theme.Colors.PanelAlt
		button.TextColor3 = Theme.Colors.Text
		button.Font = Enum.Font.GothamBold
		button.TextWrapped = true
		button.TextScaled = true
		button.Text = ("%s\n%s %s | %s | %scr | ETA %dm\n%s"):format(
			offer.DisplayName,
			offer.DistrictCode or offer.DistrictName,
			offer.RouteType,
			offer.CargoFamily,
			offer.RewardPreview,
			offer.TargetTimePreview,
			("%s | %s | Crew %d/%d | Queue %d"):format(
				offer.ClientBadge or offer.ClientName,
				offer.RouteHandling,
				offer.CrewCapacity,
				offer.FutureCapacity,
				offer.QueueCount
			)
		)
		button.Parent = self.BoardList
		button.MouseButton1Click:Connect(function()
			if self.AcceptCallback then
				self.AcceptCallback(offer.ContractId)
			end
		end)
	end

	for _, crew in ipairs(boardState.ActiveCrews or {}) do
		self:_addTextRow(self.ActiveList, ("%s | L%d\n%s | %s\nCrew %d/%d"):format(
			crew.DisplayName,
			crew.CompanyLevel,
			crew.ContractName,
			("%s %s | %s"):format(crew.DistrictCode or crew.DistrictId, crew.RouteName or crew.RouteId, crew.Stage),
			crew.CrewSlotsFilled,
			crew.CrewSlotsCapacity
		))
	end

	for _, courier in ipairs(boardState.PublicProgress or {}) do
		self:_addTextRow(self.TopList, ("%s | D%d | L%d\n%s | %dcr | S%d"):format(
			courier.DisplayName,
			courier.DeliveriesCompleted,
			courier.CompanyLevel,
			courier.VehicleTier,
			courier.Credits,
			courier.DispatchStreak
		))
	end
end

function HudController:RenderProfile(profile)
	if not profile then
		return
	end
	self.ProgressLabel.Text = ("Company L%d | %s | %dcr | %d deliveries"):format(
		profile.CompanyLevel,
		profile.VehicleTier,
		profile.Credits,
		profile.DeliveriesCompleted
	)
	local nextGoal = "Max company tier online"
	if profile.NextCompanyLevel then
		nextGoal = ("Next L%d at %dcr / %d deliveries"):format(
			profile.NextCompanyLevel.Level,
			profile.NextCompanyLevel.MinCredits,
			profile.NextCompanyLevel.MinDeliveries
		)
	end
	if profile.NextContract then
		nextGoal = ("%s | Unlock %s at %d deliveries"):format(
			nextGoal,
			profile.NextContract.DisplayName,
			profile.NextContract.UnlockAfterShifts
		)
	end
	self.SocialLabel.Text = ("%s | Rep %d | Streak %d"):format(profile.PublicRank or "Courier", profile.Reputation, profile.DispatchStreak)
	if self.ShiftLabel and (self.ShiftLabel.Text == "" or self.ShiftLabel.Text == "Shift lane: take a board job to set your route.") then
		self.ShiftLabel.Text = nextGoal
	end
end

function HudController:RenderHubStats(stats)
	if not stats or not self.PresenceLabel then
		return
	end
	self.PresenceLabel.Text = ("Depot %d online | %d active crews | %d shared-ready jobs"):format(
		stats.OnlineCouriers,
		stats.ActiveCrews,
		stats.SharedReadyContracts
	)
end

function HudController:RenderAssignment(assignment)
	if not assignment then
		self.ObjectiveLabel.Text = "Objective: No active shift. Open the dispatch board."
		if self.ShiftLabel then
			self.ShiftLabel.Text = "Shift lane: take a board job to set your route."
		end
		return
	end
	local nextStage = assignment.CurrentStage and assignment.CurrentStage.Label or "None"
	self.ObjectiveLabel.Text = ("Objective: %s | Next %s"):format(assignment.DisplayName, nextStage)
	if assignment.Info and self.ShiftLabel then
		self.ShiftLabel.Text = ("%s | %s | %s -> %s"):format(
			assignment.Info.ClientBadge or assignment.Info.ClientName,
			assignment.Info.CargoFamily,
			assignment.Info.RouteType,
			assignment.Info.DistrictCode or assignment.Info.DistrictName
		)
	end
end

function HudController:PushNotice(text, color)
	self.NoticeLabel.Text = text
	self.NoticeLabel.TextColor3 = color or Theme.Colors.Text
end

function HudController:_buildGui()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local gui = Instance.new("ScreenGui")
	gui.Name = "LogisticsHUD"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui
	self.Gui = gui

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(0, 700, 0, 176)
	topBar.Position = UDim2.fromOffset(18, 18)
	topBar.BackgroundColor3 = Theme.Colors.Background
	topBar.Parent = gui

	self.ProgressLabel = self:_makeLabel(topBar, UDim2.new(1, -20, 0, 28), UDim2.fromOffset(10, 8), "Company loading...")
	self.ObjectiveLabel = self:_makeLabel(topBar, UDim2.new(1, -20, 0, 42), UDim2.fromOffset(10, 40), "Objective: Open the dispatch board in the hub.")
	self.ShiftLabel = self:_makeLabel(topBar, UDim2.new(1, -20, 0, 28), UDim2.fromOffset(10, 86), "Shift lane: take a board job to set your route.")
	self.SocialLabel = self:_makeLabel(topBar, UDim2.new(1, -20, 0, 24), UDim2.fromOffset(10, 118), "Courier | Rep 0 | Streak 0")
	self.PresenceLabel = self:_makeLabel(topBar, UDim2.new(1, -20, 0, 24), UDim2.fromOffset(10, 144), "Depot 0 online | 0 active crews | 0 shared-ready jobs")

	self.NoticeLabel = self:_makeLabel(gui, UDim2.new(0, 620, 0, 38), UDim2.fromOffset(18, 204), "Shared depot online.")
	self.NoticeLabel.BackgroundColor3 = Theme.Colors.Panel

	self.BoardFrame = Instance.new("Frame")
	self.BoardFrame.Size = UDim2.new(0, 720, 0, 520)
	self.BoardFrame.Position = UDim2.fromOffset(18, 254)
	self.BoardFrame.BackgroundColor3 = Theme.Colors.Background
	self.BoardFrame.Visible = false
	self.BoardFrame.Parent = gui

	local title = self:_makeLabel(self.BoardFrame, UDim2.new(1, -20, 0, 32), UDim2.fromOffset(10, 8), "Dispatch Board")
	title.TextColor3 = Theme.Colors.Warning

	self:_makeLabel(self.BoardFrame, UDim2.new(0.48, -12, 0, 22), UDim2.fromOffset(10, 42), "Available Jobs").TextColor3 = Theme.Colors.Muted
	self:_makeLabel(self.BoardFrame, UDim2.new(0.24, -12, 0, 22), UDim2.new(0.5, 6, 0, 42), "Active Crews").TextColor3 = Theme.Colors.Muted
	self:_makeLabel(self.BoardFrame, UDim2.new(0.24, -12, 0, 22), UDim2.new(0.76, 6, 0, 42), "Top Couriers").TextColor3 = Theme.Colors.Muted

	self.BoardList = self:_makeScrollingFrame(self.BoardFrame, UDim2.new(0.48, -12, 1, -78), UDim2.fromOffset(10, 70))
	self.ActiveList = self:_makeScrollingFrame(self.BoardFrame, UDim2.new(0.24, -12, 1, -78), UDim2.new(0.5, 6, 0, 70))
	self.TopList = self:_makeScrollingFrame(self.BoardFrame, UDim2.new(0.24, -12, 1, -78), UDim2.new(0.76, 6, 0, 70))
end

function HudController:_makeLabel(parent, size, position, text)
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 0
	label.BackgroundColor3 = Theme.Colors.Panel
	label.TextColor3 = Theme.Colors.Text
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = text
	label.Parent = parent
	return label
end

function HudController:_makeScrollingFrame(parent, size, position)
	local frame = Instance.new("ScrollingFrame")
	frame.Size = size
	frame.Position = position
	frame.CanvasSize = UDim2.new(0, 0, 0, 0)
	frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	frame.ScrollBarThickness = 6
	frame.BackgroundColor3 = Theme.Colors.Panel
	frame.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = frame
	return frame
end

function HudController:_addTextRow(parent, text, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 42)
	label.BackgroundColor3 = Theme.Colors.PanelAlt
	label.TextColor3 = color or Theme.Colors.Text
	label.TextWrapped = true
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = text
	label.Parent = parent
	return label
end

function HudController:_clearChildren(parent)
	for _, child in ipairs(parent:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
end

return HudController
