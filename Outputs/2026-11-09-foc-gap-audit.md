---
type: output
date: 2026-11-09
question: After Phases 6–8, what in Fight Of Characters 7.7b E is still missing or different in FZFoC (v0.8.2)?
method: map re-read (MPQ files byte-identical to the 2026-11-08 extraction); object data (units, items, abilities) and all 266 triggers of the script, now including the bodies of the triggers the first audit only listed; checked against the game's code
---
# Gap audit — FZFoC v0.8.2 vs Fight Of Characters 7.7b E

**Short answer:** the map's core systems are now in the game:
- levels to 50 and attributes, ranked skills;
- the duel, the creep waves on 30/60/90 s timers, the two boss ladders and the win boss;
- tomes, the +100 stat codex, recipes, exclusive items and the capture orb;
- unique picks, 4v4 Classic and the leaver gold;
- the auto-transform at 10% HP.

What's left falls into three groups:
1. **Systems never built:** private creep rooms; multi-stage transformations; the stat-threshold evolution; a live scoreboard; the storage unit; the host's duel switch; a custom recall point; skill-name callouts.
2. **Values that differ:** Classic's kill target; respawn time; passive income; the capture orb's behaviour; potion stacking.
3. **Scale:** 8 heroes against the map's 24, 32 skills against 120, 45 items against 59, and no per-skill voice or sound.

Re-reading the trigger bodies (the first audit only listed them) found four mechanics it missed:
- multi-stage forms;
- the stat-threshold evolution;
- the host's duel switch;
- the custom recall point.

## Built since the first audit

| Map system | In the game since |
|---|---|
| Levels 1–50, XP sharing, attributes (STR/AGI/INT), ranked skills | Phase 6 |
| Duel every ~300 s, freeze, 3-2-1, level × 200 reward | Phase 6 |
| Creep waves 30/60/90 s with the map's unit stats | Phase 6 |
| Boss ladders (9 and 7 stages), next boss 10 s after a kill | Phase 6 |
| Win boss: killing it ends the match | Phase 6 |
| Stat shop: tomes, XP tomes, +100 all-stats codex for 19,000 | Phase 6 |
| 7 recipes at a combining circle | Phase 6 |
| Hero kill bounty 500; sell rate 75% | Phase 6 |
| Stuns, roots, slows, knockbacks, DoTs, channels, blinks, summons | Phases 6–7 |
| Unique picks; realms in place of the map's series taverns | Phase 7 |
| 4v4 Classic; leaver gold 2,000 / 6,000 / 18,000 by level | Phase 7 |
| One exclusive item per hero; recall scroll, throwing knives, cloak, capture orb | Phase 7 |
| Auto-transform below 10% HP (Kael) | Phase 7 |
| Map-scale creep pile-ups | Phase 7 |

## Not inserted — systems

| # | Map mechanic (from the script) | FZFoC now | Effort |
|---|---|---|---|
| 1 | **Private creep rooms.** Five pairs of teleport pads take a hero into side rooms. Four rooms spawn 4 creeps each time a hero enters, up to a cap ("Can't spawn anymore creeps"). A safe place to farm XP and gold alone. | Missing | Medium: rooms off the main field, pads, entry spawns, a cap |
| 2 | **Multi-stage transformations.** Several heroes have chained form units, the longest with three stages, each stronger than the last. | One form per hero | Medium: a stage index on the form, per-stage multipliers and looks |
| 3 | **Stat-threshold evolution.** One hero, on reaching 250 STR and 250 AGI, is permanently replaced by an evolved unit. It keeps level, XP, attributes and items, and gets four new skills. | Missing | Medium: a threshold check, a new HeroDef with a second skill set |
| 4 | **Live scoreboard.** An always-visible board shows every player's kills and deaths, team totals, and "Leaver" marks. | Team score in the HUD; your own K/D only on the result screen | Small: a toggle panel on the HUD |
| 5 | **Storage unit.** A buyable item that adds 6 more item slots. | 6 slots only | Small to medium |
| 6 | **Host's duel switch.** A host-only chat command turns duels off for the match. | Duels always on | Small: a lobby/settings toggle |
| 7 | **Custom recall point.** A chat command saves where you stand; the recall item teleports you back to that spot. | Recall goes to base | Small: a "set point" button |
| 8 | **Skill-name callout.** Every hero cast shows "*Skill name* !!" floating above the caster in a random colour. | No callout | Small: one FloatText call on cast |
| 9 | **Potion stacking.** Picking up a second charged potion merges charges into one slot (up to 2). | No stacking | Small |

## Different values

| Rule | Map | FZFoC | Note |
|---|---|---|---|
| Classic kill target | **100 team kills** | 50 | Set to 50 in Phase 6. Could become 100, or a choice |
| Respawn | **4 s** | 6 s | Mobile and Classic alike |
| Passive income | **None**: gold only from kills, creeps, bosses, duels | 20 gold/s | Mobile addition; Classic could drop it |
| Capture | The captured creep stays yours: the item toggles it out and back in, and selling the item destroys it | Released once as a 60 s ally | Partial |
| Hero pick | Steer a wisp into a hero's circle (or buy at a tavern) | Menu with unique picks | Deliberate (touch screens) |

## Scale

| | Map | FZFoC | Note |
|---|---|---|---|
| Heroes | 24 picks, plus 12 extra form units | 8 | Original heroes only; each new one is design work |
| Skills | 120 (4–5 per hero plus innate blinks) | 32 (4 per hero) | Innate short blinks on a 0–2 s cooldown aren't in |
| Items | 59, one signature item per hero (22) | 45, one per hero (8) | Grows with the roster |
| Audio | 60 imported MP3s: voice lines and per-skill sounds | Shared hit/slam/dash sounds; no voices | Needs original recordings or CC0 voice packs |

## Left out on purpose

- Characters, names, icons, models and voices from the map's source series. They're copyrighted; the mechanics are not ([copyright vs game mechanics](../Wiki/topics/copyright-vs-game-mechanics.md)).
- An author's backdoor that gives +2,000 gold to four named players in a hidden region: not a game rule.
- Lumber: each player gets 1 at the start, used only for the tavern purchase that the menu replaces.
- Chat commands as typed text: unreadable in this edit (the Korean became underscores) and awkward on phones. Their effects (items 6 and 7) can be buttons.

## Suggested order

1. **Live scoreboard**, **skill-name callout**, **respawn 4 s**: small, visible, true to the map.
2. **Classic options**: 100 kills, no passive income, a duel switch.
3. **Multi-stage forms**: the biggest "feel" gap; the map's signature heroes escalate in stages.
4. **Private creep rooms** with teleport pads.
5. **Stat-threshold evolution**, **storage unit**, **persistent capture**, **custom recall point**.
6. **More heroes**, with innate blinks and per-skill sounds.

## Method notes
- `war3map.w3u/w3t/w3a/wts/w3i` and `war3map.j` hash identically to the 2026-11-08 extraction: same map, re-read.
- Trigger bodies were read by splitting the obfuscated single-line script into functions and following each trigger's action and condition.
- Game state comes from the v0.8.2 code (`Prototype/scripts`) and the Phase 6–8 records.
