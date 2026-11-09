---
title: Phase 7 — feel, eight heroes and the original's rules (v0.7.0)
date: 2026-11-09
type: design + implementation
decided-by: owner asked for physics and animation on creeps, damage numbers for damage taken and dealt, map-like pile-ups; better hero models and skill effects (fluid movement, animation, style, skill icons, model and skill effects); more heroes and items with a balance pass "as the original game works", Classic tuned to the original's mechanics for local players; joining by IP on the same Wi-Fi; and release once done (phone connected for simulation and stress testing)
---

# Phase 7 — feel, eight heroes and the original's rules

## Creeps
- Creeps, bosses and summons are physics bodies; heroes collide with them (Warcraft III body blocking), creeps don't collide with each other.
- Animation from actual movement: walk bob and lean, attack lunge, hit punch, topple-and-sink death; stun stars and root spikes.
- Map-style pile-ups by default: camps grow to 60 (720 in all); settings offer Balanced (25 per camp) and Phone-safe (10 per camp, 80 in all).
- Four camps moved: two sat ~14 units from each base and their piles reached the fountains (found in the phone test: an idle hero at its fountain took 2,856 damage). Every camp is now at least 20 units from a base; piles spread at most 5.5 units.

## Feel
- Floating damage numbers (dealt over the target, taken over the hero), relayed to clients; damage totals in the HUD, results and snapshots.
- Procedural hero animation: run cycle, idle, smooth turning, weapon swing on a pivot, cast pose, hit flinch, death fall, respawn rise, aura in form; movement accelerates (55/s²) and decelerates faster (120/s²).
- Effect library: bursts, slash arcs, afterimages, beams, falling rocks, light columns; relayed to clients.
- 32 original skill icons in eight hero colour themes.

## Heroes and items
- Five new heroes, each after a mechanic family of the reference map: Sable (ranged archer), Morrow (summoner/caster), Kael (low-health auto-transform below 10% HP, once per 90 s — the map's mechanic), Tamsin (storm caster, chain bolts), Hask (guardian: guard buff, pull, knockback).
- Configurable skill types (strike, projectile, area/zone, summon, blink, buff, chain strike) give pulls, knockbacks, guard, zones, piercing shots and life drain.
- Realms group heroes on the select screen as the map's taverns group them by series: Ember Forge, Gale Peaks, Stone Barrows, Hollow Moon; roles Bruiser, Speed, Giant, Ranged, Caster.
- Items: exclusive item per hero (8); Homeward Scroll (recall), Throwing Knives, Shadow Cloak (invisibility until attacking or casting), Capture Orb (catch a creep under half health, release it as an ally for 60 s) — after the map's recall tome, throwing dagger, cloak and capture ball. 45 items in all.

## The original's rules for Classic
- Classic is 4v4 (Mobile stays 3v3); every hero is picked once; duplicate player picks get the first free hero; bots take heroes no player chose.
- Leaver rule from the map: allies of a player who leaves get 2,000 (level 6–15), 6,000 (16–30) or 18,000 gold (31+); then a bot takes over.
- Up to 8 players (host + 7).

## Balance
- Balance simulation: batches of all-bot Mobile matches rotating heroes; per-hero win rate, kills, deaths, damage per minute.
- Round 1 (8 matches): ranged and casters 20–25%, Barrow 83%. Round 2 after buffs and ranged kiting: originals still ahead. Round 3 (16 matches): Ryn 62, Hask 58, Barrow 55, Vael 42, Morrow 40, Kael 40, Tamsin 33, Sable 18 (%). Sable then got a final buff (range 7.5, damage 46, Volley 95, Sunpiercer 420).

## Joining by IP
- Host shows its address in large text; joiners see their own address, get their network prefix pre-filled, the last host and name are remembered, addresses are validated, a join that nobody answers fails clearly after 8 s.

## Phone (Infinix NOTE 30)
- First Classic stress run: 33–38 FPS with ~420 creeps (GPU 16–19 ms, 820 draws). Fixes: spatial grid for unit searches, running counts, sleeping camps, on-screen-only creep animation, no creep shadows, one draw and low-poly meshes per creep, cached effect resources, CPU particles, off-screen effects skipped, waves spawned 12 per tick.
- Final: a 4v4 Classic match with 570 creeps runs at 46–51 FPS once Android's launch boost ends — the same as the near-empty training ground (53 FPS) on the warm test phone (CPU/GPU 55 °C after an hour of tests); 60 FPS while boosted. Frame rate no longer depends on creep count; GPU time was the same with shadows off and at 75% resolution.

## Verification
- 13 headless suites (new: lobby test; map systems test gains unit physics, pile-up default, damage totals, 4v4 and unique picks) and the two-process network test (4v4, unique picks online) pass.
