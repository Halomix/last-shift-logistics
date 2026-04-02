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

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_build_zone()

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
	var material := StandardMaterial3D.new()
	material.albedo_color = zone_color
	material.emission_enabled = true
	material.emission = zone_color
	material.emission_energy_multiplier = 1.2
	marker.material_override = material
	marker.position = Vector3(0, 0.4, 0)
	add_child(marker)

	var sign := Label3D.new()
	sign.text = "%s\n%s" % [zone_label, district_name]
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.position = Vector3(0, 3.0, 0)
	sign.pixel_size = 0.01
	add_child(sign)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("truck"):
		truck_inside = true
		truck_entered.emit(zone_id)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("truck"):
		truck_inside = false
		truck_exited.emit(zone_id)
