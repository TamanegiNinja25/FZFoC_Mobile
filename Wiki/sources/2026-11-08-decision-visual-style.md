---
type: source
raw: ../../RAW/2026-11-08-decision-visual-style.md
added: 2026-11-08
why: Record the owner's visual style decision, with the budgets and techniques that make it workable on phones.
---
# Decision — high-poly stylized visual style

The owner chose a high-poly stylized visual style, overriding the earlier 5–20k polygon and "low-poly stylised" guidance. The record adds the librarian's recommendations: what the style means, a phone performance budget with LODs, Sketchfab sourcing tips, and a device stress test to manage the risk.

## Key points
- **Decision (owner):** high-poly stylized.
- **Style (recommendation):** sculpted forms with exaggerated, readable proportions; hand-painted or simplified textures; toon/ramp or simplified PBR shading with rim light; outlines optional; one shared palette and consistent proportions.
- **Budget (recommendation):** heroes 30–50k triangles at the closest LOD with 2–3 LODs (≈50%, ≈20%), textures up to 2K; large props 10–30k; small props under 5k; terrain detail from baked normal maps.
- **Worst case:** 6 heroes in 3v3, about 300k hero triangles at full detail; the distant camera usually triggers LODs.
- **Godot:** automatic mesh LODs on import, mobile texture compression, Mobile renderer already in use.
- **Sketchfab:** search "stylized", "hand-painted", "toon", "sculpt"; check face count and licence; prefer rigged models with baked textures.
- **Risk and mitigation:** phones have little GPU and memory headroom; stress-test 6 high-poly heroes on the target phone before committing to final assets.

## Topics
- [Art direction](../topics/art-direction.md)
- [Assets and licensing](../topics/assets-and-licensing.md#practical-checklist)
- [UI and audio direction](../topics/ui-and-audio-direction.md)

## Open questions
- Toon/ramp shading or simplified PBR?
- Which phone is the target device for the stress test?
