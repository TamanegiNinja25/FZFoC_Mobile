class_name ThousandCutsSkill
extends Skill
## Thousand Cuts (Ryn, ultimate): she vanishes into the wind and strikes random
## enemies within 6 eight times over 1.6 s, untouchable while it lasts.

const RADIUS := 6.0
const STRIKES := 8
const INTERVAL := 0.2
const DAMAGE := 70.0


func _init() -> void:
	skill_name = "Thousand Cuts"
	description = "Untouchable for 1.6 s: 8 strikes of 70 (+35% per rank) on random enemies within 6."
	cooldown = 80.0


func try_cast(hero: Hero) -> bool:
	if not is_ready() or hostiles_within(hero, RADIUS).is_empty():
		return false
	return super.try_cast(hero)


func _cast(hero: Hero) -> void:
	hero.make_invulnerable(STRIKES * INTERVAL + 0.1)
	hero.play_sfx("dash", 4.0)
	for i in STRIKES:
		hero.get_tree().create_timer(INTERVAL * (i + 1), false, true).timeout.connect(_strike.bind(hero))


func _strike(hero: Hero) -> void:
	if not is_instance_valid(hero) or not hero.is_alive():
		return
	var targets := hostiles_within(hero, RADIUS)
	if targets.is_empty():
		return
	var target: Node3D = targets[randi() % targets.size()]
	hero.global_position = target.global_position + (hero.global_position - target.global_position).normalized() * 1.2
	hero._face(target.global_position - hero.global_position)
	hero.deal_damage(target, scaled(hero, DAMAGE))
	hero.play_sfx("hit", -2.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	return target is Hero and distance_to(hero, target) < RADIUS - 1.0
