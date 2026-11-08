class_name SlamSkill
extends Skill
## Bellows Slam: Vael drives the hammer into the ground and hits every enemy
## around him. While Kindled it becomes Eruption — see power().

const BASE_RADIUS := 3.0
const BASE_DAMAGE := 120.0


func _init() -> void:
	skill_name = "Bellows Slam"
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
	for node in hero.get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Dummy
		if enemy and enemy.is_alive() and hero.global_position.distance_to(enemy.global_position) <= p.radius:
			hero.deal_damage(enemy, p.damage)
	if hero.model.has_method("play_slam"):
		hero.model.play_slam(p.radius, hero.in_form)
