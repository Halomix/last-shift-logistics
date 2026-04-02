local Progression = {
	CompanyLevels = {
		{ Level = 1, MinCredits = 0, MinDeliveries = 0 },
		{ Level = 2, MinCredits = 400, MinDeliveries = 3 },
		{ Level = 3, MinCredits = 1000, MinDeliveries = 8 },
		{ Level = 4, MinCredits = 2200, MinDeliveries = 16 },
		{ Level = 5, MinCredits = 4200, MinDeliveries = 28 }
	},
	VehicleTiers = {
		{ Level = 1, Label = "Fleet 1" },
		{ Level = 2, Label = "Fleet 2" },
		{ Level = 4, Label = "Fleet 3" }
	},
	PublicRanks = {
		"Routed",
		"Trusted",
		"Known",
		"Staple",
		"Night Shift Legend"
	}
}

return Progression
