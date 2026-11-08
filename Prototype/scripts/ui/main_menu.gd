extends Node3D
## Main menu: a dark, ember-lit backdrop with Kindled Vael turning slowly, and
## a stone panel with Single Player, Play with Friends, Settings and Quit.
## Hero select, settings and the local-play panel open over it.

var _ui := Control.new()
var _main_panel: PanelContainer
var _hero_select: HeroSelect
var _settings: SettingsPanel
var _friends: PanelContainer
var _hero_model: VaelModel
var buttons := {}


func _ready() -> void:
	# Exported builds can't open a scene named on the command line, so the
	# benchmark build passes `-- --benchmark` and is redirected here.
	if "--benchmark" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://scenes/stress_test.tscn")
		return
	_build_backdrop()
	_build_ui()


func _process(delta: float) -> void:
	if _hero_model:
		_hero_model.rotation.y += delta * 0.35


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:  # Android back button
		if _main_panel and not _main_panel.visible:
			show_screen("main")
		else:
			get_tree().quit()


func show_screen(screen: String) -> void:
	_main_panel.visible = screen == "main"
	_hero_select.visible = screen == "heroes"
	_settings.visible = screen == "settings"
	_friends.visible = screen == "friends"


func _build_backdrop() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.05, 0.045, 0.05)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.35, 0.3, 0.3)
	var world_env := WorldEnvironment.new()
	world_env.environment = environment
	add_child(world_env)

	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-35, -40, 0)
	key.light_color = Color(1.0, 0.75, 0.5)
	add_child(key)

	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(20, 20)
	ground.mesh = plane
	ground.material_override = Toon.material(Color(0.14, 0.13, 0.12), 0.0)
	add_child(ground)

	var stand := Node3D.new()  # the model's effects add rings to its grandparent
	add_child(stand)
	var holder := Node3D.new()
	holder.position = Vector3(1.6, 0, 0)
	stand.add_child(holder)
	_hero_model = VaelModel.new()
	holder.add_child(_hero_model)
	_hero_model.set_form.call_deferred(true, 1.0)

	var camera := Camera3D.new()
	camera.fov = 40
	add_child(camera)
	camera.position = Vector3(0.0, 1.9, 6.8)
	camera.look_at(Vector3(0.7, 1.05, 0), Vector3.UP)
	GameSettings.apply_to_scene(get_viewport(), key)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui.theme = UiTheme.build()
	layer.add_child(_ui)

	_main_panel = PanelContainer.new()
	_main_panel.anchor_top = 0.5
	_main_panel.anchor_bottom = 0.5
	_main_panel.offset_left = 60
	_main_panel.offset_top = -300
	_main_panel.offset_right = 520
	_main_panel.offset_bottom = 300
	_ui.add_child(_main_panel)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 16)
	_main_panel.add_child(column)

	var title := UiTheme.title(Label.new(), 64)
	title.text = "FZFoC"
	column.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Hero Arena — working title"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", UiTheme.MUTED)
	column.add_child(subtitle)
	column.add_child(HSeparator.new())

	for spec in [["single", "Single Player"], ["friends", "Play with Friends"], ["settings", "Settings"], ["quit", "Quit"]]:
		var button := Button.new()
		button.text = spec[1]
		button.custom_minimum_size = Vector2(380, 72)
		button.add_theme_font_size_override("font_size", 28)
		column.add_child(button)
		buttons[spec[0]] = button
	buttons.single.pressed.connect(_on_single_player)
	buttons.friends.pressed.connect(func(): show_screen("friends"))
	buttons.settings.pressed.connect(func(): show_screen("settings"))
	buttons.quit.pressed.connect(func(): get_tree().quit())

	_hero_select = HeroSelect.new()
	_center(_hero_select)
	_hero_select.back_requested.connect(func(): show_screen("main"))
	_hero_select.start_requested.connect(_start_match)

	_settings = SettingsPanel.new()
	_settings.show_stress_test = true
	_center(_settings)
	_settings.closed.connect(func(): show_screen("main"))
	_settings.stress_test_requested.connect(func(): get_tree().change_scene_to_file("res://scenes/stress_test.tscn"))

	_friends = _build_friends_panel()
	_center(_friends)
	show_screen("main")


func _build_friends_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 420)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	panel.add_child(column)
	var heading := UiTheme.title(Label.new(), 40)
	heading.text = "Play with Friends"
	column.add_child(heading)
	var info := Label.new()
	info.text = "Local Wi-Fi play: one phone hosts, friends on the same network join.\nNo servers or accounts needed. Arriving in a later build."
	info.autowrap_mode = TextServer.AUTOWRAP_WORD
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(info)
	for text in ["Host Game", "Join Game"]:
		var button := Button.new()
		button.text = text + "  (coming soon)"
		button.disabled = true
		button.custom_minimum_size = Vector2(360, 64)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		column.add_child(button)
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(240, 64)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(func(): show_screen("main"))
	column.add_child(back)
	return panel


func _center(control: Control) -> void:
	control.set_anchors_preset(Control.PRESET_CENTER)
	control.grow_horizontal = Control.GROW_DIRECTION_BOTH
	control.grow_vertical = Control.GROW_DIRECTION_BOTH
	_ui.add_child(control)


func _on_single_player() -> void:
	Session.mode = Session.Mode.SINGLE_PLAYER
	show_screen("heroes")


func _start_match(hero_id: String) -> void:
	Session.hero_id = hero_id
	get_tree().change_scene_to_file("res://scenes/main.tscn")
