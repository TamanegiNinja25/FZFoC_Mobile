class_name Dummy
extends CharacterBody3D
## Training dummy: stands still, hits the hero back when in range, respawns after dying.

signal died

@export var max_hp := 600.0
@export var damage := 25.0
@export var attack_interval := 1.5
@export var attack_range := 3.0
@export var respawn_time := 4.0

var hp := 0.0
var _attack_cooldown := 0.0
var _dead_time := 0.0
var _label: Label3D


func _ready() -> void:
	add_to_group("enemies")
	hp = max_hp

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.0, 2.0, 1.0)
	shape.shape = box
	shape.position.y = 1.0
	add_child(shape)

	var body := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.0, 2.0, 1.0)
	body.mesh = mesh
	body.position.y = 1.0
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.25, 0.25)
	body.material_override = material
	add_child(body)

	_label = Label3D.new()
	_label.position.y = 2.6
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.font_size = 48
	add_child(_label)
	_update_label()


func _physics_process(delta: float) -> void:
	if _dead_time > 0.0:
		_dead_time -= delta
		if _dead_time <= 0.0:
			_respawn()
		return

	_attack_cooldown -= delta
	if _attack_cooldown > 0.0:
		return
	for node in get_tree().get_nodes_in_group("heroes"):
		var hero := node as Hero
		if hero and hero.is_alive() and global_position.distance_to(hero.global_position) <= attack_range:
			hero.take_damage(damage)
			_attack_cooldown = attack_interval
			return


## Returns {dealt: float, killed: bool}.
func take_damage(amount: float) -> Dictionary:
	if not is_alive():
		return {"dealt": 0.0, "killed": false}
	var dealt := minf(amount, hp)
	hp -= dealt
	_update_label()
	if hp <= 0.0:
		_die()
		return {"dealt": dealt, "killed": true}
	return {"dealt": dealt, "killed": false}


func is_alive() -> bool:
	return _dead_time <= 0.0


func _die() -> void:
	_dead_time = respawn_time
	visible = false
	died.emit()


func _respawn() -> void:
	hp = max_hp
	visible = true
	_update_label()


func _update_label() -> void:
	_label.text = "%d" % ceili(hp)
