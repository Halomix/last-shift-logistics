extends SceneTree

const MainScene := preload("res://scripts/game/main.gd")

func _initialize() -> void:
	call_deferred("_run_probe")

func _run_probe() -> void:
	var main := MainScene.new()
	root.add_child(main)
	await process_frame
	await process_frame

	main.completed_shift_count = 2
	main._apply_contract_selection(4)
	main._start_shift()

	if main.active_pickup_zone == null:
		push_error("World expansion probe expected the late-game contract to start with a pickup stop.")
		quit(1)
		return

	if main.active_pickup_complete:
		push_error("World expansion probe expected the pickup stop to be required before the handoff.")
		quit(1)
		return

	if main.active_stage_zone == null:
		push_error("World expansion probe expected a staged contract with a handoff zone.")
		quit(1)
		return

	if main.active_stage_complete:
		push_error("World expansion probe expected the staged contract to require a handoff first.")
		quit(1)
		return

	main.active_pickup_zone.truck_inside = true
	main._try_complete_delivery()

	if not main.active_pickup_complete:
		push_error("World expansion probe failed to complete the pickup stop.")
		quit(1)
		return

	main.active_stage_zone.truck_inside = true
	main._try_complete_delivery()

	if not main.active_stage_complete:
		push_error("World expansion probe failed to complete the staged handoff.")
		quit(1)
		return

	main.active_zone.truck_inside = true
	main._try_complete_delivery()

	if main.hud.summary_panel.visible == false:
		push_error("World expansion probe did not reach the summary after staged delivery.")
		quit(1)
		return

	if main.completed_shift_count < 3:
		push_error("World expansion probe did not advance completed shift progression.")
		quit(1)
		return

	if main.total_credits <= 0:
		push_error("World expansion probe did not award credits.")
		quit(1)
		return

	print("World expansion probe passed: staged contract, progression, and payout all completed.")
	quit(0)
