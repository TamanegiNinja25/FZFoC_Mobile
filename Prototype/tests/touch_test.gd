extends SceneTree
## Headless check of the touch joystick and render scale:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/touch_test.gd
## Simulates a finger landing in the joystick zone, dragging right, and lifting.

var _main: Node
var _joystick: TouchJoystick
var _frames := 0
var _start_x := 0.0
var _failures: Array[String] = []


func _initialize() -> void:
	_main = load("res://scenes/main.tscn").instantiate()
	root.add_child(_main)


func _process(_delta: float) -> bool:
	_frames += 1
	match _frames:
		5:
			_check(is_equal_approx(_main.get_viewport().scaling_3d_scale, Platform.render_scale()), "3D render scale matches platform (%.2f)" % Platform.render_scale())
			_joystick = _main.hud.joystick
			var size := _joystick.get_viewport_rect().size
			# A touch on the right half must not grab the stick.
			_joystick.handle_input(_touch(0, Vector2(size.x * 0.8, size.y * 0.8), true))
			_check(not _joystick.is_active(), "touch outside the zone is ignored")
			_joystick.handle_input(_touch(0, Vector2(size.x * 0.8, size.y * 0.8), false))
			# Finger lands bottom-left, then drags right past full travel.
			var start := Vector2(size.x * 0.2, size.y * 0.75)
			_joystick.handle_input(_touch(1, start, true))
			_check(_joystick.is_active(), "touch in the zone grabs the stick")
			_joystick.handle_input(_drag(1, start + Vector2(_joystick.radius * 2.0, 0)))
			var v := Input.get_vector("move_left", "move_right", "move_up", "move_down")
			_check(v.x > 0.9 and absf(v.y) < 0.05, "drag right → move vector ≈ (1, 0), got %s" % v)
			_start_x = _main.hero.global_position.x
		45:
			_check(_main.hero.global_position.x > _start_x + 1.0, "hero moved right (%.2f → %.2f)" % [_start_x, _main.hero.global_position.x])
			_joystick.handle_input(_touch(1, Vector2.ZERO, false))
			var v := Input.get_vector("move_left", "move_right", "move_up", "move_down")
			_check(v == Vector2.ZERO and not _joystick.is_active(), "lifting the finger stops input")
			_start_x = _main.hero.global_position.x
		55:
			_start_x = _main.hero.global_position.x  # after the short ease-out
		70:
			_check(absf(_main.hero.global_position.x - _start_x) < 0.01, "hero comes to rest after release")
			for failure in _failures:
				printerr("FAIL: " + failure)
			print("TOUCH TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
			quit(1 if _failures.size() else 0)
	return false


func _touch(index: int, position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	return event


func _drag(index: int, position: Vector2) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = position
	return event


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
