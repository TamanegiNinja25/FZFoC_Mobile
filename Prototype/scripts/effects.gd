class_name Effects
extends RefCounted
## Shared visual effects that any hero model can use.

static var _torus: TorusMesh
static var _materials := {}


## Expanding shockwave ring at `position` (world space), sized to `radius`.
## The ring mesh and its material (per colour) are shared; each ring fades
## through its own transparency.
static func ring(world: Node, position: Vector3, radius: float, color: Color) -> void:
	if world == null or not world.is_inside_tree() or not UnitFx.visible_to_camera(world, position):
		return
	if _torus == null:
		_torus = TorusMesh.new()
		_torus.inner_radius = 0.85
		_torus.outer_radius = 1.0
		_torus.rings = 40
		_torus.ring_segments = 4
	var key := color.to_html(false)
	if not _materials.has(key):
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(color.r, color.g, color.b, 1.0)
		_materials[key] = material
	var ring_mesh := MeshInstance3D.new()
	ring_mesh.mesh = _torus
	ring_mesh.material_override = _materials[key]
	ring_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring_mesh.transparency = 1.0 - color.a
	world.add_child(ring_mesh)
	ring_mesh.global_position = position + Vector3(0, 0.1, 0)
	ring_mesh.scale = Vector3(radius * 0.3, 1.0, radius * 0.3)
	var tween := ring_mesh.create_tween()
	tween.tween_property(ring_mesh, "scale", Vector3(radius, 1.0, radius), 0.25)
	tween.parallel().tween_property(ring_mesh, "transparency", 1.0, 0.3)
	tween.tween_callback(ring_mesh.queue_free)
