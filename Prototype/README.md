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

## Test
```
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/smoke_test.gd
Godot_v4.7.2-stable_win64_console.exe --headless --path Prototype -s res://tests/meter_balance_test.gd
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
- `scripts/hud.gd` — bars, status line, transform button
- `tests/smoke_test.gd` — headless check of the meter → form → revert loop
- `tests/meter_balance_test.gd` — measures fill time, idle drain and spree rewards
