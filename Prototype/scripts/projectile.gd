class_name Projectile
extends Node3D
## A thrown boulder: flies straight and hits the first hostile unit in its path.
## On network clients it's visual only (the host applies the damage).

var owner_hero: Hero
var direction := Vector3.FORWARD
var speed := 18.0
var max_range := 12.0
var damage := 160.0
var visual_only := false
var _travelled := 0.0


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


func _ready() -> void:
	var rock := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.38
	sphere.height = 0.7
	sphere.radial_segments = 12
	sphere.rings = 6
	rock.mesh = sphere
	rock.material_override = Toon.material(Color(0.5, 0.45, 0.4))
	add_child(rock)


func _physics_process(delta: float) -> void:
	var step := speed * delta
	global_position += direction * step
	rotation.x += delta * 12.0
	_travelled += step
	if not visual_only and is_instance_valid(owner_hero):
		for node in get_tree().get_nodes_in_group("units"):
			if owner_hero.is_hostile(node) and node.is_alive():
				var flat := Vector2(node.global_position.x - global_position.x, node.global_position.z - global_position.z)
				if flat.length() <= 1.1:
					owner_hero.deal_damage(node, damage)
					queue_free()
					return
	if _travelled >= max_range:
		queue_free()
