class_name NetMatch
extends Node
## Network layer for the arena. The host simulates everything; this node
##   host:   sends a snapshot of every hero, the score and the duel 20×/s and
##           of every creep, boss and summon 5×/s; relays effects and
##           announcements; applies each client's input to its hero;
##   client: sends its stick direction every physics frame and its button
##           presses as they happen, and shows the host's snapshots.

const SNAPSHOT_INTERVAL := 1.0 / 20.0
## Creeps, bosses and summons: every 4th snapshot, as packed arrays.
const UNIT_EVERY := 4

## The ArenaMatch (typed loosely: naming it here would create a dependency cycle).
var arena: Node

var _clock := 0.0
var _snapshots := 0
var _targets := {}  # hero index → target position (clients interpolate toward it)
var _units := {}  # client: net id → puppet Creep


func _ready() -> void:
	var net := get_node("/root/Net")
	if net.is_host():
		for i in arena.heroes.size():
			arena.heroes[i].fx.connect(_on_hero_fx.bind(i))
		multiplayer.peer_disconnected.connect(_on_peer_left)
	else:
		arena.hero.action_requested.connect(func(kind, arg): _client_action.rpc_id(1, kind, arg))
		net.host_left.connect(_on_host_left)


func _physics_process(delta: float) -> void:
	if get_node("/root/Net").is_host():
		_clock += delta
		if _clock >= SNAPSHOT_INTERVAL:
			_clock = 0.0
			_snapshot.rpc(_pack())
			_snapshots += 1
			if _snapshots % UNIT_EVERY == 0:
				var units := _pack_units()
				_unit_snapshot.rpc(units[0], units[1], units[2])
	elif arena.hero and multiplayer.multiplayer_peer:
		_client_move.rpc_id(1, arena.hero._move_input())


func _process(delta: float) -> void:
	if get_node("/root/Net").is_host():
		return
	for i in _targets:  # smooth toward the latest snapshot
		var h: Hero = arena.heroes[i]
		h.global_position = h.global_position.lerp(_targets[i], minf(delta * 15.0, 1.0))


# --------------------------------------------------------------- host side
func _pack() -> Dictionary:
	var heroes := []
	for h in arena.heroes:
		var cooldowns := []
		for skill in h.skills:
			cooldowns.append(skill.time_left)
		var item_ids := PackedStringArray()  # the full Capture Orb is its own item id
		for item in h.items:
			item_ids.append(item.id)
		var ranks := PackedInt32Array()
		for skill in h.skills:
			ranks.append(skill.rank)
		heroes.append([h.global_position.x, h.global_position.z, h.animator.target_yaw, h.hp, h.max_hp, h.shield,
				h.in_form, h.form_time_left, h.is_alive(), h.gold, h.meter.charge, h.kills, h.deaths,
				cooldowns, item_ids, h.spree, h.in_shop_range,
				h.level, h.xp, h.skill_points, ranks, [h.tome_attributes.str, h.tome_attributes.agi, h.tome_attributes.int],
				h.frozen, h.is_stunned(), h.damage_dealt, h.damage_taken, h.is_rooted(), h.left_game, h.form_stage])
	return {"heroes": heroes, "kills": arena.kills, "time": arena.time_left if arena.time_left != INF else -1.0,
		"duel": [arena.duel_phase, arena.duel_text, arena.duel_in]}


## [ids, keys, floats (x, z, hp, max hp, team per unit)].
func _pack_units() -> Array:
	var ids := PackedInt32Array()
	var keys := PackedStringArray()
	var data := PackedFloat32Array()
	for node in get_tree().get_nodes_in_group("creeps"):
		var unit := node as Creep
		if unit == null or not unit.is_alive():
			continue
		ids.append(unit.net_id)
		keys.append(unit.key)
		data.append_array([unit.global_position.x, unit.global_position.z, unit.hp, unit.max_hp, unit.team])
	return [ids, keys, data]


@rpc("any_peer", "unreliable_ordered")
func _client_move(direction: Vector3) -> void:
	var h := _hero_of(multiplayer.get_remote_sender_id())
	if h:
		h.ai_move = direction.limit_length(1.0)


@rpc("any_peer", "reliable")
func _client_action(kind: String, arg: Variant) -> void:
	var h := _hero_of(multiplayer.get_remote_sender_id())
	if h == null:
		return
	match kind:
		"skill": h.try_skill(int(arg))
		"learn": h.learn_skill(int(arg))
		"attack": h.order_attack()
		"transform": h.try_transform()
		"buy": h.buy(str(arg))
		"sell": h.sell(int(arg))
		"use": h.use_item(int(arg))


func _hero_of(peer_id: int) -> Hero:
	for h in arena.heroes:
		if h.owner_peer == peer_id:
			return h
	return null


func _on_hero_fx(kind: String, data: Array, index: int) -> void:
	_fx.rpc(index, kind, data)


func announce(text: String, color: Color) -> void:
	_announce.rpc(text, color)


func end(winner: int) -> void:
	_end.rpc(winner)


## A friend dropped out. As in the reference map, their allies are paid by
## the leaver's level (2,000 at 6–15, 6,000 at 16–30, 18,000 above); then a
## bot takes over the hero so the teams stay even.
func _on_peer_left(peer_id: int) -> void:
	var h := _hero_of(peer_id)
	if h == null:
		return
	var share := 0
	if h.level > 30:
		share = 18000
	elif h.level > 15:
		share = 6000
	elif h.level > 5:
		share = 2000
	if share > 0:
		for ally in arena.heroes:
			if ally != h and ally.team == h.team:
				ally.gold += share
	var label: String = arena.hero_label(h)
	h.owner_peer = 0
	h.left_game = true
	arena.add_bot_brain(h)
	announce("%s left — a bot takes over%s" % [label, " (+%d gold to allies)" % share if share > 0 else ""], Color(0.8, 0.8, 0.8))


# --------------------------------------------------------------- client side
@rpc("authority", "unreliable_ordered")
func _snapshot(state: Dictionary) -> void:
	arena.kills = state.kills
	arena.time_left = INF if state.time < 0.0 else state.time
	arena.duel_phase = state.duel[0]
	arena.duel_text = state.duel[1]
	arena.duel_in = state.duel[2]
	for i in state.heroes.size():
		var s: Array = state.heroes[i]
		var h: Hero = arena.heroes[i]
		var target := Vector3(s[0], 0.0, s[1])
		if not _targets.has(i) or h.global_position.distance_to(target) > 6.0:
			h.global_position = target  # first snapshot or respawn: snap
		_targets[i] = target
		h.animator.target_yaw = s[2]
		h.max_hp = s[4]
		h.shield = s[5]
		if not is_equal_approx(h.hp, s[3]):
			h.hp = s[3]
			h.health_changed.emit(h.hp, h.max_hp, h.shield)
		if h.in_form != s[6]:
			h.in_form = s[6]
			if h.model.has_method("set_form"):
				h.model.set_form(h.in_form, h.form_scale)
			h.form_changed.emit(h.in_form)
		h.form_time_left = s[7]
		var was_alive := h.is_alive()
		h._dead_time = 0.0 if s[8] else 1.0
		if was_alive and not s[8]:
			h.animator.die()
		elif not was_alive and s[8]:
			h.animator.respawn()
		h.gold = s[9]
		if not is_equal_approx(h.meter.charge, s[10]):
			h.meter.charge = s[10]
			h.meter.changed.emit(h.meter.charge, h.meter.max_charge)
		h.kills = s[11]
		h.deaths = s[12]
		for k in mini(s[13].size(), h.skills.size()):
			h.skills[k].time_left = s[13][k]
		var ids: PackedStringArray = s[14]
		if ids.size() != h.items.size() or not _same_items(h, ids):
			h.items.clear()
			for item_id in ids:
				h.items.append(ItemCatalog.find(item_id))
			h.items_changed.emit()
		h.spree = s[15]
		h.in_shop_range = s[16]
		var leveled: bool = s[17] != h.level
		h.level = s[17]
		h.xp = s[18]
		h.skill_points = s[19]
		for k in mini(s[20].size(), h.skills.size()):
			h.skills[k].rank = s[20][k]
		h.tome_attributes = {"str": s[21][0], "agi": s[21][1], "int": s[21][2]}
		h.frozen = s[22]
		h._stun_time = 0.5 if s[23] else 0.0
		h.damage_dealt = s[24]
		h.damage_taken = s[25]
		h._root_time = 0.5 if s[26] else 0.0
		h.left_game = s[27]
		if h.form_stage != s[28]:
			h.form_stage = s[28]
			if h.in_form and h.model.has_method("set_form"):
				h.model.set_form(true, h.form_scale_now())
			h.form_changed.emit(h.in_form)
		if leveled:
			h.recompute_stats()
			h.leveled_up.emit(h.level)


## Clients mirror the host's creeps, bosses and summons as display-only puppets.
@rpc("authority", "unreliable_ordered")
func _unit_snapshot(ids: PackedInt32Array, keys: PackedStringArray, data: PackedFloat32Array) -> void:
	var seen := {}
	for i in ids.size():
		var id := ids[i]
		seen[id] = true
		var unit: Creep = _units.get(id)
		if unit == null or not is_instance_valid(unit):
			unit = Creep.new()
			unit.configure(keys[i])
			unit.net_id = id
			unit.puppet = true
			unit.team = int(data[i * 5 + 4])
			unit.position = Vector3(data[i * 5], 0.0, data[i * 5 + 1])
			arena.add_child(unit)
			_units[id] = unit
		unit.apply_snapshot(data[i * 5], data[i * 5 + 1], data[i * 5 + 2], data[i * 5 + 3])
	for id in _units.keys():
		if not seen.has(id):
			var gone: Creep = _units[id]
			_units.erase(id)
			if is_instance_valid(gone):
				gone._die(null)


func _same_items(h: Hero, ids: PackedStringArray) -> bool:
	for k in ids.size():
		if h.items[k].id != ids[k]:
			return false
	return true


@rpc("authority", "reliable")
func _fx(index: int, kind: String, data: Array) -> void:
	var h: Hero = arena.heroes[index]
	match kind:
		"slam":
			if h.model.has_method("play_slam"):
				h.model.play_slam(data[0], data[1])
		"boulder":
			Projectile.launch(h, data[0], BoulderHurlSkill.SPEED, BoulderHurlSkill.RANGE, 0.0, true)
		"shot":
			var shot := Projectile.launch(h, data[0], data[1], data[2], 0.0, true)
			shot.configure(data[3], data[4], 0.0, false, data[5], data[6])
		"ring":
			Effects.ring(arena, data[0], data[1], data[2])
		"vfx":
			UnitFx.play(arena, data[0], data[1])
		"anim":
			h.animator.play(data[0])
		"dmg":
			if h.is_player:
				FloatText.spawn(arena, data[0], data[1], FloatText.DEALT, data[1] >= 150.0)
		"hurt":
			if h.is_player:
				FloatText.spawn(arena, h.global_position, data[0], FloatText.TAKEN)
		"sfx":
			var sfx := get_node_or_null("/root/Sfx")
			if sfx:
				sfx.play(data[0], data[1] + (0.0 if h.is_player else -9.0))


@rpc("authority", "reliable")
func _announce(text: String, color: Color) -> void:
	arena.announce(text, color)


@rpc("authority", "reliable")
func _end(winner: int) -> void:
	arena.finish(winner)


func _on_host_left() -> void:
	Session.notice = "The host left the game."
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
