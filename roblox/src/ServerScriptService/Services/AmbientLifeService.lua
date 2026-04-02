local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldBlueprints = require(ReplicatedStorage.Shared.Config.WorldBlueprints)

local AmbientLifeService = {}
AmbientLifeService.__index = AmbientLifeService

function AmbientLifeService.new()
	return setmetatable({}, AmbientLifeService)
end

function AmbientLifeService:Init(services)
	self.Services = services
	self:_buildAmbientLife()
end

function AmbientLifeService:_buildAmbientLife()
	local root = self.Services.WorldStateService.Root
	if not root then
		return
	end

	local ambientFolder = Instance.new("Folder")
	ambientFolder.Name = "AmbientLife"
	ambientFolder.Parent = root

	self:_spawnWorker(ambientFolder, Vector3.new(-62, 4, 52), "Loader")
	self:_spawnWorker(ambientFolder, Vector3.new(52, 4, 48), "Dispatcher")
	self:_spawnWorker(ambientFolder, Vector3.new(0, 4, 88), "Mechanic")

	for index, route in ipairs(WorldBlueprints.AmbientRoutes) do
		self:_spawnVan(ambientFolder, route, index)
	end
end

function AmbientLifeService:_spawnWorker(parent, position, title)
	local part = Instance.new("Part")
	part.Name = title
	part.Anchored = true
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(2, 4, 2)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	part.Color = Color3.fromRGB(214, 175, 86)
	part.Material = Enum.Material.Neon
	part.Parent = parent

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(120, 30)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.2
	label.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
	label.TextColor3 = Color3.fromRGB(240, 241, 245)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = title
	label.Parent = gui
end

function AmbientLifeService:_spawnVan(parent, route, index)
	local van = Instance.new("Part")
	van.Name = ("CourierVan_%d"):format(index)
	van.Anchored = true
	van.Size = Vector3.new(10, 6, 16)
	van.Position = route.Points[1]
	van.Color = Color3.fromRGB(78, 118, 166)
	van.Material = Enum.Material.SmoothPlastic
	van.Parent = parent

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(150, 34)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = van

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.15
	label.BackgroundColor3 = Color3.fromRGB(17, 23, 33)
	label.TextColor3 = Color3.fromRGB(231, 239, 247)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = ("Crew %d | Active"):format(index)
	label.Parent = gui

	task.spawn(function()
		local pointIndex = 2
		while van.Parent do
			local target = route.Points[pointIndex]
			local tween = TweenService:Create(van, TweenInfo.new(8, Enum.EasingStyle.Linear), { Position = target })
			tween:Play()
			tween.Completed:Wait()
			pointIndex += 1
			if pointIndex > #route.Points then
				pointIndex = 1
			end
		end
	end)
end

return AmbientLifeService
