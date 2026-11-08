---
title: Decision — 2 shadow cascades on phones
date: 2026-11-08
type: decision + measurement
decided-by: project owner (in chat); benchmark run by the librarian in the Godot prototype
---

# Decision — 2 shadow cascades on phones

## Decision
- **Phones render sun shadows with 2 cascades**; desktop keeps Godot's default of 4. Owner's decision.
- **Prototype implementation:** a platform helper chooses 2 cascades on mobile builds; a `--phone` command-line option simulates phone settings on a PC. The stress test's shadow button cycles 2 → 4 → off for comparison on a device.

## Benchmark — 4 vs 2 cascades (PC, not a phone)
Device: ASUS Vivobook laptop, AMD Radeon integrated graphics. Godot 4.7.2, Mobile renderer, vsync off.

| Configuration | 4 cascades | 2 cascades |
|---|---|---|
| 6 heroes, game camera, LOD on | 551 FPS, 18k triangles | 521 FPS, 9k triangles |
| 6 heroes, close camera | — | 442 FPS, 25k triangles |
| 6 heroes, LOD off | 419 FPS, 971k triangles | 469 FPS, 486k triangles |
| 12 heroes, LOD off | — | 407 FPS, 971k triangles |

## Findings
- **2 cascades halve the shadow geometry** in every configuration.
- **Worst case (LOD off): +12% FPS** on this PC.
- **12 heroes with 2 cascades cost about the same geometry as 6 heroes with 4** (971k triangles each).
- At the game camera with LOD on, this PC isn't geometry-bound; the 551 vs 521 FPS difference is within run-to-run noise.

## Phone test status
- The owner connected a phone for the stress test, but at the time of writing the computer's Android tools listed no connected device, and Godot's export templates weren't installed. The phone measurement is still pending.
