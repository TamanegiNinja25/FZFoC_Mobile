class_name LobbyPanel
extends PanelContainer
## Play with Friends: host a game on this phone's Wi-Fi, or join one found on
## the network (or by IP). The host picks Versus or Co-op and starts the match;
## bots fill any empty slots.

signal back_requested

var _net: Node
var _name := LineEdit.new()
var _status := Label.new()
var _players := Label.new()
var _hosts := VBoxContainer.new()
var _ip := LineEdit.new()
var _mode := OptionButton.new()
var _hero := OptionButton.new()
var _start := Button.new()
var _pages := {}


func _ready() -> void:
	_net = get_node("/root/Net")
	custom_minimum_size = Vector2(820, 0)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	add_child(column)
	var heading := UiTheme.title(Label.new(), 40)
	heading.text = "Play with Friends"
	column.add_child(heading)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD
	_status.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	column.add_child(_status)

	_pages.choose = _page(column)
	var name_row := HBoxContainer.new()
	name_row.alignment = BoxContainer.ALIGNMENT_CENTER
	var name_label := Label.new()
	name_label.text = "Your name:"
	name_row.add_child(name_label)
	_name.text = "Player"
	_name.max_length = 16
	_name.custom_minimum_size = Vector2(300, 52)
	name_row.add_child(_name)
	_pages.choose.add_child(name_row)
	var hero_row := HBoxContainer.new()
	hero_row.alignment = BoxContainer.ALIGNMENT_CENTER
	var hero_label := Label.new()
	hero_label.text = "Your hero:"
	hero_row.add_child(hero_label)
	for definition in Roster.all():
		_hero.add_item("%s — %s" % [definition.display_name, definition.role])
		_hero.set_item_metadata(_hero.item_count - 1, definition.id)
	_hero.custom_minimum_size = Vector2(300, 52)
	hero_row.add_child(_hero)
	_pages.choose.add_child(hero_row)
	_pages.choose.add_child(_button("Host Game", _host, "confirm"))
	_pages.choose.add_child(_button("Join Game", _join_page))
	_pages.choose.add_child(_button("Back", func(): back_requested.emit()))

	_pages.hosting = _page(column)
	_mode.add_item("Versus — friends split into teams", 0)
	_mode.add_item("Co-op — friends together vs bots", 1)
	_mode.custom_minimum_size = Vector2(560, 56)
	_mode.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_mode.item_selected.connect(func(i: int): _net.mode = i)
	_pages.hosting.add_child(_mode)
	_players.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pages.hosting.add_child(_players)
	_start.text = "Start Match"
	_start.set_meta("sfx", "confirm")
	_start.custom_minimum_size = Vector2(360, 64)
	_start.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_start.pressed.connect(func(): _net.start_match())
	_pages.hosting.add_child(_start)
	_pages.hosting.add_child(_button("Leave", _leave))

	_pages.joining = _page(column)
	var found := Label.new()
	found.text = "Games on this Wi-Fi:"
	found.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pages.joining.add_child(found)
	_pages.joining.add_child(_hosts)
	var ip_row := HBoxContainer.new()
	ip_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_ip.placeholder_text = "or type the host's IP"
	_ip.custom_minimum_size = Vector2(320, 52)
	ip_row.add_child(_ip)
	var connect := Button.new()
	connect.text = "Connect"
	connect.custom_minimum_size = Vector2(180, 52)
	connect.pressed.connect(func(): _connect(_ip.text.strip_edges()))
	ip_row.add_child(connect)
	_pages.joining.add_child(ip_row)
	_pages.joining.add_child(_button("Back", _leave))

	_pages.waiting = _page(column)
	var waiting_players := Label.new()
	waiting_players.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	waiting_players.name = "Players"
	_pages.waiting.add_child(waiting_players)
	_pages.waiting.add_child(_button("Leave", _leave))

	_net.players_changed.connect(_refresh_players)
	_net.hosts_changed.connect(_refresh_hosts)
	_net.connection_failed.connect(_on_connection_failed)
	visibility_changed.connect(_on_visibility_changed)
	_show("choose")


func _on_connection_failed(reason: String) -> void:
	_status.text = reason
	_show("joining")


func _on_visibility_changed() -> void:
	if visible:
		_show("choose")


func _page(parent: Control) -> VBoxContainer:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	parent.add_child(page)
	return page


func _button(text: String, callback: Callable, sfx := "") -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(360, 64)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if sfx != "":
		button.set_meta("sfx", sfx)
	button.pressed.connect(callback)
	return button


func _show(page: String) -> void:
	for key in _pages:
		_pages[key].visible = key == page
	if page == "choose":
		_status.text = "One phone hosts; friends on the same Wi-Fi join. No servers or accounts."


func _apply_hero_choice() -> void:
	_net.my_hero = str(_hero.get_item_metadata(_hero.selected))


func _host() -> void:
	_apply_hero_choice()
	_net.my_name = _name.text.strip_edges() if _name.text.strip_edges() != "" else "Host"
	var error: String = _net.host()
	if error != "":
		_status.text = error
		return
	_status.text = "Hosting on %s — friends: Join Game" % _local_ip()
	_show("hosting")
	_refresh_players()


func _join_page() -> void:
	_apply_hero_choice()
	_net.my_name = _name.text.strip_edges() if _name.text.strip_edges() != "" else "Friend"
	_net.start_discovery()
	_status.text = "Looking for games…"
	_refresh_hosts()
	_show("joining")


func _connect(address: String) -> void:
	if address == "":
		return
	_net.stop_discovery()
	var error: String = _net.join(address)
	if error != "":
		_status.text = error
		return
	_status.text = "Connecting to %s…" % address
	_show("waiting")


func _leave() -> void:
	_net.stop_discovery()
	_net.leave()
	_show("choose")


func _refresh_players() -> void:
	var names: Array[String] = []
	for peer_id in _net.players:
		var hero_name: String = Roster.create(_net.heroes.get(peer_id, "vael")).display_name if _net.heroes.has(peer_id) else "…"
		names.append("• %s — %s%s" % [_net.players[peer_id], hero_name, "  (host)" if peer_id == 1 else ""])
	var text := "Players:\n" + "\n".join(names) + "\nBots fill the empty slots."
	_players.text = text
	_pages.waiting.get_node("Players").text = text
	if _pages.waiting.visible and _net.is_online() and _net.players.size() > 0:
		_status.text = "Connected — waiting for the host to start"


func _refresh_hosts() -> void:
	for child in _hosts.get_children():
		child.queue_free()
	for ip in _net.hosts:
		var info: Dictionary = _net.hosts[ip]
		_hosts.add_child(_button("%s — %s (%d)" % [info.name, ip, info.players], _connect.bind(ip)))
	if _net.hosts.is_empty():
		var none := Label.new()
		none.text = "None found yet — make sure you're on the same Wi-Fi."
		none.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		none.add_theme_color_override("font_color", UiTheme.MUTED)
		_hosts.add_child(none)


func _local_ip() -> String:
	for address in IP.get_local_addresses():
		if address.begins_with("192.168.") or address.begins_with("10.") or address.begins_with("172."):
			return address
	return "this device"
