class_name HeroSelect
extends PanelContainer
## Hero selection by category: a row of realm tabs (the way the reference map's
## taverns group heroes) and a row of role tabs, a grid of hero cards, and a
## detail panel with the hero's role, attributes, skills and transformation.

signal start_requested(hero_id: String)
signal training_requested(hero_id: String)
signal back_requested

var selected_id := ""

var _category := "All"
var _mode_buttons := {}
var _duel_button := Button.new()
var _cards := GridContainer.new()
var _details := RichTextLabel.new()
var _start := Button.new()
var _tab_buttons := {}


func _ready() -> void:
	custom_minimum_size = Vector2(1100, 0)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	add_child(column)

	var heading := UiTheme.title(Label.new(), 40)
	heading.text = "Choose Your Hero"
	column.add_child(heading)

	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 10)
	column.add_child(tabs)
	var roles := HBoxContainer.new()
	roles.alignment = BoxContainer.ALIGNMENT_CENTER
	roles.add_theme_constant_override("separation", 8)
	column.add_child(roles)
	for category in ["All"] + Roster.REALMS + Roster.ROLES:
		var tab := Button.new()
		tab.text = category
		tab.toggle_mode = true
		tab.custom_minimum_size = Vector2(150, 46)
		tab.add_theme_font_size_override("font_size", 17)
		tab.pressed.connect(_show_category.bind(category))
		(roles if Roster.ROLES.has(category) else tabs).add_child(tab)
		_tab_buttons[category] = tab

	# Rules: Mobile (15 kills or 8:00) or Classic (the map's 100 kills, no
	# time limit, no passive gold); duels on or off.
	var modes := HBoxContainer.new()
	modes.alignment = BoxContainer.ALIGNMENT_CENTER
	modes.add_theme_constant_override("separation", 10)
	column.add_child(modes)
	for spec in [[false, "Mobile — 15 kills · 8:00"], [true, "Classic — 100 kills · no time limit"]]:
		var mode_button := Button.new()
		mode_button.text = spec[1]
		mode_button.toggle_mode = true
		mode_button.custom_minimum_size = Vector2(380, 48)
		mode_button.add_theme_font_size_override("font_size", 18)
		mode_button.pressed.connect(_set_classic.bind(spec[0]))
		modes.add_child(mode_button)
		_mode_buttons[spec[0]] = mode_button
	_duel_button.toggle_mode = true
	_duel_button.custom_minimum_size = Vector2(200, 48)
	_duel_button.add_theme_font_size_override("font_size", 18)
	_duel_button.toggled.connect(_set_duels)
	modes.add_child(_duel_button)
	var session := get_node_or_null("/root/Session")
	_set_classic(session.classic if session else false)
	_duel_button.button_pressed = session.duels if session else true
	_set_duels(_duel_button.button_pressed)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 20)
	column.add_child(body)
	_cards.columns = 4
	_cards.add_theme_constant_override("h_separation", 12)
	_cards.add_theme_constant_override("v_separation", 12)
	_cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# 24 heroes: the cards scroll inside a fixed area, like the details.
	var card_scroll := ScrollContainer.new()
	card_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_scroll.custom_minimum_size = Vector2(560, 330)
	card_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card_scroll.add_child(_cards)
	body.add_child(card_scroll)
	# Fixed height with scrolling, so long descriptions can't push the
	# Start/Back buttons off a phone screen.
	_details.bbcode_enabled = true
	_details.fit_content = false
	_details.scroll_active = true
	_details.custom_minimum_size = Vector2(480, 330)
	_details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for size_name in ["normal_font_size", "bold_font_size", "italics_font_size"]:
		_details.add_theme_font_size_override(size_name, 20)
	_details.add_theme_color_override("default_color", UiTheme.PARCHMENT)
	body.add_child(_details)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 20)
	column.add_child(actions)
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(220, 64)
	back.pressed.connect(func(): back_requested.emit())
	actions.add_child(back)
	var training := Button.new()
	training.text = "Training"
	training.custom_minimum_size = Vector2(220, 64)
	training.pressed.connect(func(): training_requested.emit(selected_id))
	actions.add_child(training)
	_start.text = "Start Match"
	_start.set_meta("sfx", "confirm")
	_start.custom_minimum_size = Vector2(280, 64)
	_start.disabled = true
	_start.pressed.connect(func(): start_requested.emit(selected_id))
	actions.add_child(_start)

	_show_category("All")
	select_hero(Roster.all()[0].id)


func _set_duels(on: bool) -> void:
	var session := get_node_or_null("/root/Session")
	if session:
		session.duels = on
	_duel_button.text = "Duels: On" if on else "Duels: Off"


## Autoloads are looked up at run time: tests compile this script before they exist.
func _set_classic(on: bool) -> void:
	var session := get_node_or_null("/root/Session")
	if session:
		session.classic = on
	for key in _mode_buttons:
		_mode_buttons[key].button_pressed = key == on


func _show_category(category: String) -> void:
	_category = category
	for key in _tab_buttons:
		_tab_buttons[key].button_pressed = key == category
	for child in _cards.get_children():
		child.queue_free()
	for definition in Roster.all():
		if category == "All" or definition.role == category or definition.realm == category:
			_cards.add_child(_card(definition.display_name, definition.role, definition.id, true))
	for planned in Roster.PLANNED:
		if category == "All" or planned[0] == category:
			_cards.add_child(_card(planned[1], planned[0], "", false))


func _card(card_name: String, role: String, hero_id: String, available: bool) -> Button:
	var card := Button.new()
	card.text = "%s\n%s" % [card_name, role if available else "Coming soon"]
	card.custom_minimum_size = Vector2(140, 96)
	card.disabled = not available
	card.toggle_mode = available
	card.button_pressed = available and hero_id == selected_id
	if available:
		card.pressed.connect(select_hero.bind(hero_id))
	return card


func select_hero(hero_id: String) -> void:
	selected_id = hero_id
	_start.disabled = hero_id == ""
	var definition := Roster.create(hero_id)
	var lines: Array[String] = [
		"[font_size=34][color=#ffd673]%s[/color][/font_size]" % definition.display_name,
		"[i]%s[/i] — %s · %s" % [definition.title, definition.role, definition.realm],
		"",
		definition.description,
		"",
		"[color=#ffd673]Attributes[/color] — primary %s" % {"str": "strength", "agi": "agility", "int": "intelligence"}[definition.primary],
		"STR %d (+%.1f)   AGI %d (+%.1f)   INT %d (+%.1f) per level" % [definition.strength, definition.strength_gain,
			definition.agility, definition.agility_gain, definition.intelligence, definition.intelligence_gain],
		"",
		"[color=#ffd673]Skills[/color]",
	]
	for skill in definition.create_skills():
		var ranks := "ultimate, %d ranks from level %d" % [skill.max_rank, skill.required_level] if skill.ultimate \
				else "%d ranks from level %d" % [skill.max_rank, skill.required_level]
		var picture := "[img=34]%s[/img] " % skill.icon_path() if ResourceLoader.exists(skill.icon_path()) else "• "
		lines.append("%s[b]%s[/b] (%ds, %s): %s" % [picture, skill.skill_name, skill.cooldown, ranks, skill.description])
	var exclusive := ItemCatalog.find(definition.exclusive_item)
	if exclusive:
		lines.append("")
		lines.append("[color=#ffd673]Exclusive item — %s[/color] (%d gold)" % [exclusive.display_name, exclusive.cost])
		lines.append(exclusive.description)
	lines.append("")
	lines.append("[color=#ffd673]Transformation — %s[/color]" % definition.form_name)
	lines.append("%d s · shield %d%% · damage ×%.2f · speed ×%.1f" % [definition.form_duration, definition.form_shield_ratio * 100, definition.form_damage_mult, definition.form_speed_mult])
	_details.text = "\n".join(lines)
	for card in _cards.get_children():
		if card is Button and card.toggle_mode:
			card.button_pressed = card.text.begins_with(definition.display_name)
