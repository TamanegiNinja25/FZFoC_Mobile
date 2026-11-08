extends Node3D
## Phone stress test for the high-poly stylized budget (art direction, 2026-11-08):
## 6 heroes at ~40k triangles with automatic LODs, toon shading, particle
## effects and shadows, seen from the game camera. Run it on the target phone
## and read the numbers on screen.

const HERO_RADIAL_SEGMENTS := 96
const HERO_RINGS := 69  # 96 × 69 ≈ 40k triangles at full detail
const GAME_CAMERA := Vector3(0, 14, 10)
const CLOSE_CAMERA := Vector3(0, 4, 6)
const COLORS := [Color(0.35, 0.55, 0.95), Color(0.95, 0.4, 0.35), Color(0.4, 0.85, 0.45),
		Color(1.0, 0.75, 0.2), Color(0.7, 0.45, 0.95), Color(0.3, 0.85, 0.9)]

var hero_mesh: ArrayMesh
var hero_triangles := 0
var hero_lod_levels := 0
var heroes: Array[Node3D] = []

var _lod_on := true
var _effects_on := true
var _close_camera := false
## 0 = off; otherwise the number of sun-shadow cascades (phones default to 2).
var shadow_cascades := Platform.shadow_cascades()
var _time := 0.0
var _frame_times: Array[float] = []

## Benchmark mode: `godot --path Prototype res://scenes/stress_test.tscn -- --benchmark`
## runs each configuration in BENCH_STEPS for 3 s, prints the results and quits.
var _benchmark := "--benchmark" in OS.get_cmdline_user_args()
var _bench_step := 0
var _bench_clock := 0.0
var _bench_samples: Array[float] = []
## GPU and CPU render time per frame, measured by the engine. Unlike FPS this
## isn't capped by vsync, so it shows the headroom left on a 60 Hz phone.
var _bench_gpu: Array[float] = []
var _bench_cpu: Array[float] = []

var _sun: DirectionalLight3D
var _camera: Camera3D
var _stats := Label.new()
var _buttons := {}


func _ready() -> void:
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)
	Platform.apply_render_scale(get_viewport())
	hero_mesh = _build_hero_mesh()
	_build_world()
	_set_hero_count(6)
	_build_hud()


func _process(delta: float) -> void:
	_time += delta
	for i in heroes.size():
		var angle := _time * 0.6 + TAU * i / heroes.size()
		var hero := heroes[i]
		hero.position = Vector3(cos(angle) * 4.0, 0.0, sin(angle) * 4.0)
		hero.rotation.y = -angle
	_frame_times.append(delta)
	if _frame_times.size() > 180:
		_frame_times.pop_front()
	_update_stats()
	if _benchmark:
		_tick_benchmark(delta)


const BENCH_STEPS := [
	{"label": "6 heroes, game camera, LOD on, 4 casc.", "heroes": 6, "lod": true, "close": false, "cascades": 4},
	{"label": "6 heroes, game camera, LOD on, 2 casc.", "heroes": 6, "lod": true, "close": false, "cascades": 2},
	{"label": "6 heroes, close camera, 2 casc.", "heroes": 6, "lod": true, "close": true, "cascades": 2},
	{"label": "6 heroes, LOD off, 4 casc.", "heroes": 6, "lod": false, "close": false, "cascades": 4},
	{"label": "6 heroes, LOD off, 2 casc.", "heroes": 6, "lod": false, "close": false, "cascades": 2},
	{"label": "12 heroes, LOD off, 2 casc.", "heroes": 12, "lod": false, "close": false, "cascades": 2},
	# Isolate per-pixel cost: same scene as step 2 with fewer pixels, or without particles.
	{"label": "6 heroes, LOD on, 2 casc., 90% res.", "heroes": 6, "lod": true, "close": false, "cascades": 2, "scale": 0.9},
	{"label": "12 heroes, LOD off, 2 casc., 90% res.", "heroes": 12, "lod": false, "close": false, "cascades": 2, "scale": 0.9},
	{"label": "6 heroes, LOD on, 2 casc., 75% res.", "heroes": 6, "lod": true, "close": false, "cascades": 2, "scale": 0.75},
	{"label": "6 heroes, LOD on, 2 casc., no effects", "heroes": 6, "lod": true, "close": false, "cascades": 2, "effects": false},
]


## Short resolution comparison (`-- --benchmark --bench-res`): the phone-default
## scene at three render scales, run twice so clock drift between steps shows up.
const BENCH_RES_STEPS := [
	{"label": "round 1: 100% res.", "heroes": 6, "lod": true, "close": false, "cascades": 2, "scale": 1.0},
	{"label": "round 1: 90% res.", "heroes": 6, "lod": true, "close": false, "cascades": 2, "scale": 0.9},
	{"label": "round 1: 75% res.", "heroes": 6, "lod": true, "close": false, "cascades": 2, "scale": 0.75},
	{"label": "round 2: 100% res.", "heroes": 6, "lod": true, "close": false, "cascades": 2, "scale": 1.0},
	{"label": "round 2: 90% res.", "heroes": 6, "lod": true, "close": false, "cascades": 2, "scale": 0.9},
	{"label": "round 2: 75% res.", "heroes": 6, "lod": true, "close": false, "cascades": 2, "scale": 0.75},
]
var _steps: Array = BENCH_RES_STEPS if "--bench-res" in OS.get_cmdline_user_args() else BENCH_STEPS


func _apply_config(config: Dictionary) -> void:
	if heroes.size() != config.heroes:
		_set_hero_count(config.heroes)
	_lod_on = config.lod
	get_viewport().mesh_lod_threshold = 1.0 if _lod_on else 0.0
	_close_camera = config.close
	_place_camera()
	set_shadow_cascades(config.cascades)
	get_viewport().scaling_3d_scale = config.get("scale", 1.0)
	var effects_wanted: bool = config.get("effects", true)
	if _effects_on != effects_wanted:
		_toggle_effects()


func _tick_benchmark(delta: float) -> void:
	if _bench_step == 0 and _bench_clock == 0.0:
		_apply_config(_steps[0])
	_bench_clock += delta
	if _bench_clock > 1.0:  # skip the first second of each step (warm-up)
		_bench_samples.append(delta)
		var rid := get_viewport().get_viewport_rid()
		_bench_gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(rid))
		_bench_cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(rid))
	if _bench_clock < 4.0:
		return
	var total := 0.0
	var worst := 0.0
	for t in _bench_samples:
		total += t
		worst = maxf(worst, t)
	var avg := total / maxf(_bench_samples.size(), 1)
	var triangles := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	var gpu_ms := _average(_bench_gpu)
	var cpu_ms := _average(_bench_cpu)
	print("BENCH | %-40s | %5.1f FPS | avg %5.2f ms | worst %5.2f ms | GPU %5.2f ms | CPU %5.2f ms | %4dk tris" % [_steps[_bench_step].label, 1.0 / avg, avg * 1000.0, worst * 1000.0, gpu_ms, cpu_ms, triangles / 1000])
	_bench_step += 1
	_bench_clock = 0.0001
	_bench_samples.clear()
	_bench_gpu.clear()
	_bench_cpu.clear()
	if _bench_step < _steps.size():
		_apply_config(_steps[_bench_step])
	else:
		print("BENCH | device: %s | GPU: %s" % [OS.get_model_name(), RenderingServer.get_video_adapter_name()])
		get_tree().quit()


func _average(values: Array[float]) -> float:
	var total := 0.0
	for v in values:
		total += v
	return total / maxf(values.size(), 1)


## Builds a ~40k-triangle capsule and lets Godot generate LODs for it,
## the same way it does for imported models.
func _build_hero_mesh() -> ArrayMesh:
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.5
	capsule.height = 2.0
	capsule.radial_segments = HERO_RADIAL_SEGMENTS
	capsule.rings = HERO_RINGS
	var arrays := capsule.get_mesh_arrays()
	hero_triangles = arrays[Mesh.ARRAY_INDEX].size() / 3
	var importer := ImporterMesh.new()
	importer.add_surface(Mesh.PRIMITIVE_TRIANGLES, arrays)
	importer.generate_lods(25.0, 60.0, [])
	hero_lod_levels = importer.get_surface_lod_count(0)
	return importer.get_mesh()


func _make_hero(color: Color) -> Node3D:
	var root := Node3D.new()
	var body := MeshInstance3D.new()
	body.mesh = hero_mesh
	body.position.y = 1.0
	body.material_override = Toon.material(color)
	root.add_child(body)

	var particles := GPUParticles3D.new()
	particles.name = "Effect"
	particles.amount = 48
	particles.lifetime = 1.2
	particles.position.y = 1.0
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.7
	process.gravity = Vector3(0, 1.5, 0)
	process.scale_min = 0.6
	process.scale_max = 1.2
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(0.15, 0.15)
	var spark := StandardMaterial3D.new()
	spark.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	spark.albedo_color = color.lightened(0.4)
	quad.material = spark
	particles.draw_pass_1 = quad
	particles.emitting = _effects_on
	root.add_child(particles)
	return root


func _set_hero_count(count: int) -> void:
	for hero in heroes:
		hero.queue_free()
	heroes.clear()
	for i in count:
		var hero := _make_hero(COLORS[i % COLORS.size()])
		add_child(hero)
		heroes.append(hero)


func _build_world() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(30, 30)
	ground.mesh = plane
	ground.material_override = Toon.material(Color(0.32, 0.36, 0.3), 0.0)
	add_child(ground)

	_sun = DirectionalLight3D.new()
	_sun.rotation_degrees = Vector3(-55, 30, 0)
	Platform.apply_sun_shadows(_sun, shadow_cascades)
	add_child(_sun)

	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.12, 0.13, 0.16)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.6, 0.6, 0.65)
	var world_env := WorldEnvironment.new()
	world_env.environment = environment
	add_child(world_env)

	_camera = Camera3D.new()
	_camera.fov = 50
	add_child(_camera)
	_place_camera()


func _place_camera() -> void:
	_camera.position = CLOSE_CAMERA if _close_camera else GAME_CAMERA
	_camera.look_at(Vector3(0, 1, 0), Vector3.UP)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	_stats.position = Vector2(24, 20)
	_stats.add_theme_font_size_override("font_size", 22)
	layer.add_child(_stats)

	var bar := HBoxContainer.new()
	bar.anchor_top = 1.0
	bar.anchor_bottom = 1.0
	bar.anchor_right = 1.0
	bar.offset_left = 16
	bar.offset_right = -16
	bar.offset_top = -100
	bar.offset_bottom = -16
	bar.add_theme_constant_override("separation", 10)
	layer.add_child(bar)

	for spec in [["lod", _toggle_lod], ["effects", _toggle_effects], ["shadows", _toggle_shadows],
			["heroes", _toggle_heroes], ["camera", _toggle_camera], ["back", _back]]:
		var button := Button.new()
		button.custom_minimum_size = Vector2(150, 84)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(spec[1])
		bar.add_child(button)
		_buttons[spec[0]] = button
	_refresh_buttons()


func _refresh_buttons() -> void:
	_buttons["lod"].text = "LOD: %s" % ("ON" if _lod_on else "OFF")
	_buttons["effects"].text = "Effects: %s" % ("ON" if _effects_on else "OFF")
	_buttons["shadows"].text = "Shadows: %s" % ("OFF" if shadow_cascades == 0 else "%d casc." % shadow_cascades)
	_buttons["heroes"].text = "Heroes: %d" % heroes.size()
	_buttons["camera"].text = "Camera: %s" % ("CLOSE" if _close_camera else "GAME")
	_buttons["back"].text = "Back"


func _toggle_lod() -> void:
	_lod_on = not _lod_on
	# 0 forces full detail everywhere; 1.0 is Godot's default LOD behaviour.
	get_viewport().mesh_lod_threshold = 1.0 if _lod_on else 0.0
	_refresh_buttons()


func _toggle_effects() -> void:
	_effects_on = not _effects_on
	for hero in heroes:
		var effect := hero.get_node("Effect") as GPUParticles3D
		effect.emitting = _effects_on
		effect.visible = _effects_on
	_refresh_buttons()


## Cycles 2 → 4 → off → 2, so the phone default can be compared on the device.
func _toggle_shadows() -> void:
	match shadow_cascades:
		2: set_shadow_cascades(4)
		4: set_shadow_cascades(0)
		_: set_shadow_cascades(2)


func set_shadow_cascades(cascades: int) -> void:
	shadow_cascades = cascades
	Platform.apply_sun_shadows(_sun, cascades)
	if not _buttons.is_empty():
		_refresh_buttons()


func _toggle_heroes() -> void:
	_set_hero_count(12 if heroes.size() == 6 else 6)
	_refresh_buttons()


func _toggle_camera() -> void:
	_close_camera = not _close_camera
	_place_camera()
	_refresh_buttons()


func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _update_stats() -> void:
	var fps := Engine.get_frames_per_second()
	var worst := 0.0
	var total := 0.0
	for t in _frame_times:
		worst = maxf(worst, t)
		total += t
	var avg_ms := 1000.0 * total / maxf(_frame_times.size(), 1)
	var triangles := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	var draw_calls := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var verdict := "SMOOTH (60 FPS target met)" if fps >= 55 else ("PLAYABLE (30 FPS target met)" if fps >= 28 else "TOO SLOW — lower the budget")
	_stats.text = "\n".join([
		"STRESS TEST — %d heroes × %dk triangles (%d LOD levels) — %s settings, %d%% 3D resolution" % [heroes.size(), hero_triangles / 1000, hero_lod_levels, "phone" if Platform.is_phone() else "desktop", roundi(get_viewport().scaling_3d_scale * 100.0)],
		"%d FPS   avg %.1f ms   worst %.1f ms (last 3 s)" % [fps, avg_ms, worst * 1000.0],
		"Rendered: %dk triangles, %d draw calls" % [triangles / 1000, draw_calls],
		"Device: %s   GPU: %s" % [OS.get_model_name(), RenderingServer.get_video_adapter_name()],
		verdict,
	])
