extends Node3D
## Builds the greybox arena: ground, light, camera, one hero, training dummies and the HUD.

const CAMERA_OFFSET := Vector3(0, 14, 10)
const INPUTS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"transform": [KEY_SPACE],
	"skill_1": [KEY_Q],
	"skill_2": [KEY_E],
}

var hero: Hero
var hud: Hud
var camera: Camera3D


func _ready() -> void:
	# Exported builds can't open a scene named on the command line, so the
	# benchmark build passes only `-- --benchmark` and is redirected here.
	if "--benchmark" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://scenes/stress_test.tscn")
		return
	_register_inputs()
	Platform.apply_render_scale(get_viewport())
	_build_world()

	hero = Hero.new()
	hero.name = "Hero"
	hero.definition = Vael.new()
	add_child(hero)

	for spot in [Vector3(4, 0, -3), Vector3(-5, 0, -4), Vector3(0, 0, -8)]:
		var dummy := Dummy.new()
		dummy.position = spot
		add_child(dummy)

	hud = Hud.new()
	add_child(hud)
	hud.setup(hero)


func _process(_delta: float) -> void:
	if hero == null:
		return
	camera.global_position = hero.global_position + CAMERA_OFFSET
	camera.look_at(hero.global_position, Vector3.UP)


func _register_inputs() -> void:
	for action in INPUTS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in INPUTS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)


func _build_world() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(40, 40)
	ground.mesh = plane
	ground.material_override = Toon.material(Color(0.32, 0.36, 0.3), 0.0)
	add_child(ground)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 30, 0)
	Platform.apply_sun_shadows(sun)
	add_child(sun)

	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.12, 0.13, 0.16)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.6, 0.6, 0.65)
	var world_env := WorldEnvironment.new()
	world_env.environment = environment
	add_child(world_env)

	camera = Camera3D.new()
	camera.fov = 50
	add_child(camera)
	camera.position = CAMERA_OFFSET
	camera.look_at(Vector3.ZERO, Vector3.UP)
