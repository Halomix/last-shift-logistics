local Districts = {
	MarketNine = {
		Id = "MarketNine",
		DisplayName = "Market Nine",
		ShortCode = "MK9",
		Note = "Tight market streets, stacked signage, and short-turn delivery pressure.",
		RoutePressure = "tight_urban_turns",
		SocialValue = "High",
		Landmark = "Arcade canopy",
		Palette = {
			Primary = Color3.fromRGB(74, 93, 116),
			Accent = Color3.fromRGB(132, 221, 148)
		}
	},
	Floodline = {
		Id = "Floodline",
		DisplayName = "Floodline",
		ShortCode = "FLD",
		Note = "Weather-damaged roads, warning lamps, and unstable surfaces.",
		RoutePressure = "storm_damage",
		SocialValue = "Medium",
		Landmark = "Flood barrier wall",
		Palette = {
			Primary = Color3.fromRGB(86, 126, 160),
			Accent = Color3.fromRGB(115, 184, 255)
		}
	},
	DocksideRing = {
		Id = "DocksideRing",
		DisplayName = "Dockside Ring",
		ShortCode = "DOC",
		Note = "Industrial freight lanes, container stacks, and wide-load bays.",
		RoutePressure = "heavy_freight",
		SocialValue = "High",
		Landmark = "Container gantry",
		Palette = {
			Primary = Color3.fromRGB(116, 83, 59),
			Accent = Color3.fromRGB(240, 171, 89)
		}
	},
	BrightlineCivic = {
		Id = "BrightlineCivic",
		DisplayName = "Brightline Civic",
		ShortCode = "BRT",
		Note = "Permit-gated streets, compliance checkpoints, and civic loading aprons.",
		RoutePressure = "checkpoint_control",
		SocialValue = "Medium",
		Landmark = "Compliance arch",
		Palette = {
			Primary = Color3.fromRGB(96, 102, 111),
			Accent = Color3.fromRGB(235, 214, 133)
		}
	},
	OldTransit = {
		Id = "OldTransit",
		DisplayName = "Old Transit",
		ShortCode = "OLD",
		Note = "Relay yards, dead rail cuts, and shadowed service tunnels.",
		RoutePressure = "blind_relay_cuts",
		SocialValue = "Medium",
		Landmark = "Collapsed rail frame",
		Palette = {
			Primary = Color3.fromRGB(91, 90, 72),
			Accent = Color3.fromRGB(224, 161, 87)
		}
	}
}

return Districts
