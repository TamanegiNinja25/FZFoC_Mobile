class_name DashSkill
extends Skill
## Ember Dash: a short burst in the stick direction, or forward if the stick is idle.

const DISTANCE := 5.0
const DURATION := 0.18


func _init() -> void:
	skill_name = "Ember Dash"
	description = "Burst 5 units in the stick direction (+0.5 per rank)."
	cooldown = 8.0


func _cast(hero: Hero) -> void:
	var distance := DISTANCE + 0.5 * (rank - 1)
	var start := hero.global_position
	var direction := hero.aim_direction()
	hero.start_dash(direction * distance / DURATION, DURATION)
	hero.play_sfx("dash")
	for i in 3:  # afterimages along the dash
		hero.vfx("ghost", [start + direction * distance * i / 3.0, hero.model.rotation.y, Color(1.0, 0.55, 0.2)])


## Strong bots dash onto a wounded, fleeing hero.
func ai_should_cast(hero: Hero, target: Node3D, skill: float) -> bool:
	var d := distance_to(hero, target)
	return skill > 0.45 and target is Hero and d > 4.0 and d < 8.0 and target.hp / target.max_hp < 0.5


func ai_escape() -> bool:
	return true
