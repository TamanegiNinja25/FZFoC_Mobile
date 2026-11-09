class_name BuffSkill
extends Skill
## Configurable self-buff: a shield (fraction of max HP), damage reduction,
## faster attacks and/or moments of invulnerability, for `duration` seconds.

var duration := 4.0
var shield := 0.0
var guard := 0.0          # e.g. 0.4 = take 40% less damage
var haste := 1.0          # attack speed multiplier
var color := Color(0.95, 0.8, 0.45)


func _init(name_ := "", description_ := "", cooldown_ := 14.0) -> void:
	skill_name = name_
	description = description_
	cooldown = cooldown_


func _cast(hero: Hero) -> void:
	var length := duration + 0.5 * (rank - 1)
	if shield > 0.0:
		hero.shield += hero.max_hp * shield
		hero.health_changed.emit(hero.hp, hero.max_hp, hero.shield)
	if guard > 0.0:
		hero.apply_guard(guard, length)
	if haste > 1.0:
		hero.apply_haste(haste, length)
	hero.vfx("column", [hero.global_position, color, 3.5])
	hero.vfx("ring", [hero.global_position, 1.8, color])
	hero.play_sfx("confirm", 0.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	return target is Hero and distance_to(hero, target) < 6.0 and hero.hp / hero.max_hp < 0.8
