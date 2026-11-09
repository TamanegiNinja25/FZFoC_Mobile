class_name Hud
extends CanvasLayer

signal pause_requested
## Hero name, level and experience, attributes, health, shield, meter and form
## countdown on the left; on the right a big ATTACK button with the four
## skills on an arc around it. A "+" badge sits on each skill's top corner
## whenever a skill point can rank it up.

## Arc around the attack button: radius and angles (degrees, 180 = left).
const ARC_RADIUS := 250.0
const ARC_ANGLES := [180.0, 146.0, 112.0, 78.0]
const ATTACK_CENTER := Vector2(-185, -185)
const SKILL_SIZE := 120.0
const BADGE_SIZE := 48.0

var hero: Hero
var joystick := TouchJoystick.new()

var _hp_bar := ProgressBar.new()
var _shield_bar := ProgressBar.new()
var _meter_bar := ProgressBar.new()
var _xp_bar := ProgressBar.new()
var _level := Label.new()
var _attributes := Label.new()
var _status := Label.new()
var _economy := Label.new()
var _button := Button.new()
var _attack := Button.new()
var _name := Label.new()
var _skill_buttons: Array[Button] = []
var _badges: Array[Button] = []
var _fps := Label.new()
var _shop_button := Button.new()
var _inventory: Array[Button] = []
var shop := ShopPanel.new()
## Themed, safe-area-inset container for every HUD control.
var root := Control.new()


func setup(target: Hero) -> void:
	hero = target
	hero.health_changed.connect(_on_health_changed)
	hero.form_changed.connect(_on_form_changed)
	hero.meter.changed.connect(_on_meter_changed)
	_name.text = "%s — %s" % [hero.definition.display_name, hero.definition.title]
	hero.items_changed.connect(_refresh_inventory)
	hero.leveled_up.connect(func(_l): _pulse(_level))
	for i in mini(hero.skills.size(), _skill_buttons.size()):
		_skill_buttons[i].icon = hero.skills[i].icon()
	_refresh_inventory()
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
	panel.add_theme_constant_override("separation", 5)
	backing.add_child(panel)

	_name.add_theme_font_size_override("font_size", 22)
	_name.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	panel.add_child(_name)

	var level_line := HBoxContainer.new()
	_level.custom_minimum_size = Vector2(70, 0)
	_level.add_theme_font_size_override("font_size", 18)
	_level.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	_xp_bar.custom_minimum_size = Vector2(300, 12)
	_xp_bar.show_percentage = false
	_xp_bar.max_value = 1.0
	_xp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_xp_bar.modulate = Color(0.75, 0.6, 1.0)
	level_line.add_child(_level)
	level_line.add_child(_xp_bar)
	panel.add_child(level_line)
	_attributes.add_theme_font_size_override("font_size", 16)
	_attributes.add_theme_color_override("font_color", UiTheme.MUTED)
	panel.add_child(_attributes)

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

	# ATTACK: lock onto the nearest enemy (heroes first) and chase it.
	_attack.text = "ATTACK"
	_corner(_attack, Rect2(ATTACK_CENTER - Vector2(85, 85), Vector2(170, 170)))
	_attack.add_theme_font_size_override("font_size", 26)
	_attack.button_down.connect(func(): hero.order_attack())
	root.add_child(_attack)

	# Skills on an arc around ATTACK, each with a "+" badge on its top-left corner.
	for i in ARC_ANGLES.size():
		var angle := deg_to_rad(ARC_ANGLES[i])
		var center := ATTACK_CENTER + Vector2(cos(angle), -sin(angle)) * ARC_RADIUS
		var skill_button := Button.new()
		_corner(skill_button, Rect2(center - Vector2.ONE * SKILL_SIZE / 2.0, Vector2.ONE * SKILL_SIZE))
		skill_button.add_theme_font_size_override("font_size", 15)
		skill_button.clip_text = true
		skill_button.expand_icon = true
		skill_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		skill_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		skill_button.add_theme_constant_override("icon_max_width", 66)
		skill_button.pressed.connect(func(): hero.try_skill(i))
		root.add_child(skill_button)
		_skill_buttons.append(skill_button)

		var badge := Button.new()
		badge.text = "+"
		var corner := center - Vector2.ONE * SKILL_SIZE / 2.0
		_corner(badge, Rect2(corner - Vector2.ONE * BADGE_SIZE * 0.3, Vector2.ONE * BADGE_SIZE))
		badge.add_theme_font_size_override("font_size", 30)
		badge.add_theme_color_override("font_color", Color(0.15, 0.1, 0.02))
		badge.add_theme_stylebox_override("normal", _badge_style(Color(1.0, 0.8, 0.3)))
		badge.add_theme_stylebox_override("hover", _badge_style(Color(1.0, 0.88, 0.45)))
		badge.add_theme_stylebox_override("pressed", _badge_style(Color(0.9, 0.65, 0.2)))
		badge.set_meta("sfx", "confirm")
		badge.visible = false
		badge.pressed.connect(func(): hero.learn_skill(i))
		root.add_child(badge)
		_badges.append(badge)

	# TRANSFORM sits outside the arc, between the second and third skills.
	_button.text = "TRANSFORM"
	var form_center := ATTACK_CENTER + Vector2(cos(deg_to_rad(135.0)), -sin(deg_to_rad(135.0))) * 420.0
	_corner(_button, Rect2(form_center - Vector2(105, 45), Vector2(210, 90)))
	_button.disabled = true
	_button.set_meta("sfx", "confirm")
	_button.add_theme_font_size_override("font_size", 22)
	_button.pressed.connect(func(): hero.try_transform())
	root.add_child(_button)

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

	# SHOP: usable at the hero's own fountain.
	_shop_button.text = "SHOP"
	_shop_button.anchor_left = 1.0
	_shop_button.anchor_right = 1.0
	_shop_button.offset_left = -270
	_shop_button.offset_top = 24
	_shop_button.offset_right = -126
	_shop_button.offset_bottom = 104
	_shop_button.add_theme_font_size_override("font_size", 24)
	_shop_button.pressed.connect(open_shop)
	root.add_child(_shop_button)

	# Inventory bar: tap a consumable to use it.
	var bar := HBoxContainer.new()
	bar.anchor_left = 0.5
	bar.anchor_right = 0.5
	bar.anchor_top = 1.0
	bar.anchor_bottom = 1.0
	bar.offset_left = -207
	bar.offset_right = 207
	bar.offset_top = -78
	bar.offset_bottom = -14
	bar.add_theme_constant_override("separation", 6)
	root.add_child(bar)
	for i in ItemCatalog.INVENTORY_SIZE:
		var slot := Button.new()
		slot.custom_minimum_size = Vector2(64, 64)
		slot.expand_icon = true
		slot.pressed.connect(func(): hero.use_item(i))
		bar.add_child(slot)
		_inventory.append(slot)
	joystick.blockers.append(bar)

	shop.visible = false
	shop.set_anchors_preset(Control.PRESET_CENTER)
	shop.grow_horizontal = Control.GROW_DIRECTION_BOTH
	shop.grow_vertical = Control.GROW_DIRECTION_BOTH
	shop.closed.connect(close_shop)
	root.add_child(shop)

	_fps.anchor_left = 1.0
	_fps.anchor_right = 1.0
	_fps.offset_left = -440
	_fps.offset_top = 40
	_fps.offset_right = -280
	_fps.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(_fps)


## Anchors a control to the bottom-right corner at `rect` (offsets from that corner).
static func _corner(control: Control, rect: Rect2) -> void:
	control.anchor_left = 1.0
	control.anchor_right = 1.0
	control.anchor_top = 1.0
	control.anchor_bottom = 1.0
	control.offset_left = rect.position.x
	control.offset_top = rect.position.y
	control.offset_right = rect.position.x + rect.size.x
	control.offset_bottom = rect.position.y + rect.size.y


static func _badge_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(int(BADGE_SIZE / 2.0))
	style.border_color = Color(0.3, 0.2, 0.05)
	style.set_border_width_all(3)
	return style


func _process(_delta: float) -> void:
	if not hero:
		return
	_shop_button.disabled = not hero.in_shop_range
	_shop_button.modulate = Color(1.25, 1.1, 0.8) if hero.in_shop_range else Color(1, 1, 1)
	if shop.visible and not hero.in_shop_range:
		close_shop()
	_fps.visible = GameSettings.show_fps
	if _fps.visible:
		_fps.text = "%d FPS" % Engine.get_frames_per_second()

	_level.text = "Lv %d" % hero.level
	_xp_bar.value = hero.level_progress()
	var points := "   ·   %d skill point%s" % [hero.skill_points, "" if hero.skill_points == 1 else "s"] if hero.skill_points > 0 else ""
	_attributes.text = "STR %d   AGI %d   INT %d%s" % [hero.attribute("str"), hero.attribute("agi"), hero.attribute("int"), points]

	if hero.frozen:
		_status.text = "Duel in progress…"
	elif hero.is_stunned():
		_status.text = "Stunned!"
	elif hero.in_form:
		var stage := "  ·  stage %d/%d" % [hero.form_stage, hero.max_form_stage()] if hero.max_form_stage() > 1 else ""
		var ascend := ""
		if hero.can_ascend():
			ascend = "  ·  ASCEND ready" if hero.meter.is_full() else "  ·  ascend %d%%" % roundi(100.0 * hero.meter.charge / hero.meter.max_charge)
		_status.text = "%s  %.1f s%s%s" % [hero.stage_name().to_upper(), hero.form_time_left, stage, ascend]
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
	_economy.text = "Gold %d   +%.0f/s%s%s
Damage dealt %d   taken %d" % [floori(hero.gold), hero.income_per_second(), spree_text, bounty_text,
		hero.damage_dealt, hero.damage_taken]

	var can_act := hero.is_alive() and not hero.frozen
	_attack.disabled = not can_act
	for i in _skill_buttons.size():
		if i >= hero.skills.size():
			_skill_buttons[i].visible = false
			_badges[i].visible = false
			continue
		var skill := hero.skills[i]
		# The icon shows which skill it is; the text shows its state.
		if not skill.is_learned():
			_skill_buttons[i].text = "Lv %d" % skill.next_rank_level()
		elif skill.is_ready():
			_skill_buttons[i].text = skill.rank_pips()
		else:
			_skill_buttons[i].text = "%.1f" % skill.time_left
		_skill_buttons[i].tooltip_text = skill.display_name(hero)
		_skill_buttons[i].disabled = not skill.is_ready() or not can_act
		_skill_buttons[i].modulate = Color(1, 1, 1) if skill.is_learned() else Color(1, 1, 1, 0.55)
		_badges[i].visible = hero.skill_points > 0 and skill.can_learn(hero)


func open_shop() -> void:
	if not hero.in_shop_range:
		return
	shop.open_for(hero)
	shop.visible = true
	joystick.enabled = false
	UiTheme.pop_in(shop)


func close_shop() -> void:
	shop.visible = false
	joystick.enabled = true


func _pulse(control: Control) -> void:
	control.pivot_offset = control.size / 2.0
	control.scale = Vector2(1.5, 1.5)
	control.create_tween().tween_property(control, "scale", Vector2.ONE, 0.35)


func _refresh_inventory() -> void:
	for i in _inventory.size():
		var slot := _inventory[i]
		var has_item := i < hero.items.size()
		slot.icon = hero.items[i].icon() if has_item else null
		slot.disabled = not has_item or not hero.items[i].consumable
		slot.modulate = Color(1, 1, 1) if has_item else Color(1, 1, 1, 0.45)


func _on_health_changed(hp: float, max_hp: float, shield: float) -> void:
	_hp_bar.max_value = max_hp
	_hp_bar.value = hp
	_shield_bar.max_value = max_hp * hero.form_shield_ratio
	_shield_bar.value = shield


func _on_meter_changed(value: float, max_value: float) -> void:
	_meter_bar.max_value = max_value
	_meter_bar.value = value
	_refresh_transform_button()


func _on_form_changed(_active: bool) -> void:
	_refresh_transform_button()


## TRANSFORM out of form; ASCEND while a further stage waits.
func _refresh_transform_button() -> void:
	_button.text = "ASCEND" if hero.can_ascend() else "TRANSFORM"
	_button.disabled = not hero.meter.is_full() or (hero.in_form and not hero.can_ascend())
