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
## Announcer lines: Kenney "Voiceover Pack: Fighter" (CC0).
const ANNOUNCER := "res://assets/thirdparty/voices/kenney_fighter/"
## Hero voices (CREDITS.md): HaelDB's yells (CC0), thebardofblasphemy's death
## grunts (CC0) and JeanMyna_VA's "Aha!" (CC-BY 3.0). Each hero picks a set and a pitch.
const VOICES_DIR := "res://assets/thirdparty/voices/"
const VOICE_SETS := {
	"male1": {"cry": ["haeldb_yells/voice1_cry%d.wav", 8], "death": ["bard_death_grunts/death%d.wav", 10]},
	"male2": {"cry": ["haeldb_yells/voice2_cry%d.wav", 8], "death": ["bard_death_grunts/death%d.wav", 10]},
	"male3": {"cry": ["haeldb_yells/voice3_cry%d.wav", 8], "death": ["haeldb_yells/voice3_grunt%d.wav", 6]},
	"female": {"cry": ["jeanmyna_aha/aha%d.wav", 6], "death": ["jeanmyna_aha/aha%d.wav", 6]},
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
	return _streams.has(sound) or not _resolve(sound).is_empty()


## Sounds loaded on first use: "skill:<id>" (assets/sfx/skills), "voice:<set>:<kind>"
## and "announce:<line>". Returns the variants (empty when there's no file).
func _resolve(sound: String) -> Array:
	if _streams.has(sound):
		return _streams[sound]
	var paths: Array[String] = []
	var parts := sound.split(":")
	if parts[0] == "skill" and parts.size() == 2:
		paths.append("res://assets/sfx/skills/%s.wav" % parts[1])
	elif parts[0] == "voice" and parts.size() == 3 and VOICE_SETS.has(parts[1]) and VOICE_SETS[parts[1]].has(parts[2]):
		var spec: Array = VOICE_SETS[parts[1]][parts[2]]
		for k in spec[1]:
			paths.append(VOICES_DIR + spec[0] % (k + 1))
	elif parts[0] == "announce" and parts.size() == 2:
		paths.append(ANNOUNCER + parts[1] + ".ogg")
	else:
		return []
	var variants: Array[AudioStream] = []
	for path in paths:
		if ResourceLoader.exists(path):
			variants.append(load(path))
	_streams[sound] = variants
	return variants


## An announcer line ("fight", "you_win", "3" …), clear of the music.
func announce(line: String, volume_db := 0.0) -> void:
	play("announce:" + line, volume_db)


func play(sound: String, volume_db := 0.0, pitch := 1.0) -> void:
	if _resolve(sound).is_empty():
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
