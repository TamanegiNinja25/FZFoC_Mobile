class_name Ryn
extends HeroDef
## Ryn, the Gale Dancer — speed hero. Fragile and fast; twin blades.
## Transformation: Tempest — faster still, and Cyclone Cut becomes Tempest Cut.


func _init() -> void:
	id = "ryn"
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
	form_duration = 12.0
	form_shield_ratio = 0.15
	form_damage_mult = 1.2
	form_speed_mult = 1.4
	form_scale = 1.2


func create_model() -> Node3D:
	return RynModel.new()


func create_skills() -> Array[Skill]:
	return [CycloneCutSkill.new(), FlurrySkill.new()]
