extends Node3D
## Builds the greybox arena: ground, light, camera, one hero, training dummies and the HUD.

const CAMERA_OFFSET := Vector3(0, 14, 10)
var hero: Hero
var hud: Hud
var pause_menu: PauseMenu
var camera: Camera3D
var _sun: DirectionalLight3D


func _ready() -> void:
	# Exported builds can't open a scene named on the command line, so the
	# benchmark build passes only `-- --benchmark` and is redirected here.
	if "--benchmark" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://scenes/stress_test.tscn")
		return
	Controls.register()
	get_node("/root/Sfx").play_music("battle", -10.0)
	_build_world()
	GameSettings.apply_to_scene(get_viewport(), _sun)
	GameSettings.changed.connect(func(): GameSettings.apply_to_scene(get_viewport(), _sun))

	hero = Hero.new()
	hero.name = "Hero"
	hero.definition = Roster.create(Session.hero_id)
	hero.in_shop_range = true  # training ground: shop anywhere
	add_child(hero)

	for spot in [Vector3(4, 0, -3), Vector3(-5, 0, -4), Vector3(0, 0, -8)]:
		var dummy := Dummy.new()
		dummy.position = spot
		add_child(dummy)

	hud = Hud.new()
	add_child(hud)
	hud.setup(hero)

	pause_menu = PauseMenu.new()
	add_child(pause_menu)
	hud.pause_requested.connect(pause_menu.open)


func _process(_delta: float) -> void:
	if hero == null:
		return
	camera.global_position = hero.global_position + CAMERA_OFFSET
	camera.look_at(hero.global_position, Vector3.UP)


func _build_world() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(40, 40)
	ground.mesh = plane
	ground.material_override = Toon.material(Color(0.32, 0.36, 0.3), 0.0)
	add_child(ground)

	_sun = DirectionalLight3D.new()
	_sun.rotation_degrees = Vector3(-55, 30, 0)
	add_child(_sun)

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
