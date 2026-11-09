class_name QuakeStompSkill
extends Skill
## Quake Stomp (Barrow): shake the ground — damage around him and slow enemy
## heroes. While in Avalanche: 1.4× radius and a stronger slow.

const RADIUS := 3.5
const DAMAGE := 90.0


func _init() -> void:
	skill_name = "Quake Stomp"
	description = "Hit enemies within 3.5 for 90 (+35% per rank) and slow heroes 40% for 2 s. Avalanche: 4.9 radius, 55% slow."
	cooldown = 8.0


func radius(hero: Hero) -> float:
	return RADIUS * (1.4 if hero.in_form else 1.0)


func _cast(hero: Hero) -> void:
	var r := radius(hero)
	var slow := 0.45 if hero.in_form else 0.6
	for node in hostiles_within(hero, r):
		hero.deal_damage(node, scaled(hero, DAMAGE))
		if node is Hero:
			node.apply_slow(slow, 2.0)
	if hero.model.has_method("play_slam"):
		hero.model.play_slam(r, hero.in_form)
	hero.fx.emit("slam", [r, hero.in_form])
	hero.vfx("burst", [hero.global_position, Color(0.6, 0.52, 0.4), 34, 7.0])
	hero.play_sfx("slam")


func ai_should_cast(hero: Hero, _target: Node3D, _skill: float) -> bool:
	return not hostiles_within(hero, radius(hero) * 0.9).is_empty()
