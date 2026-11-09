class_name Projectile
extends Node3D
## A thrown or fired shot: flies straight and hits the first hostile unit in its
## path — or, piercing, every unit it passes once. Can stun, or pull the victim
## back to the shooter (a chain hook). On network clients it's visual only
## (the host applies the damage).

var owner_hero: Hero
var direction := Vector3.FORWARD
var speed := 18.0
var max_range := 12.0
var damage := 160.0
var visual_only := false
var pierce := false
var width := 1.1
var stun := 0.0
var pull := false
var color := Color(0.5, 0.45, 0.4)
var size := 0.38
var _travelled := 0.0
var _hit := {}


static func launch(hero: Hero, dir: Vector3, speed_: float, range_: float, damage_: float, visual := false) -> Projectile:
	var p := Projectile.new()
	p.owner_hero = hero
	p.direction = Vector3(dir.x, 0, dir.z).normalized()
	p.speed = speed_
	p.max_range = range_
	p.damage = damage_
	p.visual_only = visual
	hero.get_parent().add_child(p)
	p.global_position = hero.global_position + Vector3(0, 1.4, 0) + p.direction * 0.8
	return p


func configure(pierce_: bool, width_: float, stun_: float, pull_: bool, color_: Color, size_: float) -> void:
	pierce = pierce_
	width = width_
	stun = stun_
	pull = pull_
	color = color_
	size = size_
	if get_child_count() > 0:
		get_child(0).queue_free()
		_build()


func _ready() -> void:
	_build()


func _build() -> void:
	var rock := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = size
	sphere.height = size * 1.85
	sphere.radial_segments = 12
	sphere.rings = 6
	rock.mesh = sphere
	if color.v > 0.7:  # bright shots glow (arrows, bolts, waves); dull ones are rocks
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = color
		rock.material_override = material
		rock.scale = Vector3(0.6, 0.6, 1.8)  # stretched along the flight
	else:
		rock.material_override = Toon.material(color)
	add_child(rock)
	rotation.y = atan2(-direction.x, -direction.z)  # the stretched shot points where it flies


func _physics_process(delta: float) -> void:
	var step := speed * delta
	global_position += direction * step
	if color.v <= 0.7:
		rotation.x += delta * 12.0
	_travelled += step
	if not visual_only and is_instance_valid(owner_hero):
		for node in Creep.nearby(get_tree(), global_position, width + 1.0):
			if _hit.has(node) or not owner_hero.is_hostile(node) or not node.is_alive():
				continue
			var flat := Vector2(node.global_position.x - global_position.x, node.global_position.z - global_position.z)
			if flat.length() <= width:
				_hit[node] = true
				owner_hero.deal_damage(node, damage)
				if stun > 0.0 and node.has_method("apply_stun"):
					node.apply_stun(stun)
				if pull and node.has_method("push") and is_instance_valid(owner_hero):
					var toward: Vector3 = owner_hero.global_position - node.global_position
					toward.y = 0.0
					node.push(toward.normalized() * maxf(toward.length() - 1.4, 0.0) / 0.3, 0.3)
				UnitFx.burst(get_parent(), node.global_position, color, 12, 4.0)
				if not pierce:
					queue_free()
					return
	if _travelled >= max_range:
		queue_free()
