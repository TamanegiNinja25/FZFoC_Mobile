---
type: topic
category: Game design
sources: [2026-11-08-decision-visual-style, 2026-11-08-sketchfab-assets-and-local-multiplayer, 2026-11-08-ui-and-audio-direction]
updated: 2026-11-08
---
# Art direction

FZFoC Mobile uses a **high-poly stylized** visual style: detailed, sculpted models with exaggerated, readable shapes and painterly surfaces. Making that work on phones depends on a polygon budget, automatic LODs and a stress test on a real device.

## Decision
- **2026-11-08 — High-poly stylized.** Chosen by the owner, overriding the earlier 5–20k polygon guidance and the "low-poly stylised" example ([src](../sources/2026-11-08-decision-visual-style.md)).
- The earlier guidance came from phone performance limits ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)); the budget below is how the decision respects them.

## The style
Recommendations recorded with the decision ([src](../sources/2026-11-08-decision-visual-style.md)):
- **Shapes:** smooth, sculpted forms; exaggerated proportions (large hands, weapons, silhouettes) so heroes read from a top-down camera.
- **Surfaces:** hand-painted or simplified colour textures, not photo-realistic materials.
- **Shading:** toon/ramp shading or simplified PBR with a rim light; outlines optional because they add rendering cost.
- **Consistency:** one shared palette and consistent proportions across heroes. This matters more than ever when assets come from different creators ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)).
- **UI fit:** matches the fantasy UI direction — bevelled frames, gold trim, parchment tooltips ([src](../sources/2026-11-08-ui-and-audio-direction.md)). See [UI and audio direction](ui-and-audio-direction.md).

## Phone performance budget
Starting values, to be checked on a real device ([src](../sources/2026-11-08-decision-visual-style.md)):

| Asset | Triangles (closest LOD) | LODs | Textures |
|---|---|---|---|
| Hero | 30–50k | 2–3 (≈50%, ≈20%) | Up to 2K, compressed |
| Large prop / landmark | 10–30k | 2 | 1K–2K |
| Small prop | Under 5k | Optional | 512–1K |
| Arena terrain | Detail from baked normal maps | — | Tiling, 1K–2K |

- **Worst case:** 6 heroes in 3v3, about 300k hero triangles at full detail; the distant top-down camera usually triggers LODs ([src](../sources/2026-11-08-decision-visual-style.md)).
- **Godot:** generates mesh LODs automatically on import and compresses textures for mobile GPUs; the prototype already uses the Mobile renderer ([src](../sources/2026-11-08-decision-visual-style.md)).
- **Baking:** bake high-poly detail into normal maps on a lighter mesh when a model is over budget ([src](../sources/2026-11-08-decision-visual-style.md)).

## Sourcing
- Sketchfab searches: "stylized", "hand-painted", "toon", "sculpt"; check the face count, that it's downloadable, and that the licence allows changes if the model needs reducing or re-rigging ([src](../sources/2026-11-08-decision-visual-style.md)).
- Prefer rigged models with baked textures; log every asset in the credits file — see [Assets and licensing](assets-and-licensing.md).

## Risk
- Phones have far less GPU and memory headroom than PCs; high-poly heroes could cost frame rate or battery on mid-range devices ([src](../sources/2026-11-08-decision-visual-style.md)).
- **Mitigation:** stress-test 6 high-poly heroes with LODs and effects on the target phone before committing to final assets; lower the budget if needed ([src](../sources/2026-11-08-decision-visual-style.md)).

## Open questions
- Toon/ramp shading or simplified PBR? ([src](../sources/2026-11-08-decision-visual-style.md))
- Which phone is the target device? ([src](../sources/2026-11-08-decision-visual-style.md))

## Related
- [Assets and licensing](assets-and-licensing.md)
- [UI and audio direction](ui-and-audio-direction.md)
- [Hero transformations](hero-transformations.md) — forms change the model (scale, colour), so each form needs its own look within the budget *(inference)*
