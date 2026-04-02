local Economy = {
	MinimumPayoutFactor = 0.35,
	StreakBonusPerStep = 0.04,
	MaxStreakBonus = 0.2,
	DefaultReputationGain = 1,
	PublicMetric = "Deliveries",
	BoardModifiers = {
		CalmWindow = {
			Id = "CalmWindow",
			DisplayName = "Calm Window",
			RewardMultiplier = 0.96,
			TargetTimeShift = 4,
			BoardNote = "Dispatch expects cleaner lines and steadier rewards."
		},
		RushBoard = {
			Id = "RushBoard",
			DisplayName = "Rush Board",
			RewardMultiplier = 1.18,
			TargetTimeShift = -4,
			BoardNote = "Short clock, bigger rewards, more visible competition."
		},
		WetStreets = {
			Id = "WetStreets",
			DisplayName = "Wet Streets",
			RewardMultiplier = 1.06,
			TargetTimeShift = 1,
			BoardNote = "Rougher surfaces and extra caution pay."
		},
		PriorityFreight = {
			Id = "PriorityFreight",
			DisplayName = "Priority Freight",
			RewardMultiplier = 1.12,
			TargetTimeShift = -2,
			BoardNote = "The board is pushing urgent contracts up front."
		}
	}
}

return Economy
