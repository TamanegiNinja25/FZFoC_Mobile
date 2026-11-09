extends SceneTree
## Headless smoke test:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/smoke_test.gd
## Loads the arena, forces the meter full, transforms, and checks the form ends on time.

var _main: Node
var _frames := 0
var _phase := "boot"
var _failures: Array[String] = []


func _initialize() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	root.add_child(_main)
	Engine.time_scale = 20.0


func _process(_delta: float) -> bool:
	_frames += 1
	var hero: Hero = _main.hero
	match _phase:
		"boot":
			if _frames > 5:
				_check(hero != null and hero.meter != null, "hero and meter exist")
				var base_bounty := hero.bounty_value()
				_check(not hero.try_transform(), "cannot transform with an empty meter")
				hero.meter._add(hero.meter.max_charge)
				_check(hero.meter.is_full(), "meter reports full")
				_check(hero.try_transform(), "transform succeeds when full")
				_check(hero.in_form and hero.shield > 0.0, "form active with shield")
				_check(hero.meter.charge == 0.0 and (hero.meter.locked or hero.can_ascend()), "meter consumed (locked, or charging toward the next stage)")
				_check(hero.bounty_value() > base_bounty, "transformed hero is worth more bounty")
				_phase = "in_form"
		"in_form":
			if not hero.in_form:
				_check(not hero.meter.locked, "meter unlocked after form")
				_check(hero.shield == 0.0, "shield removed after form")
				_check(hero.bounty_value() == hero.bounty, "bounty back to base after form")
				_phase = "done"
			elif _frames > 5000:
				_check(false, "form ended within its duration")
				_phase = "done"
		"done":
			for failure in _failures:
				printerr("FAIL: " + failure)
			print("SMOKE TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
			Engine.time_scale = 1.0
			quit(1 if _failures.size() else 0)
	return false


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
