class_name DashSkill
extends Skill
## Ember Dash: a short burst in the stick direction, or forward if the stick is idle.

const DISTANCE := 5.0
const DURATION := 0.18


func _init() -> void:
	skill_name = "Ember Dash"
	description = "Burst 5 units in the stick direction."
	cooldown = 8.0


func _cast(hero: Hero) -> void:
	hero.start_dash(hero.aim_direction() * DISTANCE / DURATION, DURATION)
