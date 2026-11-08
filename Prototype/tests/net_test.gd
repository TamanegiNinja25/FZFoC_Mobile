extends SceneTree
## Two-process local multiplayer check (run by tests/run_net_test.ps1):
##   host:   godot --headless --path Prototype -s res://tests/net_test.gd -- --loopback --role=host
##   client: godot --headless --path Prototype -s res://tests/net_test.gd -- --loopback --role=client
## The client discovers the host, joins, both load the arena, the client's
## stick input moves its hero on the host, and the host's score reaches the client.

var _net: Node
var _role := ""
var _arena: Node
var _phase := "start"
var _clock := 0.0
var _mark := Vector3.ZERO
var _settle := 0.0
## `--join=IP`: join a real host by address (skips discovery; e.g. a phone
## hosting on Wi-Fi). Only movement is checked, since the host isn't scripted.
var _join_ip := ""

var _failures: Array[String] = []


func _initialize() -> void:
	_net = root.get_node("Net")
	_role = "host" if "--role=host" in OS.get_cmdline_user_args() else "client"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--join="):
			_join_ip = arg.substr(7)
	_net.match_starting.connect(_on_match_starting)


func _process(delta: float) -> bool:
	_clock += delta
	if _clock > (90.0 if _join_ip != "" else 45.0) and _phase != "done":
		_check(false, "finished within 45 s (stuck in phase '%s')" % _phase)
		_finish()
	match _role + ":" + _phase:
		"host:start":
			_net.my_name = "HostPlayer"
			_check(_net.host() == "", "host started on port %d" % _net.GAME_PORT)
			_phase = "lobby"
		"host:lobby":
			if _net.players.size() == 2:
				_check(true, "client joined the lobby (players: %s)" % str(_net.players.values()))
				_net.mode = _net.Mode.VERSUS
				_net.start_match()
				_phase = "loading"
		"host:playing":
			var guest: Node = _arena.heroes.filter(func(h): return h.owner_peer != 1 and h.owner_peer != 0)[0]
			if guest.global_position.x > _mark.x + 3.0:
				_check(true, "client's stick input moved its hero on the host (Δx %.1f)" % (guest.global_position.x - _mark.x))
				var victim: Node = _arena.heroes.filter(func(h): return h.team == 0 and h.owner_peer == 0)[0]
				victim.take_damage(99999.0, guest)
				_check(_arena.kills[1] == 1, "host scored a kill for the client's team")
				_phase = "linger"
				_clock = 30.0  # give the client time to see it, then end
		"host:linger":
			if _clock > 40.0:
				_finish()
		"client:start":
			_net.my_name = "ClientPlayer"
			if _join_ip != "":
				_check(_net.join(_join_ip) == "", "joining %s directly" % _join_ip)
				_phase = "lobby"
			else:
				_net.start_discovery()
				_phase = "discover"
		"client:lobby":
			if _net.players.size() >= 2:
				_check(true, "joined the host's lobby: %s" % str(_net.players.values()))
				print("READY_FOR_START")
				_phase = "loading"
		"client:discover":
			if _net.hosts.has("127.0.0.1"):
				_check(_net.hosts["127.0.0.1"].name == "HostPlayer", "discovered the host by broadcast (%s)" % str(_net.hosts))
				_check(_net.join("127.0.0.1") == "", "joining 127.0.0.1")
				_phase = "loading"
		"client:playing":
			if not is_instance_valid(_arena):
				_check(false, "arena still open (host left early)")
				_finish()
				return false
			var me: Node = _arena.hero
			Input.action_press("move_right", 1.0)
			# The host teleports this hero first; measure from where it lands.
			if _settle < 1.0:
				_settle += delta
				_mark = me.global_position
				return false
			if _join_ip != "" and me.global_position.distance_to(_mark) > 3.0:
				_check(true, "own hero moved via the remote host's snapshots (%.1f units)" % me.global_position.distance_to(_mark))
				Input.action_release("move_right")
				_finish()
				return false
			if _arena.kills[1] >= 1 and me.global_position.x > _mark.x + 3.0:
				_check(true, "own hero moved via the host's snapshots (Δx %.1f)" % (me.global_position.x - _mark.x))
				_check(true, "score reached the client (Blue %d — %d Red)" % [_arena.kills[0], _arena.kills[1]])
				Input.action_release("move_right")
				_finish()
	return false


func _on_match_starting(teams: Dictionary) -> void:
	var session: Node = root.get_node("Session")
	session.mode = session.Mode.LOCAL_FRIENDS
	session.net_teams = teams
	_check(teams.size() == 2 and teams.values().has(0) and teams.values().has(1), "versus teams assigned: %s" % str(teams))
	_arena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(_arena)
	current_scene = _arena
	await process_frame
	await process_frame
	_check(_arena.online and _arena.heroes.size() == 6, "%s loaded the online arena (6 heroes)" % _role)
	_check(_arena.heroes.filter(func(h): return h.is_player).size() == 1, "%s controls exactly one hero" % _role)
	if _role == "client":
		_check(_arena.heroes.all(func(h): return h.puppet), "client heroes are puppets of the host")
		_mark = _arena.hero.global_position
	else:
		_check(_arena.bots.size() == 4, "host runs 4 bots for the empty slots")
		var guest: Node = _arena.heroes.filter(func(h): return h.owner_peer != 1 and h.owner_peer != 0)[0]
		guest.global_position = Vector3(-10, 0, 16)  # open ground, away from bots
		_mark = guest.global_position
	_phase = "playing"


func _finish() -> void:
	_phase = "done"
	for failure in _failures:
		printerr("FAIL [%s]: %s" % [_role, failure])
	print("NET TEST %s %s (%d checks failed)" % [_role.to_upper(), "PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
	_net.leave()
	quit(1 if _failures.size() else 0)


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   [%s] %s" % [_role, what])
	else:
		_failures.append(what)
