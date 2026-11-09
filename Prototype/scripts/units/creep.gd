class_name Creep
extends CharacterBody3D
## A non-hero unit: wave creep, boss, the win boss, or a hero's summon.
## Creeps guard their camp: they attack heroes who come close or hit them,
## chase up to a leash, then walk home. Summons fight for their hero's team.
## A physics body, like a Warcraft III unit: creeps block heroes and each other,
## so unfarmed camps pile up. Idle creeps don't move the physics at all, and
## look for targets only 4×/s, so big piles stay cheap. Movement and attacks
## are animated (walk bob and lean, lunge, hit punch, tip-over death).
## On network clients a creep is a `puppet` the host's snapshots move.

signal died(killer: Hero)

const ACQUIRE_RANGE := 5.0
const LEASH := 9.0

## Physics layers: 1 = world and heroes, 3 = creeps and summons.
const CREEP_LAYER := 4

## Neutral creeps are team -1; summons take their hero's team.
var team := -1
var key := ""
var display_name := ""
var level := 1
var max_hp := 100.0
var hp := 100.0
var damage := 10.0
var attack_interval := 1.5
var attack_range := 1.8
var move_speed := 3.6
var bounty := 0
## Bosses give hero-kill experience; the colossus ends the match.
var is_boss := false
var is_colossus := false
var home := Vector3.ZERO
## [radius, damage, cooldown, stun]: bosses slam heroes around them.
var slam: Array = []
var lifetime := 0.0
var owner_hero: Hero
var puppet := false
var frozen := false
var net_id := 0

var _target: Node3D
var _net_target := Vector3.INF
var _cooldown := 0.0
var _scan := 0.0
var _slam_cooldown := 4.0
var _stun_time := 0.0
var _root_time := 0.0
var _dots: Array = []
var _dead := false
var _bar: Node3D
var _bar_fill: Node3D
var _body: Node3D
var _size := 1.0
## Animation state (visual only, runs on every device).
var _last_pos := Vector3.ZERO
var _speed := 0.0
var _walk_phase := 0.0
var _lunge := 0.0
var _punch := 0.0
var _stars: Node3D
## Sleeping: a camp creep at home, healthy and without a target turns its
## physics off; MapEvents wakes its camp when a hero comes near, and any hit,
## stun, root or bleed wakes it at once. Bosses just think 4×/s while idle.
var _idle_clock := 0.0
## The camp this creep belongs to (-1: bosses and summons).
var camp := -1

static var _mesh_cache := {}
static var _material_cache := {}
static var _next_id := 1


## Builds a unit from its key (see CreepTypes.lookup).
static func create(unit_key: String) -> Creep:
	var unit := Creep.new()
	unit.configure(unit_key)
	unit.net_id = _next_id
	_next_id += 1
	return unit


## A hero's summon, with stats scaled by `power` (its skill rank).
static func summon(hero: Hero, kind: String, at: Vector3, duration: float, power: float) -> Creep:
	var unit := create("summon:" + kind)
	unit.team = hero.team
	unit.owner_hero = hero
	unit.lifetime = duration
	unit.max_hp *= power
	unit.hp = unit.max_hp
	unit.damage *= power
	unit.add_to_group("summons")
	hero.get_parent().add_child(unit)
	unit.global_position = at
	unit.home = at
	return unit


func configure(unit_key: String) -> void:
	key = unit_key
	var info := CreepTypes.lookup(unit_key)
	display_name = info.name
	level = info.level
	max_hp = info.hp
	hp = max_hp
	damage = info.damage
	attack_interval = info.interval
	attack_range = info.range
	bounty = info.bounty
	slam = info.get("slam", [])
	is_boss = unit_key.begins_with("boss:") or unit_key == "colossus"
	is_colossus = unit_key == "colossus"
	if is_boss:
		move_speed = 3.2


func _ready() -> void:
	add_to_group("units")
	add_to_group("creeps")
	if home == Vector3.ZERO:
		home = global_position
	_size = CreepTypes.lookup(key).size
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38 * _size
	capsule.height = maxf(1.6 * _size, capsule.radius * 2.0 + 0.1)
	shape.shape = capsule
	shape.position.y = capsule.height / 2.0
	add_child(shape)
	# Puppets on clients are moved by snapshots, so they stay out of the physics.
	collision_layer = 0 if puppet else CREEP_LAYER
	collision_mask = 0 if puppet else 1 | CREEP_LAYER
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	_last_pos = global_position
	_idle_clock = randf() * 0.25  # spread sleeping creeps' thinking across frames
	_build_visual()
	# Only creeps on screen run their animation.
	var notifier := VisibleOnScreenNotifier3D.new()
	notifier.aabb = AABB(Vector3(-1, 0, -1) * _size, Vector3(2, 3, 2) * _size)
	notifier.screen_entered.connect(func(): set_process(true))
	notifier.screen_exited.connect(func(): set_process(false))
	add_child(notifier)
	set_process(false)


func _physics_process(delta: float) -> void:
	if puppet:
		if _net_target != Vector3.INF and not _dead:
			global_position = global_position.lerp(_net_target, minf(delta * 6.0, 1.0))
		return
	if _dead or frozen:
		return
	_idle_clock += delta
	if _is_sleeping():
		if camp >= 0:
			set_physics_process(false)  # MapEvents wakes the camp when a hero comes near
			return
		if _idle_clock < 0.25:
			return
		delta = _idle_clock
	_idle_clock = 0.0
	if lifetime > 0.0:
		lifetime -= delta
		if lifetime <= 0.0 or not is_instance_valid(owner_hero):
			_die(null)  # summons fade when time runs out or their hero is gone
			return
	_stun_time = maxf(_stun_time - delta, 0.0)
	_root_time = maxf(_root_time - delta, 0.0)
	_tick_dots(delta)
	if _dead or _stun_time > 0.0:
		return
	_cooldown -= delta
	_slam_cooldown -= delta
	_scan -= delta
	_think()
	if not slam.is_empty() and _slam_cooldown <= 0.0:
		_try_slam()
	if _target == null:
		# Back home and recover, as creeps do when they lose their target.
		var offset := home - global_position
		offset.y = 0.0
		if offset.length() > 0.4:
			_step(offset, delta)
		elif hp < max_hp and owner_hero == null:
			heal(max_hp * 0.1 * delta)
		return
	var to_target := _target.global_position - global_position
	to_target.y = 0.0
	if to_target.length() > attack_range:
		_step(to_target, delta)
	elif _cooldown <= 0.0:
		_cooldown = attack_interval
		_hit(_target)


func _is_sleeping() -> bool:
	if _target != null or owner_hero != null or not _dots.is_empty() or _stun_time > 0.0 or hp < max_hp:
		return false
	return Vector2(home.x - global_position.x, home.z - global_position.z).length() <= 0.4


## Picks or drops a target. Creeps keep to their leash; summons hunt near their hero.
func _think() -> void:
	if _target and (not is_instance_valid(_target) or not _target.is_alive() or not is_hostile(_target)):
		_target = null
	if owner_hero == null and _target and home.distance_to(_target.global_position) > LEASH:
		_target = null
		return
	if _target or _scan > 0.0:
		return
	_scan = 0.25  # idle units look around 4×/s, not every physics tick
	var range_ := 9.0 if owner_hero else ACQUIRE_RANGE
	var best := range_
	# Neutral units only ever fight heroes and summons, so they scan just those
	# (a handful) instead of every unit on the map.
	var candidates: Array[Node]
	if owner_hero:
		candidates = get_tree().get_nodes_in_group("units")
	else:
		candidates = get_tree().get_nodes_in_group("heroes") + get_tree().get_nodes_in_group("summons")
	for node in candidates:
		if is_hostile(node) and node.is_alive():
			var d := global_position.distance_to(node.global_position)
			if d < best:
				best = d
				_target = node


func _step(offset: Vector3, _delta: float) -> void:
	if _root_time > 0.0:
		return
	var direction := offset.normalized()
	velocity = direction * move_speed
	move_and_slide()
	global_position.y = 0.0
	_turn_toward(direction)


func _turn_toward(direction: Vector3) -> void:
	if _body and Vector2(direction.x, direction.z).length() > 0.01:
		_body.rotation.y = lerp_angle(_body.rotation.y, atan2(-direction.x, -direction.z), 0.35)


## Visual animation from how the unit actually moved, so it works for puppets too.
func _process(delta: float) -> void:
	if _body == null or _dead:
		return
	var moved := global_position - _last_pos
	moved.y = 0.0
	_last_pos = global_position
	_speed = lerpf(_speed, moved.length() / maxf(delta, 0.0001), minf(delta * 10.0, 1.0))
	var walking := _speed > 0.4 and not frozen
	if walking:
		_walk_phase += delta * (6.0 + _speed * 1.5) / _size
	_lunge = maxf(_lunge - delta * 5.0, 0.0)
	_punch = maxf(_punch - delta * 6.0, 0.0)
	var bob := absf(sin(_walk_phase)) * 0.12 * _size if walking else sin(Time.get_ticks_msec() * 0.003 + net_id) * 0.02 * _size
	var lunge := sin(_lunge * PI)  # 0 → 1 → 0 over the lunge
	_body.position = Vector3(0, bob, 0) + Vector3(0, 0, -0.35 * _size * lunge).rotated(Vector3.UP, _body.rotation.y)
	_body.rotation.x = (-0.12 if walking else 0.0) - 0.35 * lunge
	_body.rotation.z = sin(_walk_phase) * 0.06 if walking else 0.0
	_body.scale = Vector3.ONE * (1.0 + 0.12 * _punch)
	if _stars:
		_stars.visible = _stun_time > 0.0
		if _stars.visible:
			_stars.rotation.y += delta * 5.0


func _hit(target: Node3D) -> void:
	_turn_toward(target.global_position - global_position)
	_lunge = 1.0
	if owner_hero and is_instance_valid(owner_hero):
		owner_hero.deal_damage(target, damage)  # the hero gets the kill and the gold
	else:
		target.take_damage(damage, self)


func _try_slam() -> void:
	var radius: float = slam[0]
	var hit := false
	for node in get_tree().get_nodes_in_group("units"):
		if is_hostile(node) and node.is_alive() and global_position.distance_to(node.global_position) <= radius:
			if node is Hero or node.is_in_group("summons"):
				node.take_damage(slam[1], self)
				if node.has_method("apply_stun"):
					node.apply_stun(slam[3])
				hit = true
	if hit:
		_slam_cooldown = slam[2]
		Effects.ring(get_parent(), global_position, radius, Color(0.85, 0.6, 1.0, 0.85))


func is_hostile(unit: Node) -> bool:
	return unit != self and "team" in unit and unit.team != team


func is_alive() -> bool:
	return not _dead


## Returns {dealt, killed, bounty}. Being hit makes a creep turn on its attacker.
func wake() -> void:
	if not puppet and not _dead:
		set_physics_process(true)


func take_damage(amount: float, attacker: Node = null) -> Dictionary:
	wake()
	if _dead or frozen:
		return {"dealt": 0.0, "killed": false, "bounty": 0.0}
	var dealt := minf(amount, hp)
	hp -= dealt
	_punch = 1.0
	_update_bar()
	if attacker and is_instance_valid(attacker) and attacker is Node3D and is_hostile(attacker) and _target == null:
		_target = attacker
	if hp <= 0.0:
		_die(attacker as Hero)
		return {"dealt": dealt, "killed": true, "bounty": float(bounty)}
	return {"dealt": dealt, "killed": false, "bounty": 0.0}


func heal(amount: float) -> void:
	hp = minf(hp + amount, max_hp)
	_update_bar()


func apply_stun(duration: float) -> void:
	wake()
	if not _dead and not is_colossus:
		_stun_time = maxf(_stun_time, duration)
		if _stars == null:
			_stars = UnitFx.stun_stars(self, 2.4 * _size)


func apply_root(duration: float) -> void:
	wake()
	if not _dead and not is_colossus:
		_root_time = maxf(_root_time, duration)


func apply_dot(dps: float, duration: float, source: Hero) -> void:
	wake()
	if not _dead:
		_dots.append([dps, duration, source])


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
		if _dead:
			return


func _die(killer: Hero) -> void:
	if _dead:
		return
	_dead = true
	hp = 0.0
	died.emit(killer)
	_vanish()


## Network clients: show the host's state.
func apply_snapshot(x: float, z: float, new_hp: float, new_max: float) -> void:
	var target := Vector3(x, 0.0, z)
	if global_position.distance_to(target) > 0.05 and _body:
		var offset := target - global_position
		_body.rotation.y = atan2(-offset.x, -offset.z)
	if global_position.distance_to(target) > 6.0:
		global_position = target
	_net_target = target
	max_hp = new_max
	if not is_equal_approx(hp, new_hp):
		if new_hp < hp:
			_punch = 1.0
		hp = new_hp
		_update_bar()


## Death: topple over and sink, then go.
func _vanish() -> void:
	remove_from_group("units")
	remove_from_group("creeps")
	remove_from_group("summons")
	collision_layer = 0
	collision_mask = 0
	if _bar:
		_bar.visible = false
	var tween := create_tween()
	if _body:
		tween.tween_property(_body, "rotation:x", -PI / 2.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(_body, "position:y", -0.6 * _size, 0.5).set_delay(0.15)
	tween.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.25)
	tween.tween_callback(queue_free)


# ------------------------------------------------------------------ visuals
func _build_visual() -> void:
	var info := CreepTypes.lookup(key)
	var size: float = info.size
	var color: Color = info.color
	if owner_hero:
		color = color.lerp(Hero.TEAM_COLORS[team], 0.25)
	_body = Node3D.new()
	add_child(_body)
	var shape: String = info.shape
	var body_mat := _material(color)
	var dark_mat := _material(color.darkened(0.35))
	match shape:
		"golem":
			_part(_mesh("box", Vector3(1.1, 1.2, 0.8)), Vector3(0, 1.0, 0), body_mat, size)
			_part(_mesh("box", Vector3(0.6, 0.5, 0.5)), Vector3(0, 1.85, 0), dark_mat, size)
		"beast":
			_part(_mesh("capsule", Vector3(0.45, 1.4, 0)), Vector3(0, 0.6, 0), body_mat, size, Vector3(90, 0, 0))
			_part(_mesh("sphere", Vector3(0.38, 0, 0)), Vector3(0, 0.75, -0.75), dark_mat, size)
		"caster":
			_part(_mesh("cone", Vector3(0.55, 1.5, 0)), Vector3(0, 0.75, 0), body_mat, size)
			_part(_mesh("sphere", Vector3(0.3, 0, 0)), Vector3(0, 1.7, 0), dark_mat, size)
		_:
			_part(_mesh("capsule", Vector3(0.42, 1.5, 0)), Vector3(0, 0.95, 0), body_mat, size)
			_part(_mesh("sphere", Vector3(0.3, 0, 0)), Vector3(0, 1.9, 0), dark_mat, size)
	if is_boss:
		var crown := _part(_mesh("torus", Vector3(0.3, 0.42, 0)), Vector3(0, 2.25, 0), _material(Color(1.0, 0.8, 0.3)), size)
		crown.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Health bar, shown once the unit is hurt (always for bosses).
	_bar = Node3D.new()
	_bar.position.y = 2.5 * size + 0.3
	_bar.rotation_degrees.x = -54.0
	add_child(_bar)
	var back := MeshInstance3D.new()
	back.mesh = _mesh("quad", Vector3(1.1, 0.12, 0))
	back.material_override = _flat(Color(0.05, 0.05, 0.05, 0.85))
	_bar.add_child(back)
	_bar_fill = Node3D.new()
	_bar_fill.position = Vector3(-0.52, 0, 0.005)
	_bar.add_child(_bar_fill)
	var fill := MeshInstance3D.new()
	fill.mesh = _mesh("quad", Vector3(1.04, 0.08, 0))
	fill.position.x = 0.52
	fill.material_override = _flat(Hero.TEAM_COLORS[team] if team >= 0 else (Color(0.85, 0.5, 1.0) if is_boss else Color(0.9, 0.75, 0.3)))
	_bar_fill.add_child(fill)
	if is_boss:
		_bar.scale = Vector3(1.8, 1.8, 1.8)
	_update_bar()


func _part(mesh: Mesh, at: Vector3, material: Material, size: float, rotation_deg := Vector3.ZERO) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.material_override = material
	part.position = at * size
	part.scale = Vector3.ONE * size
	part.rotation_degrees = rotation_deg
	_body.add_child(part)
	return part


func _update_bar() -> void:
	if _bar == null:
		return
	_bar.visible = is_boss or hp < max_hp
	_bar_fill.scale.x = clampf(hp / max_hp, 0.001, 1.0)


## Meshes and materials are shared by every unit of the same look.
static func _mesh(kind: String, size: Vector3) -> Mesh:
	var cache_key := "%s:%s" % [kind, size]
	if _mesh_cache.has(cache_key):
		return _mesh_cache[cache_key]
	var mesh: Mesh
	match kind:
		"box":
			mesh = PrimitiveModel.box(size)
		"capsule":
			mesh = PrimitiveModel.capsule(size.x, size.y)
		"sphere":
			mesh = PrimitiveModel.sphere(size.x)
		"cone":
			mesh = PrimitiveModel.cone(size.x, size.y)
		"torus":
			mesh = PrimitiveModel.torus(size.x, size.y)
		_:
			var quad := QuadMesh.new()
			quad.size = Vector2(size.x, size.y)
			mesh = quad
	_mesh_cache[cache_key] = mesh
	return mesh


static func _material(color: Color) -> Material:
	var cache_key := color.to_html()
	if not _material_cache.has(cache_key):
		_material_cache[cache_key] = Toon.material(color)
	return _material_cache[cache_key]


static func _flat(color: Color) -> Material:
	var cache_key := "flat:" + color.to_html()
	if not _material_cache.has(cache_key):
		_material_cache[cache_key] = Hero._flat(color)
	return _material_cache[cache_key]
