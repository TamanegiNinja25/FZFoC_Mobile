class_name ForgeGolemSkill
extends Skill
## Forge Golem (Vael, ultimate): pour molten iron into a golem that fights for
## him for 25 s. A summon — the second most common effect in the reference map.

const LIFETIME := 25.0


func _init() -> void:
	skill_name = "Forge Golem"
	description = "Summon a molten golem for 25 s: 900 HP, 45 damage (+40% per rank)."
	cooldown = 90.0


func _cast(hero: Hero) -> void:
	var spot := hero.global_position + hero.aim_direction() * 2.0
	Creep.summon(hero, "golem", spot, LIFETIME, 1.0 + 0.4 * (rank - 1))
	hero.vfx("ring", [spot, 2.5, Color(1.0, 0.5, 0.15, 0.9)])
	hero.vfx("column", [spot, Color(1.0, 0.5, 0.15), 5.0])
	hero.vfx("burst", [spot, Color(1.0, 0.45, 0.1), 40, 7.0])
	hero.play_sfx("transform", -4.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	return target is Hero and distance_to(hero, target) < 8.0
