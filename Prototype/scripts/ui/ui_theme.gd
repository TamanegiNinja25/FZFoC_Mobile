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
