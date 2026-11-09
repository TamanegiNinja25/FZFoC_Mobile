class_name RockfallSkill
extends Skill
## Rockfall (Barrow, ultimate): he channels for 1.2 s, rooted, then a mountain's
## worth of stone lands 5 units ahead — huge damage and a stun in a radius of 4.
## A channelled cast, like the reference map's biggest skills.

const CHANNEL := 1.2
const REACH := 5.0
const RADIUS := 4.0
const DAMAGE := 350.0
const STUN := 1.5


func _init() -> void:
	skill_name = "Rockfall"
	description = "Channel 1.2 s, then crush everything within 4 of a point 5 ahead: 350 (+35% per rank) and a 1.5 s stun."
	cooldown = 100.0


func _cast(hero: Hero) -> void:
	var direction := hero.aim_direction()
	hero._face(direction)
	var spot := hero.global_position + direction * REACH
	hero.apply_root(CHANNEL)
	hero.vfx("ring", [spot, RADIUS * 0.5, Color(0.9, 0.75, 0.4, 0.6)])
	hero.get_tree().create_timer(CHANNEL, false, true).timeout.connect(_land.bind(hero, spot))


func _land(hero: Hero, spot: Vector3) -> void:
	if not is_instance_valid(hero) or not hero.is_alive():
		return
	for node in Creep.nearby(hero.get_tree(), spot, RADIUS):
		if hero.is_hostile(node) and node.is_alive() and spot.distance_to(node.global_position) <= RADIUS:
			hero.deal_damage(node, scaled(hero, DAMAGE))
			if node.has_method("apply_stun"):
				node.apply_stun(STUN)
	hero.vfx("rock", [spot, RADIUS])
	hero.play_sfx("slam", 4.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	var d := distance_to(hero, target)
	return target is Hero and d > 2.5 and d < REACH + 2.0
