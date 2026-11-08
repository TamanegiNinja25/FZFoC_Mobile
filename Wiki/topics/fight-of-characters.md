---
type: topic
category: Warcraft III modding
sources: [2026-11-08-fight-of-characters-mobile-feasibility, 2026-11-08-ui-and-audio-direction, 2026-11-08-spec-hero-transformations, 2026-11-08-phase-6-map-systems]
updated: 2026-11-08
---
# Fight Of Characters

A Korean-made, 4v4 anime crossover hero arena map for Warcraft III: The Frozen Throne. Version 7.7b E is an English edit; its heroes are copyrighted anime characters, so it cannot be published outside the modding scene.

## Identity
- Full name "Fight Of Characters 7.7b E", described as "English version — Work In Progress", edited by AF_FOC ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- Originally made by Korean modders credited as DlakWkd / dlakwwkd and dhdnthdhdghkdk, with community links to w3m.co.kr and cafe.naver.com/w3umf.cafe ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- The file is 4.09 MB and holds 265 archived files and 3,020 text strings, mostly Korean ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).

## How it plays
- Two teams of four, Red Team vs Blue Team ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- A kill-tracking scoreboard with 21 kill handlers, team victory/defeat conditions, a timer and hero levelling make up the core loop ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)) — see [hero arena genre](hero-arena-genre.md).
- 11 of 25 playable heroes can transform mid-fight, mostly through a learned, timed, zero-mana form ability on a long cooldown; transformed heroes pay out more kill gold ([src](../sources/2026-11-08-spec-hero-transformations.md)) — see [hero transformations](hero-transformations.md).

## Content
| Part | Count |
|---|---|
| Playable heroes | 25, of which 11 can transform — see [Conflicts](#conflicts) |
| Custom units | 160 (plus 91 modified stock units) |
| Custom abilities | 246 (plus 56 modified stock abilities) |
| Custom items | 59 |
| Imported assets | 189: 48 models, 80 icons, 60 MP3s, 1 WAV |

All figures from the source ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)). The 60 MP3s are short ability clips, not music — see [Conflicts](#conflicts).

- Heroes come from One Piece, Naruto, Bleach, Dragon Ball, Hellsing, InuYasha, Yu Yu Hakusho, Fate and Tsukihime; one item is a Pokémon "Monster Ball" that captures and summons creatures ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- Abilities are named after the shows' signature moves, with damage in the thousands (e.g. 1,800–2,100 per hit) ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- The game leans on spectacle: 175 scripted special effects, 53 animation calls and 120 script-spawned units ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).

## Systems
Read from the map file for the Phase 6 build ([src](../sources/2026-11-08-phase-6-map-systems.md)):
- **Winning:** the scoreboard reads "100 Kills to Win" and the script ends the match at 100 team kills; killing a 100,000-HP neutral boss in a corner wins outright.
- **Hero pick:** 24 heroes in four taverns grouped by source series; each player steers a wisp into a hero's circle, and each hero can be picked once.
- **Progression:** level cap 50; +3 primary and +2 other attributes per level; 10 HP and 0.1 HP/s per strength, 2 damage per primary point, 0.5 armour per agility; creep XP falls to 80 / 70 / 60 / 50% with hero level and never to zero.
- **Skills:** 4–5 per hero, mostly 5 ranks, all free of mana; ranks unlock at set levels with a 5-level skip; most damage scales with attributes.
- **Duel:** every 290–310 s the world freezes, one random hero per team fights in an arena, and the winner earns the loser's level × 200 gold.
- **Creep waves:** 12 camps; 42 creeps every 30 s, 68 every 60 s, and 49 every 90 s once the previous 90 s wave is dead.
- **Bosses:** two chains (9 and 7 stages, 500 → 12,500 HP); the next boss appears 10 s after a kill.
- **Items:** a stat shop (tomes 200–600, +100 all stats 19,000), exclusive items at 10,000 that only their hero keeps, 7 recipes at a combining circle, a 75% sell rate, and a 500-gold hero bounty.

## Protection and safety
The map is deliberately obscured against editing, and its script showed no harmful behaviour — details in [Warcraft III map format](warcraft-iii-map-format.md#protection).

## Mobile potential
A direct port is not feasible, but an original game using its mechanics is ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)). Why: [copyright vs game mechanics](copyright-vs-game-mechanics.md); how: [hero arena genre](hero-arena-genre.md#adapting-for-mobile).

## Sound
Each of 45 abilities plays its own short cast clip; hero voices, music and ambience are Warcraft III stock audio ([src](../sources/2026-11-08-ui-and-audio-direction.md)). Details in [UI and audio direction](ui-and-audio-direction.md#audio-patterns).

## Conflicts
- **What the 60 imported MP3s are.** The feasibility analysis described them as "60 MP3 music tracks" ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)). The later sound-event analysis measured them as 0.2–6.1 s clips (median 0.8 s) played as ability shouts and stings ([src](../sources/2026-11-08-ui-and-audio-direction.md)). The later source is a direct measurement, so this wiki treats them as **short clips**. The first source's other figures are unaffected.
- **How many heroes.** The feasibility analysis counted "36 hero forms" ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)), using hero-style unit IDs as a heuristic. The transformation spec counts **25 playable heroes** from the script's hero-pick list, 11 of which have alternate forms ([src](../sources/2026-11-08-spec-hero-transformations.md)). The two count different things, and the spec's method is direct, so this wiki uses **25 playable heroes**. The total number of form units isn't settled by either source.

## Related
- [UI and audio direction](ui-and-audio-direction.md)
- [Warcraft III map format](warcraft-iii-map-format.md)
- [Hero transformations](hero-transformations.md)
- [Hero arena genre](hero-arena-genre.md)
- [Copyright vs game mechanics](copyright-vs-game-mechanics.md)
