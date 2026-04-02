local Routes = {
	Types = {
		safe = {
			Id = "safe",
			DisplayName = "Safe",
			RewardMultiplier = 0.95,
			TargetTimeMultiplier = 1.08,
			Handling = "Clean turns and calmer braking.",
			Visual = "Wider lanes, cleaner intersections, fewer blockers."
		},
		fast = {
			Id = "fast",
			DisplayName = "Fast",
			RewardMultiplier = 1.12,
			TargetTimeMultiplier = 0.94,
			Handling = "Tempting clock pressure with worse visibility and tighter mistakes.",
			Visual = "Shortcuts, tunnel cuts, and narrow high-risk corridors."
		},
		rough = {
			Id = "rough",
			DisplayName = "Rough",
			RewardMultiplier = 1.2,
			TargetTimeMultiplier = 1.0,
			Handling = "Punishes heavy cargo on bad surfaces and freight-first turns.",
			Visual = "Industrial clutter, barriers, rough pavement, and loading traffic."
		}
	},
	Named = {
		SafeLane = {
			Id = "SafeLane",
			DisplayName = "Safe Lane",
			Type = "safe",
			Note = "Slower and steadier for calmer cargo."
		},
		StormLane = {
			Id = "StormLane",
			DisplayName = "Storm Lane",
			Type = "fast",
			Note = "Faster in theory, uglier in practice."
		},
		HeavyRoute = {
			Id = "HeavyRoute",
			DisplayName = "Heavy Route",
			Type = "rough",
			Note = "Freight-first access road for heavy loads."
		},
		PermitCorridor = {
			Id = "PermitCorridor",
			DisplayName = "Permit Corridor",
			Type = "safe",
			Note = "Formal lanes and checkpoint discipline."
		},
		TunnelCut = {
			Id = "TunnelCut",
			DisplayName = "Tunnel Cut",
			Type = "fast",
			Note = "Shorter relay route through dead transit lanes."
		}
	}
}

return Routes
