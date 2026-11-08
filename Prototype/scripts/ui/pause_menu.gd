class_name PauseMenu
extends CanvasLayer
## In-game menu: pauses the match and offers Resume, Settings (audio and video),
## Quit to Menu and Quit Game. Opened by the pause button or Android back.

var _overlay := Control.new()
var _panel := PanelContainer.new()
var _settings := SettingsPanel.new()


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.theme = UiTheme.build()
	_overlay.visible = false
	add_child(_overlay)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(dim)

	_center(_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	_panel.add_child(column)
	var heading := UiTheme.title(Label.new(), 44)
	heading.text = "Paused"
	column.add_child(heading)
	for spec in [["Resume", close], ["Settings", _open_settings], ["Quit to Menu", _quit_to_menu], ["Quit Game", func(): get_tree().quit()]]:
		var button := Button.new()
		button.text = spec[0]
		button.custom_minimum_size = Vector2(360, 68)
		button.pressed.connect(spec[1])
		column.add_child(button)

	_center(_settings)
	_settings.visible = false
	_settings.closed.connect(_close_settings)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if is_open():
			close()
		else:
			open()


func is_open() -> bool:
	return _overlay.visible


func open() -> void:
	_overlay.visible = true
	_panel.visible = true
	_settings.visible = false
	get_tree().paused = true


func close() -> void:
	_overlay.visible = false
	get_tree().paused = false


func _open_settings() -> void:
	_panel.visible = false
	_settings.visible = true


func _close_settings() -> void:
	_settings.visible = false
	_panel.visible = true


func _quit_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _center(control: Control) -> void:
	control.set_anchors_preset(Control.PRESET_CENTER)
	control.grow_horizontal = Control.GROW_DIRECTION_BOTH
	control.grow_vertical = Control.GROW_DIRECTION_BOTH
	_overlay.add_child(control)
