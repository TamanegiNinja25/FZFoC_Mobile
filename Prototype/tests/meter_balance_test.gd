extends SceneTree
## Headless balance check for the charge rule:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/meter_balance_test.gd
## 1. Fill time: hero parked next to one dummy; target ≈ 90 s of fighting.
## 2. Idle drain: meter falls once out of combat.
## 3. Spree: two quick kills build a spree and raise kill gold and income.

const TARGET_FILL := 90.0
const TOLERANCE := 15.0

var _main: Node
var _hero: Hero
var _phase := "boot"
var _t0 := 0.0
var _mark := 0.0
var _kills := 0
var _deaths := 0
var _failures: Array[String] = []


func _initialize() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	root.add_child(_main)
	Engine.max_physics_steps_per_frame = 64
	Engine.time_scale = 10.0


## Game-time seconds: physics ticks run at a fixed real rate, and each tick
## advances game time by time_scale / ticks_per_second.
func _sim_time() -> float:
	return float(Engine.get_physics_frames()) / Engine.physics_ticks_per_second * Engine.time_scale


func _process(_delta: float) -> bool:
	match _phase:
		"boot":
			_hero = _main.hero
			if _hero == null:
				return false
			_hero.died.connect(func(): _deaths += 1)
			for node in _main.get_children():
				if node is Dummy:
					node.died.connect(func(): _kills += 1)
			# Park beside the dummy at (4, 0, -3); the others are out of range.
			_hero.global_position = Vector3(2.5, 0, -3)
			_t0 = _sim_time()
			_phase = "fill"
		"fill":
			var t := _sim_time() - _t0
			if _hero.meter.is_full():
				print("fill time: %.1f s   kills: %d   deaths: %d   gold: %d   hp left: %d" % [t, _kills, _deaths, _hero.gold, _hero.hp])
				_check(absf(t - TARGET_FILL) <= TOLERANCE, "fill time %.1f s within %d±%d s" % [t, TARGET_FILL, TOLERANCE])
				_check(_deaths == 0, "hero survives the fill (regen keeps up)")
				_start_drain()
			elif t > 300.0:
				_check(false, "meter fills within 300 s (stuck at %.1f)" % _hero.meter.charge)
				_phase = "done"
		"drain":
			if _sim_time() - _mark >= 15.0:
				var after := _hero.meter.charge
				print("idle drain: 60.0 -> %.1f over 15 s" % after)
				_check(after < 60.0 and after > 40.0, "meter drains gently out of combat")
				_start_spree()
		"spree":
			if _hero.spree >= 2:
				print("spree x%d   gold %d   income %.0f/s" % [_hero.spree, _hero.gold, _hero.income_per_second()])
				_check(_hero.gold >= 250.0, "two-kill spree pays 100 + 150 gold")
				_check(_hero.income_per_second() > _hero.base_income, "spree raises income")
				_phase = "done"
			elif _sim_time() - _mark > 60.0:
				_check(false, "spree reached x2 within 60 s")
				_phase = "done"
		"done":
			for failure in _failures:
				printerr("FAIL: " + failure)
			print("BALANCE TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
			Engine.time_scale = 1.0
			quit(1 if _failures.size() else 0)
	return false


func _start_drain() -> void:
	_hero.global_position = Vector3(12, 0, 10)  # far from every dummy
	_hero.meter.charge = 60.0
	_hero.meter._since_combat = _hero.meter.out_of_combat_after  # already out of combat
	_mark = _sim_time()
	_phase = "drain"


func _start_spree() -> void:
	_hero.gold = 0.0
	_hero.spree = 0
	_hero.spree_time_left = 0.0
	# Two weakened dummies side by side: kills land seconds apart.
	var dummies: Array[Dummy] = []
	for node in _main.get_children():
		if node is Dummy:
			dummies.append(node)
	dummies[0].global_position = Vector3(10, 0, 0)
	dummies[1].global_position = Vector3(10, 0, 1.5)
	for d in [dummies[0], dummies[1]]:
		d.hp = 80.0
	_hero.global_position = Vector3(8.5, 0, 0.75)
	_mark = _sim_time()
	_phase = "spree"


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
