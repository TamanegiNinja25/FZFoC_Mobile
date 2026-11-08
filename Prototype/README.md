# Prototype — FZFoC (working title)

Greybox Godot 4.7 project testing one question: **does a charge meter make transformations feel good?** The first original hero, **Vael, the Kiln Knight**, three training dummies (red boxes) that hit back, a meter, and Vael's timed form, **Kindled**.

Design basis: [Hero transformations](../Wiki/topics/hero-transformations.md#design-direction-for-fzfoc-mobile) and the decision to use a meter ([record](../Wiki/sources/2026-11-08-decisions-meter-and-godot.md)).

## Run
Open `Prototype/project.godot` in Godot 4.7 and press **F5**. The game opens on the **main menu**.

### Menus (Phase 1)
- **Main menu:** Single Player · Play with Friends · Settings · Quit, over a dark ember-lit scene with Kindled Vael. Stone panels, gold-trimmed buttons and parchment text are an original take on the classic fantasy-RTS look (`scripts/ui/ui_theme.gd`); no assets from any existing game.
- **Single Player → Choose Your Hero:** category tabs (All / Bruiser / Speed / Giant), hero cards with planned heroes shown locked, a scrolling detail panel (role, skills, transformation), Back / Training / Start Match. **Start Match** opens the 3v3 arena; **Training** opens the dummy training ground.
- **Play with Friends:** explains local Wi-Fi play; Host / Join arrive in Phase 4.
- **Settings:** Audio (master, music, sound effects) and Video (3D resolution 75/90/100%, shadows off/2/4 cascades, 30/60 FPS cap, FPS counter; stress test from the main menu). Saved to `user://settings.cfg`; phone defaults are 90% and 2 cascades.
- **In game:** the **II** button (or Android back) pauses: Resume · Settings · Quit to Menu · Quit Game.
- **Polish:** panels slide and pop in, the title pulses, every button shrinks on press with a click sound; HUD and menus stay inside the phone's safe area; Settings has Reset to Defaults.

### 3v3 arena (Phase 2)
- **Original map** (`scripts/match/arena_match.gd`, 88 × 56): blue base (west) and red base (east) with healing fountains (90 HP/s) and a combining circle each, a stone central lane, a rune circle at the centre, symmetric pillars, 12 creep camps, two boss rings (south), the win boss's ring (north) and the duel arena off the field.
- **Teams:** you and two bot allies (blue) against three bots (red). Rings show sides (gold = you); health bars float overhead. Killing a hero pays its bounty to the killer.
- **Win:** Mobile — first team to **15 kills**, or the leader after **8:00**; Classic — first to **50 kills**, no time limit (chosen on hero select or by the host). Killing the win boss wins either way. Scoreboard (with the next duel's countdown), kill feed, and a Victory / Defeat / Draw screen with Play Again and Main Menu.
- **Adaptive AI** (`scripts/ai/bot_brain.gd`): bots use the same controls as you. One `skill` value changes only decisions — reaction time (0.7 → 0.15 s), retreating to heal, focusing the weakest enemy, skill accuracy, saving the form for fights, dashing to finish. Enemy skill = 0.5 + 0.1 per kill your team leads (0.15–0.95); allies stay at 0.55. Stats never change.
- **Phone (Infinix NOTE 30, default settings):** locked 60 FPS, GPU 10.2 ms. Godot's primitive shapes default to very high detail and get no LODs; setting their segment counts cut the arena from ~890k to ~50k triangles.

### Item shop (Phase 3)
- **Shop at your fountain** (the SHOP button glows there; the training ground lets you shop anywhere). The match keeps running while it's open.
- **Five categories, 13 original items** (`scripts/items/item_catalog.gd`):

| Category | Items |
|---|---|
| Weapons | Tempered Blade (+12 damage, 3,000) · Quickening Gauntlets (+20% attack speed, 3,500) · Forgebreaker Maul (+30 damage, +10% attack speed, 9,000) |
| Armor | Riveted Mail (+200 HP, 3,000) · Bulwark Plate (−15% damage taken, 5,000) · Emberheart Amulet (+4 HP/s, 3,500) |
| Mobility | Wayfarer's Treads (+15% move, 2,500) · Windstep Greaves (+25% move, 6,000) |
| Relics | Kindling Rune (meter +25% faster, 4,500) · Everflame Sigil (+4 s form, 6,000) · Sage's Hourglass (−20% cooldowns, 5,000) |
| Consumables | Ember Draught (heal 400 over 5 s, 1,000) · Spark Flask (+25 meter, 2,000) |
| Stats (Phase 6) | Tome of Might +2 / +5 (250 / 600) · Tome of Grace +2 / +5 (200 / 500) · Codex of Ascension, +100 to every attribute (19,000) · Minor / Greater Tome of Lore, +100 / +500 XP (150 / 450) — the reference map's stat shop and prices, used up on purchase |
| Exclusive (Phase 6) | Kilnheart Core (Vael) · Galeheart Ribbon (Ryn) · Cairnstone Heart (Barrow) — 10,000 each, only their hero can buy them |
| Artifacts (Phase 6) | 7 recipes, made at a combining circle — see Phase 6 |

- Prices are on the reference map's scale since Phase 6 (×10: a hero kill pays 500).
- **6 inventory slots**; sell for 75% (the map's rate); tap a consumable in the HUD inventory bar to use it. Stats are recomputed from the hero's definition, attributes and items, so selling removes a bonus cleanly.
- **Bots shop too**, following a fixed build (with their exclusive item and two recipes) whenever they're at their fountain, then buying tomes.
- Item icons are generated by `tools/generate_assets.py` (category-coloured tiles with original glyphs).

### Play with Friends — local Wi-Fi (Phase 4)
- **Host / Join** from the main menu (`scripts/ui/lobby_panel.gd`). The host shows its Wi-Fi address, picks **Versus** (friends alternate teams) or **Co-op** (friends together vs bots), and starts; joiners pick a game found on the network or type the host's IP. Bots fill empty slots; a friend who leaves is taken over by a bot.
- **Host-authoritative** (`scripts/net/net.gd` autoload, `scripts/net/net_match.gd`): the host runs the real match; clients send their stick 60×/s and button presses as they happen; the host sends every hero's state and the score 20×/s; clients smooth toward it. Effects (slam rings, sounds) and the kill feed are relayed; client heroes are display-only puppets.
- Ports: game 24570 (UDP/ENet), discovery 24571 (UDP broadcast). Android build declares Internet and Wi-Fi permissions. Online matches can't be paused.
- **Verified:** two-process test on one PC (`tests/run_net_test.ps1`: host 8/8, client 9/9 — discovery, join, teams, input applied on the host, snapshots, score), and a **real cross-device match**: the Infinix NOTE 30 hosted on Wi-Fi and the laptop joined by IP and moved its hero through the phone.

### Heroes 2–3 and audio (Phase 5)
| Hero | Role | Skills | Transformation |
|---|---|---|---|
| **Vael, the Kiln Knight** | Bruiser | Bellows Slam (area hit), Ember Dash | Kindled → Eruption |
| **Ryn, the Gale Dancer** | Speed — 820 HP, fast, 0.55 s attacks | **Cyclone Cut** (dash that slices everything on the path, 100), **Flurry** (+60% attack speed for 4 s) | **Tempest** (12 s, ×1.4 speed) → Tempest Cut (9 units, 150) |
| **Barrow, the Living Cairn** | Giant — 1,450 HP, slow, heavy hits | **Quake Stomp** (area hit + 40% slow on heroes), **Boulder Hurl** (projectile, first enemy hit takes 160) | **Avalanche** (14 s, ×1.7 size, 35% shield) → wider stomp, 55% slow |

- New systems: haste, slows, projectiles (visual-only on network clients); every skill tells bots when it's worth casting, so bots play any hero with no hero-specific AI.
- Bots mix the roster by slot; online, each player picks a hero in the lobby and it reaches every device.
- Models share `scripts/heroes/primitive_model.gd` (rounded parts, team accent, top-visible glow, form animation).
- **Original music** generated by `tools/generate_assets.py`: a slow minor menu theme with bells and a 110 BPM war-drum battle loop, on the Music bus.
- **Phone:** mixed-hero arena holds 60 FPS at ~10 ms GPU on the NOTE 30.

### Map systems (Phase 6)
The reference map's systems, after a fidelity audit (`Outputs/2026-11-08-foc-fidelity-audit.md`). Rules and numbers follow the map; names, looks and items are original.

- **Levels 1–50** on Warcraft III's default curve (200 XP for level 2, 127,400 for 50). Kills share XP among allied heroes within 12 units; creep XP (25–340 by creep level) is cut by the hero's level (80 / 70 / 60 / then 50%, the map's table). Hero kills give 100 / 120 / 160 / 220 / 300 XP (+100 per level after). Mobile earns XP ×3 so an 8-minute match reaches the ultimate; Classic is ×1.
- **Attributes** (`HeroDef`): strength, agility, intelligence, +3 primary / +2 others per level as in the map. Each strength point: +10 HP, +0.1 HP/s. Each primary point: +2 attack damage. Each agility point: +0.5 armour, +2% attack speed, +0.5/250 move speed. Intelligence (mana is unused) adds 1% skill damage. Only points gained after level 1 count, so every hero keeps its tuned level-1 stats.
- **Four ranked skills per hero**, learned with skill points (one per level) through a **+** badge on each skill: slot 1 from level 1, slot 2 from 2, slot 3 from 5, each rank 5 levels apart (5 ranks); the ultimate has 3 ranks at 10 / 15 / 20 — patterns taken from the map's skill data. Damage +35% per rank, plus 1 per primary point gained (the map's skills scale with attributes). Skills cost no mana, as in the map.
- **New skills** (stun, summon, bleed, untouchable strikes, root, channelled blast):

| Hero | Skill 3 | Ultimate |
|---|---|---|
| Vael | **Searing Brand** — nearest enemy within 7: 110 damage, 1.25 s stun (+0.25 s per rank) | **Forge Golem** — a molten golem fights for 25 s (900 HP, 45 damage, +40% per rank) |
| Ryn | **Razor Wind** — 70° cone: 60 damage and a 25/s bleed for 4 s | **Thousand Cuts** — untouchable for 1.6 s, 8 strikes of 70 on random enemies within 6 |
| Barrow | **Stone Grip** — root the nearest enemy within 8 for 2 s, 40/s crushing | **Rockfall** — channel 1.2 s, then 350 damage and a 1.5 s stun in radius 4, 5 units ahead |

- **Controls:** a big **ATTACK** button locks onto the nearest enemy (heroes first) and walks to it; the four skills sit on an arc around it, each showing its rank as pips; **TRANSFORM** sits outside the arc.
- **Duel** (`scripts/match/duel.gd`), kept the same as the map: every 290–310 s the world freezes and everyone is invulnerable; dead heroes revive; the camera shakes and pans to the duel arena; one random hero per team arrives at full health; "3, 2, 1, Fight!!". Leaving the arena puts you back on your mark. The winner earns the loser's level × 200 gold and gets their health back, then everyone returns to where they stood. (A 120 s limit, which the map lacks, stops a stalled duel.)
- **Creep waves** (`scripts/match/map_events.gd`), kept the same: 12 camps; every 30 s a wave of 42 (the map's gnoll / poacher / spider / spitting-spider groups per camp), every 60 s a wave of 68 (bandits, mystics, golems, deserters, knights…), and every 90 s a wave of 49 big creeps that only comes once the previous 90 s wave is dead. Creep HP, gold and levels are the map's (`scripts/units/creep_types.gd`, original names and looks). Creeps guard their camp, chase within a 9-unit leash, then go home. They pile up like the map's, capped at 10 per camp and 80 in all to hold the phone's frame rate.
- **Boss chains:** two rings in the south. Chain A has 9 bosses (500 → 12,500 HP), chain B 7 (500 → 12,500); the next appears 10 s after one falls. Bosses slam and stun around them and pay 500+ gold.
- **Win boss:** The Undying Colossus, 100,000 HP, in the north ring — whoever lands the killing blow wins the match for their team.
- **Recipes:** carry the parts into a combining circle beside either base:

| Artifact | Parts |
|---|---|
| Pyreheart Brand | Forgebreaker Maul + Kindling Rune |
| Bastion Aegis | Riveted Mail + Bulwark Plate |
| Titan's Cleaver | Riveted Mail + Forgebreaker Maul |
| Galestride Boots | Wayfarer's Treads + Quickening Gauntlets |
| Champion's Medallion | Riveted Mail + Wayfarer's Treads + Kindling Rune |
| Wellspring Stone | Emberheart Amulet + Sage's Hourglass |
| Sovereign Blade | Forgebreaker Maul + Bulwark Plate |

- **Network:** levels, XP, ranks, attributes and the duel ride in the 20×/s snapshot; creeps, bosses and summons are mirrored on clients 5×/s as packed arrays and glide between updates. The host's Mobile/Classic choice reaches every device.
- **Pacing** (`tests/pacing_test.gd`, all-bot Mobile match): ultimates at ~6 min, average level 17 at the end, one duel, creeps at the 80 cap.

### Original assets
`tools/generate_assets.py` synthesises the app icon (hammer-and-slash emblem in gold and ember, plus Android adaptive layers) and all sound effects from code — nothing taken from other games. Rerun it to rebuild `assets/`.

| Control | Action |
|---|---|
| Touch: drag in the lower-left area (floating joystick) | Move — the stick appears under your thumb |
| WASD / arrow keys | Move (desktop) |
| Walk into range | Auto-attack the nearest enemy |
| ATTACK button, or F | Lock onto the nearest enemy (heroes first) and walk to it |
| Skill buttons on the arc, or Q / E / R / T | Cast skills 1–4 (once learned) |
| **+** badge on a skill | Spend a skill point on it |
| Space or the TRANSFORM button | Transform when the meter is full |

On desktop, the mouse emulates touch, so the joystick can be tested by clicking and dragging. The game fills wide phone screens (stretch aspect "expand"), so there are no black bars on 20:9 displays.

## Vael, the Kiln Knight
An original iron knight whose armour is a living kiln; hammer and shield; bruiser. Design: [Roster](../Wiki/topics/roster.md).

| Slot | Name | Normal | Kindled |
|---|---|---|---|
| Basic attack | Hammer | 40 per 0.8 s, range 2.5 | ×1.25 damage |
| Skill 1 | Bellows Slam → **Eruption** | 120 damage within 3.0; 6 s cooldown | 180 effective damage within **4.5** (radius ×1.5, damage ×1.2 × form ×1.25) |
| Skill 2 | Ember Dash | 5 units in 0.18 s; 8 s cooldown | ×1.3 move speed between dashes |
| Form | Kindled | — | 15 s; 25% shield; ×1.4 size; scorched armour, glow ×4, embers; bounty ×1.75 |

Heroes are data-driven: `scripts/hero_def.gd` (stats, form, model, skills) with Vael in `scripts/heroes/vael.gd`, his greybox model in `scripts/heroes/vael_model.gd`, and skills in `scripts/skills/`. A new hero is a new definition; game logic doesn't change.

## Look
All materials use the shared toon material in `scripts/toon.gd`: banded light, toon highlights and a rim light (decision 2026-11-08, see [Art direction](../Wiki/topics/art-direction.md)).

## Stress test (phone performance)
Press **STRESS TEST** in the game, or open `scenes/stress_test.tscn` and press F6. It shows 6 heroes at **40,320 triangles** each (Godot generates 10 LOD levels), toon shading, particle effects and shadows, from the game camera.

On-screen toggles: LOD on/off, effects, shadows (2 / 4 cascades / off), 6/12 heroes, game/close camera, back. The top-left readout shows FPS, average and worst frame time, triangles and draw calls actually rendered, the device, GPU, and a verdict (60 FPS smooth / 30 FPS playable / too slow).

**Benchmark mode** runs eight configurations (4 vs 2 cascades, LOD off, 75% resolution, no effects) for 3 s each, prints FPS, frame times, GPU/CPU render time and triangles, and quits:
```
Godot_v4.7.2-stable_win64_console.exe --path Prototype --disable-vsync res://scenes/stress_test.tscn -- --benchmark
```

PC baseline (2026-11-08, AMD Radeon integrated graphics, ASUS Vivobook laptop — **not a phone**):

| Configuration | FPS | Avg frame | Triangles rendered |
|---|---|---|---|
| 6 heroes, game camera, LOD on | 506 | 1.98 ms | 18k |
| 6 heroes, close camera | 433 | 2.31 ms | 25k |
| 6 heroes, LOD off (worst case) | 396 | 2.52 ms | 971k |
| 12 heroes, LOD off | 326 | 3.07 ms | 1,941k |

- At the game camera, LODs cut ~240k hero triangles to ~18k rendered. A capsule simplifies easily; real sculpted models will reduce less.
- Shadows multiply geometry cost about 4× (971k rendered from 242k): Godot's default sun shadow draws 4 cascades.
- **Phones use 2 shadow cascades** (decision 2026-11-08, `scripts/platform.gd`); desktop keeps 4. Add `-- --phone` to the command line to simulate phone settings on a PC. The stress test's Shadows button cycles 2 → 4 → off.

Cascade comparison (same PC, benchmark mode):

| Configuration | 4 cascades | 2 cascades |
|---|---|---|
| 6 heroes, game camera, LOD on | 551 FPS, 18k tris | 521 FPS, 9k tris |
| 6 heroes, LOD off | 419 FPS, 971k tris | 469 FPS, 486k tris |
| 12 heroes, LOD off | — | 407 FPS, 971k tris |

2 cascades halve shadow geometry; with LOD off that's +12% FPS on this PC. At the game camera with LOD on the PC isn't geometry-bound, so the small difference is noise.
### Phone results — Infinix NOTE 30 (2026-11-08)
MediaTek MT6789, Mali-G57 MC2 (Vulkan 1.1), Android 14, 1080×2460 screen at 60 Hz. The driver only offers vsync on, so FPS caps at 60; **GPU ms** (measured by the engine) shows the real cost per frame. Budget at 60 FPS: 16.7 ms.

| Configuration | FPS | Worst frame | GPU | Triangles |
|---|---|---|---|---|
| 6 heroes, game camera, LOD on, 4 cascades | 60.1 | 16.7 ms | 13.9 ms | 18k |
| 6 heroes, game camera, LOD on, **2 cascades (phone default)** | **60.0** | **16.7 ms** | **13.7 ms** | 9k |
| 6 heroes, close camera, 2 cascades | 60.0 | 16.7 ms | 14.9 ms | 32k |
| 6 heroes, LOD off, 4 cascades | 56.6 | 28.9 ms | 16.4 ms | 971k |
| 6 heroes, LOD off, 2 cascades | 60.0 | 16.7 ms | 15.2 ms | 486k |
| 12 heroes, LOD off, 2 cascades | 52.7 | 25.7 ms | 17.8 ms | 971k |
| 6 heroes, LOD on, 2 cascades, **75% render resolution** | 60.1 | 16.7 ms | **6.2 ms** | 9k |
| 6 heroes, LOD on, 2 cascades, no particle effects | 60.0 | 16.7 ms | 13.7 ms | 8k |

- **Realistic settings hold a locked 60 FPS** with no dropped frames, but with only ~3 ms of GPU headroom.
- **The phone is pixel-bound, not triangle-bound:** 9k → 486k triangles adds only 1.5 ms; rendering 75% resolution cuts GPU time by 54%. Particles cost almost nothing.
- Results were stable across four runs (within ~0.5 FPS); phone thermal status stayed normal.

**Render resolution (decision 2026-11-08: phones render 3D at 90%, UI at full resolution).** A focused run, repeated twice to rule out clock drift (phone default scene: 6 heroes, LOD on, 2 cascades):

| 3D resolution | GPU, round 1 | GPU, round 2 |
|---|---|---|
| 100% | 13.71 ms | 13.68 ms |
| **90% (phone default)** | **7.37 ms** | **7.44 ms** |
| 75% | 6.25 ms | 6.24 ms |

90% gets most of 75%'s saving (−46% vs −54%) with a sharper image, leaving ~9 ms of the 16.7 ms frame free. Run it with `-- --benchmark --bench-res`.

A longer 10-step run showed the phone slowing mid-run (GPU and CPU times both rose, e.g. 75% read 14.7 ms instead of 6.2 ms); those later steps were discarded. Long runs need a fixed order and repeats to catch throttling.

### Building for Android
Export presets live in `export_presets.cfg` (committed — Godot 4 keeps signing credentials in `.godot/` or Editor Settings, never in this file). Two presets: **Android** (the playable build) and **Android Benchmark** (opens the stress test, runs the benchmark, writes `BENCH` lines to the log, quits).
```
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype --export-debug "Android" build/FZFoC.apk
adb install -r Prototype/build/FZFoC.apk
adb logcat -s godot     # benchmark results appear here
```
Requirements: Godot 4.7.2 export templates, Android SDK, a JDK path in Godot's Editor Settings, a debug keystore, and USB debugging on the phone.

### Releases and the update notice
- **Version:** `application/config/version` in `project.godot` (shown under the menu title) and `version/code` in the Android preset (major×10000 + minor×100 + patch, e.g. 0.5.0 → 500). Android only installs an update when the code goes up.
- **Release build:** pushing a `v*` tag runs `.github/workflows/release.yml`, which stamps both values from the tag, exports with Godot on Linux and publishes a GitHub Release with `FZFoC.apk`. `https://github.com/TamanegiNinja25/FrozenThrone_FightOfTheCharacters/releases/latest/download/FZFoC.apk` always serves the newest one.
- **Update notice** (`scripts/ui/update_checker.gd`): the main menu asks the GitHub API for the latest release (8 s timeout, silent when offline or when there are no releases). If the tag is newer than the running version, a gold **Update available** button opens the release page.
- **Signing:** updates only install over an app signed with the same key. Set the repository secret `DEBUG_KEYSTORE_BASE64` so cloud builds share one key; local builds use the machine's own debug keystore, so a phone switching between local and cloud builds needs one uninstall.

## Test
```
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/smoke_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/meter_balance_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/stress_scene_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/hero_kit_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/touch_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/menu_flow_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/arena_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/shop_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/roster_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/update_check_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/map_systems_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/pacing_test.gd
```
The balance test measures how long the meter takes to fill against one dummy. Last result: **87.2 s** (target 90 ± 15 s), 5 kills, no deaths.

## Charge rule
Aggression is rewarded and there's no comeback boost. Values are in `TransformMeter`'s "Charge rule" group.

| Source | Rate | Share of a fill |
|---|---|---|
| Damage dealt | 0.019 per damage, max 3 per hit | ≈ 64% |
| Damage taken | 0.008 per damage (under half the dealt rate), max 1.5 per hit | ≈ 9% |
| Kill | +2 | ≈ 10% |
| In combat | +0.2 per second | ≈ 18% |
| Out of combat (5 s without dealing or taking damage) | −0.5 per second | — |

The meter is locked while transformed and restarts from zero afterwards.

## Kill spree economy
Gold is on the reference map's scale since Phase 6 (×10).
- Passive income: 20 gold per second.
- **Bounty (risk/reward):** a hero is worth 500 gold to its killer (the map's bounty), ×1.75 (875) while transformed, plus 50% per spree step. The HUD shows the current bounty and flags it in form.
- Creeps and bosses pay their own bounty (creeps 10–200, bosses 500+); a training dummy pays 1,000.
- A spree builds when the next kill lands within 15 s; each step adds +20 gold per second while it lasts (cap ×10).
- Dying or missing the window ends the spree.

## Tuning
| Value | Where | Starting point | Basis |
|---|---|---|---|
| Health regeneration | `Hero.hp_regen` | 5 HP/s | Survive a 90 s fight with one dummy |
| Form duration | `Hero.form_duration` | 15 s | Spec: 15/20/25 s by rank |
| Transform invulnerability | `Hero.form_transition` | 0.75 s | Spec: 0.5–1 s |
| Shield | `Hero.form_shield_ratio` | 25% of max HP | Spec: ≈ +25% HP |
| Damage / speed in form | `Hero.form_damage_mult`, `form_speed_mult` | ×1.25 / ×1.3 | Spec: +20–30% |
| Hero damage | `Hero.attack_damage` / `attack_interval` | 40 per 0.8 s (50 DPS) | — |
| Dummy damage | `Dummy.damage` / `attack_interval` | 25 per 1.5 s (≈17 DPS) | — |

## Files
- `scripts/main.gd` — builds the arena, camera, inputs and HUD in code
- `scripts/hero.gd` — movement, auto-attack, skills, dash, health and shield, form state (driven by a HeroDef)
- `scripts/hero_def.gd` — hero definition base class
- `scripts/heroes/vael.gd`, `scripts/heroes/vael_model.gd` — Vael's definition and greybox model
- `scripts/skills/` — `skill.gd` (cooldowns), `slam_skill.gd` (Bellows Slam / Eruption), `dash_skill.gd` (Ember Dash)
- `scripts/transform_meter.gd` — the meter
- `scripts/dummy.gd` — training dummy
- `scripts/hud.gd` — bars, status line, transform and stress-test buttons
- `scripts/toon.gd` — shared toon material
- `scripts/platform.gd` — phone vs desktop settings (shadow cascades, 3D render scale)
- `scripts/touch_joystick.gd` — floating touch joystick driving the move actions
- `scripts/stress_test.gd` + `scenes/stress_test.tscn` — phone stress test and benchmark mode
- `tests/smoke_test.gd` — headless check of the meter → form → revert loop
- `tests/meter_balance_test.gd` — measures fill time, idle drain and spree rewards
- `tests/stress_scene_test.gd` — checks the stress scene is built to budget (triangles, LODs, toon, toggles)
- `scripts/ui/` — `main_menu.gd`, `hero_select.gd`, `settings_panel.gd`, `pause_menu.gd`, `ui_theme.gd`, `game_settings.gd` (autoload)
- `scripts/session.gd` (autoload) — mode and hero chosen in the menus; `scripts/heroes/roster.gd` — every hero plus planned slots by category
- `scenes/menu.tscn` — main scene
- `scripts/match/arena_match.gd` + `scenes/arena.tscn` — 3v3 match; `scripts/ai/bot_brain.gd` — adaptive bot; `scripts/controls.gd` — keyboard bindings
- `scripts/ui/sfx.gd` (autoload) — sound effects and button animation
- `scripts/items/` — `item_def.gd`, `item_catalog.gd`; `scripts/ui/shop_panel.gd` — shop screen
- `scripts/net/` — `net.gd` (autoload: host/join/discovery), `net_match.gd` (snapshots, input, relays); `scripts/ui/lobby_panel.gd`
- `tests/net_test.gd` + `tests/run_net_test.ps1` — two-process multiplayer test on 127.0.0.1 (`-- --join=IP` joins a real host)
- `scripts/heroes/` — `ryn.gd`, `barrow.gd`, their models, `primitive_model.gd`, `roster.gd`; `scripts/skills/` — Cyclone Cut, Flurry, Quake Stomp, Boulder Hurl; `scripts/projectile.gd`, `scripts/effects.gd`
- `tests/roster_test.gd` — every hero: each skill has a real effect, form grows the model, roles differ (17 checks)
- `tests/shop_test.gd` — categories, buying rules, stat effects, selling, consumables, bots shopping (17 checks)
- `tests/arena_test.gd` — 3v3 spawn, bots score on their own, fountain heals, adaptive skill, victory screen (9 checks)
- `tests/menu_flow_test.gd` — menu order, hero select by category, start match, pause/resume, settings persistence (10 checks)
- `tests/hero_kit_test.gd` — Vael's kit: slam range and cooldown, dash distance, Kindled growth, Eruption reach and damage (15 checks)
- `tests/touch_test.gd` — simulated finger: zone, drag direction, hero moves and stops; render scale
- `scripts/units/` — `creep.gd` (creeps, bosses, win boss, summons; network puppets), `creep_types.gd` (the map's creep stats, boss chains)
- `scripts/match/` — `map_events.gd` (creep waves, boss chains, win boss), `duel.gd` (the duel)
- `scripts/skills/` — Searing Brand, Forge Golem, Razor Wind, Thousand Cuts, Stone Grip, Rockfall
- `tests/map_systems_test.gd` — levels, XP, attributes, ranks, tomes, exclusive items, recipes, stun/root, waves, boss chains, win boss, duel, Classic, attack button (52 checks)
- `tests/pacing_test.gd` — a full all-bot Mobile match at 8× speed: levels, ultimates, duel, creep cap
