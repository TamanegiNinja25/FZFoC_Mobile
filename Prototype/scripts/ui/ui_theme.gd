class_name UiTheme
extends RefCounted
## Shared menu theme: dark stone panels, bevelled gold-trimmed buttons and
## parchment text — the classic fantasy-RTS feel from the UI direction,
## built from scratch (no assets from any existing game).

const STONE := Color(0.15, 0.14, 0.13)
const STONE_LIGHT := Color(0.24, 0.22, 0.2)
const STONE_DARK := Color(0.09, 0.085, 0.08)
const GOLD := Color(0.78, 0.62, 0.32)
const GOLD_BRIGHT := Color(1.0, 0.84, 0.45)
const PARCHMENT := Color(0.94, 0.88, 0.72)
const MUTED := Color(0.55, 0.52, 0.47)


static func build() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 24

	var normal := _box(STONE, GOLD, 3)
	var hover := _box(STONE_LIGHT, GOLD_BRIGHT, 3)
	var pressed := _box(STONE_DARK, GOLD_BRIGHT, 3)
	pressed.shadow_size = 0
	var disabled := _box(STONE_DARK, MUTED.darkened(0.3), 2)
	for type in ["Button", "OptionButton"]:
		theme.set_stylebox("normal", type, normal)
		theme.set_stylebox("hover", type, hover)
		theme.set_stylebox("pressed", type, pressed)
		theme.set_stylebox("disabled", type, disabled)
		theme.set_stylebox("focus", type, StyleBoxEmpty.new())
		theme.set_color("font_color", type, PARCHMENT)
		theme.set_color("font_hover_color", type, GOLD_BRIGHT)
		theme.set_color("font_pressed_color", type, GOLD_BRIGHT)
		theme.set_color("font_disabled_color", type, MUTED)

	var panel := _box(Color(STONE_DARK, 0.96), GOLD, 4)
	panel.set_content_margin_all(24)
	theme.set_stylebox("panel", "PanelContainer", panel)
	theme.set_stylebox("panel", "Panel", panel)

	theme.set_color("font_color", "Label", PARCHMENT)
	theme.set_color("font_color", "CheckButton", PARCHMENT)
	theme.set_color("font_hover_color", "CheckButton", GOLD_BRIGHT)

	var tab_on := _box(STONE_LIGHT, GOLD_BRIGHT, 2)
	tab_on.shadow_size = 0
	var tab_off := _box(STONE_DARK, GOLD.darkened(0.45), 2)
	tab_off.shadow_size = 0
	var tab_hover := _box(STONE, GOLD, 2)
	tab_hover.shadow_size = 0
	for box in [tab_on, tab_off, tab_hover]:
		box.content_margin_left = 22
		box.content_margin_right = 22
	theme.set_stylebox("tab_selected", "TabContainer", tab_on)
	theme.set_stylebox("tab_unselected", "TabContainer", tab_off)
	theme.set_stylebox("tab_hovered", "TabContainer", tab_hover)
	var tab_panel := _box(Color(STONE, 0.6), GOLD.darkened(0.45), 1)
	tab_panel.shadow_size = 0
	tab_panel.set_content_margin_all(20)
	theme.set_stylebox("panel", "TabContainer", tab_panel)
	theme.set_color("font_selected_color", "TabContainer", GOLD_BRIGHT)
	theme.set_color("font_unselected_color", "TabContainer", MUTED)
	theme.set_color("font_hovered_color", "TabContainer", PARCHMENT)

	var groove := _box(STONE_DARK, GOLD.darkened(0.4), 1)
	groove.set_content_margin_all(4)
	theme.set_stylebox("slider", "HSlider", groove)
	var fill := _box(GOLD.darkened(0.2), GOLD, 1)
	fill.set_content_margin_all(4)
	theme.set_stylebox("grabber_area", "HSlider", fill)
	theme.set_stylebox("grabber_area_highlight", "HSlider", fill)
	return theme


## Large gold title text.
static func title(label: Label, size := 72) -> Label:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", GOLD_BRIGHT)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


## A translucent stone backing for HUD text over the 3D scene.
static func hud_panel() -> StyleBoxFlat:
	var box := _box(Color(STONE_DARK, 0.72), Color(GOLD, 0.55), 2)
	box.shadow_size = 0
	box.set_content_margin_all(12)
	return box


## Insets a full-screen control so nothing sits under the camera cutout or the
## rounded corners on phones; a no-op on desktop.
static func apply_safe_area(control: Control, extra := 12.0) -> void:
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	var margins := Vector4.ZERO  # left, top, right, bottom in UI units
	if OS.has_feature("mobile"):
		var safe := DisplayServer.get_display_safe_area()
		var window := Vector2(DisplayServer.window_get_size())
		var canvas := control.get_viewport().get_visible_rect().size
		var scale := canvas / window
		margins = Vector4(safe.position.x * scale.x, safe.position.y * scale.y,
				(window.x - safe.end.x) * scale.x, (window.y - safe.end.y) * scale.y)
	control.offset_left = margins.x + extra
	control.offset_top = margins.y + extra
	control.offset_right = -(margins.z + extra)
	control.offset_bottom = -(margins.w + extra)


## Opening animation for panels: fade and grow in from 94%.
static func pop_in(control: Control) -> void:
	control.pivot_offset = control.size / 2.0
	control.modulate.a = 0.0
	control.scale = Vector2.ONE * 0.94
	var tween := control.create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "modulate:a", 1.0, 0.22)
	tween.tween_property(control, "scale", Vector2.ONE, 0.26)


static func _box(bg: Color, border: Color, width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(4)
	box.shadow_color = Color(0, 0, 0, 0.5)
	box.shadow_size = 4
	box.shadow_offset = Vector2(0, 3)
	box.set_content_margin_all(14)
	return box
