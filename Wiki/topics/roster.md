---
type: topic
category: Game design
sources: [2026-11-08-hero-design-vael, 2026-11-08-spec-hero-transformations, 2026-11-08-ui-and-audio-direction]
updated: 2026-11-08
---
# Roster

FZFoC Mobile's original heroes, each with a kit of a basic attack, two skills and a meter-triggered transformation. The prototype has one hero so far: Vael, the Kiln Knight.

## Heroes
| Hero | Archetype | Skills | Transformation | Status |
|---|---|---|---|---|
| **Vael, the Kiln Knight** | Bruiser (melee) | Bellows Slam, Ember Dash | Kindled — Bellows Slam becomes Eruption | In prototype; Eruption pending |

Source: ([src](../sources/2026-11-08-hero-design-vael.md)).

## Vael, the Kiln Knight
An iron knight whose armour is a living kiln: hammer in the right hand, shield in the left, dark iron with an ember glow ([src](../sources/2026-11-08-hero-design-vael.md)).

| Slot | Name | Effect | Cooldown |
|---|---|---|---|
| Basic attack | Hammer | 40 damage every 0.8 s, range 2.5 | — |
| Skill 1 | Bellows Slam | 120 damage to every enemy within 3.0 | 6 s |
| Skill 2 | Ember Dash | 5-unit burst in the stick direction over 0.18 s | 8 s |
| Transformation | Kindled | 15 s; 25% shield; ×1.25 damage; ×1.3 speed; ×1.4 size; slam → Eruption | Meter |

All values from the design ([src](../sources/2026-11-08-hero-design-vael.md)).

- **Kindled visual:** the model grows with a springy overshoot, the armour scorches, the visor and kiln door flare, embers stream off ([src](../sources/2026-11-08-hero-design-vael.md)).
- **Why a bruiser first:** the archetype is the easiest to read and reuses the auto-attack ([src](../sources/2026-11-08-hero-design-vael.md)); the reference map's forms fell into speed, bruiser and giant archetypes ([src](../sources/2026-11-08-spec-hero-transformations.md)).
- **Base stats** equal the tuned prototype hero, so the ~90 s meter fill holds ([src](../sources/2026-11-08-hero-design-vael.md)).
- **Phone check:** the silhouette reads at the game camera, but the chest glow faces away from it; glow belongs on top-facing surfaces such as shoulders, back vents and helm crest ([src](../sources/2026-11-08-hero-design-vael.md)).
- **Sound:** Vael needs cast shouts, select/order lines and a big Kindled sound moment *(inference from the audio direction)* ([src](../sources/2026-11-08-ui-and-audio-direction.md)).

## How heroes are built
In the prototype each hero is a data definition (identity, stats, form values, model, skills); skills share one cooldown system and deal damage through the same path as auto-attacks, so form multipliers, meter charge and kill rewards apply everywhere ([src](../sources/2026-11-08-hero-design-vael.md)).

## Open questions
- How is Eruption empowered? ([src](../sources/2026-11-08-hero-design-vael.md))
- Glow placement on Vael's final model ([src](../sources/2026-11-08-hero-design-vael.md))
- Heroes 2 and 3: which archetypes (speed and giant would complete the reference's set)? *(inference)*

## Related
- [Hero transformations](hero-transformations.md)
- [Art direction](art-direction.md)
- [UI and audio direction](ui-and-audio-direction.md)
- [Hero arena genre](hero-arena-genre.md)
