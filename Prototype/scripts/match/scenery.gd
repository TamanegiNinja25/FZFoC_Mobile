class_name Scenery
extends RefCounted
## Dressing around the arena from the KayKit Medieval Hexagon pack (CC0, Kay
## Lousberg — assets/thirdparty/CREDITS.md): a castle and towers behind each
## base, banners at the fountains, camp props in the base corners, and
## mountains, hills and forest outside the walls.
## Every piece shares one texture, so all of it is merged into a single mesh
## (one draw call; two with shadows). It is decoration only — no collision —
## and placed deterministically so every player sees the same map.

const ROOT := "res://assets/thirdparty/kaykit/medieval/"
const HEX := 2.5  # KayKit hex tiles are ~2 wide; heroes are ~2.2 tall
## Mountains are sunk into the ground so their hex-tile bases don't show.
const SINK := -1.6


static func build(parent: Node3D, bases: Array, half_field: Vector2, duel_center: Vector3, duel_radius: float) -> MeshInstance3D:
	var tool := SurfaceTool.new()
	var state := {"material": null, "count": 0}
	var colors := ["blue", "red"]
	for team in 2:
		var base: Vector3 = bases[team]
		var side := signf(base.x)
		var back := half_field.x + 5.0  # just outside the end wall
		var facing := -side * PI / 2.0  # fronts turned toward the field
		var c: String = colors[team]
		_add(tool, state, "buildings/%s/building_castle_%s" % [c, c], Vector3(side * back, 0, 0), facing, HEX)
		for z in [-1.0, 1.0]:
			_add(tool, state, "buildings/%s/building_tower_A_%s" % [c, c], Vector3(side * (back - 1.0), 0, 9.0 * z), facing, HEX)
			_add(tool, state, "buildings/%s/building_tower_catapult_%s" % [c, c], Vector3(side * (back - 1.0), 0, 17.0 * z), facing, HEX)
			# Banners either side of the fountain, camp props in the base corners.
			_add(tool, state, "decoration/props/flag_%s" % c, base + Vector3(0, 0, 6.8 * z), facing, 8.0)
			var corner := Vector3(side * (half_field.x - 2.5), 0, 13.0 * z)
			_add(tool, state, "decoration/props/tent", corner, facing + 0.3 * z, 4.0)
			_add(tool, state, "decoration/props/weaponrack", corner + Vector3(-side * 2.6, 0, -1.2 * z), facing, 4.0)
			_add(tool, state, "decoration/props/barrel", corner + Vector3(-side * 0.6, 0, -2.4 * z), 0.0, 4.0)
			_add(tool, state, "decoration/props/crate_A_big", corner + Vector3(-side * 1.6, 0, -2.6 * z), 0.6, 4.0)

	# Mountains, hills and forest beyond the long walls and behind the castles.
	var rng := RandomNumberGenerator.new()
	rng.seed = 7041
	var tall := ["mountain_A_grass_trees", "mountain_B_grass_trees", "mountain_C_grass_trees"]
	var low := ["hills_A_trees", "hills_B_trees", "trees_A_large", "trees_B_large", "trees_A_medium"]
	var x := -half_field.x - 14.0
	while x <= half_field.x + 14.0:
		for z_side in [-1.0, 1.0]:
			var near_z: float = z_side * (half_field.y + 3.5)
			var far_z: float = z_side * (half_field.y + 8.5)
			var in_duel: bool = z_side < 0.0 and absf(x - duel_center.x) < duel_radius + 5.0
			if not in_duel:
				_add(tool, state, "decoration/nature/" + low[rng.randi() % low.size()], Vector3(x + rng.randf_range(-1, 1), -0.4, near_z), rng.randf() * TAU, HEX * 1.2)
				if rng.randf() < 0.7:
					_add(tool, state, "decoration/nature/" + tall[rng.randi() % tall.size()], Vector3(x + rng.randf_range(-2, 2), SINK, far_z + rng.randf_range(-1, 2)), rng.randf() * TAU, HEX * 1.6)
		x += 7.0
	for side in [-1.0, 1.0]:
		var z := -half_field.y
		while z <= half_field.y:
			_add(tool, state, "decoration/nature/" + tall[rng.randi() % tall.size()], Vector3(side * (half_field.x + 12.0), SINK, z), rng.randf() * TAU, HEX * 1.7)
			z += 9.0
	# Trees around the duel arena, which sits off the field to the north.
	for i in 10:
		var angle := PI * (0.05 + 0.9 * i / 9.0) + PI  # the far half, away from the camera
		var at := duel_center + Vector3(cos(angle), 0, sin(angle)) * (duel_radius + 5.5)
		_add(tool, state, "decoration/nature/tree_single_A", at, rng.randf() * TAU, 3.2)
	# Scattered flat stones inside the field (never on the camps or the lane).
	for i in 16:
		var at := Vector3(rng.randf_range(-half_field.x + 3, half_field.x - 3), 0, rng.randf_range(4.5, half_field.y - 2) * (1.0 if i % 2 == 0 else -1.0))
		_add(tool, state, "decoration/nature/rock_single_%s" % ["A", "B", "C"][i % 3], at, rng.randf() * TAU, 4.0)

	if state.count == 0:
		return null
	var mesh := MeshInstance3D.new()
	mesh.name = "Scenery"
	mesh.mesh = tool.commit()
	var material := state.material as BaseMaterial3D
	if material:  # tone the bright tile colours down to the arena's muted palette
		material = material.duplicate()
		material.albedo_color = Color(0.82, 0.85, 0.78)
		material.roughness = 1.0
	mesh.material_override = material if material else state.material
	parent.add_child(mesh)
	return mesh


static var _scenes := {}


## Appends every mesh surface of one model, placed at `at` with yaw `yaw`.
static func _add(tool: SurfaceTool, state: Dictionary, model: String, at: Vector3, yaw: float, size: float) -> void:
	var path := ROOT + model + ".gltf"
	if not _scenes.has(path):
		_scenes[path] = load(path) if ResourceLoader.exists(path) else null
	var scene: PackedScene = _scenes[path]
	if scene == null:
		return
	var root := scene.instantiate()
	var place := Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * size), at)
	_append(tool, state, root, place)
	root.free()


static func _append(tool: SurfaceTool, state: Dictionary, node: Node, xf: Transform3D) -> void:
	var here: Transform3D = xf * ((node as Node3D).transform if node is Node3D else Transform3D())
	if node is MeshInstance3D and (node as MeshInstance3D).mesh:
		var mesh: Mesh = (node as MeshInstance3D).mesh
		for surface in mesh.get_surface_count():
			if state.count == 0:
				tool.begin(Mesh.PRIMITIVE_TRIANGLES)
				state.material = mesh.surface_get_material(surface)
			tool.append_from(mesh, surface, here)
			state.count += 1
	for child in node.get_children():
		_append(tool, state, child, here)
