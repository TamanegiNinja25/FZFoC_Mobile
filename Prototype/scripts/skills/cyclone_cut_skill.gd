class_name CycloneCutSkill
extends Skill
## Cyclone Cut (Ryn): dash through the line, slicing every enemy along the path.
## While in Tempest it becomes Tempest Cut: 1.5× distance and damage.

const DISTANCE := 6.0
const DAMAGE := 100.0
const WIDTH := 1.4
const DURATION := 0.2


func _init() -> void:
	skill_name = "Cyclone Cut"
	description = "Dash 6, slicing enemies on the path for 100 (+35% per rank). Tempest: 9 units, ×1.5 damage."
	cooldown = 7.0


func display_name(hero: Hero) -> String:
	return "Tempest Cut" if hero.in_form else skill_name


func _cast(hero: Hero) -> void:
	var scale := 1.5 if hero.in_form else 1.0
	var direction := hero.aim_direction()
	var start := hero.global_position
	var finish := start + direction * DISTANCE * scale
	for node in hero.get_tree().get_nodes_in_group("units"):
		if hero.is_hostile(node) and node.is_alive() and segment_distance(node.global_position, start, finish) <= WIDTH:
			hero.deal_damage(node, scaled(hero, DAMAGE) * scale)
	hero.start_dash(direction * DISTANCE * scale / DURATION, DURATION)
	hero.play_sfx("dash")
	var yaw := atan2(-direction.x, -direction.z)
	for i in 4:  # wind afterimages and a slash along the path
		hero.vfx("ghost", [start + direction * DISTANCE * scale * i / 4.0, yaw, Color(0.4, 1.0, 0.95)])
	hero.vfx("slash", [start + direction * DISTANCE * scale * 0.5, yaw, 2.6, Color(0.6, 1.0, 1.0, 0.8)])


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	var d := distance_to(hero, target)
	return d > 2.0 and d < DISTANCE


func ai_escape() -> bool:
	return true


static func segment_distance(p: Vector3, a: Vector3, b: Vector3) -> float:
	var ab := Vector2(b.x - a.x, b.z - a.z)
	var ap := Vector2(p.x - a.x, p.z - a.z)
	var t := clampf(ap.dot(ab) / maxf(ab.length_squared(), 0.0001), 0.0, 1.0)
	return (ap - ab * t).length()
