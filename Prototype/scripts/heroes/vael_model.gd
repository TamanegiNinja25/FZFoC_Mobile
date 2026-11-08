class_name VaelModel
extends Node3D
## Model for Vael, built from smooth rounded primitives with the toon material.
## It stands in for the future high-poly sculpt (30–50k triangles) and fixes the
## silhouette: domed pauldrons, round shield with a team emblem, barrel hammer.
## Glow sits on surfaces the top-down camera sees — shoulder vents and helm
## crest — as well as the visor and kiln door. Faces −Z.

const IRON := Color(0.45, 0.47, 0.53)
const DARK_IRON := Color(0.26, 0.27, 0.31)
const WOOD := Color(0.38, 0.26, 0.17)
const SCORCHED := Color(0.3, 0.2, 0.17)
const EMBER := Color(1.0, 0.45, 0.1)

## Team colour for the shield emblem; set before the model enters the tree.
var accent := Color(0.3, 0.55, 1.0)

var _glow_materials: Array[StandardMaterial3D] = []
var _body_material: StandardMaterial3D
var _embers: GPUParticles3D
var _tween: Tween


func _ready() -> void:
	_body_material = Toon.material(IRON)
	var dark := Toon.material(DARK_IRON)
	_add(_capsule(0.45, 1.5), Vector3(0, 0.85, 0), _body_material)                       # torso
	_add(_torus(0.43, 0.52), Vector3(0, 0.62, 0), dark)                                  # belt: blends torso into legs
	_add(_sphere(0.31), Vector3(0, 1.86, 0), dark)                                       # helm
	_add(_box(Vector3(0.36, 0.06, 0.06)), Vector3(0, 1.88, -0.28), _glow())              # visor slit
	_add(_box(Vector3(0.07, 0.07, 0.5)), Vector3(0, 2.16, 0.02), _glow())                # helm crest (top-visible glow)
	_add(_box(Vector3(0.34, 0.42, 0.06)), Vector3(0, 1.15, -0.43), _glow())              # kiln door
	for side in [-1.0, 1.0]:
		_add(_dome(0.34), Vector3(0.6 * side, 1.5, 0), dark, Vector3(1.0, 0.7, 1.15))  # domed pauldrons
		_add(_dome(0.1), Vector3(0.6 * side, 1.73, 0.05), _glow(), Vector3(1.6, 0.6, 1.0))  # shoulder vents (top-visible glow)
	_add(_cylinder(0.06, 1.3), Vector3(0.8, 0.95, -0.1), Toon.material(WOOD))            # hammer handle
	_add(_cylinder(0.2, 0.62), Vector3(0.8, 1.6, -0.1), dark, Vector3.ONE, Vector3(0, 0, 90))  # barrel hammer head
	_add(_cylinder(0.44, 0.09), Vector3(-0.8, 1.0, -0.05), Toon.material(IRON), Vector3.ONE, Vector3(0, 0, 90))  # round shield
	_add(_cylinder(0.22, 0.1), Vector3(-0.86, 1.0, -0.05), Toon.material(accent, 0.3), Vector3.ONE, Vector3(0, 0, 90))  # team emblem
	_embers = _make_embers()
	add_child(_embers)


## Kindled on/off: grow, scorch the armour, flare the glow, emit embers.
func set_form(active: bool, form_scale := 1.4) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "scale", Vector3.ONE * (form_scale if active else 1.0), 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_body_material, "albedo_color", SCORCHED if active else IRON, 0.35)
	for material in _glow_materials:
		_tween.tween_property(material, "emission_energy_multiplier", 4.0 if active else 1.0, 0.35)
	_embers.emitting = active


## Expanding shockwave ring for Bellows Slam / Eruption.
func play_slam(radius: float, hot: bool) -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.85
	torus.outer_radius = 1.0
	torus.rings = 40
	torus.ring_segments = 4
	ring.mesh = torus
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = EMBER if hot else Color(0.95, 0.9, 0.75, 0.85)
	ring.material_override = material
	get_parent().get_parent().add_child(ring)  # world space: unaffected by model scale and rotation
	ring.global_position = global_position + Vector3(0, 0.1, 0)
	ring.scale = Vector3(radius * 0.3, 1.0, radius * 0.3)
	var tween := ring.create_tween()
	tween.tween_property(ring, "scale", Vector3(radius, 1.0, radius), 0.25)
	tween.parallel().tween_property(material, "albedo_color:a", 0.0, 0.3)
	tween.tween_callback(ring.queue_free)


func _add(mesh: Mesh, position_: Vector3, material: Material, scale_ := Vector3.ONE, rotation_deg := Vector3.ZERO) -> void:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = position_
	part.scale = scale_
	part.rotation_degrees = rotation_deg
	part.material_override = material
	add_child(part)


func _glow() -> StandardMaterial3D:
	var material := Toon.material(EMBER, 0.0)
	material.emission_enabled = true
	material.emission = EMBER
	material.emission_energy_multiplier = 1.0
	_glow_materials.append(material)
	return material


func _make_embers() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.amount = 40
	particles.lifetime = 1.0
	particles.position.y = 1.2
	particles.emitting = false
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.6
	process.gravity = Vector3(0, 2.0, 0)
	process.scale_min = 0.5
	process.scale_max = 1.0
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(0.12, 0.12)
	var spark := StandardMaterial3D.new()
	spark.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	spark.albedo_color = EMBER
	quad.material = spark
	particles.draw_pass_1 = quad
	return particles


static func _capsule(radius: float, height: float) -> CapsuleMesh:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh.rings = 6
	return mesh


static func _sphere(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 24
	mesh.rings = 12
	return mesh


## Half sphere, flat side down — smooth rounded armour plates.
static func _dome(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius
	mesh.is_hemisphere = true
	mesh.radial_segments = 20
	mesh.rings = 6
	return mesh


static func _torus(inner: float, outer: float) -> TorusMesh:
	var mesh := TorusMesh.new()
	mesh.inner_radius = inner
	mesh.outer_radius = outer
	mesh.rings = 24
	mesh.ring_segments = 8
	return mesh


static func _box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh


static func _cylinder(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 20
	mesh.rings = 1
	return mesh
