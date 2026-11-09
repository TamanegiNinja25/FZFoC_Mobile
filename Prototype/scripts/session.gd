extends Node
## Autoload "Session": choices made in the menus for the next match.

enum Mode { SINGLE_PLAYER, LOCAL_FRIENDS }

var mode := Mode.SINGLE_PLAYER
var hero_id := "vael"
## Classic: the reference map's rules — first to 100 kills, no time limit, no
## passive gold. Otherwise Mobile: 15 kills or 8:00.
var classic := false
## Duels every ~5 min; the host can switch them off for the match, as the map allows.
var duels := true
## Local multiplayer: peer id → team, chosen by the host when the match starts.
var net_teams := {}
## A message for the main menu (e.g. "The host left the game").
var notice := ""
