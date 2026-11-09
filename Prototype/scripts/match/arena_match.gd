class_name ArenaMatch
extends Node3D
## 3v3 on an original arena. The player plus two bot allies (blue, west) face
## three bots (red, east); online, friends take bot slots. Rules:
##   Mobile  — first to 15 kills, or the leader after 8:00;
##   Classic — the reference map's rules: first to 100 kills, no time limit,
##             and no passive gold (kills, creeps, bosses and duels pay).
## Either way the reference map's world runs: creep waves at 12 camps, two boss
## chains, the win boss (kill it and your team wins), and a duel every ~5 min
## unless the host switched duels off. A scoreboard lists every hero's kills
## and deaths, as the map's board does.

const MOBILE_KILLS := 15
const CLASSIC_KILLS := 100
## Mobile is 3v3; Classic is the reference map's 4v4.
const MOBILE_TEAM := 3
const CLASSIC_TEAM := 4
const MATCH_TIME := 480.0
## Experience multiplier: Mobile packs a full levelling curve into 8 minutes.
const MOBILE_XP_RATE := 3.0
const BASES := [Vector3(-38, 0, 0), Vector3(38, 0, 0)]
const HALF_FIELD := Vector2(44, 28)
const FOUNTAIN_RADIUS := 5.0
const FOUNTAIN_HEAL := 90.0  # HP per second
## The reference map revives a fallen hero at base after 4 s.
const RESPAWN_TIME := 4.0
## Combining circles (one by each base); any hero can use either.
const CIRCLES := [Vector3(-32, 0, -8), Vector3(32, 0, 8)]
const CIRCLE_RADIUS := 2.2
## The 12 creep camps in the order of the map's camp regions (rect18…rect29),
## laid out so each camp's wave twin sits opposite it, and every camp at least
## 20 units from a base so piles never reach a fountain.
const CAMPS := [Vector3(-14, 0, -12), Vector3(-14, 0, 12), Vector3(-25, 0, -21), Vector3(-25, 0, 21),
	Vector3(-37, 0, -21), Vector3(-37, 0, 21), Vector3(37, 0, 21), Vector3(37, 0, -21),
	Vector3(25, 0, 21), Vector3(14, 0, 12), Vector3(25, 0, -21), Vector3(14, 0, -12)]
const BOSS_SPOTS := {"a": Vector3(-7, 0, 22), "b": Vector3(7, 0, 22)}
const COLOSSUS_SPOT := Vector3(0, 0, -23)
const DUEL_CENTER := Vector3(0, 0, -46)
const CAMERA_OFFSET := Vector3(0, 14, 10)
const CAMERA_LIMIT := Vector2(36, 19)
## Enemy bot skill: base + per-kill lead of the player's team (adaptive AI).
const ENEMY_BASE_SKILL := 0.5
const ADAPT_PER_KILL := 0.1
const ALLY_SKILL := 0.55

var classic := false
var duels_enabled := true
var team_size := MOBILE_TEAM
var kill_target := MOBILE_KILLS
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
var duel: Duel
var events: MapEvents

## Duel state, from the Duel node on the host or snapshots on clients.
var duel_phase := "idle"
var duel_text := ""
var duel_in := 300.0

## Local multiplayer layer (null in single player).
var net_match: NetMatch
var online := false
var is_authority := true  # false on network clients: the host decides everything

var _sun: DirectionalLight3D
var _score := Label.new()
var _board_blue := Label.new()
var _board_red := Label.new()
var _board_text := ""
var _feed := VBoxContainer.new()
var _banner := Label.new()
var _result: Control
var _shake := 0.0


func _ready() -> void:
	online = Net.is_online() and Session.mode == Session.Mode.LOCAL_FRIENDS
	is_authority = not online or Net.is_host()
	classic = Session.classic
	duels_enabled = Session.duels
	team_size = CLASSIC_TEAM if classic else MOBILE_TEAM
	kill_target = CLASSIC_KILLS if classic else MOBILE_KILLS
	time_left = INF if classic else MATCH_TIME
	Controls.register()
	_build_world()
	GameSettings.apply_to_scene(get_viewport(), _sun)
	GameSettings.changed.connect(func(): GameSettings.apply_to_scene(get_viewport(), _sun))
	_spawn_teams()
	if is_authority:
		events = MapEvents.new()
		events.name = "MapEvents"
		events.arena = self
		events.camps = CAMPS
		events.boss_spots = BOSS_SPOTS
		events.colossus_spot = COLOSSUS_SPOT
		events.colossus_slain.connect(_on_colossus_slain)
		events.boss_slain.connect(func(boss_name, killer): announce("%s felled %s" % [hero_label(killer) if killer else "Someone", boss_name], Color(0.85, 0.6, 1.0)))
		add_child(events)
		if duels_enabled:
			duel = Duel.new()
			duel.name = "Duel"
			duel.arena = self
			duel.center = DUEL_CENTER
			duel.state_changed.connect(_on_duel_state)
			add_child(duel)
	Sfx.play_music("battle")

	hud = Hud.new()
	add_child(hud)
	hud.setup(hero)
	_build_match_ui()
	pause_menu = PauseMenu.new()
	pause_menu.online = online
	add_child(pause_menu)
	hud.pause_requested.connect(pause_menu.open)
	update_adaptive()
	if online:
		net_match = NetMatch.new()
		net_match.name = "NetMatch"
		net_match.arena = self
		add_child(net_match)


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
	print("PERF | %d FPS | GPU %.2f ms | render CPU %.2f ms | script %.2f ms | physics %.2f ms | %d draws | %dk tris | 3D %d%% | shadows %d | cap %d | units %d" % [
		Engine.get_frames_per_second(),
		RenderingServer.viewport_get_measured_render_time_gpu(rid),
		RenderingServer.viewport_get_measured_render_time_cpu(rid),
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) / 1000,
		roundi(get_viewport().scaling_3d_scale * 100.0), GameSettings.shadow_cascades, GameSettings.fps_cap,
		get_tree().get_node_count_in_group("units")])


func _process(delta: float) -> void:
	_log_perf(delta)
	_update_camera(delta)
	if over:
		return
	if is_authority:
		if duel:
			duel_in = duel.time_to_duel
		if not duel_active():  # the clock stops while a duel runs
			time_left = maxf(time_left - delta, 0.0)
		if time_left <= 0.0:
			_end(0 if kills[0] > kills[1] else (1 if kills[1] > kills[0] else -1))
	_update_score()


func _update_camera(delta: float) -> void:
	if camera == null:
		return
	var target: Vector3
	if duel_active():
		target = DUEL_CENTER + CAMERA_OFFSET
	elif hero:
		target = hero.global_position + CAMERA_OFFSET
		target.x = clampf(target.x, -CAMERA_LIMIT.x, CAMERA_LIMIT.x)
		target.z = clampf(target.z, -CAMERA_LIMIT.y + CAMERA_OFFSET.z, CAMERA_LIMIT.y + CAMERA_OFFSET.z)
	else:
		return
	var jump := camera.global_position.distance_to(target) > 30.0
	camera.global_position = target if jump else camera.global_position.lerp(target, minf(delta * 8.0, 1.0))
	if _shake > 0.0:  # the duel opens with a camera shake, as in the map
		_shake -= delta
		camera.global_position += Vector3(randf_range(-0.35, 0.35), randf_range(-0.2, 0.2), 0)


func duel_active() -> bool:
	return duel_phase != "idle"


func _physics_process(delta: float) -> void:
	if not is_authority:
		return  # clients get shop range and health from the host's snapshots
	for h in heroes:
		h.in_shop_range = h.is_alive() and not h.frozen and h.global_position.distance_to(BASES[h.team]) <= FOUNTAIN_RADIUS
		if h.in_shop_range:
			h.heal(FOUNTAIN_HEAL * delta)
		if h.is_alive() and not h.frozen and not h.items.is_empty():
			for circle in CIRCLES:
				if h.global_position.distance_to(circle) <= CIRCLE_RADIUS:
					var made := h.try_combine()
					if made != "" and h == hero:
						announce("Forged %s" % ItemCatalog.find(made).display_name, Color(1.0, 0.85, 0.4))


func fountain_position(team: int) -> Vector3:
	return BASES[team]


func circle_position(team: int) -> Vector3:
	return CIRCLES[team]


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
	if over or not is_authority:
		return
	if killer:
		kills[killer.team] += 1
		announce("%s slew %s" % [hero_label(killer), hero_label(victim)], Hero.TEAM_COLORS[killer.team])
	else:
		announce("%s fell" % hero_label(victim), Color(0.8, 0.8, 0.8))
	update_adaptive()
	if kills[0] >= kill_target:
		_end(0)
	elif kills[1] >= kill_target:
		_end(1)


func _on_colossus_slain(killer: Hero) -> void:
	if over or killer == null:
		return
	announce("%s brought down %s!" % [hero_label(killer), CreepTypes.COLOSSUS.name], Color(1.0, 0.85, 0.4))
	_end(killer.team)


func _on_duel_state(phase: String, text: String) -> void:
	duel_phase = phase
	duel_text = text


## Kill-feed name: player names online, "Name (Blue)" for bots.
func hero_label(h: Hero) -> String:
	if h == null:
		return "?"
	if online and h.owner_peer != 0 and Net.players.has(h.owner_peer):
		return str(Net.players[h.owner_peer])
	if not online and h == hero:
		return "You"
	return "%s (%s)" % [h.definition.display_name, "Blue" if h.team == 0 else "Red"]


## Kill feed line; the host also sends it to every client.
func announce(text: String, color: Color) -> void:
	_announce(text, color)
	if hero and (text.begins_with(hero_label(hero)) or text.ends_with(hero_label(hero))):
		Sfx.play("kill", -3.0)
	if net_match and is_authority:
		net_match.announce(text, color)


func add_bot_brain(h: Hero) -> void:
	var brain := BotBrain.new()
	brain.hero = h
	brain.arena = self
	h.add_child(brain)
	bots.append(brain)
	update_adaptive()


func _end(team: int) -> void:
	if net_match:
		net_match.end(team)
	finish(team)


## Shows the result; on the authority it also stops the match.
func finish(team: int) -> void:
	if over and winner == team:
		return
	over = true
	winner = team
	_update_score()
	var my_team := hero.team if hero else 0
	Sfx.play("victory" if team == my_team else ("defeat" if team != -1 else "back"))
	_show_result()
	get_tree().paused = true


# ------------------------------------------------------------------ spawning
## Six (Mobile) or eight (Classic) heroes, identical on every device: slot
## order and names never change. Offline: the player is blue slot 0. Online:
## each peer owns a slot on the team the host gave it; bots fill the rest.
## Every hero is picked once, as in the reference map: bots take heroes no
## player chose.
func _spawn_teams() -> void:
	var owners := []
	for team in 2:
		var row := []
		row.resize(team_size)
		row.fill(0)
		owners.append(row)
	var taken := []
	if online:
		var peers: Array = Session.net_teams.keys()
		peers.sort()
		var filled := [0, 0]
		for peer_id in peers:
			var team: int = Session.net_teams[peer_id]
			if filled[team] < team_size:
				owners[team][filled[team]] = peer_id
				filled[team] += 1
				taken.append(Net.heroes.get(peer_id, "vael"))
	else:
		taken.append(Session.hero_id)
	var bot_count := team_size * 2 - taken.size()
	var bot_picks := Roster.unique_bot_heroes(taken, bot_count)
	var next_bot := 0
	var my_id := multiplayer.get_unique_id() if online else 0
	for team in 2:
		for i in team_size:
			var h := Hero.new()
			h.team = team
			h.owner_peer = owners[team][i]
			h.is_player = (h.owner_peer == my_id) if online else (team == 0 and i == 0)
			h.puppet = not is_authority
			h.xp_rate = 1.0 if classic else MOBILE_XP_RATE
			if online and h.owner_peer != 0:
				h.definition = Roster.create(Net.heroes.get(h.owner_peer, "vael"))
			elif not online and h.is_player:
				h.definition = Roster.create(Session.hero_id)
			else:
				h.definition = Roster.create(bot_picks[next_bot])
				next_bot += 1
			h.respawn_time = RESPAWN_TIME
			if classic:  # the map has no passive income
				h.base_income = 0.0
				h.spree_income_step = 0.0
			h.name = "Hero%d" % (team * team_size + i)
			h.position = BASES[team] + Vector3(0, 0, (i - (team_size - 1) / 2.0) * 3.0)
			add_child(h)
			h.died.connect(_on_hero_died.bind(h))
			heroes.append(h)
			if h.is_player:
				hero = h
			elif is_authority and h.owner_peer == 0:
				add_bot_brain(h)


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

	_plane(Vector2(240, 180), Vector3(0, -0.03, -10), Color(0.24, 0.3, 0.22))           # land outside the walls
	_plane(HALF_FIELD * 2.0 + Vector2(2, 2), Vector3.ZERO, Color(0.31, 0.36, 0.28))   # grass
	_plane(Vector2(76, 6), Vector3(0, 0.01, 0), Color(0.42, 0.39, 0.33))                # central lane
	for camp in CAMPS:
		_disc(camp + Vector3(0, 0.012, 0), 3.6, Color(0.36, 0.33, 0.3))                  # camp clearings
	for chain in BOSS_SPOTS:
		_disc(BOSS_SPOTS[chain] + Vector3(0, 0.014, 0), 4.2, Color(0.3, 0.24, 0.32))
		_ring(BOSS_SPOTS[chain] + Vector3(0, 0.03, 0), 3.9, 4.2, Color(0.75, 0.5, 0.95))
	_disc(COLOSSUS_SPOT + Vector3(0, 0.014, 0), 5.5, Color(0.25, 0.2, 0.3))
	_ring(COLOSSUS_SPOT + Vector3(0, 0.03, 0), 5.2, 5.5, Color(0.95, 0.7, 0.3))
	_ring(Vector3(0, 0.02, 0), 3.75, 4.0, Color(0.5, 0.42, 0.26))                       # centre rune circle
	for circle in CIRCLES:                                                               # combining circles
		_disc(circle + Vector3(0, 0.016, 0), CIRCLE_RADIUS, Color(0.35, 0.28, 0.12))
		_ring(circle + Vector3(0, 0.035, 0), CIRCLE_RADIUS - 0.25, CIRCLE_RADIUS, Color(1.0, 0.8, 0.35))

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

	# The duel arena, off the field to the north: the camera pans here for duels.
	_disc(DUEL_CENTER + Vector3(0, -0.01, 0), Duel.RADIUS + 3.0, Color(0.2, 0.19, 0.22))
	_disc(DUEL_CENTER, Duel.RADIUS, Color(0.42, 0.36, 0.3))
	_ring(DUEL_CENTER + Vector3(0, 0.03, 0), Duel.RADIUS - 0.35, Duel.RADIUS, Color(1.0, 0.6, 0.3))
	for i in 8:
		var angle := TAU * i / 8.0
		_pillar(DUEL_CENTER + Vector3(cos(angle), 0, sin(angle)) * (Duel.RADIUS + 1.6), 0.6, 2.4)

	# Border walls.
	var w := HALF_FIELD.x + 0.5
	var d := HALF_FIELD.y + 0.5
	for spec in [[Vector3(0, 0.75, -d), Vector3(w * 2 + 2, 1.5, 1)], [Vector3(0, 0.75, d), Vector3(w * 2 + 2, 1.5, 1)],
			[Vector3(-w, 0.75, 0), Vector3(1, 1.5, d * 2)], [Vector3(w, 0.75, 0), Vector3(1, 1.5, d * 2)]]:
		_block(spec[0], spec[1], Color(0.3, 0.29, 0.28))
	# Symmetric pillars: cover to fight around, clear of camps.
	for x in [-1.0, 1.0]:
		_pillar(Vector3(10 * x, 0, 0), 1.8, 2.2)
		_pillar(Vector3(21 * x, 0, 5 * x), 1.3, 2.6)
		for z in [-1.0, 1.0]:
			_pillar(Vector3(6 * x, 0, 8 * z), 1.1, 3.2)
	Scenery.build(self, BASES, HALF_FIELD, DUEL_CENTER, Duel.RADIUS)

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
	board.offset_left = -230
	board.offset_right = 230
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(board)
	var board_column := VBoxContainer.new()
	board_column.add_theme_constant_override("separation", 2)
	board.add_child(board_column)
	_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_score.add_theme_font_size_override("font_size", 22)
	board_column.add_child(_score)
	# The map's scoreboard: every hero's kills / deaths, team by team.
	var rows := HBoxContainer.new()
	rows.add_theme_constant_override("separation", 18)
	board_column.add_child(rows)
	for spec in [[_board_blue, Hero.TEAM_COLORS[0]], [_board_red, Hero.TEAM_COLORS[1]]]:
		var column: Label = spec[0]
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_font_size_override("font_size", 15)
		column.add_theme_color_override("font_color", (spec[1] as Color).lightened(0.45))
		rows.add_child(column)
	_board_red.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	_feed.anchor_left = 1.0
	_feed.anchor_right = 1.0
	_feed.offset_left = -520
	_feed.offset_right = -130
	_feed.offset_top = 120
	_feed.alignment = BoxContainer.ALIGNMENT_BEGIN
	_feed.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_feed)

	# Big centre text for the duel: "Duel!", "3", "2", "1", "Fight!!", "Winner is …".
	_banner.set_anchors_preset(Control.PRESET_CENTER)
	_banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_banner.grow_vertical = Control.GROW_DIRECTION_BOTH
	_banner.offset_top = -160
	_banner.offset_bottom = -60
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.add_theme_font_size_override("font_size", 72)
	_banner.add_theme_color_override("font_color", Color(1.0, 0.82, 0.45))
	_banner.add_theme_constant_override("outline_size", 14)
	_banner.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.02))
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_banner)
	_update_score()


var _last_banner := ""


func _update_score() -> void:
	var clock := "no time limit"
	if time_left != INF:
		var t := int(ceil(time_left))
		clock = "%d:%02d" % [t / 60, t % 60]
	var duel_line := "DUEL" if duel_active() else ("Duel in %d:%02d" % [int(duel_in) / 60, int(duel_in) % 60] if duels_enabled else "Duels off")
	_score.text = "BLUE  %d  ⚔  %d  RED\n%s  ·  first to %d  ·  %s" % [kills[0], kills[1], clock, kill_target, duel_line]
	_update_board()
	if duel_text != _last_banner:
		_last_banner = duel_text
		_banner.text = duel_text
		if duel_text != "":
			_on_banner(duel_text)


## Kills / deaths per hero; rebuilt only when something changed.
func _update_board() -> void:
	var lines := [PackedStringArray(), PackedStringArray()]
	for h in heroes:
		var name_text := hero_label(h)
		if h.left_game:
			name_text += " (left)"
		lines[h.team].append("%s  %d / %d" % [name_text, h.kills, h.deaths])
	var text := "\n".join(lines[0]) + "|" + "\n".join(lines[1])
	if text == _board_text:
		return
	_board_text = text
	_board_blue.text = "\n".join(lines[0])
	_board_red.text = "\n".join(lines[1])


## Banner changes drive the duel's sounds and effects on every device.
func _on_banner(text: String) -> void:
	_banner.scale = Vector2(1.4, 1.4)
	_banner.pivot_offset = _banner.size / 2.0
	var tween := _banner.create_tween()
	tween.tween_property(_banner, "scale", Vector2.ONE, 0.25)
	match text:
		"Duel!":
			_shake = 2.0
			Sfx.play("duel", 0.0)
		"3", "2", "1":
			Sfx.play("click", 4.0)
		"Fight!!":
			Sfx.play("duel", 2.0)
		_:
			Sfx.play("kill", 0.0)


func _announce(text: String, color: Color) -> void:
	var line := Label.new()
	line.text = text
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	summary.text = "Blue %d — %d Red  (%s)\nYou: level %d · %d kills · %d deaths · %d gold\nDamage dealt %d · taken %d" % [
		kills[0], kills[1], "Classic" if classic else "Mobile", hero.level, hero.kills, hero.deaths, hero.gold,
		hero.damage_dealt, hero.damage_taken]
	column.add_child(summary)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 20)
	column.add_child(buttons)
	var actions: Array = [["Main Menu", _to_menu]] if online else [["Play Again", _play_again], ["Main Menu", _to_menu]]
	for spec in actions:
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
	if online:
		Net.leave()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
