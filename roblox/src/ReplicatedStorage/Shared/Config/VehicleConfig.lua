local VehicleConfig = {
	DefaultCollisionBox = Vector3.new(13, 7, 23),
	Tiers = {
		["Fleet 1"] = {
			Label = "Fleet 1",
			MaxForwardSpeed = 54,
			MaxReverseSpeed = 20,
			Acceleration = 30,
			Brake = 54,
			Coast = 20,
			SteerRate = math.rad(60),
			TurnGrip = 0.82
		},
		["Fleet 2"] = {
			Label = "Fleet 2",
			MaxForwardSpeed = 59,
			MaxReverseSpeed = 22,
			Acceleration = 33,
			Brake = 58,
			Coast = 22,
			SteerRate = math.rad(64),
			TurnGrip = 0.88
		},
		["Fleet 3"] = {
			Label = "Fleet 3",
			MaxForwardSpeed = 64,
			MaxReverseSpeed = 24,
			Acceleration = 36,
			Brake = 62,
			Coast = 24,
			SteerRate = math.rad(68),
			TurnGrip = 0.92
		}
	},
	CargoFamilies = {
		stable = {
			TopSpeedMultiplier = 1.0,
			AccelerationMultiplier = 1.0,
			BrakeMultiplier = 1.0,
			SteerMultiplier = 1.0
		},
		fragile = {
			TopSpeedMultiplier = 0.96,
			AccelerationMultiplier = 0.94,
			BrakeMultiplier = 0.92,
			SteerMultiplier = 0.9
		},
		heavy = {
			TopSpeedMultiplier = 0.88,
			AccelerationMultiplier = 0.82,
			BrakeMultiplier = 0.86,
			SteerMultiplier = 0.84
		},
		sensitive = {
			TopSpeedMultiplier = 0.94,
			AccelerationMultiplier = 0.9,
			BrakeMultiplier = 0.96,
			SteerMultiplier = 0.9
		},
		unstable = {
			TopSpeedMultiplier = 0.92,
			AccelerationMultiplier = 0.88,
			BrakeMultiplier = 0.9,
			SteerMultiplier = 0.78
		}
	},
	RouteTypes = {
		safe = {
			TopSpeedMultiplier = 0.95,
			AccelerationMultiplier = 0.98,
			BrakeMultiplier = 1.02,
			SteerMultiplier = 1.0
		},
		fast = {
			TopSpeedMultiplier = 1.06,
			AccelerationMultiplier = 1.04,
			BrakeMultiplier = 0.96,
			SteerMultiplier = 0.94
		},
		rough = {
			TopSpeedMultiplier = 0.91,
			AccelerationMultiplier = 0.9,
			BrakeMultiplier = 0.93,
			SteerMultiplier = 0.88
		}
	}
}

return VehicleConfig
