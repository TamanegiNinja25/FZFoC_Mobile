extends SceneTree
## Headless check of the 3v3 arena and the adaptive AI:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/arena_test.gd
## Teams spawn 3v3; bots fight and score kills on their own; fountains heal;
## enemy bots get sharper when the player's team leads and ease off when it
## trails; reaching the kill target ends the match with a result screen.
## (The arena is typed as Node: naming ArenaMatch here would compile it before
## autoloads exist.)

var _arena: Node
var _frames := 0
var _sim := 0.0
var _phase := "boot"
var _failures: Array[String] = []


func _initialize() -> void:
	_arena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(_arena)
	current_scene = _arena
	Engine.max_physics_steps_per_frame = 64
	Engine.time_scale = 8.0


func _process(delta: float) -> bool:
	_frames += 1
	_sim += delta
	match _phase:
		"boot":
			if _frames < 5:
				return false
			var heroes: Array = _arena.heroes
			var blue := heroes.filter(func(h): return h.team == 0).size()
			var red := heroes.filter(func(h): return h.team == 1).size()
			_check(heroes.size() == 6 and blue == 3 and red == 3, "3v3 spawned (%d blue, %d red)" % [blue, red])
			_check(heroes.filter(func(h): return h.is_player).size() == 1 and _arena.bots.size() == 5, "one player, five bots")
			_check(is_equal_approx(_arena.enemy_skill(), 0.5), "enemy bots start at normal skill (0.5)")
			# Park the player safely in the corner so the bots decide the fight.
			_arena.hero.global_position = Vector3(-30, 0, 18)
			_sim = 0.0
			_phase = "fight"
		"fight":
			var total: int = _arena.kills[0] + _arena.kills[1]
			if total >= 3:
				_check(true, "bots fight and score on their own (%d kills in %.0f s)" % [total, _sim])
				_test_fountain()
				_phase = "heal"
				_sim = 0.0
			elif _sim > 240.0:
				_check(false, "bots scored 3 kills within 240 s (got %d)" % total)
				_test_fountain()
				_phase = "heal"
				_sim = 0.0
		"heal":
			if _sim > 2.0:
				var player: Node = _arena.hero
				_check(player.hp > 200.0, "fountain heals (200 → %d HP in 2 s)" % player.hp)
				_test_adaptive()
				_arena.kill_target = _arena.kills[0] + 1
				# The next blue kill wins: hand the player one.
				var victim: Node = _arena.heroes.filter(func(h): return h.team == 1 and h.is_alive())[0]
				_arena.hero.global_position = victim.global_position + Vector3(1.5, 0, 0)
				victim.take_damage(99999.0, _arena.hero)
				_phase = "result"
				_frames = 0
		"result":
			if _frames > 3:
				_check(_arena.over and _arena.winner == 0, "reaching the kill target ends the match in victory")
				_check(paused and _arena._result != null and _arena._result.is_inside_tree(), "result screen shown, game paused")
				for failure in _failures:
					printerr("FAIL: " + failure)
				print("ARENA TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
				Engine.time_scale = 1.0
				paused = false
				quit(1 if _failures.size() else 0)
	return false


func _test_fountain() -> void:
	var player: Node = _arena.hero
	player.revive_now()  # bots may have just killed it
	player.global_position = _arena.fountain_position(0)
	player.hp = 200.0


func _test_adaptive() -> void:
	var saved: Array = _arena.kills.duplicate()
	_arena.kills = [8, 2]
	_arena.update_adaptive()
	var leading: float = _arena.enemy_skill()
	_arena.kills = [2, 8]
	_arena.update_adaptive()
	var trailing: float = _arena.enemy_skill()
	_check(leading > 0.8 and trailing < 0.2, "adaptive AI: enemy skill %.2f when you lead by 6, %.2f when you trail by 6" % [leading, trailing])
	var ally_skill: float = _arena.bots.filter(func(b): return b.hero.team == 0)[0].skill
	_check(is_equal_approx(ally_skill, 0.55), "ally bots stay steady (%.2f)" % ally_skill)
	_arena.kills = saved
	_arena.update_adaptive()


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
