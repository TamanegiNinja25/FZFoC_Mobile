---
type: source
raw: ../../RAW/2026-11-08-fight-of-characters-mobile-feasibility.md
added: 2026-11-08
why: Assess whether the Warcraft III custom map "Fight Of Characters 7.7b E" could become a mobile game with changes.
---
# Fight Of Characters 7.7b E — analysis and mobile feasibility

A direct inspection of a Korean-made, 4v4 anime crossover hero arena map for Warcraft III: The Frozen Throne. It concludes that a direct mobile port is not feasible (engine dependency, copyrighted characters, unusable scrambled code), but an original mobile game reusing its gameplay mechanics is.

## Key points
- **Identity:** "Fight Of Characters 7.7b E", an English edit labelled Work In Progress by AF_FOC; original by Korean modders (dlakwwkd and others). 4 vs 4, Red Team vs Blue Team. 4.09 MB, 265 archived files, 3,020 text strings.
- **Protection:** stripped and implode-compressed file list, script moved to `scripts\war3map.j`, 1,139 functions renamed to two-letter names, carriage-return-only line breaks.
- **Safety:** no Preload file writes, no game-cache disk access, one `ExecuteFunc` call — judged ordinary anti-copying protection, not malware.
- **Content:** 36 hero forms (transformations are separate forms, e.g. Super Saiyan 1/2/3), 160 custom units, 246 custom abilities, 59 custom items, 189 imported assets (48 models, 80 icons, 60 MP3s, 1 WAV).
- **Franchises used:** One Piece, Naruto, Bleach, Dragon Ball, Hellsing, InuYasha, Yu Yu Hakusho, Fate, Tsukihime, plus a Pokémon "Monster Ball" item.
- **Systems:** kill-tracking scoreboard with 21 kill handlers, team victory/defeat, timer, hero levelling, 175 scripted special effects.
- **Port blockers:** runs only in the Warcraft III engine (no mobile version, not licensed out; Blizzard art can't be redistributed); all heroes and likely all music are copyrighted by third parties; code is scrambled and owned by the original modders.
- **Feasible path:** copyright covers expression (characters, art, music, names, code), not mechanics. Keep team arena fights, item shop, kill-based victory and mid-fight transformations; change to original characters/art/music, 5–8 min matches, 3v3, touch controls, bots and matchmaking.
- **Suggested tools and effort:** Unity or Godot plus Photon or Nakama; offline prototype with 2–3 heroes in weeks, polished online release in many months for a small team, art the biggest cost.

## Topics
- [Fight Of Characters](../topics/fight-of-characters.md)
- [Warcraft III map format](../topics/warcraft-iii-map-format.md)
- [Hero transformations](../topics/hero-transformations.md)
- [Hero arena genre](../topics/hero-arena-genre.md)
- [Copyright vs game mechanics](../topics/copyright-vs-game-mechanics.md)

## Open questions
- Which mechanics define the game's appeal and should be prototyped first?
- What setting and art style would make an original roster distinctive?
- Casual short sessions, or competitive ranked play?
