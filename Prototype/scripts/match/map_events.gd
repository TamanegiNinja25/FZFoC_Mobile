class_name MapEvents
extends Node
## The reference map's world events, run by the host:
##  • creep waves at 12 camps every 30 s and 60 s, plus a 90 s wave that only
##    comes once the previous 90 s wave is dead — the map's exact compositions;
##  • two boss chains: the next, stronger boss appears 10 s after one falls;
##  • the win boss, whose death ends the match for the killer's team.

signal colossus_slain(killer: Hero)
signal boss_slain(name: String, killer: Hero)

## Per camp (the map's rect18…rect29, in that order): [creep id, count].
const WAVE_30 := [[["ngno", 4]], [["ngna", 4]], [["nspr", 4]], [["nssp", 2]], [["ngno", 4]], [["ngna", 4]],
	[["nspr", 4]], [["nssp", 2]], [["ngno", 4]], [["ngna", 4]], [["nspr", 4]], [["nssp", 2]]]
const WAVE_60 := [[["nban", 5], ["nbld", 1]], [["hmpr", 5], ["nwzr", 1]], [["ngrk", 6]], [["hfoo", 5], ["hkni", 1]],
	[["hmpr", 5]], [["hfoo", 5]], [["ngrk", 5]], [["nban", 5]], [["ngrk", 6]], [["nban", 5], ["nbld", 1]],
	[["hfoo", 5], ["hkni", 1]], [["hmpr", 5], ["nwzr", 1]]]
const WAVE_90 := [[["nbld", 3], ["otau", 2]], [["nwzr", 3], ["unec", 2]], [["ngst", 4]], [["hkni", 3], ["edoc", 2]],
	[["nwzr", 3]], [["hkni", 3]], [["ngst", 2]], [["nbld", 3]], [["ngst", 4]], [["nbld", 3], ["otau", 2]],
	[["hkni", 3], ["edoc", 2]], [["nwzr", 3], ["unec", 2]]]
const BOSS_RESPAWN := 10.0
## Creeps pile up if nobody farms them, as in the map. "Map" pile-ups (the
## default) only stop a camp at 60; the "Phone-safe" setting keeps the old caps.
const MAP_CAMP_CAP := 60
const MAP_TOTAL_CAP := 720
const SAFE_CAMP_CAP := 10
const SAFE_TOTAL_CAP := 80
const BALANCED_CAMP_CAP := 25
## A wave's creeps appear over several frames, not all at once (no hitch).
const SPAWNS_PER_TICK := 12

var camp_cap := MAP_CAMP_CAP
var total_cap := MAP_TOTAL_CAP

## The ArenaMatch (typed loosely: naming it here would create a dependency cycle).
var arena: Node
## Camp positions, in the same order as the waves.
var camps: Array = []
var boss_spots := {}
var colossus_spot := Vector3.ZERO

var timers := {30: 30.0, 60: 60.0, 90: 90.0}
var _wake_clock := 0.0
## Creeps waiting to appear: [creep id, position, camp, part of a 90 s wave].
var _queue: Array = []
## Heroes or summons this close to a camp's centre wake its sleeping creeps.
const WAKE_RADIUS := 13.0
var _camp_units: Array = []
var _camp_counts: Array[int] = []
var _alive := 0
var _wave_90_units: Array[Creep] = []
var _boss_stage := {"a": 0, "b": 0}
var colossus: Creep


func _ready() -> void:
	var settings := get_node_or_null("/root/GameSettings")
	if settings and settings.creep_limit == "safe":
		camp_cap = SAFE_CAMP_CAP
		total_cap = SAFE_TOTAL_CAP
	elif settings and settings.creep_limit == "balanced":
		camp_cap = BALANCED_CAMP_CAP
	for i in camps.size():
		_camp_units.append([])
		_camp_counts.append(0)
	for chain in boss_spots:
		_spawn_boss(chain)
	colossus = _spawn("colossus", colossus_spot)
	colossus.died.connect(func(killer): colossus_slain.emit(killer))


func _physics_process(delta: float) -> void:
	_wake_clock += delta
	if _wake_clock >= 0.25:
		_wake_clock = 0.0
		_wake_camps()
	for period in timers:
		timers[period] -= delta
		if timers[period] <= 0.0:
			timers[period] += period
			_wave(period)
	for i in mini(SPAWNS_PER_TICK, _queue.size()):
		var entry: Array = _queue.pop_front()
		_spawn_queued(entry[0], entry[1], entry[2], entry[3])


func _wave(period: int) -> void:
	if period == 90:
		_wave_90_units = _wave_90_units.filter(func(u): return is_instance_valid(u) and u.is_alive())
		if not _wave_90_units.is_empty() or _queue.any(func(e): return e[3]):
			return  # the map spawns the 90 s wave only when the last one is dead
	var table: Array = {30: WAVE_30, 60: WAVE_60, 90: WAVE_90}[period]
	for camp in camps.size():
		_camp_units[camp] = _camp_units[camp].filter(func(u): return is_instance_valid(u) and u.is_alive())
		for group in table[camp]:
			for n in group[1]:
				if _camp_counts[camp] >= camp_cap or _alive >= total_cap:
					break
				# Spread new creeps on a widening spiral so a pile grows outward.
				var k: int = _camp_counts[camp]
				var spot: Vector3 = camps[camp] + Vector3(cos(k * 2.4), 0, sin(k * 2.4)) * minf((0.8 + 0.42 * sqrt(k)) * 1.6, 5.5)
				spot.x = clampf(spot.x, -42.5, 42.5)
				spot.z = clampf(spot.z, -26.5, 26.5)
				# Counted now (so caps hold), placed over the next frames.
				_camp_counts[camp] += 1
				_alive += 1
				_queue.append([group[0], spot, camp, period == 90])


## Sleeping camps cost nothing; 4×/s, wake the camps a hero or summon is near.
func _wake_camps() -> void:
	var visitors: Array[Node] = get_tree().get_nodes_in_group("heroes") + get_tree().get_nodes_in_group("summons")
	for i in camps.size():
		var near := false
		for unit in visitors:
			if unit.is_alive() and unit.global_position.distance_to(camps[i]) <= WAKE_RADIUS:
				near = true
				break
		if near:
			for creep in _camp_units[i]:
				if is_instance_valid(creep):
					creep.wake()


func _spawn_queued(creep_id: String, spot: Vector3, camp: int, wave_90: bool) -> void:
	var unit := _spawn(creep_id, spot)
	unit.camp = camp
	_camp_units[camp].append(unit)
	unit.died.connect(_on_creep_died.bind(camp))
	if wave_90:
		_wave_90_units.append(unit)


## Places every queued creep at once (tests use this to check a wave).
func flush_spawns() -> void:
	while not _queue.is_empty():
		var entry: Array = _queue.pop_front()
		_spawn_queued(entry[0], entry[1], entry[2], entry[3])


func _on_creep_died(_killer: Hero, camp: int) -> void:
	_camp_counts[camp] -= 1
	_alive -= 1


func camp_size(index: int) -> int:
	return _camp_counts[index] if index >= 0 and index < _camp_counts.size() else 0


func alive_creeps() -> int:
	return _alive


func _spawn_boss(chain: String) -> void:
	var stage: int = _boss_stage[chain]
	var unit := _spawn("boss:%s:%d" % [chain, stage], boss_spots[chain])
	unit.died.connect(_on_boss_died.bind(chain, unit.display_name))


func _on_boss_died(killer: Hero, chain: String, boss_name: String) -> void:
	boss_slain.emit(boss_name, killer)
	_boss_stage[chain] += 1
	if _boss_stage[chain] >= CreepTypes.CHAINS[chain].hp.size():
		return  # the chain's final boss is down
	get_tree().create_timer(BOSS_RESPAWN, false, true).timeout.connect(_spawn_boss.bind(chain))


func boss_stage(chain: String) -> int:
	return _boss_stage[chain]


func _spawn(unit_key: String, at: Vector3) -> Creep:
	var unit := Creep.create(unit_key)
	unit.position = at
	unit.home = at
	arena.add_child(unit)
	if unit.is_colossus:
		unit.move_speed = 2.6
	return unit
