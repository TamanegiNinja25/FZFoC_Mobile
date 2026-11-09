class_name RazorWindSkill
extends Skill
## Razor Wind (Ryn): a fan of wind blades in front of her — a hit, then a bleed
## (damage over time) on everything in a 70° cone up to 6 units.

const RANGE := 6.0
const HALF_ANGLE := deg_to_rad(35.0)
const DAMAGE := 60.0
const BLEED_DPS := 25.0
const BLEED_TIME := 4.0


func _init() -> void:
	skill_name = "Razor Wind"
	description = "Blades in a 70° cone (6 units): 60 damage and a 25/s bleed for 4 s (+35% per rank)."
	cooldown = 9.0


func _cast(hero: Hero) -> void:
	var forward := hero.aim_direction()
	hero._face(forward)
	for node in hostiles_within(hero, RANGE):
		var offset: Vector3 = node.global_position - hero.global_position
		offset.y = 0.0
		if offset.length() < 0.5 or absf(forward.signed_angle_to(offset, Vector3.UP)) <= HALF_ANGLE:
			hero.deal_damage(node, scaled(hero, DAMAGE))
			if node.has_method("apply_dot"):
				node.apply_dot(scaled(hero, BLEED_DPS), BLEED_TIME, hero)
	var yaw := atan2(-forward.x, -forward.z)
	for reach in [2.5, 4.5, 6.0]:  # three widening blade arcs
		hero.vfx("slash", [hero.global_position + forward * (reach - 2.0), yaw, reach * 0.6, Color(0.55, 0.95, 1.0, 0.75)])
	hero.play_sfx("dash", 4.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	return distance_to(hero, target) <= RANGE - 1.0
