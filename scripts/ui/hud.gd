class_name LogisticsHUD
extends CanvasLayer

var root_panel: PanelContainer
var summary_panel: PanelContainer
var selection_label: Label
var route_label: Label
var cargo_label: Label
var district_label: Label
var objective_label: Label
var hint_label: Label
var summary_title: Label
var summary_body: Label

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
	root_panel.custom_minimum_size = Vector2(540, 260)
	root.add_child(root_panel)

	var root_box := VBoxContainer.new()
	root_box.offset_left = 12
	root_box.offset_top = 12
	root_box.offset_right = 12
	root_box.offset_bottom = 12
	root_panel.add_child(root_box)

	selection_label = _make_label("Contracts")
	route_label = _make_label("Route")
	cargo_label = _make_label("Cargo")
	district_label = _make_label("District")
	objective_label = _make_label("Objective")
	hint_label = _make_label("Hint")

	root_box.add_child(selection_label)
	root_box.add_child(route_label)
	root_box.add_child(cargo_label)
	root_box.add_child(district_label)
	root_box.add_child(objective_label)
	root_box.add_child(hint_label)

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
	label.add_theme_font_size_override("font_size", 18)
	return label

func set_contract_list(lines: Array[String], selected_index: int) -> void:
	var formatted := PackedStringArray()
	for i in range(lines.size()):
		var prefix := ">"
		if i != selected_index:
			prefix = " "
		formatted.append("%s %s" % [prefix, lines[i]])
	selection_label.text = "Contracts:\n" + "\n".join(formatted)

func set_drive_state(speed_kph: float, stability_percent: float, cargo_state: String) -> void:
	cargo_label.text = "Cargo: %s | Stability: %d%% | Speed: %dkm/h" % [cargo_state, roundi(stability_percent), roundi(speed_kph)]

func set_route_state(route_name: String, route_type: String, district_name: String) -> void:
	route_label.text = "Route: %s (%s)" % [route_name, route_type]
	district_label.text = "District: %s" % district_name

func set_objective(text: String) -> void:
	objective_label.text = "Objective: %s" % text

func set_hint(text: String) -> void:
	hint_label.text = "Hint: %s" % text

func show_summary(title_text: String, body_text: String) -> void:
	summary_title.text = title_text
	summary_body.text = body_text
	summary_panel.visible = true

func hide_summary() -> void:
	summary_panel.visible = false
