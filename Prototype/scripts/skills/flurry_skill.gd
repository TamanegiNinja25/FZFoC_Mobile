class_name FlurrySkill
extends Skill
## Flurry (Ryn): 60% faster attacks for 4 seconds.

const MULTIPLIER := 1.6
const DURATION := 4.0


func _init() -> void:
	skill_name = "Flurry"
	description = "Attack 60% faster for 4 s (+0.5 s per rank)."
	cooldown = 10.0


func _cast(hero: Hero) -> void:
	hero.apply_haste(MULTIPLIER, DURATION + 0.5 * (rank - 1))
	hero.play_sfx("dash", 2.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	return distance_to(hero, target) <= hero.attack_range + 0.5
