class_name AreaSkill
extends Skill
## Configurable area skill, centred on the caster or `ahead` units in front:
## an instant blast, an optional channel before it lands, or a zone that
## ticks damage for `zone_time` seconds. Can stun, slow, knock back and make
## the caster untouchable while it lasts.

var radius := 3.5
var ahead := 0.0
var damage := 100.0
var channel := 0.0
var zone_time := 0.0          # > 0: damage per second over this long instead of one blast
var stun := 0.0
var slow := 0.0
var knockback := 0.0
var self_invulnerable := 0.0
var color := Color(1, 0.8, 0.4)
var effect := "burst"         # "burst", "rock" or "column" on impact


func _init(name_ := "", description_ := "", cooldown_ := 8.0) -> void:
	skill_name = name_
	description = description_
	cooldown = cooldown_


func _center(hero: Hero) -> Vector3:
	return hero.global_position + hero.aim_direction() * ahead


func _cast(hero: Hero) -> void:
	hero._face(hero.aim_direction())
	var spot := _center(hero)
	if self_invulnerable > 0.0:
		hero.make_invulnerable(self_invulnerable)
	if channel > 0.0:
		hero.apply_root(channel)
		hero.vfx("ring", [spot, radius * 0.5, Color(color.r, color.g, color.b, 0.6)])
		hero.get_tree().create_timer(channel, false, true).timeout.connect(_land.bind(hero, spot))
	else:
		_land(hero, spot)


func _land(hero: Hero, spot: Vector3) -> void:
	if not is_instance_valid(hero) or not hero.is_alive():
		return
	if zone_time > 0.0:
		var ticks := int(zone_time / 0.5)
		for i in ticks:
			hero.get_tree().create_timer(0.5 * i, false, true).timeout.connect(_tick.bind(hero, spot, damage * 0.5))
		hero.vfx("ring", [spot, radius, Color(color.r, color.g, color.b, 0.8)])
		return
	_hit_all(hero, spot, damage)
	match effect:
		"rock":
			hero.vfx("rock", [spot, radius])
		"column":
			hero.vfx("column", [spot, color, 5.0])
			hero.vfx("ring", [spot, radius, color])
		_:
			hero.vfx("ring", [spot, radius, color])
			hero.vfx("burst", [spot, color, 30, 6.0])
	hero.play_sfx("slam", 2.0)


func _tick(hero: Hero, spot: Vector3, amount: float) -> void:
	if not is_instance_valid(hero) or not hero.is_alive():
		return
	_hit_all(hero, spot, amount)
	hero.vfx("burst", [spot + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * radius * 0.6, color, 10, 4.0])


func _hit_all(hero: Hero, spot: Vector3, amount: float) -> void:
	for node in Creep.nearby(hero.get_tree(), spot, radius):
		if not hero.is_hostile(node) or not node.is_alive() or spot.distance_to(node.global_position) > radius:
			continue
		hero.deal_damage(node, scaled(hero, amount))
		if stun > 0.0 and node.has_method("apply_stun"):
			node.apply_stun(stun)
		if slow > 0.0 and node is Hero:
			node.apply_slow(1.0 - slow, 1.0 if zone_time > 0.0 else 2.0)
		if knockback > 0.0 and node.has_method("push"):
			var away: Vector3 = node.global_position - spot
			away.y = 0.0
			node.push((away.normalized() if away.length() > 0.1 else Vector3.FORWARD) * knockback / 0.3, 0.3)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	var d := distance_to(hero, target)
	if ahead <= 0.0:
		return not hostiles_within(hero, radius * 0.9).is_empty()
	return target is Hero and absf(d - ahead) < radius
