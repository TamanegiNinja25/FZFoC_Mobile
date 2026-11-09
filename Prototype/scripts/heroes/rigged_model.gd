class_name RiggedModel
extends Node3D
## A rigged, animated character (KayKit, CC0 — see assets/thirdparty/CREDITS.md)
## behind the same interface as the primitive hero models, so Hero and
## HeroAnimator drive either. It shows only the weapons a hero carries, can
## put separate weapon models in empty hands, loops Idle / Running at a speed
## that matches the hero's movement, and plays one-shot attack, cast, hit,
## death and spawn animations before blending back. Faces −Z like the others.

const IDLE := "Idle"
const RUN := "Running_A"

var scene_path := ""
## Hand-slot meshes to keep visible; every other hand-slot mesh is hidden.
var keep_parts: Array = []
## Extra weapon models for empty hands: [["handslot_r", "res://…gltf"], …].
var attach: Array = []
var attack_anim := "1H_Melee_Attack_Chop"
var cast_anim := "Spellcast_Raise"
var spawn_anim := ""
var height := 2.2
## Team colour (set by Hero) and the colour of the form aura.
var accent := Color(0.3, 0.55, 1.0)
var glow_color := Color(1.0, 0.7, 0.3)

var _instance: Node3D
var _player: AnimationPlayer
var _busy := 0.0
var _running := false
var _dead := false
var _tween: Tween


static func make(path: String, attack: String, cast: String, parts: Array, glow: Color, extra: Array = []) -> RiggedModel:
	var model := RiggedModel.new()
	model.scene_path = path
	model.attack_anim = attack
	model.cast_anim = cast
	model.keep_parts = parts
	model.glow_color = glow
	model.attach = extra
	return model


func _ready() -> void:
	var scene: PackedScene = load(scene_path)
	_instance = scene.instantiate()
	add_child(_instance)
	_instance.rotation.y = PI  # KayKit characters face +Z; heroes face −Z
	_instance.scale = Vector3.ONE * (height / 2.47)
	for slot in _instance.find_children("*", "BoneAttachment3D", true, false):
		if not slot.name.begins_with("handslot"):
			continue
		for part in slot.get_children():
			if part is MeshInstance3D:
				part.visible = keep_parts.has(String(part.name))
		for spec in attach:
			if slot.name == spec[0]:
				var weapon: Node3D = (load(spec[1]) as PackedScene).instantiate()
				slot.add_child(weapon)
	for mesh in _instance.find_children("*", "MeshInstance3D", true, false):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	var players := _instance.find_children("*", "AnimationPlayer", true, false)
	if players.size() > 0:
		_player = players[0]
		for loop_name in [IDLE, RUN, "Idle_Combat"]:
			if _player.has_animation(loop_name):
				_player.get_animation(loop_name).loop_mode = Animation.LOOP_LINEAR
		_player.play(IDLE)
		if spawn_anim != "" and _player.has_animation(spawn_anim):
			play_anim("spawn")


func _process(delta: float) -> void:
	if _busy > 0.0:
		_busy -= delta
		if _busy <= 0.0 and not _dead:
			_play_loop(true)


## Idle or Running, with the run cycle sped up or slowed to match `speed`.
func set_locomotion(speed: float) -> void:
	if _player == null or _dead:
		return
	_running = speed > 0.6
	if _busy <= 0.0:
		_play_loop(false)
	if _running and _player.current_animation == RUN:
		_player.speed_scale = clampf(speed / 6.0, 0.6, 1.8)
	elif _busy <= 0.0:
		_player.speed_scale = 1.0


func play_anim(kind: String) -> void:
	if _player == null:
		return
	var anim := ""
	match kind:
		"attack":
			anim = attack_anim
		"cast":
			anim = cast_anim
		"hit":
			if _busy > 0.0:
				return  # don't interrupt an attack or a cast
			anim = "Hit_A"
		"death":
			anim = "Death_A"
			_dead = true
		"spawn":
			anim = spawn_anim
	if anim == "" or not _player.has_animation(anim):
		return
	_player.speed_scale = 1.0 if kind != "attack" else 1.4
	_player.play(anim, 0.08)
	_busy = _player.get_animation(anim).length / _player.speed_scale
	if kind == "death":
		_busy = INF


## Back from the dead (Hero respawn).
func revive() -> void:
	_dead = false
	_busy = 0.0
	_play_loop(true)


func _play_loop(force: bool) -> void:
	var wanted := RUN if _running else IDLE
	if force or _player.current_animation != wanted:
		_player.speed_scale = 1.0
		_player.play(wanted, 0.15)


func set_form(active: bool, form_scale := 1.4) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector3.ONE * (form_scale if active else 1.0), 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func play_slam(radius: float, hot: bool) -> void:
	Effects.ring(get_parent().get_parent(), global_position, radius, glow_color if hot else Color(0.95, 0.9, 0.75, 0.85))
