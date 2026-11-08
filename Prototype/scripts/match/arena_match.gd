class_name ArenaMatch
extends Node3D
## Single player: 3v3 on an original arena. The player plus two bot allies
## (blue, west) face three bots (red, east). First team to `kill_target` kills
## wins, or the leader when time runs out. Enemy bots adapt to the score.

const KILL_TARGET := 15
const MATCH_TIME := 480.0
const BASES := [Vector3(-26, 0, 0), Vector3(26, 0, 0)]
const FOUNTAIN_RADIUS := 5.0
const FOUNTAIN_HEAL := 90.0  # HP per second
const RESPAWN_TIME := 6.0
const CAMERA_OFFSET := Vector3(0, 14, 10)
const CAMERA_LIMIT := Vector2(22, 10)
## Enemy bot skill: base + per-kill lead of the player's team (adaptive AI).
const ENEMY_BASE_SKILL := 0.5
const ADAPT_PER_KILL := 0.1
const ALLY_SKILL := 0.55

var kill_target := KILL_TARGET
var time_left := MATCH_TIME
var kills := [0, 0]
var over := false
var winner := -2  # -2 playing, -1 draw, 0 blue, 1 red

var hero: Hero  # the player's hero
var heroes: Array[Hero] = []
var bots: Array[BotBrain] = []
var hud: Hud
var pause_menu: PauseMenu
var camera: Camera3D

var _sun: DirectionalLight3D
var _score := Label.new()
var _feed := VBoxContainer.new()
var _result: Control


func _ready() -> void:
	Controls.register()
	_build_world()
	GameSettings.apply_to_scene(get_viewport(), _sun)
	GameSettings.changed.connect(func(): GameSettings.apply_to_scene(get_viewport(), _sun))
	_spawn_teams()
	_spawn_camps()

	hud = Hud.new()
	add_child(hud)
	hud.setup(hero)
	_build_match_ui()
	pause_menu = PauseMenu.new()
	add_child(pause_menu)
	hud.pause_requested.connect(pause_menu.open)
	update_adaptive()


var _perf_clock := 0.0


## In debug builds (or with the FPS counter on), log where frame time goes
## every 2 s; read it with `adb logcat -s godot`.
func _log_perf(delta: float) -> void:
	_perf_clock += delta
	if _perf_clock < 2.0 or not (GameSettings.show_fps or OS.is_debug_build()):
		return
	_perf_clock = 0.0
	var rid := get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(rid, true)
	print("PERF | %d FPS | GPU %.2f ms | render CPU %.2f ms | script %.2f ms | physics %.2f ms | %d draws | %dk tris | 3D %d%% | shadows %d | cap %d" % [
		Engine.get_frames_per_second(),
		RenderingServer.viewport_get_measured_render_time_gpu(rid),
		RenderingServer.viewport_get_measured_render_time_cpu(rid),
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) / 1000,
		roundi(get_viewport().scaling_3d_scale * 100.0), GameSettings.shadow_cascades, GameSettings.fps_cap])


func _process(delta: float) -> void:
	_log_perf(delta)
	if hero:
		var target := hero.global_position + CAMERA_OFFSET
		target.x = clampf(target.x, -CAMERA_LIMIT.x, CAMERA_LIMIT.x)
		target.z = clampf(target.z, -CAMERA_LIMIT.y + CAMERA_OFFSET.z, CAMERA_LIMIT.y + CAMERA_OFFSET.z)
		camera.global_position = camera.global_position.lerp(target, minf(delta * 8.0, 1.0))
	if over:
		return
	time_left = maxf(time_left - delta, 0.0)
	if time_left <= 0.0:
		_end(0 if kills[0] > kills[1] else (1 if kills[1] > kills[0] else -1))
	_update_score()


func _physics_process(delta: float) -> void:
	for h in heroes:
		if h.is_alive() and h.global_position.distance_to(BASES[h.team]) <= FOUNTAIN_RADIUS:
			h.heal(FOUNTAIN_HEAL * delta)


func fountain_position(team: int) -> Vector3:
	return BASES[team]


func center_point() -> Vector3:
	return Vector3.ZERO


## Adaptive AI: the further the player's team leads, the sharper the enemy
## bots play; the further it trails, the more they ease off. Allies stay steady.
func update_adaptive() -> void:
	var lead: int = kills[0] - kills[1]
	var enemy_skill := clampf(ENEMY_BASE_SKILL + ADAPT_PER_KILL * lead, 0.15, 0.95)
	for bot in bots:
		bot.skill = enemy_skill if bot.hero.team == 1 else ALLY_SKILL


func enemy_skill() -> float:
	for bot in bots:
		if bot.hero.team == 1:
			return bot.skill
	return 0.0


func _on_hero_died(killer: Hero, victim: Hero) -> void:
	if over:
		return
	if killer:
		kills[killer.team] += 1
		_announce("%s slew %s" % [_label(killer), _label(victim)], Hero.TEAM_COLORS[killer.team])
		if killer == hero or victim == hero:
			Sfx.play("kill", -3.0)
	else:
		_announce("%s fell" % _label(victim), Color(0.8, 0.8, 0.8))
	update_adaptive()
	if kills[0] >= kill_target:
		_end(0)
	elif kills[1] >= kill_target:
		_end(1)


func _label(h: Hero) -> String:
	if h == hero:
		return "You"
	return "%s (%s)" % [h.definition.display_name, "Blue" if h.team == 0 else "Red"]


func _end(team: int) -> void:
	over = true
	winner = team
	_update_score()
	Sfx.play("victory" if team == 0 else "defeat")
	_show_result()
	get_tree().paused = true


# ------------------------------------------------------------------ spawning
func _spawn_teams() -> void:
	for team in 2:
		for i in 3:
			var h := Hero.new()
			h.team = team
			h.is_player = team == 0 and i == 0
			h.definition = Roster.create(Session.hero_id if h.is_player else "vael")
			h.respawn_time = RESPAWN_TIME
			h.name = "Player" if h.is_player else "%s%d" % ["Blue" if team == 0 else "Red", i]
			h.position = BASES[team] + Vector3(0, 0, (i - 1) * 3.0)
			add_child(h)
			h.died.connect(_on_hero_died.bind(h))
			heroes.append(h)
			if h.is_player:
				hero = h
			else:
				var brain := BotBrain.new()
				brain.hero = h
				brain.arena = self
				h.add_child(brain)
				bots.append(brain)


func _spawn_camps() -> void:
	for z in [-14.0, 14.0]:
		for x in [-1.6, 1.6]:
			var sentinel := Dummy.new()
			sentinel.position = Vector3(x, 0, z)
			sentinel.respawn_time = 25.0
			add_child(sentinel)


# ------------------------------------------------------------------ the map
func _build_world() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.1, 0.11, 0.13)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.6, 0.6, 0.65)
	var world_env := WorldEnvironment.new()
	world_env.environment = environment
	add_child(world_env)

	_sun = DirectionalLight3D.new()
	_sun.rotation_degrees = Vector3(-55, 30, 0)
	# The camera sees ~30 units; past that, shadow casters only cost GPU time.
	_sun.directional_shadow_max_distance = 40.0
	add_child(_sun)

	_plane(Vector2(64, 40), Vector3.ZERO, Color(0.31, 0.36, 0.28))             # grass
	_plane(Vector2(52, 6), Vector3(0, 0.01, 0), Color(0.42, 0.39, 0.33))       # central lane
	for z in [-14.0, 14.0]:
		_plane(Vector2(10, 7), Vector3(0, 0.01, z), Color(0.36, 0.33, 0.3))    # camp clearings
	_ring(Vector3(0, 0.02, 0), 3.75, 4.0, Color(0.5, 0.42, 0.26))               # centre rune circle

	for team in 2:  # bases with healing fountains
		var base: Vector3 = BASES[team]
		var tint: Color = Hero.TEAM_COLORS[team]
		_disc(base + Vector3(0, 0.015, 0), FOUNTAIN_RADIUS + 1.0, tint.darkened(0.55))
		_ring(base + Vector3(0, 0.03, 0), FOUNTAIN_RADIUS - 0.3, FOUNTAIN_RADIUS, tint)
		var font := MeshInstance3D.new()
		var basin := CylinderMesh.new()
		basin.top_radius = 1.0
		basin.bottom_radius = 1.2
		basin.height = 0.5
		basin.radial_segments = 24
		basin.rings = 1
		font.mesh = basin
		font.position = base + Vector3(0, 0.25, 0)
		var water := Toon.material(tint.lightened(0.3), 0.0)
		water.emission_enabled = true
		water.emission = tint
		water.emission_energy_multiplier = 1.5
		font.material_override = water
		add_child(font)

	# Border walls.
	for spec in [[Vector3(0, 0.75, -20.5), Vector3(66, 1.5, 1)], [Vector3(0, 0.75, 20.5), Vector3(66, 1.5, 1)],
			[Vector3(-32.5, 0.75, 0), Vector3(1, 1.5, 42)], [Vector3(32.5, 0.75, 0), Vector3(1, 1.5, 42)]]:
		_block(spec[0], spec[1], Color(0.3, 0.29, 0.28))
	# Symmetric pillars and boulders: cover to fight around.
	for x in [-1.0, 1.0]:
		_pillar(Vector3(12 * x, 0, 0), 1.8, 2.2)
		for z in [-1.0, 1.0]:
			_pillar(Vector3(8 * x, 0, 9 * z), 1.1, 3.2)
			_pillar(Vector3(18 * x, 0, 7 * z), 1.3, 2.6)

	camera = Camera3D.new()
	camera.fov = 50
	add_child(camera)
	camera.position = BASES[0] + CAMERA_OFFSET
	camera.rotation_degrees = Vector3(-54.5, 0, 0)


func _plane(size: Vector2, at: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = size
	mesh.mesh = plane
	mesh.position = at
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.material_override = Toon.material(color, 0.0)
	add_child(mesh)


func _disc(at: Vector3, radius: float, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = 0.02
	cylinder.radial_segments = 40
	cylinder.rings = 1
	mesh.mesh = cylinder
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.position = at
	mesh.material_override = Toon.material(color, 0.0)
	add_child(mesh)


func _ring(at: Vector3, inner: float, outer: float, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = inner
	torus.outer_radius = outer
	torus.rings = 48
	torus.ring_segments = 4
	mesh.mesh = torus
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.position = at
	mesh.scale = Vector3(1, 0.05, 1)
	var material := Toon.material(color, 0.0)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.6
	mesh.material_override = material
	add_child(mesh)


func _block(at: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = at
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.material_override = Toon.material(color)
	body.add_child(mesh)
	add_child(body)


func _pillar(at: Vector3, radius: float, height: float) -> void:
	var body := StaticBody3D.new()
	body.position = at + Vector3(0, height / 2.0, 0)
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = radius
	cylinder.height = height
	shape.shape = cylinder
	body.add_child(shape)
	var mesh := MeshInstance3D.new()
	var cylinder_mesh := CylinderMesh.new()
	cylinder_mesh.top_radius = radius * 0.85
	cylinder_mesh.bottom_radius = radius
	cylinder_mesh.height = height
	cylinder_mesh.radial_segments = 24
	cylinder_mesh.rings = 1
	mesh.mesh = cylinder_mesh
	mesh.material_override = Toon.material(Color(0.46, 0.44, 0.41))
	body.add_child(mesh)
	var cap := MeshInstance3D.new()
	var cap_mesh := SphereMesh.new()
	cap_mesh.radius = radius * 0.85
	cap_mesh.height = radius * 0.85
	cap_mesh.is_hemisphere = true
	cap_mesh.radial_segments = 24
	cap_mesh.rings = 6
	cap.mesh = cap_mesh
	cap.position.y = height / 2.0
	cap.material_override = Toon.material(Color(0.38, 0.36, 0.34))
	body.add_child(cap)
	add_child(body)


# ------------------------------------------------------------------ match UI
func _build_match_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var root := Control.new()
	root.theme = UiTheme.build()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	UiTheme.apply_safe_area(root)

	var board := PanelContainer.new()
	board.add_theme_stylebox_override("panel", UiTheme.hud_panel())
	board.anchor_left = 0.5
	board.anchor_right = 0.5
	board.offset_left = -190
	board.offset_right = 190
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(board)
	_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_score.add_theme_font_size_override("font_size", 22)
	board.add_child(_score)

	_feed.anchor_left = 1.0
	_feed.anchor_right = 1.0
	_feed.offset_left = -420
	_feed.offset_right = -130
	_feed.offset_top = 8
	_feed.alignment = BoxContainer.ALIGNMENT_BEGIN
	_feed.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_feed)
	_update_score()


func _update_score() -> void:
	var t := int(ceil(time_left))
	_score.text = "BLUE  %d  ⚔  %d  RED\n%d:%02d  ·  first to %d" % [kills[0], kills[1], t / 60, t % 60, kill_target]


func _announce(text: String, color: Color) -> void:
	var line := Label.new()
	line.text = text
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	line.add_theme_color_override("font_color", color.lightened(0.25))
	line.add_theme_font_size_override("font_size", 18)
	_feed.add_child(line)
	while _feed.get_child_count() > 4:
		_feed.get_child(0).free()
	var tween := line.create_tween()
	tween.tween_interval(4.0)
	tween.tween_property(line, "modulate:a", 0.0, 0.6)
	tween.tween_callback(line.queue_free)


func _show_result() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_result = Control.new()
	_result.set_anchors_preset(Control.PRESET_FULL_RECT)
	_result.theme = UiTheme.build()
	layer.add_child(_result)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_result.add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	_result.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	panel.add_child(column)
	var heading := UiTheme.title(Label.new(), 64)
	heading.text = {0: "Victory", 1: "Defeat", -1: "Draw"}[winner]
	column.add_child(heading)
	var summary := Label.new()
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.text = "Blue %d — %d Red\nYou: %d kills · %d deaths · %d gold" % [kills[0], kills[1], hero.kills, hero.deaths, hero.gold]
	column.add_child(summary)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 20)
	column.add_child(buttons)
	for spec in [["Play Again", _play_again], ["Main Menu", _to_menu]]:
		var button := Button.new()
		button.text = spec[0]
		button.custom_minimum_size = Vector2(260, 68)
		button.pressed.connect(spec[1])
		buttons.add_child(button)
	UiTheme.pop_in.call_deferred(panel)


func _play_again() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
