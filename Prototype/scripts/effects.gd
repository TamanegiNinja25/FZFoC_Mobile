class_name Effects
extends RefCounted
## Shared visual effects that any hero model can use.


## Expanding shockwave ring at `position` (world space), sized to `radius`.
static func ring(world: Node, position: Vector3, radius: float, color: Color) -> void:
	var ring_mesh := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.85
	torus.outer_radius = 1.0
	torus.rings = 40
	torus.ring_segments = 4
	ring_mesh.mesh = torus
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	ring_mesh.material_override = material
	world.add_child(ring_mesh)
	ring_mesh.global_position = position + Vector3(0, 0.1, 0)
	ring_mesh.scale = Vector3(radius * 0.3, 1.0, radius * 0.3)
	var tween := ring_mesh.create_tween()
	tween.tween_property(ring_mesh, "scale", Vector3(radius, 1.0, radius), 0.25)
	tween.parallel().tween_property(material, "albedo_color:a", 0.0, 0.3)
	tween.tween_callback(ring_mesh.queue_free)
