---
type: topic
category: Game design
sources: [2026-11-08-hero-design-vael, 2026-11-08-vael-eruption, 2026-11-08-spec-hero-transformations, 2026-11-08-ui-and-audio-direction, 2026-11-08-ui-polish-and-phase-2, 2026-11-08-phase-5-heroes-and-music]
updated: 2026-11-08
---
# Roster

FZFoC Mobile's original heroes, each with a kit of a basic attack, two skills and a meter-triggered transformation. The roster covers the three archetypes: Vael (Bruiser), Ryn (Speed) and Barrow (Giant).

## Heroes
| Hero | Archetype | Skills | Transformation | Status |
|---|---|---|---|---|
| **Vael, the Kiln Knight** | Bruiser (melee) | Bellows Slam, Ember Dash | Kindled — Bellows Slam becomes Eruption | Complete in the prototype |
| **Ryn, the Gale Dancer** | Speed | Cyclone Cut (dash slicing the path), Flurry (+60% attack speed) | Tempest — ×1.4 speed; Cyclone Cut becomes Tempest Cut | Complete ([src](../sources/2026-11-08-phase-5-heroes-and-music.md)) |
| **Barrow, the Living Cairn** | Giant | Quake Stomp (area hit + slow), Boulder Hurl (projectile) | Avalanche — ×1.7 size, 35% shield; wider stomp | Complete ([src](../sources/2026-11-08-phase-5-heroes-and-music.md)) |

Sources: ([src](../sources/2026-11-08-hero-design-vael.md)), ([src](../sources/2026-11-08-vael-eruption.md)).

## Vael, the Kiln Knight
An iron knight whose armour is a living kiln: hammer in the right hand, shield in the left, dark iron with an ember glow ([src](../sources/2026-11-08-hero-design-vael.md)).

| Slot | Name | Effect | Cooldown |
|---|---|---|---|
| Basic attack | Hammer | 40 damage every 0.8 s, range 2.5 | — |
| Skill 1 | Bellows Slam | 120 damage to every enemy within 3.0 | 6 s |
| Skill 2 | Ember Dash | 5-unit burst in the stick direction over 0.18 s | 8 s |
| Transformation | Kindled | 15 s; 25% shield; ×1.25 damage; ×1.3 speed; ×1.4 size; slam → Eruption | Meter |
| Empowered skill | **Eruption** | 180 effective damage within **4.5** (radius ×1.5, damage ×1.2, then the form's ×1.25) | 6 s |

Values from the design ([src](../sources/2026-11-08-hero-design-vael.md)) and its Eruption addendum ([src](../sources/2026-11-08-vael-eruption.md)).

- **Eruption favours area:** the reference's empowered forms grew in area, and a bigger shockwave ring reads clearly on a phone. Total power is ×1.5, the top of the spec's budget. ×1.5 radius covers ×2.25 the area, so watch its crowd value in 3v3 ([src](../sources/2026-11-08-vael-eruption.md)).

- **Kindled visual:** the model grows with a springy overshoot, the armour scorches, the visor and kiln door flare, embers stream off ([src](../sources/2026-11-08-hero-design-vael.md)).
- **Why a bruiser first:** the archetype is the easiest to read and reuses the auto-attack ([src](../sources/2026-11-08-hero-design-vael.md)); the reference map's forms fell into speed, bruiser and giant archetypes ([src](../sources/2026-11-08-spec-hero-transformations.md)).
- **Base stats** equal the tuned prototype hero, so the ~90 s meter fill holds ([src](../sources/2026-11-08-hero-design-vael.md)).
- **Polished model:** rounded pauldrons, barrel hammer, round shield with a team-coloured emblem, a belt; glow added on top-visible shoulder vents and a helm crest, applying the phone finding below ([src](../sources/2026-11-08-ui-polish-and-phase-2.md)).
- **Phone check:** the silhouette reads at the game camera, but the chest glow faces away from it; glow belongs on top-facing surfaces such as shoulders, back vents and helm crest ([src](../sources/2026-11-08-hero-design-vael.md)).
- **Sound:** Vael needs cast shouts, select/order lines and a big Kindled sound moment *(inference from the audio direction)* ([src](../sources/2026-11-08-ui-and-audio-direction.md)).

## Ryn and Barrow
- **Ryn:** hooded duelist, twin blades, wind-cyan glow; 820 HP, move 7.0, 26 damage every 0.55 s. Cyclone Cut: dash 6, 100 to everything on the path (7 s). Flurry: +60% attack speed for 4 s (10 s). Tempest: 12 s, 15% shield, ×1.2 damage, ×1.4 speed; Tempest Cut reaches 9 units for 150 ([src](../sources/2026-11-08-phase-5-heroes-and-music.md)).
- **Barrow:** stacked-boulder giant, moss and amber runes; 1,450 HP, move 5.0, 58 damage every 1.3 s. Quake Stomp: 90 within 3.5 and a 40% slow on heroes for 2 s (8 s). Boulder Hurl: projectile, first enemy hit takes 160 (9 s). Avalanche: 14 s, 35% shield, ×1.3 damage, ×1.7 size; stomp radius 4.9, 55% slow ([src](../sources/2026-11-08-phase-5-heroes-and-music.md)).
- Both keep glow on top-facing surfaces, applying the Vael phone finding ([src](../sources/2026-11-08-phase-5-heroes-and-music.md)).

## How heroes are built
In the prototype each hero is a data definition (identity, stats, form values, model, skills); skills share one cooldown system and deal damage through the same path as auto-attacks, so form multipliers, meter charge and kill rewards apply everywhere ([src](../sources/2026-11-08-hero-design-vael.md)). Each skill also tells bots when it's worth casting, so bots play any hero without hero-specific AI ([src](../sources/2026-11-08-phase-5-heroes-and-music.md)).

## Open questions
- ~~How is Eruption empowered?~~ Radius ×1.5, damage ×1.2 ([src](../sources/2026-11-08-vael-eruption.md))
- Glow placement on Vael's final model ([src](../sources/2026-11-08-hero-design-vael.md))
- ~~Heroes 2 and 3: which archetypes?~~ Speed (Ryn) and Giant (Barrow) ([src](../sources/2026-11-08-phase-5-heroes-and-music.md))

## Related
- [Hero transformations](hero-transformations.md)
- [Art direction](art-direction.md)
- [UI and audio direction](ui-and-audio-direction.md)
- [Hero arena genre](hero-arena-genre.md)
