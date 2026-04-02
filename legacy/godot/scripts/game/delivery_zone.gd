class_name DeliveryZone
extends Area3D

signal truck_entered(zone_id: StringName)
signal truck_exited(zone_id: StringName)

@export var zone_id: StringName = &""
@export var district_name := "Unknown District"
@export var zone_label := "Delivery"
@export var zone_color := Color(0.35, 0.8, 1.0, 0.75)
@export var zone_radius := 4.0

var truck_inside := false
var marker_mesh: MeshInstance3D
var marker_material: StandardMaterial3D
var sign_label: Label3D
var bay_pad: MeshInstance3D
var bay_arch: MeshInstance3D
var pulse_time := 0.0

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_build_zone()
	set_process(true)

func _build_zone() -> void:
	var shape_node := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(zone_radius * 2.0, 3.0, zone_radius * 2.0)
	shape_node.shape = box
	add_child(shape_node)

	var marker := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = zone_radius * 0.35
	cylinder.bottom_radius = zone_radius * 0.6
	cylinder.height = 0.8
	marker.mesh = cylinder
	marker_material = StandardMaterial3D.new()
	marker_material.albedo_color = zone_color
	marker_material.emission_enabled = true
	marker_material.emission = zone_color
	marker_material.emission_energy_multiplier = 1.2
	marker.material_override = marker_material
	marker.position = Vector3(0, 0.4, 0)
	marker_mesh = marker
	add_child(marker)

	sign_label = Label3D.new()
	sign_label.text = "%s\n%s" % [zone_label, district_name]
	sign_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign_label.position = Vector3(0, 3.0, 0)
	sign_label.pixel_size = 0.01
	add_child(sign_label)

	bay_pad = MeshInstance3D.new()
	var bay_box := BoxMesh.new()
	bay_box.size = Vector3(zone_radius * 1.8, 0.12, zone_radius * 1.5)
	bay_pad.mesh = bay_box
	var bay_material := StandardMaterial3D.new()
	bay_material.albedo_color = zone_color.darkened(0.75)
	bay_material.roughness = 0.9
	bay_pad.material_override = bay_material
	bay_pad.position = Vector3(0, 0.06, 0)
	add_child(bay_pad)

	bay_arch = MeshInstance3D.new()
	var arch_box := BoxMesh.new()
	arch_box.size = Vector3(zone_radius * 1.55, 0.24, 0.28)
	bay_arch.mesh = arch_box
	var arch_material := StandardMaterial3D.new()
	arch_material.albedo_color = zone_color.lightened(0.15)
	arch_material.emission_enabled = true
	arch_material.emission = zone_color
	arch_material.emission_energy_multiplier = 0.35
	bay_arch.material_override = arch_material
	bay_arch.position = Vector3(0, 2.1, -zone_radius * 0.45)
	add_child(bay_arch)

	var left_post := _make_post(Vector3(-zone_radius * 0.78, 1.05, -zone_radius * 0.45))
	var right_post := _make_post(Vector3(zone_radius * 0.78, 1.05, -zone_radius * 0.45))
	add_child(left_post)
	add_child(right_post)

	var front_barrier := _make_barrier(Vector3(0, 0.45, zone_radius * 0.62))
	add_child(front_barrier)

	var rear_barrier := _make_barrier(Vector3(0, 0.45, -zone_radius * 0.62))
	add_child(rear_barrier)

func _process(delta: float) -> void:
	pulse_time += delta
	if marker_mesh != null:
		var pulse := 1.0 + sin(pulse_time * 3.0) * 0.035
		if truck_inside:
			pulse += 0.08
		marker_mesh.scale = Vector3.ONE * pulse
		var spin_speed := 12.0 + (26.0 if truck_inside else 6.0)
		marker_mesh.rotation_degrees.y += spin_speed * delta
	if marker_material != null:
		marker_material.emission_energy_multiplier = 1.0 + (0.9 if truck_inside else 0.35) + sin(pulse_time * 3.0) * 0.12
	if sign_label != null:
		sign_label.modulate = Color(1, 1, 1, 0.85 + (0.15 if truck_inside else 0.05))

	if bay_pad != null:
		var pad_material := bay_pad.material_override as StandardMaterial3D
		if pad_material != null:
			pad_material.emission_energy_multiplier = 0.2 + (0.35 if truck_inside else 0.12)
			pad_material.albedo_color = zone_color.darkened(0.78 if truck_inside else 0.84)

func apply_district_state(mood: int, reputation: int, visits: int) -> void:
	var mood_scale := 1.0
	if mood <= -2:
		mood_scale = 0.72
	elif mood == -1:
		mood_scale = 0.84
	elif mood == 1:
		mood_scale = 1.08
	elif mood >= 2:
		mood_scale = 1.18
	var rep_scale := clampf(1.0 + float(reputation) * 0.04, 0.84, 1.22)
	var visit_scale := clampf(1.0 + float(visits) * 0.015, 1.0, 1.18)
	var accent := zone_color.lerp(Color.WHITE, clampf(float(reputation) * 0.08 + 0.08, 0.08, 0.28))
	accent = accent.lerp(Color(0.25, 0.35, 0.5), clampf(float(mood) * -0.04, 0.0, 0.18))
	if marker_material != null:
		marker_material.albedo_color = accent
		marker_material.emission = accent
		marker_material.emission_energy_multiplier = (1.0 if not truck_inside else 1.5) * mood_scale * rep_scale
	if bay_pad != null:
		var pad_material := bay_pad.material_override as StandardMaterial3D
		if pad_material != null:
			pad_material.albedo_color = zone_color.darkened(0.8 - clampf(float(reputation) * 0.015, 0.0, 0.08))
			pad_material.emission_energy_multiplier = 0.18 * mood_scale * visit_scale
	if bay_arch != null:
		var arch_material := bay_arch.material_override as StandardMaterial3D
		if arch_material != null:
			arch_material.albedo_color = accent.lightened(0.08)
			arch_material.emission_energy_multiplier = 0.32 * mood_scale * rep_scale
	if sign_label != null:
		sign_label.modulate = accent.lightened(0.2)

func _make_post(position: Vector3) -> MeshInstance3D:
	var post := MeshInstance3D.new()
	var post_box := BoxMesh.new()
	post_box.size = Vector3(0.3, 2.2, 0.3)
	post.mesh = post_box
	var post_material := StandardMaterial3D.new()
	post_material.albedo_color = zone_color.lightened(0.12)
	post_material.roughness = 0.8
	post.material_override = post_material
	post.position = position
	return post

func _make_barrier(position: Vector3) -> MeshInstance3D:
	var barrier := MeshInstance3D.new()
	var barrier_box := BoxMesh.new()
	barrier_box.size = Vector3(zone_radius * 1.2, 0.18, 0.35)
	barrier.mesh = barrier_box
	var barrier_material := StandardMaterial3D.new()
	barrier_material.albedo_color = zone_color.darkened(0.62)
	barrier_material.roughness = 0.95
	barrier.material_override = barrier_material
	barrier.position = position
	return barrier

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("truck"):
		truck_inside = true
		truck_entered.emit(zone_id)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("truck"):
		truck_inside = false
		truck_exited.emit(zone_id)
