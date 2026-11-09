class_name ProjectileSkill
extends Skill
## Configurable shot: one or more projectiles fly in the aim direction. Each hits
## the first enemy (or, piercing, everything) in its path for damage, with an
## optional stun or a pull back to the caster. Waves and beams are wide,
## piercing shots.

var damage := 100.0
var speed := 22.0
var reach := 12.0
var count := 1
var spread_deg := 18.0
var pierce := false
var width := 1.1
var stun := 0.0
var pull := false
var color := Color(1, 0.9, 0.6)
var size := 0.3


func _init(name_ := "", description_ := "", cooldown_ := 8.0) -> void:
	skill_name = name_
	description = description_
	cooldown = cooldown_


func _cast(hero: Hero) -> void:
	var aim := hero.aim_direction()
	hero._face(aim)
	for i in count:
		var offset := 0.0 if count == 1 else lerpf(-spread_deg, spread_deg, float(i) / (count - 1))
		var direction := aim.rotated(Vector3.UP, deg_to_rad(offset))
		var shot := Projectile.launch(hero, direction, speed, reach, scaled(hero, damage))
		shot.configure(pierce, width, stun + (0.1 * (rank - 1) if stun > 0.0 else 0.0), pull, color, size)
		hero.fx.emit("shot", [direction, speed, reach, pierce, width, color, size])
	if pierce and width >= 1.5:
		hero.vfx("beam", [hero.global_position, hero.global_position + aim * reach, color, width * 0.5])
	hero.play_sfx("dash", 2.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	var d := distance_to(hero, target)
	return target is Hero and d > 1.5 and d < reach - 1.0
