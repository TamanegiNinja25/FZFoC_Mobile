extends Node
## Autoload "Sfx": plays the generated sound effects (assets/sfx, made by
## tools/generate_assets.py) on the SFX bus, and gives every button in the
## game a press animation and a click sound automatically.

const SOUNDS := ["click", "confirm", "back", "hit", "slam", "dash", "transform", "kill", "victory", "defeat"]
const VOICES := 8

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # menus work while the game is paused
	for sound in SOUNDS:
		var stream := load("res://assets/sfx/%s.wav" % sound)
		if stream:
			_streams[sound] = stream
	for i in VOICES:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_players.append(player)
	get_tree().node_added.connect(_on_node_added)


func play(sound: String, volume_db := 0.0, pitch := 1.0) -> void:
	if not _streams.has(sound):
		return
	var player := _players[_next]
	_next = (_next + 1) % VOICES
	player.stream = _streams[sound]
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()


## Sound for a button: set button.set_meta("sfx", "confirm") to override.
func sound_for(button: BaseButton) -> String:
	if button.has_meta("sfx"):
		return button.get_meta("sfx")
	var text := (button as Button).text if button is Button else ""
	if text.begins_with("Back") or text.begins_with("Resume") or text.begins_with("Quit to"):
		return "back"
	return "click"


func _on_node_added(node: Node) -> void:
	if node is BaseButton and not node.has_meta("fx_attached"):
		node.set_meta("fx_attached", true)
		_attach(node)


## Press feedback: shrink on press, spring back on release, sound on press.
func _attach(button: BaseButton) -> void:
	button.resized.connect(func(): button.pivot_offset = button.size / 2.0)
	button.button_down.connect(func():
		_scale(button, 0.94, 0.06)
		play(sound_for(button), -4.0, randf_range(0.96, 1.04)))
	button.button_up.connect(func(): _scale(button, 1.0, 0.18))
	button.mouse_entered.connect(func():
		if not button.disabled and not button.is_pressed():
			_scale(button, 1.03, 0.1))
	button.mouse_exited.connect(func(): _scale(button, 1.0, 0.12))


func _scale(button: Control, target: float, duration: float) -> void:
	if not button.is_inside_tree():
		return
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE * target, duration)
