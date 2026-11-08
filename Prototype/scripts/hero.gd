class_name Hero
extends CharacterBody3D
## Player hero: moves, auto-attacks the nearest enemy in range, casts its
## skills, and transforms into a timed form when its meter is full. Identity,
## stats, model and skills come from a HeroDef (default: Vael).

signal health_changed(hp: float, max_hp: float, shield: float)
signal form_changed(active: bool)
signal gold_changed(gold: float, income: float, spree: int)
## killer is the Hero that landed the killing blow, or null.
signal died(killer: Hero)
signal items_changed

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
@export var base_income := 2.0
@export var kill_gold := 100.0
## The next kill must land within this many seconds to extend the spree.
@export var spree_window := 15.0
## Each spree step adds this fraction of kill gold: kill 1 = 100, kill 2 = 150, kill 3 = 200…
@export var spree_gold_bonus := 0.5
## Each spree step adds this much gold per second while the spree lasts.
@export var spree_income_step := 2.0
@export var spree_max := 10
## Gold an enemy earns for killing this hero (placeholder until enemy heroes exist).
@export var bounty := 300.0
## Risk/reward: a transformed hero is a richer target (spec: 1.5–2× base).
@export var form_bounty_mult := 1.75

const TEAM_COLORS := [Color(0.3, 0.55, 1.0), Color(1.0, 0.32, 0.28)]
const PLAYER_COLOR := Color(1.0, 0.84, 0.4)

## Which hero this is. Set before adding to the tree; its values override the exports above.
var definition: HeroDef
## 0 = blue (the player's side), 1 = red. Neutral units use -1.
var team := 0
## The human-controlled hero reads touch/keyboard; bots set ai_move instead.
var is_player := true
var ai_move := Vector3.ZERO
var kills := 0
var deaths := 0
## Inventory (up to ItemCatalog.INVENTORY_SIZE). Stats are recomputed from the
## definition plus every item carried.
var items: Array[ItemDef] = []
## Set by the match each frame: true at the hero's own fountain (shop range).
var in_shop_range := false
var damage_reduction := 0.0
var cooldown_reduction := 0.0
var _hot_time := 0.0
var _hot_rate := 0.0
var model: Node3D
var skills: Array[Skill] = []

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

	model = definition.create_model()
	model.name = "Model"
	if "accent" in model:
		model.accent = TEAM_COLORS[team]
	add_child(model)
	_build_overhead()
	skills = definition.create_skills()

	meter = TransformMeter.new()
	meter.name = "TransformMeter"
	add_child(meter)
	recompute_stats()


func _physics_process(delta: float) -> void:
	if _dead_time > 0.0:
		_dead_time -= delta
		if _dead_time <= 0.0:
			_respawn()
		return

	_invulnerable_time = maxf(_invulnerable_time - delta, 0.0)
	if _hot_time > 0.0:
		_hot_time -= delta
		heal(_hot_rate * delta)
	_tick_form(delta)
	_tick_economy(delta)
	if hp < max_hp:
		hp = minf(hp + hp_regen * delta, max_hp)
		health_changed.emit(hp, max_hp, shield)

	for skill in skills:
		skill.tick(delta)

	if is_player:
		if Input.is_action_just_pressed("transform"):
			try_transform()
		if Input.is_action_just_pressed("skill_1"):
			try_skill(0)
		if Input.is_action_just_pressed("skill_2"):
			try_skill(1)

	if _dash_time > 0.0:
		_dash_time -= delta
		velocity = _dash_velocity
	else:
		var direction := _move_input()
		var speed := move_speed * (form_speed_mult if in_form else 1.0)
		velocity = direction * speed
		if direction.length() > 0.1:
			_face(direction)
	move_and_slide()

	_attack_cooldown -= delta
	if _attack_cooldown <= 0.0:
		var target := _nearest_enemy()
		if target:
			_attack(target)


func try_transform() -> bool:
	if in_form or _dead_time > 0.0 or not meter.is_full():
		return false
	meter.consume()
	meter.locked = true
	in_form = true
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
func take_damage(amount: float, attacker: Hero = null) -> Dictionary:
	if _dead_time > 0.0 or _invulnerable_time > 0.0:
		return {"dealt": 0.0, "killed": false, "bounty": 0.0}
	amount *= 1.0 - damage_reduction
	var absorbed := minf(shield, amount)
	shield -= absorbed
	var dealt := minf(hp, amount - absorbed) + absorbed
	hp -= amount - absorbed
	meter.on_damage_taken(amount)
	health_changed.emit(hp, max_hp, shield)
	if hp <= 0.0:
		var reward := bounty_value()
		_die(attacker)
		return {"dealt": dealt, "killed": true, "bounty": reward}
	return {"dealt": dealt, "killed": false, "bounty": 0.0}


## Buys an item; returns "" on success or the reason it failed.
func buy(item_id: String) -> String:
	var item := ItemCatalog.find(item_id)
	if item == null:
		return "Unknown item"
	if not in_shop_range:
		return "Return to your fountain to shop"
	if items.size() >= ItemCatalog.INVENTORY_SIZE:
		return "Inventory full"
	if gold < item.cost:
		return "Not enough gold"
	gold -= item.cost
	items.append(item)
	recompute_stats()
	items_changed.emit()
	return ""


func sell(index: int) -> bool:
	if index < 0 or index >= items.size() or not in_shop_range:
		return false
	gold += floorf(items[index].cost * ItemCatalog.SELL_RATE)
	items.remove_at(index)
	recompute_stats()
	items_changed.emit()
	return true


## Uses a consumable from the inventory (anywhere on the map).
func use_item(index: int) -> bool:
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


func recompute_stats() -> void:
	var total := {}
	for item in items:
		for key in item.stats:
			total[key] = total.get(key, 0.0) + item.stats[key]
	var old_max := max_hp
	max_hp = definition.max_hp + total.get("hp", 0.0)
	attack_damage = definition.attack_damage + total.get("damage", 0.0)
	attack_interval = definition.attack_interval / (1.0 + total.get("attack_speed", 0.0))
	move_speed = definition.move_speed * (1.0 + total.get("move_speed", 0.0))
	hp_regen = definition.hp_regen + total.get("regen", 0.0)
	damage_reduction = clampf(total.get("armor", 0.0), 0.0, 0.6)
	cooldown_reduction = clampf(total.get("cooldown", 0.0), 0.0, 0.5)
	form_duration = definition.form_duration + total.get("form_duration", 0.0)
	if meter:
		meter.gain_multiplier = 1.0 + total.get("meter_gain", 0.0)
	if hp > 0.0 and max_hp > old_max:
		hp += max_hp - old_max
	hp = minf(hp, max_hp)
	health_changed.emit(hp, max_hp, shield)


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
	var sfx := get_node_or_null("/root/Sfx")
	if sfx:
		sfx.play(sound, volume_db + (0.0 if is_player else -9.0), randf_range(0.95, 1.05))


func is_alive() -> bool:
	return _dead_time <= 0.0


func try_skill(index: int) -> bool:
	if _dead_time > 0.0 or index >= skills.size():
		return false
	return skills[index].try_cast(self)


## Deals damage with the form multiplier, charging the meter and paying out
## kills: kill gold for neutral units, the victim's bounty for heroes.
## Used by auto-attacks and skills alike.
func deal_damage(target: Node3D, amount: float) -> void:
	var result: Dictionary = target.take_damage(amount * (form_damage_mult if in_form else 1.0), self)
	meter.on_damage_dealt(result.dealt)
	if result.killed:
		meter.on_kill()
		if target is Hero:
			kills += 1
			_register_kill(result.bounty)
		else:
			_register_kill(kill_gold)


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


## Turns the model to face a direction (the model's forward is −Z).
func _face(direction: Vector3) -> void:
	_facing = Vector3(direction.x, 0.0, direction.z).normalized()
	model.rotation.y = atan2(-_facing.x, -_facing.z)


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
	_attack_cooldown = attack_interval
	deal_damage(target, attack_damage)
	if is_player:
		play_sfx("hit", -10.0)


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


## Team ring at the feet (gold for the player) and a health bar overhead,
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
	_dead_time = respawn_time
	visible = false
	died.emit(killer)


func _respawn() -> void:
	hp = max_hp
	shield = 0.0
	global_position = _spawn_point
	visible = true
	health_changed.emit(hp, max_hp, shield)
