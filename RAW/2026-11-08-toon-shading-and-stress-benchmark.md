---
title: Toon shading decision and first stress-test benchmark
date: 2026-11-08
type: decision + measurement
decided-by: project owner (toon shading, in chat); benchmark run by the librarian in the Godot prototype
---

# Toon shading decision and first stress-test benchmark

## Decision: toon shading
- **The game uses toon shading** (owner's decision), not simplified PBR.
- **Prototype implementation:** one shared material — banded (toon) diffuse light, toon specular highlights, and a rim light so silhouettes read from the top-down camera. Applied to every object.

## Stress-test scene
- 6 placeholder heroes at **40,320 triangles** each (within the 30–50k budget), with **10 LOD levels** generated automatically by Godot, toon shading, particle effects and sun shadows, viewed from the game camera.
- On-screen toggles: LOD, effects, shadows, 6/12 heroes, game/close camera; live FPS, frame time, rendered triangles, draw calls and device info.
- Benchmark mode runs four configurations for 3 s each and prints the results.

## Benchmark — PC baseline (not a phone)
Device: ASUS Vivobook laptop with AMD Radeon integrated graphics. Godot 4.7.2, Mobile renderer, vsync off.

| Configuration | FPS | Avg frame | Triangles rendered |
|---|---|---|---|
| 6 heroes, game camera, LOD on | 506 | 1.98 ms | 18k |
| 6 heroes, close camera | 433 | 2.31 ms | 25k |
| 6 heroes, LOD off (worst case) | 396 | 2.52 ms | 971k |
| 12 heroes, LOD off | 326 | 3.07 ms | 1,941k |

## Findings
- **LODs do most of the work at the game camera:** about 240k triangles of heroes rendered as about 18k in total. Limitation: the placeholder is a smooth capsule, which simplifies easily; sculpted models with detailed silhouettes will reduce less.
- **Shadows multiply geometry cost about 4×:** 242k hero triangles became 971k rendered with LOD off, because Godot's default sun shadow draws 4 cascades. Fewer cascades is an easy saving on phones.
- **A PC result says nothing definite about phones.** Mobile GPUs are much weaker; the stress test must still run on the target phone.
