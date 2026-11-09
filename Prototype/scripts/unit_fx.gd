class_name UnitFx
extends RefCounted
## Status visuals attached to units (stun stars, roots) and one-shot effects
## (bursts of sparks, slash arcs, afterimages, beams, falling rocks).
## Meshes and materials are shared; particles are tiny one-shot emitters.

static var _cache := {}


## Three little stars circling above a stunned unit. The caller shows or hides
## the returned node and spins it.
static func stun_stars(parent: Node3D, height: float) -> Node3D:
	var ring := Node3D.new()
	ring.position.y = height
	for i in 3:
		var star := MeshInstance3D.new()
		star.mesh = _sphere(0.11)
		star.material_override = flat(Color(1.0, 0.92, 0.35))
		star.position = Vector3(cos(TAU * i / 3.0), 0, sin(TAU * i / 3.0)) * 0.45
		star.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ring.add_child(star)
	ring.visible = false
	parent.add_child(ring)
	return ring


## Stone spikes around the feet of a rooted unit.
static func root_spikes(parent: Node3D) -> Node3D:
	var group := Node3D.new()
	for i in 5:
		var spike := MeshInstance3D.new()
		spike.mesh = _cone(0.14, 0.7)
		spike.material_override = Toon.material(Color(0.5, 0.42, 0.3))
		var angle := TAU * i / 5.0
		spike.position = Vector3(cos(angle), 0.3, sin(angle)) * Vector3(0.7, 1, 0.7)
		spike.rotation = Vector3(sin(angle) * 0.35, 0, -cos(angle) * 0.35)
		spike.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		group.add_child(spike)
	group.visible = false
	parent.add_child(group)
	return group


static func flat(color: Color) -> StandardMaterial3D:
	var key := "flat:" + color.to_html()
	if not _cache.has(key):
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = color
		if color.a < 1.0:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_cache[key] = material
	return _cache[key]


static func _sphere(radius: float) -> SphereMesh:
	var key := "sphere:%s" % radius
	if not _cache.has(key):
		var mesh := SphereMesh.new()
		mesh.radius = radius
		mesh.height = radius * 2.0
		mesh.radial_segments = 8
		mesh.rings = 4
		_cache[key] = mesh
	return _cache[key]


static func _cone(radius: float, height: float) -> CylinderMesh:
	var key := "cone:%s:%s" % [radius, height]
	if not _cache.has(key):
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.0
		mesh.bottom_radius = radius
		mesh.height = height
		mesh.radial_segments = 6
		mesh.rings = 1
		_cache[key] = mesh
	return _cache[key]
