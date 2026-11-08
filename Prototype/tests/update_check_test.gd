extends SceneTree
## Headless check of the release version comparison used by the update notice:
##   Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/update_check_test.gd


func _initialize() -> void:
	var cases := [
		["v0.6.0", "0.5.0", true],
		["v0.5.1", "0.5.0", true],
		["v1.0.0", "0.9.9", true],
		["v0.10.0", "0.9.0", true],   # numeric, not alphabetical
		["v0.5.0", "0.5.0", false],
		["v0.4.9", "0.5.0", false],
		["v0.5", "0.5.0", false],     # missing parts count as zero
		["0.5.0.1", "0.5.0", true],
	]
	var failures := 0
	for c in cases:
		var got := UpdateChecker.is_newer(c[0], c[1])
		var ok: bool = got == c[2]
		print("%s  is_newer(%s, %s) = %s" % ["PASS" if ok else "FAIL", c[0], c[1], got])
		if not ok:
			failures += 1
	var version := UpdateChecker.current_version()
	print("%s  project version is %s" % ["PASS" if version != "0.0.0" else "FAIL", version])
	if version == "0.0.0":
		failures += 1
	print("UPDATE CHECK: %s" % ("PASS" if failures == 0 else "FAIL (%d)" % failures))
	quit(1 if failures else 0)
