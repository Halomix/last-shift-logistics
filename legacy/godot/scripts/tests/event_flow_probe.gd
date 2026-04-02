extends SceneTree

const MainScene := preload("res://scripts/game/main.gd")

func _initialize() -> void:
	call_deferred("_run_probe")

func _run_probe() -> void:
	var main := MainScene.new()
	root.add_child(main)
	await process_frame
	await process_frame

	main._apply_contract_selection(0)
	main._start_shift()

	for i in range(30):
		main._process(1.0)

	if main.shift_event_history.is_empty():
		push_error("Event flow probe did not trigger any shift events.")
		quit(1)
		return

	main.active_zone.truck_inside = true
	main._try_complete_delivery()

	if main.hud.summary_panel.visible == false:
		push_error("Event flow probe did not reach the delivery summary.")
		quit(1)
		return

	print("Event flow probe passed: %s" % ", ".join(main.shift_event_history))
	quit(0)
