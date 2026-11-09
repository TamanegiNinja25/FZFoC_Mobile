class_name ShopPanel
extends PanelContainer
## Shop by category: tabs, an icon grid with prices, a detail pane with Buy,
## and the 6-slot inventory (tap an item to sell it for 75%). Stats sells the
## reference map's tomes (used up at once), Exclusive the heroes' signature
## items, and Artifacts lists the combining-circle recipes (made, not bought).
## The match keeps running while it's open, as in classic hero arenas.

signal closed

var hero: Hero
var selected_id := ""

var _grid := GridContainer.new()
var _details := RichTextLabel.new()
var _buy := Button.new()
var _status := Label.new()
var _gold := Label.new()
var _slots: Array[Button] = []
var _tabs := {}


func _ready() -> void:
	custom_minimum_size = Vector2(1180, 0)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	add_child(column)

	var header := HBoxContainer.new()
	column.add_child(header)
	var heading := UiTheme.title(Label.new(), 38)
	heading.text = "Shop"
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	_gold.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	_gold.add_theme_font_size_override("font_size", 26)
	header.add_child(_gold)

	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 8)
	column.add_child(tabs)
	for category in ["All"] + ItemCatalog.CATEGORIES:
		var tab := Button.new()
		tab.text = category
		tab.toggle_mode = true
		tab.custom_minimum_size = Vector2(118, 48)
		tab.add_theme_font_size_override("font_size", 17)
		tab.pressed.connect(show_category.bind(category))
		tabs.add_child(tab)
		_tabs[category] = tab

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 18)
	column.add_child(body)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(640, 300)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_grid.columns = 4
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(_grid)

	var side := VBoxContainer.new()
	side.add_theme_constant_override("separation", 10)
	body.add_child(side)
	_details.bbcode_enabled = true
	_details.fit_content = false
	_details.scroll_active = false
	_details.custom_minimum_size = Vector2(440, 190)
	for size_name in ["normal_font_size", "bold_font_size"]:
		_details.add_theme_font_size_override(size_name, 20)
	_details.add_theme_color_override("default_color", UiTheme.PARCHMENT)
	side.add_child(_details)
	_buy.text = "Buy"
	_buy.custom_minimum_size = Vector2(440, 62)
	_buy.set_meta("sfx", "confirm")
	_buy.pressed.connect(_on_buy)
	side.add_child(_buy)
	_status.add_theme_color_override("font_color", Color(1.0, 0.6, 0.45))
	_status.add_theme_font_size_override("font_size", 18)
	side.add_child(_status)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	column.add_child(footer)
	var label := Label.new()
	label.text = "Inventory (tap to sell):"
	label.add_theme_font_size_override("font_size", 18)
	footer.add_child(label)
	for i in ItemCatalog.INVENTORY_SIZE:
		var slot := Button.new()
		slot.custom_minimum_size = Vector2(72, 72)
		slot.expand_icon = true
		slot.pressed.connect(_on_sell.bind(i))
		footer.add_child(slot)
		_slots.append(slot)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)
	var close := Button.new()
	close.text = "Back"
	close.custom_minimum_size = Vector2(180, 64)
	close.pressed.connect(func(): closed.emit())
	footer.add_child(close)

	show_category("All")
	select_item(ItemCatalog.all()[0].id)


func open_for(target: Hero) -> void:
	if hero and hero.items_changed.is_connected(_refresh):
		hero.items_changed.disconnect(_refresh)
	hero = target
	hero.items_changed.connect(_refresh)
	_status.text = ""
	_refresh()


func _process(_delta: float) -> void:
	if visible and hero:
		_gold.text = "%d gold" % floori(hero.gold)
		var item := ItemCatalog.find(selected_id)
		var full := item != null and not item.is_tome() and hero.items.size() >= ItemCatalog.INVENTORY_SIZE
		var wrong_hero := item != null and item.hero_only != "" and item.hero_only != hero.definition.id
		_buy.disabled = item == null or not item.buyable or wrong_hero or hero.gold < item.cost or full or not hero.in_shop_range
		if item and not item.buyable:
			_buy.text = "Forge at a combining circle"
		elif wrong_hero:
			_buy.text = "%s only" % item.hero_only.capitalize()
		else:
			_buy.text = "Buy"


func show_category(category: String) -> void:
	for key in _tabs:
		_tabs[key].button_pressed = key == category
	for child in _grid.get_children():
		child.queue_free()
	for item in ItemCatalog.in_category(category):
		var card := Button.new()
		card.text = "%s\n%s" % [item.display_name, "recipe" if not item.buyable else str(item.cost)]
		card.icon = item.icon()
		card.expand_icon = true
		card.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		card.custom_minimum_size = Vector2(150, 150)
		card.add_theme_font_size_override("font_size", 15)
		card.add_theme_constant_override("icon_max_width", 72)
		card.toggle_mode = true
		card.button_pressed = item.id == selected_id
		card.set_meta("item_id", item.id)
		card.pressed.connect(select_item.bind(item.id))
		_grid.add_child(card)


func select_item(item_id: String) -> void:
	selected_id = item_id
	var item := ItemCatalog.find(item_id)
	for card in _grid.get_children():
		if card.has_meta("item_id"):
			card.button_pressed = card.get_meta("item_id") == item_id
	if item:
		var note := ""
		if item.consumable:
			note = "\n\n[i]Consumable: tap it in the HUD inventory to use.[/i]"
		elif item.is_tome():
			note = "\n\n[i]Used up the moment you buy it — no inventory slot.[/i]"
		elif not item.buyable:
			note = "\n\n[color=#ffd673]Recipe:[/color] %s\n[i]Carry the parts into a combining circle (beside each base).[/i]" % ItemCatalog.recipe_text(item.id)
		var price := "made from parts worth %d gold" % item.cost if not item.buyable else "%d gold" % item.cost
		_details.text = "[font_size=28][color=#ffd673]%s[/color][/font_size]\n[i]%s[/i] — [color=#ffd673]%s[/color]\n\n%s%s" % [
			item.display_name, item.category, price, item.description, note]
	_status.text = ""


func _on_buy() -> void:
	var item := ItemCatalog.find(selected_id)
	var error := hero.buy(selected_id)
	_status.text = error
	if error == "" and item and item.is_tome():
		_status.text = "%s used" % item.display_name
	Sfx.play("error" if error != "" else "coins", -4.0)


func _on_sell(index: int) -> void:
	if hero and index < hero.items.size():
		var refund := floori(hero.items[index].cost * ItemCatalog.SELL_RATE)
		if hero.sell(index):
			_status.text = "Sold for %d gold" % refund
			Sfx.play("coins", -4.0)
		else:
			_status.text = "Return to your fountain to sell"


func _refresh() -> void:
	if hero == null:
		return
	for i in _slots.size():
		var slot := _slots[i]
		if i < hero.items.size():
			slot.icon = hero.items[i].icon()
			slot.tooltip_text = hero.items[i].display_name
			slot.disabled = false
		else:
			slot.icon = null
			slot.tooltip_text = ""
			slot.disabled = true
