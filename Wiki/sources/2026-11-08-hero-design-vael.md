---
type: source
raw: ../../RAW/2026-11-08-hero-design-vael.md
added: 2026-11-08
why: The owner asked for the first original hero with its transformation.
---
# Hero design — Vael, the Kiln Knight

FZFoC Mobile's first original hero: an iron bruiser whose armour is a living kiln. Kit: hammer auto-attack, Bellows Slam (area hit), Ember Dash; transformation Kindled (grow, scorch, flare, embers) turns the slam into Eruption, whose empowerment the owner will design. Implemented in the prototype with data-driven heroes and verified on the phone.

## Key points
- **Concept:** original; iron knight with a kiln for armour; hammer and shield; bruiser; dark iron with ember glow.
- **Kit:** auto-attack 40 per 0.8 s (range 2.5); Bellows Slam 120 damage within 3.0, 6 s cooldown; Ember Dash 5 units in 0.18 s, 8 s cooldown.
- **Kindled:** meter-triggered, 15 s, 0.75 s invulnerable, 25% shield, ×1.25 damage, ×1.3 speed, ×1.4 size; armour scorches, glow ×4, embers; slam → Eruption (empowerment pending); bounty ×1.75.
- **Base stats** equal the tuned prototype hero, preserving the ~90 s meter fill.
- **Prototype:** data-driven hero definitions; shared skill cooldowns; skill damage uses the auto-attack path; HUD skill arc; greybox primitive model; 13/14 kit checks pass.
- **Phone finding:** silhouette reads, but the chest glow faces away from the top-down camera — put glow on top-facing surfaces.

## Topics
- [Roster](../topics/roster.md)
- [Hero transformations](../topics/hero-transformations.md)
- [Art direction](../topics/art-direction.md)

## Open questions
- How is Eruption empowered (radius, damage, extra effect)?
- Where should Vael's glow sit on the final model so the camera sees it?
- Vael's voice lines and transformation sound.
