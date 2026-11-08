class_name Controls
extends RefCounted
## Keyboard bindings for desktop play (touch controls live in the HUD).

const INPUTS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"transform": [KEY_SPACE],
	"skill_1": [KEY_Q],
	"skill_2": [KEY_E],
}


static func register() -> void:
	for action in INPUTS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key in INPUTS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
