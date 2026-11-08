extends Node
## Autoload "Session": choices made in the menus for the next match.

enum Mode { SINGLE_PLAYER, LOCAL_FRIENDS }

var mode := Mode.SINGLE_PLAYER
var hero_id := "vael"
## Local multiplayer: peer id → team, chosen by the host when the match starts.
var net_teams := {}
## A message for the main menu (e.g. "The host left the game").
var notice := ""
