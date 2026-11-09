class_name HeroAnimator
extends Node
## Procedural animation for a hero's model, driven by how the hero actually
## moves — so network puppets animate the same way. Run cycle (bob, lean into
## the motion, sway), idle breathing, smooth turning, an attack swing of the
## weapon pivot, a cast pose, a flinch when hit, a fall when killed and a rise
## on respawn, plus a glowing aura while transformed.
## It moves the model's position and X/Z rotation only: the hero owns facing
## (through target_yaw) and the form owns scale.

const TURN_SPEED := 16.0
const ATTACK_TIME := 0.3
const CAST_TIME := 0.45
const DEATH_TIME := 0.6

var hero: Node3D
var model: Node3D
## Where the model should face (radians); the animator turns it there smoothly.
var target_yaw := 0.0

var _last_pos := Vector3.ZERO
var _speed := 0.0
var _phase := 0.0
var _clock := 0.0
var _attack := 0.0
var _cast := 0.0
var _flinch := 0.0
var _dying := -1.0
var _last_hp := 0.0
var _aura: MeshInstance3D
var _aura_material: StandardMaterial3D


func setup(target: Node3D, target_model: Node3D) -> void:
	hero = target
	model = target_model
	target_yaw = model.rotation.y
	_last_pos = hero.global_position
	_last_hp = hero.hp
	hero.health_changed.connect(_on_health)
	_build_aura()


func play(kind: String) -> void:
	match kind:
		"attack":
			_attack = ATTACK_TIME
			if hero.is_inside_tree():  # a quick swing trail in the hero's colour
				var color: Color = _aura_material.albedo_color if _aura_material else Color.WHITE
				UnitFx.slash(hero.get_parent(), hero.global_position, model.rotation.y, 1.8, Color(color.r, color.g, color.b, 0.55))
		"cast":
			_cast = CAST_TIME
		"hit":
			if _flinch <= 0.05:
				_flinch = 0.25


## Killed: topple backward and sink, then hide the hero.
func die() -> void:
	_dying = 0.0
	_attack = 0.0
	_cast = 0.0


## Back from the dead: pop up at the spawn point.
func respawn() -> void:
	_dying = -1.0
	hero.visible = true
	model.rotation.x = 0.0
	model.rotation.z = 0.0
	model.position = Vector3.ZERO
	var target_scale := model.scale
	model.scale = target_scale * 0.25
	model.create_tween().tween_property(model, "scale", target_scale, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if model == null:
		return
	_clock += delta
	model.rotation.y = lerp_angle(model.rotation.y, target_yaw, minf(delta * TURN_SPEED, 1.0))
	if _dying >= 0.0:
		_animate_death(delta)
		return

	var moved: Vector3 = hero.global_position - _last_pos
	moved.y = 0.0
	_last_pos = hero.global_position
	var step_speed: float = moved.length() / maxf(delta, 0.0001)
	if step_speed > 40.0:
		step_speed = 0.0  # a teleport (respawn, duel), not running
	_speed = lerpf(_speed, step_speed, minf(delta * 10.0, 1.0))
	var run := clampf(_speed / 6.0, 0.0, 1.4)
	if run > 0.08:
		_phase += delta * (7.0 + _speed * 1.2)

	_attack = maxf(_attack - delta, 0.0)
	_cast = maxf(_cast - delta, 0.0)
	_flinch = maxf(_flinch - delta, 0.0)
	var strike := _curve(1.0 - _attack / ATTACK_TIME) if _attack > 0.0 else 0.0
	var cast := sin((1.0 - _cast / CAST_TIME) * PI) if _cast > 0.0 else 0.0

	var bob := absf(sin(_phase)) * 0.13 * run + sin(_clock * 2.2) * 0.025 * (1.0 - minf(run, 1.0))
	var forward := Vector3(0, 0, -1).rotated(Vector3.UP, model.rotation.y)
	model.position = Vector3(0, bob + cast * 0.28, 0) + forward * (maxf(strike, 0.0) * 0.22)
	model.rotation.x = -0.2 * minf(run, 1.0) - 0.22 * maxf(strike, 0.0) + 0.3 * _flinch / 0.25 + 0.18 * cast
	model.rotation.z = sin(_phase) * 0.08 * minf(run, 1.0)

	if "weapon_pivot" in model:
		var pivot: Node3D = model.weapon_pivot
		var swing := -1.5 * strike - 2.0 * cast
		if model.swing_axis == "y":
			pivot.rotation = Vector3(0, swing * 1.1 + sin(_phase) * 0.15 * run, 0)
		else:
			pivot.rotation = Vector3(swing + sin(_phase) * 0.12 * run, 0, 0)

	if _aura:
		var on: bool = hero.in_form and hero.visible
		_aura.visible = on
		if on:
			var pulse := 0.5 + 0.5 * sin(_clock * 6.0)
			_aura.scale = Vector3.ONE * (1.0 + 0.12 * pulse) * Vector3(1, 0.06, 1)
			_aura_material.albedo_color.a = 0.35 + 0.35 * pulse


## Wind up (back), strike hard (forward), recover: −0.4 → 1 → 0 over the swing.
static func _curve(t: float) -> float:
	if t < 0.25:
		return -0.4 * sin(t / 0.25 * PI * 0.5)
	if t < 0.5:
		return lerpf(-0.4, 1.0, (t - 0.25) / 0.25)
	return lerpf(1.0, 0.0, (t - 0.5) / 0.5)


func _animate_death(delta: float) -> void:
	_dying += delta
	var t := clampf(_dying / DEATH_TIME, 0.0, 1.0)
	model.rotation.x = lerpf(model.rotation.x, 1.35, minf(delta * 9.0, 1.0))
	model.position.y = lerpf(0.0, -0.35, t)
	if _aura:
		_aura.visible = false
	if _dying >= DEATH_TIME + 0.15 and hero.visible:
		hero.visible = false


func _on_health(hp: float, _max_hp: float, _shield: float) -> void:
	if hp < _last_hp - 1.0:
		play("hit")
	_last_hp = hp


func _build_aura() -> void:
	var color := Color(1.0, 0.7, 0.3)
	if "glow_color" in model:
		color = model.glow_color
	elif "EMBER" in model:
		color = model.EMBER
	_aura = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.75
	torus.outer_radius = 1.05
	torus.rings = 32
	torus.ring_segments = 4
	_aura.mesh = torus
	_aura_material = StandardMaterial3D.new()
	_aura_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_aura_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_aura_material.albedo_color = Color(color.r, color.g, color.b, 0.5)
	_aura.material_override = _aura_material
	_aura.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_aura.position.y = 0.06
	_aura.visible = false
	hero.add_child(_aura)
