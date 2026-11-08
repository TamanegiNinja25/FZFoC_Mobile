class_name HeroDef
extends Resource
## Data for one hero: identity, base stats, transformation and skills.
## Each hero is a subclass that sets these values and builds its model and skills.

@export var id := ""
@export var display_name := ""
@export var title := ""
@export var form_name := ""

@export_group("Stats")
@export var max_hp := 1000.0
@export var hp_regen := 5.0
@export var move_speed := 6.0
@export var attack_damage := 40.0
@export var attack_interval := 0.8
@export var attack_range := 2.5

@export_group("Form")
@export var form_duration := 15.0
@export var form_shield_ratio := 0.25
@export var form_damage_mult := 1.25
@export var form_speed_mult := 1.3
@export var form_scale := 1.4


## Returns the hero's visual: a Node3D with set_form(active: bool, scale: float).
func create_model() -> Node3D:
	return Node3D.new()


func create_skills() -> Array[Skill]:
	return []
