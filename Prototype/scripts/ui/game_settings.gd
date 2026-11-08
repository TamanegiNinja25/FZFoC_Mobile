extends Node
## Autoload "GameSettings": player settings, saved to user://settings.cfg.
## Defaults come from Platform (phones: 90% 3D resolution, 2 shadow cascades).

signal changed

const PATH := "user://settings.cfg"

var master_volume := 1.0
var music_volume := 0.8
var sfx_volume := 1.0
var render_scale := Platform.render_scale()
var shadow_cascades := Platform.shadow_cascades()
var fps_cap := 60
var show_fps := false


func _ready() -> void:
	_ensure_bus("Music")
	_ensure_bus("SFX")
	load_settings()
	apply()


## Platform defaults: phones get 90% 3D resolution and 2 shadow cascades.
func reset_to_defaults() -> void:
	master_volume = 1.0
	music_volume = 0.8
	sfx_volume = 1.0
	render_scale = Platform.render_scale()
	shadow_cascades = Platform.shadow_cascades()
	fps_cap = 60
	show_fps = false
	save_settings()
	apply()


func load_settings() -> void:
	var file := ConfigFile.new()
	if file.load(PATH) != OK:
		return
	master_volume = file.get_value("audio", "master", master_volume)
	music_volume = file.get_value("audio", "music", music_volume)
	sfx_volume = file.get_value("audio", "sfx", sfx_volume)
	render_scale = file.get_value("video", "render_scale", render_scale)
	shadow_cascades = file.get_value("video", "shadow_cascades", shadow_cascades)
	fps_cap = file.get_value("video", "fps_cap", fps_cap)
	show_fps = file.get_value("video", "show_fps", show_fps)


func save_settings() -> void:
	var file := ConfigFile.new()
	file.set_value("audio", "master", master_volume)
	file.set_value("audio", "music", music_volume)
	file.set_value("audio", "sfx", sfx_volume)
	file.set_value("video", "render_scale", render_scale)
	file.set_value("video", "shadow_cascades", shadow_cascades)
	file.set_value("video", "fps_cap", fps_cap)
	file.set_value("video", "show_fps", show_fps)
	file.save(PATH)


## Applies everything that doesn't depend on a scene; scenes call
## apply_to_scene() for render scale and shadows.
func apply() -> void:
	_set_bus_volume("Master", master_volume)
	_set_bus_volume("Music", music_volume)
	_set_bus_volume("SFX", sfx_volume)
	Engine.max_fps = fps_cap
	changed.emit()


func apply_to_scene(viewport: Viewport, sun: DirectionalLight3D) -> void:
	Platform.apply_render_scale(viewport, render_scale)
	if sun:
		Platform.apply_sun_shadows(sun, shadow_cascades)


func set_and_save(key: String, value: Variant) -> void:
	set(key, value)
	save_settings()
	apply()


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_mute(index, linear <= 0.001)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.001)))
