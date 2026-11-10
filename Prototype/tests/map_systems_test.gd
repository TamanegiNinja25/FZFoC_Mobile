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
	_steps = [_progression, _form_stages, _shop_rules, _status_effects, _inventory_systems, _evolution, _innate_and_voices, _start_arena, _creep_rooms, _waves, _wave_cap, _wave_90, _bosses,
		_boss_respawned, _duel_start, _duel_fight, _duel_kill, _duel_over, _attack_order, _colossus, _classic, _no_duels, _done]


func _process(delta: float) -> bool:
	_wait -= delta
	if _wait > 0.0 or _steps.is_empty():
		return false
	var step: Callable = _steps.pop_front()
	step.call()
	return false


# ------------------------------------------------------- hero systems (training)
## The map's chained forms: while transformed, a full meter climbs a stage.
func _form_stages() -> void:
	var h: Hero = _scene.hero
	_check(h.max_form_stage() == 2, "Vael's form has two stages (Kindled, %s)" % h.definition.form_stages[0])
	h.meter.charge = h.meter.max_charge
	h.try_transform()
	_check(h.in_form and h.form_stage == 1 and h.can_ascend() and not h.meter.locked and h.meter.boost == Hero.STAGE_CHARGE_RATE,
			"in the first form the meter charges fast toward the next stage")
	var bounty1 := h.bounty_value()
	h.meter.charge = h.meter.max_charge
	_check(h.try_transform() and h.form_stage == 2 and h.stage_name() == h.definition.form_stages[0], "a full meter ascends to stage 2")
	_check(h.bounty_value() > bounty1 and h._stage_mult() > 1.0 and not h.can_ascend() and h.meter.locked,
			"stage 2 hits harder, is worth more, and is the last stage")
	_check(not h.try_transform(), "no stage past the last")
	h._end_form()
	h._invulnerable_time = 0.0
	_check(h.form_stage == 0 and not h.meter.locked and h.meter.boost == 1.0, "the form ends back at stage 0")
	h.meter.charge = 0.0
	var tamsin := Roster.create("tamsin")
	_check(tamsin.form_stages.size() == 2, "Tamsin's form chains through three stages")


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


## Potion stacking, the storage satchel, the recall point and the capture orb
## that keeps its creature — all from the reference map.
func _inventory_systems() -> void:
	var h: Hero = _scene.hero
	h.items.clear()
	h.charges.clear()
	h.in_shop_range = true
	h.gold = 100000.0
	h.buy("ember_draught")
	h.buy("ember_draught")
	_check(h.items.size() == 1 and h.charges[0] == 2, "a second potion stacks into the same slot (2 charges)")
	h.buy("ember_draught")
	_check(h.items.size() == 2, "a third potion takes a new slot (stacks hold 2)")
	h.use_item(0)
	_check(h.charges[0] == 1 and h.items.size() == 2, "using a stacked potion spends one charge")
	h.items.clear()
	h.charges.clear()
	h.buy("satchel_of_holding")
	_check(h.bag_unlocked and h.items.is_empty(), "the satchel opens the bag without taking a slot")
	for i in 6:
		h.buy("riveted_mail")
	var hp_full := h.max_hp
	_check(h.buy("riveted_mail") == "" and h.bag.size() == 1 and h.max_hp == hp_full, "with the inventory full, a purchase goes to the bag and gives no stats")
	h.stash(0)
	_check(h.items.size() == 5 and h.bag.size() == 2 and h.max_hp < hp_full, "stashing an item moves it to the bag (its stats rest)")
	h.unstash(0)
	_check(h.items.size() == 6 and h.max_hp == hp_full, "taking it out of the bag restores its stats")
	h.items.clear()
	h.charges.clear()
	h.bag.clear()
	h.bag_charges.clear()
	h.recompute_stats()
	var mark := h.global_position + Vector3(5, 0, 3)
	h.global_position = mark
	h.mark_recall_point()
	h.global_position = Vector3.ZERO
	h._recall()
	_check(h.global_position.distance_to(mark) < 0.01, "the recall scroll returns to the marked point")
	h.recall_point = Vector3.INF
	h.captured_key = "ngno"
	h.items.append(ItemCatalog.find("capture_orb_full"))
	h.use_item(0)
	_check(h.pet != null and h.pet.is_alive() and h.items.size() == 1, "the full orb calls the captured creep out and stays")
	_check(h.pet.lifetime == 0.0, "the captured creep stays until it dies (no timer)")
	h.use_item(0)
	_check(h.pet == null and h.captured_key == "ngno", "tapping again calls it back into the orb")
	h.use_item(0)
	h.pet._die(null)
	_check(h.captured_key == "" and h.items[0].id == "capture_orb", "when it dies the orb is empty again")
	h.items.clear()
	h.charges.clear()
	h.recompute_stats()


## The map's stat-threshold evolution: reaching the attributes swaps the hero
## for good, keeping level and items.
func _evolution() -> void:
	var h: Hero = _scene.hero
	var level := h.level
	h.items.append(ItemCatalog.find("riveted_mail"))
	h.definition.evolve_at = {"str": 1.0}
	h.definition.evolve_into = func(): return Roster.create("hask")
	h.recompute_stats()
	_check(h.evolved and h.definition.display_name == "Hask" and h.level == level and h.items.size() == 1,
			"reaching the stat threshold evolves the hero, keeping level and items")
	_check(h.skills.size() == 4 and h.model != null and h.model.is_inside_tree(), "the evolved hero has the new kit and look")
	h.items.clear()
	h.charges.clear()


## The map's innate blink (always learned, ~2 s), hero voices and the announcer.
func _innate_and_voices() -> void:
	var h := Hero.new()
	h.definition = MoreHeroes.oren()
	h.is_player = false
	h.position = Vector3(0, 0, 6)
	_scene.add_child(h)
	_check(h.innate != null and h.innate.is_ready() and h.innate.cooldown <= 2.0, "new heroes have an innate blink, ready from level 1 (%s)" % (h.innate.skill_name if h.innate else "none"))
	var start := h.global_position
	h._face(Vector3(1, 0, 0))
	_check(h.try_innate() and h.global_position.distance_to(start) > 3.0, "the innate blink moves the hero")
	_check(not h.try_innate(), "the blink has a short cooldown")
	var sfx: Node = root.get_node("/root/Sfx")
	_check(sfx.has_sound("voice:male2:cry") and sfx.has_sound("voice:female:cry") and sfx.has_sound("voice:male1:death"), "hero voice sets load (battle cries, death cries)")
	_check(sfx.has_sound("announce:fight") and sfx.has_sound("announce:you_win") and sfx.has_sound("announce:3"), "announcer lines load")
	_check(sfx.has_sound(h.skills[0].sound_id()) and sfx.has_sound(h.innate.sound_id()), "skills have their own sounds")
	h.queue_free()


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
	_check(_hero.respawn_time == 4.0, "heroes revive after 4 s, as in the map")
	_scene._update_score()
	_check(_scene._board_blue.text.split("\n").size() == 3 and _scene._board_red.text.split("\n").size() == 3 and "0 / 0" in _scene._board_blue.text,
			"the scoreboard lists every hero's kills / deaths")
	_hero.left_game = true
	_scene._update_score()
	_check("(left)" in _scene._board_blue.text, "a leaver is marked on the scoreboard")
	_hero.left_game = false
	_hero.level = 1
	_hero.skill_points = 1
	_hero.learn_skill(0)
	_scene.camera.make_current()  # the training scene's camera is still current this frame
	_hero.try_skill(0)
	var callouts := _scene.find_children("*", "Label3D", true, false).filter(func(l): return l.visible and l.text.ends_with(" !!"))
	_check(callouts.any(func(l): return l.text.begins_with(_hero.skills[0].display_name(_hero))), "casting floats \"Skill name !!\" over the hero")
	_scene.events.timers[30] = 0.01
	_wait = 0.2


## The map's private creep rooms: a pad by the south wall, creeps on entry up
## to 20 of a type, and a pad back.
func _creep_rooms() -> void:
	var rooms: CreepRooms = _scene.rooms
	var before := get_nodes_in_group("creeps").size()
	_hero.global_position = CreepRooms.ROOMS[0][0]
	rooms._physics_process(0.016)
	_check(CreepRooms.room_at(_hero.global_position) == 0, "stepping on a pad takes the player into a creep room")
	_check(get_nodes_in_group("creeps").size() - before == 4, "entering the room spawns its 4 creeps")
	for i in 30:
		rooms.spawn(0)
	_check(rooms.spawn(0) == 0, "a room stops at 20 of each creep type (Can't spawn any more creeps)")
	var bot: Hero = _scene.heroes[1]
	bot.global_position = CreepRooms.ROOMS[1][0]
	rooms._physics_process(0.016)
	_check(CreepRooms.room_at(bot.global_position) == 1, "bots use the pads too")
	var brain := BotBrain.new()
	brain.hero = bot
	brain.arena = _scene
	bot.add_child(brain)
	for unit in rooms._units[1]:
		unit._die(null)
	rooms._units[1].clear()
	brain._creep_rooms(1.0)
	_check(bot.ai_move.length() > 0.5 and bot.ai_move.dot((CreepRooms.exit_pad(1) - bot.global_position).normalized()) > 0.9,
			"a bot heads for the exit pad once its room is empty")
	brain.queue_free()
	rooms._cooldown.clear()
	_hero.global_position = CreepRooms.exit_pad(0)
	rooms._physics_process(0.016)
	_check(CreepRooms.room_at(_hero.global_position) == -1 and _hero.global_position.z < _scene.HALF_FIELD.y,
			"the room's pad leads back to the field")
	for unit in rooms._units[0]:
		unit.queue_free()  # keep the wave checks that follow exact
	rooms._units[0].clear()
	rooms._cooldown.clear()
	_hero.global_position = _scene.BASES[0]
	bot.global_position = _scene.BASES[0] + Vector3(0, 0, 3)
	_wait = 0.1


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
	_check(duel.time_to_duel >= Duel.INTERVAL_MIN - 30.0, "the next duel is ~5 minutes away (%.0f s)" % duel.time_to_duel)


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
	_check(_scene.kill_target == 100 and _scene.time_left == INF, "Classic rules: the map's 100 kills, no time limit")
	_check(_scene.heroes.all(func(h): return h.income_per_second() == 0.0), "Classic has no passive gold, as in the map")
	_check(_scene.duel != null, "duels run when switched on")
	var picked: Array = _scene.heroes.map(func(h): return h.definition.id)
	var unique := {}
	for id in picked:
		unique[id] = true
	_check(_scene.heroes.size() == 8 and _scene.heroes.filter(func(h): return h.team == 0).size() == 4, "Classic is 4v4, as in the reference map")
	_check(unique.size() == 8, "every hero is picked once (%s)" % ", ".join(picked))
	_check(_scene.hero.xp_rate == 1.0, "Classic levels at the map's own pace (Mobile ×%.0f)" % _scene.MOBILE_XP_RATE)
	root.get_node("/root/Session").classic = false


func _no_duels() -> void:
	_scene.queue_free()
	root.get_node("/root/Session").duels = false
	_scene = load("res://scenes/arena.tscn").instantiate()
	root.add_child(_scene)
	current_scene = _scene
	_scene._update_score()
	_check(_scene.duel == null and "Duels off" in _scene._score.text, "the host can switch duels off for the match")
	_check(_scene.heroes.any(func(h): return h.income_per_second() > 0.0), "Mobile keeps its passive gold")
	root.get_node("/root/Session").duels = true


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
