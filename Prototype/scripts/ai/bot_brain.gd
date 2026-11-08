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
## Items already bought from the build (parts may since have been fused).
var _bought := {}


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
	_learn_skills()
	if hero.in_shop_range:
		_shop()
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
			for i in hero.skills.size():
				if hero.skills[i].ai_escape() and hero.skills[i].is_ready():
					hero.try_skill(i)  # escape along the retreat path
					break
		return

	# Carry a finished recipe to the combining circle when no enemy hero is close.
	if hero.has_recipe_ready() and _count_enemy_heroes(10.0) == 0 and arena.has_method("circle_position"):
		_move_to(arena.circle_position(hero.team))
		return

	var target := _choose_target()
	if target == null:
		_move_to(arena.center_point())
		return
	var distance := hero.global_position.distance_to(target.global_position)

	# Transformation: strong bots wait for a fight; weak bots use it at once.
	if hero.meter.is_full() and (skill < 0.35 or _count_enemy_heroes(7.0) > 0):
		hero.try_transform()

	# Each skill says when it's worth casting; accuracy scales with skill.
	for i in hero.skills.size():
		var s: Skill = hero.skills[i]
		if s.is_ready() and s.ai_should_cast(hero, target, skill) and randf() < skill_accuracy():
			hero.ai_move = _flat_direction(target.global_position)
			hero.try_skill(i)

	if distance > hero.attack_range * 0.85:
		_move_to(target.global_position)
	else:
		hero.ai_move = Vector3.ZERO  # in range: the auto-attack does the work


## Buys the next item of the bot build (one per decision); once the build is
## done, spends spare gold on primary-attribute tomes from the stat shop.
func _shop() -> void:
	for entry in ItemCatalog.BOT_BUILD:
		var item_id: String = hero.definition.exclusive_item if entry == "exclusive" else entry
		if _bought.has(item_id):
			continue
		var error := hero.buy(item_id)
		if error != "Not enough gold":
			_bought[item_id] = true  # bought, or never buyable (full, wrong hero): move on
		return
	var tome := "tome_agi_5" if hero.definition.primary == "agi" else "tome_str_5"
	if hero.gold >= ItemCatalog.find(tome).cost * 2:
		hero.buy(tome)


## Spends skill points: the ultimate as soon as it can rank up, otherwise the
## lowest-ranked skill that can (ties go to the earlier button).
func _learn_skills() -> void:
	while hero.skill_points > 0:
		var pick := -1
		for i in hero.skills.size():
			var s: Skill = hero.skills[i]
			if not s.can_learn(hero):
				continue
			if s.ultimate:
				pick = i
				break
			if pick == -1 or s.rank < hero.skills[pick].rank:
				pick = i
		if pick == -1 or not hero.learn_skill(pick):
			return


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
		if node is Hero or not hero.is_hostile(node) or not node.is_alive() or not _worth_farming(node):
			continue
		var distance := hero.global_position.distance_to(node.global_position)
		if distance < FARM_RANGE and distance < best_score:
			best = node
			best_score = distance
	return best


## Bots leave bosses alone until they're strong enough, and only go for the
## win boss late in a Classic match.
func _worth_farming(node: Node) -> bool:
	if "frozen" in node and node.frozen:
		return false
	if not ("is_boss" in node) or not node.is_boss:
		return true
	if node.is_colossus:
		return hero.level >= 30
	return hero.level + 2 >= node.level


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
