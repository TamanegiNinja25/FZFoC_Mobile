extends SceneTree
## Headless check of the menu flow:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/menu_flow_test.gd
## Menu order → Single Player → hero select by category → Start Match → game
## with the chosen hero → pause and resume; settings save, load and apply.

var _menu: Node
var _frames := 0
var _failures: Array[String] = []
var _saved := {}


func _initialize() -> void:
	_menu = load("res://scenes/menu.tscn").instantiate()
	root.add_child(_menu)
	current_scene = _menu


func _process(_delta: float) -> bool:
	_frames += 1
	match _frames:
		5:
			var labels: Array = _menu.buttons.values().map(func(b): return b.text)
			_check(labels == ["Single Player", "Play with Friends", "Settings", "Credits", "Quit"], "menu order: %s" % ", ".join(labels))
			_menu.buttons.credits.pressed.emit()
			_check(_menu._credits.visible and not _menu._main_panel.visible, "Credits opens the credits screen")
			_check("Kay Lousberg" in CreditsPanel.credits_text() and "Kenney" in CreditsPanel.credits_text() and "cynicmusic" in CreditsPanel.credits_text(),
					"credits name every third-party creator")
			_menu.show_screen("main")
			_menu.buttons.single.pressed.emit()
			_check(_menu._hero_select.visible and not _menu._main_panel.visible, "Single Player opens hero select")
			_check(_menu._hero_select.selected_id == "vael", "Vael is selected by default")
		8:
			var select: HeroSelect = _menu._hero_select
			select._show_category("Speed")
		10:
			var select: HeroSelect = _menu._hero_select
			var cards: Array = select._cards.get_children().filter(func(c): return not c.is_queued_for_deletion())
			_check(cards.size() == 1 and not cards[0].disabled and cards[0].text.begins_with("Ryn"), "Speed category shows Ryn")
			select._show_category("Bruiser")
		12:
			var select: HeroSelect = _menu._hero_select
			var cards: Array = select._cards.get_children().filter(func(c): return not c.is_queued_for_deletion())
			_check(cards.size() == 2 and cards.any(func(c): return c.text.begins_with("Vael")) and cards.any(func(c): return c.text.begins_with("Kael")),
					"Bruiser category shows Vael and Kael")
			_settings_round_trip()
			select.start_requested.emit("vael")
		20:
			var game := current_scene
			_check(game != null and game.get("hero") != null and game.hero.definition.id == "vael", "Start Match loads the game with Vael")
			game.pause_menu.open()
			_check(paused, "pause menu pauses the game")
			game.pause_menu.close()
			_check(not paused, "Resume unpauses")
			for failure in _failures:
				printerr("FAIL: " + failure)
			print("MENU FLOW TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
			quit(1 if _failures.size() else 0)
	return false


func _settings_round_trip() -> void:
	var settings: Node = root.get_node("GameSettings")
	for key in ["music_volume", "render_scale"]:
		_saved[key] = settings.get(key)
	settings.set_and_save("music_volume", 0.3)
	settings.set_and_save("render_scale", 0.75)
	var bus := AudioServer.get_bus_index("Music")
	_check(bus != -1 and is_equal_approx(AudioServer.get_bus_volume_db(bus), linear_to_db(0.3)), "music volume applies to the Music bus")
	settings.music_volume = 1.0
	settings.load_settings()
	_check(is_equal_approx(settings.music_volume, 0.3) and is_equal_approx(settings.render_scale, 0.75), "settings persist to disk and load back")
	for key in _saved:  # restore the player's real settings
		settings.set_and_save(key, _saved[key])


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
