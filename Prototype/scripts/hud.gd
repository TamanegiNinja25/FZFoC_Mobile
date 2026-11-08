class_name Hud
extends CanvasLayer

signal pause_requested
## Hero name, health, shield, meter and form countdown, plus thumb-sized
## transform and skill buttons arranged around the right thumb.

var hero: Hero
var joystick := TouchJoystick.new()

var _hp_bar := ProgressBar.new()
var _shield_bar := ProgressBar.new()
var _meter_bar := ProgressBar.new()
var _status := Label.new()
var _economy := Label.new()
var _button := Button.new()
var _name := Label.new()
var _skill_buttons: Array[Button] = []
var _fps := Label.new()
## Themed, safe-area-inset container for every HUD control.
var root := Control.new()


func setup(target: Hero) -> void:
	hero = target
	hero.health_changed.connect(_on_health_changed)
	hero.form_changed.connect(_on_form_changed)
	hero.meter.changed.connect(_on_meter_changed)
	_name.text = "%s — %s" % [hero.definition.display_name, hero.definition.title]
	_on_health_changed(hero.hp, hero.max_hp, hero.shield)
	_on_meter_changed(hero.meter.charge, hero.meter.max_charge)


func _ready() -> void:
	add_child(joystick)  # full screen and first, so buttons draw on top of it
	root.theme = UiTheme.build()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	UiTheme.apply_safe_area(root)
	get_viewport().size_changed.connect(func(): UiTheme.apply_safe_area(root))

	# Stats sit on a translucent stone backing so they stay readable over the arena.
	var backing := PanelContainer.new()
	backing.add_theme_stylebox_override("panel", UiTheme.hud_panel())
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(backing)
	var panel := VBoxContainer.new()
	panel.add_theme_constant_override("separation", 6)
	backing.add_child(panel)

	_name.add_theme_font_size_override("font_size", 22)
	_name.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	panel.add_child(_name)

	for row in [["HP", _hp_bar, Color(0.3, 0.85, 0.35)], ["Shield", _shield_bar, Color(0.6, 0.8, 1.0)], ["Meter", _meter_bar, Color(1.0, 0.75, 0.2)]]:
		var line := HBoxContainer.new()
		var label := Label.new()
		label.text = row[0]
		label.custom_minimum_size = Vector2(70, 0)
		label.add_theme_font_size_override("font_size", 18)
		var bar: ProgressBar = row[1]
		bar.custom_minimum_size = Vector2(300, 18)
		bar.show_percentage = false
		bar.modulate = row[2]
		line.add_child(label)
		line.add_child(bar)
		panel.add_child(line)

	for line in [_status, _economy]:
		line.add_theme_font_size_override("font_size", 18)
		panel.add_child(line)

	_button.text = "TRANSFORM"
	_button.custom_minimum_size = Vector2(220, 96)
	_button.disabled = true
	_button.anchor_left = 1.0
	_button.anchor_right = 1.0
	_button.anchor_top = 1.0
	_button.anchor_bottom = 1.0
	_button.offset_left = -260
	_button.offset_top = -136
	_button.offset_right = -40
	_button.offset_bottom = -40
	_button.set_meta("sfx", "confirm")
	_button.pressed.connect(func(): hero.try_transform())
	root.add_child(_button)

	# Skill buttons in an arc around TRANSFORM: skill 1 to its left, skill 2 above.
	for spec in [[0, Rect2(-430, -136, 150, 96)], [1, Rect2(-240, -256, 180, 96)]]:
		var skill_button := Button.new()
		var r: Rect2 = spec[1]
		skill_button.anchor_left = 1.0
		skill_button.anchor_right = 1.0
		skill_button.anchor_top = 1.0
		skill_button.anchor_bottom = 1.0
		skill_button.offset_left = r.position.x
		skill_button.offset_top = r.position.y
		skill_button.offset_right = r.position.x + r.size.x
		skill_button.offset_bottom = r.position.y + r.size.y
		var index: int = spec[0]
		skill_button.pressed.connect(func(): hero.try_skill(index))
		root.add_child(skill_button)
		_skill_buttons.append(skill_button)

	var pause := Button.new()
	pause.text = "II"
	pause.anchor_left = 1.0
	pause.anchor_right = 1.0
	pause.offset_left = -112
	pause.offset_top = 24
	pause.offset_right = -24
	pause.offset_bottom = 104
	pause.add_theme_font_size_override("font_size", 32)
	pause.pressed.connect(func(): pause_requested.emit())
	root.add_child(pause)

	_fps.anchor_left = 1.0
	_fps.anchor_right = 1.0
	_fps.offset_left = -300
	_fps.offset_top = 30
	_fps.offset_right = -130
	_fps.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(_fps)


func _process(_delta: float) -> void:
	if not hero:
		return
	_fps.visible = GameSettings.show_fps
	if _fps.visible:
		_fps.text = "%d FPS" % Engine.get_frames_per_second()
	if hero.in_form:
		_status.text = "%s  %.1f s" % [hero.definition.form_name.to_upper(), hero.form_time_left]
	elif not hero.is_alive():
		_status.text = "Respawning…"
	elif hero.meter.is_full():
		_status.text = "Meter full — press Space or TRANSFORM"
	else:
		var state := "" if hero.meter.in_combat() else "  (out of combat — draining)"
		_status.text = "Charging %d%%%s" % [roundi(100.0 * hero.meter.charge / hero.meter.max_charge), state]

	var spree_text := ""
	if hero.spree >= 2:
		spree_text = "   SPREE ×%d  (%.0f s)" % [hero.spree, hero.spree_time_left]
	var bounty_text := "   BOUNTY %d  ⚠" % hero.bounty_value() if hero.in_form else "   Bounty %d" % hero.bounty_value()
	_economy.text = "Gold %d   +%.0f/s%s%s" % [floori(hero.gold), hero.income_per_second(), spree_text, bounty_text]

	for i in _skill_buttons.size():
		if i >= hero.skills.size():
			_skill_buttons[i].visible = false
			continue
		var skill := hero.skills[i]
		var label := skill.display_name(hero)
		_skill_buttons[i].text = label if skill.is_ready() else "%s
%.1f" % [label, skill.time_left]
		_skill_buttons[i].disabled = not skill.is_ready() or not hero.is_alive()


func _on_health_changed(hp: float, max_hp: float, shield: float) -> void:
	_hp_bar.max_value = max_hp
	_hp_bar.value = hp
	_shield_bar.max_value = max_hp * hero.form_shield_ratio
	_shield_bar.value = shield


func _on_meter_changed(value: float, max_value: float) -> void:
	_meter_bar.max_value = max_value
	_meter_bar.value = value
	_button.disabled = hero.in_form or value < max_value


func _on_form_changed(active: bool) -> void:
	_button.disabled = active or not hero.meter.is_full()
