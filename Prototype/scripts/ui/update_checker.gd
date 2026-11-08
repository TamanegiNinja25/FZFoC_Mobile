class_name UpdateChecker
extends HTTPRequest
## Asks GitHub for the latest release and reports when it's newer than this
## build (application/config/version). Fails silently when offline.

signal update_available(version: String, url: String)

const REPO := "TamanegiNinja25/FrozenThrone_FightOfTheCharacters"
const API := "https://api.github.com/repos/%s/releases/latest" % REPO
const RELEASES := "https://github.com/%s/releases/latest" % REPO


func _ready() -> void:
	timeout = 8.0
	request_completed.connect(_on_completed)
	request(API, ["Accept: application/vnd.github+json", "User-Agent: FZFoC-update-check"])


static func current_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))


## True when `latest` (e.g. "v0.6.0") is a higher version than `current`.
static func is_newer(latest: String, current: String) -> bool:
	var a := latest.trim_prefix("v").split(".")
	var b := current.trim_prefix("v").split(".")
	for i in maxi(a.size(), b.size()):
		var x := int(a[i]) if i < a.size() else 0
		var y := int(b[i]) if i < b.size() else 0
		if x != y:
			return x > y
	return false


func _on_completed(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		return
	var data: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(data) != TYPE_DICTIONARY or not data.has("tag_name"):
		return
	var tag: String = data.tag_name
	if is_newer(tag, current_version()):
		update_available.emit(tag, str(data.get("html_url", RELEASES)))
