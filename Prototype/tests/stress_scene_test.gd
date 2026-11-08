extends SceneTree
## Headless check that the stress scene is built to budget:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/stress_scene_test.gd
## It can't measure frame rate (no GPU in headless mode); run the scene on the
## target phone for that.

var _scene: Node
var _frames := 0
var _failures: Array[String] = []


func _initialize() -> void:
	_scene = load("res://scenes/stress_test.tscn").instantiate()
	root.add_child(_scene)


func _process(_delta: float) -> bool:
	_frames += 1
	if _frames == 10:
		_check(_scene.heroes.size() == 6, "6 heroes spawned")
		_check(_scene.hero_triangles >= 35000 and _scene.hero_triangles <= 50000,
				"hero mesh within the 30–50k budget (%d triangles)" % _scene.hero_triangles)
		_check(_scene.hero_lod_levels >= 2, "automatic LODs generated (%d levels)" % _scene.hero_lod_levels)
		_check(_scene.heroes[0].get_node("Effect") is GPUParticles3D, "each hero has a particle effect")
		var material: StandardMaterial3D = _scene.heroes[0].get_child(0).material_override
		_check(material.diffuse_mode == BaseMaterial3D.DIFFUSE_TOON, "heroes use toon shading")
		_scene._toggle_heroes()
	elif _frames == 20:
		_check(_scene.heroes.size() == 12, "hero toggle doubles to 12")
		_scene._toggle_lod()
		_check(_scene.get_viewport().mesh_lod_threshold == 0.0, "LOD toggle forces full detail")
		_scene._toggle_effects()
		_scene._toggle_shadows()
		_scene._toggle_camera()
	elif _frames == 40:
		for failure in _failures:
			printerr("FAIL: " + failure)
		print("STRESS SCENE TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
		quit(1 if _failures.size() else 0)
	return false


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
