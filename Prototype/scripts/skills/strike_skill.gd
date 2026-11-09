class_name StrikeSkill
extends Skill
## Configurable single-target skill: hits the nearest enemy (heroes first) within
## `reach` and applies any mix of damage, stun, slow, root, life drain and a
## pull toward the caster. Used to build hero kits from data.

var reach := 6.0
var damage := 100.0
var stun := 0.0
var slow := 0.0          # e.g. 0.5 = 50% slower
var slow_time := 2.0
var root := 0.0
var drain := 0.0         # fraction of damage healed back
var pull := false
var color := Color(1, 0.8, 0.4)
var beam := true
var sound := "hit"


func _init(name_ := "", description_ := "", cooldown_ := 8.0) -> void:
	skill_name = name_
	description = description_
	cooldown = cooldown_


func try_cast(hero: Hero) -> bool:
	if not is_ready() or nearest_hostile(hero, reach) == null:
		return false
	return super.try_cast(hero)


func _cast(hero: Hero) -> void:
	var target := nearest_hostile(hero, reach)
	if target == null:
		return
	hero._face(target.global_position - hero.global_position)
	if beam:
		hero.vfx("beam", [hero.global_position, target.global_position, color, 0.16])
	var before := hero.damage_dealt
	hero.deal_damage(target, scaled(hero, damage))
	if drain > 0.0:
		hero.heal((hero.damage_dealt - before) * drain)
		hero.vfx("burst", [hero.global_position, FloatText.HEAL, 14, 3.0])
	if stun > 0.0 and target.has_method("apply_stun"):
		target.apply_stun(stun + 0.1 * (rank - 1))
	if slow > 0.0 and target is Hero:
		target.apply_slow(1.0 - slow, slow_time)
	if root > 0.0 and target.has_method("apply_root"):
		target.apply_root(root)
	if pull and target.has_method("push"):
		var toward := hero.global_position - target.global_position
		toward.y = 0.0
		var distance := maxf(toward.length() - 1.4, 0.0)
		target.push(toward.normalized() * distance / 0.25, 0.25)
	hero.vfx("burst", [target.global_position, color, 18, 5.0])
	hero.play_sfx(sound, 2.0)


func ai_should_cast(hero: Hero, target: Node3D, _skill: float) -> bool:
	return target is Hero and distance_to(hero, target) <= reach
