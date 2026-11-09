extends SceneTree
## Headless check of the reference map's systems:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/map_systems_test.gd
## Levels, XP, attributes and skill ranks; the stat shop, exclusive items and
## recipes; stuns and roots; creep waves; boss chains; the win boss; the duel;
## Classic rules; and the attack button. (The arena is typed as Node: naming
## its class here would compile it before autoloads exist.)

var _scene: Node
var _failures: Array[String] = []
var _steps: Array[Callable] = []
var _wait := 0.0
var _hero: Hero
var _saved := {}


func _initialize() -> void:
	_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(_scene)
	current_scene = _scene
	_steps = [_progression, _shop_rules, _status_effects, _start_arena, _waves, _wave_cap, _wave_90, _bosses,
		_boss_respawned, _duel_start, _duel_fight, _duel_kill, _duel_over, _attack_order, _colossus, _classic, _done]


func _process(delta: float) -> bool:
	_wait -= delta
	if _wait > 0.0 or _steps.is_empty():
		return false
	var step: Callable = _steps.pop_front()
	step.call()
	return false


# ------------------------------------------------------- hero systems (training)
func _progression() -> void:
	_hero = _scene.hero
	_check(Hero.xp_for_level(2) == 200.0 and Hero.xp_for_level(3) == 500.0 and Hero.xp_for_level(50) == 127400.0,
			"XP curve: 200 / 500 … 127,400 for level 50 (Warcraft III default)")
	_check(_hero.level == 1 and _hero.skill_points == 1, "start: level 1 with 1 skill point")
	_check(_hero.skills[0].can_learn(_hero) and not _hero.skills[1].can_learn(_hero) and not _hero.skills[3].can_learn(_hero),
			"level 1: only the first skill can be learned")
	var hp1 := _hero.max_hp
	var dmg1 := _hero.attack_damage
	_hero.add_xp(200.0)
	_check(_hero.level == 2 and _hero.skill_points == 2, "200 XP: level 2, a second skill point")
	_check(is_equal_approx(_hero.attribute("str"), 33.0) and is_equal_approx(_hero.max_hp, hp1 + 30.0),
			"Vael gains 3 strength → +30 max HP")
	_check(is_equal_approx(_hero.attack_damage, dmg1 + 6.0), "strength is primary: +2 damage per point (+6)")
	_check(_hero.learn_skill(0) and _hero.skills[0].rank == 1 and _hero.skill_points == 1, "learning spends a point")
	_check(not _hero.learn_skill(0), "rank 2 of the first skill needs level 6")
	_check(_hero.learn_skill(1), "the second skill unlocks at level 2")
	_check(not _hero.learn_skill(2), "no points left")
	_hero.add_xp(Hero.xp_for_level(10) - _hero.xp)
	_check(_hero.level == 10 and _hero.skills[3].can_learn(_hero), "the ultimate unlocks at level 10")
	# Creep XP: a level-1 creep is worth 25, reduced by the hero's level (50% from level 4).
	var before := _hero.xp
	_hero.share_kill_xp(_hero.global_position, 1, false)
	_check(is_equal_approx(_hero.xp - before, 12.5), "creep XP at level 10: 25 × 50% = 12.5")
	before = _hero.xp
	_hero.share_kill_xp(_hero.global_position, 3, true)
	_check(is_equal_approx(_hero.xp - before, 160.0), "killing a level-3 hero: 160 XP")


func _shop_rules() -> void:
	_hero.gold = 30000.0
	var str_before := _hero.attribute("str")
	_check(_hero.buy("tome_str_2") == "" and is_equal_approx(_hero.attribute("str"), str_before + 2.0)
			and _hero.items.is_empty() and is_equal_approx(_hero.gold, 29750.0), "Tome of Might +2: +2 strength for 250, no slot used")
	var xp_before := _hero.xp
	_hero.buy("tome_xp_minor")
	_check(is_equal_approx(_hero.xp - xp_before, 100.0), "Minor Tome of Lore: +100 XP")
	_check(_hero.buy("galeheart_ribbon") == "Only Ryn can wield this", "exclusive items refuse other heroes")
	_check(_hero.buy("kilnheart_core") == "" and _hero.items.size() == 1, "Vael buys his own Kilnheart Core (10,000)")
	_check(_hero.buy("bastion_aegis") == "Made at the combining circle", "artifacts can't be bought")
	_hero.sell(0)
	_hero.gold = 30000.0
	var hp_before := _hero.max_hp
	_hero.buy("riveted_mail")
	_hero.buy("bulwark_plate")
	_check(_hero.has_recipe_ready(), "Riveted Mail + Bulwark Plate is a recipe")
	_check(_hero.try_combine() == "bastion_aegis" and _hero.items.size() == 1 and _hero.items[0].id == "bastion_aegis",
			"the combining circle fuses them into Bastion Aegis")
	_check(is_equal_approx(_hero.max_hp, hp_before + 450.0), "Bastion Aegis: +450 max HP")
	_hero.sell(0)


func _status_effects() -> void:
	_hero.skills[0].time_left = 0.0
	_hero.apply_stun(1.0)
	_check(_hero.is_stunned() and not _hero.try_skill(0), "a stunned hero can't cast")
	_hero._stun_time = 0.0
	_hero.apply_root(1.0)
	_check(_hero.is_rooted() and _hero.try_skill(0), "a rooted hero can still cast")
	_hero._root_time = 0.0


# ------------------------------------------------------------ the arena world
func _start_arena() -> void:
	_scene.queue_free()
	root.get_node("/root/Session").classic = false
	_scene = load("res://scenes/arena.tscn").instantiate()
	root.add_child(_scene)
	current_scene = _scene
	for brain in _scene.bots:
		brain.queue_free()  # still heroes, no decisions: the checks stay deterministic
	_scene.bots.clear()
	_hero = _scene.hero
	_check(_scene.kill_target == 15 and _scene.time_left == 480.0 and _scene.heroes.size() == 6, "Mobile rules: 3v3, 15 kills or 8:00")
	var bosses := get_nodes_in_group("creeps").filter(func(c): return c.is_boss and not c.is_colossus)
	_check(bosses.size() == 2 and bosses.all(func(c): return c.max_hp == 500.0), "two boss chains start with a 500 HP boss")
	_check(_scene.events.colossus.max_hp == 100000.0, "the win boss has 100,000 HP")
	var creep: Node = _scene.events.colossus
	_check(creep is CharacterBody3D and creep.collision_layer == Creep.CREEP_LAYER and (_hero.collision_mask & Creep.CREEP_LAYER) != 0,
			"units have physics bodies: heroes bump into creeps and bosses")
	_check(_scene.events.camp_cap == MapEvents.MAP_CAMP_CAP, "map-style pile-ups by default (camps grow to %d)" % MapEvents.MAP_CAMP_CAP)
	_scene.events.timers[30] = 0.01
	_wait = 0.2


func _waves() -> void:
	_scene.events.flush_spawns()
	_check(_scene.events.alive_creeps() == 42, "30 s wave: 42 creeps across 12 camps (%d)" % _scene.events.alive_creeps())
	_scene.events.timers[60] = 0.01
	_wait = 0.2


func _wave_cap() -> void:
	_scene.events.flush_spawns()
	_check(_scene.events.alive_creeps() == 110, "60 s wave adds 68 on top: 110 creeps piling up, as in the map (%d)" % _scene.events.alive_creeps())
	for creep in get_nodes_in_group("creeps"):
		if not creep.is_boss:
			creep._die(null)
	_scene.events.timers[90] = 0.01
	_wait = 0.4


func _wave_90() -> void:
	_scene.events.flush_spawns()
	_check(_scene.events.alive_creeps() == 49, "90 s wave on a clear map: 49 creeps (%d)" % _scene.events.alive_creeps())
	_scene.events.timers[90] = 0.01
	_saved.count = _scene.events.alive_creeps()
	_wait = 0.2


func _bosses() -> void:
	_check(_scene.events.alive_creeps() == _saved.count, "no new 90 s wave while the last one lives")
	var boss: Node = get_nodes_in_group("creeps").filter(func(c): return c.key == "boss:a:0")[0]
	var gold_before := _hero.gold
	_hero.global_position = boss.global_position + Vector3(0, 0, 3)
	_hero.deal_damage(boss, 99999.0)
	_check(not boss.is_alive() and _hero.gold - gold_before >= 499.0, "a boss kill pays its bounty")
	_check(_hero.damage_dealt >= 500.0, "damage dealt is counted (%d)" % _hero.damage_dealt)
	_check(_scene.events.boss_stage("a") == 1, "chain A moves to stage 2")
	_hero.global_position = _scene.fountain_position(0)
	Engine.time_scale = 10.0
	_wait = 11.0


func _boss_respawned() -> void:
	Engine.time_scale = 1.0
	var next := get_nodes_in_group("creeps").filter(func(c): return c.key == "boss:a:1")
	_check(next.size() == 1 and next[0].max_hp == 2000.0, "10 s later the next boss appears with 2,000 HP")


func _duel_start() -> void:
	for creep in get_nodes_in_group("creeps"):
		if not creep.is_boss:
			creep._die(null)
	for h in _scene.heroes:
		h.level = 4
		h.gold = 0.0
	_saved.positions = {}
	for h in _scene.heroes:
		_saved.positions[h] = h.global_position
	_scene.duel.time_to_duel = 0.01
	_wait = 0.3


func _duel_fight() -> void:
	var duel: Node = _scene.duel
	_check(duel.phase == "intro" or duel.phase == "countdown", "the duel timer starts a duel (%s)" % duel.phase)
	_check(_scene.heroes.all(func(h): return h.frozen), "everyone is frozen for the intro")
	_check(duel.duelists.size() == 2 and duel.duelists[0].team != duel.duelists[1].team, "one duelist from each team")
	_check(duel.duelists.all(func(h): return h.global_position.distance_to(duel.center) <= Duel.RADIUS and h.hp == h.max_hp),
			"duelists are in the arena at full health")
	_check(get_nodes_in_group("creeps").all(func(c): return c.frozen), "creeps and bosses freeze too")
	_wait = 7.0


func _duel_kill() -> void:
	var duel: Node = _scene.duel
	_check(duel.phase == "fight", "3, 2, 1 — Fight!! (%s)" % duel.phase)
	_check(duel.duelists.all(func(h): return not h.frozen), "duelists are free to fight")
	_check(_scene.heroes.filter(func(h): return not duel.duelists.has(h)).all(func(h): return h.frozen), "everyone else stays frozen")
	var away: Hero = duel.duelists[0]
	away.global_position = duel.center + Vector3(30, 0, 0)
	_wait = 0.1
	_steps.push_front(_duel_kill_2)


func _duel_kill_2() -> void:
	var duel: Node = _scene.duel
	_check(duel.duelists[0].global_position.distance_to(duel.center) <= Duel.RADIUS, "leaving the arena puts you back on your mark")
	_saved.winner = duel.duelists[0]
	_saved.loser = duel.duelists[1]
	_saved.winner.deal_damage(_saved.loser, 99999.0)
	_wait = 0.2


func _duel_over() -> void:
	var duel: Node = _scene.duel
	_check(duel.phase == "outro" and _saved.winner.gold >= 4 * 200, "the winner earns the loser's level × 200 gold (%d)" % _saved.winner.gold)
	_check(_scene.kills[_saved.winner.team] == 1, "the duel kill counts for the team")
	Engine.time_scale = 4.0
	_wait = 4.0
	_steps.push_front(_duel_after)


func _duel_after() -> void:
	Engine.time_scale = 1.0
	var duel: Node = _scene.duel
	_check(duel.phase == "idle" and _scene.heroes.all(func(h): return not h.frozen), "play resumes after the duel")
	_check(_saved.winner.global_position.distance_to(_saved.positions[_saved.winner]) < 0.5, "the winner returns to where they stood")
	_check(duel.time_to_duel >= Duel.INTERVAL_MIN - 1.0, "the next duel is ~5 minutes away")


func _attack_order() -> void:
	var enemy: Hero = _scene.heroes.filter(func(h): return h.team == 1 and h.is_alive())[0]
	_hero.global_position = Vector3(0, 0, 6)
	enemy.global_position = Vector3(6, 0, 6)
	_hero.order_attack()
	_check(_hero._chase_target == enemy, "ATTACK locks onto the nearest enemy hero")
	_saved.attack_from = _hero.global_position.distance_to(enemy.global_position)
	_wait = 0.6
	_steps.push_front(_attack_check)


func _attack_check() -> void:
	var enemy: Hero = _hero._chase_target
	_check(enemy != null and _hero.global_position.distance_to(enemy.global_position) < _saved.attack_from - 1.0,
			"the hero walks to its target")


func _colossus() -> void:
	var colossus: Node = _scene.events.colossus
	_hero.global_position = colossus.global_position + Vector3(0, 0, 3)
	_hero.deal_damage(colossus, 100000.0)
	_check(_scene.over and _scene.winner == _hero.team, "killing the win boss wins the match")
	paused = false


func _classic() -> void:
	_scene.queue_free()
	root.get_node("/root/Session").classic = true
	_scene = load("res://scenes/arena.tscn").instantiate()
	root.add_child(_scene)
	current_scene = _scene
	_check(_scene.kill_target == 50 and _scene.time_left == INF, "Classic rules: 50 kills, no time limit")
	var picked: Array = _scene.heroes.map(func(h): return h.definition.id)
	var unique := {}
	for id in picked:
		unique[id] = true
	_check(_scene.heroes.size() == 8 and _scene.heroes.filter(func(h): return h.team == 0).size() == 4, "Classic is 4v4, as in the reference map")
	_check(unique.size() == 8, "every hero is picked once (%s)" % ", ".join(picked))
	_check(_scene.hero.xp_rate == 1.0, "Classic levels at the map's own pace (Mobile ×%.0f)" % _scene.MOBILE_XP_RATE)
	root.get_node("/root/Session").classic = false


func _done() -> void:
	for failure in _failures:
		printerr("FAIL: " + failure)
	print("MAP SYSTEMS TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
	quit(1 if _failures.size() else 0)


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
