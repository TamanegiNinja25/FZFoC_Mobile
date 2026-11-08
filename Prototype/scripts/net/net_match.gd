class_name NetMatch
extends Node
## Network layer for the arena. The host simulates everything; this node
##   host:   sends a snapshot of every hero and the score 20×/s, relays effects
##           and announcements, applies each client's input to its hero;
##   client: sends its stick direction every physics frame and its button
##           presses as they happen, and shows the host's snapshots.

const SNAPSHOT_INTERVAL := 1.0 / 20.0

## The ArenaMatch (typed loosely: naming it here would create a dependency cycle).
var arena: Node

var _clock := 0.0
var _targets := {}  # hero index → target position (clients interpolate toward it)


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
		var item_ids := PackedStringArray()
		for item in h.items:
			item_ids.append(item.id)
		heroes.append([h.global_position.x, h.global_position.z, h.model.rotation.y, h.hp, h.max_hp, h.shield,
				h.in_form, h.form_time_left, h.is_alive(), h.gold, h.meter.charge, h.kills, h.deaths,
				cooldowns, item_ids, h.spree, h.in_shop_range])
	return {"heroes": heroes, "kills": arena.kills, "time": arena.time_left}


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


## A friend dropped out: a bot takes over their hero.
func _on_peer_left(peer_id: int) -> void:
	var h := _hero_of(peer_id)
	if h:
		h.owner_peer = 0
		arena.add_bot_brain(h)
		announce("%s left — a bot takes over" % arena.hero_label(h), Color(0.8, 0.8, 0.8))


# --------------------------------------------------------------- client side
@rpc("authority", "unreliable_ordered")
func _snapshot(state: Dictionary) -> void:
	arena.kills = state.kills
	arena.time_left = state.time
	for i in state.heroes.size():
		var s: Array = state.heroes[i]
		var h: Hero = arena.heroes[i]
		var target := Vector3(s[0], 0.0, s[1])
		if not _targets.has(i) or h.global_position.distance_to(target) > 6.0:
			h.global_position = target  # first snapshot or respawn: snap
		_targets[i] = target
		h.model.rotation.y = s[2]
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
		h.visible = s[8]
		h._dead_time = 0.0 if s[8] else 1.0
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
