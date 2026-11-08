class_name Duel
extends Node
## The reference map's duel, kept the same: every 290–310 s the whole world
## freezes (everyone invulnerable, dead heroes revived), the camera shakes and
## pans to the duel arena, and one random hero from each team is brought in at
## full health. "3, 2, 1, Fight!!" — leaving the arena puts you back at your
## mark. The winner earns the loser's level × 200 gold and gets their health
## back; then everyone returns to where they stood and play resumes.

signal state_changed(phase: String, text: String)

const INTERVAL_MIN := 290.0
const INTERVAL_MAX := 310.0
const RADIUS := 10.0
## Safety net so a duel can't stall a match forever (the map has none).
const MAX_FIGHT := 120.0

## The ArenaMatch (typed loosely: naming it here would create a dependency cycle).
var arena: Node
var center := Vector3(0, 0, -46)
var time_to_duel := 0.0
## "idle", "intro", "countdown", "fight", "outro".
var phase := "idle"
var text := ""
var duelists: Array[Hero] = []
var winner: Hero

var _saved := {}  # hero → [hp, shield, position, facing]
var _hooks := {}  # hero → its died-signal callable
var _fight_time := 0.0


func _ready() -> void:
	time_to_duel = randf_range(INTERVAL_MIN, INTERVAL_MAX)


func active() -> bool:
	return phase != "idle"


func _physics_process(delta: float) -> void:
	if arena.over:
		return
	if phase == "idle":
		time_to_duel -= delta
		if time_to_duel <= 0.0:
			start()
	elif phase == "fight":
		_fight_time += delta
		for i in duelists.size():
			var h := duelists[i]
			if h.is_alive() and h.global_position.distance_to(center) > RADIUS:
				h.global_position = _mark(i)  # leaving the arena puts you back
		if _fight_time >= MAX_FIGHT:
			_finish(null)


func start() -> void:
	if phase != "idle":
		return
	var teams := [[], []]
	for h in arena.heroes:
		teams[h.team].append(h)
	if teams[0].is_empty() or teams[1].is_empty():
		time_to_duel = randf_range(INTERVAL_MIN, INTERVAL_MAX)
		return
	_set_phase("intro", "Duel!")
	_freeze_world(true)
	for h in arena.heroes:
		h.revive_now()
	duelists = [teams[0][randi() % teams[0].size()], teams[1][randi() % teams[1].size()]]
	_saved.clear()
	for i in 2:
		var h := duelists[i]
		_saved[h] = [h.hp, h.shield, h.global_position, h._facing]
		h.global_position = _mark(i)
		h._face(center - h.global_position)
		h.hp = h.max_hp
		h.shield = 0.0
		h.health_changed.emit(h.hp, h.max_hp, h.shield)
	arena.announce("Duel: %s vs %s — winner earns level × 200 gold" % [arena.hero_label(duelists[0]), arena.hero_label(duelists[1])], Color(1.0, 0.75, 0.35))
	for h in duelists:
		_hooks[h] = _on_duelist_died.bind(h)
		h.died.connect(_hooks[h])
	_countdown()


func _countdown() -> void:
	await _wait(3.0)  # the map: camera shake, pan, then the countdown
	for n in ["3", "2", "1"]:
		_set_phase("countdown", n)
		await _wait(1.0)
	if phase != "countdown":
		return
	_set_phase("fight", "Fight!!")
	_fight_time = 0.0
	for h in duelists:
		h.frozen = false
	await _wait(1.0)
	if phase == "fight":
		text = ""
		state_changed.emit(phase, text)


func _on_duelist_died(_killer: Hero, loser: Hero) -> void:
	if phase != "fight" and phase != "countdown":
		return
	_finish(duelists[1] if loser == duelists[0] else duelists[0])


func _finish(won: Hero) -> void:
	winner = won
	for h in _hooks:
		if h.died.is_connected(_hooks[h]):
			h.died.disconnect(_hooks[h])
	_hooks.clear()
	for h in duelists:
		h.frozen = true
	if won:
		var loser := duelists[1] if won == duelists[0] else duelists[0]
		var reward := loser.level * 200
		won.gold += reward
		_set_phase("outro", "Winner is %s" % arena.hero_label(won))
		arena.announce("%s wins the duel: +%d gold" % [arena.hero_label(won), reward], Color(1.0, 0.85, 0.4))
	else:
		_set_phase("outro", "Duel drawn")
	await _wait(3.0)
	for h in duelists:
		var saved: Array = _saved.get(h, [])
		if saved.is_empty() or not h.is_alive():
			continue
		h.global_position = saved[2]
		h._face(saved[3])
		if h == winner:
			h.hp = minf(saved[0], h.max_hp)
			h.shield = saved[1]
			h.health_changed.emit(h.hp, h.max_hp, h.shield)
	duelists.clear()
	_freeze_world(false)
	_set_phase("idle", "")
	time_to_duel = randf_range(INTERVAL_MIN, INTERVAL_MAX)


## Freezes (or thaws) every unit: heroes, creeps, bosses and summons.
func _freeze_world(on: bool) -> void:
	for node in get_tree().get_nodes_in_group("units"):
		if "frozen" in node:
			node.frozen = on
	for node in get_tree().get_nodes_in_group("heroes"):
		node.frozen = on
		if on:
			node.velocity = Vector3.ZERO


func _mark(index: int) -> Vector3:
	return center + Vector3(-5.0 if index == 0 else 5.0, 0, 0)


func _set_phase(new_phase: String, new_text: String) -> void:
	phase = new_phase
	text = new_text
	state_changed.emit(phase, text)


func _wait(seconds: float) -> Signal:
	return get_tree().create_timer(seconds, false, true).timeout
