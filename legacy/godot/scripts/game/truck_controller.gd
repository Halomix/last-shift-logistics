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
@export var prototype_damage_enabled := false

var driving_enabled := false
var current_speed := 0.0
var cargo_stability := 1.0
var cargo_weight := 1.0
var cargo_sensitivity := 1.0
var cargo_speed_cap_multiplier := 1.0
var cargo_acceleration_multiplier := 1.0
var cargo_steering_multiplier := 1.0
var cargo_brake_multiplier := 1.0
var cargo_reverse_multiplier := 1.0
var route_speed_cap_multiplier := 1.0
var route_steering_multiplier := 1.0
var route_cargo_stress_multiplier := 1.0
var route_cargo_recovery_multiplier := 1.0
var route_brake_multiplier := 1.0
var route_reverse_multiplier := 1.0
var event_speed_cap_multiplier := 1.0
var event_steering_multiplier := 1.0
var event_cargo_stress_multiplier := 1.0
var event_cargo_recovery_multiplier := 1.0
var event_brake_multiplier := 1.0
var event_reverse_multiplier := 1.0
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

func apply_cargo_profile(profile: Dictionary) -> void:
	cargo_weight = cargo_weight * float(profile.get("weight_multiplier", 1.0))
	cargo_sensitivity = cargo_sensitivity * float(profile.get("sensitivity_multiplier", 1.0))
	cargo_speed_cap_multiplier = float(profile.get("speed_cap_multiplier", 1.0))
	cargo_acceleration_multiplier = float(profile.get("acceleration_multiplier", 1.0))
	cargo_steering_multiplier = float(profile.get("steering_multiplier", 1.0))
	cargo_brake_multiplier = float(profile.get("brake_multiplier", 1.0))
	cargo_reverse_multiplier = float(profile.get("reverse_multiplier", 1.0))

func reset_truck() -> void:
	current_speed = 0.0
	cargo_stability = 1.0
	velocity = Vector3.ZERO
	rotation = Vector3.ZERO
	route_speed_cap_multiplier = 1.0
	route_steering_multiplier = 1.0
	route_cargo_stress_multiplier = 1.0
	route_cargo_recovery_multiplier = 1.0
	route_brake_multiplier = 1.0
	route_reverse_multiplier = 1.0
	cargo_speed_cap_multiplier = 1.0
	cargo_acceleration_multiplier = 1.0
	cargo_steering_multiplier = 1.0
	cargo_brake_multiplier = 1.0
	cargo_reverse_multiplier = 1.0
	event_speed_cap_multiplier = 1.0
	event_steering_multiplier = 1.0
	event_cargo_stress_multiplier = 1.0
	event_cargo_recovery_multiplier = 1.0
	event_brake_multiplier = 1.0
	event_reverse_multiplier = 1.0
	last_speed_kph = -1.0
	last_stability = -1.0

func apply_route_profile(profile: Dictionary) -> void:
	route_speed_cap_multiplier = float(profile.get("speed_cap_multiplier", 1.0))
	route_steering_multiplier = float(profile.get("steering_multiplier", 1.0))
	route_cargo_stress_multiplier = float(profile.get("cargo_stress_multiplier", 1.0))
	route_cargo_recovery_multiplier = float(profile.get("cargo_recovery_multiplier", 1.0))
	route_brake_multiplier = float(profile.get("brake_multiplier", 1.0))
	route_reverse_multiplier = float(profile.get("reverse_multiplier", 1.0))

func apply_event_profile(profile: Dictionary) -> void:
	event_speed_cap_multiplier = float(profile.get("speed_cap_multiplier", 1.0))
	event_steering_multiplier = float(profile.get("steering_multiplier", 1.0))
	event_cargo_stress_multiplier = float(profile.get("cargo_stress_multiplier", 1.0))
	event_cargo_recovery_multiplier = float(profile.get("cargo_recovery_multiplier", 1.0))
	event_brake_multiplier = float(profile.get("brake_multiplier", 1.0))
	event_reverse_multiplier = float(profile.get("reverse_multiplier", 1.0))

func clear_event_profile() -> void:
	event_speed_cap_multiplier = 1.0
	event_steering_multiplier = 1.0
	event_cargo_stress_multiplier = 1.0
	event_cargo_recovery_multiplier = 1.0
	event_brake_multiplier = 1.0
	event_reverse_multiplier = 1.0

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
		velocity = global_transform.basis.z * current_speed
		move_and_slide()
		_sync_signals()
		return

	var throttle: float = Input.get_action_strength("drive_forward") - Input.get_action_strength("drive_backward")
	var steer: float = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var handbrake: bool = Input.is_action_pressed("handbrake")
	var speed_cap: float = max_forward_speed * route_speed_cap_multiplier * event_speed_cap_multiplier * cargo_speed_cap_multiplier

	if throttle > 0.0:
		var scaled_accel: float = (acceleration / max(cargo_weight, 0.75)) * route_speed_cap_multiplier * event_speed_cap_multiplier * cargo_acceleration_multiplier
		current_speed = move_toward(current_speed, speed_cap, scaled_accel * delta)
	elif throttle < 0.0:
		current_speed = move_toward(current_speed, -max_reverse_speed * route_reverse_multiplier * event_reverse_multiplier * cargo_reverse_multiplier, acceleration * 0.7 * cargo_acceleration_multiplier * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, drag * delta)

	if handbrake:
		current_speed = move_toward(current_speed, 0.0, braking * 1.3 * route_brake_multiplier * event_brake_multiplier * cargo_brake_multiplier * delta)

	var normalized_speed_cap: float = maxf(speed_cap, 0.001)
	var speed_factor: float = clamp(abs(current_speed) / normalized_speed_cap, 0.0, 1.0)
	var steering_factor: float = (0.35 + speed_factor) * lerp(1.0, 0.65, 1.0 - cargo_stability) * route_steering_multiplier * event_steering_multiplier * cargo_steering_multiplier
	rotation.y -= steer * steering_rate * steering_factor * delta

	if prototype_damage_enabled:
		var stress: float = abs(steer) * speed_factor * cargo_sensitivity * route_cargo_stress_multiplier * event_cargo_stress_multiplier
		if handbrake and abs(current_speed) > 2.0:
			stress += 0.2
		cargo_stability = clamp(cargo_stability - stress * cargo_stress_rate * delta, 0.0, 1.0)

		if abs(steer) < 0.1 and speed_factor < 0.25:
			cargo_stability = min(1.0, cargo_stability + cargo_recovery_rate * route_cargo_recovery_multiplier * event_cargo_recovery_multiplier * delta)
	else:
		cargo_stability = 1.0

	velocity = global_transform.basis.z * current_speed
	move_and_slide()

	for index in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(index)
		if collision and prototype_damage_enabled:
			cargo_stability = max(0.0, cargo_stability - maxf(0.01, abs(current_speed) / max_forward_speed * 0.02))
			current_speed = move_toward(current_speed, 0.0, braking * 0.3 * delta)

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
