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
## Creeps pile up if nobody farms them, as in the map. Caps keep a phone at 60 FPS.
const CAMP_CAP := 10
const TOTAL_CAP := 80

## The ArenaMatch (typed loosely: naming it here would create a dependency cycle).
var arena: Node
## Camp positions, in the same order as the waves.
var camps: Array = []
var boss_spots := {}
var colossus_spot := Vector3.ZERO

var timers := {30: 30.0, 60: 60.0, 90: 90.0}
var _camp_units: Array = []
var _wave_90_units: Array[Creep] = []
var _boss_stage := {"a": 0, "b": 0}
var colossus: Creep


func _ready() -> void:
	for i in camps.size():
		_camp_units.append([])
	for chain in boss_spots:
		_spawn_boss(chain)
	colossus = _spawn("colossus", colossus_spot)
	colossus.died.connect(func(killer): colossus_slain.emit(killer))


func _physics_process(delta: float) -> void:
	for period in timers:
		timers[period] -= delta
		if timers[period] <= 0.0:
			timers[period] += period
			_wave(period)


func _wave(period: int) -> void:
	if period == 90:
		_wave_90_units = _wave_90_units.filter(func(u): return is_instance_valid(u) and u.is_alive())
		if not _wave_90_units.is_empty():
			return  # the map spawns the 90 s wave only when the last one is dead
	var table: Array = {30: WAVE_30, 60: WAVE_60, 90: WAVE_90}[period]
	for camp in camps.size():
		_camp_units[camp] = _camp_units[camp].filter(func(u): return is_instance_valid(u) and u.is_alive())
		for group in table[camp]:
			for n in group[1]:
				if _camp_units[camp].size() >= CAMP_CAP or alive_creeps() >= TOTAL_CAP:
					break
				var spot: Vector3 = camps[camp] + Vector3(randf_range(-2.2, 2.2), 0, randf_range(-2.2, 2.2))
				var unit := _spawn(group[0], spot)
				_camp_units[camp].append(unit)
				if period == 90:
					_wave_90_units.append(unit)


func alive_creeps() -> int:
	var count := 0
	for list in _camp_units:
		for unit in list:
			if is_instance_valid(unit) and unit.is_alive():
				count += 1
	return count


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
