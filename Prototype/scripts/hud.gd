class_name Hud
extends CanvasLayer
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


func setup(target: Hero) -> void:
	hero = target
	hero.health_changed.connect(_on_health_changed)
	hero.form_changed.connect(_on_form_changed)
	hero.meter.changed.connect(_on_meter_changed)
	_name.text = "%s — %s" % [hero.definition.display_name, hero.definition.title]
	_on_health_changed(hero.hp, hero.max_hp, hero.shield)
	_on_meter_changed(hero.meter.charge, hero.meter.max_charge)


func _ready() -> void:
	add_child(joystick)  # first, so buttons draw on top of it

	var panel := VBoxContainer.new()
	panel.position = Vector2(24, 24)
	panel.add_theme_constant_override("separation", 6)
	add_child(panel)

	_name.add_theme_font_size_override("font_size", 22)
	panel.add_child(_name)

	for row in [["HP", _hp_bar, Color(0.3, 0.85, 0.35)], ["Shield", _shield_bar, Color(0.6, 0.8, 1.0)], ["Meter", _meter_bar, Color(1.0, 0.75, 0.2)]]:
		var line := HBoxContainer.new()
		var label := Label.new()
		label.text = row[0]
		label.custom_minimum_size = Vector2(64, 0)
		var bar: ProgressBar = row[1]
		bar.custom_minimum_size = Vector2(320, 22)
		bar.show_percentage = false
		bar.modulate = row[2]
		line.add_child(label)
		line.add_child(bar)
		panel.add_child(line)

	panel.add_child(_status)
	panel.add_child(_economy)

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
	_button.pressed.connect(func(): hero.try_transform())
	add_child(_button)

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
		add_child(skill_button)
		_skill_buttons.append(skill_button)

	var stress := Button.new()
	stress.text = "STRESS TEST"
	stress.anchor_left = 1.0
	stress.anchor_right = 1.0
	stress.offset_left = -220
	stress.offset_top = 24
	stress.offset_right = -24
	stress.offset_bottom = 84
	stress.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stress_test.tscn"))
	add_child(stress)


func _process(_delta: float) -> void:
	if not hero:
		return
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
