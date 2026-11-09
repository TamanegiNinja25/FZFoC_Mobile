class_name BlinkSkill
extends Skill
## Configurable blink: vanish and reappear `distance` units ahead (stopped by
## walls), optionally striking everything around the landing spot.

var distance := 6.0
var damage := 0.0
var radius := 2.2
var color := Color(0.85, 0.9, 1.0)


func _init(name_ := "", description_ := "", cooldown_ := 6.0) -> void:
	skill_name = name_
	description = description_
	cooldown = cooldown_


func _cast(hero: Hero) -> void:
	var direction := hero.aim_direction()
	var start := hero.global_position
	hero.vfx("ghost", [start, hero.model.rotation.y, color])
	# Test the path so a blink can't pass through walls or pillars.
	var motion := direction * (distance + 0.5 * (rank - 1))
	var collision := hero.move_and_collide(motion, true)
	hero.global_position = start + (collision.get_travel() if collision else motion)
	hero._face(direction)
	hero.vfx("burst", [hero.global_position, color, 20, 5.0])
	if damage > 0.0:
		for node in hostiles_within(hero, radius):
			hero.deal_damage(node, scaled(hero, damage))
		hero.vfx("slash", [hero.global_position, hero.model.rotation.y, radius, Color(color.r, color.g, color.b, 0.8)])
	hero.play_sfx("dash", 3.0)


func ai_should_cast(hero: Hero, target: Node3D, skill: float) -> bool:
	var d := distance_to(hero, target)
	return skill > 0.4 and target is Hero and d > 3.0 and d < distance + 1.0


func ai_escape() -> bool:
	return true
