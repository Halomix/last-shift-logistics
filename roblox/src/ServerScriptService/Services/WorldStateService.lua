local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Districts = require(ReplicatedStorage.Shared.Config.Districts)
local WorldBlueprints = require(ReplicatedStorage.Shared.Config.WorldBlueprints)

local WorldStateService = {}
WorldStateService.__index = WorldStateService

function WorldStateService.new()
	local self = setmetatable({}, WorldStateService)
	self.Root = nil
	self.NodeMap = {}
	self.SpawnLocations = {}
	self.DispatchBoardPrompt = nil
	self.DispatchBoardLabel = nil
	self.CrewBoardLabel = nil
	self.LeaderboardLabel = nil
	self.CompanyPadLabels = {}
	self.TruckBayCFrames = {}
	return self
end

function WorldStateService:Init(services)
	self.Services = services
	self:_buildWorld()
end

function WorldStateService:GetSpawnCFrame(index)
	local count = math.max(#self.SpawnLocations, 1)
	local spawn = self.SpawnLocations[((index - 1) % count) + 1]
	if spawn then
		return spawn.CFrame + Vector3.new(0, 4, 0)
	end
	return CFrame.new(0, 8, 0)
end

function WorldStateService:GetVehicleBayCount()
	return math.max(#self.TruckBayCFrames, 1)
end

function WorldStateService:GetVehicleBayCFrame(index)
	local count = math.max(#self.TruckBayCFrames, 1)
	local bay = self.TruckBayCFrames[((index - 1) % count) + 1]
	if bay then
		return bay
	end
	return CFrame.lookAt(Vector3.new(0, 3, 16), Vector3.new(0, 3, 44))
end

function WorldStateService:ResetPlayerToHub(player)
	local character = player.Character
	if not character then
		return
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		rootPart.CFrame = self:GetSpawnCFrame((player.UserId % math.max(#self.SpawnLocations, 1)) + 1)
	end
end

function WorldStateService:GetNode(nodeId)
	return self.NodeMap[nodeId]
end

function WorldStateService:GetDispatchBoardPrompt()
	return self.DispatchBoardPrompt
end

function WorldStateService:UpdateDispatchBoard(lines)
	if self.DispatchBoardLabel then
		self.DispatchBoardLabel.Text = table.concat(lines, "\n")
	end
end

function WorldStateService:UpdateLeaderboard(lines)
	if self.LeaderboardLabel then
		self.LeaderboardLabel.Text = table.concat(lines, "\n")
	end
end

function WorldStateService:UpdateCrewBoard(lines)
	if self.CrewBoardLabel then
		self.CrewBoardLabel.Text = table.concat(lines, "\n")
	end
end

function WorldStateService:UpdateShowcasePads(entries)
	for index, label in ipairs(self.CompanyPadLabels) do
		local entry = entries and entries[index]
		if entry then
			label.Text = ("%s\nL%d | %s\nD%d | %dcr"):format(
				entry.DisplayName,
				entry.CompanyLevel,
				entry.VehicleTier,
				entry.DeliveriesCompleted,
				entry.Credits
			)
		else
			label.Text = ("Showcase %d\nOpen Pad\nTake a contract"):format(index)
		end
	end
end

function WorldStateService:_buildWorld()
	local existing = Workspace:FindFirstChild("LogisticsWorld")
	if existing then
		existing:Destroy()
	end

	self.Root = Instance.new("Folder")
	self.Root.Name = "LogisticsWorld"
	self.Root.Parent = Workspace
	self.NodeMap = {}
	self.SpawnLocations = {}
	self.TruckBayCFrames = {}

	self:_createGround()
	self:_createHub()
	self:_createRoads()
	self:_createSupportNodes()
	self:_createDistrictNodes()
	self:_createDecor()
end

function WorldStateService:_createGround()
	local base = Instance.new("Part")
	base.Name = "Ground"
	base.Anchored = true
	base.Size = Vector3.new(1200, 4, 1200)
	base.Position = Vector3.new(0, -2, 0)
	base.Color = Color3.fromRGB(24, 29, 37)
	base.Material = Enum.Material.Asphalt
	base.Parent = self.Root
end

function WorldStateService:_createHub()
	local hubData = WorldBlueprints.Hub

	local hub = Instance.new("Part")
	hub.Name = "CentralHub"
	hub.Anchored = true
	hub.Size = hubData.Size
	hub.Position = hubData.Position
	hub.Color = Color3.fromRGB(33, 41, 52)
	hub.Material = Enum.Material.Concrete
	hub.Parent = self.Root
	CollectionService:AddTag(hub, "Depot")
	CollectionService:AddTag(hub, "Hub")

	local hubSign = self:_createStandingBoard("HubSign", Vector3.new(0, 8, 92), Vector3.new(40, 12, 1), "LAST SHIFT LOGISTICS\nShared Depot")
	hubSign.Parent = self.Root

	local dispatchBoard = self:_createStandingBoard("DispatchBoard", hubData.DispatchBoard.Position, hubData.DispatchBoard.Size, "Dispatch board loading...")
	dispatchBoard.Parent = self.Root
	self.DispatchBoardLabel = self:_getBoardLabel(dispatchBoard)
	self.DispatchBoardPrompt = Instance.new("ProximityPrompt")
	self.DispatchBoardPrompt.Name = "DispatchBoardPrompt"
	self.DispatchBoardPrompt.ActionText = "Open Board"
	self.DispatchBoardPrompt.ObjectText = "Dispatch Board"
	self.DispatchBoardPrompt.MaxActivationDistance = 14
	self.DispatchBoardPrompt.Parent = dispatchBoard

	local leaderboardBoard = self:_createStandingBoard("LeaderboardBoard", hubData.LeaderboardBoard.Position, hubData.LeaderboardBoard.Size, "Top couriers loading...")
	leaderboardBoard.Parent = self.Root
	self.LeaderboardLabel = self:_getBoardLabel(leaderboardBoard)

	local crewBoard = self:_createStandingBoard("CrewBoard", hubData.CrewBoard.Position, hubData.CrewBoard.Size, "Crew board loading...")
	crewBoard.Parent = self.Root
	self.CrewBoardLabel = self:_getBoardLabel(crewBoard)

	for index, spawnData in ipairs(hubData.SpawnPads) do
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = spawnData.Name
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.AllowTeamChangeOnTouch = false
		spawn.Size = Vector3.new(16, 1, 16)
		spawn.Position = spawnData.Position
		spawn.Color = Color3.fromRGB(64, 90, 112)
		spawn.Material = Enum.Material.Metal
		spawn.Parent = self.Root
		self.SpawnLocations[index] = spawn
	end

	for bayIndex, bayPosition in ipairs(hubData.TruckBays) do
		local bay = Instance.new("Part")
		bay.Name = ("TruckBay_%d"):format(bayIndex)
		bay.Anchored = true
		bay.Size = Vector3.new(18, 2, 28)
		bay.Position = bayPosition
		bay.Color = Color3.fromRGB(54, 61, 71)
		bay.Material = Enum.Material.Metal
		bay.Parent = self.Root

		local marker = Instance.new("Part")
		marker.Name = "TruckMarker"
		marker.Anchored = true
		marker.Size = Vector3.new(12, 6, 20)
		marker.Position = bayPosition + Vector3.new(0, 4, 0)
		marker.Color = Color3.fromRGB(99, 132, 174)
		marker.Material = Enum.Material.SmoothPlastic
		marker.CanCollide = false
		marker.CanTouch = false
		marker.CanQuery = false
		marker.Transparency = 0.45
		marker.CastShadow = false
		marker.Parent = self.Root
		self.TruckBayCFrames[bayIndex] = CFrame.lookAt(bayPosition + Vector3.new(0, 1.8, 0), bayPosition + Vector3.new(0, 1.8, 40))
	end

	for index, padData in ipairs(hubData.CompanyPads or {}) do
		local pad = Instance.new("Part")
		pad.Name = padData.Name
		pad.Anchored = true
		pad.Size = Vector3.new(20, 2, 20)
		pad.Position = padData.Position
		pad.Color = Color3.fromRGB(42, 51, 63)
		pad.Material = Enum.Material.Metal
		pad.Parent = self.Root

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ShowcaseBillboard"
		billboard.Size = UDim2.fromOffset(210, 74)
		billboard.StudsOffset = Vector3.new(0, 7, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = pad

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 0.15
		label.BackgroundColor3 = Color3.fromRGB(17, 22, 31)
		label.TextColor3 = Color3.fromRGB(232, 239, 245)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Text = ("Showcase %d\nOpen Pad\nTake a contract"):format(index)
		label.Parent = billboard

		self.CompanyPadLabels[index] = label
	end

	self:_createDepotStructures()
	self:_createHubWayfinding()
end

function WorldStateService:_createRoads()
	for _, road in ipairs(WorldBlueprints.Roads) do
		local vector = road.To - road.From
		local length = vector.Magnitude
		local center = road.From:Lerp(road.To, 0.5)
		local part = Instance.new("Part")
		part.Name = road.Name
		part.Anchored = true
		part.Size = Vector3.new(road.Width, 1, length)
		part.Color = road.Color
		part.Material = Enum.Material.Asphalt
		part.CFrame = CFrame.lookAt(center, road.To) * CFrame.Angles(math.rad(90), 0, 0)
		part.Parent = self.Root
		CollectionService:AddTag(part, "TrafficPath")
	end
end

function WorldStateService:_createSupportNodes()
	for _, node in ipairs(WorldBlueprints.SupportNodes) do
		self:_createNodePart(node)
	end
end

function WorldStateService:_createDistrictNodes()
	for _, node in ipairs(WorldBlueprints.DistrictNodes) do
		self:_createNodePart(node)
	end
end

function WorldStateService:_createNodePart(nodeData)
	local district = Districts[nodeData.DistrictId]
	self:_createNodeCompound(nodeData, district)

	local part = Instance.new("Part")
	part.Name = nodeData.NodeId
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(16, 2, 16)
	part.Position = nodeData.Position + Vector3.new(0, 1.1, 0)
	part.Color = district and district.Palette.Accent or Color3.fromRGB(255, 255, 255)
	part.Material = Enum.Material.Neon
	part.Parent = self.Root
	part:SetAttribute("NodeId", nodeData.NodeId)
	part:SetAttribute("DistrictId", nodeData.DistrictId)
	part:SetAttribute("DisplayName", nodeData.DisplayName)
	part:SetAttribute("NodeRole", nodeData.Role)
	CollectionService:AddTag(part, nodeData.Role)
	CollectionService:AddTag(part, "ServicePoint")
	CollectionService:AddTag(part, "District")
	self.NodeMap[nodeData.NodeId] = part

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "LogisticsNodePrompt"
	if nodeData.Role == "PickupNode" then
		prompt.ActionText = "Collect Load"
	elseif nodeData.Role == "HandoffNode" then
		prompt.ActionText = "Transfer Cargo"
	else
		prompt.ActionText = "Confirm Delivery"
	end
	prompt.ObjectText = nodeData.DisplayName
	prompt.MaxActivationDistance = 14
	prompt.Parent = part

	local labelPart = self:_createStandingBoard(nodeData.NodeId .. "_Sign", nodeData.Position + Vector3.new(0, 8, -30), Vector3.new(18, 8, 1), ("%s\n%s"):format(district and district.DisplayName or "District", nodeData.DisplayName))
	labelPart.Parent = self.Root
end

function WorldStateService:_createDecor()
	for _, position in ipairs({
		Vector3.new(-70, 2, 15),
		Vector3.new(-54, 2, 22),
		Vector3.new(60, 2, 20),
		Vector3.new(76, 2, 28),
		Vector3.new(-88, 2, -34),
		Vector3.new(88, 2, -34)
	}) do
		local crate = Instance.new("Part")
		crate.Name = "Crate"
		crate.Anchored = true
		crate.Size = Vector3.new(8, 8, 8)
		crate.Position = position
		crate.Color = Color3.fromRGB(99, 85, 65)
		crate.Material = Enum.Material.WoodPlanks
		crate.Parent = self.Root
	end

	for _, position in ipairs({
		Vector3.new(-100, 7, 30),
		Vector3.new(100, 7, 30),
		Vector3.new(-100, 7, -60),
		Vector3.new(100, 7, -60)
	}) do
		local mast = Instance.new("Part")
		mast.Name = "HubLightMast"
		mast.Anchored = true
		mast.Size = Vector3.new(2, 14, 2)
		mast.Position = position
		mast.Color = Color3.fromRGB(76, 84, 97)
		mast.Material = Enum.Material.Metal
		mast.Parent = self.Root

		local lamp = Instance.new("Part")
		lamp.Name = "HubLight"
		lamp.Anchored = true
		lamp.Size = Vector3.new(6, 2, 6)
		lamp.Position = position + Vector3.new(0, 8, 0)
		lamp.Color = Color3.fromRGB(241, 215, 137)
		lamp.Material = Enum.Material.Neon
		lamp.Parent = self.Root
	end
end

function WorldStateService:_createDepotStructures()
	local office = Instance.new("Part")
	office.Name = "DepotOffice"
	office.Anchored = true
	office.Size = Vector3.new(64, 20, 34)
	office.Position = Vector3.new(0, 10, -96)
	office.Color = Color3.fromRGB(42, 48, 58)
	office.Material = Enum.Material.Concrete
	office.Parent = self.Root

	local canopy = Instance.new("Part")
	canopy.Name = "DispatchCanopy"
	canopy.Anchored = true
	canopy.Size = Vector3.new(108, 2, 30)
	canopy.Position = Vector3.new(0, 10, -12)
	canopy.Color = Color3.fromRGB(58, 66, 79)
	canopy.Material = Enum.Material.Metal
	canopy.CanCollide = false
	canopy.CanTouch = false
	canopy.Parent = self.Root

	for _, position in ipairs({
		Vector3.new(-48, 5, -12),
		Vector3.new(-16, 5, -12),
		Vector3.new(16, 5, -12),
		Vector3.new(48, 5, -12)
	}) do
		local pillar = Instance.new("Part")
		pillar.Name = "CanopyPillar"
		pillar.Anchored = true
		pillar.Size = Vector3.new(3, 10, 3)
		pillar.Position = position
		pillar.Color = Color3.fromRGB(71, 78, 91)
		pillar.Material = Enum.Material.Metal
		pillar.Parent = self.Root
	end

	for _, position in ipairs({
		Vector3.new(-96, 3, -8),
		Vector3.new(-96, 3, 52),
		Vector3.new(96, 3, -8),
		Vector3.new(96, 3, 52)
	}) do
		local stack = Instance.new("Part")
		stack.Name = "ContainerStack"
		stack.Anchored = true
		stack.Size = Vector3.new(18, 6, 28)
		stack.Position = position
		stack.Color = Color3.fromRGB(116, 83, 59)
		stack.Material = Enum.Material.Metal
		stack.Parent = self.Root
	end

	for _, position in ipairs({
		Vector3.new(-74, 1.05, 8),
		Vector3.new(-42, 1.05, 8),
		Vector3.new(-10, 1.05, 8),
		Vector3.new(22, 1.05, 8),
		Vector3.new(54, 1.05, 8)
	}) do
		local stripe = Instance.new("Part")
		stripe.Name = "LaneStripe"
		stripe.Anchored = true
		stripe.CanCollide = false
		stripe.Size = Vector3.new(4, 0.1, 18)
		stripe.Position = position
		stripe.Color = Color3.fromRGB(242, 199, 99)
		stripe.Material = Enum.Material.Neon
		stripe.Parent = self.Root
	end

	for _, position in ipairs({
		Vector3.new(-110, 4, -96),
		Vector3.new(110, 4, -96)
	}) do
		local gatePillar = Instance.new("Part")
		gatePillar.Name = "GatePillar"
		gatePillar.Anchored = true
		gatePillar.Size = Vector3.new(8, 18, 8)
		gatePillar.Position = position
		gatePillar.Color = Color3.fromRGB(79, 84, 91)
		gatePillar.Material = Enum.Material.Concrete
		gatePillar.Parent = self.Root
	end

	local gateBeam = Instance.new("Part")
	gateBeam.Name = "GateBeam"
	gateBeam.Anchored = true
	gateBeam.Size = Vector3.new(228, 4, 8)
	gateBeam.Position = Vector3.new(0, 13, -96)
	gateBeam.Color = Color3.fromRGB(92, 100, 112)
	gateBeam.Material = Enum.Material.Metal
	gateBeam.CanCollide = false
	gateBeam.CanTouch = false
	gateBeam.Parent = self.Root
end

function WorldStateService:_createHubWayfinding()
	local signs = {
		{
			Name = "NorthWayfinding",
			Position = Vector3.new(0, 8, 128),
			Size = Vector3.new(28, 10, 1),
			Text = "NORTH LANE\nMarket Nine / Floodline / Crossdock"
		},
		{
			Name = "EastWayfinding",
			Position = Vector3.new(128, 8, 42),
			Size = Vector3.new(28, 10, 1),
			Text = "EAST CUT\nDockside / Brightline / Service Apron"
		},
		{
			Name = "WestWayfinding",
			Position = Vector3.new(-128, 8, 42),
			Size = Vector3.new(28, 10, 1),
			Text = "WEST CUT\nOld Transit / Relay Yard / Floodline"
		}
	}

	for _, signData in ipairs(signs) do
		local sign = self:_createStandingBoard(signData.Name, signData.Position, signData.Size, signData.Text)
		sign.Parent = self.Root
	end

	for _, position in ipairs({
		Vector3.new(0, 1.15, 118),
		Vector3.new(104, 1.15, 36),
		Vector3.new(-104, 1.15, 36)
	}) do
		local stripe = Instance.new("Part")
		stripe.Name = "WayfindingStripe"
		stripe.Anchored = true
		stripe.CanCollide = false
		stripe.Size = Vector3.new(18, 0.1, 42)
		stripe.Position = position
		stripe.Color = Color3.fromRGB(105, 184, 255)
		stripe.Material = Enum.Material.Neon
		stripe.Parent = self.Root
	end
end

function WorldStateService:_createNodeCompound(nodeData, district)
	local lot = Instance.new("Part")
	lot.Name = nodeData.NodeId .. "_Lot"
	lot.Anchored = true
	lot.Size = Vector3.new(74, 1, 64)
	lot.Position = nodeData.Position
	lot.Color = district and district.Palette.Primary or Color3.fromRGB(56, 59, 66)
	lot.Material = Enum.Material.Concrete
	lot.Parent = self.Root

	local building = Instance.new("Part")
	building.Name = nodeData.NodeId .. "_Building"
	building.Anchored = true
	building.Size = Vector3.new(46, 24, 26)
	building.Position = nodeData.Position + Vector3.new(0, 12, -22)
	building.Color = district and district.Palette.Primary or Color3.fromRGB(78, 82, 94)
	building.Material = Enum.Material.Metal
	building.Parent = self.Root

	local dock = Instance.new("Part")
	dock.Name = nodeData.NodeId .. "_Dock"
	dock.Anchored = true
	dock.Size = Vector3.new(26, 3, 10)
	dock.Position = nodeData.Position + Vector3.new(0, 1.5, -8)
	dock.Color = district and district.Palette.Accent or Color3.fromRGB(191, 181, 104)
	dock.Material = Enum.Material.Metal
	dock.Parent = self.Root

	for _, offset in ipairs({ Vector3.new(-22, 4, 12), Vector3.new(22, 4, 12) }) do
		local lamp = Instance.new("Part")
		lamp.Name = nodeData.NodeId .. "_Lamp"
		lamp.Anchored = true
		lamp.Size = Vector3.new(2, 8, 2)
		lamp.Position = nodeData.Position + offset
		lamp.Color = Color3.fromRGB(82, 88, 96)
		lamp.Material = Enum.Material.Metal
		lamp.Parent = self.Root

		local glow = Instance.new("Part")
		glow.Name = nodeData.NodeId .. "_Glow"
		glow.Anchored = true
		glow.CanCollide = false
		glow.Size = Vector3.new(4, 2, 4)
		glow.Position = nodeData.Position + offset + Vector3.new(0, 5, 0)
		glow.Color = district and district.Palette.Accent or Color3.fromRGB(240, 214, 144)
		glow.Material = Enum.Material.Neon
		glow.Parent = self.Root
	end
end

function WorldStateService:_createStandingBoard(name, position, size, text)
	local board = Instance.new("Part")
	board.Name = name
	board.Anchored = true
	board.Size = size
	board.Position = position
	board.Color = Color3.fromRGB(26, 34, 44)
	board.Material = Enum.Material.Metal

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "SurfaceGui"
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.CanvasSize = Vector2.new(700, 420)
	surfaceGui.Parent = board

	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(19, 26, 35)
	frame.Parent = surfaceGui

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(227, 235, 245)
	label.TextWrapped = true
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = frame

	return board
end

function WorldStateService:_getBoardLabel(board)
	local surfaceGui = board:FindFirstChild("SurfaceGui")
	if not surfaceGui then
		return nil
	end
	local frame = surfaceGui:FindFirstChild("Frame")
	if not frame then
		return nil
	end
	return frame:FindFirstChild("Label")
end

return WorldStateService
