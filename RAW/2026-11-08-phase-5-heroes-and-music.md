---
title: Phase 5 — heroes Ryn and Barrow, original music
date: 2026-11-08
type: design + implementation
decided-by: owner asked to continue to Phase 5 (heroes 2–3, icons, audio); designs by the librarian, completing the speed / bruiser / giant archetype set with original characters
---

# Phase 5 — heroes Ryn and Barrow, original music

## Ryn, the Gale Dancer (Speed)
- Original hooded duelist with twin blades; wind-cyan glow on the hood ribbon and shoulder ribbons (top-visible).
- Stats: 820 HP, 4.5 HP/s, move 7.0, 26 damage every 0.55 s, range 2.2.
- **Cyclone Cut** (7 s): dash 6 units, slicing every enemy within 1.4 of the path for 100.
- **Flurry** (10 s): +60% attack speed for 4 s.
- **Tempest** form: 12 s, 15% shield, ×1.2 damage, ×1.4 speed, ×1.2 size; Cyclone Cut becomes Tempest Cut (9 units, 150).

## Barrow, the Living Cairn (Giant)
- Original giant of stacked boulders with moss on the shoulders and amber runes (top-visible back rune).
- Stats: 1,450 HP, 6 HP/s, move 5.0, 58 damage every 1.3 s, range 2.8.
- **Quake Stomp** (8 s): 90 to enemies within 3.5 and a 40% slow on heroes for 2 s.
- **Boulder Hurl** (9 s): a boulder flies 12 units at 18/s; the first enemy hit takes 160.
- **Avalanche** form: 14 s, 35% shield, ×1.3 damage, ×1.7 size; Quake Stomp radius 4.9 and 55% slow.

## Systems added
- Haste and slows on heroes; projectiles (visual-only on network clients — the host applies damage).
- Each skill tells bots when it's worth casting and whether it can be used to escape, so bots play any hero without hero-specific AI.
- Shared model base (rounded primitives, team accent, top-visible glow, form animation) and a shared shockwave effect.
- Bots mix the roster by slot; in local multiplayer each player picks a hero in the lobby and the choice reaches every device.

## Audio
- Original music generated from code: a slow minor menu theme (Am–F–C–G pads with a bell melody, 16 s loop) and a 110 BPM battle loop (war drums, rim cracks, off-beat toms, pulsing bass, low drone), on the Music bus.
- Item icons were added in Phase 3 and the app icon in the polish round, all generated from code.

## Verification
- Roster test 17/17: every hero's skills have a real effect (damage, movement or haste); forms grow the models (×1.4, ×1.2, ×1.7); roles differ (Speed faster and frailer than Bruiser, Giant tougher and slower).
- All 11 suites pass, including the two-process network test.
- Phone: hero select shows Vael, Ryn and Barrow; a mixed-hero arena holds 60 FPS at about 10 ms GPU (one dip while a screenshot was being taken on the device).
