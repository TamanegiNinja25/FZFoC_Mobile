extends SceneTree
## A full all-bot Mobile match at 8× speed, to check pacing:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/pacing_test.gd
## Every hero (the player's too) is a bot. Reports levels, kills, gold, items
## and creeps every minute; passes if heroes reach their ultimate (level 10+)
## by the end without outgrowing the curve (average under 25), at least one
## duel happens, and creeps stay under the pile-up limit.

var _scene: Node
var _sim := 0.0
var _next_report := 60.0
var _failures: Array[String] = []
var _duels := 0
var _last_phase := "idle"
var _max_creeps := 0


func _initialize() -> void:
	pass


func _start() -> void:
	root.get_node("/root/Session").classic = false
	_scene = load("res://scenes/arena.tscn").instantiate()
	root.add_child(_scene)
	current_scene = _scene
	_scene.add_bot_brain(_scene.hero)
	_scene.hero.is_player = false
	Engine.max_physics_steps_per_frame = 64
	Engine.time_scale = 8.0


func _process(delta: float) -> bool:
	if _scene == null:
		_start()  # autoloads exist from the first frame, not in _initialize
		return false
	_sim += delta
	if _scene.duel_phase != _last_phase:
		if _scene.duel_phase == "intro":
			_duels += 1
		_last_phase = _scene.duel_phase
	_max_creeps = maxi(_max_creeps, _scene.events.alive_creeps())
	if _sim >= _next_report or _scene.over:
		_next_report += 60.0
		_report()
	if _scene.over or _sim > 500.0:
		_finish()
	return false


func _report() -> void:
	var levels: Array = _scene.heroes.map(func(h): return h.level)
	var gold: Array = _scene.heroes.map(func(h): return int(h.gold))
	var items: Array = _scene.heroes.map(func(h): return h.items.size())
	print("t=%3ds  score %d-%d  levels %s  gold %s  items %s  creeps %d  duels %d" % [
		_sim, _scene.kills[0], _scene.kills[1], str(levels), str(gold), str(items), _scene.events.alive_creeps(), _duels])


func _finish() -> void:
	Engine.time_scale = 1.0
	var levels: Array = _scene.heroes.map(func(h): return h.level)
	var average: float = levels.reduce(func(a, b): return a + b, 0) / float(levels.size())
	var ultimates: int = _scene.heroes.filter(func(h): return h.skills[3].rank > 0).size()
	print("END t=%ds over=%s winner=%d  average level %.1f  ultimates learned %d/6  max creeps %d" % [_sim, _scene.over, _scene.winner, average, ultimates, _max_creeps])
	_check(average >= 10.0 and average < 25.0, "average level %.1f at the end (target 10–25)" % average)
	_check(ultimates >= 3, "at least half the heroes learned their ultimate (%d)" % ultimates)
	_check(_duels >= 1, "a duel happened (%d)" % _duels)
	_check(_max_creeps <= _scene.events.total_cap, "creeps stayed under the pile-up limit (max %d)" % _max_creeps)
	for failure in _failures:
		printerr("FAIL: " + failure)
	print("PACING TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
	paused = false
	quit(1 if _failures.size() else 0)


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
