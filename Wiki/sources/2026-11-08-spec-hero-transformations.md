---
type: source
raw: ../../RAW/2026-11-08-spec-hero-transformations.md
added: 2026-11-08
why: Answer how transformations work in Fight Of Characters (trigger, duration, cost, stages, carry-over) to design the game's core mechanic.
---
# Hero transformations — mechanic spec (Fight Of Characters)

A clean-room spec from static analysis of the map's object data and script, produced by the mechanics analyst. 11 of 25 playable heroes can change form: 10 with a learned, timed, zero-mana form ability on a long cooldown; 1 with a scripted, permanent, once-per-match awakening. Transformed heroes are worth more gold when killed. Heroes are labelled generically (A–K).

## Key points
- **Timed form (10 heroes):** a learned skill with a level gate; 0 mana at every rank; a countdown buff, then automatic revert; no manual cancel *(spec's inference)*. Higher ranks give a longer duration, a bigger HP bonus, and sometimes a shorter cooldown. Uses the engine's built-in morph, which keeps the same unit.
- **Multi-stage chain (Hero A):** one ability with 3 ranks, each pointing to a different stage, unlocked at levels 15/21/27. A cast goes straight to the stage matching the rank. Stages: +50/+100/+150 all attributes, +3,000/+6,000/+9,000 max HP. Duration and cooldown inferred at 60 s / 180 s (stock defaults).
- **Permanent awakening (Hero K):** script-driven. Fires on level-up or item pickup once total Strength ≥ 250 and Agility ≥ 250, which needs stat items. About 2.5 s frozen and invulnerable, then the unit is replaced. Level, XP and all 6 items carry over; base attributes are added; skills are replaced by awakened versions at rank 1. Once per match. Bug: HP is set from the old maximum mana.
- **HP-threshold states (Hero B, buffs):** an uncontrolled last stand (at ≤10% HP: set to 30%, 8 s buff, +3 × Agility per hit, death after 7 s), switched off by a level-30 skill that gives a controlled version (15 s, 120 s cooldown, +2 × Agility, no death).
- **Archetypes:** speed (B, F, I: attack interval 1.5 → 0.5 s, move 250 → 400), bruiser (G, H, J: attributes roughly doubled, HP 600 → 1,000), giant (C, D, E: HP 2,000, mana 1,000, armour 50, base damage 2,000), attribute stages (A).
- **Bounty:** 500 gold normally; 1,000 for speed, bruiser and awakened forms; 2,000 for giants. Hero A's stages stay at 500.
- **Timings:** unlocks between levels 10 and 50 on a 50-level curve; durations 10–90 s; cooldowns 90–180 s; top-rank uptime 33–89%, and 100% for H, I and J.
- **Carry-over (timed forms):** level, XP, items, shared skill ranks and buffs *(spec's inference from engine behaviour)*. Three heroes' signature items can only be picked up in normal form.
- **Design notes (mobile 3v3, 5–8 min):** keep the timed form, zero mana, higher bounty, rank-decides-stage and distinct archetypes. Change to a short level curve or a charge meter (a form every 60–90 s), +30–50% power, 35–50% uptime (e.g. 15/20/25 s on 70/60/50 s), a 0.5–1 s transform, HP kept as a percentage. Turn awakening into a visible objective. Drop unit swaps, normal-form-only items, and forced-death last stands.
- **Roster count:** 25 playable heroes (from the script's pick-area list).

## Topics
- [Hero transformations](../topics/hero-transformations.md)
- [Fight Of Characters](../topics/fight-of-characters.md#conflicts)

## Open questions
- Meter or cooldown?
- Should every hero get a form, or only some?
- Stage progression per match (skill points) or per activation (meter tiers)?
- Should a form end early on death or crowd control?
- Runtime unknowns: attribute recalculation on morph, form ending on death, cooldown start time, Hero B morph's stock bonuses.
