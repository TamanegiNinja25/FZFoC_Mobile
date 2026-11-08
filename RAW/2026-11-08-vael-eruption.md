---
title: Vael's Eruption — empowered skill design
date: 2026-11-08
type: design
decided-by: owner asked for Eruption to be implemented in the style of the game's skills; values set by the librarian from the transformation spec's limits
---

# Vael's Eruption — empowered skill design

Addendum to the Vael hero design (2026-11-08).

## Design
- **Eruption** is Bellows Slam while Vael is Kindled: **a wider blast with a modest damage increase**.
- **Radius ×1.5:** 3.0 → 4.5. It catches groups and enemies trying to escape, and the shockwave ring draws visibly larger.
- **Damage ×1.2 before the form multiplier:** 120 → 144. With Kindled's ×1.25 on all damage, the effective hit is **180** (×1.5 overall), the top of the spec's +30–50% form power budget.
- **Why area over damage:** the reference map's empowered forms tended to gain area (splash attacks, damage auras) rather than bigger single hits; a radius change is also the most visible difference on a small screen.

## Verification
- Prototype kit test passes 15/15, including an end-to-end check: a dummy 4 units away is out of Bellows Slam's reach but takes exactly 180 from Eruption.
- Area grows faster than radius: ×1.5 radius covers ×2.25 the ground area, so Eruption's crowd value rises more than its single-target value. Worth watching when 3v3 fights exist.
