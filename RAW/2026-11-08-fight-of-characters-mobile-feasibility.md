---
title: Fight Of Characters 7.7b E — analysis and mobile feasibility
date: 2026-11-08
subject: Warcraft Game/Warcraft III/Maps/FrozenThrone/Community/fight_of_characters 7.7b E.w3x
method: Map archive unpacked with a custom read-only MPQ parser; map info, strings, object data, imported files and script inspected directly.
---

# Fight Of Characters 7.7b E — analysis and mobile feasibility

**Summary:** A Korean-made anime crossover hero arena for Warcraft III (4 vs 4). A direct mobile port is not feasible — it depends on the Warcraft III engine and Blizzard assets, and every hero is a copyrighted anime character. An *original* mobile game reusing its gameplay mechanics is feasible.

## 1. The file

| Property | Value |
|---|---|
| File | `fight_of_characters 7.7b E.w3x` (4.09 MB) |
| Game version | Warcraft III: The Frozen Throne (map info format v25), installed client 1.30.4 |
| Map name | Fight Of Characters 7.7b E |
| Players | 4 vs 4 teams (Red Team vs Blue Team) |
| Description | "English version — Work In Progress", edited by AF_FOC |
| Original authors | Korean modders credited as DlakWkd / dlakwwkd and dhdnthdhdghkdk; community sites w3m.co.kr and cafe.naver.com/w3umf.cafe |
| Archive | 265 files, ~6.9 MB uncompressed, 3,020 text strings (mostly Korean) |

### Protection
The map is deliberately obscured to prevent editing:
- The file list (`(listfile)`) and `(attributes)` are stripped down and stored with an older compression method (PKWARE implode).
- The script is moved to `scripts\war3map.j` instead of the usual `war3map.j`.
- The script (436 KB, 9,495 lines) uses only carriage-return line breaks, and its 1,139 functions are renamed to two-letter names (`BO`, `dO`, `gO`…).

### Safety check
The script was checked for functions that could do harm: no Preload file writes, no game-cache disk access, and one `ExecuteFunc` call (runs another function by name). This is consistent with ordinary anti-copying protection, not malware.

## 2. Game content

| Part | Count / detail |
|---|---|
| Heroes | 36 playable hero forms; transformations are separate forms (e.g. Goku → Super Saiyan 1/2/3, Ichigo → Bankai, Luffy → Gear) |
| Source franchises | One Piece, Naruto, Bleach, Dragon Ball, Hellsing, InuYasha, Yu Yu Hakusho, Fate, Tsukihime; a Pokémon "Monster Ball" item |
| Units | 160 custom units, 91 modified stock units |
| Abilities | 246 custom, 56 modified stock; named after the shows' signature moves, with damage numbers in the thousands (e.g. 1,800–2,100 per hit) |
| Items | 59 custom shop items, including capture-and-summon (Monster Ball), mana and health stones, and summoning scrolls |
| Imported assets | 189 files: 48 3D models (.mdx), 80 icons (.blp), 60 MP3 music tracks, 1 WAV |

### Gameplay systems (from the script)
- Kill-tracking scoreboard (`CreateMultiboard`), with 21 handlers reacting to kills.
- Team victory/defeat conditions and a timer.
- Hero levelling (53 level checks) and items added by script.
- Heavy visual scripting: 175 special effects, 53 animation calls, 120 units spawned by script.

## 3. Mobile feasibility

### Direct port — not feasible
1. **Engine dependency:** the script, models and textures run only inside Warcraft III. Blizzard's engine has no mobile version and isn't licensed out; most of the map's art is Blizzard's own, and Blizzard's licence forbids redistributing it.
2. **Copyright:** all 36 heroes belong to Japanese publishers and studios (Shueisha, Toei, Type-Moon and others), and the music is likely copyrighted too. App stores remove unlicensed games like this, even free ones, and licensing this many franchises is impractical.
3. **Unusable code:** the script is scrambled, belongs to the original modders, and is written for Blizzard's scripting engine.

### Original game in the same genre — feasible
Copyright covers how something is expressed (characters, art, music, names, code), not game mechanics. Keep the mechanics; replace everything protected.

| Keep (game design) | Change |
|---|---|
| Team arena fights, item shop, kill-based victory | Shorter matches (5–8 min), smaller teams (3v3) |
| Mid-fight hero transformations (the map's standout idea) | Original characters, art and music |
| Fast, high-damage, flashy combat | Touch controls: virtual joystick plus 3–4 skill buttons, auto-targeting |
| Summon and capture items | Bots to fill slots, online matchmaking, fair monetisation (cosmetics) |

- **Suggested tools:** Unity or Godot, plus a multiplayer service such as Photon or Nakama.
- **Rough effort:** a playable offline prototype with 2–3 heroes takes weeks; a polished online release takes many months for a small team, with art usually the biggest cost.
- Much of the original's feel comes from Warcraft III's built-in systems (terrain, pathfinding, right-click unit control); a mobile version must build these from scratch.

## 4. Open questions
- Which mechanics define the game's appeal (transformations, item builds, team fights) and should be prototyped first?
- What setting and art style would make an original roster distinctive?
- Target: casual short sessions, or competitive ranked play?
