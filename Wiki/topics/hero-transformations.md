---
type: topic
category: Game design
sources: [2026-11-08-fight-of-characters-mobile-feasibility, 2026-11-08-spec-hero-transformations, 2026-11-08-decisions-meter-and-godot, 2026-11-08-decisions-charge-rule-and-spree, 2026-11-08-decision-transformed-bounty]
updated: 2026-11-08
---
# Hero transformations

A mechanic where a hero changes into a stronger form mid-fight. In Fight Of Characters it is mostly a learned, timed, zero-mana ability on a long cooldown, and transformed heroes are worth more gold when killed. It is the leading candidate for FZFoC Mobile's core mechanic.

## In Fight Of Characters
- 11 of 25 playable heroes can change form ([src](../sources/2026-11-08-spec-hero-transformations.md)). Signature examples include a three-stage power-up chain and sword- and gear-style forms ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).
- The source analysis named mid-fight transformations as the map's standout idea ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)).

### Three models
| Model | Heroes | Trigger | Duration and end | Cost |
|---|---|---|---|---|
| **Timed form** | 10 | Cast a learned ability, gated by hero level | 10–90 s with a countdown, then automatic revert | 0 mana; 90–180 s cooldown |
| **Stage chain** | 1 (Hero A) | Same, but each ability rank points to a stronger stage (levels 15/21/27) | 60 s *(inferred default)* | 0 mana; 180 s *(inferred default)* |
| **Permanent awakening** | 1 (Hero K) | Automatic once Strength ≥ 250 and Agility ≥ 250, checked on level-up or item pickup | Permanent; once per match | Needs stat items; 2.5 s frozen and invulnerable |

All from the spec ([src](../sources/2026-11-08-spec-hero-transformations.md)).

- Timed forms can't be cancelled early *(spec's inference)*. Higher ranks give a longer duration, a bigger HP bonus, and sometimes a shorter cooldown ([src](../sources/2026-11-08-spec-hero-transformations.md)).
- Stage chain: a cast goes straight to the stage matching the current rank. Stages add +50/+100/+150 to all attributes and +3,000/+6,000/+9,000 HP ([src](../sources/2026-11-08-spec-hero-transformations.md)).
- Awakening: level, XP and all 6 items carry over; skills are replaced by awakened versions at rank 1. A bug sets the new HP from the old maximum mana ([src](../sources/2026-11-08-spec-hero-transformations.md)).

### What a form changes
| Archetype | Change |
|---|---|
| Speed | 3× attack rate (interval 1.5 → 0.5 s), move speed 250 → 400, Agility growth doubled |
| Bruiser | Attributes roughly doubled, HP 600 → 1,000, sometimes an extra skill |
| Giant | HP 2,000, mana 1,000, armour 50, **base damage 2,000**, larger model |
| Attribute stages | Same unit, flat attribute and HP bonus per stage |

Source: ([src](../sources/2026-11-08-spec-hero-transformations.md)).

### Risk and reward
- **Bounty:** killing a transformed hero pays 1,000–2,000 gold against 500 normally ([src](../sources/2026-11-08-spec-hero-transformations.md)).
- **Uptime at top rank** ranges from 33% to 89%, and reaches **100%** for three heroes (90 s form on a 90 s cooldown) — the form window disappears ([src](../sources/2026-11-08-spec-hero-transformations.md)).

### Related state: last stand
One hero (B) has HP-threshold buffs rather than a form: at ≤10% HP it berserks for 8 s, then dies after 7 s, until a level-30 skill replaces this with a controlled 15 s version on a 120 s cooldown ([src](../sources/2026-11-08-spec-hero-transformations.md)).

### How it's built
- 10 of 11 transformations use the engine's built-in morph, which keeps the same unit, so level, XP, items and shared skills carry over *(spec's inference from engine behaviour)* ([src](../sources/2026-11-08-spec-hero-transformations.md)).
- Only the awakening replaces the unit, copying level, XP, items and attributes by script ([src](../sources/2026-11-08-spec-hero-transformations.md)).
- In a custom engine, a form should be a state on one character, so nothing needs copying ([src](../sources/2026-11-08-spec-hero-transformations.md)).

## Design direction for FZFoC Mobile

### Decisions
- **2026-11-08 — Charge meter.** A full meter unlocks the form, replacing level gates and cooldowns ([src](../sources/2026-11-08-decisions-meter-and-godot.md)). The spec suggested a form every 60–90 s ([src](../sources/2026-11-08-spec-hero-transformations.md)).
- **2026-11-08 — Charge rule.** About **90 s** to fill; aggression rewarded, no comeback mechanic ([src](../sources/2026-11-08-decisions-charge-rule-and-spree.md)):

| Source | Rate | Share of a fill |
|---|---|---|
| Damage dealt | 0.019 per damage, max 3 per hit | ≈ 64% |
| Damage taken | 0.008 per damage, max 1.5 per hit | ≈ 9% |
| Kill | +2 | ≈ 10% |
| In combat | +0.2/s | ≈ 18% |
| Out of combat (after 5 s) | −0.5/s | — |

  Locked during the form. Measured in the prototype: **87.2 s** fill against one dummy ([src](../sources/2026-11-08-decisions-charge-rule-and-spree.md)).
- **2026-11-08 — Transformed-hero bounty kept as risk/reward.** The spec called a higher bounty "a comeback lever" ([src](../sources/2026-11-08-spec-hero-transformations.md)), which clashed with the owner's no-comeback rule ([src](../sources/2026-11-08-decisions-charge-rule-and-spree.md)). Resolved: the bounty stays, framed as risk/reward for the transformed player, who is stronger but a richer target. Prototype placeholder: 300 gold, ×1.75 (525) in form, shown on the HUD ([src](../sources/2026-11-08-decision-transformed-bounty.md)).

### Spec recommendations
From the spec's design notes for a mobile 3v3, 5–8 minute match ([src](../sources/2026-11-08-spec-hero-transformations.md)):

| Keep | Change | Drop |
|---|---|---|
| Timed form, then cooldown, with a visible countdown | Unlock via a short level curve (form at level 4–6 of ~12) or a charge meter (ready every 60–90 s) | Swapping the whole unit |
| Zero mana cost — timing is the only decision | Power: about +30–50% (≈ +25% HP shield, +20–30% damage or attack speed, one empowered skill) | Items only the normal form can hold |
| Higher bounty on transformed heroes (≈1.5–2× base) | Uptime 35–50%, e.g. 15/20/25 s on 70/60/50 s | Last stands that end in forced death |
| Rank decides the stage, for one signature hero | 0.5–1 s invulnerable transform; keep HP as a percentage | |
| Distinct archetypes: speed, bruiser, giant | Awakening as a visible in-match objective, not a hidden stat threshold | |

- A transformation deserves its own big sound moment — see [UI and audio direction](ui-and-audio-direction.md) *(inference)*.

## Open questions
- ~~Meter or cooldown?~~ Decided: meter ([src](../sources/2026-11-08-decisions-meter-and-godot.md)). ~~What fills it?~~ Decided: charge rule above ([src](../sources/2026-11-08-decisions-charge-rule-and-spree.md)).
- Does the 90 s fill hold up in 3v3, with more damage spread across targets? ([src](../sources/2026-11-08-decisions-charge-rule-and-spree.md))
- Every hero, or only some (the reference: 11 of 25)? ([src](../sources/2026-11-08-spec-hero-transformations.md))
- Stage progression per match or per activation? ([src](../sources/2026-11-08-spec-hero-transformations.md))
- Does a form end early on death or crowd control? ([src](../sources/2026-11-08-spec-hero-transformations.md))

## Related
- [Fight Of Characters](fight-of-characters.md)
- [Hero arena genre](hero-arena-genre.md)
- [UI and audio direction](ui-and-audio-direction.md) — a transformation as a sound moment
- [Copyright vs game mechanics](copyright-vs-game-mechanics.md) — the mechanic is free to reuse; the reference's characters aren't
