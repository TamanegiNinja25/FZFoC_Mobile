class_name Skill
extends RefCounted
## A hero skill with a cooldown. Subclasses implement _cast().

var skill_name := ""
var description := ""
var cooldown := 6.0
var time_left := 0.0


## Name shown on the button; skills can rename themselves while the hero is transformed.
func display_name(_hero: Hero) -> String:
	return skill_name


func is_ready() -> bool:
	return time_left <= 0.0


func tick(delta: float) -> void:
	time_left = maxf(time_left - delta, 0.0)


func try_cast(hero: Hero) -> bool:
	if not is_ready():
		return false
	_cast(hero)
	time_left = cooldown * (1.0 - hero.cooldown_reduction)
	return true


func _cast(_hero: Hero) -> void:
	pass


## Bot hint: should a bot cast this now? `skill` is the bot's 0..1 skill level;
## bots aim by facing the target before casting.
func ai_should_cast(_hero: Hero, _target: Node3D, _skill: float) -> bool:
	return false


## Bot hint: can this skill carry the hero away from danger (used when retreating)?
func ai_escape() -> bool:
	return false


static func hostiles_within(hero: Hero, radius: float) -> Array[Node3D]:
	var found: Array[Node3D] = []
	for node in hero.get_tree().get_nodes_in_group("units"):
		if hero.is_hostile(node) and node.is_alive() and hero.global_position.distance_to(node.global_position) <= radius:
			found.append(node)
	return found


static func distance_to(hero: Hero, target: Node3D) -> float:
	return hero.global_position.distance_to(target.global_position) if target else INF
