class_name Hero
extends CharacterBody3D
## Player hero: moves, auto-attacks the nearest enemy in range,
## and transforms into a timed form when its meter is full.

signal health_changed(hp: float, max_hp: float, shield: float)
signal form_changed(active: bool)
signal gold_changed(gold: float, income: float, spree: int)
signal died

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

const NORMAL_COLOR := Color(0.35, 0.55, 0.95)
const FORM_COLOR := Color(1.0, 0.75, 0.2)

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
var _material := StandardMaterial3D.new()
var _body: MeshInstance3D


func _ready() -> void:
	add_to_group("heroes")
	_spawn_point = global_position
	hp = max_hp

	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.5
	capsule.height = 2.0
	shape.shape = capsule
	shape.position.y = 1.0
	add_child(shape)

	_body = MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.5
	mesh.height = 2.0
	_body.mesh = mesh
	_body.position.y = 1.0
	_material.albedo_color = NORMAL_COLOR
	_body.material_override = _material
	add_child(_body)

	meter = TransformMeter.new()
	meter.name = "TransformMeter"
	add_child(meter)


func _physics_process(delta: float) -> void:
	if _dead_time > 0.0:
		_dead_time -= delta
		if _dead_time <= 0.0:
			_respawn()
		return

	_invulnerable_time = maxf(_invulnerable_time - delta, 0.0)
	_tick_form(delta)
	_tick_economy(delta)
	if hp < max_hp:
		hp = minf(hp + hp_regen * delta, max_hp)
		health_changed.emit(hp, max_hp, shield)

	if Input.is_action_just_pressed("transform"):
		try_transform()

	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed := move_speed * (form_speed_mult if in_form else 1.0)
	velocity = Vector3(input.x, 0.0, input.y) * speed
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
	_material.albedo_color = FORM_COLOR
	_body.scale = Vector3.ONE * form_scale
	form_changed.emit(true)
	health_changed.emit(hp, max_hp, shield)
	return true


func take_damage(amount: float) -> void:
	if _dead_time > 0.0 or _invulnerable_time > 0.0:
		return
	var absorbed := minf(shield, amount)
	shield -= absorbed
	hp -= amount - absorbed
	meter.on_damage_taken(amount)
	health_changed.emit(hp, max_hp, shield)
	if hp <= 0.0:
		_die()


func is_alive() -> bool:
	return _dead_time <= 0.0


func bounty_value() -> float:
	return bounty * (form_bounty_mult if in_form else 1.0)


func income_per_second() -> float:
	return base_income + spree_income_step * maxi(spree - 1, 0)


func _register_kill() -> void:
	spree = mini(spree + 1, spree_max) if spree_time_left > 0.0 else 1
	spree_time_left = spree_window
	gold += kill_gold * (1.0 + spree_gold_bonus * (spree - 1))
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
	_material.albedo_color = NORMAL_COLOR
	_body.scale = Vector3.ONE
	form_changed.emit(false)
	health_changed.emit(hp, max_hp, shield)


func _attack(target: Dummy) -> void:
	_attack_cooldown = attack_interval
	var damage := attack_damage * (form_damage_mult if in_form else 1.0)
	var result := target.take_damage(damage)
	meter.on_damage_dealt(result.dealt)
	if result.killed:
		meter.on_kill()
		_register_kill()


func _nearest_enemy() -> Dummy:
	var best: Dummy = null
	var best_dist := attack_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Dummy
		if enemy and enemy.is_alive():
			var dist := global_position.distance_to(enemy.global_position)
			if dist <= best_dist:
				best = enemy
				best_dist = dist
	return best


func _die() -> void:
	hp = 0.0
	if in_form:
		_end_form()
	_end_spree()
	_dead_time = respawn_time
	visible = false
	died.emit()


func _respawn() -> void:
	hp = max_hp
	shield = 0.0
	global_position = _spawn_point
	visible = true
	health_changed.emit(hp, max_hp, shield)
