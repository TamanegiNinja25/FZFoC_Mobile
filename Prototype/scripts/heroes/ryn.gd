class_name Ryn
extends HeroDef
## Ryn, the Gale Dancer — speed hero. Fragile and fast; twin blades.
## Transformation: Tempest — faster still, and Cyclone Cut becomes Tempest Cut.


func _init() -> void:
	id = "ryn"
	realm = "Gale Peaks"
	display_name = "Ryn"
	title = "the Gale Dancer"
	form_name = "Tempest"
	role = "Speed"
	description = "A hooded duelist who fights on the wind. Twin blades, blinding speed, little armour."
	max_hp = 820.0
	hp_regen = 4.5
	move_speed = 7.0
	attack_damage = 26.0
	attack_interval = 0.55
	attack_range = 2.2
	primary = "agi"
	strength = 20.0
	agility = 30.0
	intelligence = 20.0
	strength_gain = 2.0
	agility_gain = 3.0
	intelligence_gain = 2.0
	exclusive_item = "galeheart_ribbon"
	form_duration = 12.0
	form_shield_ratio = 0.15
	form_damage_mult = 1.2
	form_speed_mult = 1.4
	form_scale = 1.2


## Look: KayKit Rogue (hooded, CC0, Kay Lousberg) with twin knives.
func create_model() -> Node3D:
	return RiggedModel.make("res://assets/thirdparty/kaykit/characters/Rogue_Hooded.glb", "Dualwield_Melee_Attack_Slice", "2H_Melee_Attack_Spin",
			["Knife", "Knife_Offhand"], Color(0.35, 1.0, 0.95))


func create_skills() -> Array[Skill]:
	return arrange([CycloneCutSkill.new(), FlurrySkill.new(), RazorWindSkill.new(), ThousandCutsSkill.new()])
