extends SceneTree
## Balance simulation: a batch of all-bot Mobile matches at 8× speed, rotating
## which heroes play, then a per-hero table (win rate, kills and deaths per
## match, damage per minute). Not part of the pass/fail suite:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/balance_sim.gd -- 8

var _matches := 8
var _index := -1
var _scene: Node
var _sim := 0.0
var _stats := {}  # hero id → {played, wins, kills, deaths, damage, minutes}


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0 and args[0].is_valid_int():
		_matches = int(args[0])


func _process(delta: float) -> bool:
	if _scene == null:
		_next()
		return false
	_sim += delta
	if _scene.over or _sim > 600.0:
		_record()
		_scene.queue_free()
		_scene = null
		paused = false
		if _index + 1 >= _matches:
			_report()
			quit(0)
	return false


func _next() -> void:
	_index += 1
	root.get_node("/root/Session").classic = false
	var ids := Roster.ids()
	root.get_node("/root/Session").hero_id = ids[_index % ids.size()]
	Roster.bot_order_seed = _index * 3
	_scene = load("res://scenes/arena.tscn").instantiate()
	root.add_child(_scene)
	current_scene = _scene
	_scene.add_bot_brain(_scene.hero)
	_scene.hero.is_player = false
	Engine.max_physics_steps_per_frame = 64
	Engine.time_scale = 8.0
	_sim = 0.0


func _record() -> void:
	var minutes := maxf(_sim / 60.0, 0.1)
	var line := []
	for h in _scene.heroes:
		var id: String = h.definition.id
		if not _stats.has(id):
			_stats[id] = {"played": 0, "wins": 0, "kills": 0, "deaths": 0, "damage": 0.0, "minutes": 0.0}
		var s: Dictionary = _stats[id]
		s.played += 1
		s.wins += 1 if _scene.winner == h.team else 0
		s.kills += h.kills
		s.deaths += h.deaths
		s.damage += h.damage_dealt
		s.minutes += minutes
		line.append("%s(%s)" % [id, "B" if h.team == 0 else "R"])
	print("match %d: %.1f min, %d-%d, winner %d — %s" % [_index + 1, minutes, _scene.kills[0], _scene.kills[1], _scene.winner, ", ".join(line)])


func _report() -> void:
	Engine.time_scale = 1.0
	print("\nhero       played  win%%   kills/m  deaths/m  dmg/min")
	for id in Roster.ids():
		if not _stats.has(id):
			continue
		var s: Dictionary = _stats[id]
		print("%-10s %6d  %4.0f%%  %7.1f  %8.1f  %7.0f" % [id, s.played, 100.0 * s.wins / s.played,
			float(s.kills) / s.played, float(s.deaths) / s.played, s.damage / s.minutes])
	print("BALANCE SIM DONE")
