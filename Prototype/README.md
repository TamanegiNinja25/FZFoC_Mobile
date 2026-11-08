# Prototype — transformation meter

Greybox Godot 4.7 project testing one question: **does a charge meter make transformations feel good?** One hero (blue capsule), three training dummies (red boxes) that hit back, a meter, and a timed form (gold, larger).

Design basis: [Hero transformations](../Wiki/topics/hero-transformations.md#design-direction-for-fzfoc-mobile) and the decision to use a meter ([record](../Wiki/sources/2026-11-08-decisions-meter-and-godot.md)).

## Run
Open `Prototype/project.godot` in Godot 4.7 and press **F5**.

| Control | Action |
|---|---|
| WASD / arrow keys | Move |
| Walk into range | Auto-attack the nearest dummy |
| Space or the TRANSFORM button | Transform when the meter is full |

Touch movement comes later; the TRANSFORM button is already sized for a thumb.

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

### Building for Android
Export presets live in `export_presets.cfg` (not committed: it can hold signing details). Two presets: **Android** (the playable build) and **Android Benchmark** (opens the stress test, runs the benchmark, writes `BENCH` lines to the log, quits).
```
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype --export-debug "Android" build/fzfoc-prototype.apk
adb install -r Prototype/build/fzfoc-prototype.apk
adb logcat -s godot     # benchmark results appear here
```
Requirements: Godot 4.7.2 export templates, Android SDK, a JDK path in Godot's Editor Settings, a debug keystore, and USB debugging on the phone.

## Test
```
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/smoke_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/meter_balance_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/stress_scene_test.gd
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
- Passive income: 2 gold per second.
- Kill gold: 100, plus 50% per spree step (100, 150, 200…).
- A spree builds when the next kill lands within 15 s; each step adds +2 gold per second while it lasts (cap ×10).
- Dying or missing the window ends the spree.
- **Bounty (risk/reward):** the hero is worth 300 gold to its killer, ×1.75 (525) while transformed. The HUD shows the current bounty and flags it in form. Placeholder until enemy heroes exist.

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
- `scripts/hero.gd` — movement, auto-attack, health and shield, form state
- `scripts/transform_meter.gd` — the meter
- `scripts/dummy.gd` — training dummy
- `scripts/hud.gd` — bars, status line, transform and stress-test buttons
- `scripts/toon.gd` — shared toon material
- `scripts/platform.gd` — phone vs desktop settings (shadow cascades)
- `scripts/stress_test.gd` + `scenes/stress_test.tscn` — phone stress test and benchmark mode
- `tests/smoke_test.gd` — headless check of the meter → form → revert loop
- `tests/meter_balance_test.gd` — measures fill time, idle drain and spree rewards
- `tests/stress_scene_test.gd` — checks the stress scene is built to budget (triangles, LODs, toon, toggles)
