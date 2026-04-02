class_name TruckController
extends CharacterBody3D

signal cargo_state_changed(stability: float)
signal speed_changed(speed_kph: float)

@export var max_forward_speed := 18.0
@export var max_reverse_speed := 7.0
@export var acceleration := 22.0
@export var braking := 30.0
@export var steering_rate := 1.8
@export var drag := 4.5
@export var cargo_stress_rate := 0.09
@export var cargo_recovery_rate := 0.04

var driving_enabled := false
var current_speed := 0.0
var cargo_stability := 1.0
var cargo_weight := 1.0
var cargo_sensitivity := 1.0
var contract_name := "Unassigned"
var last_speed_kph := -1.0
var last_stability := -1.0

func set_driving_enabled(enabled: bool) -> void:
	driving_enabled = enabled

func configure_contract(contract: Dictionary) -> void:
	contract_name = str(contract.get("name", "Unassigned"))
	cargo_weight = float(contract.get("weight", 1.0))
	cargo_sensitivity = float(contract.get("stability", 1.0))
	cargo_stability = 1.0
	current_speed = 0.0
	last_speed_kph = -1.0
	last_stability = -1.0

func reset_truck() -> void:
	current_speed = 0.0
	cargo_stability = 1.0
	velocity = Vector3.ZERO
	rotation = Vector3.ZERO
	last_speed_kph = -1.0
	last_stability = -1.0

func get_speed_kph() -> float:
	return abs(current_speed) * 3.6

func get_stability_percent() -> float:
	return cargo_stability * 100.0

func get_cargo_state_label() -> String:
	if cargo_stability >= 0.9:
		return "Stable"
	if cargo_stability >= 0.7:
		return "Drifting"
	if cargo_stability >= 0.45:
		return "Shaky"
	if cargo_stability >= 0.2:
		return "Critical"
	return "Ruined"

func _physics_process(delta: float) -> void:
	if not driving_enabled:
		current_speed = move_toward(current_speed, 0.0, braking * delta)
		velocity = -global_transform.basis.z * current_speed
		move_and_slide()
		_sync_signals()
		return

	var throttle: float = Input.get_action_strength("drive_forward") - Input.get_action_strength("drive_backward")
	var steer: float = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var handbrake: bool = Input.is_action_pressed("handbrake")

	if throttle > 0.0:
		var scaled_accel: float = acceleration / max(cargo_weight, 0.75)
		current_speed = move_toward(current_speed, max_forward_speed, scaled_accel * delta)
	elif throttle < 0.0:
		current_speed = move_toward(current_speed, -max_reverse_speed, acceleration * 0.7 * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, drag * delta)

	if handbrake:
		current_speed = move_toward(current_speed, 0.0, braking * 1.3 * delta)

	var speed_factor: float = clamp(abs(current_speed) / max_forward_speed, 0.0, 1.0)
	var steering_factor: float = (0.35 + speed_factor) * lerp(1.0, 0.65, 1.0 - cargo_stability)
	rotation.y -= steer * steering_rate * steering_factor * delta

	var stress: float = abs(steer) * speed_factor * cargo_sensitivity
	if handbrake and abs(current_speed) > 2.0:
		stress += 0.2
	cargo_stability = clamp(cargo_stability - stress * cargo_stress_rate * delta, 0.0, 1.0)

	if abs(steer) < 0.1 and speed_factor < 0.25:
		cargo_stability = min(1.0, cargo_stability + cargo_recovery_rate * delta)

	velocity = -global_transform.basis.z * current_speed
	move_and_slide()

	for index in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(index)
		if collision:
			cargo_stability = max(0.0, cargo_stability - 0.01)

	_sync_signals()

func _sync_signals() -> void:
	var speed_kph: float = roundf(get_speed_kph())
	var stability: float = roundf(get_stability_percent())
	if abs(speed_kph - last_speed_kph) >= 1.0:
		speed_changed.emit(speed_kph)
		last_speed_kph = speed_kph
	if abs(stability - last_stability) >= 1.0:
		cargo_state_changed.emit(cargo_stability)
		last_stability = stability
