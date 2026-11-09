class_name SearingBrandSkill
extends Skill
## Searing Brand (Vael): hurl a white-hot rivet at the nearest enemy within 7 —
## damage and a stun (the reference map's most common skill effect).

const RANGE := 7.0
const DAMAGE := 110.0


func _init() -> void:
	skill_name = "Searing Brand"
	description = "Hit the nearest enemy within 7 for 110 (+35% per rank) and stun it for 1.25 s (+0.25 s per rank)."
	cooldown = 10.0


func stun_time() -> float:
	return 1.0 + 0.25 * rank


func _cast(hero: Hero) -> void:
	var target := nearest_hostile(hero, RANGE)
	if target == null:
		time_left = 0.0  # nothing in range: no cooldown wasted
		return
	hero._face(target.global_position - hero.global_position)
	hero.deal_damage(target, scaled(hero, DAMAGE))
	if target.has_method("apply_stun"):
		target.apply_stun(stun_time())
	hero.vfx("beam", [hero.global_position, target.global_position, Color(1.0, 0.75, 0.3), 0.18])
	hero.vfx("ring", [target.global_position, 1.4, Color(1.0, 0.7, 0.3, 0.9)])
	hero.vfx("burst", [target.global_position, Color(1.0, 0.65, 0.2), 18, 5.0])
	hero.play_sfx("hit", 3.0)


func try_cast(hero: Hero) -> bool:
	if not is_ready() or nearest_hostile(hero, RANGE) == null:
		return false
	return super.try_cast(hero)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	return target is Hero and distance_to(hero, target) <= RANGE
