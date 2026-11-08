class_name SettingsPanel
extends PanelContainer
## Audio and video settings, used by both the main menu and the in-game pause
## menu. Every change is applied and saved immediately.

signal closed
signal stress_test_requested

## The main menu offers the stress test; the in-game copy doesn't.
var show_stress_test := false

var _tabs := TabContainer.new()


func _ready() -> void:
	custom_minimum_size = Vector2(760, 520)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	add_child(column)

	var heading := UiTheme.title(Label.new(), 40)
	heading.text = "Settings"
	column.add_child(heading)

	_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_tabs)
	_tabs.add_child(_audio_tab())
	_tabs.add_child(_video_tab())

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 20)
	column.add_child(actions)
	var reset := Button.new()
	reset.text = "Reset to Defaults"
	reset.custom_minimum_size = Vector2(280, 64)
	reset.pressed.connect(_reset)
	actions.add_child(reset)
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(240, 64)
	back.pressed.connect(func(): closed.emit())
	actions.add_child(back)


## Restores platform defaults and rebuilds the tabs so the controls show them.
func _reset() -> void:
	GameSettings.reset_to_defaults()
	var current := _tabs.current_tab
	for child in _tabs.get_children():
		child.queue_free()
	_tabs.add_child(_audio_tab())
	_tabs.add_child(_video_tab())
	_tabs.set_deferred("current_tab", current)


func _audio_tab() -> Control:
	var grid := _grid("Audio")
	_slider(grid, "Master volume", "master_volume")
	_slider(grid, "Music", "music_volume")
	_slider(grid, "Sound effects", "sfx_volume")
	return grid


func _video_tab() -> Control:
	var grid := _grid("Video")
	_options(grid, "3D resolution", "render_scale", [[0.75, "75%"], [0.9, "90%"], [1.0, "100%"]])
	_options(grid, "Shadows", "shadow_cascades", [[0, "Off"], [2, "Medium (2 cascades)"], [4, "High (4 cascades)"]])
	_options(grid, "Frame rate cap", "fps_cap", [[30, "30 FPS (battery)"], [60, "60 FPS"]])
	var fps := CheckButton.new()
	fps.text = "Show FPS counter"
	fps.button_pressed = GameSettings.show_fps
	fps.toggled.connect(func(on: bool): GameSettings.set_and_save("show_fps", on))
	grid.add_child(Label.new())
	grid.add_child(fps)
	if show_stress_test:
		var stress := Button.new()
		stress.text = "Run stress test"
		stress.pressed.connect(func(): stress_test_requested.emit())
		grid.add_child(Label.new())
		grid.add_child(stress)
	return grid


func _grid(tab_name: String) -> GridContainer:
	var grid := GridContainer.new()
	grid.name = tab_name
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 18)
	return grid


func _slider(grid: GridContainer, label_text: String, key: String) -> void:
	var label := Label.new()
	label.text = label_text
	grid.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = GameSettings.get(key)
	slider.custom_minimum_size = Vector2(380, 40)
	slider.value_changed.connect(func(v: float): GameSettings.set_and_save(key, v))
	grid.add_child(slider)


func _options(grid: GridContainer, label_text: String, key: String, choices: Array) -> void:
	var label := Label.new()
	label.text = label_text
	grid.add_child(label)
	var picker := OptionButton.new()
	picker.custom_minimum_size = Vector2(380, 56)
	var current: Variant = GameSettings.get(key)
	for i in choices.size():
		picker.add_item(choices[i][1], i)
		if is_equal_approx(float(choices[i][0]), float(current)):
			picker.select(i)
	picker.item_selected.connect(func(i: int): GameSettings.set_and_save(key, choices[i][0]))
	grid.add_child(picker)
