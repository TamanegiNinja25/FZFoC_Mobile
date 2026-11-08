---
title: Phase 6 — the reference map's systems (levels, duel, creep waves, bosses, recipes, modes)
date: 2026-11-08
type: design + implementation
decided-by: owner asked to implement the fidelity audit's six adoptions in order — duel, levels/XP/stats with ranked skills and a stat shop, and creep waves "kept the same"; recipes and exclusive items original; a boss chain and win boss; a Classic mode with 50 kills and no time limit — plus an attack button with the skills around it and a "+" above a skill to rank it up
---

# Phase 6 — the reference map's systems

## Reference map facts used (re-read from fight_of_characters 7.7b E.w3x)
- Match: 4v4; scoreboard reads "100 Kills to Win" and the script ends the match at 100 team kills; killing a 100,000-HP neutral boss in a map corner also wins.
- Heroes: 24 in four taverns grouped by source series; picked by steering a wisp into a hero's circle, each hero once. All start at 600 HP, 250 move speed, 1.5 s attack; primary strength or agility; +3 primary / +2 others per level; maximum level 50.
- Attribute constants: 10 HP and 0.1 HP/s per strength point; 2 damage per primary point; 0.5 armour and 0.5 move speed (of 250) per agility point; armour factor 0.02; creep XP reduction 80 / 70 / 60 / 50% (no 0% step).
- Skills: 4–5 learned per hero, mostly 5 ranks (some 3, 1 or 10), every one free of mana; rank requirements such as level 1 / 2 / 5 / 10 with a 5-level skip; most damage formulas scale with hero attributes.
- Duel: every 290–310 s; all units paused and invulnerable; dead heroes revived; camera shake and pan; one random hero per team teleported in at full health and mana; 3-2-1 "Fight!!"; leaving the arena teleports back; winner gets loser level × 200 gold and their saved health back.
- Creep waves at 12 camps: every 30 s (4 gnolls / 4 poachers / 4 spiders / 2 spitting spiders per camp in turn, 42 total), every 60 s (68: bandits + lord, priests + wizard, mud golems, footmen + knight), every 90 s (49: bandit lords + tauren, wizards + necromancers, rock golems, knights + druids) only when the previous 90 s group is dead. Creep HP, bounty and level are modified per type (e.g. gnoll 250 HP / 25 gold, tauren 2,500 HP / 200 gold, level 8).
- Boss chains: two; the next boss spawns 10 s after the previous dies; HP 500 → 2,000 … 12,500 (9 stages) and 500 → 3,500 … 12,500 (7 stages).
- Items: stat shop (+2 / +5 strength 250 / 600, +2 / +5 agility 200 / 500, experience tomes 150, +100 all stats 19,000); exclusive items at 10,000 that drop from any hero but their own; 7 combine recipes at a circle; pawn rate 75%; hero bounty 500.

## What was built (prototype v0.6.0)
- Levels 1–50 on Warcraft III's default curve (200 XP for level 2 … 127,400 for 50); shared kill XP within 12 units; creep XP by level × the map's reduction table; hero-kill XP 100 / 120 / 160 / 220 / 300 (+100 per level). Mobile earns ×3 XP, Classic ×1.
- Attributes per hero (Vael 30/20/20 +3/+2/+2 strength; Ryn 20/30/20 agility; Barrow 34/15/18 strength). Bonuses use the map's constants but count only points gained after level 1, so level-1 stats and the meter balance are unchanged. Intelligence (no mana in the game) adds 1% skill damage per point.
- Four skills per hero with ranks (slot rules 1 / 2 / 5 / ultimate 10, skip 5; ultimates 3 ranks); damage +35% per rank plus 1 per primary point gained. New skills: Searing Brand (stun), Forge Golem (summon), Razor Wind (bleed), Thousand Cuts (untouchable strikes), Stone Grip (root), Rockfall (channel + stun).
- HUD: ATTACK button (locks onto the nearest enemy, heroes first) with the four skills on an arc, rank pips, and a "+" badge on the top corner of each skill that can rank up.
- Duel, creep waves and boss chains as in the map; creeps get original names and looks; caps of 10 per camp and 80 alive in total for phone performance; a 120 s duel limit (not in the map) as a safety net.
- Win boss "The Undying Colossus", 100,000 HP.
- Gold moved to the map's scale (×10): items 1,000–9,000, hero bounty 500, passive income 20/s; stat shop and duel reward as in the map; exclusive items (one per hero) 10,000, refused to other heroes at purchase; 7 original recipes at two combining circles; sell rate 75%.
- Mobile (15 kills or 8:00) and Classic (50 kills, no time limit) on hero select and in the host's lobby; the choice reaches every device.
- Network: levels, ranks, attributes and duel state in snapshots; creeps, bosses and summons mirrored on clients 5×/s.

## Verification
- New map systems test: 52 checks pass (curve, attributes, ranks, tomes, exclusive, recipes, stun/root, waves 42 / cap 80 / 90 s rule, boss respawn, win boss, duel phases and reward, Classic, attack button).
- All-bot Mobile pacing test: ultimates at ~6 min, average level 17 at the end, one duel, creeps at the 80 cap.
- All 12 headless suites and the two-process network test pass (client sees Classic rules, hero levels, mirrored bosses).
- Laptop, 1×, ~80 units: about 2 ms script and 4 ms physics per frame. Phone check pending (device not connected).
