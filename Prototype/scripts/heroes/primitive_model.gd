class_name PrimitiveModel
extends Node3D
## Base for hero models built from smooth primitives with the toon material:
## subclasses describe their parts in _build(); this class handles the team
## accent, glow parts, form animation and the shockwave effect. Faces −Z.
## Weapon parts go under `weapon_pivot` (add_weapon_part) so HeroAnimator can
## swing them: around X for an overhead strike, around Y for a sweep.

var accent := Color(0.3, 0.55, 1.0)
var body_color := Color(0.5, 0.5, 0.5)
var form_body_color := Color(0.4, 0.4, 0.4)
var glow_color := Color(1, 0.5, 0.1)
var particle_color := Color(1, 1, 1)
## The pivot weapon parts hang from, and how HeroAnimator swings it ("x" or "y").
var weapon_pivot := Node3D.new()
var weapon_pivot_at := Vector3(0, 1.3, 0)
var swing_axis := "x"

var _glow_materials: Array[StandardMaterial3D] = []
var _body_material: StandardMaterial3D
var _particles: GPUParticles3D
var _tween: Tween


func _ready() -> void:
	_setup_colors()
	_body_material = Toon.material(body_color)
	weapon_pivot.name = "WeaponPivot"
	weapon_pivot.position = weapon_pivot_at
	add_child(weapon_pivot)
	_build()
	_particles = _make_particles()
	add_child(_particles)


## Subclasses set body/glow/particle colours here, before parts are built.
func _setup_colors() -> void:
	pass


func _build() -> void:
	pass


func set_form(active: bool, form_scale := 1.4) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "scale", Vector3.ONE * (form_scale if active else 1.0), 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_body_material, "albedo_color", form_body_color if active else body_color, 0.35)
	for material in _glow_materials:
		_tween.tween_property(material, "emission_energy_multiplier", 4.0 if active else 1.0, 0.35)
	_particles.emitting = active


func play_slam(radius: float, hot: bool) -> void:
	Effects.ring(get_parent().get_parent(), global_position, radius, glow_color if hot else Color(0.95, 0.9, 0.75, 0.85))


func add_part(mesh: Mesh, at: Vector3, material: Material, scale_ := Vector3.ONE, rotation_deg := Vector3.ZERO) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = at
	part.scale = scale_
	part.rotation_degrees = rotation_deg
	part.material_override = material
	add_child(part)
	return part


## Like add_part, but hung from the weapon pivot (`at` is in model space).
func add_weapon_part(mesh: Mesh, at: Vector3, material: Material, scale_ := Vector3.ONE, rotation_deg := Vector3.ZERO) -> MeshInstance3D:
	var part := add_part(mesh, at - weapon_pivot_at, material, scale_, rotation_deg)
	remove_child(part)
	weapon_pivot.add_child(part)
	return part


func glow() -> StandardMaterial3D:
	var material := Toon.material(glow_color, 0.0)
	material.emission_enabled = true
	material.emission = glow_color
	material.emission_energy_multiplier = 1.0
	_glow_materials.append(material)
	return material


func _make_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.amount = 36
	particles.lifetime = 1.0
	particles.position.y = 1.2
	particles.emitting = false
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.7
	process.gravity = Vector3(0, 2.0, 0)
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(0.12, 0.12)
	var spark := StandardMaterial3D.new()
	spark.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	spark.albedo_color = particle_color
	quad.material = spark
	particles.draw_pass_1 = quad
	return particles


static func sphere(radius: float, height_scale := 1.0) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0 * height_scale
	mesh.radial_segments = 20
	mesh.rings = 10
	return mesh


static func dome(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius
	mesh.is_hemisphere = true
	mesh.radial_segments = 18
	mesh.rings = 6
	return mesh


static func capsule(radius: float, height: float) -> CapsuleMesh:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 20
	mesh.rings = 6
	return mesh


static func box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh


static func torus(inner: float, outer: float) -> TorusMesh:
	var mesh := TorusMesh.new()
	mesh.inner_radius = inner
	mesh.outer_radius = outer
	mesh.rings = 24
	mesh.ring_segments = 8
	return mesh


static func cone(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mesh.rings = 1
	return mesh
