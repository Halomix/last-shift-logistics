local WorldBlueprints = {
	Hub = {
		Size = Vector3.new(220, 2, 220),
		Position = Vector3.new(0, 0, 0),
		SpawnPads = {
			{ Name = "HubSpawnNorth", Position = Vector3.new(-30, 3, 35) },
			{ Name = "HubSpawnSouth", Position = Vector3.new(30, 3, 35) },
			{ Name = "HubSpawnEast", Position = Vector3.new(-30, 3, 70) },
			{ Name = "HubSpawnWest", Position = Vector3.new(30, 3, 70) }
		},
		DispatchBoard = { Position = Vector3.new(0, 6, 18), Size = Vector3.new(20, 10, 1) },
		CrewBoard = { Position = Vector3.new(-42, 6, -18), Size = Vector3.new(20, 10, 1) },
		LeaderboardBoard = { Position = Vector3.new(42, 6, -18), Size = Vector3.new(20, 10, 1) },
		CompanyPads = {
			{ Name = "CompanyPad_1", Position = Vector3.new(-72, 2, -52) },
			{ Name = "CompanyPad_2", Position = Vector3.new(-24, 2, -52) },
			{ Name = "CompanyPad_3", Position = Vector3.new(24, 2, -52) },
			{ Name = "CompanyPad_4", Position = Vector3.new(72, 2, -52) }
		},
		TruckBays = {
			Vector3.new(-48, 2, 8),
			Vector3.new(-16, 2, 8),
			Vector3.new(16, 2, 8),
			Vector3.new(48, 2, 8)
		}
	},
	SupportNodes = {
		{
			NodeId = "NorthlineCrossdock_Handoff",
			DisplayName = "Northline Crossdock",
			Role = "HandoffNode",
			DistrictId = "MarketNine",
			Position = Vector3.new(90, 2, 150)
		},
		{
			NodeId = "ComplianceGate_Handoff",
			DisplayName = "Compliance Gate",
			Role = "HandoffNode",
			DistrictId = "BrightlineCivic",
			Position = Vector3.new(280, 2, 110)
		},
		{
			NodeId = "RelayYard_Pickup",
			DisplayName = "Relay Yard",
			Role = "PickupNode",
			DistrictId = "OldTransit",
			Position = Vector3.new(-220, 2, -120)
		},
		{
			NodeId = "ServiceApron_Pickup",
			DisplayName = "Service Apron",
			Role = "PickupNode",
			DistrictId = "DocksideRing",
			Position = Vector3.new(180, 2, -70)
		}
	},
	DistrictNodes = {
		{
			NodeId = "MarketNine_Delivery",
			DisplayName = "Market Nine Drop",
			Role = "DeliveryNode",
			DistrictId = "MarketNine",
			Position = Vector3.new(180, 2, 180)
		},
		{
			NodeId = "Floodline_Delivery",
			DisplayName = "Floodline Relief Drop",
			Role = "DeliveryNode",
			DistrictId = "Floodline",
			Position = Vector3.new(-180, 2, 250)
		},
		{
			NodeId = "DocksideRing_Delivery",
			DisplayName = "Dockside Ring Freight Bay",
			Role = "DeliveryNode",
			DistrictId = "DocksideRing",
			Position = Vector3.new(260, 2, -150)
		},
		{
			NodeId = "BrightlineCivic_Delivery",
			DisplayName = "Brightline Permit Drop",
			Role = "DeliveryNode",
			DistrictId = "BrightlineCivic",
			Position = Vector3.new(360, 2, 210)
		},
		{
			NodeId = "OldTransit_Delivery",
			DisplayName = "Old Transit Relay Drop",
			Role = "DeliveryNode",
			DistrictId = "OldTransit",
			Position = Vector3.new(-360, 2, -240)
		}
	},
	Roads = {
		{ Name = "NorthSpine", From = Vector3.new(0, 1, 60), To = Vector3.new(0, 1, 240), Width = 26, Color = Color3.fromRGB(35, 43, 56) },
		{ Name = "SouthSpine", From = Vector3.new(0, 1, 60), To = Vector3.new(0, 1, -180), Width = 24, Color = Color3.fromRGB(31, 39, 50) },
		{ Name = "EastBranch", From = Vector3.new(40, 1, 90), To = Vector3.new(320, 1, 170), Width = 22, Color = Color3.fromRGB(38, 46, 58) },
		{ Name = "WestBranch", From = Vector3.new(-40, 1, 90), To = Vector3.new(-320, 1, 210), Width = 22, Color = Color3.fromRGB(38, 46, 58) },
		{ Name = "DocksideCut", From = Vector3.new(40, 1, 10), To = Vector3.new(250, 1, -150), Width = 24, Color = Color3.fromRGB(40, 44, 52) },
		{ Name = "TransitCut", From = Vector3.new(-40, 1, 10), To = Vector3.new(-320, 1, -220), Width = 20, Color = Color3.fromRGB(41, 40, 37) }
	},
	AmbientRoutes = {
		{
			Name = "HubLoop",
			Points = {
				Vector3.new(-70, 4, 40),
				Vector3.new(70, 4, 40),
				Vector3.new(70, 4, 100),
				Vector3.new(-70, 4, 100)
			}
		},
		{
			Name = "NorthlineRun",
			Points = {
				Vector3.new(20, 4, 40),
				Vector3.new(90, 4, 150),
				Vector3.new(180, 4, 180),
				Vector3.new(280, 4, 110)
			}
		}
	}
}

return WorldBlueprints
