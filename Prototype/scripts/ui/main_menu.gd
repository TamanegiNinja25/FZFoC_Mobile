extends Node3D
## Main menu: a dark, ember-lit backdrop with Kindled Vael turning slowly, and
## a stone panel with Single Player, Play with Friends, Settings, Credits and
## Quit. Hero select, settings, credits and the local-play panel open over it.

var _ui := Control.new()
var _main_panel: PanelContainer
var _hero_select: HeroSelect
var _settings: SettingsPanel
var _friends: LobbyPanel
var _credits: CreditsPanel
var _hero_model: Node3D
var _title: Label
var _time := 0.0
var buttons := {}


func _ready() -> void:
	# Exported builds can't open a scene named on the command line, so the
	# benchmark build passes `-- --benchmark` and is redirected here.
	if "--benchmark" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://scenes/stress_test.tscn")
		return
	_build_backdrop()
	_build_ui()
	Sfx.play_music("menu")
	var checker := UpdateChecker.new()
	checker.update_available.connect(_on_update_available)
	add_child(checker)


func _process(delta: float) -> void:
	_time += delta
	if _hero_model:
		_hero_model.rotation.y += delta * 0.35
	if _title:  # slow gold pulse on the title
		_title.modulate = Color(1, 1, 1).lerp(Color(1.25, 1.1, 0.85), 0.5 + 0.5 * sin(_time * 1.6))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:  # Android back button
		if _main_panel and not _main_panel.visible:
			show_screen("main")
		else:
			get_tree().quit()


func show_screen(screen: String) -> void:
	var panels := {"main": _main_panel, "heroes": _hero_select, "settings": _settings, "friends": _friends, "credits": _credits}
	for key in panels:
		var was_visible: bool = panels[key].visible
		panels[key].visible = key == screen
		if key == screen and not was_visible:
			UiTheme.pop_in.call_deferred(panels[key])
			if key == "heroes":
				Sfx.announce("choose_your_character")


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
	_hero_model = Roster.create("vael").create_model()
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
	_ui.theme = UiTheme.build()
	layer.add_child(_ui)
	UiTheme.apply_safe_area(_ui, 0.0)

	_main_panel = PanelContainer.new()
	_main_panel.anchor_top = 0.5
	_main_panel.anchor_bottom = 0.5
	_main_panel.offset_left = 60
	_main_panel.offset_top = -320
	_main_panel.offset_right = 520
	_main_panel.offset_bottom = 320
	_ui.add_child(_main_panel)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 14)
	_main_panel.add_child(column)

	_title = UiTheme.title(Label.new(), 64)
	_title.text = "FZFoC"
	column.add_child(_title)
	var subtitle := Label.new()
	subtitle.text = "Hero Arena — working title · v%s" % UpdateChecker.current_version()
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", UiTheme.MUTED)
	column.add_child(subtitle)
	column.add_child(HSeparator.new())
	if Session.notice != "":
		var notice := Label.new()
		notice.text = Session.notice
		notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		notice.add_theme_color_override("font_color", Color(1.0, 0.65, 0.5))
		column.add_child(notice)
		Session.notice = ""

	for spec in [["single", "Single Player"], ["friends", "Play with Friends"], ["settings", "Settings"], ["credits", "Credits"], ["quit", "Quit"]]:
		var button := Button.new()
		button.text = spec[1]
		var minor: bool = spec[0] in ["credits", "quit"]
		button.custom_minimum_size = Vector2(380, 56 if minor else 72)
		button.add_theme_font_size_override("font_size", 24 if minor else 28)
		column.add_child(button)
		buttons[spec[0]] = button
	buttons.single.pressed.connect(_on_single_player)
	buttons.friends.pressed.connect(func(): show_screen("friends"))
	buttons.settings.pressed.connect(func(): show_screen("settings"))
	buttons.credits.pressed.connect(func(): show_screen("credits"))
	buttons.quit.pressed.connect(func(): get_tree().quit())

	_hero_select = HeroSelect.new()
	_center(_hero_select)
	_hero_select.back_requested.connect(func(): show_screen("main"))
	_hero_select.start_requested.connect(_start_match.bind("res://scenes/arena.tscn"))
	_hero_select.training_requested.connect(_start_match.bind("res://scenes/main.tscn"))

	_settings = SettingsPanel.new()
	_settings.show_stress_test = true
	_center(_settings)
	_settings.closed.connect(func(): show_screen("main"))
	_settings.stress_test_requested.connect(func(): get_tree().change_scene_to_file("res://scenes/stress_test.tscn"))

	_friends = LobbyPanel.new()
	_friends.back_requested.connect(func(): show_screen("main"))
	_center(_friends)
	_credits = CreditsPanel.new()
	_credits.closed.connect(func(): show_screen("main"))
	_center(_credits)
	Net.match_starting.connect(_on_net_match_starting)
	for panel in [_hero_select, _settings, _friends, _credits]:
		panel.visible = false
	_slide_in_main_panel.call_deferred()


## Opening flourish: the menu panel slides in from the left as it fades up.
func _slide_in_main_panel() -> void:
	var rest := _main_panel.position.x
	_main_panel.position.x = rest - 120
	_main_panel.modulate.a = 0.0
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_main_panel, "position:x", rest, 0.5)
	tween.tween_property(_main_panel, "modulate:a", 1.0, 0.4)


func _center(control: Control) -> void:
	control.set_anchors_preset(Control.PRESET_CENTER)
	control.grow_horizontal = Control.GROW_DIRECTION_BOTH
	control.grow_vertical = Control.GROW_DIRECTION_BOTH
	_ui.add_child(control)


## A newer release exists on GitHub: offer it under the menu buttons.
func _on_update_available(version: String, url: String) -> void:
	var button := Button.new()
	button.text = "Update available: %s — Download" % version
	button.custom_minimum_size = Vector2(380, 56)
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	button.set_meta("sfx", "confirm")
	button.pressed.connect(func(): OS.shell_open(url))
	_main_panel.get_child(0).add_child(button)
	UiTheme.pop_in(button)


func _on_net_match_starting(teams: Dictionary) -> void:
	Session.mode = Session.Mode.LOCAL_FRIENDS
	Session.net_teams = teams
	get_tree().change_scene_to_file("res://scenes/arena.tscn")


func _on_single_player() -> void:
	Session.mode = Session.Mode.SINGLE_PLAYER
	show_screen("heroes")


func _start_match(hero_id: String, scene: String) -> void:
	Session.hero_id = hero_id
	Session.bot_seed = randi_range(1, 999999)  # bots draw from the whole roster
	get_tree().change_scene_to_file(scene)
