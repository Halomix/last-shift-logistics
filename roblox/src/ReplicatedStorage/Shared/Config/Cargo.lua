local Cargo = {
	DryGoodsBulk = {
		Id = "DryGoodsBulk",
		DisplayName = "Dry Goods Bulk",
		Family = "stable",
		Note = "Steady freight for reliable starter work.",
		PayoutMultiplier = 0.95
	},
	MedpackStack = {
		Id = "MedpackStack",
		DisplayName = "Medpack Stack",
		Family = "fragile",
		Note = "Urgent cargo that rewards clean driving and fast recovery.",
		PayoutMultiplier = 1.1
	},
	GeneratorCore = {
		Id = "GeneratorCore",
		DisplayName = "Generator Core",
		Family = "heavy",
		Note = "Dense freight that wants wide turns and calm braking.",
		PayoutMultiplier = 1.2
	},
	PermitCase = {
		Id = "PermitCase",
		DisplayName = "Permit Case",
		Family = "sensitive",
		Note = "Formal civic freight that needs tidy staging.",
		PayoutMultiplier = 1.08
	},
	RelayCapsules = {
		Id = "RelayCapsules",
		DisplayName = "Relay Capsules",
		Family = "unstable",
		Note = "Transfer capsules that hate bad surfaces and panic turns.",
		PayoutMultiplier = 1.16
	}
}

return Cargo
