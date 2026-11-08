---
type: source
raw: ../../RAW/2026-11-08-toon-shading-and-stress-benchmark.md
added: 2026-11-08
why: Record the toon shading decision and the first measured performance of the high-poly budget.
---
# Toon shading decision and first stress-test benchmark

The owner chose toon shading. The prototype gained a shared toon material and a stress-test scene (6 heroes × 40k triangles, auto LODs, effects, shadows). A PC baseline benchmark showed LODs cutting hero geometry to ~18k rendered triangles at the game camera and shadows multiplying geometry cost ~4×. A phone run is still needed.

## Key points
- **Decision:** toon shading, not simplified PBR. Material: banded diffuse, toon specular, rim light.
- **Stress scene:** 40,320-triangle heroes with 10 auto-generated LOD levels; toggles for LOD, effects, shadows, hero count, camera; live FPS and rendering stats; benchmark mode.
- **PC baseline (AMD Radeon integrated, laptop):** 506 FPS at game camera with LOD (18k tris rendered); 433 close-up; 396 with LOD off (971k tris); 326 with 12 heroes and LOD off (1,941k tris).
- **Findings:** LODs do most of the work from the top-down camera (≈240k → ≈18k); the smooth capsule flatters this, real sculpts will reduce less. Shadows multiply geometry ~4× (4 cascades by default) — fewer cascades is an easy phone saving. PC numbers don't predict phone performance.

## Topics
- [Art direction](../topics/art-direction.md)

## Open questions
- Which phone is the target device?
- How many shadow cascades (or which shadow mode) for phones?
