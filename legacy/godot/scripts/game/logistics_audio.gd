class_name LogisticsAudio
extends Node

const SAMPLE_RATE := 44100.0

var engine_player: AudioStreamPlayer
var ambience_player: AudioStreamPlayer
var cue_player: AudioStreamPlayer
var engine_playback: AudioStreamGeneratorPlayback
var ambience_playback: AudioStreamGeneratorPlayback
var cue_playback: AudioStreamGeneratorPlayback
var engine_phase := 0.0
var ambience_phase := 0.0
var drive_speed_kph := 0.0
var drive_stability := 100.0
var drive_throttle := 0.0
var handbrake_pressed := false
var driving_enabled := false
var route_type := "safe"
var district_name := "Market Nine"
var cargo_family := "stable"
var active_event_type := ""
var cue_queue: Array[Dictionary] = []
var ambient_seed := 0.0

func _ready() -> void:
	_setup_player("engine", 0.18)
	_setup_player("ambience", 0.25)
	_setup_player("cue", 0.16)
	_set_district(district_name)

func _setup_player(kind: String, buffer_length: float) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = SAMPLE_RATE
	stream.buffer_length = buffer_length
	player.stream = stream
	player.volume_db = -12.0 if kind == "engine" else (-16.0 if kind == "ambience" else -8.0)
	player.play()
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	match kind:
		"engine":
			engine_player = player
			engine_playback = playback
		"ambience":
			ambience_player = player
			ambience_playback = playback
		"cue":
			cue_player = player
			cue_playback = playback

func set_drive_state(speed_kph: float, stability_percent: float, throttle_axis: float, handbrake: bool, enabled: bool, current_route_type: String, current_district: String, current_cargo_family: String, event_type: String = "") -> void:
	drive_speed_kph = speed_kph
	drive_stability = stability_percent
	drive_throttle = throttle_axis
	handbrake_pressed = handbrake
	driving_enabled = enabled
	route_type = current_route_type
	cargo_family = current_cargo_family
	if current_district != district_name:
		_set_district(current_district)
	active_event_type = event_type

func play_cue(cue_name: String) -> void:
	match cue_name:
		"selection":
			_enqueue_tone(880.0, 0.08, 0.11)
		"start":
			_enqueue_tone(220.0, 0.08, 0.10)
			_enqueue_tone(330.0, 0.10, 0.10)
		"traffic_pileup":
			_enqueue_tone(330.0, 0.10, 0.10)
		"weather_change":
			_enqueue_tone(260.0, 0.10, 0.10)
		"road_closure":
			_enqueue_tone(180.0, 0.10, 0.12)
			_enqueue_tone(220.0, 0.12, 0.10)
		"inspection_stop":
			_enqueue_tone(520.0, 0.10, 0.09)
		"arrival":
			_enqueue_tone(660.0, 0.10, 0.10)
		"handoff":
			_enqueue_tone(540.0, 0.08, 0.10)
			_enqueue_tone(720.0, 0.10, 0.09)
		"pickup":
			_enqueue_tone(420.0, 0.08, 0.09)
			_enqueue_tone(540.0, 0.10, 0.08)
		"wrong_zone":
			_enqueue_tone(240.0, 0.09, 0.11)
			_enqueue_tone(180.0, 0.13, 0.09)
		"success":
			_enqueue_tone(660.0, 0.12, 0.11)
			_enqueue_tone(880.0, 0.14, 0.11)
		"failure":
			_enqueue_tone(220.0, 0.14, 0.12)
			_enqueue_tone(110.0, 0.20, 0.12)
		_:
			_enqueue_tone(440.0, 0.08, 0.08)

func _process(_delta: float) -> void:
	_ensure_playbacks()
	_fill_engine()
	_fill_ambience()
	_fill_cues()

func _ensure_playbacks() -> void:
	if engine_playback == null and engine_player != null:
		engine_playback = engine_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if ambience_playback == null and ambience_player != null:
		ambience_playback = ambience_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if cue_playback == null and cue_player != null:
		cue_playback = cue_player.get_stream_playback() as AudioStreamGeneratorPlayback

func _fill_engine() -> void:
	if engine_playback == null:
		return
	var frames := engine_playback.get_frames_available()
	while frames > 0:
		frames -= 1
		var speed_ratio := clampf(drive_speed_kph / 72.0, 0.0, 1.0)
		var roughness := 1.0 - clampf(drive_stability / 100.0, 0.0, 1.0)
		var base_pitch := lerpf(42.0, 96.0, speed_ratio)
		if not driving_enabled:
			base_pitch = 24.0
		if handbrake_pressed and drive_speed_kph > 3.0:
			base_pitch = maxf(base_pitch * 0.85, 22.0)
		if route_type == "fast":
			base_pitch += 4.0
		elif route_type == "rough":
			base_pitch -= 3.0
		match cargo_family:
			"fragile":
				base_pitch += 2.5
			"heavy":
				base_pitch -= 4.0
			"stable":
				base_pitch += 0.5
			_:
				base_pitch += 1.0
		var amplitude := 0.006 + speed_ratio * 0.022 + maxf(drive_throttle, 0.0) * 0.012 + roughness * 0.01
		match cargo_family:
			"fragile":
				amplitude += 0.002
			"heavy":
				amplitude += 0.005
			"stable":
				amplitude += 0.001
		if handbrake_pressed:
			amplitude += 0.003
		var frame := _synth_engine_sample(base_pitch, amplitude, 0.6 + roughness * 0.2)
		engine_playback.push_frame(frame)

func _fill_ambience() -> void:
	if ambience_playback == null:
		return
	var frames := ambience_playback.get_frames_available()
	while frames > 0:
		frames -= 1
		var district_base := _ambient_base_for_district()
		var density := 0.45
		match cargo_family:
			"fragile":
				density += 0.05
			"heavy":
				density += 0.08
		if active_event_type == "weather_change":
			density += 0.18
		elif active_event_type == "traffic_pileup":
			density += 0.08
		elif active_event_type == "inspection_stop":
			density += 0.10
		var sample := _synth_ambient_sample(district_base, density)
		ambience_playback.push_frame(sample)

func _fill_cues() -> void:
	if cue_playback == null:
		return
	var frames := cue_playback.get_frames_available()
	while frames > 0:
		frames -= 1
		if cue_queue.is_empty():
			cue_playback.push_frame(Vector2.ZERO)
			continue
		var current := cue_queue[0]
		var duration := float(current.get("duration", 0.1))
		var freq := float(current.get("freq", 440.0))
		var gain := float(current.get("gain", 0.1))
		var decay := float(current.get("decay", 0.03))
		var attack := float(current.get("attack", 0.01))
		var overtone := float(current.get("overtone", 1.5))
		var stereo := float(current.get("stereo", 0.0))
		var t := float(current.get("t", 0.0))
		var env := 1.0
		if t < attack:
			env = t / maxf(attack, 0.001)
		elif t > duration - decay:
			env = maxf((duration - t) / maxf(decay, 0.001), 0.0)
		var sample := sin(TAU * freq * t) * 0.7 + sin(TAU * freq * overtone * t) * 0.3
		sample *= gain * env
		var left := sample * (1.0 - stereo)
		var right := sample * (1.0 + stereo)
		cue_playback.push_frame(Vector2(left, right))
		t += 1.0 / SAMPLE_RATE
		current["t"] = t
		cue_queue[0] = current
		if t >= duration:
			cue_queue.remove_at(0)

func _enqueue_tone(freq: float, duration: float, gain: float, overtone := 1.5, stereo := 0.0) -> void:
	cue_queue.append({
		"freq": freq,
		"duration": duration,
		"gain": gain,
		"overtone": overtone,
		"stereo": stereo,
		"t": 0.0,
		"attack": minf(0.01, duration * 0.25),
		"decay": maxf(0.02, duration * 0.45)
	})

func _ambient_base_for_district() -> float:
	match district_name:
		"Market Nine":
			return 48.0 if cargo_family != "heavy" else 44.0
		"Floodline":
			return 42.0 if cargo_family != "fragile" else 46.0
		"Dockside Ring":
			return 36.0 if cargo_family == "heavy" else 39.0
		_:
			return 40.0

func _set_district(new_district: String) -> void:
	district_name = new_district
	if district_name == "Floodline":
		ambient_seed = 0.55
	elif district_name == "Dockside Ring":
		ambient_seed = 0.22
	else:
		ambient_seed = 0.84

func _synth_engine_sample(freq: float, gain: float, color: float) -> Vector2:
	engine_phase = fmod(engine_phase + TAU * freq / SAMPLE_RATE, TAU)
	var harmonic := sin(engine_phase) * 0.68 + sin(engine_phase * 2.03) * 0.22 + sin(engine_phase * 3.95) * 0.10
	var noise := sin(engine_phase * 11.3 + ambient_seed * 2.0) * 0.05
	var sample := (harmonic + noise) * gain * color
	var pan := clampf(drive_throttle * 0.2, -0.12, 0.12)
	return Vector2(sample * (1.0 - pan), sample * (1.0 + pan))

func _synth_ambient_sample(freq: float, density: float) -> Vector2:
	ambience_phase = fmod(ambience_phase + TAU * freq / SAMPLE_RATE, TAU)
	var slow := sin(ambience_phase * 0.5 + ambient_seed) * 0.55
	var mid := sin(ambience_phase * 1.03 + ambient_seed * 2.0) * 0.30
	var air := sin(ambience_phase * 1.97 + ambient_seed * 3.5) * 0.15
	var sample := (slow + mid + air) * 0.016 * density
	return Vector2(sample, sample * 0.95)
