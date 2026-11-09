extends SceneTree
## Headless check of Vael's kit:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/hero_kit_test.gd
## Bellows Slam hits only enemies in range and respects its cooldown; Ember Dash
## moves Vael; Kindled empowers the slam into Eruption and grows the model.

var _main: Node
var _hero: Hero
var _dummies: Array[Dummy] = []
var _frames := 0
var _mark := Vector3.ZERO
var _failures: Array[String] = []


func _initialize() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	root.add_child(_main)


func _process(_delta: float) -> bool:
	_frames += 1
	match _frames:
		5:
			_hero = _main.hero
			for node in _main.get_children():
				if node is Dummy:
					_dummies.append(node)
			_check(_hero.definition.display_name == "Vael" and _hero.definition.form_name == "Kindled", "hero is Vael with the Kindled form")
			_check(_hero.skills.size() == 4 and _hero.skills[0] is SlamSkill and _hero.skills[1] is DashSkill
					and _hero.skills[2] is SearingBrandSkill and _hero.skills[3] is ForgeGolemSkill, "kit: Bellows Slam, Ember Dash, Searing Brand, Forge Golem")
			_check(not _hero.try_skill(0), "an unlearned skill can't be cast")
			for s in _hero.skills:
				s.rank = 1  # rank 1 everywhere, so the numbers below are the base values
			_check(_hero.model is RiggedModel and _hero.model._player != null, "Vael's rigged model is built with its animations")
			# Slam: dummy 0 sits at (4, 0, -3); stand 2 units from it, far from the others.
			_hero.global_position = Vector3(4, 0, -1)
			var hp_before := _dummies.map(func(d): return d.hp)
			_check(_hero.try_skill(0), "Bellows Slam casts")
			_check(is_equal_approx(_dummies[0].hp, hp_before[0] - SlamSkill.BASE_DAMAGE), "slam hits the dummy in range for %d" % SlamSkill.BASE_DAMAGE)
			_check(_dummies[1].hp == hp_before[1] and _dummies[2].hp == hp_before[2], "slam misses dummies out of range")
			_check(not _hero.try_skill(0), "slam is on cooldown right after casting")
			_check(_hero.meter.charge > 0.0, "slam damage charges the meter")
			# Dash: move clear of the dummies, dash forward (no stick input → facing).
			_hero.global_position = Vector3(10, 0, 10)
			_mark = _hero.global_position
			_check(_hero.try_skill(1), "Ember Dash casts")
		30:
			var moved := _hero.global_position.distance_to(_mark)
			_check(moved >= 4.0 and moved <= 6.0, "dash moved %.2f units (target %d)" % [moved, DashSkill.DISTANCE])
			# Kindled: compare the slam's power before and after transforming.
			var normal: Dictionary = _hero.skills[0].power(_hero)
			_hero.meter._add(_hero.meter.max_charge)
			_check(_hero.try_transform(), "Vael transforms into Kindled")
			var kindled: Dictionary = _hero.skills[0].power(_hero)
			_check(_hero.skills[0].display_name(_hero) == "Eruption", "slam is renamed Eruption while Kindled")
			_check(kindled.radius > normal.radius or kindled.damage > normal.damage,
					"Eruption is stronger than Bellows Slam (radius %.1f→%.1f, damage %d→%d)" % [normal.radius, kindled.radius, normal.damage, kindled.damage])
			# End to end: a dummy 4 units away is out of Bellows Slam's reach but inside Eruption's.
			_hero.global_position = Vector3(4, 0, 1)
			_hero.skills[0].time_left = 0.0
			var before := _dummies[0].hp
			_hero.try_skill(0)
			var expected: float = kindled.damage * _hero.form_damage_mult
			_check(4.0 > normal.radius and is_equal_approx(before - _dummies[0].hp, expected),
					"Eruption hits a dummy 4 units away for %d (Bellows Slam couldn't reach it)" % expected)
		60:
			_check(_hero.model.scale.x > 1.3, "Kindled model grew (scale %.2f)" % _hero.model.scale.x)
			for failure in _failures:
				printerr("FAIL: " + failure)
			print("HERO KIT TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
			quit(1 if _failures.size() else 0)
	return false


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
