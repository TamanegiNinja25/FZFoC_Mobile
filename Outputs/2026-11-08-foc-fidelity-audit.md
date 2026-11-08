---
type: output
date: 2026-11-08
question: Does FZFoC follow Fight Of Characters 7.7b E's game mode strictly — mechanics, gameplay, items, item categories, skills, skill effects, character selection and categories, game flow and events?
method: map re-read (MPQ files byte-identical to the earlier extraction), parse of object data (units, items, abilities) and the 267-trigger script, plus a 500-match simulation of the map's rules
---
# Fidelity audit — FZFoC vs Fight Of Characters 7.7b E

**Short answer: no, the game does not follow the map strictly.** It keeps the genre skeleton: team hero arena, kill race, a shop at base, transformations that raise your bounty, and respawning creep camps. Almost every specific system differs. Some differences are deliberate, approved decisions: original heroes, a charge meter, 3v3, short matches. The rest are systems the map has and FZFoC never built: levels and attributes, duels, creep waves, boss ladders, recipes, hero-exclusive items, a stat shop and unique picks.

**Close matches:** transformed heroes are worth more bounty; skills cost no mana and run on cooldowns; skills are custom-scripted. **Partial:** team arena, scoreboard, creep camps, kill gold, inventory, effect variety. **Missing entirely:** levels and attributes, duels, creep waves, private creep rooms, boss ladders, the win boss, recipes, hero-exclusive items, stat shop, unique picks.

## 1. Teams, win condition, match length

| | Fight Of Characters | FZFoC | Match? |
|---|---|---|---|
| Teams | 4v4, Red vs Blue (players 1–4 vs 5–8) | 3v3, you + 2 bots vs 3 bots, or friends | Partial (deliberate: mobile) |
| Win | **100 team kills**, shown on the scoreboard as "100 Kills to Win" and enforced in the script | 15 kills, or the leader after 8:00 | No (deliberate: mobile) |
| Alternative win | Kill **Super Buu**, a 100,000-HP neutral boss in the south-west corner, and your team wins instantly | — | Missing |
| Time limit | None | 8:00 | No |
| Scoreboard | 3×12 board: player, kills, deaths per player and per team | Team score and kill feed | Partial |
| Leavers | The leaver's allies get gold scaled by the leaver's hero level: 2,000 (level 6–15), 6,000 (16–30), 18,000 (31+). The board marks them "Leaver" | A friend who leaves is replaced by a bot | Partial |

**Simulated match length** (500 runs per scenario, rules from the script; the kill rate is assumed):

| Kill rate (both teams) | Median length | Duels per match | Time paused for duels |
|---|---|---|---|
| 4 per minute | 54 min | 9 | 6.2 min |
| 8 per minute | 27 min | 4 | 2.9 min |
| 12 per minute | 18 min | 3 | 2.0 min |

The map is a 20–50 minute game, and FZFoC is capped at 8. That cap was the mobile adaptation from the feasibility analysis.

## 2. Character selection and categories

| | Fight Of Characters | FZFoC | Match? |
|---|---|---|---|
| How you pick | Each player steers a **wisp** into a hero's circle. That hero spawns for them and leaves the pool, so **each hero can be picked once**. Taverns also sell heroes | Menu screen with category tabs; duplicate heroes allowed | No |
| Categories | **By source anime**, one tavern each: Bleach (4), One Piece (6), Naruto (7), others (7: Hellsing, InuYasha, Dragon Ball, Yu Yu Hakusho, Fate, Tsukihime) | **By role**: Bruiser, Speed, Giant | No |
| Roster | 24 tavern heroes, all with 600 base HP, 250 move speed, 1.5 s attack, 300 mana; primary attribute STR (12) or AGI (12) | 3 heroes with distinct stats | No (3 of 24) |

## 3. Hero progression (missing)

The map is a levelling RPG: heroes reach **level 50**, gaining XP from creeps, bosses and kills (XP factors 80/70/60/50%). Attributes drive stats: each STR point gives 10 HP and 2 attack damage, and each AGI point gives armour and move speed. Skills are learned and ranked up with skill points; most have 5 ranks, some 3, 1 or 10. One hero transforms when he reaches **250 STR and 250 AGI**.

FZFoC has no levels, XP, attributes or skill ranks. Heroes are at full power from the start, and only items change their stats.

## 4. Skills and skill effects

| | Fight Of Characters | FZFoC | Match? |
|---|---|---|---|
| Skills per hero | 4–5 learned (110 in total) plus innate skills (13, mostly short-range blinks with a 0–2 s cooldown) | 2 skills plus a transformation | No |
| Cost | **Zero mana** on every skill; cooldown only (median 30 s, up to 180 s) | Cooldown only (7–10 s) | Partial: same principle, very different cooldowns |
| Scripting | 102 of 123 skills run custom trigger code | All custom code | Match in principle |
| Damage scale | Stated damage 25–8,000 (median 300) against 600 base HP plus stat growth | 90–160 against 820–1,450 HP | No (different scale) |
| Effect mix (tooltip keywords) | Stuns 25 (mostly 2–3 s, up to 10), summons 11, damage over time 10, transformations or releases 7, stat bonuses 7, blinks 7, channelled casts 5, slows 4, knockbacks 3, roots 3, heals 3 | Area hits, dashes, attack-speed buff, slows, a projectile | Partial: no stuns, summons, roots, DoTs, channels or innate blinks |
| Transformation trigger | A learned skill: timed, zero mana, long cooldown. Plus special cases: auto-transform at 10% HP (and you die when it ends), and a stat-threshold transform | **Charge meter** filled by fighting | No (deliberate, approved decision) |
| Transformed bounty | Higher kill gold while transformed | ×1.75 bounty while transformed | Match |

## 5. Items and item categories

| | Fight Of Characters | FZFoC | Match? |
|---|---|---|---|
| Item count | 59 | 13 | No |
| Shops (= categories) | **Stat shop** (7): +2/+5 STR and AGI tomes, XP tomes, +100 all stats for 19,000. **Item shop** (10): boots, belts, shield, axe, health and mana stones, Third Eye, and more. **Exclusive-item shops ×2** (22): hero-signature items at 10,000 each, with a pickup message per item. **Item & exclusive shop** (8): a **storage unit** with 6 extra slots, a capture ball (catch a creep and summon it later), summoning tome, throwing dagger, cloak, and more. A **potion shop** stocks nothing | One fountain shop with 5 tabs: Weapons, Armor, Mobility, Relics, Consumables | No |
| Recipes | **7 combine recipes**: walk the ingredients into the combining circle to get an artifact (e.g. belt + boots + voodoo → medal; shield + axe → emperor's sword) | None | Missing |
| Price scale | 10–19,000 gold; signature items 10,000 | 100–900 gold | No |
| Inventory | 6 slots plus a buyable storage unit | 6 slots, sell for half | Partial |
| Sell rate | 75% | 50% | No |

## 6. Economy

| | Fight Of Characters | FZFoC | Match? |
|---|---|---|---|
| Hero kill | 500 gold flat (raised while transformed) | 100 + 50% per spree step; bounty 300 (525 transformed) | Partial |
| Passive income | Not in the script; gold comes from kills, creeps, bosses and duels | 2 gold/s plus spree income | No |
| Duel reward | Loser's level × 200 to the winner | — | Missing |
| Creep gold and XP | 12 camps of waves, plus private creep rooms | 2 sentinel camps | Partial |

Simulated kill gold to 100 kills is about 95,000 per match, plus 8,000–58,000 from duels depending on length.

## 7. Game flow and events

| Event | Fight Of Characters | FZFoC |
|---|---|---|
| Start | Scoreboard and duel timer at 1 s; wisps pick heroes | Hero select menu, then the match |
| **Duel** | Every 290–310 s: everyone freezes and becomes invulnerable, dead heroes revive, and the camera shakes and pans to the arena. **One random hero per team** is teleported in at full HP and mana, then "3, 2, 1, Fight!!". Leaving the arena teleports you back. The winner gets level × 200 gold, both heroes get their HP, mana and facing back, and play resumes | Missing |
| **Creep waves** | 12 camps; waves every 30 s (42 units), every 60 s (68 units), and every 90 s (49 units, only when the previous big wave is dead) | 2 camps, sentinels respawn every 25 s |
| **Private creep rooms** | Teleporter pads take a hero to a room where creeps spawn on entry, up to a cap ("Can't spawn anymore creeps") | Missing |
| **Boss ladders** | Two chains of neutral boss heroes (9 and 7 stages, 2,000 → 12,500 HP). The next boss appears 10 s after the last dies | Missing |
| **Win boss** | Super Buu, 100,000 HP; killing him ends the match for the killer's team | Missing |
| Respawn | Fixed 4 s, at base | 6 s |
| Chat commands | Present, but their text is unreadable in this English edit: the Korean literals in the script became underscores | — |

## What was deliberately different

These were your decisions or the legal line, not oversights:
- **Original heroes, skill names, icons, models and audio.** The map's heroes and their signature moves are copyrighted characters. Mechanics are reusable; expression is not ([copyright vs game mechanics](../Wiki/topics/copyright-vs-game-mechanics.md)).
- **Charge meter** instead of a learned transformation skill ([decision](../Wiki/sources/2026-11-08-decisions-meter-and-godot.md)).
- **3v3, short matches**, from the mobile feasibility analysis ([source](../Wiki/sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- **Role categories** in place of franchise categories, since the franchises can't be used.

## What could be adopted (mechanics only, all legally reusable)

Ordered by how much of the map's identity each adds:
1. **Duel event**: timed 1v1 with a freeze, countdown and level-scaled reward. Fits mobile well as a short break.
2. **Levels, XP and attributes** with ranked skills, and a stat shop with tomes. The map's progression backbone.
3. **Creep waves** in more camps on 30/60/90 s timers.
4. **Item recipes** at a combining circle, and hero-exclusive signature items (original ones).
5. **Boss ladder** and a **win boss** as an alternative victory.
6. **Unique hero picks** (one per match) and a "world" category per original cast, in place of franchise taverns.
7. **Zero-mana, long-cooldown skill design**: 4–5 skills per hero, stuns, summons, roots and innate blinks.
8. **Longer mode option**: a "classic" setting with 100 kills and no time limit alongside the mobile 15-kill mode.

## Notes on method
- The map file was re-read with the MPQ reader; `war3map.w3t/w3u/w3a/wts` and `war3map.j` are byte-identical to the earlier extraction.
- Skill-effect counts come from keyword matches in the Korean tooltips: approximate, not exact.
- The simulation's kill rate, duel length and levelling speed are assumptions. Everything else (timers, unit counts, rewards, the 100-kill limit) comes straight from the script.
- One trigger gives +2,000 gold to four named players who enter a hidden region: an author's backdoor, not a game rule. It was excluded.
