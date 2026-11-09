extends SceneTree
## Headless check of joining by address on the same Wi-Fi:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/lobby_test.gd
## Address checks, the same-network rule, and a join to an address where no game
## answers failing with a clear message instead of hanging.

var _lobby: Node
var _clock := 0.0
var _phase := "start"
var _failures: Array[String] = []


func _process(delta: float) -> bool:
	match _phase:
		"start":
			_lobby = LobbyPanel.new()
			root.add_child(_lobby)
			_check("192.168.1.5".is_valid_ip_address() and not "192.168.1".is_valid_ip_address() and not "hello".is_valid_ip_address(),
					"addresses are validated (192.168.1.5 yes; 192.168.1 and words no)")
			_check(LobbyPanel._same_network("192.168.1.5", "192.168.1.33") and not LobbyPanel._same_network("192.168.1.5", "192.168.0.5"),
					"same Wi-Fi means the first three numbers match")
			_lobby._connect("not an address")
			_check(_lobby._status.text.contains("isn't an address"), "a typo gets a clear message, no connection attempt")
			# TEST-NET-1 (RFC 5737): never routed, so nothing can answer.
			_lobby._connect("192.0.2.1")
			_check(_lobby._connect_clock >= 0.0, "joining by address starts the connect timer")
			_phase = "waiting"
		"waiting":
			_clock += delta
			var failed: bool = _lobby._status.text.contains("No game answered") or _lobby._status.text.contains("Couldn't")
			if failed or _clock > LobbyPanel.CONNECT_TIMEOUT + 4.0:
				_check(failed and _lobby._pages.joining.visible, "an address where no game answers fails clearly within %d s (%.1f s)" % [LobbyPanel.CONNECT_TIMEOUT, _clock])
				_finish()
	return false


func _finish() -> void:
	for failure in _failures:
		printerr("FAIL: " + failure)
	print("LOBBY TEST %s (%d checks failed)" % ["PASSED" if _failures.is_empty() else "FAILED", _failures.size()])
	quit(1 if _failures.size() else 0)


func _check(ok: bool, what: String) -> void:
	if ok:
		print("ok   " + what)
	else:
		_failures.append(what)
