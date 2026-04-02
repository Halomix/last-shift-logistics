extends Node3D

const TruckController := preload("res://scripts/game/truck_controller.gd")
const DeliveryZone := preload("res://scripts/game/delivery_zone.gd")
const LogisticsHUD := preload("res://scripts/ui/hud.gd")

enum ShiftState { SELECTING, DRIVING, SUMMARY }

var shift_state := ShiftState.SELECTING
var selected_contract_index := 0
var active_contract: Dictionary = {}
var active_zone: DeliveryZone
var truck: TruckController
var hud: LogisticsHUD
var delivery_zones: Array[DeliveryZone] = []
var district_mood := {
	"Market Nine": 0,
	"Floodline": 0,
	"Dockside Ring": 0
}
var district_reputation := {
	"Market Nine": 0,
	"Floodline": 0,
	"Dockside Ring": 0
}
var cargo_warnings := 0.0
var shift_time := 0.0

var contracts := [
	{
		"id": "orientation",
		"name": "Orientation Run",
		"cargo": "Dry Goods Bulk",
		"district": "Market Nine",
		"route": "Safe Lane",
		"route_type": "safe",
		"reward": 120,
		"weight": 1.0,
		"stability": 0.5,
		"color": Color(0.52, 0.87, 0.58),
		"target_position": Vector3(28, 0, 10)
	},
	{
		"id": "floodline",
		"name": "Floodline Relief",
		"cargo": "Medpack Stack",
		"district": "Floodline",
		"route": "Storm Lane",
		"route_type": "fast",
		"reward": 180,
		"weight": 0.8,
		"stability": 0.35,
		"color": Color(0.45, 0.72, 1.0),
		"target_position": Vector3(-18, 0, 32)
	},
	{
		"id": "dockside",
		"name": "Dockside Core",
		"cargo": "Generator Core",
		"district": "Dockside Ring",
		"route": "Heavy Route",
		"route_type": "weird",
		"reward": 220,
		"weight": 1.5,
		"stability": 0.65,
		"color": Color(0.94, 0.67, 0.35),
		"target_position": Vector3(30, 0, -24)
	}
]

func _ready() -> void:
	_build_world()
	_build_truck()
	_build_zones()
	_build_hud()
	_apply_contract_selection(0)
	_update_status("Select a contract with 1, 2, or 3. Press Enter to start the shift.")

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#0a1017")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#2a3548")
	environment.ambient_light_energy = 1.6
	env.environment = environment
	add_child(env)

	var sky := Sky.new()
	environment.sky = sky

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55.0, -30.0, 0.0)
	light.light_energy = 2.4
	add_child(light)

	_build_ground()
	_build_landmarks()

func _build_ground() -> void:
	var ground_body := StaticBody3D.new()
	add_child(ground_body)

	var ground_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(140.0, 140.0)
	ground_mesh.mesh = plane
	ground_mesh.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	var ground_material := StandardMaterial3D.new()
	ground_material.albedo_color = Color("#1b232d")
	ground_material.roughness = 1.0
	ground_mesh.material_override = ground_material
	ground_body.add_child(ground_mesh)

	var ground_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(140.0, 0.5, 140.0)
	ground_shape.shape = box
	ground_shape.position = Vector3(0.0, -0.25, 0.0)
	ground_body.add_child(ground_shape)

func _build_landmarks() -> void:
	_add_block(Vector3(8, 1.5, 16), Vector3(10, 3, 10), Color("#233145"))
	_add_block(Vector3(-14, 1.5, 16), Vector3(10, 3, 10), Color("#243744"))
	_add_block(Vector3(24, 1.5, -12), Vector3(12, 3, 12), Color("#2f283f"))
	_add_block(Vector3(-26, 1.5, -14), Vector3(12, 3, 12), Color("#3d2d25"))
	_add_lane_marker(Vector3(0, 0.06, 0), Vector3(60, 0.12, 4), Color("#0f1b25"))
	_add_lane_marker(Vector3(0, 0.06, 20), Vector3(60, 0.12, 3), Color("#13202b"))
	_add_lane_marker(Vector3(0, 0.06, -18), Vector3(60, 0.12, 3), Color("#13202b"))

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

func _add_lane_marker(position: Vector3, size: Vector3, color: Color) -> void:
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

	var shape := CollisionShape3D.new()
	var collision_box := BoxShape3D.new()
	collision_box.size = size
	shape.shape = collision_box
	body.add_child(shape)

func _build_truck() -> void:
	truck = TruckController.new()
	truck.position = Vector3(0.0, 1.0, -2.0)
	truck.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	truck.add_to_group("truck")
	add_child(truck)

	var body_mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.3, 1.5, 4.2)
	body_mesh.mesh = box
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color("#8f9ba8")
	body_material.roughness = 0.7
	body_mesh.material_override = body_material
	truck.add_child(body_mesh)

	var cabin_mesh := MeshInstance3D.new()
	var cabin_box := BoxMesh.new()
	cabin_box.size = Vector3(2.0, 1.6, 1.8)
	cabin_mesh.mesh = cabin_box
	cabin_mesh.position = Vector3(0.0, 0.3, -1.0)
	var cabin_material := StandardMaterial3D.new()
	cabin_material.albedo_color = Color("#495b70")
	cabin_material.roughness = 0.65
	cabin_mesh.material_override = cabin_material
	truck.add_child(cabin_mesh)

	var collision := CollisionShape3D.new()
	var collision_box := BoxShape3D.new()
	collision_box.size = Vector3(2.1, 1.25, 3.8)
	collision.shape = collision_box
	collision.position = Vector3(0.0, 0.0, 0.0)
	truck.add_child(collision)

	var spring_arm := SpringArm3D.new()
	spring_arm.spring_length = 7.0
	spring_arm.position = Vector3(0.0, 2.5, 0.5)
	spring_arm.rotation_degrees = Vector3(-10.0, 180.0, 0.0)
	truck.add_child(spring_arm)

	var camera := Camera3D.new()
	camera.current = true
	camera.position = Vector3(0.0, 0.0, 0.0)
	spring_arm.add_child(camera)

func _build_zones() -> void:
	_create_zone("market", "Market Nine", "Market Nine", Vector3(28, 0.0, 10), Color(0.52, 0.87, 0.58))
	_create_zone("flood", "Floodline", "Floodline", Vector3(-18, 0.0, 32), Color(0.45, 0.72, 1.0))
	_create_zone("dock", "Dockside Ring", "Dockside Ring", Vector3(30, 0.0, -24), Color(0.94, 0.67, 0.35))

func _create_zone(zone_id: StringName, district_name: String, zone_label: String, position: Vector3, color: Color) -> void:
	var zone := DeliveryZone.new()
	zone.zone_id = zone_id
	zone.district_name = district_name
	zone.zone_label = zone_label
	zone.zone_color = color
	zone.position = position
	zone.truck_entered.connect(_on_zone_truck_entered)
	zone.truck_exited.connect(_on_zone_truck_exited)
	add_child(zone)
	delivery_zones.append(zone)

func _build_hud() -> void:
	hud = LogisticsHUD.new()
	add_child(hud)
	hud.set_hint("1/2/3 select a contract. Enter starts the shift. E delivers at the zone.")

func _process(delta: float) -> void:
	if shift_state == ShiftState.SELECTING:
		_handle_contract_selection()
		return

	if shift_state == ShiftState.DRIVING:
		shift_time += delta
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
	if Input.is_action_just_pressed("interact"):
		_start_shift()

func _apply_contract_selection(index: int) -> void:
	selected_contract_index = clampi(index, 0, contracts.size() - 1)
	var contract: Dictionary = contracts[selected_contract_index]
	hud.set_contract_list(_contract_lines(), selected_contract_index)
	hud.set_route_state(contract["route"], contract["route_type"], contract["district"])
	hud.set_objective("Select this shift, then press Enter to begin.")
	hud.set_hint("A delivery to %s will teach the first slice." % contract["district"])
	_update_status("Selected %s. Press Enter to start the shift." % contract["name"])

func _contract_lines() -> Array[String]:
	var lines: Array[String] = []
	for contract in contracts:
		lines.append("%s - %s -> %s" % [contract["name"], contract["cargo"], contract["district"]])
	return lines

func _start_shift() -> void:
	active_contract = contracts[selected_contract_index]
	active_zone = _find_zone_by_district(str(active_contract["district"]))
	shift_state = ShiftState.DRIVING
	shift_time = 0.0
	cargo_warnings = 0.0
	truck.reset_truck()
	truck.configure_contract(active_contract)
	truck.position = Vector3(0.0, 1.0, -6.0)
	truck.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	truck.set_driving_enabled(true)
	hud.hide_summary()
	hud.set_objective("Drive to %s and press E to deliver." % active_contract["district"])
	_update_status("Shift started. Deliver to %s." % active_contract["district"])

func _find_zone_by_district(district_name: String) -> DeliveryZone:
	for zone in delivery_zones:
		if zone.district_name == district_name:
			return zone
	return null

func _update_drive_hud() -> void:
	hud.set_drive_state(truck.get_speed_kph(), truck.get_stability_percent(), truck.get_cargo_state_label())
	hud.set_route_state(str(active_contract["route"]), str(active_contract["route_type"]), str(active_contract["district"]))

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

func _on_zone_truck_entered(zone_id: StringName) -> void:
	if shift_state != ShiftState.DRIVING:
		return
	if active_contract.is_empty():
		return
	if active_zone != null and zone_id == active_zone.zone_id:
		_update_status("You reached %s. Press E to complete the delivery." % active_contract["district"])
	else:
		_update_status("Wrong district. This one is not your drop.")

func _on_zone_truck_exited(zone_id: StringName) -> void:
	if shift_state != ShiftState.DRIVING:
		return
	if active_zone != null and zone_id == active_zone.zone_id:
		_update_status("You left %s. Get back in there." % active_contract["district"])

func _try_complete_delivery() -> void:
	if active_zone == null:
		return
	if not active_zone.truck_inside:
		return
	if shift_state != ShiftState.DRIVING:
		return
	_complete_delivery()

func _complete_delivery() -> void:
	truck.set_driving_enabled(false)
	shift_state = ShiftState.SUMMARY
	var district_name := str(active_contract["district"])
	district_mood[district_name] = int(district_mood[district_name]) + 1
	district_reputation[district_name] = int(district_reputation[district_name]) + 1
	var stability_percent := roundi(truck.get_stability_percent())
	var reward := int(active_contract["reward"])
	var payout := roundi(reward * clampf(truck.cargo_stability, 0.25, 1.0))
	var summary := PackedStringArray()
	summary.append("Delivery: %s" % active_contract["name"])
	summary.append("Cargo: %s" % active_contract["cargo"])
	summary.append("District: %s" % district_name)
	summary.append("Route: %s" % active_contract["route"])
	summary.append("Payout: %d credits" % payout)
	summary.append("Cargo stability: %d%%" % stability_percent)
	summary.append("District mood: %d" % int(district_mood[district_name]))
	summary.append("Reputation: %d" % int(district_reputation[district_name]))
	hud.show_summary("Shift Complete", "\n".join(summary))
	_update_status("Delivery complete. Press Enter to return to contract selection.")

func _fail_shift(reason: String) -> void:
	truck.set_driving_enabled(false)
	shift_state = ShiftState.SUMMARY
	var district_name := str(active_contract.get("district", "Unknown"))
	district_mood[district_name] = int(district_mood.get(district_name, 0)) - 1
	district_reputation[district_name] = int(district_reputation.get(district_name, 0)) - 1
	var summary := PackedStringArray()
	summary.append("Delivery: %s" % active_contract.get("name", "Unknown"))
	summary.append("Cargo: %s" % active_contract.get("cargo", "Unknown"))
	summary.append("District: %s" % district_name)
	summary.append("Status: Failed")
	summary.append("Reason: %s" % reason)
	summary.append("Cargo stability: 0%%")
	summary.append("District mood: %d" % int(district_mood.get(district_name, 0)))
	summary.append("Reputation: %d" % int(district_reputation.get(district_name, 0)))
	hud.show_summary("Shift Failed", "\n".join(summary))
	_update_status("Shift failed. Press Enter to return to contract selection.")

func _reset_to_selection() -> void:
	shift_state = ShiftState.SELECTING
	active_contract = {}
	active_zone = null
	truck.set_driving_enabled(false)
	truck.reset_truck()
	truck.position = Vector3(0.0, 1.0, -6.0)
	hud.hide_summary()
	_apply_contract_selection(selected_contract_index)
	_update_status("Select another contract and press Enter.")

func _update_status(message: String) -> void:
	hud.set_hint(message)
