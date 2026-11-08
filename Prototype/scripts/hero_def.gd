class_name HeroDef
extends Resource
## Data for one hero: identity, base stats, attributes, transformation and skills.
## Each hero is a subclass that sets these values and builds its model and skills.

@export var id := ""
@export var display_name := ""
@export var title := ""
@export var form_name := ""
## Category on the hero select screen: "Bruiser", "Speed" or "Giant".
@export var role := ""
@export_multiline var description := ""
## Exclusive (signature) item only this hero can wield.
@export var exclusive_item := ""

@export_group("Stats")
## Level-1 values. Attribute points gained later (levels, tomes, items) add on top.
@export var max_hp := 1000.0
@export var hp_regen := 5.0
@export var move_speed := 6.0
@export var attack_damage := 40.0
@export var attack_interval := 0.8
@export var attack_range := 2.5

@export_group("Attributes")
## "str", "agi" or "int": each point gained adds 2 attack damage (the map's
## primary-attribute bonus) and 1 skill damage.
@export var primary := "str"
@export var strength := 20.0
@export var agility := 20.0
@export var intelligence := 20.0
## Points gained per level, as in the reference map (+3 primary, +2 others).
@export var strength_gain := 2.0
@export var agility_gain := 2.0
@export var intelligence_gain := 2.0

@export_group("Form")
@export var form_duration := 15.0
@export var form_shield_ratio := 0.25
@export var form_damage_mult := 1.25
@export var form_speed_mult := 1.3
@export var form_scale := 1.4


func base_attribute(key: String) -> float:
	return {"str": strength, "agi": agility, "int": intelligence}.get(key, 0.0)


func attribute_gain(key: String) -> float:
	return {"str": strength_gain, "agi": agility_gain, "int": intelligence_gain}.get(key, 0.0)


## Returns the hero's visual: a Node3D with set_form(active: bool, scale: float).
func create_model() -> Node3D:
	return Node3D.new()


## Skills in button order: three ranked skills (5 ranks) and an ultimate (3 ranks).
func create_skills() -> Array[Skill]:
	return []


## Rank rules per button slot, using patterns from the reference map's skills:
## slot 1 from level 1, slot 2 from level 2, slot 3 from level 5, each rank 5
## levels apart; the ultimate has 3 ranks at levels 10, 15 and 20.
static func arrange(skills: Array[Skill]) -> Array[Skill]:
	var rules := [[1, 5, 5], [2, 5, 5], [5, 5, 5], [10, 5, 3]]
	for i in skills.size():
		var rule: Array = rules[mini(i, rules.size() - 1)]
		skills[i].required_level = rule[0]
		skills[i].level_skip = rule[1]
		skills[i].max_rank = rule[2]
		skills[i].ultimate = i == 3
	return skills
