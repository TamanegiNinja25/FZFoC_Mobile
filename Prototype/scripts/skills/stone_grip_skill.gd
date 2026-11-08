class_name StoneGripSkill
extends Skill
## Stone Grip (Barrow): stone hands burst from the ground around the nearest
## enemy within 8, rooting it in place and crushing it over time.

const RANGE := 8.0
const DPS := 40.0


func _init() -> void:
	skill_name = "Stone Grip"
	description = "Root the nearest enemy within 8 for 2 s (+0.25 s per rank), crushing it for 40/s (+35% per rank)."
	cooldown = 11.0


func root_time() -> float:
	return 1.75 + 0.25 * rank


func try_cast(hero: Hero) -> bool:
	if not is_ready() or nearest_hostile(hero, RANGE) == null:
		return false
	return super.try_cast(hero)


func _cast(hero: Hero) -> void:
	var target := nearest_hostile(hero, RANGE)
	if target.has_method("apply_root"):
		target.apply_root(root_time())
	if target.has_method("apply_dot"):
		target.apply_dot(scaled(hero, DPS), root_time(), hero)
	else:
		hero.deal_damage(target, scaled(hero, DPS) * root_time())
	Effects.ring(hero.get_parent(), target.global_position, 1.2, Color(0.75, 0.6, 0.35, 0.95))
	hero.fx.emit("ring", [target.global_position, 1.2, Color(0.75, 0.6, 0.35, 0.95)])
	hero.play_sfx("slam", -4.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	return target is Hero and distance_to(hero, target) <= RANGE
