class_name LogisticsHUD
extends CanvasLayer

var root_panel: PanelContainer
var summary_panel: PanelContainer
var phase_label: Label
var client_label: Label
var selection_label: Label
var route_label: Label
var route_detail_label: Label
var cargo_label: Label
var cargo_detail_label: Label
var district_label: Label
var district_detail_label: Label
var shift_brief_label: Label
var event_label: Label
var objective_label: Label
var hint_label: Label
var brief_labels: Array[Label] = []
var help_panel: PanelContainer
var help_body: Label
var summary_title: Label
var summary_body: Label
var flash_rect: ColorRect
var flash_tween: Tween

func _ready() -> void:
	_build_ui()
	hide_summary()

func _build_ui() -> void:
	var root := Control.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	add_child(root)

	root_panel = PanelContainer.new()
	root_panel.position = Vector2(18, 18)
	root_panel.custom_minimum_size = Vector2(620, 320)
	root.add_child(root_panel)

	flash_rect = ColorRect.new()
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.color = Color(1, 1, 1, 0)
	flash_rect.z_index = 50
	root.add_child(flash_rect)

	var root_box := VBoxContainer.new()
	root_box.offset_left = 12
	root_box.offset_top = 12
	root_box.offset_right = 12
	root_box.offset_bottom = 12
	root_panel.add_child(root_box)

	phase_label = _make_label("Shift: Selecting")
	client_label = _make_label("Client: Northline Dispatch")
	selection_label = _make_label("Contracts")
	route_label = _make_label("Route")
	route_detail_label = _make_label("Route Detail")
	cargo_label = _make_label("Cargo")
	cargo_detail_label = _make_label("Cargo Detail")
	district_label = _make_label("District")
	district_detail_label = _make_label("District Status")
	shift_brief_label = _make_label("Shift Brief")
	event_label = _make_label("Event")
	objective_label = _make_label("Objective")
	hint_label = _make_label("Hint")

	root_box.add_child(phase_label)
	root_box.add_child(client_label)
	root_box.add_child(selection_label)
	root_box.add_child(route_label)
	root_box.add_child(route_detail_label)
	root_box.add_child(cargo_label)
	root_box.add_child(cargo_detail_label)
	root_box.add_child(district_label)
	root_box.add_child(district_detail_label)
	root_box.add_child(shift_brief_label)
	root_box.add_child(event_label)
	root_box.add_child(objective_label)
	root_box.add_child(hint_label)
	brief_labels = [route_detail_label, cargo_detail_label, shift_brief_label]

	help_panel = PanelContainer.new()
	help_panel.position = Vector2(1070, 18)
	help_panel.custom_minimum_size = Vector2(380, 180)
	root.add_child(help_panel)

	var help_box := VBoxContainer.new()
	help_box.offset_left = 12
	help_box.offset_top = 12
	help_box.offset_right = 12
	help_box.offset_bottom = 12
	help_panel.add_child(help_box)

	var help_title := _make_label("Quick Help")
	help_body = _make_label("1-5 = select contract\nEnter = start / confirm\nWASD = drive\nSpace = handbrake\nE = staging / deliver\nR = reset spawn\nH = hide help")
	help_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_box.add_child(help_title)
	help_box.add_child(help_body)

	summary_panel = PanelContainer.new()
	summary_panel.position = Vector2(520, 220)
	summary_panel.custom_minimum_size = Vector2(560, 300)
	root.add_child(summary_panel)

	var summary_box := VBoxContainer.new()
	summary_box.offset_left = 12
	summary_box.offset_top = 12
	summary_box.offset_right = 12
	summary_box.offset_bottom = 12
	summary_panel.add_child(summary_box)

	summary_title = _make_label("Shift Summary")
	summary_body = _make_label("")
	summary_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_box.add_child(summary_title)
	summary_box.add_child(summary_body)

func _make_label(default_text: String) -> Label:
	var label := Label.new()
	label.text = default_text
	label.add_theme_font_size_override("font_size", 16)
	return label

func set_contract_list(lines: Array[String], selected_index: int) -> void:
	var formatted := PackedStringArray()
	for i in range(lines.size()):
		var prefix := ">"
		if i != selected_index:
			prefix = " "
		formatted.append("%s %s" % [prefix, lines[i]])
	selection_label.text = "Contracts:\n" + "\n".join(formatted)

func set_contract_list_visible(visible: bool) -> void:
	selection_label.visible = visible

func set_client_visible(visible: bool) -> void:
	client_label.visible = visible

func set_phase_state(text: String) -> void:
	phase_label.text = "Shift: %s" % text

func set_client_state(text: String) -> void:
	client_label.text = "Client: %s" % text

func set_drive_state(speed_kph: float, stability_percent: float, cargo_state: String) -> void:
	cargo_label.text = "Cargo: %s | Stability: %d%% | Speed: %dkm/h" % [cargo_state, roundi(stability_percent), roundi(speed_kph)]

func set_route_state(route_name: String, route_type: String, district_name: String) -> void:
	route_label.text = "Route: %s (%s)" % [route_name, route_type]
	district_label.text = "District: %s" % district_name

func set_route_detail(text: String) -> void:
	route_detail_label.text = "Route Detail: %s" % text

func set_district_state(status_text: String) -> void:
	district_detail_label.text = "District Status: %s" % status_text

func set_event_state(title: String, message: String) -> void:
	event_label.text = "Event: %s - %s" % [title, message]
	event_label.visible = true

func set_cargo_detail(text: String) -> void:
	cargo_detail_label.text = "Cargo Detail: %s" % text

func set_shift_brief(text: String) -> void:
	shift_brief_label.text = "Shift Brief: %s" % text

func clear_event_state() -> void:
	event_label.text = "Event: None"
	event_label.visible = false

func set_objective(text: String) -> void:
	objective_label.text = "Objective: %s" % text

func set_hint(text: String) -> void:
	hint_label.text = "Hint: %s" % text

func set_help_text(text: String) -> void:
	help_body.text = text

func set_help_visible(visible: bool) -> void:
	help_panel.visible = visible

func set_brief_visible(visible: bool) -> void:
	for label in brief_labels:
		label.visible = visible

func toggle_help() -> void:
	help_panel.visible = not help_panel.visible

func flash(color: Color, alpha := 0.34, duration := 0.18) -> void:
	if flash_tween != null and flash_tween.is_running():
		flash_tween.kill()
	flash_rect.color = Color(color.r, color.g, color.b, alpha)
	flash_tween = create_tween()
	flash_tween.set_trans(Tween.TRANS_SINE)
	flash_tween.set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(flash_rect, "color:a", 0.0, duration)

func show_summary(title_text: String, body_text: String) -> void:
	summary_title.text = title_text
	summary_body.text = body_text
	summary_panel.visible = true

func hide_summary() -> void:
	summary_panel.visible = false
