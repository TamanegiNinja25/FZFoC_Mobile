class_name BoulderHurlSkill
extends Skill
## Boulder Hurl (Barrow): throw a boulder that hits the first enemy in its path.

const DAMAGE := 160.0
const SPEED := 18.0
const RANGE := 12.0


func _init() -> void:
	skill_name = "Boulder Hurl"
	description = "Throw a boulder 12 units; the first enemy hit takes 160 (+35% per rank)."
	cooldown = 9.0


func _cast(hero: Hero) -> void:
	var direction := hero.aim_direction()
	Projectile.launch(hero, direction, SPEED, RANGE, scaled(hero, DAMAGE))
	hero.fx.emit("boulder", [direction])
	hero.play_sfx("hit", 4.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	var d := distance_to(hero, target)
	return target is Hero and d > 3.0 and d < RANGE - 1.0
