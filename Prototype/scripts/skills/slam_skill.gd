class_name SlamSkill
extends Skill
## Bellows Slam: Vael drives the hammer into the ground and hits every enemy
## around him. While Kindled it becomes Eruption — see power().

const BASE_RADIUS := 3.0
const BASE_DAMAGE := 120.0


func _init() -> void:
	skill_name = "Bellows Slam"
	description = "Hit every enemy within 3 for 120. Kindled: Eruption — 4.5 radius, 180 damage."
	cooldown = 6.0


func display_name(hero: Hero) -> String:
	return "Eruption" if hero.in_form else skill_name


## Radius and damage of the slam right now. Damage is before the form's
## general damage multiplier, which Hero.deal_damage() applies to all damage.
func power(hero: Hero) -> Dictionary:
	var radius := BASE_RADIUS
	var damage := BASE_DAMAGE
	if hero.in_form:
		# Eruption: the kiln vents outward — a wider blast that catches groups and
		# fleeing enemies, plus a modest hit. With the form's ×1.25 on all damage
		# the total is ×1.5 (120 → 180), the top of the spec's +30–50% form budget.
		radius *= 1.5
		damage *= 1.2
	return {"radius": radius, "damage": damage}


func _cast(hero: Hero) -> void:
	var p := power(hero)
	for node in hero.get_tree().get_nodes_in_group("units"):
		if hero.is_hostile(node) and node.is_alive() and hero.global_position.distance_to(node.global_position) <= p.radius:
			hero.deal_damage(node, p.damage)
	hero.play_sfx("slam")
	if hero.model.has_method("play_slam"):
		hero.model.play_slam(p.radius, hero.in_form)
	hero.fx.emit("slam", [p.radius, hero.in_form])


func ai_should_cast(hero: Hero, _target: Node3D, _skill: float) -> bool:
	return not hostiles_within(hero, power(hero).radius * 0.9).is_empty()
