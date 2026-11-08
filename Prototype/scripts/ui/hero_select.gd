class_name HeroSelect
extends PanelContainer
## Hero selection by category: tabs for All / Bruiser / Speed / Giant, a grid
## of hero cards (planned heroes shown locked), and a detail panel with the
## hero's role, skills and transformation.

signal start_requested(hero_id: String)
signal back_requested

var selected_id := ""

var _category := "All"
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
	for category in ["All"] + Roster.ROLES:
		var tab := Button.new()
		tab.text = category
		tab.toggle_mode = true
		tab.custom_minimum_size = Vector2(150, 52)
		tab.pressed.connect(_show_category.bind(category))
		tabs.add_child(tab)
		_tab_buttons[category] = tab

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 20)
	column.add_child(body)
	_cards.columns = 3
	_cards.add_theme_constant_override("h_separation", 12)
	_cards.add_theme_constant_override("v_separation", 12)
	_cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(_cards)
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
	_start.text = "Start Match"
	_start.custom_minimum_size = Vector2(280, 64)
	_start.disabled = true
	_start.pressed.connect(func(): start_requested.emit(selected_id))
	actions.add_child(_start)

	_show_category("All")
	select_hero(Roster.all()[0].id)


func _show_category(category: String) -> void:
	_category = category
	for key in _tab_buttons:
		_tab_buttons[key].button_pressed = key == category
	for child in _cards.get_children():
		child.queue_free()
	for definition in Roster.all():
		if category == "All" or definition.role == category:
			_cards.add_child(_card(definition.display_name, definition.role, definition.id, true))
	for planned in Roster.PLANNED:
		if category == "All" or planned[0] == category:
			_cards.add_child(_card(planned[1], planned[0], "", false))


func _card(card_name: String, role: String, hero_id: String, available: bool) -> Button:
	var card := Button.new()
	card.text = "%s\n%s" % [card_name, role if available else "Coming soon"]
	card.custom_minimum_size = Vector2(180, 120)
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
		"[i]%s[/i] — %s" % [definition.title, definition.role],
		"",
		definition.description,
		"",
		"[color=#ffd673]Skills[/color]",
	]
	for skill in definition.create_skills():
		lines.append("• [b]%s[/b] (%ds): %s" % [skill.skill_name, skill.cooldown, skill.description])
	lines.append("")
	lines.append("[color=#ffd673]Transformation — %s[/color]" % definition.form_name)
	lines.append("%d s · shield %d%% · damage ×%.2f · speed ×%.1f" % [definition.form_duration, definition.form_shield_ratio * 100, definition.form_damage_mult, definition.form_speed_mult])
	_details.text = "\n".join(lines)
	for card in _cards.get_children():
		if card is Button and card.toggle_mode:
			card.button_pressed = card.text.begins_with(definition.display_name)
