class_name BotBrain
extends Node
## Drives a bot hero through the same controls a player has (ai_move, skills,
## transform). Adaptive AI: one `skill` value (0..1), set by the match from the
## score, changes only the bot's decisions — never its stats.
##   low skill  → slow reactions, fights to the death, hits the nearest enemy,
##                misses skills, wastes its form the moment the meter fills
##   high skill → fast reactions, retreats to heal, focuses the weakest enemy,
##                lands skills, saves its form for a fight, dashes to finish

const AGGRO_RANGE := 16.0
const FARM_RANGE := 30.0

var hero: Hero
## The match: provides fountain_position(team) and center_point().
var arena: Node
var skill := 0.5

var _think := 0.0
var _retreating := false
var _stuck_time := 0.0
var _sidestep := Vector3.ZERO
var _sidestep_time := 0.0


func reaction_time() -> float:
	return lerpf(0.7, 0.15, skill)


func retreat_threshold() -> float:
	return lerpf(0.0, 0.38, skill)  # the weakest bots never retreat


func skill_accuracy() -> float:
	return lerpf(0.3, 0.95, skill)


func _physics_process(delta: float) -> void:
	if hero == null or not hero.is_alive():
		if hero:
			hero.ai_move = Vector3.ZERO
		_retreating = false
		return
	_track_stuck(delta)
	if _sidestep_time > 0.0:
		_sidestep_time -= delta
		hero.ai_move = _sidestep
		return
	_think -= delta
	if _think > 0.0:
		return
	_think = reaction_time() * randf_range(0.8, 1.2)
	_decide()


func _decide() -> void:
	var hp_ratio := hero.hp / hero.max_hp
	var home: Vector3 = arena.fountain_position(hero.team)

	# Retreat to heal at the fountain; stay until mostly healthy.
	if _retreating and hp_ratio > 0.85:
		_retreating = false
	elif not _retreating and hp_ratio < retreat_threshold() and not hero.in_form:
		_retreating = true
	if _retreating:
		_move_to(home)
		if skill > 0.5 and _count_enemy_heroes(5.0) > 0:
			hero.try_skill(1)  # dash away along the retreat path
		return

	var target := _choose_target()
	if target == null:
		_move_to(arena.center_point())
		return
	var distance := hero.global_position.distance_to(target.global_position)

	# Transformation: strong bots wait for a fight; weak bots use it at once.
	if hero.meter.is_full() and (skill < 0.35 or _count_enemy_heroes(7.0) > 0):
		hero.try_transform()

	# Bellows Slam / Eruption when something hostile is inside its radius.
	var slam := hero.skills[0] as SlamSkill
	if slam and slam.is_ready() and _count_hostiles(slam.power(hero).radius * 0.9) > 0 and randf() < skill_accuracy():
		hero.try_skill(0)

	# Strong bots dash onto a fleeing, wounded hero.
	if skill > 0.45 and target is Hero and distance > 4.0 and distance < 8.0 and target.hp / target.max_hp < 0.5:
		hero.ai_move = _flat_direction(target.global_position)
		hero.try_skill(1)

	if distance > hero.attack_range * 0.85:
		_move_to(target.global_position)
	else:
		hero.ai_move = Vector3.ZERO  # in range: the auto-attack does the work


## Strong bots focus the weakest enemy hero nearby; weak bots take the nearest.
## With no hero in reach, bots farm the nearest neutral camp.
func _choose_target() -> Node3D:
	var best: Node3D = null
	var best_score := INF
	for node in get_tree().get_nodes_in_group("heroes"):
		if not hero.is_hostile(node) or not node.is_alive():
			continue
		var distance := hero.global_position.distance_to(node.global_position)
		if distance > AGGRO_RANGE:
			continue
		var score := distance
		if skill > 0.5:
			score = node.hp / node.max_hp * AGGRO_RANGE + distance * 0.3
		if score < best_score:
			best = node
			best_score = score
	if best:
		return best
	for node in get_tree().get_nodes_in_group("units"):
		if node is Hero or not hero.is_hostile(node) or not node.is_alive():
			continue
		var distance := hero.global_position.distance_to(node.global_position)
		if distance < FARM_RANGE and distance < best_score:
			best = node
			best_score = distance
	return best


func _count_enemy_heroes(radius: float) -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("heroes"):
		if hero.is_hostile(node) and node.is_alive() and hero.global_position.distance_to(node.global_position) <= radius:
			count += 1
	return count


func _count_hostiles(radius: float) -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("units"):
		if hero.is_hostile(node) and node.is_alive() and hero.global_position.distance_to(node.global_position) <= radius:
			count += 1
	return count


func _move_to(point: Vector3) -> void:
	var offset := point - hero.global_position
	offset.y = 0.0
	hero.ai_move = offset.normalized() if offset.length() > 0.6 else Vector3.ZERO


func _flat_direction(point: Vector3) -> Vector3:
	var offset := point - hero.global_position
	offset.y = 0.0
	return offset.normalized()


## Pillars can block a straight path. If the bot is trying to move but isn't,
## it sidesteps perpendicular to its heading for a moment.
func _track_stuck(delta: float) -> void:
	var trying := hero.ai_move.length() > 0.1
	var moving := hero.get_real_velocity().length() > hero.move_speed * 0.25
	_stuck_time = _stuck_time + delta if trying and not moving else 0.0
	if _stuck_time > 0.35:
		_stuck_time = 0.0
		var side := 1.0 if randf() < 0.5 else -1.0
		_sidestep = Vector3(-hero.ai_move.z, 0.0, hero.ai_move.x).normalized() * side
		_sidestep_time = 0.6
