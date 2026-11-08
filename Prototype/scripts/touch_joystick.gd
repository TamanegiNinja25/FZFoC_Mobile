class_name TouchJoystick
extends Control
## Floating touch joystick for the left thumb. The stick appears wherever a
## finger lands in the lower-left zone and drives the existing move_* actions
## with analog strength, so the hero reads it through Input.get_vector()
## exactly like the keyboard.

## Maximum knob travel from the centre, in UI pixels.
@export var radius := 110.0
## Below this fraction of full travel the stick reports no movement.
@export var deadzone := 0.15
## Touches that start left of this fraction of the screen width…
@export var zone_width := 0.45
## …and below this fraction of its height grab the stick (keeps the HUD bars free).
@export var zone_top := 0.3

## Current direction and strength, length 0..1.
var output := Vector2.ZERO

var _finger := -1
var _base := Vector2.ZERO
var _knob := Vector2.ZERO
var _rest := Vector2.ZERO


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_rest()
	get_viewport().size_changed.connect(_update_rest)


func is_active() -> bool:
	return _finger != -1


func _input(event: InputEvent) -> void:
	handle_input(event)


## Public entry point so tests can feed touch events directly.
func handle_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _finger == -1 and _in_zone(event.position):
			_finger = event.index
			_base = event.position
			_move_knob(event.position)
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == _finger:
			_release()
	elif event is InputEventScreenDrag and event.index == _finger:
		_move_knob(event.position)
		get_viewport().set_input_as_handled()


func _in_zone(point: Vector2) -> bool:
	var size := get_viewport_rect().size
	return point.x < size.x * zone_width and point.y > size.y * zone_top


func _move_knob(point: Vector2) -> void:
	var offset := (point - _base).limit_length(radius)
	_knob = _base + offset
	var stick := offset / radius
	output = Vector2.ZERO if stick.length() < deadzone else stick
	_apply(output)
	queue_redraw()


func _release() -> void:
	_finger = -1
	output = Vector2.ZERO
	_apply(output)
	_base = _rest
	_knob = _rest
	queue_redraw()


func _apply(stick: Vector2) -> void:
	_set_axis("move_left", "move_right", stick.x)
	_set_axis("move_up", "move_down", stick.y)


func _set_axis(negative: StringName, positive: StringName, value: float) -> void:
	if value < 0.0:
		Input.action_press(negative, -value)
		Input.action_release(positive)
	elif value > 0.0:
		Input.action_press(positive, value)
		Input.action_release(negative)
	else:
		Input.action_release(negative)
		Input.action_release(positive)


func _update_rest() -> void:
	var size := get_viewport_rect().size
	_rest = Vector2(radius * 1.6, size.y - radius * 1.6)
	if _finger == -1:
		_base = _rest
		_knob = _rest
	queue_redraw()


func _draw() -> void:
	var active := is_active()
	draw_circle(_base, radius, Color(1, 1, 1, 0.12 if active else 0.06))
	draw_arc(_base, radius, 0.0, TAU, 48, Color(1, 1, 1, 0.5 if active else 0.25), 3.0)
	draw_circle(_knob, radius * 0.42, Color(1, 1, 1, 0.55 if active else 0.3))
