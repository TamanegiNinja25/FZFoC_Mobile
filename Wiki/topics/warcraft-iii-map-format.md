---
type: topic
category: Warcraft III modding
sources: [2026-11-08-fight-of-characters-mobile-feasibility]
updated: 2026-11-08
---
# Warcraft III map format

Warcraft III maps (`.w3x` for The Frozen Throne, `.w3m` for Reign of Chaos) are archives that bundle a map's script, data and imported assets. Map makers often "protect" them by scrambling the archive and script so they can't easily be opened in the editor.

## Structure
- A map is an MPQ archive, Blizzard's archive format, and can be unpacked with an MPQ reader ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- Inside are the map info, text strings, object data (units, abilities, items), imported files and the script ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- The script normally lives at `war3map.j` and is written in JASS, Warcraft III's scripting language ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- The archive is preceded by a 512-byte map header, and the archive's file tables are encrypted with publicly known keys *(inference)*.
- The archive normally contains a file list, `(listfile)`, naming every file inside *(inference)*.

## Protection
Techniques seen in [Fight Of Characters](fight-of-characters.md) ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)):
- The file list and `(attributes)` are stripped down and stored with an older compression method (PKWARE implode).
- The script is moved from `war3map.j` to `scripts\war3map.j`.
- All 1,139 script functions are renamed to two-letter names (`BO`, `dO`, `gO`…).
- The script uses carriage-return-only line breaks (9,495 lines, 436 KB).

Protection hides things but doesn't encrypt them meaningfully: the game finds files by hashing their names, so it never needs the file list *(inference)*.

## Safety checks
A map's script can call functions that touch the player's computer. The checks applied to Fight Of Characters ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)):
- **Preload file writes** — none found.
- **Game-cache disk access** — none found.
- **`ExecuteFunc`** (runs a function by name) — one call.

The verdict was ordinary anti-copying protection, not malware ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).

## Related
- [Fight Of Characters](fight-of-characters.md)
- [Copyright vs game mechanics](copyright-vs-game-mechanics.md) — why the scrambled code can't be reused
