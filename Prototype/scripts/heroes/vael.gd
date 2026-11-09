class_name Vael
extends HeroDef
## Vael, the Kiln Knight — an iron knight whose armour is a living kiln.
## Bruiser: sword and shield. Transformation: Kindled — the kiln doors burst
## open, he grows and glows, and Bellows Slam becomes Eruption.
## Base stats match the tuned prototype hero, so the meter balance (≈90 s fill)
## still holds.


func _init() -> void:
	id = "vael"
	realm = "Ember Forge"
	display_name = "Vael"
	title = "the Kiln Knight"
	form_name = "Kindled"
	role = "Bruiser"
	description = "An iron knight whose armour is a living kiln. Sword and shield; hard to kill, strongest in the thick of a fight."

	max_hp = 1000.0
	hp_regen = 5.0
	move_speed = 6.0
	attack_damage = 40.0
	attack_interval = 0.8
	attack_range = 2.5

	primary = "str"
	strength = 30.0
	agility = 20.0
	intelligence = 20.0
	strength_gain = 3.0
	agility_gain = 2.0
	intelligence_gain = 2.0
	exclusive_item = "kilnheart_core"

	form_duration = 15.0
	form_shield_ratio = 0.25
	form_damage_mult = 1.25
	form_speed_mult = 1.3
	form_scale = 1.4


## Look: KayKit Knight (CC0, Kay Lousberg) with sword and round shield.
func create_model() -> Node3D:
	return RiggedModel.make("res://assets/thirdparty/kaykit/characters/Knight.glb", "1H_Melee_Attack_Chop", "2H_Melee_Attack_Spin",
			["1H_Sword", "Round_Shield"], Color(1.0, 0.45, 0.1))


func create_skills() -> Array[Skill]:
	return arrange([SlamSkill.new(), DashSkill.new(), SearingBrandSkill.new(), ForgeGolemSkill.new()])
