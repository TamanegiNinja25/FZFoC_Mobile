class_name LobbyPanel
extends PanelContainer
## Play with Friends: host a game on this phone's Wi-Fi, or join one found on
## the network or by typing the host's address. Everyone must be on the same
## Wi-Fi. The host's address is shown big on its screen; joiners get their own
## network prefix filled in, so they only type the last number. The last
## address and name are remembered. The host picks Versus or Co-op and the
## rules, then starts; bots fill any empty slots.

signal back_requested

const PREFS := "user://lobby.cfg"
## How long a join by address may take before we say nothing answered.
const CONNECT_TIMEOUT := 8.0

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
var _host_address := Label.new()
var _my_address := Label.new()
var _connect_clock := -1.0
var _connecting_to := ""


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
	_name.text = _pref("name", "Player")
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
	_host_address.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_host_address.add_theme_font_size_override("font_size", 34)
	_host_address.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	_pages.hosting.add_child(_host_address)
	_mode.add_item("Versus — friends split into teams", 0)
	_mode.add_item("Co-op — friends together vs bots", 1)
	_mode.custom_minimum_size = Vector2(560, 56)
	_mode.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_mode.item_selected.connect(func(i: int): _net.mode = i)
	_pages.hosting.add_child(_mode)
	var rules := OptionButton.new()
	rules.add_item("Mobile — first to 15 kills or 8:00", 0)
	rules.add_item("Classic — first to 100 kills, no time limit", 1)
	rules.custom_minimum_size = Vector2(560, 56)
	rules.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rules.select(1 if _net.classic else 0)
	rules.item_selected.connect(func(i: int): _net.classic = i == 1)
	_pages.hosting.add_child(rules)
	# The map lets the host switch duels off for the match.
	var duels := OptionButton.new()
	duels.add_item("Duels every ~5 minutes", 0)
	duels.add_item("No duels", 1)
	duels.custom_minimum_size = Vector2(560, 56)
	duels.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	duels.select(0 if _net.duels else 1)
	duels.item_selected.connect(func(i: int): _net.duels = i == 0)
	_pages.hosting.add_child(duels)
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
	_my_address.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_my_address.add_theme_color_override("font_color", UiTheme.MUTED)
	_pages.joining.add_child(_my_address)
	var ip_row := HBoxContainer.new()
	ip_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_ip.placeholder_text = "host's address, e.g. 192.168.1.5"
	_ip.custom_minimum_size = Vector2(360, 56)
	_ip.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER_DECIMAL
	_ip.text_submitted.connect(func(text: String): _connect(text.strip_edges()))
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
	_connect_clock = -1.0
	_status.text = reason
	_show("joining")


## A join by address that nobody answers fails after CONNECT_TIMEOUT seconds.
func _process(delta: float) -> void:
	if _connect_clock < 0.0:
		return
	if _net.is_online() and _net.players.size() > 0:
		_connect_clock = -1.0
		_set_pref("last_host", _connecting_to)
		return
	_connect_clock += delta
	if _connect_clock >= CONNECT_TIMEOUT:
		_connect_clock = -1.0
		_net.leave()
		_on_connection_failed("No game answered at %s. Check that both phones are on the same Wi-Fi and the host is on the Hosting screen." % _connecting_to)


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
	_set_pref("name", _net.my_name)
	_status.text = "Hosting — friends on the same Wi-Fi tap Join Game"
	_host_address.text = "Your address:  %s" % _local_ip()
	_show("hosting")
	_refresh_players()


func _join_page() -> void:
	_apply_hero_choice()
	_net.my_name = _name.text.strip_edges() if _name.text.strip_edges() != "" else "Friend"
	_set_pref("name", _net.my_name)
	_net.start_discovery()
	_status.text = "Looking for games…"
	var mine := _local_ip()
	_my_address.text = "This phone: %s — the host's address should start the same way" % mine
	# Prefill: the last host if it's on this network, else this network's prefix.
	var last: String = _pref("last_host", "")
	if last != "" and _same_network(last, mine):
		_ip.text = last
	elif _ip.text == "" and mine.count(".") == 3:
		_ip.text = mine.substr(0, mine.rfind(".") + 1)
	_refresh_hosts()
	_show("joining")


func _connect(address: String) -> void:
	if address == "":
		return
	if not address.is_valid_ip_address():
		_status.text = "\"%s\" isn't an address — it looks like 192.168.1.5" % address
		return
	var mine := _local_ip()
	if mine.count(".") == 3 and not _same_network(address, mine):
		_status.text = "%s isn't on this phone's Wi-Fi (%s…). Trying anyway." % [address, mine.substr(0, mine.rfind("."))]
	_net.stop_discovery()
	var error: String = _net.join(address)
	if error != "":
		_status.text = error
		return
	_status.text = "Connecting to %s…" % address
	_connecting_to = address
	_connect_clock = 0.0
	_show("waiting")


func _leave() -> void:
	_connect_clock = -1.0
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


## Same /24 network: the first three numbers match (home Wi-Fi routers).
static func _same_network(a: String, b: String) -> bool:
	var pa := a.split(".")
	var pb := b.split(".")
	return pa.size() == 4 and pb.size() == 4 and pa[0] == pb[0] and pa[1] == pb[1] and pa[2] == pb[2]


func _pref(key: String, fallback: Variant) -> Variant:
	var file := ConfigFile.new()
	if file.load(PREFS) != OK:
		return fallback
	return file.get_value("lobby", key, fallback)


func _set_pref(key: String, value: Variant) -> void:
	var file := ConfigFile.new()
	file.load(PREFS)
	file.set_value("lobby", key, value)
	file.save(PREFS)


func _local_ip() -> String:
	for address in IP.get_local_addresses():
		if address.begins_with("192.168.") or address.begins_with("10.") or address.begins_with("172."):
			return address
	return "this device"
