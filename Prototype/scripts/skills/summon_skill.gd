class_name SummonSkill
extends Skill
## Configurable summon: `count` units of a summon kind (CreepTypes.SUMMONS)
## fight for the caster for `lifetime` seconds, stronger with each rank.

var kind := "wisp"
var count := 2
var lifetime := 18.0
var color := Color(0.7, 1.0, 0.75)


func _init(name_ := "", description_ := "", cooldown_ := 16.0) -> void:
	skill_name = name_
	description = description_
	cooldown = cooldown_


func _cast(hero: Hero) -> void:
	var forward := hero.aim_direction()
	for i in count:
		var angle := (float(i) - (count - 1) / 2.0) * 0.8
		var spot := hero.global_position + forward.rotated(Vector3.UP, angle) * 2.0
		Creep.summon(hero, kind, spot, lifetime, 1.0 + 0.3 * (rank - 1))
		hero.vfx("column", [spot, color, 3.5])
	hero.vfx("burst", [hero.global_position + forward * 2.0, color, 30, 5.0])
	hero.play_sfx("transform", -4.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	return distance_to(hero, target) < 9.0
