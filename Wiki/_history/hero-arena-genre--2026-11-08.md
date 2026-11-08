---
type: topic
category: Game design
sources: [2026-11-08-fight-of-characters-mobile-feasibility]
updated: 2026-11-08
---
# Hero arena genre

Team games where each player controls one hero, buys items and fights the other team until a win condition such as a kill count is met. Fight Of Characters is an example; adapting the genre for phones means shorter matches, smaller teams and touch controls.

## Core loop (as in Fight Of Characters)
- Teams of four fight each other (Red vs Blue) ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- Heroes level up and buy items from a shop; items include summons and capture-style tools ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- A scoreboard tracks kills, and the match ends on team victory/defeat, with a timer ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- Combat is fast, high-damage and flashy ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).

## Adapting for mobile
Changes the source recommends ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)):

| From (Warcraft III map) | To (mobile) |
|---|---|
| 4v4 teams | 3v3 |
| Long matches | 5–8 minute matches |
| RTS mouse control | Virtual joystick plus 3–4 skill buttons, auto-targeting |
| Human players only | Bots to fill slots, online matchmaking |
| — | Fair monetisation through cosmetics, not paying to win |

- Much of the original's feel comes from Warcraft III's built-in systems (terrain, pathfinding, right-click unit control); a mobile version must build these itself ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- Suggested tools: Unity or Godot, with a multiplayer service such as Photon or Nakama ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- Rough effort: an offline prototype with 2–3 heroes in weeks; a polished online release in many months for a small team, with art usually the biggest cost ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).

## Open questions
- Casual short sessions or competitive ranked play? ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md))
- Which mechanics to prototype first? ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md))

## Related
- [Fight Of Characters](fight-of-characters.md)
- [Hero transformations](hero-transformations.md)
- [Copyright vs game mechanics](copyright-vs-game-mechanics.md)
