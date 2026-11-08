class_name Skill
extends RefCounted
## A hero skill with a cooldown and ranks. Subclasses implement _cast().
## Ranks follow the reference map: a skill unlocks at `required_level` and each
## further rank needs `level_skip` more hero levels; one skill point per rank.

var skill_name := ""
var description := ""
var cooldown := 6.0
var time_left := 0.0

var rank := 0
var max_rank := 5
var required_level := 1
var level_skip := 5
var ultimate := false


## Name shown on the button; skills can rename themselves while the hero is transformed.
func display_name(_hero: Hero) -> String:
	return skill_name


func is_learned() -> bool:
	return rank > 0


func is_ready() -> bool:
	return rank > 0 and time_left <= 0.0


## Hero level needed for the next rank.
func next_rank_level() -> int:
	return required_level + level_skip * rank


func can_learn(hero: Hero) -> bool:
	return rank < max_rank and hero.level >= next_rank_level()


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


## Damage of this skill right now: +35% per rank above the first, scaled by the
## hero's intelligence, plus 1 per primary-attribute point gained (the map's
## skills scale with hero attributes). Rank 1 at level 1 equals `base`.
func scaled(hero: Hero, base: float) -> float:
	return base * (1.0 + 0.35 * (maxi(rank, 1) - 1)) * hero.skill_power + hero.attribute_gained(hero.definition.primary)


## Rank as pips for the HUD, e.g. "●●○○○".
func rank_pips() -> String:
	return "●".repeat(rank) + "○".repeat(max_rank - rank)


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


static func nearest_hostile(hero: Hero, radius: float) -> Node3D:
	var best: Node3D = null
	var best_d := radius
	for node in hostiles_within(hero, radius):
		var d := hero.global_position.distance_to(node.global_position)
		# Heroes first: a skill aimed at "the nearest enemy" prefers a hero in range.
		if node is Hero:
			d -= 100.0
		if d < best_d:
			best = node
			best_d = d
	return best


static func distance_to(hero: Hero, target: Node3D) -> float:
	return hero.global_position.distance_to(target.global_position) if target else INF
