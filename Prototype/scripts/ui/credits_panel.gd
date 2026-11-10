class_name CreditsPanel
extends PanelContainer
## Credits: the game's own work, then every third-party creator whose assets
## ship in the game, with licence and what each asset is used for. Mirrors
## assets/thirdparty/CREDITS.md — keep the two in step.

signal closed

## [creator, work, licence, used for]
const THIRD_PARTY := [
	["Kay Lousberg (kaylousberg.com)", "KayKit Character Pack: Adventurers 1.0", "CC0 1.0", "Hero models and animations"],
	["Kay Lousberg", "KayKit Character Pack: Skeletons 1.0", "CC0 1.0", "Morrow, Kael and the Barrow-Dead summons"],
	["Quaternius (quaternius.com)", "RPG Characters (Nov 2020)", "CC0 1.0", "Oren, Ashka, Nyx, Velka, Corin and Lys"],
	["Kay Lousberg", "KayKit Medieval Hexagon Pack 1.0", "CC0 1.0", "Castles, towers, banners and scenery"],
	["Kenney (kenney.nl)", "50 RPG Sound Effects", "CC0 1.0", "Hit, dash and coin sounds"],
	["Kenney", "Interface Sounds", "CC0 1.0", "Menu and button sounds"],
	["Kenney", "UI Pack: RPG Extension", "CC0 1.0", "Button and panel skins"],
	["cynicmusic (OpenGameArt)", "Town Theme RPG", "CC0 1.0", "Menu music"],
	["cynicmusic", "Battle Theme A", "CC0 1.0", "Battle music"],
	["Kenney", "Voiceover Pack: Fighter", "CC0 1.0", "Announcer lines"],
	["HaelDB (OpenGameArt)", "Male Grunt/Yelling sounds", "CC0 1.0", "Hero battle cries"],
	["thebardofblasphemy (OpenGameArt)", "grunts of male death and pain", "CC0 1.0", "Hero death cries"],
	["JeanMyna_VA (OpenGameArt)", "Aha! voice pack — Female Fighter Voice Over", "CC-BY 3.0", "Female heroes' battle cries — Voice: JeanMyna_VA (CC-BY 3.0)"],
]


func _ready() -> void:
	custom_minimum_size = Vector2(860, 560)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	add_child(column)

	var heading := UiTheme.title(Label.new(), 40)
	heading.text = "Credits"
	column.add_child(heading)

	var text := RichTextLabel.new()
	text.bbcode_enabled = true
	text.fit_content = false
	text.scroll_active = true
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.add_theme_font_size_override("normal_font_size", 20)
	text.add_theme_font_size_override("bold_font_size", 22)
	text.add_theme_color_override("default_color", UiTheme.PARCHMENT)
	text.text = credits_text()
	column.add_child(text)

	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(240, 64)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(func(): closed.emit())
	column.add_child(back)


static func credits_text() -> String:
	var gold := UiTheme.GOLD_BRIGHT.to_html(false)
	var muted := UiTheme.MUTED.to_html(false)
	var lines := PackedStringArray()
	lines.append("[center][b][color=#%s]FrozenThrone: Fight Of The Characters[/color][/b]" % gold)
	lines.append("An original hero arena. Code, all 24 heroes, skill icons, effects, skill sounds and generated sounds are original work.[/center]")
	lines.append("")
	lines.append("[b][color=#%s]Assets by other creators[/color][/b] — thank you!" % gold)
	for entry in THIRD_PARTY:
		lines.append("[b]%s[/b] — %s  [color=#%s](%s)[/color]\n    %s" % [entry[1], entry[0], muted, entry[2], entry[3]])
	lines.append("")
	lines.append("[color=#%s]Engine: Godot Engine (MIT licence) — godotengine.org[/color]" % muted)
	return "\n".join(lines)
