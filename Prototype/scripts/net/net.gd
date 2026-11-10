extends Node
## Autoload "Net": local Wi-Fi multiplayer. One device hosts (runs the real
## match); friends on the same network join. The host announces itself with a
## UDP broadcast so joiners see it in a list; joining by IP also works.
## Pass `-- --loopback` to keep everything on 127.0.0.1 (tests on one machine).

signal players_changed
signal hosts_changed
signal match_starting(seed_teams: Dictionary)
signal connection_failed(reason: String)
signal host_left

const GAME_PORT := 24570
const DISCOVERY_PORT := 24571
## Up to 8 players: the host and 7 friends (Classic is 4v4).
const MAX_CLIENTS := 7
const TAG := "FZFOC1"

enum Mode { VERSUS, COOP }

## peer id → display name, kept in sync by the host.
var players := {}
## peer id → hero id chosen by that player.
var heroes := {}
var my_hero := "vael"
## host ip → {name, players}
var hosts := {}
var mode := Mode.VERSUS
## Classic rules (100 kills, no time limit, no passive gold) for the next match; the host decides.
var classic := false
## Duels on or off for the next match; the host decides.
var duels := true
var my_name := "Player"

var _announce: PacketPeerUDP
var _listen: PacketPeerUDP
var _announce_clock := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(func(): connection_failed.emit("Couldn't reach the host"); leave())
	multiplayer.server_disconnected.connect(func(): host_left.emit(); leave())


func loopback() -> bool:
	return "--loopback" in OS.get_cmdline_user_args()


func is_online() -> bool:
	return multiplayer.multiplayer_peer != null and not (multiplayer.multiplayer_peer is OfflineMultiplayerPeer)


func is_host() -> bool:
	return is_online() and multiplayer.is_server()


func host() -> String:
	leave()
	var peer := ENetMultiplayerPeer.new()
	if loopback():
		peer.set_bind_ip("127.0.0.1")
	var error := peer.create_server(GAME_PORT, MAX_CLIENTS)
	if error != OK:
		return "Couldn't host (port %d busy?)" % GAME_PORT
	multiplayer.multiplayer_peer = peer
	players = {1: my_name}
	heroes = {1: my_hero}
	_announce = PacketPeerUDP.new()
	_announce.set_broadcast_enabled(true)
	players_changed.emit()
	return ""


func join(address: String) -> String:
	leave()
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, GAME_PORT)
	if error != OK:
		return "Couldn't connect to %s" % address
	multiplayer.multiplayer_peer = peer
	return ""


func leave() -> void:
	if multiplayer.multiplayer_peer and not (multiplayer.multiplayer_peer is OfflineMultiplayerPeer):
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players = {}
	if _announce:
		_announce.close()
		_announce = null
	players_changed.emit()


func start_discovery() -> void:
	stop_discovery()
	hosts = {}
	_listen = PacketPeerUDP.new()
	if _listen.bind(DISCOVERY_PORT, "127.0.0.1" if loopback() else "*") != OK:
		_listen = null


func stop_discovery() -> void:
	if _listen:
		_listen.close()
		_listen = null


## Host only: everyone loads the arena. Teams: peer id → team (bots fill the rest).
func start_match() -> void:
	if not is_host():
		return
	var teams := {}
	var index := 0
	for peer_id in _sorted_peers():
		teams[peer_id] = 0 if mode == Mode.COOP else index % 2
		index += 1
	_announce_stop()
	_begin_match.rpc(teams, _unique_choices(), {"classic": classic, "duels": duels, "bot_seed": randi_range(1, 999999)})


## Each hero once per match: a player who picked a hero already taken (by the
## host or an earlier joiner) gets the first free one.
func _unique_choices() -> Dictionary:
	var resolved := {}
	var taken := []
	for peer_id in _sorted_peers():
		var choice: String = heroes.get(peer_id, "vael")
		if taken.has(choice):
			for hero_id in Roster.ids():
				if not taken.has(hero_id):
					choice = hero_id
					break
		resolved[peer_id] = choice
		taken.append(choice)
	return resolved


@rpc("authority", "call_local", "reliable")
func _begin_match(teams: Dictionary, hero_choices: Dictionary, rules: Dictionary) -> void:
	heroes = hero_choices
	classic = rules.get("classic", false)
	duels = rules.get("duels", true)
	var session := get_node("/root/Session")
	session.classic = classic
	session.duels = duels
	session.bot_seed = rules.get("bot_seed", 0)
	match_starting.emit(teams)


func _process(delta: float) -> void:
	if _announce and is_host():
		_announce_clock += delta
		if _announce_clock >= 1.0:
			_announce_clock = 0.0
			var message := "%s|%s|%d" % [TAG, my_name, players.size()]
			var target := "127.0.0.1" if loopback() else "255.255.255.255"
			_announce.set_dest_address(target, DISCOVERY_PORT)
			_announce.put_packet(message.to_utf8_buffer())
	if _listen:
		while _listen.get_available_packet_count() > 0:
			var data := _listen.get_packet().get_string_from_utf8()
			var ip := _listen.get_packet_ip()
			var parts := data.split("|")
			if parts.size() == 3 and parts[0] == TAG:
				var known := hosts.has(ip)
				hosts[ip] = {"name": parts[1], "players": int(parts[2])}
				if not known:
					hosts_changed.emit()


func _announce_stop() -> void:
	if _announce:
		_announce.close()
		_announce = null


func _sorted_peers() -> Array:
	var ids := players.keys()
	ids.sort()
	return ids


func _on_connected() -> void:
	_register.rpc_id(1, my_name, my_hero)


@rpc("any_peer", "reliable")
func _register(player_name: String, hero_id: String) -> void:
	if not is_host():
		return
	players[multiplayer.get_remote_sender_id()] = player_name
	heroes[multiplayer.get_remote_sender_id()] = hero_id
	_sync_players.rpc(players)
	players_changed.emit()


@rpc("authority", "call_remote", "reliable")
func _sync_players(roster: Dictionary) -> void:
	players = roster
	players_changed.emit()


func _on_peer_connected(_id: int) -> void:
	pass  # the new peer registers its name via _register


func _on_peer_disconnected(id: int) -> void:
	if is_host():
		players.erase(id)
		heroes.erase(id)
		_sync_players.rpc(players)
		players_changed.emit()
