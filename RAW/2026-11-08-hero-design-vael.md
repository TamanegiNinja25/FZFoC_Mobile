---
title: Hero design — Vael, the Kiln Knight
date: 2026-11-08
type: design
decided-by: owner asked for the first original hero with its transformation; concept, kit and numbers proposed and implemented by the librarian in the Godot prototype
---

# Hero design — Vael, the Kiln Knight

## Concept
- **Original character**, not based on any existing franchise: an iron knight whose armour is a living kiln. Hammer in the right hand, shield in the left.
- **Archetype:** bruiser (durable melee fighter) — the easiest archetype to read and a natural fit for the existing auto-attack.
- **Visual identity:** dark iron with an ember glow; suits toon shading and the fantasy UI direction.

## Kit
| Slot | Name | Effect | Cooldown |
|---|---|---|---|
| Basic attack | Hammer | Auto-attacks the nearest enemy in 2.5 range: 40 damage every 0.8 s | — |
| Skill 1 | **Bellows Slam** | Hits every enemy within 3.0 of Vael for 120 damage; expanding shockwave ring | 6 s |
| Skill 2 | **Ember Dash** | Bursts 5 units in the stick direction (or forward) over 0.18 s | 8 s |
| Transformation | **Kindled** | Meter-triggered; see below | Meter |

Base stats equal the tuned prototype hero (1,000 HP, 5 HP/s regeneration, move speed 6), so the measured ~90 s meter fill still holds.

## Transformation: Kindled
- Triggered by a full charge meter.
- Lasts 15 s; 0.75 s invulnerable transition; shield 25% of max HP; all damage ×1.25; move speed ×1.3.
- **Visual:** the model grows to 1.4× with a springy overshoot, the armour darkens to scorched iron, the visor and kiln door flare (emission ×4), and embers stream from the body.
- **Empowered skill:** Bellows Slam becomes **Eruption**. Its exact empowerment (radius, damage or extra effect) is left for the owner to design; a test requires Eruption to be stronger than Bellows Slam.
- Bounty while Kindled: ×1.75 (risk/reward).

## Prototype implementation
- Heroes are now data-driven: a hero definition holds identity, stats, form values, model and skills, so further heroes slot in without changing game logic.
- Skills share a cooldown system; skill damage goes through the same path as auto-attacks (form multiplier, meter charge, kill rewards).
- HUD: hero name; skill buttons in an arc around TRANSFORM for the right thumb, with cooldown countdowns; form name shown during the form. Keyboard: Q and E.
- Greybox model from primitives (helm, visor, torso, pauldrons, hammer, shield, kiln door) using the toon material; it fixes the silhouette for the future 30–50k-triangle sculpt.
- Test: 13 of 14 kit checks pass; the remaining check is Eruption's empowerment, pending.

## Phone check (Infinix NOTE 30)
- The silhouette reads at the game camera: pauldrons, helm and hammer are recognisable; Vael turns to face his target.
- **Finding:** the glowing kiln door sits on the chest, facing away from the top-down camera, so the signature glow is mostly hidden. Glow should live on surfaces the camera sees — shoulders, back vents, helm crest.
