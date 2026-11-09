extends Node
## Autoload "Sfx": plays sound effects on the SFX bus, and gives every button
## in the game a press animation and a click sound automatically.
## Each sound name maps to one or more variants, picked at random so repeated
## hits don't sound mechanical. Variants are Kenney's CC0 packs where one fits
## (assets/thirdparty/kenney, see CREDITS.md) and otherwise the generated
## sounds in assets/sfx (tools/generate_assets.py).

const KENNEY := "res://assets/thirdparty/kenney/"
const GENERATED := "res://assets/sfx/%s.wav"
const SOUNDS := {
	"click": [KENNEY + "interface_sounds/click_001.ogg"],
	"confirm": [KENNEY + "interface_sounds/confirmation_001.ogg"],
	"back": [KENNEY + "interface_sounds/back_001.ogg"],
	"error": [KENNEY + "interface_sounds/error_001.ogg"],
	"open": [KENNEY + "interface_sounds/open_001.ogg"],
	"hit": [KENNEY + "rpg_sounds/knifeSlice.ogg", KENNEY + "rpg_sounds/knifeSlice2.ogg", KENNEY + "rpg_sounds/chop.ogg", "hit"],
	"dash": [KENNEY + "rpg_sounds/drawKnife2.ogg", KENNEY + "rpg_sounds/cloth3.ogg"],
	"coins": [KENNEY + "rpg_sounds/handleCoins.ogg", KENNEY + "rpg_sounds/handleCoins2.ogg"],
	"slam": ["slam"], "transform": ["transform"], "kill": ["kill"], "victory": ["victory"],
	"defeat": ["defeat"], "levelup": ["levelup"], "duel": ["duel"],
}
## Music tracks (cynicmusic, CC0 — see CREDITS.md); generated WAVs are the fallback.
const MUSIC := {
	"menu": "res://assets/thirdparty/music/town_theme_rpg.mp3",
	"battle": "res://assets/thirdparty/music/battle_theme_a.mp3",
}
const VOICES := 8

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # menus work while the game is paused
	for sound in SOUNDS:
		var variants: Array[AudioStream] = []
		for source: String in SOUNDS[sound]:
			var path := source if source.begins_with("res://") else GENERATED % source
			if ResourceLoader.exists(path):
				variants.append(load(path))
		if variants.is_empty() and ResourceLoader.exists(GENERATED % sound):
			variants.append(load(GENERATED % sound))
		if not variants.is_empty():
			_streams[sound] = variants
	for i in VOICES:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_players.append(player)
	get_tree().node_added.connect(_on_node_added)


var _music := AudioStreamPlayer.new()
var _music_name := ""


## Loops a music track (assets/music) on the Music bus, fading between tracks.
func play_music(track: String, volume_db := -6.0) -> void:
	if track == _music_name:
		return
	_music_name = track
	var stream := _music_stream(track)
	if stream == null:
		return
	if _music.get_parent() == null:
		_music.bus = "Music"
		add_child(_music)
	var tween := create_tween()
	if _music.playing:
		tween.tween_property(_music, "volume_db", -40.0, 0.4)
	tween.tween_callback(func():
		_music.stream = stream
		_music.volume_db = -40.0
		_music.play())
	tween.tween_property(_music, "volume_db", volume_db, 0.8)


func _music_stream(track: String) -> AudioStream:
	if MUSIC.has(track) and ResourceLoader.exists(MUSIC[track]):
		var mp3 := load(MUSIC[track]) as AudioStreamMP3
		if mp3:
			mp3.loop = true
			return mp3
	var wav := load("res://assets/music/%s.wav" % track) as AudioStreamWAV
	if wav:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
	return wav


func has_sound(sound: String) -> bool:
	return _streams.has(sound)


func play(sound: String, volume_db := 0.0, pitch := 1.0) -> void:
	if not _streams.has(sound):
		return
	var player := _players[_next]
	_next = (_next + 1) % VOICES
	player.stream = _streams[sound].pick_random()
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
