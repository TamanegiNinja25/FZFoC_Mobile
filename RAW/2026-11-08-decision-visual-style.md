---
title: Decision — high-poly stylized visual style
date: 2026-11-08
type: decision
decided-by: project owner (in chat); budgets and techniques are the librarian's recommendations
---

# Decision — high-poly stylized visual style

## Decision
- **The game uses a high-poly stylized visual style.** Owner's decision.
- It replaces the earlier example of "low-poly stylised" and overrides the earlier 5–20k polygon guidance for characters.

## What "high-poly stylized" means here (recommendation)
- **Shapes:** smooth, sculpted forms with exaggerated, readable proportions: large hands, weapons and silhouettes, so each hero reads from a top-down camera.
- **Surfaces:** hand-painted or simplified colour textures over detailed geometry, not photo-realistic materials.
- **Shading:** stylized lighting, either toon/ramp shading or simplified PBR with a rim light. Outlines are optional (they add rendering cost).
- **Palette:** one shared colour palette and consistent proportions across all heroes, so assets from different creators look like one game.
- **Fit with the UI direction:** matches the planned fantasy UI (bevelled frames, gold trim, parchment tooltips).

## Performance budget for phones (recommendation)
High detail on phones needs a budget and level-of-detail (LOD) versions. Starting values, to be checked on a real device:

| Asset | Triangles (closest LOD) | LODs | Textures |
|---|---|---|---|
| Hero | 30–50k | 2–3 levels (≈50%, ≈20%) | Up to 2K, compressed |
| Large prop / landmark | 10–30k | 2 levels | 1K–2K |
| Small prop | Under 5k | Optional | 512–1K |
| Arena terrain | Detail from baked normal maps, not geometry | — | Tiling, 1K–2K |

- **Worst case:** 6 heroes on screen in 3v3, about 300k hero triangles at full detail. The distant top-down camera means LODs will usually apply.
- **Godot support:** Godot 4 can generate mesh LODs automatically when importing 3D models, and compresses textures for mobile GPUs. The prototype already uses Godot's Mobile renderer.
- **Baking:** where a model is too heavy, bake its high-poly detail into normal maps on a lighter mesh. This keeps the high-poly look at lower cost.

## Sourcing on Sketchfab (recommendation)
- Search terms: "stylized", "hand-painted", "toon", "sculpt"; check that a model is downloadable and has a game-usable licence.
- Filter or check the face count; prefer models already within or near the budget.
- Prefer rigged models with baked textures; the licence must allow changes if a model needs reducing or re-rigging.

## Risk
- Phones have far less GPU and memory headroom than PCs. High-poly heroes could hurt frame rate or battery life on mid-range phones.
- **Mitigation:** test a stress scene (6 high-poly heroes with LODs, effects on) on the target phone before committing to final assets; lower the budget if needed.
