---
type: topic
category: Game design
sources: [2026-11-08-fight-of-characters-mobile-feasibility, 2026-11-08-sketchfab-assets-and-local-multiplayer, 2026-11-08-decisions-meter-and-godot, 2026-11-08-decisions-charge-rule-and-spree, 2026-11-08-decision-transformed-bounty, 2026-11-08-decision-90-percent-resolution-and-touch-joystick, 2026-11-08-game-build-plan-and-phase-1, 2026-11-08-ui-polish-and-phase-2, 2026-11-08-phase-3-item-shop]
updated: 2026-11-08
---
# Hero arena genre

Team games where each player controls one hero, buys items and fights the other team until a win condition such as a kill count is met. Fight Of Characters is an example; adapting the genre for phones means shorter matches, smaller teams and touch controls, and an offline version can run over local Wi-Fi without servers.

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

- **Implemented in the prototype (2026-11-08):** a floating touch joystick for the left thumb — it appears where the thumb lands in the lower-left area, with analog strength and a 15% deadzone — verified on the owner's phone. Auto-attack already handles targeting; skill buttons beyond TRANSFORM are still to come. The layout fills wide (20:9) phone screens ([src](../sources/2026-11-08-decision-90-percent-resolution-and-touch-joystick.md)).
- Much of the original's feel comes from Warcraft III's built-in systems (terrain, pathfinding, right-click unit control); a mobile version must build these itself ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- Suggested tools: Unity or Godot, with a multiplayer service such as Photon or Nakama ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- Rough effort: an offline prototype with 2–3 heroes in weeks; a polished online release in many months for a small team, with art usually the biggest cost ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).

## Modes
The planned game has two modes, reached from the main menu ([src](../sources/2026-11-08-game-build-plan-and-phase-1.md)):
- **Single Player (built, Phase 2):** 3v3 on an original arena — two bases with healing fountains, a central lane, pillars for cover, neutral camps; first to 15 kills or the leader after 8:00 ([src](../sources/2026-11-08-ui-polish-and-phase-2.md)).
  - **Adaptive AI:** bots use the player's controls; one skill value changes only their decisions (reaction 0.7 → 0.15 s, retreating, focus fire, accuracy 30 → 95%, form timing, dash finishing). Enemy skill rises 0.1 per kill the player's team leads (0.15–0.95); allies stay at 0.55; stats never change ([src](../sources/2026-11-08-ui-polish-and-phase-2.md)).
  - Killing a hero pays the killer its bounty, so the transformed-hero bounty now matters in play ([src](../sources/2026-11-08-ui-polish-and-phase-2.md)).
- **Play with Friends:** host/join over local Wi-Fi with Godot's built-in multiplayer (Phase 4).
- Item shop with categories follows in Phase 3; heroes 2–3, icons and audio in Phase 5.

## Itemization
Built in Phase 3 ([src](../sources/2026-11-08-phase-3-item-shop.md)):
- **Fountain shop**, 6 slots, sell for half; the match keeps running while shopping.
- **Five categories:** Weapons, Armor, Mobility, **Relics** (meter charge, form duration, cooldowns — items built around the transformation), Consumables (tapped from the HUD).
- 13 original items, 100–900 gold; bots buy a fixed build at their fountain.

## Economy
Decided for FZFoC Mobile: a **kill-spree economy** that rewards aggression, with no comeback mechanic ([src](../sources/2026-11-08-decisions-charge-rule-and-spree.md)):
- 2 gold per second passive income.
- Kill gold 100, plus 50% per spree step (100, 150, 200…).
- A spree builds when the next kill lands within 15 s; each step adds +2 gold per second while it lasts (cap ×10).
- Dying or missing the window ends the spree.

- **Hero bounty:** a hero is worth 300 gold to its killer, ×1.75 while transformed — risk/reward for the transformed player, not a comeback lever ([src](../sources/2026-11-08-decision-transformed-bounty.md)). See [Hero transformations](hero-transformations.md#decisions).

Without a comeback mechanic, a team that gets ahead stays ahead, so whether this snowballs too hard is an open question *(inference)*.

## Local multiplayer
For an offline project played with friends, online matchmaking and servers are unnecessary ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)):
- **Godot:** built-in high-level multiplayer (ENet) works over local Wi-Fi; one phone hosts and the others join.
- **Unity:** Netcode for GameObjects with Unity Transport supports direct local connections.
- Devices find each other with a UDP broadcast on the local network; no Photon, Nakama, accounts or monthly costs.

This replaces the online matchmaking and Photon/Nakama suggestions above only for the offline scenario; a public release would still need them *(inference)*.

**Decided 2026-11-08: Godot** (4.7.2) for the prototype, using its built-in ENet multiplayer for local play ([src](../sources/2026-11-08-decisions-meter-and-godot.md)).

## Open questions
- ~~Godot or Unity?~~ Decided: Godot ([src](../sources/2026-11-08-decisions-meter-and-godot.md))
- Casual short sessions or competitive ranked play? ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md))
- Which mechanics to prototype first? ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md))

## Related
- [Fight Of Characters](fight-of-characters.md)
- [Hero transformations](hero-transformations.md)
- [Copyright vs game mechanics](copyright-vs-game-mechanics.md)
- [Assets and licensing](assets-and-licensing.md) — sourcing models and arenas for the game
