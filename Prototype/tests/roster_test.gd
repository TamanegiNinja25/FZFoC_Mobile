extends SceneTree
## Headless check of every hero in the roster:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/roster_test.gd
## For each hero: every skill (at rank 1) has a real effect — damage, movement,
## a buff, a summon, a stun or a root — the transformation grows the model, and
## roles differ in their stats.

var _scene: Node
var _dummy: Dummy
var _steps: Array = []
var _wait := 0.0  # seconds: headless frames are far shorter than 1/60 s
var _hero: Hero
var _before := {}
var _failures: Array[String] = []


func _initialize() -> void:
	_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(_scene)
	current_scene = _scene
	for definition in Roster.all():
		_steps.append(["spawn", definition])
		for i in definition.create_skills().size():
			_steps.append(["skill", i])
		_steps.append(["form", null])


func _process(delta: float) -> bool:
	if _wait > 0.0:
		_wait -= delta
		return false
	if _before.has("pending"):
		_judge()
	if _steps.is_empty():
		_roles()
		for failure in _failures:
			printerr("FAIL: " + failure)
		print("ROSTER TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
		quit(1 if _failures.size() else 0)
		return false
	var step: Array = _steps.pop_front()
	match step[0]:
		"spawn":
			if _hero:
				_hero.queue_free()
			if _dummy == null:
				for node in _scene.get_children():
					if node is Dummy:
						_dummy = node
						break
			_hero = Hero.new()
			_hero.definition = step[1]
			_hero.is_player = false
			_hero.position = _dummy.position + Vector3(0, 0, 4.0)
			_scene.add_child(_hero)
			_wait = 0.1
		"skill":
			var i: int = step[1]
			if not _dummy.is_alive():  # a strong skill (Thousand Cuts) can kill it outright
				_dummy._dead_time = 0.0
				_dummy._respawn()
			_dummy.hp = _dummy.max_hp
			_hero.global_position = _dummy.global_position + Vector3(0, 0, 2.5 if i == 0 else 5.0)
			_hero.ai_move = (_dummy.global_position - _hero.global_position).normalized()
			_hero.skills[i].time_left = 0.0
			_hero.skills[i].rank = 1
			_before = {"pending": "skill", "index": i, "hp": _dummy.hp, "pos": _hero.global_position,
					"summons": get_nodes_in_group("summons").size(),
					"cast": _hero.try_skill(i), "name": _hero.skills[i].skill_name}
			_hero.ai_move = Vector3.ZERO
			_wait = 2.0  # long enough for a boulder to fly or a channel to land
		"form":
			_hero.meter._add(_hero.meter.max_charge)
			_before = {"pending": "form", "cast": _hero.try_transform()}
			_wait = 0.6
	return false


func _judge() -> void:
	var who := _hero.definition.display_name
	match _before.pending:
		"skill":
			var damaged: bool = _dummy.hp < _before.hp or not _dummy.is_alive()
			var moved: bool = _hero.global_position.distance_to(_before.pos) > 2.0
			var summoned: bool = get_nodes_in_group("summons").size() > _before.summons
			var effect := "damage" if damaged else ("movement" if moved else ("haste" if _hero.is_hasted() else ("summon" if summoned else "none")))
			_check(_before.cast and effect != "none", "%s — %s casts with a real effect (%s)" % [who, _before.name, effect])
		"form":
			_check(_before.cast and _hero.in_form, "%s transforms into %s" % [who, _hero.definition.form_name])
			_check(_hero.model.scale.x > 1.1, "%s's model grows in form (×%.2f)" % [who, _hero.model.scale.x])
			_check(_hero.skills.all(func(s): return s.description != ""), "%s's skills all have descriptions" % who)
	_before = {}


func _roles() -> void:
	var by_role := {}
	for definition in Roster.all():
		by_role[definition.role] = definition
	_check(by_role.keys().size() == 3, "three roles in the roster: %s" % ", ".join(by_role.keys()))
	_check(by_role.Speed.move_speed > by_role.Bruiser.move_speed and by_role.Speed.max_hp < by_role.Bruiser.max_hp,
			"Speed is faster and frailer than Bruiser")
	_check(by_role.Giant.max_hp > by_role.Bruiser.max_hp and by_role.Giant.move_speed < by_role.Bruiser.move_speed,
			"Giant is tougher and slower than Bruiser")


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
