extends Node3D

const LogisticsDefs := preload("res://scripts/game/logistics_defs.gd")
const TruckController := preload("res://scripts/game/truck_controller.gd")
const DeliveryZone := preload("res://scripts/game/delivery_zone.gd")
const LogisticsHUD := preload("res://scripts/ui/hud.gd")
const LogisticsAudio := preload("res://scripts/game/logistics_audio.gd")
const AmbientActor := preload("res://scripts/game/ambient_actor.gd")
const SPAWN_SAFE_CENTER := Vector3(0.0, 1.0, -14.0)
const SPAWN_SAFE_SIZE := Vector3(14.0, 4.0, 12.0)
const SPAWN_EXIT_CENTER := Vector3(0.0, 1.0, -1.0)
const SPAWN_EXIT_SIZE := Vector3(12.0, 4.0, 24.0)
const SPAWN_TRUCK_SIZE := Vector3(2.1, 1.25, 3.8)
const SPAWN_BLOCKER_LAYER := 2
const SPAWN_CANDIDATES := [Vector3(0.0, 1.0, -14.0), Vector3(0.0, 1.0, -18.0), Vector3(4.0, 1.0, -14.0)]
const DISTRICT_ZONE_SPECS := [
	{"zone_id": "market", "district": "Market Nine", "label": "Market Nine", "position": Vector3(28, 0.0, 10), "color": Color(0.52, 0.87, 0.58), "radius": 4.0},
	{"zone_id": "flood", "district": "Floodline", "label": "Floodline", "position": Vector3(-18, 0.0, 32), "color": Color(0.45, 0.72, 1.0), "radius": 4.2},
	{"zone_id": "dock", "district": "Dockside Ring", "label": "Dockside Ring", "position": Vector3(30, 0.0, -24), "color": Color(0.94, 0.67, 0.35), "radius": 4.4},
	{"zone_id": "civic", "district": "Brightline Civic", "label": "Brightline Civic", "position": Vector3(56, 0.0, 22), "color": Color(0.92, 0.84, 0.52), "radius": 4.0},
	{"zone_id": "transit", "district": "Old Transit", "label": "Old Transit", "position": Vector3(-58, 0.0, -30), "color": Color(0.88, 0.63, 0.34), "radius": 4.2}
]
const SERVICE_HUB_SPECS := [
	{"zone_id": "crossdock", "district": "Market Nine", "label": "Northline Crossdock", "position": Vector3(8, 0.0, 24), "color": Color(0.58, 0.78, 1.0), "radius": 3.2},
	{"zone_id": "civic_gate", "district": "Brightline Civic", "label": "Compliance Gate", "position": Vector3(44, 0.0, 8), "color": Color(0.95, 0.9, 0.62), "radius": 3.0},
	{"zone_id": "relay_yard", "district": "Old Transit", "label": "Relay Yard", "position": Vector3(-36, 0.0, -12), "color": Color(0.93, 0.7, 0.42), "radius": 3.3},
	{"zone_id": "service_apron", "district": "Dockside Ring", "label": "Service Apron", "position": Vector3(18, 0.0, -10), "color": Color(0.96, 0.58, 0.3), "radius": 3.0}
]
const OFFER_MODIFIERS := [
	{
		"name": "Calm Window",
		"note": "Dispatch expects a cleaner lane and a steadier reward floor.",
		"reward_multiplier": 0.96,
		"target_time_shift": 4.0,
		"bonus_shift": 10,
		"penalty_shift": -4,
		"speed_multiplier": 0.96,
		"recovery_multiplier": 1.08
	},
	{
		"name": "Rush Board",
		"note": "Short clock, bigger payout. Good drivers cash out harder.",
		"reward_multiplier": 1.18,
		"target_time_shift": -4.0,
		"bonus_shift": 18,
		"penalty_shift": 8,
		"speed_multiplier": 1.03,
		"stress_multiplier": 1.08
	},
	{
		"name": "Wet Streets",
		"note": "Conditions are ugly. Expect worse grip but a fatter on-time bonus.",
		"reward_multiplier": 1.06,
		"target_time_shift": 1.0,
		"bonus_shift": 14,
		"penalty_shift": 2,
		"steering_multiplier": 0.94,
		"stress_multiplier": 1.06
	},
	{
		"name": "Priority Freight",
		"note": "The client is paying to move first. Keep the lane flowing.",
		"reward_multiplier": 1.12,
		"target_time_shift": -2.0,
		"bonus_shift": 20,
		"penalty_shift": 4,
		"speed_multiplier": 1.02
	},
	{
		"name": "Maintenance Shift",
		"note": "Crews are everywhere. Slower routes, calmer handling.",
		"reward_multiplier": 1.02,
		"target_time_shift": 3.0,
		"bonus_shift": 8,
		"penalty_shift": -2,
		"speed_multiplier": 0.95,
		"recovery_multiplier": 1.06
	}
]

enum ShiftState { SELECTING, DRIVING, SUMMARY }

var shift_state := ShiftState.SELECTING
var selected_contract_index := 0
var active_contract: Dictionary = {}
var active_client_profile: Dictionary = {}
var active_cargo_profile: Dictionary = {}
var active_zone: DeliveryZone
var active_pickup_zone: DeliveryZone
var active_pickup_complete := true
var active_stage_zone: DeliveryZone
var active_stage_complete := true
var truck: TruckController
var hud: LogisticsHUD
var audio_director: LogisticsAudio
var delivery_zones: Array[DeliveryZone] = []
var district_zone_lookup := {}
var service_zone_lookup := {}
var ambient_actors: Array[AmbientActor] = []
var truck_body_mesh: MeshInstance3D
var truck_cabin_mesh: MeshInstance3D
var truck_bed_mesh: MeshInstance3D
var truck_front_left_wheel: Node3D
var truck_front_right_wheel: Node3D
var truck_rear_left_wheel: Node3D
var truck_rear_right_wheel: Node3D
var truck_left_headlight: SpotLight3D
var truck_right_headlight: SpotLight3D
var truck_brake_light_left: OmniLight3D
var truck_brake_light_right: OmniLight3D
var truck_spring_arm: SpringArm3D
var truck_camera: Camera3D
var spawn_debug_root: Node3D
var spawn_debug_visible := false
var last_valid_spawn_transform := Transform3D.IDENTITY
var district_mood := {}
var district_reputation := {}
var district_visit_count := {}
var district_mastery := {}
var cargo_warnings := 0.0
var shift_time := 0.0
var shift_event_queue: Array[Dictionary] = []
var active_shift_event: Dictionary = {}
var active_shift_event_end_time := 0.0
var shift_event_history: Array[String] = []
var board_cycle := 0
var dispatch_streak := 0
var completed_shift_count := 0
var total_credits := 0
var featured_district := "Market Nine"
var base_contracts := LogisticsDefs.get_contracts()
var contracts: Array = []

func _ready() -> void:
	_initialize_district_state()
	_refresh_contract_board()
	_build_world()
	_build_truck()
	_build_zones()
	_build_audio()
	_build_hud()
	_build_spawn_debug_overlay()
	_finalize_spawn_position()
	_apply_contract_selection(0)
	hud.set_phase_state("Selecting")
	_update_status("Select a contract with 1-5. Press Enter to start the shift.")

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#081018")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#1d2a3b")
	environment.ambient_light_energy = 1.35
	environment.fog_enabled = true
	environment.fog_light_color = Color("#0b1118")
	environment.fog_light_energy = 0.95
	environment.fog_density = 0.013
	environment.fog_sky_affect = 0.15
	env.environment = environment
	add_child(env)

	var sky := Sky.new()
	environment.sky = sky

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55.0, -30.0, 0.0)
	light.light_energy = 2.0
	light.light_color = Color("#b8c8db")
	add_child(light)

	var fill_light := DirectionalLight3D.new()
	fill_light.rotation_degrees = Vector3(-20.0, 120.0, 0.0)
	fill_light.light_energy = 0.45
	fill_light.light_color = Color("#43617b")
	add_child(fill_light)

	_build_ground()
	_build_route_network()
	_build_depot_space(Vector3(0.0, 0.0, -8.0))
	_build_landmarks()
	_build_support_hub_spaces()
	_build_delivery_spaces()
	_build_wayfinding()
	_build_world_life()

func _build_ground() -> void:
	var ground_body := StaticBody3D.new()
	add_child(ground_body)

	var ground_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(220.0, 220.0)
	ground_mesh.mesh = plane
	ground_mesh.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	var ground_material := StandardMaterial3D.new()
	ground_material.albedo_color = Color("#1b232d")
	ground_material.roughness = 1.0
	ground_mesh.material_override = ground_material
	ground_body.add_child(ground_mesh)

	var ground_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(220.0, 0.5, 220.0)
	ground_shape.shape = box
	ground_shape.position = Vector3(0.0, -0.25, 0.0)
	ground_body.add_child(ground_shape)

func _build_route_network() -> void:
	_add_lane_marker(Vector3(0, 0.05, 0), Vector3(190, 0.12, 6.0), Color("#10202b"))
	_add_lane_marker(Vector3(0, 0.05, 28), Vector3(170, 0.12, 5.0), Color("#132430"))
	_add_lane_marker(Vector3(0, 0.05, -30), Vector3(176, 0.12, 5.0), Color("#10202b"))
	_add_lane_marker(Vector3(0, 0.05, 54), Vector3(110, 0.12, 4.5), Color("#172833"))
	_add_lane_marker(Vector3(0, 0.05, -54), Vector3(110, 0.12, 4.5), Color("#172833"))
	_add_lane_marker(Vector3(0, 0.05, 0), Vector3(5.0, 0.12, 118), Color("#14232d"))
	_add_lane_marker(Vector3(56, 0.05, 2), Vector3(5.0, 0.12, 96), Color("#13212c"))
	_add_lane_marker(Vector3(-52, 0.05, -6), Vector3(5.0, 0.12, 102), Color("#162631"))
	_add_lane_marker(Vector3(30, 0.05, -6), Vector3(4.4, 0.12, 64), Color("#172833"))
	_add_lane_marker(Vector3(-24, 0.05, 18), Vector3(4.2, 0.12, 62), Color("#1a2935"))
	_add_fence_line(Vector3(-72, 0.0, 35), 14, Vector3(0.0, 0.0, -5.2), Color("#34434f"))
	_add_fence_line(Vector3(72, 0.0, 40), 14, Vector3(0.0, 0.0, -5.2), Color("#39444f"))
	_add_fence_line(Vector3(-40, 0.0, 70), 16, Vector3(5.0, 0.0, 0.0), Color("#3a4752"))
	_add_fence_line(Vector3(-42, 0.0, -70), 16, Vector3(5.0, 0.0, 0.0), Color("#3a4752"))
	_add_checkpoint_gate(Vector3(44.0, 0.0, 11.5), "CIVIC GATE", Color("#dce3bf"))
	_add_sign_frame(Vector3(-38.0, 1.9, -18.0), "OLD TRANSIT / RELAY", Color("#ffcf8d"))
	_add_sign_frame(Vector3(8.0, 1.9, 28.0), "NORTHLINE CROSSDOCK", Color("#c6dfff"))
	_add_sign_frame(Vector3(58.0, 1.9, 25.0), "BRIGHTLINE CIVIC", Color("#ede1a7"))

func _build_landmarks() -> void:
	_add_block(Vector3(8, 1.5, 16), Vector3(10, 3, 10), Color("#233145"))
	_add_block(Vector3(-14, 1.5, 16), Vector3(10, 3, 10), Color("#243744"))
	_add_block(Vector3(24, 1.5, -12), Vector3(12, 3, 12), Color("#2f283f"))
	_add_block(Vector3(-26, 1.5, -14), Vector3(12, 3, 12), Color("#3d2d25"))
	_add_block(Vector3(42, 1.5, 4), Vector3(8, 3, 8), Color("#1d3343"))
	_add_block(Vector3(-42, 1.5, 6), Vector3(8, 3, 8), Color("#2c3f52"))
	_add_block(Vector3(0, 1.5, 44), Vector3(14, 3, 6), Color("#31404f"))
	_add_block(Vector3(60, 1.7, 18), Vector3(14, 3.4, 12), Color("#2f3942"))
	_add_block(Vector3(72, 1.9, 30), Vector3(10, 3.8, 10), Color("#46525d"))
	_add_block(Vector3(-60, 1.8, -28), Vector3(14, 3.6, 14), Color("#3c342a"))
	_add_block(Vector3(-72, 1.5, -12), Vector3(12, 3.0, 12), Color("#2f343c"))
	_add_block(Vector3(-8, 1.5, 58), Vector3(18, 3.0, 8), Color("#364552"))
	_add_block(Vector3(22, 1.5, 58), Vector3(14, 3.0, 8), Color("#2d3b49"))
	_add_block(Vector3(44, 1.5, -42), Vector3(18, 3.0, 10), Color("#3d322d"))
	_add_block(Vector3(-36, 1.5, 42), Vector3(16, 3.0, 10), Color("#294051"))
	_add_lane_marker(Vector3(0, 0.06, 0), Vector3(60, 0.12, 4), Color("#0f1b25"))
	_add_lane_marker(Vector3(0, 0.06, 20), Vector3(60, 0.12, 3), Color("#13202b"))
	_add_lane_marker(Vector3(0, 0.06, -18), Vector3(60, 0.12, 3), Color("#13202b"))
	_add_lane_marker(Vector3(26, 0.06, 26), Vector3(28, 0.12, 2.5), Color("#162a33"))
	_add_lane_marker(Vector3(-24, 0.06, 28), Vector3(28, 0.12, 2.5), Color("#1a2b3d"))
	_add_street_lamp(Vector3(-6, 0, 4), Color("#f3c56a"))
	_add_street_lamp(Vector3(14, 0, 6), Color("#d7ebff"))
	_add_street_lamp(Vector3(-18, 0, 18), Color("#b7d1ff"))
	_add_street_lamp(Vector3(32, 0, -2), Color("#f0a95d"))
	_add_street_lamp(Vector3(54, 0, 18), Color("#f2efc7"))
	_add_street_lamp(Vector3(62, 0, 30), Color("#f2efc7"))
	_add_street_lamp(Vector3(-42, 0, -12), Color("#ffc27c"))
	_add_street_lamp(Vector3(-60, 0, -24), Color("#ffd48f"))
	_add_street_lamp(Vector3(10, 0, 30), Color("#d3e4ff"))
	_add_street_lamp(Vector3(-8, 0, 46), Color("#9dc3ff"))
	_add_container_stack(Vector3(22, 0, -18), Color("#445768"))
	_add_container_stack(Vector3(-30, 0, 8), Color("#5a4d63"))
	_add_container_stack(Vector3(46, 0, 8), Color("#596470"))
	_add_container_stack(Vector3(-50, 0, -18), Color("#625246"))

func _build_depot_space(position: Vector3) -> void:
	# Keep the spawn lot open: visuals can frame the yard, but the truck needs a clean exit corridor.
	_add_prop(position + Vector3(-16.0, 1.7, -8.5), Vector3(6.5, 3.4, 4.0), Color("#223040"), false)
	_add_prop(position + Vector3(16.0, 1.7, -8.5), Vector3(6.5, 3.4, 4.0), Color("#2d3a49"), false)
	_add_prop(position + Vector3(-15.5, 1.4, -18.0), Vector3(7.5, 2.8, 3.4), Color("#2d3a49"), false)
	_add_prop(position + Vector3(15.5, 1.4, -18.0), Vector3(7.5, 2.8, 3.4), Color("#2d3a49"), false)
	_add_prop(position + Vector3(-19.0, 1.1, 3.0), Vector3(3.2, 2.4, 2.6), Color("#354a59"), true, SPAWN_BLOCKER_LAYER)
	_add_prop(position + Vector3(19.0, 1.1, 3.0), Vector3(3.2, 2.4, 2.6), Color("#354a59"), true, SPAWN_BLOCKER_LAYER)
	_add_prop(position + Vector3(0, 0.45, 10.5), Vector3(11.5, 0.9, 0.65), Color("#6b7580"), false)
	_add_prop(position + Vector3(-9.5, 0.5, 11.5), Vector3(1.2, 1.0, 1.2), Color("#9ab0bf"), false)
	_add_prop(position + Vector3(9.5, 0.5, 11.5), Vector3(1.2, 1.0, 1.2), Color("#9ab0bf"), false)
	_add_prop(position + Vector3(0, 0.1, 7.8), Vector3(10.5, 0.2, 0.45), Color("#253241"), false)
	_add_prop(position + Vector3(0, 0.25, 6.2), Vector3(12.0, 0.4, 0.45), Color("#94a0ae"), false)
	_add_container_stack(position + Vector3(-14.5, 0.9, -2.5), Color("#4d5f72"), false)
	_add_container_stack(position + Vector3(14.5, 0.9, -3.0), Color("#5c4d47"), false)
	_add_street_lamp(position + Vector3(-13.5, 0, 6.0), Color("#ffd684"), false)
	_add_street_lamp(position + Vector3(13.5, 0, 6.0), Color("#ffd684"), false)
	_add_sign_frame(position + Vector3(0, 1.8, -22.0), "DEPOT / SHIFT YARD", Color("#dce7f2"), false)
	_add_cone_line(position + Vector3(-8.0, 0, 9.0), 3, Vector3(2.2, 0.0, 0.0), Color("#ff9c52"), false)
	_add_cone_line(position + Vector3(6.0, 0, 9.0), 3, Vector3(2.2, 0.0, 0.0), Color("#ff9c52"), false)

func _build_delivery_spaces() -> void:
	_build_market_space(Vector3(28, 0, 10))
	_build_flood_space(Vector3(-18, 0, 32))
	_build_dock_space(Vector3(30, 0, -24))
	_build_civic_space(Vector3(56, 0, 22))
	_build_transit_space(Vector3(-58, 0, -30))

func _build_support_hub_spaces() -> void:
	_build_crossdock_space(Vector3(8, 0, 24))
	_build_civic_gate_space(Vector3(44, 0, 8))
	_build_relay_yard_space(Vector3(-36, 0, -12))
	_build_service_apron_space(Vector3(18, 0, -10))

func _build_market_space(position: Vector3) -> void:
	_add_prop_cluster(position, [
		{"offset": Vector3(-5, 0.6, 4), "size": Vector3(1.8, 1.2, 1.0), "color": Color("#435566")},
		{"offset": Vector3(-3, 0.45, 3), "size": Vector3(1.2, 0.9, 1.0), "color": Color("#56697c")},
		{"offset": Vector3(3, 0.5, 4), "size": Vector3(2.0, 1.0, 1.2), "color": Color("#4d5f72")},
		{"offset": Vector3(5, 0.5, 2), "size": Vector3(1.6, 0.8, 1.2), "color": Color("#344454")}
	], "market")
	_add_beacon_light(position + Vector3(0, 4.0, 0), Color(0.52, 0.87, 0.58), 1.1, 16.0)

func _build_flood_space(position: Vector3) -> void:
	_add_prop_cluster(position, [
		{"offset": Vector3(-4, 0.25, 5), "size": Vector3(1.0, 0.5, 2.2), "color": Color("#2f4d5f")},
		{"offset": Vector3(-2, 0.5, 3), "size": Vector3(0.9, 1.0, 0.9), "color": Color("#415e71")},
		{"offset": Vector3(4, 0.35, 4), "size": Vector3(1.1, 0.7, 2.4), "color": Color("#2d3f54")},
		{"offset": Vector3(2, 0.45, 1), "size": Vector3(1.5, 0.9, 0.8), "color": Color("#5e7f95")}
	], "flood")
	_add_beacon_light(position + Vector3(0, 4.4, 0), Color(0.45, 0.72, 1.0), 1.0, 18.0)

func _build_dock_space(position: Vector3) -> void:
	_add_prop_cluster(position, [
		{"offset": Vector3(-5, 0.9, -4), "size": Vector3(3.2, 1.8, 1.2), "color": Color("#45525f")},
		{"offset": Vector3(-1, 0.9, -4.3), "size": Vector3(3.2, 1.8, 1.2), "color": Color("#304150")},
		{"offset": Vector3(4.5, 0.8, -4.1), "size": Vector3(2.4, 1.6, 1.0), "color": Color("#6a5546")},
		{"offset": Vector3(0, 0.5, 4.8), "size": Vector3(2.4, 1.0, 1.0), "color": Color("#4d3e38")}
	], "dock")
	_add_beacon_light(position + Vector3(0, 4.2, 0), Color(0.94, 0.67, 0.35), 1.2, 18.0)

func _build_civic_space(position: Vector3) -> void:
	_add_prop_cluster(position, [
		{"offset": Vector3(-6, 0.7, -4), "size": Vector3(2.4, 1.4, 1.0), "color": Color("#5e676f")},
		{"offset": Vector3(-2, 0.9, -4.5), "size": Vector3(2.4, 1.8, 1.0), "color": Color("#79858f")},
		{"offset": Vector3(3.5, 0.8, -4.2), "size": Vector3(2.0, 1.6, 1.0), "color": Color("#5e686f")},
		{"offset": Vector3(0, 0.4, 5.4), "size": Vector3(4.8, 0.8, 1.4), "color": Color("#73808a")}
	], "civic")
	_add_beacon_light(position + Vector3(0, 4.4, 0), Color(0.92, 0.84, 0.52), 1.1, 18.0)
	_add_sign_frame(position + Vector3(0, 1.9, -6.6), "PERMIT DROP", Color("#f4efcb"))

func _build_transit_space(position: Vector3) -> void:
	_add_prop_cluster(position, [
		{"offset": Vector3(-6, 1.0, -4), "size": Vector3(3.4, 2.0, 1.3), "color": Color("#413a31")},
		{"offset": Vector3(-1, 0.8, -4.4), "size": Vector3(2.6, 1.6, 1.2), "color": Color("#5e523f")},
		{"offset": Vector3(4.2, 0.9, -4.1), "size": Vector3(2.6, 1.8, 1.1), "color": Color("#665948")},
		{"offset": Vector3(0, 0.5, 4.8), "size": Vector3(5.0, 1.0, 1.2), "color": Color("#3a3530")}
	], "transit")
	_add_beacon_light(position + Vector3(0, 4.0, 0), Color(0.88, 0.63, 0.34), 1.0, 16.0)
	_add_sign_frame(position + Vector3(0, 1.9, -6.8), "RELAY DROP", Color("#f4bd83"))

func _build_crossdock_space(position: Vector3) -> void:
	_add_prop(position + Vector3(-5.5, 1.0, -4.0), Vector3(3.6, 2.0, 1.2), Color("#41586f"))
	_add_prop(position + Vector3(5.5, 1.0, -4.0), Vector3(3.6, 2.0, 1.2), Color("#485f78"))
	_add_prop(position + Vector3(0, 0.4, 5.0), Vector3(9.0, 0.8, 1.0), Color("#5b6e7e"))
	_add_cone_line(position + Vector3(-4.0, 0.0, 3.2), 4, Vector3(2.6, 0.0, 0.0), Color("#ff9e52"))
	_add_beacon_light(position + Vector3(0, 3.8, 0), Color(0.58, 0.78, 1.0), 1.0, 14.0)

func _build_civic_gate_space(position: Vector3) -> void:
	_add_checkpoint_gate(position + Vector3(0, 0, -1.5), "COMPLIANCE GATE", Color("#efe7b2"))
	_add_prop(position + Vector3(-5.0, 0.6, 3.2), Vector3(2.0, 1.2, 1.0), Color("#6f757b"))
	_add_prop(position + Vector3(5.0, 0.6, 3.2), Vector3(2.0, 1.2, 1.0), Color("#6f757b"))
	_add_beacon_light(position + Vector3(0, 4.2, 0), Color(0.95, 0.9, 0.62), 1.0, 14.0)

func _build_relay_yard_space(position: Vector3) -> void:
	_add_prop(position + Vector3(-5.5, 0.9, -4.0), Vector3(3.2, 1.8, 1.2), Color("#564b3d"))
	_add_prop(position + Vector3(5.0, 0.9, -4.0), Vector3(3.0, 1.8, 1.2), Color("#453d34"))
	_add_container_stack(position + Vector3(0.0, 0.0, 5.2), Color("#5c4b41"), false)
	_add_sign_frame(position + Vector3(0.0, 1.7, -6.6), "RELAY YARD", Color("#ffc983"))
	_add_beacon_light(position + Vector3(0, 3.8, 0), Color(0.93, 0.7, 0.42), 0.95, 14.0)

func _build_service_apron_space(position: Vector3) -> void:
	_add_prop(position + Vector3(-4.0, 0.7, -3.2), Vector3(2.4, 1.4, 1.0), Color("#4b4f58"))
	_add_prop(position + Vector3(4.0, 0.7, -3.2), Vector3(2.4, 1.4, 1.0), Color("#4b4f58"))
	_add_prop(position + Vector3(0.0, 0.4, 4.5), Vector3(8.0, 0.8, 1.0), Color("#6b5c4c"))
	_add_cone_line(position + Vector3(-3.0, 0.0, 2.8), 3, Vector3(3.0, 0.0, 0.0), Color("#ff9956"))
	_add_beacon_light(position + Vector3(0, 3.4, 0), Color(0.96, 0.58, 0.3), 0.92, 12.0)

func _add_prop_cluster(origin: Vector3, props: Array, kind: String) -> void:
	for prop in props:
		var offset: Vector3 = prop.get("offset", Vector3.ZERO)
		var size: Vector3 = prop.get("size", Vector3.ONE)
		var color: Color = prop.get("color", Color.WHITE)
		_add_prop(origin + offset, size, color)
	match kind:
		"market":
			_add_prop(origin + Vector3(0, 0.3, 6.5), Vector3(8, 0.3, 0.45), Color("#8a6b4d"))
			_add_prop(origin + Vector3(0, 1.2, 6.5), Vector3(8, 0.15, 0.25), Color("#c8a36b"))
		"flood":
			_add_prop(origin + Vector3(0, 0.18, 6.4), Vector3(7.8, 0.18, 0.5), Color("#53758b"))
			_add_prop(origin + Vector3(-5.8, 0.35, 6.2), Vector3(1.0, 0.7, 0.7), Color("#89a4bb"))
		"dock":
			_add_prop(origin + Vector3(-7.0, 1.0, 5.5), Vector3(2.4, 2.0, 1.2), Color("#2f3e4d"))
			_add_prop(origin + Vector3(7.0, 1.0, 5.5), Vector3(2.4, 2.0, 1.2), Color("#364753"))
		"civic":
			_add_prop(origin + Vector3(0, 0.22, 6.6), Vector3(8.4, 0.22, 0.55), Color("#c4c6bd"))
			_add_prop(origin + Vector3(-6.0, 0.6, 5.8), Vector3(1.0, 1.2, 0.8), Color("#6f757b"))
			_add_prop(origin + Vector3(6.0, 0.6, 5.8), Vector3(1.0, 1.2, 0.8), Color("#6f757b"))
		"transit":
			_add_prop(origin + Vector3(0, 0.25, 6.4), Vector3(8.6, 0.25, 0.6), Color("#6c5942"))
			_add_prop(origin + Vector3(-5.8, 0.45, 5.6), Vector3(1.2, 0.9, 0.8), Color("#4b4338"))
			_add_prop(origin + Vector3(5.8, 0.45, 5.6), Vector3(1.2, 0.9, 0.8), Color("#4b4338"))

func _add_prop(position: Vector3, size: Vector3, color: Color, with_collision := true, collision_layer := 1) -> void:
	var prop := StaticBody3D.new()
	prop.position = position
	prop.collision_layer = collision_layer
	if collision_layer == SPAWN_BLOCKER_LAYER:
		prop.add_to_group("spawn_blocker")
	add_child(prop)

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	mesh.material_override = material
	prop.add_child(mesh)

	if with_collision:
		var shape := CollisionShape3D.new()
		var collision_box := BoxShape3D.new()
		collision_box.size = size
		shape.shape = collision_box
		prop.add_child(shape)

func _add_beacon_light(position: Vector3, color: Color, energy: float, range_value: float) -> void:
	var light := OmniLight3D.new()
	light.position = position
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_value
	add_child(light)

func _add_street_lamp(position: Vector3, color: Color, with_collision := false) -> void:
	var pole := StaticBody3D.new()
	pole.position = position
	add_child(pole)

	var pole_mesh := MeshInstance3D.new()
	var shaft := CylinderMesh.new()
	shaft.top_radius = 0.12
	shaft.bottom_radius = 0.14
	shaft.height = 3.4
	pole_mesh.mesh = shaft
	var pole_material := StandardMaterial3D.new()
	pole_material.albedo_color = Color("#2d3947")
	pole_material.roughness = 0.9
	pole_mesh.material_override = pole_material
	pole_mesh.position = Vector3(0, 1.7, 0)
	pole.add_child(pole_mesh)
	if with_collision:
		var pole_shape := CollisionShape3D.new()
		var pole_box := CylinderShape3D.new()
		pole_box.radius = 0.15
		pole_box.height = 3.4
		pole_shape.shape = pole_box
		pole_shape.position = Vector3(0, 1.7, 0)
		pole.add_child(pole_shape)

	var light := OmniLight3D.new()
	light.position = Vector3(0, 3.4, 0)
	light.light_color = color
	light.light_energy = 0.65
	light.omni_range = 10.0
	pole.add_child(light)

func _add_sign_frame(position: Vector3, text: String, color: Color, with_collision := false) -> void:
	var sign_base := StaticBody3D.new()
	sign_base.position = position
	add_child(sign_base)

	var board := MeshInstance3D.new()
	var board_mesh := BoxMesh.new()
	board_mesh.size = Vector3(5.5, 0.35, 0.25)
	board.mesh = board_mesh
	var board_material := StandardMaterial3D.new()
	board_material.albedo_color = Color("#1f2933")
	board_material.roughness = 0.85
	board_material.emission_enabled = true
	board_material.emission = color
	board_material.emission_energy_multiplier = 0.15
	board.material_override = board_material
	sign_base.add_child(board)
	if with_collision:
		var board_shape := CollisionShape3D.new()
		var board_box := BoxShape3D.new()
		board_box.size = Vector3(5.5, 0.35, 0.25)
		board_shape.shape = board_box
		sign_base.add_child(board_shape)

	var label := Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0.45, 0)
	label.modulate = color
	label.pixel_size = 0.012
	sign_base.add_child(label)

func _add_cone_line(start_position: Vector3, count: int, step: Vector3, color: Color, with_collision := false) -> void:
	for index in range(count):
		var cone := MeshInstance3D.new()
		var cone_mesh := CylinderMesh.new()
		cone_mesh.top_radius = 0.08
		cone_mesh.bottom_radius = 0.24
		cone_mesh.height = 0.45
		cone_mesh.radial_segments = 8
		cone.mesh = cone_mesh
		var cone_material := StandardMaterial3D.new()
		cone_material.albedo_color = color
		cone_material.roughness = 0.88
		cone.material_override = cone_material
		cone.position = start_position + step * float(index)
		add_child(cone)
		if with_collision:
			var cone_body := StaticBody3D.new()
			cone_body.position = cone.position
			add_child(cone_body)

func _add_fence_line(start_position: Vector3, count: int, step: Vector3, color: Color) -> void:
	for index in range(count):
		var post := MeshInstance3D.new()
		var post_mesh := BoxMesh.new()
		post_mesh.size = Vector3(0.18, 1.2, 0.18)
		post.mesh = post_mesh
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.9
		post.material_override = material
		post.position = start_position + step * float(index) + Vector3(0.0, 0.6, 0.0)
		add_child(post)
		if index < count - 1:
			var rail := MeshInstance3D.new()
			var rail_mesh := BoxMesh.new()
			var span := step.length()
			if absf(step.x) > absf(step.z):
				rail_mesh.size = Vector3(span, 0.08, 0.12)
			else:
				rail_mesh.size = Vector3(0.12, 0.08, span)
			rail.mesh = rail_mesh
			rail.material_override = material
			rail.position = start_position + step * float(index) + step * 0.5 + Vector3(0.0, 0.9, 0.0)
			add_child(rail)

func _add_checkpoint_gate(position: Vector3, text: String, color: Color) -> void:
	_add_prop(position + Vector3(-3.0, 1.2, 0.0), Vector3(0.35, 2.4, 0.35), Color("#5f666d"))
	_add_prop(position + Vector3(3.0, 1.2, 0.0), Vector3(0.35, 2.4, 0.35), Color("#5f666d"))
	_add_prop(position + Vector3(0.0, 2.3, 0.0), Vector3(6.6, 0.28, 0.35), Color("#b8bba8"))
	_add_sign_frame(position + Vector3(0.0, 0.1, 0.0), text, color)

func _build_wayfinding() -> void:
	_add_sign_frame(Vector3(0.0, 1.9, 12.0), "MARKET NINE / FLOODLINE", Color("#bfe5c5"))
	_add_sign_frame(Vector3(20.0, 1.9, -6.0), "DOCKSIDE / SERVICE APRON", Color("#f0bc96"))
	_add_sign_frame(Vector3(46.0, 1.9, 2.0), "BRIGHTLINE / GATE", Color("#eee5ab"))
	_add_sign_frame(Vector3(-34.0, 1.9, -2.0), "OLD TRANSIT / CUT", Color("#ffca8d"))

func _build_world_life() -> void:
	_spawn_ambient_actor("worker", [
		Vector3(-3.0, 0.55, -5.0),
		Vector3(3.0, 0.55, -5.0),
		Vector3(4.0, 0.55, 4.0),
		Vector3(-4.0, 0.55, 4.0)
	], 1.7)
	_spawn_ambient_actor("worker", [
		Vector3(6.0, 0.55, 20.0),
		Vector3(11.0, 0.55, 20.0),
		Vector3(11.0, 0.55, 27.0),
		Vector3(6.0, 0.55, 27.0)
	], 1.6)
	_spawn_ambient_actor("forklift", [
		Vector3(14.0, 0.45, -12.0),
		Vector3(22.0, 0.45, -12.0),
		Vector3(22.0, 0.45, -6.0),
		Vector3(14.0, 0.45, -6.0)
	], 1.2)
	_spawn_ambient_actor("worker", [
		Vector3(41.0, 0.55, 8.0),
		Vector3(47.0, 0.55, 8.0),
		Vector3(47.0, 0.55, 15.0),
		Vector3(41.0, 0.55, 15.0)
	], 1.5)
	_spawn_ambient_actor("worker", [
		Vector3(-39.0, 0.55, -16.0),
		Vector3(-33.0, 0.55, -16.0),
		Vector3(-33.0, 0.55, -8.0),
		Vector3(-39.0, 0.55, -8.0)
	], 1.45)
	_spawn_ambient_actor("van", [
		Vector3(-18.0, 0.45, 26.0),
		Vector3(6.0, 0.45, 26.0),
		Vector3(30.0, 0.45, 26.0),
		Vector3(52.0, 0.45, 22.0),
		Vector3(38.0, 0.45, 6.0),
		Vector3(10.0, 0.45, 0.0),
		Vector3(-16.0, 0.45, 8.0)
	], 3.0)
	_spawn_ambient_actor("van", [
		Vector3(22.0, 0.45, -18.0),
		Vector3(6.0, 0.45, -28.0),
		Vector3(-18.0, 0.45, -28.0),
		Vector3(-36.0, 0.45, -18.0),
		Vector3(-52.0, 0.45, -28.0),
		Vector3(-42.0, 0.45, -46.0),
		Vector3(-8.0, 0.45, -48.0),
		Vector3(26.0, 0.45, -42.0)
	], 3.3)

func _spawn_ambient_actor(actor_kind: String, points: Array[Vector3], speed: float) -> void:
	var actor := AmbientActor.new()
	actor.actor_kind = actor_kind
	actor.loop_points = points
	actor.move_speed = speed
	add_child(actor)
	ambient_actors.append(actor)

func _add_container_stack(position: Vector3, color: Color, with_collision := true, collision_layer := 1) -> void:
	_add_prop(position + Vector3(0, 0.75, 0), Vector3(2.6, 1.5, 1.1), color, with_collision, collision_layer)
	_add_prop(position + Vector3(2.8, 0.55, 0.3), Vector3(2.1, 1.1, 1.0), color.lightened(0.08), with_collision, collision_layer)
	_add_prop(position + Vector3(-2.6, 0.55, -0.3), Vector3(1.9, 1.1, 0.95), color.darkened(0.08), with_collision, collision_layer)

func _add_block(position: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = position
	add_child(body)

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.95
	mesh.material_override = material
	body.add_child(mesh)

	var shape := CollisionShape3D.new()
	var collision_box := BoxShape3D.new()
	collision_box.size = size
	shape.shape = collision_box
	body.add_child(shape)

func _add_lane_marker(position: Vector3, size: Vector3, color: Color, with_collision := false) -> void:
	var body := StaticBody3D.new()
	body.position = position
	add_child(body)

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	mesh.material_override = material
	body.add_child(mesh)

	if with_collision:
		var shape := CollisionShape3D.new()
		var collision_box := BoxShape3D.new()
		collision_box.size = size
		shape.shape = collision_box
		body.add_child(shape)

func _build_truck() -> void:
	truck = TruckController.new()
	truck.position = SPAWN_SAFE_CENTER
	truck.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	truck.add_to_group("truck")
	add_child(truck)

	truck_body_mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.3, 1.5, 4.2)
	truck_body_mesh.mesh = box
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color("#8f9ba8")
	body_material.roughness = 0.7
	truck_body_mesh.material_override = body_material
	truck.add_child(truck_body_mesh)

	truck_bed_mesh = MeshInstance3D.new()
	var bed_box := BoxMesh.new()
	bed_box.size = Vector3(2.1, 0.55, 2.4)
	truck_bed_mesh.mesh = bed_box
	truck_bed_mesh.position = Vector3(0.0, -0.15, 0.9)
	var bed_material := StandardMaterial3D.new()
	bed_material.albedo_color = Color("#6b7580")
	bed_material.roughness = 0.85
	truck_bed_mesh.material_override = bed_material
	truck.add_child(truck_bed_mesh)

	truck_cabin_mesh = MeshInstance3D.new()
	var cabin_box := BoxMesh.new()
	cabin_box.size = Vector3(2.0, 1.6, 1.8)
	truck_cabin_mesh.mesh = cabin_box
	truck_cabin_mesh.position = Vector3(0.0, 0.3, -1.0)
	var cabin_material := StandardMaterial3D.new()
	cabin_material.albedo_color = Color("#495b70")
	cabin_material.roughness = 0.65
	truck_cabin_mesh.material_override = cabin_material
	truck.add_child(truck_cabin_mesh)

	truck_front_left_wheel = _make_wheel(Vector3(-1.1, -0.65, -1.35))
	truck_front_right_wheel = _make_wheel(Vector3(1.1, -0.65, -1.35))
	truck_rear_left_wheel = _make_wheel(Vector3(-1.1, -0.65, 1.25))
	truck_rear_right_wheel = _make_wheel(Vector3(1.1, -0.65, 1.25))
	truck.add_child(truck_front_left_wheel)
	truck.add_child(truck_front_right_wheel)
	truck.add_child(truck_rear_left_wheel)
	truck.add_child(truck_rear_right_wheel)

	truck_left_headlight = SpotLight3D.new()
	truck_left_headlight.position = Vector3(-0.65, 0.5, -2.0)
	truck_left_headlight.rotation_degrees = Vector3(-10.0, 180.0, 0.0)
	truck_left_headlight.spot_angle = 28.0
	truck_left_headlight.light_energy = 0.8
	truck_left_headlight.light_color = Color("#fff0c9")
	truck.add_child(truck_left_headlight)

	truck_right_headlight = SpotLight3D.new()
	truck_right_headlight.position = Vector3(0.65, 0.5, -2.0)
	truck_right_headlight.rotation_degrees = Vector3(-10.0, 180.0, 0.0)
	truck_right_headlight.spot_angle = 28.0
	truck_right_headlight.light_energy = 0.8
	truck_right_headlight.light_color = Color("#fff0c9")
	truck.add_child(truck_right_headlight)

	truck_brake_light_left = OmniLight3D.new()
	truck_brake_light_left.position = Vector3(-0.65, 0.2, 2.1)
	truck_brake_light_left.omni_range = 3.5
	truck_brake_light_left.light_energy = 0.0
	truck_brake_light_left.light_color = Color("#ff4c3c")
	truck.add_child(truck_brake_light_left)

	truck_brake_light_right = OmniLight3D.new()
	truck_brake_light_right.position = Vector3(0.65, 0.2, 2.1)
	truck_brake_light_right.omni_range = 3.5
	truck_brake_light_right.light_energy = 0.0
	truck_brake_light_right.light_color = Color("#ff4c3c")
	truck.add_child(truck_brake_light_right)

	var collision := CollisionShape3D.new()
	var collision_box := BoxShape3D.new()
	collision_box.size = SPAWN_TRUCK_SIZE
	collision.shape = collision_box
	collision.position = Vector3(0.0, 0.0, 0.0)
	truck.add_child(collision)

	truck_spring_arm = SpringArm3D.new()
	truck_spring_arm.spring_length = 7.0
	truck_spring_arm.position = Vector3(0.0, 2.5, 0.5)
	truck_spring_arm.rotation_degrees = Vector3(-10.0, 180.0, 0.0)
	truck.add_child(truck_spring_arm)

	truck_camera = Camera3D.new()
	truck_camera.current = true
	truck_camera.position = Vector3(0.0, 0.0, 0.0)
	truck_camera.fov = 70.0
	truck_spring_arm.add_child(truck_camera)

func _make_wheel(position: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = position

	var wheel := MeshInstance3D.new()
	var wheel_mesh := CylinderMesh.new()
	wheel_mesh.top_radius = 0.38
	wheel_mesh.bottom_radius = 0.38
	wheel_mesh.height = 0.3
	wheel_mesh.radial_segments = 12
	wheel.mesh = wheel_mesh
	var wheel_material := StandardMaterial3D.new()
	wheel_material.albedo_color = Color("#15191f")
	wheel_material.roughness = 0.9
	wheel.material_override = wheel_material
	wheel.rotation_degrees = Vector3(0.0, 0.0, 90.0)
	pivot.add_child(wheel)
	return pivot

func _build_zones() -> void:
	for spec in DISTRICT_ZONE_SPECS:
		_create_zone(
			StringName(spec["zone_id"]),
			str(spec["district"]),
			str(spec["label"]),
			spec["position"],
			spec["color"],
			float(spec.get("radius", 4.0)),
			false
		)
	for spec in SERVICE_HUB_SPECS:
		_create_zone(
			StringName(spec["zone_id"]),
			str(spec["district"]),
			str(spec["label"]),
			spec["position"],
			spec["color"],
			float(spec.get("radius", 3.2)),
			true
		)

func _build_audio() -> void:
	audio_director = LogisticsAudio.new()
	add_child(audio_director)

func _initialize_district_state() -> void:
	for district_name in LogisticsDefs.get_district_names():
		district_mood[district_name] = 0
		district_reputation[district_name] = 0
		district_visit_count[district_name] = 0
		district_mastery[district_name] = 0

func _refresh_contract_board() -> void:
	contracts.clear()
	var district_rotation := _district_rotation_names()
	featured_district = district_rotation[board_cycle % district_rotation.size()]
	for index in range(base_contracts.size()):
		var contract: Dictionary = base_contracts[index].duplicate(true)
		var modifier: Dictionary = OFFER_MODIFIERS[(board_cycle + index) % OFFER_MODIFIERS.size()]
		_apply_offer_modifier(contract, modifier)
		contracts.append(contract)

func _apply_offer_modifier(contract: Dictionary, modifier: Dictionary) -> void:
	contract["offer_modifier"] = str(modifier.get("name", "Standard Board"))
	contract["offer_note"] = str(modifier.get("note", ""))
	contract["reward"] = max(40, int(roundf(float(contract.get("reward", 0)) * float(modifier.get("reward_multiplier", 1.0)))))
	contract["target_time"] = maxf(18.0, float(contract.get("target_time", 30.0)) + float(modifier.get("target_time_shift", 0.0)))
	contract["on_time_bonus"] = max(0, int(contract.get("on_time_bonus", 0)) + int(modifier.get("bonus_shift", 0)))
	contract["late_penalty"] = max(0, int(contract.get("late_penalty", 0)) + int(modifier.get("penalty_shift", 0)))
	var route_profile: Dictionary = contract.get("route_profile", {}).duplicate(true)
	route_profile["speed_cap_multiplier"] = float(route_profile.get("speed_cap_multiplier", 1.0)) * float(modifier.get("speed_multiplier", 1.0))
	route_profile["steering_multiplier"] = float(route_profile.get("steering_multiplier", 1.0)) * float(modifier.get("steering_multiplier", 1.0))
	route_profile["cargo_stress_multiplier"] = float(route_profile.get("cargo_stress_multiplier", 1.0)) * float(modifier.get("stress_multiplier", 1.0))
	route_profile["cargo_recovery_multiplier"] = float(route_profile.get("cargo_recovery_multiplier", 1.0)) * float(modifier.get("recovery_multiplier", 1.0))
	contract["route_profile"] = route_profile
	contract["featured_board"] = str(contract.get("district", "")) == featured_district
	if bool(contract.get("featured_board", false)):
		contract["reward"] = int(contract.get("reward", 0)) + 36
		var offer_note := str(contract.get("offer_note", "")).strip_edges()
		if offer_note.is_empty():
			contract["offer_note"] = "Featured district payout is hot tonight."
		else:
			contract["offer_note"] = "%s / Featured district payout is hot tonight." % offer_note

func _create_zone(zone_id: StringName, district_name: String, zone_label: String, position: Vector3, color: Color, radius: float, is_service := false) -> void:
	var zone := DeliveryZone.new()
	zone.zone_id = zone_id
	zone.district_name = district_name
	zone.zone_label = zone_label
	zone.zone_color = color
	zone.zone_radius = radius
	zone.position = position
	zone.truck_entered.connect(_on_zone_truck_entered)
	zone.truck_exited.connect(_on_zone_truck_exited)
	add_child(zone)
	delivery_zones.append(zone)
	if is_service:
		service_zone_lookup[zone_id] = zone
	else:
		district_zone_lookup[district_name] = zone

func _build_hud() -> void:
	hud = LogisticsHUD.new()
	add_child(hud)
	hud.set_hint("1-5 select a contract. Enter starts the shift. E confirms staging and deliveries.")
	hud.set_help_text("1-5 = select contract\nEnter = start / confirm\nWASD = drive\nSpace = handbrake\nE = staging / deliver\nR = reset spawn\nH = hide help")
	hud.set_help_visible(true)
	hud.set_brief_visible(true)
	hud.set_contract_list_visible(true)
	hud.flash(Color(0.7, 0.8, 1.0), 0.18, 0.1)
	hud.set_route_detail("Select a job to read the route tradeoff.")
	hud.set_cargo_detail("Cargo notes appear here during the shift.")
	hud.set_shift_brief("The shift brief will summarize route, cargo, and district pressure.")

func _build_spawn_debug_overlay() -> void:
	spawn_debug_root = Node3D.new()
	spawn_debug_root.visible = spawn_debug_visible
	add_child(spawn_debug_root)
	_refresh_spawn_debug_overlay()

func _refresh_spawn_debug_overlay() -> void:
	if spawn_debug_root == null:
		return
	for child in spawn_debug_root.get_children():
		child.queue_free()
	_add_debug_volume(spawn_debug_root, SPAWN_SAFE_CENTER, SPAWN_SAFE_SIZE, Color(0.2, 0.9, 0.45, 0.16))
	_add_debug_volume(spawn_debug_root, SPAWN_EXIT_CENTER, SPAWN_EXIT_SIZE, Color(0.25, 0.6, 1.0, 0.12))
	_add_debug_truck_volume(spawn_debug_root, last_valid_spawn_transform.origin, SPAWN_TRUCK_SIZE, Color(1.0, 0.85, 0.2, 0.18))
	for blocker in get_tree().get_nodes_in_group("spawn_blocker"):
		if blocker is Node3D:
			var blocker_node := blocker as Node3D
			var size := _get_blocker_size(blocker_node)
			if size != Vector3.ZERO:
				_add_debug_volume(spawn_debug_root, blocker_node.global_position, size, Color(1.0, 0.25, 0.2, 0.24))

func _add_debug_volume(parent: Node3D, center: Vector3, size: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = material
	mesh.position = center
	parent.add_child(mesh)

func _add_debug_truck_volume(parent: Node3D, center: Vector3, size: Vector3, color: Color) -> void:
	_add_debug_volume(parent, center, size, color)

func _get_blocker_size(blocker: Node3D) -> Vector3:
	var shape_node := blocker.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if shape_node == null:
		for child in blocker.get_children():
			if child is CollisionShape3D:
				shape_node = child as CollisionShape3D
				break
	if shape_node == null or shape_node.shape == null:
		return Vector3.ZERO
	if shape_node.shape is BoxShape3D:
		return (shape_node.shape as BoxShape3D).size
	if shape_node.shape is CylinderShape3D:
		var cylinder := shape_node.shape as CylinderShape3D
		return Vector3(cylinder.radius * 2.0, cylinder.height, cylinder.radius * 2.0)
	return Vector3.ZERO

func _toggle_spawn_debug_overlay() -> void:
	spawn_debug_visible = not spawn_debug_visible
	if spawn_debug_root != null:
		spawn_debug_root.visible = spawn_debug_visible
		if spawn_debug_visible:
			_refresh_spawn_debug_overlay()
	_update_status("Spawn debug overlay %s." % ("on" if spawn_debug_visible else "off"))

func _validate_spawn_candidate(candidate: Vector3) -> bool:
	if truck == null:
		return false
	var state := get_world_3d().direct_space_state
	if state == null:
		return false
	var safe_query := PhysicsShapeQueryParameters3D.new()
	var safe_shape := BoxShape3D.new()
	safe_shape.size = SPAWN_SAFE_SIZE
	safe_query.shape = safe_shape
	safe_query.transform = Transform3D(Basis.IDENTITY, candidate)
	safe_query.collision_mask = SPAWN_BLOCKER_LAYER
	safe_query.collide_with_areas = false
	safe_query.collide_with_bodies = true
	if not state.intersect_shape(safe_query, 8).is_empty():
		return false
	var truck_query := PhysicsShapeQueryParameters3D.new()
	var truck_shape := BoxShape3D.new()
	truck_shape.size = SPAWN_TRUCK_SIZE + Vector3(0.75, 0.35, 0.9)
	truck_query.shape = truck_shape
	truck_query.transform = Transform3D(Basis.IDENTITY, candidate)
	truck_query.collision_mask = SPAWN_BLOCKER_LAYER
	truck_query.collide_with_areas = false
	truck_query.collide_with_bodies = true
	if not state.intersect_shape(truck_query, 8).is_empty():
		return false
	var corridor_center := candidate + Vector3(0.0, 0.0, 10.0)
	var corridor_query := PhysicsShapeQueryParameters3D.new()
	var corridor_shape := BoxShape3D.new()
	corridor_shape.size = SPAWN_EXIT_SIZE
	corridor_query.shape = corridor_shape
	corridor_query.transform = Transform3D(Basis.IDENTITY, corridor_center)
	corridor_query.collision_mask = SPAWN_BLOCKER_LAYER
	corridor_query.collide_with_areas = false
	corridor_query.collide_with_bodies = true
	if not state.intersect_shape(corridor_query, 8).is_empty():
		return false
	return true

func _find_valid_spawn_transform() -> Transform3D:
	for candidate in SPAWN_CANDIDATES:
		if _validate_spawn_candidate(candidate):
			return Transform3D(Basis.IDENTITY, candidate)
	return Transform3D(Basis.IDENTITY, SPAWN_CANDIDATES[0])

func _finalize_spawn_position() -> void:
	last_valid_spawn_transform = _find_valid_spawn_transform()
	_apply_spawn_transform(last_valid_spawn_transform)
	_refresh_spawn_debug_overlay()
	_update_status("Spawn validated. Exit corridor is clear.")

func _apply_spawn_transform(spawn_transform: Transform3D) -> void:
	if truck == null:
		return
	truck.global_transform = spawn_transform
	truck.velocity = Vector3.ZERO
	truck.current_speed = 0.0
	truck.set_driving_enabled(shift_state == ShiftState.DRIVING)

func _reset_to_last_valid_spawn() -> void:
	if truck == null:
		return
	_apply_spawn_transform(last_valid_spawn_transform)
	_update_status("Returned to last valid spawn.")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_reset_spawn"):
		_reset_to_last_valid_spawn()
	if Input.is_action_just_pressed("debug_toggle_spawn_overlay"):
		_toggle_spawn_debug_overlay()
	if Input.is_action_just_pressed("toggle_help"):
		hud.toggle_help()

	_update_truck_juice(delta)
	_update_audio_state()
	_update_district_presentations()

	if shift_state == ShiftState.SELECTING:
		_handle_contract_selection()
		return

	if shift_state == ShiftState.DRIVING:
		shift_time += delta
		_update_shift_events()
		_update_drive_hud()
		_check_cargo_pressure()
		if truck.get_stability_percent() <= 0.0:
			_fail_shift("Cargo ruined before delivery.")
			return
		if Input.is_action_just_pressed("interact"):
			_try_complete_delivery()
		return

	if shift_state == ShiftState.SUMMARY:
		if Input.is_action_just_pressed("interact"):
			_reset_to_selection()

func _handle_contract_selection() -> void:
	if Input.is_action_just_pressed("route_1"):
		_apply_contract_selection(0)
	if Input.is_action_just_pressed("route_2"):
		_apply_contract_selection(1)
	if Input.is_action_just_pressed("route_3"):
		_apply_contract_selection(2)
	if Input.is_action_just_pressed("route_4"):
		_apply_contract_selection(3)
	if Input.is_action_just_pressed("route_5"):
		_apply_contract_selection(4)
	if Input.is_action_just_pressed("interact"):
		_start_shift()

func _apply_contract_selection(index: int) -> void:
	selected_contract_index = clampi(index, 0, contracts.size() - 1)
	var contract: Dictionary = contracts[selected_contract_index]
	var unlocked := _is_contract_unlocked(contract)
	var district_name := str(contract["district"])
	var client_name := str(contract.get("client", "Northline Dispatch"))
	var client_profile := LogisticsDefs.get_client_profile(client_name)
	var cargo_name := str(contract.get("cargo", "Unknown"))
	var visits := int(district_visit_count.get(district_name, 0))
	var route_note := str(contract.get("route_note", ""))
	var cargo_note := str(contract.get("cargo_note", ""))
	var pickup_note := str(contract.get("pickup_note", ""))
	var handoff_note := str(contract.get("handoff_note", ""))
	var offer_modifier := str(contract.get("offer_modifier", "Standard Board"))
	var offer_note := str(contract.get("offer_note", ""))
	hud.set_contract_list(_contract_lines(), selected_contract_index)
	hud.set_client_state("%s | %s" % [client_name, str(client_profile.get("tone", ""))])
	hud.set_route_state(contract["route"], contract["route_type"], contract["district"])
	hud.set_district_state(_district_status_text(district_name))
	var route_detail := "%s | %s" % [offer_modifier, route_note]
	if bool(contract.get("featured_board", false)):
		route_detail += " | Spotlight %s" % featured_district
	hud.set_route_detail(route_detail)
	hud.set_cargo_detail("%s | %s" % [LogisticsDefs.get_cargo_family_label(cargo_name), cargo_note])
	var shift_brief := "%s / %s / %s" % [str(client_profile.get("brief", "")), route_note, cargo_note]
	if not pickup_note.is_empty():
		shift_brief += " / " + pickup_note
	if not handoff_note.is_empty():
		shift_brief += " / " + handoff_note
	if not offer_note.is_empty():
		shift_brief += " / " + offer_note
	shift_brief += " / " + _contract_schedule_text(contract)
	shift_brief += " / " + _streak_bonus_text()
	hud.set_shift_brief(shift_brief)
	hud.set_phase_state("Selecting | Rank %d | Runs %d | Credits %d" % [_company_level(), completed_shift_count, total_credits])
	if unlocked:
		hud.set_objective("Select this shift, then press Enter to begin.")
	else:
		hud.set_objective(_contract_unlock_requirement_text(contract))
	hud.clear_event_state()
	hud.set_hint("Route memory: %s | %s | %s | Spotlight: %s | %s" % [_route_memory_label(visits), _contract_unlock_requirement_text(contract), _network_activity_text(), featured_district, _streak_bonus_text()])
	hud.set_contract_list_visible(true)
	hud.set_client_visible(true)
	hud.flash(Color(0.55, 0.75, 1.0), 0.12, 0.1)
	if audio_director != null:
		audio_director.play_cue("selection")
	if unlocked:
		_update_status("Selected %s for %s on the %s board. Press Enter to start the shift." % [contract["name"], client_name, offer_modifier])
	else:
		_update_status("%s is locked. %s" % [contract["name"], _contract_unlock_requirement_text(contract)])

func _contract_lines() -> Array[String]:
	var lines: Array[String] = []
	for contract in contracts:
		var client_name := str(contract.get("client", "Northline Dispatch"))
		var cargo_name := str(contract.get("cargo", "Unknown"))
		var line := "%s | %s | %s | %s | %s | %d cr" % [
			contract["name"],
			str(contract.get("offer_modifier", "Standard")),
			client_name,
			LogisticsDefs.get_cargo_family_label(cargo_name),
			contract["district"],
			int(contract["reward"])
		]
		if bool(contract.get("featured_board", false)):
			line += " | HOT"
		if not _is_contract_unlocked(contract):
			line = "[LOCKED] %s" % line
		lines.append(line)
	return lines

func _is_contract_unlocked(contract: Dictionary) -> bool:
	var unlock_after_shifts := int(contract.get("unlock_after_shifts", 0))
	return completed_shift_count >= unlock_after_shifts

func _contract_unlock_requirement_text(contract: Dictionary) -> String:
	var unlock_after_shifts := int(contract.get("unlock_after_shifts", 0))
	if completed_shift_count >= unlock_after_shifts:
		return "Ready to run."
	if unlock_after_shifts <= 1:
		return "Unlocks after 1 completed shift."
	return "Unlocks after %d completed shifts." % unlock_after_shifts

func _start_shift() -> void:
	if not _is_contract_unlocked(contracts[selected_contract_index]):
		_update_status(_contract_unlock_requirement_text(contracts[selected_contract_index]))
		if audio_director != null:
			audio_director.play_cue("wrong_zone")
		return
	active_contract = contracts[selected_contract_index]
	active_client_profile = LogisticsDefs.get_client_profile(str(active_contract.get("client", "Northline Dispatch")))
	active_cargo_profile = LogisticsDefs.get_cargo_profile(str(active_contract.get("cargo", "")))
	active_zone = _find_zone_by_district(str(active_contract["district"]))
	active_pickup_zone = _find_zone_by_id(StringName(str(active_contract.get("pickup_zone", ""))))
	active_pickup_complete = active_pickup_zone == null
	active_stage_zone = _find_zone_by_id(StringName(str(active_contract.get("handoff_zone", ""))))
	active_stage_complete = active_stage_zone == null
	var district_name := str(active_contract["district"])
	var visits := int(district_visit_count.get(district_name, 0))
	var route_profile := _build_shift_profile(active_contract, district_name, visits)
	shift_state = ShiftState.DRIVING
	shift_time = 0.0
	cargo_warnings = 0.0
	truck.reset_truck()
	truck.configure_contract(active_contract)
	truck.apply_cargo_profile(active_cargo_profile)
	truck.apply_route_profile(route_profile)
	truck.clear_event_profile()
	truck.cargo_sensitivity += min(float(visits) * 0.04, 0.12)
	_apply_spawn_transform(last_valid_spawn_transform)
	truck.set_driving_enabled(true)
	hud.set_phase_state("Driving")
	hud.set_client_state("%s | %s" % [str(active_contract.get("client", "Northline Dispatch")), str(active_client_profile.get("tone", ""))])
	var route_detail := "%s | %s" % [str(active_contract.get("offer_modifier", "Standard Board")), str(active_contract.get("route_note", ""))]
	if bool(active_contract.get("featured_board", false)):
		route_detail += " | Spotlight %s" % featured_district
	hud.set_route_detail(route_detail)
	hud.set_cargo_detail("%s | %s" % [LogisticsDefs.get_cargo_family_label(str(active_contract.get("cargo", ""))), str(active_contract.get("cargo_note", ""))])
	var start_brief := "%s / %s / %s" % [str(active_client_profile.get("brief", "")), str(active_contract.get("route_note", "")), str(active_contract.get("cargo_note", ""))]
	if str(active_contract.get("pickup_note", "")).length() > 0:
		start_brief += " / " + str(active_contract.get("pickup_note", ""))
	if str(active_contract.get("handoff_note", "")).length() > 0:
		start_brief += " / " + str(active_contract.get("handoff_note", ""))
	if str(active_contract.get("offer_note", "")).length() > 0:
		start_brief += " / " + str(active_contract.get("offer_note", ""))
	start_brief += " / " + _contract_schedule_text(active_contract)
	start_brief += " / " + _streak_bonus_text()
	hud.set_shift_brief(start_brief)
	shift_event_queue = _build_shift_events(active_contract)
	active_shift_event = {}
	active_shift_event_end_time = 0.0
	shift_event_history.clear()
	hud.clear_event_state()
	hud.hide_summary()
	hud.set_help_visible(false)
	hud.set_brief_visible(false)
	hud.set_contract_list_visible(false)
	hud.set_client_visible(false)
	_update_shift_objective()
	hud.flash(Color(0.45, 0.65, 1.0), 0.18, 0.12)
	if audio_director != null:
		audio_director.play_cue("start")
	if active_pickup_zone != null:
		_update_status("Shift started for %s on the %s board. First stop: %s. Route memory: %s" % [str(active_contract.get("client", "Northline Dispatch")), str(active_contract.get("offer_modifier", "Standard Board")), active_pickup_zone.zone_label, _route_memory_label(visits)])
	elif active_stage_zone != null:
		_update_status("Shift started for %s on the %s board. First stop: %s. Route memory: %s" % [str(active_contract.get("client", "Northline Dispatch")), str(active_contract.get("offer_modifier", "Standard Board")), active_stage_zone.zone_label, _route_memory_label(visits)])
	else:
		_update_status("Shift started for %s on the %s board. Deliver to %s. Route memory: %s" % [str(active_contract.get("client", "Northline Dispatch")), str(active_contract.get("offer_modifier", "Standard Board")), active_contract["district"], _route_memory_label(visits)])

func _find_zone_by_district(district_name: String) -> DeliveryZone:
	return district_zone_lookup.get(district_name, null)

func _find_zone_by_id(zone_id: StringName) -> DeliveryZone:
	if zone_id == StringName():
		return null
	return service_zone_lookup.get(zone_id, null)

func _update_shift_objective() -> void:
	if active_pickup_zone != null and not active_pickup_complete:
		hud.set_objective("Pickup stop: %s. Press E to secure the load." % active_pickup_zone.zone_label)
	elif active_stage_zone != null and not active_stage_complete:
		hud.set_objective("First stop: %s. Press E to confirm the handoff." % active_stage_zone.zone_label)
	else:
		hud.set_objective("Drive to %s and press E to deliver." % active_contract["district"])

func _update_drive_hud() -> void:
	hud.set_drive_state(truck.get_speed_kph(), truck.get_stability_percent(), truck.get_cargo_state_label())
	hud.set_route_state(str(active_contract["route"]), str(active_contract["route_type"]), str(active_contract["district"]))
	var route_detail := "%s | %s" % [str(active_contract.get("offer_modifier", "Standard Board")), str(active_contract.get("route_note", ""))]
	if bool(active_contract.get("featured_board", false)):
		route_detail += " | Spotlight %s" % featured_district
	hud.set_route_detail(route_detail)
	hud.set_cargo_detail("%s | %s" % [LogisticsDefs.get_cargo_family_label(str(active_contract.get("cargo", ""))), str(active_contract.get("cargo_note", ""))])
	var shift_brief := "%s / %s / %s" % [str(active_client_profile.get("brief", "")), str(active_contract.get("route_note", "")), str(active_contract.get("cargo_note", ""))]
	if str(active_contract.get("pickup_note", "")).length() > 0:
		shift_brief += " / " + str(active_contract.get("pickup_note", ""))
	if str(active_contract.get("handoff_note", "")).length() > 0:
		shift_brief += " / " + str(active_contract.get("handoff_note", ""))
	if str(active_contract.get("offer_note", "")).length() > 0:
		shift_brief += " / " + str(active_contract.get("offer_note", ""))
	shift_brief += " / " + _contract_schedule_text(active_contract)
	shift_brief += " / " + _streak_bonus_text()
	hud.set_shift_brief(shift_brief)
	hud.set_district_state(_district_status_text(str(active_contract["district"])))
	_update_shift_objective()
	hud.set_phase_state("Driving | %s" % _shift_clock_text())
	if active_shift_event.is_empty():
		hud.clear_event_state()
	else:
		hud.set_event_state(str(active_shift_event.get("title", "Event")), str(active_shift_event.get("message", "")))

func _update_district_presentations() -> void:
	for zone in delivery_zones:
		var mood := int(district_mood.get(zone.district_name, 0))
		var reputation := int(district_reputation.get(zone.district_name, 0))
		var visits := int(district_visit_count.get(zone.district_name, 0))
		zone.apply_district_state(mood, reputation, visits)

func _check_cargo_pressure() -> void:
	var stability := truck.get_stability_percent()
	if stability < 20.0 and cargo_warnings < 3:
		_update_status("Cargo is critical. Stop driving like that.")
		cargo_warnings = 3
	elif stability < 45.0 and cargo_warnings < 2:
		_update_status("Cargo is shaky. Smooth out the route.")
		cargo_warnings = 2
	elif stability < 70.0 and cargo_warnings < 1:
		_update_status("Cargo is drifting. The city can see that, by the way.")
		cargo_warnings = 1

func _build_shift_events(contract: Dictionary) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var contract_events: Array = contract.get("events", [])
	for contract_event in contract_events:
		events.append(contract_event.duplicate(true))
	return events

func _update_shift_events() -> void:
	if active_shift_event.is_empty() and not shift_event_queue.is_empty():
		var next_event: Dictionary = shift_event_queue[0]
		if shift_time >= float(next_event.get("start", 0.0)):
			shift_event_queue.remove_at(0)
			_start_shift_event(next_event)
	elif not active_shift_event.is_empty():
		if shift_time >= active_shift_event_end_time:
			_end_shift_event()

func _start_shift_event(event: Dictionary) -> void:
	active_shift_event = event
	active_shift_event_end_time = shift_time + float(event.get("duration", 8.0))
	shift_event_history.append(str(event.get("title", "Event")))
	truck.apply_event_profile(event.get("profile", {}))
	var title := str(event.get("title", "Event"))
	var message := str(event.get("message", ""))
	hud.set_event_state(title, message)
	hud.flash(_event_flash_color(str(event.get("type", "event"))), 0.26, 0.16)
	if audio_director != null:
		audio_director.play_cue(str(event.get("type", "event")))
	_update_status("%s: %s" % [title, message])
	if bool(event.get("hold_drive", false)):
		truck.set_driving_enabled(false)
	else:
		truck.set_driving_enabled(true)

func _end_shift_event() -> void:
	var event_title := str(active_shift_event.get("title", "Event"))
	var event_type := str(active_shift_event.get("type", "event"))
	var cargo_name := str(active_contract.get("cargo", ""))
	truck.clear_event_profile()
	if shift_state == ShiftState.DRIVING:
		truck.set_driving_enabled(true)
	active_shift_event = {}
	active_shift_event_end_time = 0.0
	hud.clear_event_state()
	match event_type:
		"inspection_stop":
			var district_name := str(active_contract.get("district", "Unknown"))
			var stability := truck.get_stability_percent()
			if stability < 65.0:
				district_reputation[district_name] = int(district_reputation.get(district_name, 0)) - 1
				district_mood[district_name] = int(district_mood.get(district_name, 0)) - 1
				_update_status("%s cleared, but the cargo looked rough." % event_title)
			else:
				district_mood[district_name] = int(district_mood.get(district_name, 0)) + 1
				district_reputation[district_name] = int(district_reputation.get(district_name, 0)) + 1
				if cargo_name == "Medpack Stack":
					district_reputation[district_name] = int(district_reputation.get(district_name, 0)) + 1
					_update_status("%s cleared. The medpack stack impressed the checkpoint." % event_title)
				else:
					_update_status("%s cleared. Authority let the truck move on." % event_title)
		"road_closure":
			var district_name := str(active_contract.get("district", "Unknown"))
			if cargo_name == "Generator Core":
				district_mood[district_name] = int(district_mood.get(district_name, 0)) + 1
				_update_status("%s cleared. The generator core made the reroute worth it." % event_title)
			else:
				district_mood[district_name] = int(district_mood.get(district_name, 0)) - 1
				_update_status("%s cleared. The reroute held, but the city noticed the delay." % event_title)
		"weather_change":
			var district_name := str(active_contract.get("district", "Unknown"))
			if cargo_name == "Medpack Stack":
				district_reputation[district_name] = int(district_reputation.get(district_name, 0)) + 1
				_update_status("%s passed. The medpack stack survived the storm." % event_title)
			else:
				district_mood[district_name] = int(district_mood.get(district_name, 0)) + 1
				_update_status("%s passed. The road is still slick, but the city likes a driver who keeps moving." % event_title)
		"traffic_pileup":
			var district_name := str(active_contract.get("district", "Unknown"))
			if cargo_name == "Dry Goods Bulk":
				district_mood[district_name] = int(district_mood.get(district_name, 0)) + 1
				_update_status("%s eased up. The dry goods stayed calm through the snarl." % event_title)
			else:
				_update_status("%s eased up. The lane is moving again." % event_title)
		_:
			_update_status("%s ended." % event_title)

func _on_zone_truck_entered(zone_id: StringName) -> void:
	if shift_state != ShiftState.DRIVING:
		return
	if active_contract.is_empty():
		return
	if active_pickup_zone != null and not active_pickup_complete and zone_id == active_pickup_zone.zone_id:
		_update_status("Reached %s. Press E to secure the load." % active_pickup_zone.zone_label)
		hud.flash(Color(0.55, 0.85, 1.0), 0.16, 0.12)
		if audio_director != null:
			audio_director.play_cue("arrival")
	elif active_stage_zone != null and not active_stage_complete and zone_id == active_stage_zone.zone_id:
		_update_status("Reached %s. Press E to confirm the handoff." % active_stage_zone.zone_label)
		hud.flash(Color(0.55, 0.9, 1.0), 0.16, 0.12)
		if audio_director != null:
			audio_director.play_cue("arrival")
	elif active_zone != null and zone_id == active_zone.zone_id and not active_pickup_complete:
		_update_status("Final bay is here, but dispatch still wants the pickup at %s." % active_pickup_zone.zone_label)
		hud.flash(Color(1.0, 0.85, 0.3), 0.16, 0.12)
	elif active_zone != null and zone_id == active_zone.zone_id and not active_stage_complete:
		_update_status("Final bay is here, but dispatch still wants the handoff at %s." % active_stage_zone.zone_label)
		hud.flash(Color(1.0, 0.85, 0.3), 0.16, 0.12)
	elif active_zone != null and zone_id == active_zone.zone_id:
		_update_status("You reached %s. Press E to complete the delivery." % active_contract["district"])
		hud.flash(Color(0.35, 0.95, 0.65), 0.18, 0.14)
		if audio_director != null:
			audio_director.play_cue("arrival")
	else:
		_update_status("Wrong district. This one is not your drop.")
		hud.flash(Color(1.0, 0.8, 0.2), 0.16, 0.14)
		if audio_director != null:
			audio_director.play_cue("wrong_zone")

func _on_zone_truck_exited(zone_id: StringName) -> void:
	if shift_state != ShiftState.DRIVING:
		return
	if active_pickup_zone != null and not active_pickup_complete and zone_id == active_pickup_zone.zone_id:
		_update_status("You left %s. Dispatch still wants the pickup." % active_pickup_zone.zone_label)
	elif active_stage_zone != null and not active_stage_complete and zone_id == active_stage_zone.zone_id:
		_update_status("You left %s. Dispatch still wants that handoff." % active_stage_zone.zone_label)
	elif active_zone != null and zone_id == active_zone.zone_id:
		_update_status("You left %s. Get back in there." % active_contract["district"])

func _try_complete_delivery() -> void:
	if shift_state != ShiftState.DRIVING:
		return
	if active_pickup_zone != null and not active_pickup_complete:
		if active_pickup_zone.truck_inside:
			_complete_pickup_stop()
			return
		return
	if active_stage_zone != null and not active_stage_complete:
		if active_stage_zone.truck_inside:
			_complete_handoff_stop()
			return
		return
	if active_zone == null:
		return
	if not active_zone.truck_inside:
		return
	_complete_delivery()

func _complete_pickup_stop() -> void:
	active_pickup_complete = true
	shift_event_history.append("Pickup: %s" % active_pickup_zone.zone_label)
	var pickup_district := active_pickup_zone.district_name
	if pickup_district != str(active_contract.get("district", "")):
		district_reputation[pickup_district] = int(district_reputation.get(pickup_district, 0)) + 1
		district_visit_count[pickup_district] = int(district_visit_count.get(pickup_district, 0)) + 1
	hud.flash(Color(0.52, 0.88, 1.0), 0.2, 0.16)
	if audio_director != null:
		audio_director.play_cue("pickup")
	_update_shift_objective()
	if active_stage_zone != null and not active_stage_complete:
		_update_status("%s secured. Next stop is %s." % [active_pickup_zone.zone_label, active_stage_zone.zone_label])
	else:
		_update_status("%s secured. Final stop is now %s." % [active_pickup_zone.zone_label, active_contract["district"]])

func _complete_handoff_stop() -> void:
	active_stage_complete = true
	shift_event_history.append("Handoff: %s" % active_stage_zone.zone_label)
	var stage_district := active_stage_zone.district_name
	if stage_district != str(active_contract.get("district", "")):
		district_reputation[stage_district] = int(district_reputation.get(stage_district, 0)) + 1
		district_visit_count[stage_district] = int(district_visit_count.get(stage_district, 0)) + 1
	hud.flash(Color(0.55, 0.92, 1.0), 0.2, 0.16)
	if audio_director != null:
		audio_director.play_cue("handoff")
	_update_shift_objective()
	_update_status("%s logged. Final stop is now %s." % [active_stage_zone.zone_label, active_contract["district"]])

func _complete_delivery() -> void:
	truck.set_driving_enabled(false)
	shift_state = ShiftState.SUMMARY
	var district_name := str(active_contract["district"])
	district_mood[district_name] = int(district_mood[district_name]) + 1
	district_reputation[district_name] = int(district_reputation[district_name]) + 1
	district_visit_count[district_name] = int(district_visit_count[district_name]) + 1
	var stability_percent := roundi(truck.get_stability_percent())
	var reward := int(active_contract["reward"])
	var schedule_result := _calculate_schedule_result(active_contract)
	var streak_multiplier := _current_streak_bonus_multiplier()
	var applied_streak_percent := roundi((streak_multiplier - 1.0) * 100.0)
	var payout := roundi(reward * clampf(truck.cargo_stability, 0.25, 1.0) * _route_payout_multiplier(str(active_contract.get("route_type", ""))) * float(active_contract.get("payout_multiplier", 1.0)) * float(active_cargo_profile.get("payout_multiplier", 1.0)) * streak_multiplier)
	payout += int(schedule_result.get("credit_adjustment", 0))
	payout = max(payout, roundi(reward * 0.35))
	var visits := int(district_visit_count[district_name])
	completed_shift_count += 1
	dispatch_streak += 1
	district_mastery[district_name] = int(district_mastery.get(district_name, 0)) + 1 + (1 if shift_time <= float(active_contract.get("target_time", 30.0)) else 0)
	total_credits += payout
	var summary := PackedStringArray()
	summary.append("Delivery: %s" % active_contract["name"])
	summary.append("Board: %s" % str(active_contract.get("offer_modifier", "Standard Board")))
	summary.append("Client: %s" % str(active_contract.get("client", "Northline Dispatch")))
	summary.append("Cargo: %s" % active_contract["cargo"])
	summary.append("Cargo family: %s" % LogisticsDefs.get_cargo_family_label(str(active_contract.get("cargo", ""))))
	summary.append("District: %s" % district_name)
	summary.append("Route: %s" % active_contract["route"])
	summary.append("Route brief: %s" % str(active_contract.get("route_note", "")))
	summary.append("Cargo brief: %s" % str(active_contract.get("cargo_note", "")))
	summary.append("Client brief: %s" % str(active_client_profile.get("brief", "")))
	if active_pickup_zone != null:
		summary.append("Pickup stop: %s" % active_pickup_zone.zone_label)
	if active_stage_zone != null:
		summary.append("Handoff stop: %s" % active_stage_zone.zone_label)
	summary.append("Route memory: %s" % _route_memory_label(visits))
	summary.append("District mastery: %s" % _district_mastery_label(int(district_mastery.get(district_name, 0))))
	summary.append("Shift time: %s" % _shift_clock_text())
	summary.append("Schedule: %s" % str(schedule_result.get("label", "On time")))
	summary.append("Applied streak bonus: +%d%%" % applied_streak_percent)
	summary.append("Payout: %d credits" % payout)
	summary.append("Dispatch streak: %d" % dispatch_streak)
	summary.append("Company rank: %d" % _company_level())
	summary.append("Career total: %d credits across %d shifts" % [total_credits, completed_shift_count])
	summary.append("Cargo stability: %d%%" % stability_percent)
	summary.append("District mood: %d" % int(district_mood[district_name]))
	summary.append("Reputation: %d" % int(district_reputation[district_name]))
	if not shift_event_history.is_empty():
		summary.append("Events: %s" % ", ".join(shift_event_history))
	hud.show_summary("Shift Complete", "\n".join(summary))
	hud.set_phase_state("Summary")
	hud.set_client_state("%s | %s" % [str(active_contract.get("client", "Northline Dispatch")), str(active_client_profile.get("tone", ""))])
	hud.set_client_visible(true)
	hud.set_help_visible(true)
	hud.set_brief_visible(true)
	hud.flash(Color(0.4, 1.0, 0.6), 0.3, 0.22)
	if audio_director != null:
		audio_director.play_cue("success")
	_update_status("Delivery complete. Press Enter to return to contract selection.")

func _fail_shift(reason: String) -> void:
	truck.set_driving_enabled(false)
	shift_state = ShiftState.SUMMARY
	dispatch_streak = 0
	var district_name := str(active_contract.get("district", "Unknown"))
	district_mood[district_name] = int(district_mood.get(district_name, 0)) - 1
	district_reputation[district_name] = int(district_reputation.get(district_name, 0)) - 1
	district_visit_count[district_name] = int(district_visit_count.get(district_name, 0)) + 1
	var summary := PackedStringArray()
	summary.append("Delivery: %s" % active_contract.get("name", "Unknown"))
	summary.append("Board: %s" % str(active_contract.get("offer_modifier", "Standard Board")))
	summary.append("Client: %s" % str(active_contract.get("client", "Northline Dispatch")))
	summary.append("Cargo: %s" % active_contract.get("cargo", "Unknown"))
	summary.append("Cargo family: %s" % LogisticsDefs.get_cargo_family_label(str(active_contract.get("cargo", ""))))
	summary.append("District: %s" % district_name)
	summary.append("Status: Failed")
	summary.append("Reason: %s" % reason)
	if active_pickup_zone != null:
		summary.append("Pickup stop: %s" % active_pickup_zone.zone_label)
	if active_stage_zone != null:
		summary.append("Handoff stop: %s" % active_stage_zone.zone_label)
	summary.append("Route memory: %s" % _route_memory_label(int(district_visit_count[district_name])))
	summary.append("District mastery: %s" % _district_mastery_label(int(district_mastery.get(district_name, 0))))
	summary.append("Shift time: %s" % _shift_clock_text())
	summary.append("Schedule: Shift lost before payout.")
	summary.append("Applied streak bonus: +0%%")
	summary.append("Dispatch streak: %d" % dispatch_streak)
	summary.append("Company rank: %d" % _company_level())
	summary.append("Career total: %d credits across %d shifts" % [total_credits, completed_shift_count])
	summary.append("Cargo stability: 0%%")
	summary.append("District mood: %d" % int(district_mood.get(district_name, 0)))
	summary.append("Reputation: %d" % int(district_reputation.get(district_name, 0)))
	if not shift_event_history.is_empty():
		summary.append("Events: %s" % ", ".join(shift_event_history))
	hud.show_summary("Shift Failed", "\n".join(summary))
	hud.set_phase_state("Summary")
	hud.set_client_state("%s | %s" % [str(active_contract.get("client", "Northline Dispatch")), str(active_client_profile.get("tone", ""))])
	hud.set_client_visible(true)
	hud.set_help_visible(true)
	hud.set_brief_visible(true)
	hud.flash(Color(1.0, 0.25, 0.25), 0.3, 0.24)
	if audio_director != null:
		audio_director.play_cue("failure")
	_update_status("Shift failed. Press Enter to return to contract selection.")

func _reset_to_selection() -> void:
	shift_state = ShiftState.SELECTING
	active_contract = {}
	active_client_profile = {}
	active_cargo_profile = {}
	active_zone = null
	active_pickup_zone = null
	active_pickup_complete = true
	active_stage_zone = null
	active_stage_complete = true
	shift_event_queue.clear()
	active_shift_event = {}
	active_shift_event_end_time = 0.0
	shift_event_history.clear()
	truck.set_driving_enabled(false)
	truck.reset_truck()
	_apply_spawn_transform(last_valid_spawn_transform)
	hud.hide_summary()
	hud.set_help_visible(true)
	hud.set_brief_visible(true)
	hud.set_contract_list_visible(true)
	board_cycle += 1
	_refresh_contract_board()
	hud.set_phase_state("Selecting")
	_apply_contract_selection(selected_contract_index)
	_update_status("Dispatch board refreshed. Select another contract and press Enter.")

func _update_status(message: String) -> void:
	hud.set_hint(message)

func _update_audio_state() -> void:
	if audio_director == null or truck == null:
		return
	var throttle_axis := Input.get_action_strength("drive_forward") - Input.get_action_strength("drive_backward")
	var handbrake := Input.is_action_pressed("handbrake")
	var event_type := ""
	if not active_shift_event.is_empty():
		event_type = str(active_shift_event.get("type", ""))
	audio_director.set_drive_state(
		truck.get_speed_kph(),
		truck.get_stability_percent(),
		throttle_axis,
		handbrake,
		shift_state == ShiftState.DRIVING,
		str(active_contract.get("route_type", "safe")),
		str(active_contract.get("district", "Market Nine")),
		LogisticsDefs.get_cargo_family_key(str(active_contract.get("cargo", ""))),
		event_type
	)

func _build_shift_profile(contract: Dictionary, district_name: String, visits: int) -> Dictionary:
	var profile: Dictionary = contract.get("route_profile", {}).duplicate(true)
	var mood := int(district_mood.get(district_name, 0))
	var reputation := int(district_reputation.get(district_name, 0))
	var mastery := int(district_mastery.get(district_name, 0))
	var visit_bonus := clampf(float(visits) * 0.02, 0.0, 0.08)
	var mood_shift := clampf(float(mood) * 0.03, -0.09, 0.09)
	var reputation_shift := clampf(float(reputation) * 0.02, -0.06, 0.10)
	var mastery_shift := clampf(float(mastery) * 0.015, 0.0, 0.12)
	var streak_shift := clampf(float(dispatch_streak) * 0.01, 0.0, 0.05)
	profile["speed_cap_multiplier"] = float(profile.get("speed_cap_multiplier", 1.0)) * (1.0 + mood_shift * 0.4)
	profile["steering_multiplier"] = float(profile.get("steering_multiplier", 1.0)) * (1.0 - mood_shift * 0.2 + mastery_shift * 0.2 + streak_shift)
	profile["cargo_stress_multiplier"] = float(profile.get("cargo_stress_multiplier", 1.0)) * (1.0 + mood_shift * 0.5 - reputation_shift * 0.25)
	profile["cargo_recovery_multiplier"] = float(profile.get("cargo_recovery_multiplier", 1.0)) * (1.0 + reputation_shift + visit_bonus + mastery_shift + streak_shift)
	profile["brake_multiplier"] = float(profile.get("brake_multiplier", 1.0))
	profile["reverse_multiplier"] = float(profile.get("reverse_multiplier", 1.0))
	match visits:
		1:
			profile["steering_multiplier"] = float(profile.get("steering_multiplier", 1.0)) * 1.02
			profile["cargo_recovery_multiplier"] = float(profile.get("cargo_recovery_multiplier", 1.0)) * 1.04
		2:
			profile["speed_cap_multiplier"] = float(profile.get("speed_cap_multiplier", 1.0)) * 1.02
			profile["cargo_recovery_multiplier"] = float(profile.get("cargo_recovery_multiplier", 1.0)) * 1.06
		_:
			if visits >= 3:
				profile["cargo_stress_multiplier"] = float(profile.get("cargo_stress_multiplier", 1.0)) * 1.05
				profile["brake_multiplier"] = float(profile.get("brake_multiplier", 1.0)) * 1.03
	return profile

func _route_payout_multiplier(route_type: String) -> float:
	match route_type:
		"safe":
			return 0.95
		"fast":
			return 1.12
		"rough":
			return 1.2
		_:
			return 1.0

func _contract_schedule_text(contract: Dictionary) -> String:
	return "Schedule %ss / +%scr / -%scr late" % [
		int(roundf(float(contract.get("target_time", 30.0)))),
		int(contract.get("on_time_bonus", 0)),
		int(contract.get("late_penalty", 0))
	]

func _shift_clock_text() -> String:
	var minutes := int(floor(shift_time / 60.0))
	var seconds := int(floor(fmod(shift_time, 60.0)))
	return "%02d:%02d" % [minutes, seconds]

func _calculate_schedule_result(contract: Dictionary) -> Dictionary:
	var target_time := float(contract.get("target_time", 30.0))
	var on_time_bonus := int(contract.get("on_time_bonus", 0))
	var late_penalty := int(contract.get("late_penalty", 0))
	if shift_time <= target_time:
		return {
			"credit_adjustment": on_time_bonus,
			"label": "On time (+%d cr)" % on_time_bonus
		}
	return {
		"credit_adjustment": -late_penalty,
		"label": "Late (-%d cr)" % late_penalty
	}

func _route_memory_label(visits: int) -> String:
	if visits <= 0:
		return "First time"
	if visits == 1:
		return "Familiar"
	if visits == 2:
		return "Known"
	return "Watched"

func _district_status_text(district_name: String) -> String:
	var mood := int(district_mood.get(district_name, 0))
	var reputation := int(district_reputation.get(district_name, 0))
	var visits := int(district_visit_count.get(district_name, 0))
	var mastery := int(district_mastery.get(district_name, 0))
	return "%s | Reputation %d | %s | %s" % [_mood_label(mood), reputation, _route_memory_label(visits), _district_mastery_label(mastery)]

func _district_mastery_label(mastery: int) -> String:
	if mastery <= 0:
		return "Mastery: New"
	if mastery <= 2:
		return "Mastery: Routed"
	if mastery <= 4:
		return "Mastery: Trusted"
	if mastery <= 7:
		return "Mastery: Known"
	return "Mastery: Staple"

func _company_level() -> int:
	return 1 + int(floor(float(total_credits) / 300.0)) + int(floor(float(completed_shift_count) / 3.0))

func _current_streak_bonus_multiplier() -> float:
	return 1.0 + clampf(float(dispatch_streak) * 0.04, 0.0, 0.20)

func _streak_bonus_text() -> String:
	var bonus_percent := roundi((_current_streak_bonus_multiplier() - 1.0) * 100.0)
	if bonus_percent <= 0:
		return "No streak bonus"
	return "Streak bonus +%d%%" % bonus_percent

func _district_rotation_names() -> Array[String]:
	var names: Array[String] = []
	for spec in DISTRICT_ZONE_SPECS:
		names.append(str(spec["district"]))
	return names

func _network_activity_text() -> String:
	return "Network: %d crews active / streak %d" % [ambient_actors.size(), dispatch_streak]

func _mood_label(mood: int) -> String:
	if mood <= -2:
		return "Cold"
	if mood == -1:
		return "Uneasy"
	if mood == 0:
		return "Neutral"
	if mood == 1:
		return "Warm"
	return "Welcoming"

func _event_flash_color(event_type: String) -> Color:
	match event_type:
		"traffic_pileup":
			return Color(1.0, 0.72, 0.2)
		"weather_change":
			return Color(0.45, 0.68, 1.0)
		"road_closure":
			return Color(1.0, 0.4, 0.25)
		"inspection_stop":
			return Color(0.95, 0.95, 0.95)
		_:
			return Color(0.8, 0.8, 0.9)

func _update_truck_juice(delta: float) -> void:
	if truck == null:
		return

	var speed_ratio := clampf(truck.get_speed_kph() / (truck.max_forward_speed * 3.6), 0.0, 1.0)
	var steer_axis := Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var throttle_axis := Input.get_action_strength("drive_forward") - Input.get_action_strength("drive_backward")
	var handbrake := Input.is_action_pressed("handbrake")
	var cargo_instability := 1.0 - clampf(truck.get_stability_percent() / 100.0, 0.0, 1.0)
	var lean_target := -steer_axis * (3.0 + speed_ratio * 5.5) + cargo_instability * 1.8

	if truck_body_mesh != null:
		truck_body_mesh.rotation_degrees.z = lerpf(truck_body_mesh.rotation_degrees.z, lean_target, 6.0 * delta)
		truck_body_mesh.position.y = lerpf(truck_body_mesh.position.y, 0.02 + sin(shift_time * 8.0) * (0.02 + speed_ratio * 0.02), 4.0 * delta)

	if truck_cabin_mesh != null:
		truck_cabin_mesh.rotation_degrees.z = lerpf(truck_cabin_mesh.rotation_degrees.z, lean_target * 0.65, 6.0 * delta)

	if truck_bed_mesh != null:
		truck_bed_mesh.rotation_degrees.z = lerpf(truck_bed_mesh.rotation_degrees.z, lean_target * 0.35, 6.0 * delta)

	var wheel_spin := speed_ratio * 550.0 * delta
	_spin_wheel(truck_front_left_wheel, wheel_spin, steer_axis, true, delta)
	_spin_wheel(truck_front_right_wheel, wheel_spin, steer_axis, true, delta)
	_spin_wheel(truck_rear_left_wheel, wheel_spin, steer_axis, false, delta)
	_spin_wheel(truck_rear_right_wheel, wheel_spin, steer_axis, false, delta)

	if truck_spring_arm != null:
		var camera_drop := 2.5 + speed_ratio * 0.24 + cargo_instability * 0.08
		truck_spring_arm.position.y = lerpf(truck_spring_arm.position.y, camera_drop, 4.0 * delta)
		truck_spring_arm.spring_length = lerpf(truck_spring_arm.spring_length, 7.0 + speed_ratio * 1.15 - cargo_instability * 0.25, 4.0 * delta)
		truck_spring_arm.rotation_degrees.x = lerpf(truck_spring_arm.rotation_degrees.x, -10.0 - speed_ratio * 2.25 + cargo_instability * 0.6, 3.5 * delta)

	if truck_camera != null:
		truck_camera.fov = clampf(lerpf(truck_camera.fov, 69.0 + speed_ratio * 8.5 + cargo_instability * 2.0, 4.0 * delta), 45.0, 85.0)

	if truck_left_headlight != null:
		truck_left_headlight.light_energy = lerpf(truck_left_headlight.light_energy, 0.85 if shift_state == ShiftState.DRIVING else 0.55, 4.0 * delta)
	if truck_right_headlight != null:
		truck_right_headlight.light_energy = lerpf(truck_right_headlight.light_energy, 0.85 if shift_state == ShiftState.DRIVING else 0.55, 4.0 * delta)
	if truck_brake_light_left != null:
		var brake_intensity := 0.05
		if handbrake or throttle_axis < 0.0:
			brake_intensity = 0.55 + speed_ratio * 0.25
		if speed_ratio < 0.02 and throttle_axis < 0.0:
			brake_intensity = 0.85
		truck_brake_light_left.light_energy = lerpf(truck_brake_light_left.light_energy, brake_intensity, 8.0 * delta)
	if truck_brake_light_right != null:
		var brake_intensity_right := 0.05
		if handbrake or throttle_axis < 0.0:
			brake_intensity_right = 0.55 + speed_ratio * 0.25
		if speed_ratio < 0.02 and throttle_axis < 0.0:
			brake_intensity_right = 0.85
		truck_brake_light_right.light_energy = lerpf(truck_brake_light_right.light_energy, brake_intensity_right, 8.0 * delta)

func _spin_wheel(pivot: Node3D, wheel_spin: float, steer_axis: float, is_front: bool, delta: float) -> void:
	if pivot == null:
		return
	pivot.rotation_degrees.y = lerpf(pivot.rotation_degrees.y, steer_axis * (13.0 if is_front else 4.0), 5.5 * delta)
	var wheel_mesh := pivot.get_child(0) as MeshInstance3D
	if wheel_mesh != null:
		wheel_mesh.rotation_degrees.x += wheel_spin
