---
type: source
raw: ../../RAW/2026-11-08-decision-phone-shadow-cascades.md
added: 2026-11-08
why: Record the owner's phone shadow setting and the measured effect of 2 vs 4 cascades.
---
# Decision — 2 shadow cascades on phones

The owner set phones to 2 sun-shadow cascades (desktop keeps 4). The prototype's benchmark shows 2 cascades halve shadow geometry and give +12% FPS in the worst case on a PC. The phone run is still pending.

## Key points
- **Decision:** 2 cascades on phones, 4 on desktop; a `--phone` option simulates phone settings on PC; the stress test cycles 2 → 4 → off.
- **PC benchmark:** game camera 18k → 9k triangles; LOD off 971k → 486k triangles and 419 → 469 FPS (+12%); 12 heroes on 2 cascades ≈ 6 heroes on 4 (971k triangles).
- **Caveat:** at the game camera with LOD on, the PC isn't geometry-bound; small FPS differences there are noise.
- **Phone status:** the phone wasn't visible to the computer's Android tools yet, and Godot's export templates weren't installed.

## Topics
- [Art direction](../topics/art-direction.md#measurements)

## Open questions
- Phone results with 2 cascades.
