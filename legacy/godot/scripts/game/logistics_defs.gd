class_name LogisticsDefs
extends RefCounted

const DISTRICT_PROFILES := {
	"Market Nine": {
		"note": "Tight urban market blocks, crowded access roads, and short sightlines.",
		"dressing": "market",
		"ambient": Color("#4a5d74"),
		"beacon": Color(0.52, 0.87, 0.58)
	},
	"Floodline": {
		"note": "Weather-battered streets, damp concrete, and routes that punish sloppy driving.",
		"dressing": "flood",
		"ambient": Color("#567ea0"),
		"beacon": Color(0.45, 0.72, 1.0)
	},
	"Dockside Ring": {
		"note": "Industrial lanes, container yards, and freight-first delivery logic.",
		"dressing": "dock",
		"ambient": Color("#74533b"),
		"beacon": Color(0.94, 0.67, 0.35)
	},
	"Brightline Civic": {
		"note": "Checkpoint-lit civic lanes, permit gates, and tidy loading aprons.",
		"dressing": "civic",
		"ambient": Color("#60666f"),
		"beacon": Color(0.92, 0.84, 0.52)
	},
	"Old Transit": {
		"note": "Sunken service routes, relay yards, and tunnel cuts under dead rails.",
		"dressing": "transit",
		"ambient": Color("#5b5a48"),
		"beacon": Color(0.88, 0.63, 0.34)
	}
}

const CLIENT_PROFILES := {
	"Northline Dispatch": {
		"tone": "Calm routing and clear handoffs.",
		"brief": "Procedural city work with low drama and clean timing."
	},
	"Municipal Response": {
		"tone": "Urgent civic freight and weather pressure.",
		"brief": "Keep emergency cargo moving and the district steady."
	},
	"Dockside Cooperative": {
		"tone": "Heavy freight, yard discipline, and hard turns.",
		"brief": "Freight-first work that rewards calm braking and wide lanes."
	},
	"Civic Compliance": {
		"tone": "Permits, gates, and formal handoffs.",
		"brief": "Structured civic freight where clean routing matters as much as speed."
	},
	"Night Market Collectors": {
		"tone": "Quiet relays, side-yard swaps, and routes that reward nerve.",
		"brief": "Fast transfer work that pays well if you can keep the lane under control."
	}
}

const CARGO_PROFILES := {
	"Dry Goods Bulk": {
		"family": "stable",
		"note": "Standard freight that favors calm hands and low drama.",
		"weight_multiplier": 1.00,
		"speed_cap_multiplier": 1.02,
		"acceleration_multiplier": 1.00,
		"steering_multiplier": 1.06,
		"brake_multiplier": 1.02,
		"reverse_multiplier": 1.00,
		"stress_multiplier": 0.92,
		"recovery_multiplier": 1.10,
		"payout_multiplier": 0.95
	},
	"Medpack Stack": {
		"family": "fragile",
		"note": "Urgent cargo that rewards clean lines and careful braking.",
		"weight_multiplier": 0.85,
		"speed_cap_multiplier": 0.96,
		"acceleration_multiplier": 0.98,
		"steering_multiplier": 0.94,
		"brake_multiplier": 1.06,
		"reverse_multiplier": 0.98,
		"stress_multiplier": 1.12,
		"recovery_multiplier": 0.88,
		"payout_multiplier": 1.10
	},
	"Generator Core": {
		"family": "heavy",
		"note": "Weight-first freight that punishes sloppy turn-in and late braking.",
		"weight_multiplier": 1.35,
		"speed_cap_multiplier": 0.88,
		"acceleration_multiplier": 0.82,
		"steering_multiplier": 0.86,
		"brake_multiplier": 0.90,
		"reverse_multiplier": 0.90,
		"stress_multiplier": 1.18,
		"recovery_multiplier": 0.86,
		"payout_multiplier": 1.20
	},
	"Permit Case": {
		"family": "sensitive",
		"note": "Document freight that rewards tidy inputs and precise arrivals.",
		"weight_multiplier": 0.72,
		"speed_cap_multiplier": 0.98,
		"acceleration_multiplier": 1.04,
		"steering_multiplier": 1.05,
		"brake_multiplier": 1.04,
		"reverse_multiplier": 1.02,
		"stress_multiplier": 1.02,
		"recovery_multiplier": 1.04,
		"payout_multiplier": 1.08
	},
	"Relay Capsules": {
		"family": "unstable",
		"note": "Transfer cargo that hates bad surfaces and abrupt corrections.",
		"weight_multiplier": 0.94,
		"speed_cap_multiplier": 1.03,
		"acceleration_multiplier": 1.02,
		"steering_multiplier": 0.92,
		"brake_multiplier": 0.96,
		"reverse_multiplier": 0.95,
		"stress_multiplier": 1.14,
		"recovery_multiplier": 0.84,
		"payout_multiplier": 1.16
	}
}

const CONTRACTS := [
	{
		"id": "orientation",
		"name": "Orientation Run",
		"client": "Northline Dispatch",
		"cargo": "Dry Goods Bulk",
		"cargo_note": "Stable freight for learning the route and reading the shift.",
		"district": "Market Nine",
		"district_note": "Tight curb access, short turns, and busy loading lanes.",
		"route": "Safe Lane",
		"route_type": "safe",
		"route_note": "Slower and steadier. Best when the truck and cargo need calm hands.",
		"reward": 120,
		"payout_multiplier": 0.95,
		"target_time": 34.0,
		"on_time_bonus": 16,
		"late_penalty": 8,
		"weight": 1.0,
		"stability": 0.5,
		"route_profile": {
			"speed_cap_multiplier": 0.90,
			"steering_multiplier": 1.08,
			"cargo_stress_multiplier": 0.88,
			"cargo_recovery_multiplier": 1.10,
			"brake_multiplier": 1.05,
			"reverse_multiplier": 1.02
		},
		"color": Color(0.52, 0.87, 0.58),
		"target_position": Vector3(28, 0, 10),
		"events": [
			{
				"type": "traffic_pileup",
				"title": "Traffic Pileup",
				"message": "Market Nine has jammed up ahead. Keep the truck steady and patient.",
				"start": 7.0,
				"duration": 10.0,
				"hold_drive": false,
				"profile": {
					"speed_cap_multiplier": 0.72,
					"steering_multiplier": 0.88,
					"cargo_stress_multiplier": 1.08,
					"cargo_recovery_multiplier": 1.0
				}
			},
			{
				"type": "weather_change",
				"title": "Weather Change",
				"message": "Rain is moving in. Grip is down and the city wants a cleaner line.",
				"start": 18.0,
				"duration": 12.0,
				"hold_drive": false,
				"profile": {
					"speed_cap_multiplier": 0.86,
					"steering_multiplier": 0.92,
					"cargo_stress_multiplier": 1.15,
					"cargo_recovery_multiplier": 0.9
				}
			}
		]
	},
	{
		"id": "floodline",
		"name": "Floodline Relief",
		"client": "Municipal Response",
		"cargo": "Medpack Stack",
		"cargo_note": "Fragile emergency cargo that rewards clean lines and fast but careful decisions.",
		"district": "Floodline",
		"district_note": "Wet streets, low grip, and visibility pressure from the weather.",
		"route": "Storm Lane",
		"route_type": "fast",
		"route_note": "Faster and riskier. Good for urgent cargo if the driver can keep the truck composed.",
		"reward": 180,
		"payout_multiplier": 1.10,
		"target_time": 30.0,
		"on_time_bonus": 24,
		"late_penalty": 12,
		"weight": 0.8,
		"stability": 0.35,
		"route_profile": {
			"speed_cap_multiplier": 1.08,
			"steering_multiplier": 0.96,
			"cargo_stress_multiplier": 1.12,
			"cargo_recovery_multiplier": 0.86,
			"brake_multiplier": 0.96,
			"reverse_multiplier": 0.96
		},
		"color": Color(0.45, 0.72, 1.0),
		"target_position": Vector3(-18, 0, 32),
		"events": [
			{
				"type": "weather_change",
				"title": "Weather Change",
				"message": "Storm cells are rolling over Floodline. Everything now feels heavier.",
				"start": 6.5,
				"duration": 12.0,
				"hold_drive": false,
				"profile": {
					"speed_cap_multiplier": 0.82,
					"steering_multiplier": 0.9,
					"cargo_stress_multiplier": 1.16,
					"cargo_recovery_multiplier": 0.82
				}
			},
			{
				"type": "inspection_stop",
				"title": "Inspection Stop",
				"message": "Authority checkpoint ahead. Pull over and wait for clearance.",
				"start": 18.0,
				"duration": 4.0,
				"hold_drive": true,
				"profile": {
					"speed_cap_multiplier": 1.0,
					"steering_multiplier": 1.0,
					"cargo_stress_multiplier": 1.0,
					"cargo_recovery_multiplier": 1.0
				}
			}
		]
	},
	{
		"id": "dockside",
		"name": "Dockside Core",
		"client": "Dockside Cooperative",
		"cargo": "Generator Core",
		"cargo_note": "Heavy freight that changes a district when delivered and punishes sloppy braking.",
		"district": "Dockside Ring",
		"district_note": "Industrial freight lanes, containers, and hard steel around every turn.",
		"route": "Heavy Route",
		"route_type": "rough",
		"route_note": "Rough and freight-first. Slower, heavier, and better for cargo that should not be rushed.",
		"reward": 220,
		"payout_multiplier": 1.20,
		"target_time": 32.0,
		"on_time_bonus": 30,
		"late_penalty": 15,
		"weight": 1.5,
		"stability": 0.65,
		"route_profile": {
			"speed_cap_multiplier": 0.80,
			"steering_multiplier": 0.86,
			"cargo_stress_multiplier": 1.18,
			"cargo_recovery_multiplier": 0.90,
			"brake_multiplier": 0.92,
			"reverse_multiplier": 0.88
		},
		"color": Color(0.94, 0.67, 0.35),
		"target_position": Vector3(30, 0, -24),
		"events": [
			{
				"type": "road_closure",
				"title": "Road Closure",
				"message": "A lane has been sealed off. Reroute with the freight in mind.",
				"start": 7.0,
				"duration": 10.0,
				"hold_drive": false,
				"profile": {
					"speed_cap_multiplier": 0.68,
					"steering_multiplier": 0.84,
					"cargo_stress_multiplier": 1.18,
					"cargo_recovery_multiplier": 0.95
				}
			},
			{
				"type": "inspection_stop",
				"title": "Inspection Stop",
				"message": "Dock authority wants a look at the cargo. Hold position and cooperate.",
				"start": 17.0,
				"duration": 4.0,
				"hold_drive": true,
				"profile": {
					"speed_cap_multiplier": 1.0,
					"steering_multiplier": 1.0,
					"cargo_stress_multiplier": 1.0,
					"cargo_recovery_multiplier": 1.0
				}
			}
		]
	},
	{
		"id": "brightline",
		"name": "Brightline Permit Sweep",
		"client": "Civic Compliance",
		"cargo": "Permit Case",
		"cargo_note": "Sensitive permit cargo that rewards controlled arrivals and clean staging.",
		"district": "Brightline Civic",
		"district_note": "Checkpoint-lit lanes, cleaner pavement, and gated drop yards.",
		"route": "Permit Corridor",
		"route_type": "safe",
		"route_note": "Slower and tidier. Best when the freight needs formal handoffs instead of heroics.",
		"pickup_zone": "service_apron",
		"pickup_note": "Start at the service apron to secure the permit case before heading into Brightline.",
		"handoff_zone": "civic_gate",
		"handoff_note": "Stop at the compliance gate first to log the permit case before the final drop.",
		"unlock_after_shifts": 1,
		"reward": 260,
		"payout_multiplier": 1.08,
		"target_time": 38.0,
		"on_time_bonus": 34,
		"late_penalty": 14,
		"weight": 0.7,
		"stability": 0.4,
		"route_profile": {
			"speed_cap_multiplier": 0.94,
			"steering_multiplier": 1.05,
			"cargo_stress_multiplier": 0.95,
			"cargo_recovery_multiplier": 1.10,
			"brake_multiplier": 1.06,
			"reverse_multiplier": 1.02
		},
		"color": Color(0.92, 0.84, 0.52),
		"target_position": Vector3(56, 0, 22),
		"events": [
			{
				"type": "inspection_stop",
				"title": "Gate Audit",
				"message": "Brightline compliance wants a clean handoff and a clean truck.",
				"start": 8.0,
				"duration": 4.0,
				"hold_drive": true,
				"profile": {
					"speed_cap_multiplier": 1.0,
					"steering_multiplier": 1.0,
					"cargo_stress_multiplier": 1.0,
					"cargo_recovery_multiplier": 1.0
				}
			},
			{
				"type": "road_closure",
				"title": "Permit Detour",
				"message": "A civic lane is sealed. Keep the permit case steady through the detour.",
				"start": 18.0,
				"duration": 10.0,
				"hold_drive": false,
				"profile": {
					"speed_cap_multiplier": 0.74,
					"steering_multiplier": 0.9,
					"cargo_stress_multiplier": 1.08,
					"cargo_recovery_multiplier": 1.0
				}
			}
		]
	},
	{
		"id": "transit",
		"name": "Old Transit Relay",
		"client": "Night Market Collectors",
		"cargo": "Relay Capsules",
		"cargo_note": "Unstable relay capsules that reward smooth transfer work and punishes panic turns.",
		"district": "Old Transit",
		"district_note": "Sunken access lanes, tunnel walls, relay yards, and weak sightlines.",
		"route": "Tunnel Cut",
		"route_type": "fast",
		"route_note": "Shorter and tempting. The old rail service cut saves time if you can keep the truck composed.",
		"pickup_zone": "relay_yard",
		"pickup_note": "Secure the capsules at the relay yard before they can be logged at the crossdock.",
		"handoff_zone": "crossdock",
		"handoff_note": "Secure the capsules at the Northline crossdock before heading into Old Transit.",
		"unlock_after_shifts": 2,
		"reward": 320,
		"payout_multiplier": 1.14,
		"target_time": 42.0,
		"on_time_bonus": 42,
		"late_penalty": 18,
		"weight": 0.95,
		"stability": 0.3,
		"route_profile": {
			"speed_cap_multiplier": 1.08,
			"steering_multiplier": 0.92,
			"cargo_stress_multiplier": 1.16,
			"cargo_recovery_multiplier": 0.82,
			"brake_multiplier": 0.96,
			"reverse_multiplier": 0.95
		},
		"color": Color(0.88, 0.63, 0.34),
		"target_position": Vector3(-58, 0, -30),
		"events": [
			{
				"type": "traffic_pileup",
				"title": "Relay Congestion",
				"message": "Crossdock traffic is backing up. Hold the capsules together through the squeeze.",
				"start": 6.0,
				"duration": 10.0,
				"hold_drive": false,
				"profile": {
					"speed_cap_multiplier": 0.76,
					"steering_multiplier": 0.9,
					"cargo_stress_multiplier": 1.14,
					"cargo_recovery_multiplier": 0.9
				}
			},
			{
				"type": "road_closure",
				"title": "Tunnel Closure",
				"message": "An old service cut is pinched off. Reroute without rattling the load apart.",
				"start": 18.0,
				"duration": 12.0,
				"hold_drive": false,
				"profile": {
					"speed_cap_multiplier": 0.72,
					"steering_multiplier": 0.86,
					"cargo_stress_multiplier": 1.18,
					"cargo_recovery_multiplier": 0.88
				}
			}
		]
	}
]

static func get_contracts() -> Array:
	var result: Array = []
	for contract in CONTRACTS:
		result.append(contract.duplicate(true))
	return result

static func get_district_profile(district_name: String) -> Dictionary:
	return DISTRICT_PROFILES.get(district_name, {})

static func get_client_profile(client_name: String) -> Dictionary:
	return CLIENT_PROFILES.get(client_name, {})

static func get_cargo_profile(cargo_name: String) -> Dictionary:
	return CARGO_PROFILES.get(cargo_name, {})

static func get_cargo_family_label(cargo_name: String) -> String:
	var profile := get_cargo_profile(cargo_name)
	var family := str(profile.get("family", "general"))
	if family.is_empty():
		return "general"
	return family.capitalize()

static func get_cargo_family_key(cargo_name: String) -> String:
	var profile := get_cargo_profile(cargo_name)
	var family := str(profile.get("family", "general"))
	if family.is_empty():
		return "general"
	return family

static func get_district_names() -> Array:
	var names: Array = []
	for district_name in DISTRICT_PROFILES.keys():
		names.append(str(district_name))
	return names
