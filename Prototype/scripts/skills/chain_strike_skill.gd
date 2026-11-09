class_name ChainStrikeSkill
extends Skill
## Configurable barrage: `strikes` bolts fall on random enemies within `radius`,
## one every `interval` seconds, each dealing damage and an optional stun.

var radius := 10.0
var strikes := 5
var interval := 0.2
var damage := 200.0
var stun := 1.0
var color := Color(0.7, 0.85, 1.0)


func _init(name_ := "", description_ := "", cooldown_ := 90.0) -> void:
	skill_name = name_
	description = description_
	cooldown = cooldown_


func try_cast(hero: Hero) -> bool:
	if not is_ready() or hostiles_within(hero, radius).is_empty():
		return false
	return super.try_cast(hero)


func _cast(hero: Hero) -> void:
	hero.vfx("column", [hero.global_position, color, 6.0])
	for i in strikes:
		hero.get_tree().create_timer(interval * (i + 1), false, true).timeout.connect(_strike.bind(hero))


func _strike(hero: Hero) -> void:
	if not is_instance_valid(hero) or not hero.is_alive():
		return
	var targets := hostiles_within(hero, radius)
	if targets.is_empty():
		return
	var target: Node3D = targets[randi() % targets.size()]
	hero.vfx("beam", [target.global_position + Vector3(0, 9, 0), target.global_position, color, 0.35])
	hero.vfx("burst", [target.global_position, color, 18, 6.0])
	hero.deal_damage(target, scaled(hero, damage))
	if stun > 0.0 and target.has_method("apply_stun"):
		target.apply_stun(stun)
	hero.play_sfx("hit", 3.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	return target is Hero and distance_to(hero, target) < radius - 2.0
