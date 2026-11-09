class_name FloatText
extends RefCounted
## Floating damage numbers: rise, drift and fade above a unit. Labels come from
## a small pool per world and are reused, so a heavy fight never creates more
## than POOL_SIZE nodes.

const POOL_SIZE := 28
const LIFETIME := 0.9
## Damage you deal, damage you take, skill hits, and healing.
const DEALT := Color(1.0, 0.95, 0.85)
const TAKEN := Color(1.0, 0.35, 0.3)
const SKILL := Color(1.0, 0.78, 0.3)
const HEAL := Color(0.45, 1.0, 0.5)

static var _pools := {}  # world instance id → {labels, next}


static func spawn(world: Node, at: Vector3, amount: float, color: Color, big := false) -> void:
	if world == null or not world.is_inside_tree() or amount < 0.5:
		return
	var label := _take(world)
	label.text = str(roundi(amount))
	label.modulate = color
	label.outline_modulate = Color(0.08, 0.04, 0.02, 1.0)
	label.font_size = 64 if big else 48
	label.visible = true
	var start := at + Vector3(randf_range(-0.35, 0.35), 2.6, randf_range(-0.2, 0.2))
	label.global_position = start
	label.scale = Vector3.ONE * (1.5 if big else 1.25)
	var tween: Tween = label.get_meta("tween") if label.has_meta("tween") else null
	if tween and tween.is_valid():
		tween.kill()
	tween = label.create_tween().set_parallel(true)
	tween.tween_property(label, "global_position", start + Vector3(randf_range(-0.4, 0.4), 1.4, 0), LIFETIME) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector3.ONE, 0.18)
	tween.tween_property(label, "modulate:a", 0.0, LIFETIME * 0.45).set_delay(LIFETIME * 0.55)
	tween.chain().tween_callback(func(): label.visible = false)
	label.set_meta("tween", tween)


## The reference map's cast callout: "Skill name !!" rises above the caster
## in a random colour every time a hero casts.
static func callout(world: Node, at: Vector3, text: String, color: Color) -> void:
	if world == null or not world.is_inside_tree():
		return
	var label := _take(world)
	label.text = text
	label.modulate = color
	label.outline_modulate = Color(0.05, 0.03, 0.02, 1.0)
	label.font_size = 40
	label.visible = true
	var start := at + Vector3(0, 3.3, 0)
	label.global_position = start
	label.scale = Vector3.ONE * 1.3
	var tween: Tween = label.get_meta("tween") if label.has_meta("tween") else null
	if tween and tween.is_valid():
		tween.kill()
	tween = label.create_tween().set_parallel(true)
	tween.tween_property(label, "global_position", start + Vector3(0, 1.2, 0), 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector3.ONE, 0.2)
	tween.tween_property(label, "modulate:a", 0.0, 0.55).set_delay(0.95)
	tween.chain().tween_callback(func(): label.visible = false)
	label.set_meta("tween", tween)


static func _take(world: Node) -> Label3D:
	var id := world.get_instance_id()
	if not _pools.has(id) or not is_instance_valid(_pools[id].labels[0]):
		var labels: Array[Label3D] = []
		for i in POOL_SIZE:
			var label := Label3D.new()
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.no_depth_test = true
			label.fixed_size = false
			label.pixel_size = 0.006
			label.outline_size = 14
			label.render_priority = 3
			label.outline_render_priority = 2
			label.visible = false
			world.add_child(label)
			labels.append(label)
		_pools[id] = {"labels": labels, "next": 0}
	var pool: Dictionary = _pools[id]
	var picked: Label3D = pool.labels[pool.next]
	pool.next = (pool.next + 1) % POOL_SIZE
	return picked
