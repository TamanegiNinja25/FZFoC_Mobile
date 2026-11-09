class_name Barrow
extends HeroDef
## Barrow, the Living Cairn — giant hero. Slow, huge, and very hard to bring down.
## Transformation: Avalanche — grows enormous, and Quake Stomp widens.


func _init() -> void:
	id = "barrow"
	realm = "Stone Barrows"
	display_name = "Barrow"
	title = "the Living Cairn"
	form_name = "Avalanche"
	form_stages = ["Mountain's Wrath"]
	role = "Giant"
	description = "A giant of stacked boulders woken by old runes. Slow, heavy-handed and nearly impossible to bring down."
	max_hp = 1320.0
	hp_regen = 6.0
	move_speed = 5.0
	attack_damage = 58.0
	attack_interval = 1.3
	attack_range = 2.8
	primary = "str"
	strength = 34.0
	agility = 15.0
	intelligence = 18.0
	strength_gain = 3.4
	agility_gain = 1.5
	intelligence_gain = 1.8
	exclusive_item = "cairnstone_heart"
	form_duration = 14.0
	form_shield_ratio = 0.35
	form_damage_mult = 1.3
	form_speed_mult = 1.0
	form_scale = 1.7


func create_model() -> Node3D:
	return BarrowModel.new()


func create_skills() -> Array[Skill]:
	return arrange([QuakeStompSkill.new(), BoulderHurlSkill.new(), StoneGripSkill.new(), RockfallSkill.new()])
