class_name AmbientActor
extends Node3D

@export var actor_kind := "worker"
@export var loop_points: Array[Vector3] = []
@export var move_speed := 2.0
@export var bob_strength := 0.05
@export var turn_speed := 5.0

var mesh_instance: MeshInstance3D
var accent_light: OmniLight3D
var current_target_index := 0
var travel_time := 0.0
var base_height := 0.0

func _ready() -> void:
	_build_visual()
	if not loop_points.is_empty():
		global_position = loop_points[0]
	base_height = global_position.y
	set_process(true)

func _process(delta: float) -> void:
	if loop_points.size() < 2:
		return
	travel_time += delta
	var target := loop_points[current_target_index]
	var to_target := target - global_position
	var distance := to_target.length()
	if distance < 0.4:
		current_target_index = (current_target_index + 1) % loop_points.size()
		target = loop_points[current_target_index]
		to_target = target - global_position
		distance = to_target.length()
	if distance > 0.001:
		var direction := to_target.normalized()
		global_position += direction * move_speed * delta
		var yaw := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, yaw, turn_speed * delta)
	global_position.y = base_height + sin(travel_time * 3.0) * bob_strength
	if accent_light != null and actor_kind == "van":
		accent_light.light_energy = 0.18 + abs(sin(travel_time * 4.0)) * 0.08

func _build_visual() -> void:
	mesh_instance = MeshInstance3D.new()
	var material := StandardMaterial3D.new()
	match actor_kind:
		"worker":
			var mesh := CapsuleMesh.new()
			mesh.radius = 0.22
			mesh.height = 1.16
			mesh_instance.mesh = mesh
			material.albedo_color = Color("#e7bf74")
			bob_strength = 0.04
			move_speed = maxf(move_speed, 1.6)
		"forklift":
			var mesh := BoxMesh.new()
			mesh.size = Vector3(0.9, 0.8, 1.2)
			mesh_instance.mesh = mesh
			material.albedo_color = Color("#d78736")
			bob_strength = 0.02
			move_speed = maxf(move_speed, 1.2)
		_:
			var mesh := BoxMesh.new()
			mesh.size = Vector3(1.1, 0.7, 2.2)
			mesh_instance.mesh = mesh
			material.albedo_color = Color("#6d7e94")
			bob_strength = 0.015
			move_speed = maxf(move_speed, 2.8)
			accent_light = OmniLight3D.new()
			accent_light.light_color = Color("#ffe3aa")
			accent_light.omni_range = 3.8
			accent_light.light_energy = 0.2
			accent_light.position = Vector3(0.0, 0.3, -1.1)
			add_child(accent_light)
	material.roughness = 0.86
	mesh_instance.material_override = material
	add_child(mesh_instance)
