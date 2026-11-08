---
type: topic
category: Warcraft III modding
sources: [2026-11-08-fight-of-characters-mobile-feasibility, 2026-11-08-ui-and-audio-direction]
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
- Heroes can transform mid-fight; each form is a separate hero unit ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)) — see [hero transformations](hero-transformations.md).

## Content
| Part | Count |
|---|---|
| Hero forms | 36 |
| Custom units | 160 (plus 91 modified stock units) |
| Custom abilities | 246 (plus 56 modified stock abilities) |
| Custom items | 59 |
| Imported assets | 189: 48 models, 80 icons, 60 MP3s, 1 WAV |

All figures from the source ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)). The 60 MP3s are short ability clips, not music — see [Conflicts](#conflicts).

- Heroes come from One Piece, Naruto, Bleach, Dragon Ball, Hellsing, InuYasha, Yu Yu Hakusho, Fate and Tsukihime; one item is a Pokémon "Monster Ball" that captures and summons creatures ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- Abilities are named after the shows' signature moves, with damage in the thousands (e.g. 1,800–2,100 per hit) ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- The game leans on spectacle: 175 scripted special effects, 53 animation calls and 120 script-spawned units ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).

## Protection and safety
The map is deliberately obscured against editing, and its script showed no harmful behaviour — details in [Warcraft III map format](warcraft-iii-map-format.md#protection).

## Mobile potential
A direct port is not feasible, but an original game using its mechanics is ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)). Why: [copyright vs game mechanics](copyright-vs-game-mechanics.md); how: [hero arena genre](hero-arena-genre.md#adapting-for-mobile).

## Sound
Each of 45 abilities plays its own short cast clip; hero voices, music and ambience are Warcraft III stock audio ([src](../sources/2026-11-08-ui-and-audio-direction.md)). Details in [UI and audio direction](ui-and-audio-direction.md#audio-patterns).

## Conflicts
- **What the 60 imported MP3s are.** The feasibility analysis described them as "60 MP3 music tracks" ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)). The later sound-event analysis measured them as 0.2–6.1 s clips (median 0.8 s) played as ability shouts and stings ([src](../sources/2026-11-08-ui-and-audio-direction.md)). The later source is a direct measurement, so this wiki treats them as **short clips**. The first source's other figures are unaffected.

## Related
- [UI and audio direction](ui-and-audio-direction.md)
- [Warcraft III map format](warcraft-iii-map-format.md)
- [Hero transformations](hero-transformations.md)
- [Hero arena genre](hero-arena-genre.md)
- [Copyright vs game mechanics](copyright-vs-game-mechanics.md)
