class_name CreepRooms
extends Node3D
## The reference map's private creep rooms. Teleport pads by the south wall lead
## to four walled rooms off the field; every time a hero steps in, the room
## spawns its creeps, up to a cap per type ("Can't spawn any more creeps."), so a
## player can farm alone. A pad inside each room leads back. Room contents follow
## the map's four rooms (unit counts, levels and HP; original names):
##   1  four mixed creeps, levels 5–10        2  two giants, levels 15 and 20
##   3  ten level-10 fiends                    4  three level-15 and two level-20
## Players and bots both use the pads (bots farm a room when the field is quiet
## and leave when it's empty). The rooms are built on every device; teleports
## and spawns run on the host.

const PAD_RADIUS := 1.3
const ROOM_RADIUS := 7.5
## The map's cap: a room stops spawning a type once 20 of it are alive.
const CAP_PER_TYPE := 20
## [entry pad on the field, room centre, creep keys spawned per entry].
const ROOMS := [
	[Vector3(-30, 0, 24.5), Vector3(-33, 0, 50), ["room_whelp", "room_hound", "room_hound2", "room_wraith"]],
	[Vector3(-18, 0, 24.5), Vector3(-11, 0, 50), ["room_warden", "room_revenant"]],
	[Vector3(18, 0, 24.5), Vector3(11, 0, 50), ["room_fiend", "room_fiend", "room_fiend", "room_fiend", "room_fiend",
		"room_fiend", "room_fiend", "room_fiend", "room_fiend", "room_fiend"]],
	[Vector3(30, 0, 24.5), Vector3(33, 0, 50), ["room_warden", "room_warden", "room_warden", "room_revenant", "room_revenant"]],
]
const ROOM_NAMES := ["Cinder Den", "Vault of Titans", "Ember Pit", "Throne of Dread"]
const COLORS := [Color(1.0, 0.55, 0.25), Color(0.55, 0.75, 1.0), Color(1.0, 0.35, 0.2), Color(0.75, 0.45, 1.0)]

## The ArenaMatch (typed loosely: naming it here would create a dependency cycle).
var arena: Node
var authority := true
var _cooldown := {}  # hero → seconds before it can use a pad again
var _units: Array = []  # per room: its living creeps


static func exit_pad(room: int) -> Vector3:
	return ROOMS[room][1] + Vector3(0, 0, -ROOM_RADIUS + 1.6)


## Which room a position is in, or -1.
static func room_at(at: Vector3) -> int:
	for i in ROOMS.size():
		var centre: Vector3 = ROOMS[i][1]
		if Vector2(at.x - centre.x, at.z - centre.z).length() <= ROOM_RADIUS + 1.0:
			return i
	return -1


func _ready() -> void:
	for i in ROOMS.size():
		_units.append([])
		_build_room(i)


func _physics_process(delta: float) -> void:
	if not authority or arena.over:
		return
	for h in _cooldown.keys():
		_cooldown[h] -= delta
		if _cooldown[h] <= 0.0:
			_cooldown.erase(h)
	for h: Hero in arena.heroes:
		if not h.is_alive() or h.frozen or _cooldown.has(h):
			continue
		for i in ROOMS.size():
			if _flat_distance(h.global_position, ROOMS[i][0]) <= PAD_RADIUS:
				enter(h, i)
				break
			if _flat_distance(h.global_position, exit_pad(i)) <= PAD_RADIUS:
				leave(h, i)
				break


func enter(h: Hero, room: int) -> void:
	_teleport(h, ROOMS[room][1] + Vector3(0, 0, -1.5))
	var spawned := spawn(room)
	if spawned == 0:
		_note(h, "Can't spawn any more creeps.")
	else:
		_note(h, ROOM_NAMES[room])


func leave(h: Hero, room: int) -> void:
	var pad: Vector3 = ROOMS[room][0]
	_teleport(h, pad + Vector3(0, 0, -3.0))


## Spawns the room's creeps (skipping any type at its cap); returns how many.
func spawn(room: int) -> int:
	var alive: Array = _units[room].filter(func(u): return is_instance_valid(u) and u.is_alive())
	_units[room] = alive
	var counts := {}
	for unit in alive:
		counts[unit.key] = counts.get(unit.key, 0) + 1
	var made := 0
	var centre: Vector3 = ROOMS[room][1]
	for unit_key: String in ROOMS[room][2]:
		if counts.get(unit_key, 0) >= CAP_PER_TYPE:
			continue
		counts[unit_key] = counts.get(unit_key, 0) + 1
		var angle := randf() * TAU
		var at := centre + Vector3(cos(angle), 0, sin(angle)) * randf_range(1.5, ROOM_RADIUS - 2.0)
		var unit := Creep.create(unit_key)
		unit.position = at
		unit.home = centre
		arena.add_child(unit)
		_units[room].append(unit)
		made += 1
	return made


func _teleport(h: Hero, at: Vector3) -> void:
	_cooldown[h] = 1.0
	h.vfx("column", [h.global_position, Color(0.6, 0.8, 1.0), 4.0])
	h.global_position = at
	h.velocity = Vector3.ZERO
	h.vfx("column", [at, Color(0.6, 0.8, 1.0), 4.0])
	h.play_sfx("open", -4.0)


## A message for the hero's own player (relayed to their device online).
func _note(h: Hero, text: String) -> void:
	if h == arena.hero:
		arena._announce(text, Color(0.75, 0.85, 1.0))
	h.fx.emit("note", [text])


static func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


# ------------------------------------------------------------------ visuals
func _build_room(i: int) -> void:
	var color: Color = COLORS[i]
	var centre: Vector3 = ROOMS[i][1]
	_disc(centre + Vector3(0, 0.01, 0), ROOM_RADIUS + 0.6, Color(0.2, 0.18, 0.2))
	_disc(centre + Vector3(0, 0.02, 0), ROOM_RADIUS, color.darkened(0.72))
	for pad in [ROOMS[i][0], exit_pad(i)]:
		_disc(pad + Vector3(0, 0.03, 0), PAD_RADIUS, color.darkened(0.35))
		_glow_ring(pad + Vector3(0, 0.05, 0), PAD_RADIUS, color)
	# Walls: an octagon of stone blocks keeps the room's creeps (and the hero) in.
	for k in 8:
		var angle := TAU * (k + 0.5) / 8.0
		var at := centre + Vector3(cos(angle), 0, sin(angle)) * (ROOM_RADIUS + 0.6)
		var body := StaticBody3D.new()
		body.position = at + Vector3(0, 0.9, 0)
		body.rotation.y = -angle + PI / 2.0
		var length := 2.0 * (ROOM_RADIUS + 0.6) * tan(PI / 8.0) + 0.3
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(length, 1.8, 0.8)
		shape.shape = box
		body.add_child(shape)
		var mesh := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = box.size
		mesh.mesh = box_mesh
		mesh.material_override = Toon.material(Color(0.32, 0.3, 0.3))
		body.add_child(mesh)
		add_child(body)
	var sign := Label3D.new()
	sign.text = ROOM_NAMES[i]
	sign.font_size = 56
	sign.outline_size = 12
	sign.modulate = color.lightened(0.3)
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.position = ROOMS[i][0] + Vector3(0, 2.4, 0)
	add_child(sign)


func _disc(at: Vector3, radius: float, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = 0.02
	cylinder.radial_segments = 32
	cylinder.rings = 1
	mesh.mesh = cylinder
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.position = at
	mesh.material_override = Toon.material(color, 0.0)
	add_child(mesh)


func _glow_ring(at: Vector3, radius: float, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius - 0.15
	torus.outer_radius = radius
	torus.rings = 32
	torus.ring_segments = 4
	mesh.mesh = torus
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.position = at
	mesh.scale = Vector3(1, 0.05, 1)
	var material := Toon.material(color, 0.0)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.4
	mesh.material_override = material
	add_child(mesh)
