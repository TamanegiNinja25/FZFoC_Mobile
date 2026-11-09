class_name Hero
extends CharacterBody3D
## Player hero: moves, auto-attacks the nearest enemy in range, casts its
## ranked skills, levels up, and transforms into a timed form when its meter is
## full. Identity, stats, attributes, model and skills come from a HeroDef.
##
## Progression follows the reference map: levels 1–50 on Warcraft III's default
## XP curve, kill XP shared by allied heroes nearby, one skill point per level,
## and strength / agility / intelligence that grow each level.

signal health_changed(hp: float, max_hp: float, shield: float)
signal form_changed(active: bool)
signal gold_changed(gold: float, income: float, spree: int)
## killer is the Hero that landed the killing blow, or null.
signal died(killer: Hero)
signal items_changed
signal leveled_up(level: int)
signal skills_changed
## Network: a puppet's actions go to the host instead of running locally.
signal action_requested(kind: String, arg: Variant)
## Network: effects (sounds, slam rings) the host relays to clients.
signal fx(kind: String, data: Array)

@export var move_speed := 6.0
@export var max_hp := 1000.0
## Keeps a hero alive through a ~90 s fight with one dummy (≈17 DPS incoming).
@export var hp_regen := 5.0
@export var attack_damage := 40.0
@export var attack_interval := 0.8
@export var attack_range := 2.5
@export var respawn_time := 3.0

@export_group("Form")
## Spec starting point: 15 s at rank 1 (transformation spec, design notes).
@export var form_duration := 15.0
## Spec: keep the invulnerable transform short, 0.5–1 s.
@export var form_transition := 0.75
## Spec: about +25% HP as a shield.
@export var form_shield_ratio := 0.25
## Spec: about +20–30% damage or attack speed.
@export var form_damage_mult := 1.25
@export var form_speed_mult := 1.3
@export var form_scale := 1.4

@export_group("Economy")
## Gold is on the reference map's scale (hero kill = 500).
@export var base_income := 20.0
## Gold for killing a training dummy (creeps pay their own bounty).
@export var kill_gold := 1000.0
## The next kill must land within this many seconds to extend the spree.
@export var spree_window := 15.0
## Each spree step adds this fraction of kill gold: kill 1 = 100%, kill 2 = 150%…
@export var spree_gold_bonus := 0.5
## Each spree step adds this much gold per second while the spree lasts.
@export var spree_income_step := 20.0
@export var spree_max := 10
## Gold an enemy earns for killing this hero: 500, as in the reference map.
@export var bounty := 500.0
## Risk/reward: a transformed hero is a richer target (spec: 1.5–2× base).
@export var form_bounty_mult := 1.75

const TEAM_COLORS := [Color(0.3, 0.55, 1.0), Color(1.0, 0.32, 0.28)]
const PLAYER_COLOR := Color(1.0, 0.84, 0.4)

const MAX_LEVEL := 50
## Allied heroes within this distance of a kill share its experience.
const XP_RANGE := 12.0
## Warcraft III's default creep XP by creep level (1–10).
const CREEP_XP := [25, 40, 60, 85, 115, 150, 190, 235, 285, 340]
## The reference map's creep XP reduction by hero level (80, 70, 60, then 50%
## for every level after; the stock game gives 0% past level 5).
const CREEP_XP_FACTOR := [0.8, 0.7, 0.6, 0.5]
## Warcraft III's default XP for killing a hero of level 1–5 (+100 per level after).
const HERO_XP := [100, 120, 160, 220, 300]
## How far the attack button looks for a target.
const ACQUIRE_RANGE := 10.0
## Movement is capped at the map's 522/250 of base speed.
const MAX_SPEED_MULT := 2.09
## Movement eases in and out instead of starting and stopping dead; stopping
## is quicker than starting so the stick still feels tight.
const ACCELERATION := 55.0
const DECELERATION := 120.0

## Which hero this is. Set before adding to the tree; its values override the exports above.
var definition: HeroDef
## 0 = blue (the player's side), 1 = red. Neutral units use -1.
var team := 0
## The human-controlled hero reads touch/keyboard; bots set ai_move instead.
var is_player := true
var ai_move := Vector3.ZERO
var kills := 0
var deaths := 0
## Damage totals for the HUD and the results screen.
var damage_dealt := 0.0
var damage_taken := 0.0
## Damage numbers are gathered for a moment and shown (or sent) as one number.
var _numbers_out := 0.0
var _numbers_in := 0.0
var _numbers_at := Vector3.ZERO
var _numbers_clock := 0.0
var _stars: Node3D
var _roots: Node3D
## Inventory (up to ItemCatalog.INVENTORY_SIZE). Stats are recomputed from the
## definition, attributes and every item carried.
var items: Array[ItemDef] = []
## Set by the match each frame: true at the hero's own fountain (shop range).
var in_shop_range := false
var damage_reduction := 0.0
var cooldown_reduction := 0.0
## Skill damage multiplier from intelligence (1% per point gained).
var skill_power := 1.0
var _hot_time := 0.0
var _hot_rate := 0.0
## Network client: this hero only displays the host's state.
var puppet := false
var _haste_time := 0.0
var _haste_mult := 1.0
var _slow_time := 0.0
var _slow_mult := 1.0
var _stun_time := 0.0
var _root_time := 0.0
## Damage over time: [damage per second, seconds left, source hero].
var _dots: Array = []
## Duel: everyone but the duelists is frozen — no actions, no damage taken.
var frozen := false
## Network: the peer controlling this hero (0 = bot or offline).
var owner_peer := 0
var model: Node3D
var animator: HeroAnimator
var skills: Array[Skill] = []

var level := 1
var xp := 0.0
var skill_points := 1
## Multiplier on experience earned (the match sets it: Mobile plays faster).
var xp_rate := 1.0
## Attribute points from tomes (permanent).
var tome_attributes := {"str": 0.0, "agi": 0.0, "int": 0.0}
## Attribute points from items carried (recomputed with stats).
var _item_attributes := {"str": 0.0, "agi": 0.0, "int": 0.0}

var hp := 0.0
var shield := 0.0
var in_form := false
var form_time_left := 0.0
var meter: TransformMeter
var gold := 0.0
var spree := 0
var spree_time_left := 0.0

var _invulnerable_time := 0.0
var _attack_cooldown := 0.0
var _dead_time := 0.0
var _spawn_point := Vector3.ZERO
var _facing := Vector3(0, 0, -1)
var _dash_velocity := Vector3.ZERO
var _dash_time := 0.0
var _bar_pivot: Node3D
var _level_label: Label3D
## Attack button: the enemy this hero chases and hits until it dies or the stick moves.
var _chase_target: Node3D


func _ready() -> void:
	add_to_group("heroes")
	add_to_group("units")
	if definition == null:
		definition = Vael.new()
	_apply_definition()
	_spawn_point = global_position
	hp = max_hp

	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.5
	capsule.height = 2.0
	shape.shape = capsule
	shape.position.y = 1.0
	add_child(shape)
	collision_mask = 1 | Creep.CREEP_LAYER

	model = definition.create_model()
	model.name = "Model"
	if "accent" in model:
		model.accent = TEAM_COLORS[team]
	add_child(model)
	animator = HeroAnimator.new()
	animator.name = "Animator"
	add_child(animator)
	animator.setup(self, model)
	_build_overhead()
	skills = definition.create_skills()

	meter = TransformMeter.new()
	meter.name = "TransformMeter"
	add_child(meter)
	recompute_stats()


func _physics_process(delta: float) -> void:
	# Network clients only read input; the host's snapshots drive everything else.
	if puppet:
		if is_player:
			_poll_actions()
		return
	if _dead_time > 0.0:
		_dead_time -= delta
		if _dead_time <= 0.0:
			_respawn()
		return
	if frozen:
		velocity = Vector3.ZERO
		return

	_invulnerable_time = maxf(_invulnerable_time - delta, 0.0)
	if _hot_time > 0.0:
		_hot_time -= delta
		heal(_hot_rate * delta)
	_haste_time = maxf(_haste_time - delta, 0.0)
	_slow_time = maxf(_slow_time - delta, 0.0)
	_stun_time = maxf(_stun_time - delta, 0.0)
	_root_time = maxf(_root_time - delta, 0.0)
	_tick_dots(delta)
	if not is_alive():
		return
	_tick_form(delta)
	_tick_economy(delta)
	if hp < max_hp:
		hp = minf(hp + hp_regen * delta, max_hp)
		health_changed.emit(hp, max_hp, shield)

	for skill in skills:
		skill.tick(delta)
	_flush_numbers(delta)

	if is_stunned():
		velocity = Vector3.ZERO
		return

	if is_player:
		_poll_actions()

	if _dash_time > 0.0:
		_dash_time -= delta
		velocity = _dash_velocity
		if _dash_time <= 0.0:
			velocity = velocity.limit_length(move_speed)  # a dash ends crisply, no coasting
	elif _root_time > 0.0:
		velocity = Vector3.ZERO
	else:
		var direction := _steering()
		var speed := move_speed * (form_speed_mult if in_form else 1.0) * (_slow_mult if _slow_time > 0.0 else 1.0)
		var wanted := direction * speed
		var rate := ACCELERATION if wanted.length() >= velocity.length() else DECELERATION
		velocity = velocity.move_toward(wanted, rate * delta)
		if direction.length() > 0.1:
			_face(direction)
	move_and_slide()

	_attack_cooldown -= delta
	if _attack_cooldown <= 0.0:
		var target := _attack_target()
		if target:
			_attack(target)
		else:
			_attack_cooldown = 0.1  # nothing in range: look again in 0.1 s, not every tick


func _poll_actions() -> void:
	if Input.is_action_just_pressed("transform"):
		try_transform()
	for i in 4:
		if Input.is_action_just_pressed("skill_%d" % (i + 1)):
			try_skill(i)
	if Input.is_action_just_pressed("attack"):
		order_attack()


func try_transform() -> bool:
	if puppet:
		action_requested.emit("transform", null)
		return false
	if in_form or _dead_time > 0.0 or frozen or is_stunned() or not meter.is_full():
		return false
	meter.consume()
	meter.locked = true
	in_form = true
	_animate("cast")
	vfx("column", [global_position, animator._aura_material.albedo_color if animator and animator._aura_material else Color(1, 0.7, 0.3), 5.0])
	form_time_left = form_duration
	_invulnerable_time = form_transition
	shield = max_hp * form_shield_ratio
	play_sfx("transform")
	if model.has_method("set_form"):
		model.set_form(true, form_scale)
	form_changed.emit(true)
	health_changed.emit(hp, max_hp, shield)
	return true


## Returns {dealt, killed, bounty}. The bounty is read before death ends the form.
func take_damage(amount: float, attacker: Node = null) -> Dictionary:
	if _dead_time > 0.0 or _invulnerable_time > 0.0 or frozen:
		return {"dealt": 0.0, "killed": false, "bounty": 0.0}
	amount *= 1.0 - damage_reduction
	var absorbed := minf(shield, amount)
	shield -= absorbed
	var dealt := minf(hp, amount - absorbed) + absorbed
	hp -= amount - absorbed
	damage_taken += dealt
	_numbers_in += dealt
	meter.on_damage_taken(amount)
	health_changed.emit(hp, max_hp, shield)
	if hp <= 0.0:
		var reward := bounty_value()
		_die(attacker as Hero)
		return {"dealt": dealt, "killed": true, "bounty": reward}
	return {"dealt": dealt, "killed": false, "bounty": 0.0}


## Buys an item; returns "" on success or the reason it failed. Stat-shop tomes
## are used up at once and never take an inventory slot.
func buy(item_id: String) -> String:
	if puppet:
		action_requested.emit("buy", item_id)
		return ""
	var item := ItemCatalog.find(item_id)
	if item == null:
		return "Unknown item"
	if not item.buyable:
		return "Made at the combining circle"
	if item.hero_only != "" and item.hero_only != definition.id:
		return "Only %s can wield this" % item.hero_only.capitalize()
	if not in_shop_range:
		return "Return to your fountain to shop"
	if not item.is_tome() and items.size() >= ItemCatalog.INVENTORY_SIZE:
		return "Inventory full"
	if gold < item.cost:
		return "Not enough gold"
	gold -= item.cost
	if item.is_tome():
		for key in item.tome:
			tome_attributes[key] += item.tome[key]
		if item.xp > 0.0:
			add_xp(item.xp)
		recompute_stats()
		play_sfx("confirm", -4.0)
		skills_changed.emit()
		return ""
	items.append(item)
	recompute_stats()
	items_changed.emit()
	return ""


func sell(index: int) -> bool:
	if puppet:
		action_requested.emit("sell", index)
		return true
	if index < 0 or index >= items.size() or not in_shop_range:
		return false
	gold += floorf(items[index].cost * ItemCatalog.SELL_RATE)
	items.remove_at(index)
	recompute_stats()
	items_changed.emit()
	return true


## Combining circle: fuses the first recipe whose parts are all carried.
## Returns the artifact's id, or "".
func try_combine() -> String:
	for recipe in ItemCatalog.RECIPES:
		var picked: Array[int] = []
		for part_id in recipe[1]:
			for i in items.size():
				if items[i].id == part_id and not picked.has(i):
					picked.append(i)
					break
		if picked.size() != recipe[1].size():
			continue
		picked.sort()
		picked.reverse()
		for i in picked:
			items.remove_at(i)
		items.append(ItemCatalog.find(recipe[0]))
		recompute_stats()
		items_changed.emit()
		play_sfx("transform", -6.0)
		vfx("ring", [global_position, 2.0, Color(1.0, 0.85, 0.4, 0.9)])
		vfx("burst", [global_position, Color(1.0, 0.85, 0.4), 30, 6.0])
		return recipe[0]
	return ""


func has_recipe_ready() -> bool:
	for recipe in ItemCatalog.RECIPES:
		var ids := items.map(func(i): return i.id)
		var complete := true
		for part_id in recipe[1]:
			var at: int = ids.find(part_id)
			if at == -1:
				complete = false
				break
			ids.remove_at(at)
		if complete:
			return true
	return false


## Uses a consumable from the inventory (anywhere on the map).
func use_item(index: int) -> bool:
	if puppet:
		action_requested.emit("use", index)
		return true
	if index < 0 or index >= items.size() or not items[index].consumable or _dead_time > 0.0:
		return false
	var item := items[index]
	match item.use:
		"heal":
			_hot_time = 5.0
			_hot_rate = item.use_amount / 5.0
		"meter":
			if meter.locked or meter.is_full():
				return false
			meter._add(item.use_amount)
	items.remove_at(index)
	recompute_stats()
	items_changed.emit()
	play_sfx("confirm", -6.0)
	return true


# ---------------------------------------------------------------- progression
## Total experience needed to reach `target_level` (Warcraft III default:
## 200 for level 2, then 300, 400… more per level).
static func xp_for_level(target_level: int) -> float:
	return 0.0 if target_level <= 1 else 50.0 * target_level * (target_level + 1) - 100.0


func add_xp(amount: float) -> void:
	if puppet or level >= MAX_LEVEL or amount <= 0.0:
		return
	xp += amount
	var gained_level := false
	while level < MAX_LEVEL and xp >= xp_for_level(level + 1):
		level += 1
		skill_points += 1
		gained_level = true
	if level >= MAX_LEVEL:
		xp = xp_for_level(MAX_LEVEL)
	if gained_level:
		recompute_stats()
		play_sfx("levelup", -2.0)
		vfx("ring", [global_position, 2.2, Color(1.0, 0.9, 0.45, 0.9)])
		vfx("column", [global_position, Color(1.0, 0.88, 0.4), 4.0])
		leveled_up.emit(level)
		skills_changed.emit()


## Progress through the current level, 0..1.
func level_progress() -> float:
	if level >= MAX_LEVEL:
		return 1.0
	var start := xp_for_level(level)
	return clampf((xp - start) / (xp_for_level(level + 1) - start), 0.0, 1.0)


## Total attribute: level-1 value + growth per level + tomes + items.
func attribute(key: String) -> float:
	return definition.base_attribute(key) + definition.attribute_gain(key) * (level - 1) \
			+ tome_attributes.get(key, 0.0) + _item_attributes.get(key, 0.0)


## Points above the level-1 value. Only these change stats, so every hero keeps
## its tuned level-1 numbers.
func attribute_gained(key: String) -> float:
	return attribute(key) - definition.base_attribute(key)


## Spends a skill point on skill `index`.
func learn_skill(index: int) -> bool:
	if puppet:
		action_requested.emit("learn", index)
		return false
	if index < 0 or index >= skills.size() or skill_points <= 0 or not skills[index].can_learn(self):
		return false
	skills[index].rank += 1
	skill_points -= 1
	play_sfx("confirm", -6.0)
	skills_changed.emit()
	return true


func can_learn_any() -> bool:
	return skill_points > 0 and skills.any(func(s): return s.can_learn(self))


## XP for killing a hero of `victim_level`.
static func hero_kill_xp(victim_level: int) -> float:
	if victim_level <= HERO_XP.size():
		return HERO_XP[maxi(victim_level, 1) - 1]
	return HERO_XP[-1] + 100.0 * (victim_level - HERO_XP.size())


## Shares a kill's experience among the killer's allied heroes near `at`,
## split equally (as Warcraft III does). Creep XP is reduced by each hero's level.
func share_kill_xp(at: Vector3, victim_level: int, victim_is_hero: bool) -> void:
	var receivers: Array[Hero] = []
	for node in get_tree().get_nodes_in_group("heroes"):
		var ally := node as Hero
		if ally and ally.team == team and ally.is_alive() and ally.global_position.distance_to(at) <= XP_RANGE:
			receivers.append(ally)
	if not receivers.has(self) and is_alive():
		receivers.append(self)
	if receivers.is_empty():
		return
	var base := hero_kill_xp(victim_level) if victim_is_hero else float(CREEP_XP[clampi(victim_level, 1, CREEP_XP.size()) - 1])
	for ally in receivers:
		var factor: float = 1.0 if victim_is_hero else CREEP_XP_FACTOR[mini(ally.level, CREEP_XP_FACTOR.size()) - 1]
		ally.add_xp(base / receivers.size() * factor * ally.xp_rate)


func recompute_stats() -> void:
	var total := {}
	for item in items:
		for key in item.stats:
			total[key] = total.get(key, 0.0) + item.stats[key]
	for key in _item_attributes:
		_item_attributes[key] = total.get(key, 0.0)
	var strength := attribute_gained("str")
	var agility := attribute_gained("agi")
	var intelligence := attribute_gained("int")
	var old_max := max_hp
	# The reference map's attribute rules: 10 HP and 0.1 HP/s per strength,
	# 2 damage per primary point, 0.5 armour, 2% attack speed and 0.5/250 move
	# speed per agility. Intelligence (mana, unused here) powers skills instead.
	max_hp = definition.max_hp + total.get("hp", 0.0) + 10.0 * strength
	hp_regen = definition.hp_regen + total.get("regen", 0.0) + 0.1 * strength
	attack_damage = definition.attack_damage + total.get("damage", 0.0) + 2.0 * attribute_gained(definition.primary)
	attack_interval = definition.attack_interval / maxf(1.0 + total.get("attack_speed", 0.0) + 0.02 * agility, 0.2)
	move_speed = minf(definition.move_speed * (1.0 + total.get("move_speed", 0.0) + 0.002 * agility), definition.move_speed * MAX_SPEED_MULT)
	var armour := 0.5 * agility
	var armour_reduction := 0.02 * armour / (1.0 + 0.02 * armour)
	damage_reduction = 1.0 - (1.0 - clampf(total.get("armor", 0.0), 0.0, 0.6)) * (1.0 - armour_reduction)
	cooldown_reduction = clampf(total.get("cooldown", 0.0), 0.0, 0.5)
	skill_power = 1.0 + 0.01 * intelligence
	form_duration = definition.form_duration + total.get("form_duration", 0.0)
	if meter:
		meter.gain_multiplier = 1.0 + total.get("meter_gain", 0.0)
	if hp > 0.0 and max_hp > old_max:
		hp += max_hp - old_max
	hp = minf(hp, max_hp)
	if _level_label:
		_level_label.text = str(level)
	health_changed.emit(hp, max_hp, shield)


# -------------------------------------------------------------------- effects
## Attack-speed buff, e.g. apply_haste(1.6, 4.0) = 60% faster attacks for 4 s.
func apply_haste(multiplier: float, duration: float) -> void:
	_haste_mult = multiplier
	_haste_time = duration


## Movement slow, e.g. apply_slow(0.6, 2.0) = 40% slower for 2 s.
func apply_slow(multiplier: float, duration: float) -> void:
	if _slow_time <= 0.0 or multiplier < _slow_mult:
		_slow_mult = multiplier
	_slow_time = maxf(_slow_time, duration)


## Stun: no moving, attacking, casting or transforming.
func apply_stun(duration: float) -> void:
	if is_alive() and not frozen and _invulnerable_time <= 0.0:
		_stun_time = maxf(_stun_time, duration)
		_dash_time = 0.0


## Root: can't move, but can still attack and cast.
func apply_root(duration: float) -> void:
	if is_alive() and not frozen:
		_root_time = maxf(_root_time, duration)


## Stun stars and root spikes, on every device (clients learn stuns from snapshots).
func _process(delta: float) -> void:
	if _stun_time > 0.0 and _stars == null:
		_stars = UnitFx.stun_stars(self, 2.7)
	if _stars:
		_stars.visible = _stun_time > 0.0 and visible
		_stars.rotation.y += delta * 5.0
	if _root_time > 0.0 and _roots == null:
		_roots = UnitFx.root_spikes(self)
	if _roots:
		_roots.visible = _root_time > 0.0 and visible


func apply_dot(dps: float, duration: float, source: Hero) -> void:
	if is_alive() and not frozen:
		_dots.append([dps, duration, source])


func make_invulnerable(duration: float) -> void:
	_invulnerable_time = maxf(_invulnerable_time, duration)


func is_hasted() -> bool:
	return _haste_time > 0.0


func is_slowed() -> bool:
	return _slow_time > 0.0


func is_stunned() -> bool:
	return _stun_time > 0.0


func is_rooted() -> bool:
	return _root_time > 0.0


func heal(amount: float) -> void:
	if _dead_time > 0.0 or hp >= max_hp:
		return
	hp = minf(hp + amount, max_hp)
	health_changed.emit(hp, max_hp, shield)


## Enemies are units on another team; neutral units (team -1) are fair game for all.
func is_hostile(unit: Node) -> bool:
	return unit != self and "team" in unit and unit.team != team


## Plays a sound at full volume for the player's own hero, quieter for others.
## The Sfx autoload is looked up at call time: test scripts compile Hero before
## autoloads exist, so naming it directly would fail there.
func play_sfx(sound: String, volume_db := 0.0) -> void:
	fx.emit("sfx", [sound, volume_db])
	var sfx := get_node_or_null("/root/Sfx")
	if sfx:
		sfx.play(sound, volume_db + (0.0 if is_player else -9.0), randf_range(0.95, 1.05))


func is_alive() -> bool:
	return _dead_time <= 0.0


func try_skill(index: int) -> bool:
	if puppet:
		action_requested.emit("skill", index)
		return false
	if _dead_time > 0.0 or frozen or is_stunned() or index >= skills.size():
		return false
	var cast := skills[index].try_cast(self)
	if cast:
		_animate("cast")
	return cast


## Plays an animation here and on network clients.
func _animate(kind: String) -> void:
	if animator:
		animator.play(kind)
	fx.emit("anim", [kind])


## Plays a one-shot effect (see UnitFx.play) here and on network clients.
func vfx(kind: String, data: Array) -> void:
	UnitFx.play(get_parent(), kind, data)
	fx.emit("vfx", [kind, data])


## Attack button: lock onto the nearest enemy (heroes first) and chase it.
func order_attack() -> void:
	if puppet:
		action_requested.emit("attack", null)
		return
	_chase_target = Skill.nearest_hostile(self, ACQUIRE_RANGE)


## Deals damage with the form multiplier, charging the meter and paying out
## kills: the victim's bounty for heroes (with spree), a creep's own bounty,
## kill gold for training dummies — plus shared experience for every kill.
## Used by auto-attacks and skills alike.
func deal_damage(target: Node3D, amount: float) -> void:
	var result: Dictionary = target.take_damage(amount * (form_damage_mult if in_form else 1.0), self)
	meter.on_damage_dealt(result.dealt)
	damage_dealt += result.dealt
	if result.dealt > 0.0:
		_numbers_out += result.dealt
		_numbers_at = target.global_position
	if not result.killed:
		return
	meter.on_kill()
	if target is Hero:
		kills += 1
		_register_kill(result.bounty)
		share_kill_xp(target.global_position, target.level, true)
	elif "bounty" in target:
		gold += target.bounty
		gold_changed.emit(gold, income_per_second(), spree)
		share_kill_xp(target.global_position, target.level, target.is_boss)
	else:
		_register_kill(kill_gold)
		share_kill_xp(target.global_position, 1, false)


## Every 0.15 s: one number for the damage dealt and one for damage taken.
## The local player's hero shows them; the host also sends them to the owner.
func _flush_numbers(delta: float) -> void:
	_numbers_clock += delta
	if _numbers_clock < 0.15:
		return
	_numbers_clock = 0.0
	if _numbers_out >= 1.0:
		fx.emit("dmg", [_numbers_at, _numbers_out])
		if is_player:
			FloatText.spawn(get_parent(), _numbers_at, _numbers_out, FloatText.DEALT, _numbers_out >= 150.0)
	if _numbers_in >= 1.0:
		fx.emit("hurt", [_numbers_in])
		if is_player:
			FloatText.spawn(get_parent(), global_position, _numbers_in, FloatText.TAKEN)
	_numbers_out = 0.0
	_numbers_in = 0.0


## Direction skills aim in: the stick if held, otherwise where the hero faces.
func aim_direction() -> Vector3:
	var direction := _move_input()
	return direction.normalized() if direction.length() > 0.1 else _facing


func start_dash(dash_velocity: Vector3, duration: float) -> void:
	_dash_velocity = dash_velocity
	_dash_time = duration
	_face(dash_velocity)


func _move_input() -> Vector3:
	if not is_player:
		return ai_move
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return Vector3(input.x, 0.0, input.y)


## The stick wins; with the stick idle, an attack order walks the hero to its target.
func _steering() -> Vector3:
	var direction := _move_input()
	if direction.length() > 0.1:
		_chase_target = null
		return direction
	if _chase_target and (not is_instance_valid(_chase_target) or not _chase_target.is_alive()
			or global_position.distance_to(_chase_target.global_position) > ACQUIRE_RANGE * 1.5):
		_chase_target = null
	if _chase_target:
		var offset := _chase_target.global_position - global_position
		offset.y = 0.0
		if offset.length() > attack_range * 0.85:
			return offset.normalized()
	return Vector3.ZERO


## Turns the model to face a direction (the model's forward is −Z); the
## animator eases it round.
func _face(direction: Vector3) -> void:
	if Vector2(direction.x, direction.z).length() < 0.001:
		return
	_facing = Vector3(direction.x, 0.0, direction.z).normalized()
	var yaw := atan2(-_facing.x, -_facing.z)
	if animator:
		animator.target_yaw = yaw
	else:
		model.rotation.y = yaw


func _apply_definition() -> void:
	max_hp = definition.max_hp
	hp_regen = definition.hp_regen
	move_speed = definition.move_speed
	attack_damage = definition.attack_damage
	attack_interval = definition.attack_interval
	attack_range = definition.attack_range
	form_duration = definition.form_duration
	form_shield_ratio = definition.form_shield_ratio
	form_damage_mult = definition.form_damage_mult
	form_speed_mult = definition.form_speed_mult
	form_scale = definition.form_scale


func bounty_value() -> float:
	return bounty * (form_bounty_mult if in_form else 1.0)


func income_per_second() -> float:
	return base_income + spree_income_step * maxi(spree - 1, 0)


func _register_kill(base_gold: float) -> void:
	spree = mini(spree + 1, spree_max) if spree_time_left > 0.0 else 1
	spree_time_left = spree_window
	gold += base_gold * (1.0 + spree_gold_bonus * (spree - 1))
	gold_changed.emit(gold, income_per_second(), spree)


func _end_spree() -> void:
	spree = 0
	spree_time_left = 0.0
	gold_changed.emit(gold, income_per_second(), spree)


func _tick_economy(delta: float) -> void:
	gold += income_per_second() * delta
	if spree_time_left > 0.0:
		spree_time_left -= delta
		if spree_time_left <= 0.0:
			_end_spree()


func _tick_dots(delta: float) -> void:
	for i in range(_dots.size() - 1, -1, -1):
		var dot: Array = _dots[i]
		dot[1] -= delta
		if dot[1] <= 0.0:
			_dots.remove_at(i)
		var source = dot[2]
		if is_instance_valid(source) and source is Hero:
			source.deal_damage(self, dot[0] * delta)
		else:
			take_damage(dot[0] * delta)
		if not is_alive():
			_dots.clear()
			return


func _tick_form(delta: float) -> void:
	if not in_form:
		return
	form_time_left -= delta
	if form_time_left <= 0.0:
		_end_form()


func _end_form() -> void:
	in_form = false
	form_time_left = 0.0
	shield = 0.0
	meter.locked = false
	if model.has_method("set_form"):
		model.set_form(false, form_scale)
	form_changed.emit(false)
	health_changed.emit(hp, max_hp, shield)


func _attack(target: Node3D) -> void:
	_attack_cooldown = attack_interval / (_haste_mult if _haste_time > 0.0 else 1.0)
	_face(target.global_position - global_position)
	_animate("attack")
	deal_damage(target, attack_damage)
	if is_player:
		play_sfx("hit", -10.0)


## The attack order's target when it's in range, otherwise the nearest enemy.
func _attack_target() -> Node3D:
	if _chase_target and is_instance_valid(_chase_target) and _chase_target.is_alive() \
			and global_position.distance_to(_chase_target.global_position) <= attack_range:
		return _chase_target
	return _nearest_enemy()


func _nearest_enemy() -> Node3D:
	var best: Node3D = null
	var best_dist := attack_range
	for node in get_tree().get_nodes_in_group("units"):
		if is_hostile(node) and node.is_alive():
			var dist := global_position.distance_to(node.global_position)
			if dist <= best_dist:
				best = node
				best_dist = dist
	return best


## Team ring at the feet (gold for the player), a health bar and the level overhead,
## tilted to face the top-down camera.
func _build_overhead() -> void:
	var color: Color = PLAYER_COLOR if is_player else TEAM_COLORS[team]
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.6
	torus.outer_radius = 0.74
	torus.rings = 32
	torus.ring_segments = 4
	ring.mesh = torus
	ring.position.y = 0.04
	ring.scale = Vector3(1, 0.15, 1)
	ring.material_override = _flat(color)
	add_child(ring)

	var bar := Node3D.new()
	bar.position.y = 3.1
	bar.rotation_degrees.x = -54.0
	add_child(bar)
	var back := MeshInstance3D.new()
	back.mesh = _quad(Vector2(1.3, 0.16))
	back.material_override = _flat(Color(0.05, 0.05, 0.05, 0.85))
	bar.add_child(back)
	_bar_pivot = Node3D.new()
	_bar_pivot.position = Vector3(-0.62, 0, 0.005)
	bar.add_child(_bar_pivot)
	var fill := MeshInstance3D.new()
	fill.mesh = _quad(Vector2(1.24, 0.1))
	fill.position.x = 0.62
	fill.material_override = _flat(color)
	_bar_pivot.add_child(fill)
	_level_label = Label3D.new()
	_level_label.text = "1"
	_level_label.font_size = 40
	_level_label.outline_size = 10
	_level_label.no_depth_test = true
	_level_label.position = Vector3(-0.85, 0, 0.01)
	_level_label.modulate = color.lightened(0.3)
	bar.add_child(_level_label)
	health_changed.connect(_on_bar_health)


func _on_bar_health(value: float, maximum: float, _shield: float) -> void:
	_bar_pivot.scale.x = clampf(value / maximum, 0.001, 1.0)


static func _flat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true
	material.render_priority = 1
	return material


static func _quad(size: Vector2) -> QuadMesh:
	var mesh := QuadMesh.new()
	mesh.size = size
	return mesh


func _die(killer: Hero = null) -> void:
	hp = 0.0
	deaths += 1
	if in_form:
		_end_form()
	_end_spree()
	_dash_time = 0.0
	_stun_time = 0.0
	_root_time = 0.0
	_dots.clear()
	_chase_target = null
	_dead_time = respawn_time
	velocity = Vector3.ZERO
	if animator:
		animator.die()  # topples, then hides the hero
	else:
		visible = false
	died.emit(killer)


func _respawn() -> void:
	hp = max_hp
	shield = 0.0
	global_position = _spawn_point
	if animator:
		animator.respawn()
	else:
		visible = true
	health_changed.emit(hp, max_hp, shield)


## Brings a dead hero back at once (the duel revives everyone before it starts).
func revive_now() -> void:
	if _dead_time > 0.0:
		_dead_time = 0.0
		_respawn()
