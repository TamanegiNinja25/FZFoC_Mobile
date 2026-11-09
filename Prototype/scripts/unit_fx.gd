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


# ------------------------------------------------------------- one-shot effects
## Plays an effect by name; Hero.vfx() calls this and relays it to clients.
##   ring    [pos, radius, color]         expanding shockwave
##   burst   [pos, color, amount, speed]  spray of sparks
##   slash   [pos, yaw, radius, color]    crescent sweep
##   ghost   [pos, yaw, color]            fading afterimage
##   beam    [from, to, color, width]     bright line that fades
##   rock    [pos, radius]                boulder falling from the sky
##   column  [pos, color, height]         rising pillar of light
static func play(world: Node, kind: String, data: Array) -> void:
	if world == null or not world.is_inside_tree():
		return
	match kind:
		"ring":
			Effects.ring(world, data[0], data[1], data[2])
		"burst":
			burst(world, data[0], data[1], data[2], data[3])
		"slash":
			slash(world, data[0], data[1], data[2], data[3])
		"ghost":
			ghost(world, data[0], data[1], data[2])
		"beam":
			beam(world, data[0], data[1], data[2], data[3])
		"rock":
			rock(world, data[0], data[1])
		"column":
			column(world, data[0], data[1], data[2])


static func burst(world: Node, at: Vector3, color: Color, amount: int, speed: float) -> void:
	var particles := GPUParticles3D.new()
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.amount = clampi(amount, 4, 48)
	particles.lifetime = 0.55
	var process := ParticleProcessMaterial.new()
	process.direction = Vector3(0, 1, 0)
	process.spread = 80.0
	process.initial_velocity_min = speed * 0.5
	process.initial_velocity_max = speed
	process.gravity = Vector3(0, -9.0, 0)
	process.scale_min = 0.6
	process.scale_max = 1.2
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(0.14, 0.14)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_color = color
	quad.material = material
	particles.draw_pass_1 = quad
	world.add_child(particles)
	particles.global_position = at + Vector3(0, 0.8, 0)
	particles.emitting = true
	world.get_tree().create_timer(1.0).timeout.connect(particles.queue_free)


static func slash(world: Node, at: Vector3, yaw: float, radius: float, color: Color) -> void:
	var arc := MeshInstance3D.new()
	arc.mesh = _crescent()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = color
	arc.material_override = material
	arc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(arc)
	arc.global_position = at + Vector3(0, 1.0, 0)
	arc.rotation.y = yaw + 0.9
	arc.scale = Vector3.ONE * radius * 0.6
	var tween := arc.create_tween().set_parallel(true)
	tween.tween_property(arc, "rotation:y", yaw - 0.9, 0.16)
	tween.tween_property(arc, "scale", Vector3.ONE * radius, 0.16)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.25).set_delay(0.08)
	tween.chain().tween_callback(arc.queue_free)


static func ghost(world: Node, at: Vector3, yaw: float, color: Color) -> void:
	var image := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	capsule.radial_segments = 10
	capsule.rings = 3
	image.mesh = capsule
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(color.r, color.g, color.b, 0.45)
	image.material_override = material
	image.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(image)
	image.global_position = at + Vector3(0, 0.95, 0)
	image.rotation.y = yaw
	var tween := image.create_tween()
	tween.tween_property(material, "albedo_color:a", 0.0, 0.3)
	tween.tween_callback(image.queue_free)


static func beam(world: Node, from: Vector3, to: Vector3, color: Color, width: float) -> void:
	var length := from.distance_to(to)
	if length < 0.1:
		return
	var line := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(width, width, length)
	line.mesh = box
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	line.material_override = material
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(line)
	var lift := Vector3(0, 1.2, 0)
	line.global_position = (from + to) / 2.0 + lift
	line.look_at(to + lift, Vector3.UP)
	var tween := line.create_tween().set_parallel(true)
	tween.tween_property(line, "scale", Vector3(0.2, 0.2, 1.0), 0.3)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.3)
	tween.chain().tween_callback(line.queue_free)


static func rock(world: Node, at: Vector3, radius: float) -> void:
	var boulder := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius * 0.45
	sphere.height = radius * 0.8
	sphere.radial_segments = 12
	sphere.rings = 6
	boulder.mesh = sphere
	boulder.material_override = Toon.material(Color(0.5, 0.45, 0.38))
	world.add_child(boulder)
	boulder.global_position = at + Vector3(0, 9.0, 0)
	var tween := boulder.create_tween()
	tween.tween_property(boulder, "global_position", at + Vector3(0, radius * 0.3, 0), 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		burst(world, at, Color(0.7, 0.6, 0.45), 30, 7.0)
		Effects.ring(world, at, radius, Color(1.0, 0.8, 0.4, 0.95)))
	tween.tween_property(boulder, "scale", Vector3(1.3, 0.05, 1.3), 0.2)
	tween.tween_callback(boulder.queue_free)


static func column(world: Node, at: Vector3, color: Color, height: float) -> void:
	var pillar := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.55
	cylinder.bottom_radius = 0.75
	cylinder.height = height
	cylinder.radial_segments = 16
	cylinder.rings = 1
	cylinder.cap_top = false
	cylinder.cap_bottom = false
	pillar.mesh = cylinder
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(color.r, color.g, color.b, 0.55)
	pillar.material_override = material
	pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(pillar)
	pillar.global_position = at + Vector3(0, height / 2.0, 0)
	pillar.scale = Vector3(1, 0.1, 1)
	var tween := pillar.create_tween().set_parallel(true)
	tween.tween_property(pillar, "scale", Vector3(1, 1, 1), 0.2)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.5).set_delay(0.15)
	tween.chain().tween_callback(pillar.queue_free)


## A flat crescent (120° ribbon, radius 1), built once and shared.
static func _crescent() -> ArrayMesh:
	if _cache.has("crescent"):
		return _cache["crescent"]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps := 16
	for i in steps:
		var a0 := lerpf(-1.05, 1.05, float(i) / steps)
		var a1 := lerpf(-1.05, 1.05, float(i + 1) / steps)
		var w0 := sin(float(i) / steps * PI) * 0.35
		var w1 := sin(float(i + 1) / steps * PI) * 0.35
		var o0 := Vector3(sin(a0), 0, -cos(a0))
		var o1 := Vector3(sin(a1), 0, -cos(a1))
		var i0 := o0 * (1.0 - w0)
		var i1 := o1 * (1.0 - w1)
		for v in [o0, o1, i1, o0, i1, i0]:
			st.add_vertex(v)
	var mesh := st.commit()
	_cache["crescent"] = mesh
	return mesh
