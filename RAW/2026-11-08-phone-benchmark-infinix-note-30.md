---
title: Phone stress-test benchmark — Infinix NOTE 30
date: 2026-11-08
type: measurement
method: Godot prototype benchmark build installed over USB; results read from the phone's log. Four runs; values from the final run, which added engine-measured GPU/CPU time.
---

# Phone stress-test benchmark — Infinix NOTE 30

## Device
- Infinix NOTE 30 (model X6833B), Android 14.
- MediaTek MT6789 chip, Mali-G57 MC2 GPU, Vulkan 1.1.
- Screen 1080×2460, supports 60/90/120 Hz; it was running at **60 Hz**.
- The graphics driver offers **vsync on only**, so FPS can't exceed the refresh rate. GPU render time, measured by the engine per frame, shows the real cost. Budget at 60 FPS: 16.7 ms.

## Results
Scene: 40,320-triangle heroes with automatic LODs, toon shading, particle effects, sun shadows, game camera unless noted. Godot 4.7.2, Mobile renderer.

| Configuration | FPS | Worst frame | GPU | CPU | Triangles |
|---|---|---|---|---|---|
| 6 heroes, LOD on, 4 cascades | 60.1 | 16.7 ms | 13.9 ms | 0.4 ms | 18k |
| 6 heroes, LOD on, 2 cascades (phone default) | 60.0 | 16.7 ms | 13.7 ms | 0.3 ms | 9k |
| 6 heroes, close camera, 2 cascades | 60.0 | 16.7 ms | 14.9 ms | 0.4 ms | 32k |
| 6 heroes, LOD off, 4 cascades | 56.6 | 28.9 ms | 16.4 ms | 0.4 ms | 971k |
| 6 heroes, LOD off, 2 cascades | 60.0 | 16.7 ms | 15.2 ms | 0.4 ms | 486k |
| 12 heroes, LOD off, 2 cascades | 52.7 | 25.7 ms | 17.8 ms | 0.4 ms | 971k |
| 6 heroes, LOD on, 2 cascades, 75% render resolution | 60.1 | 16.7 ms | 6.2 ms | 0.3 ms | 9k |
| 6 heroes, LOD on, 2 cascades, no particle effects | 60.0 | 16.7 ms | 13.7 ms | 0.3 ms | 8k |

## Findings
- **The 30–50k triangle hero budget works on this phone.** Realistic settings (LOD on, 2 cascades) hold a locked 60 FPS with no dropped frames.
- **Headroom is thin:** about 3 ms of GPU time left per frame at full resolution.
- **The phone is pixel-bound, not triangle-bound.** Going from 9k to 486k triangles adds only 1.5 ms of GPU time; rendering at 75% resolution cuts GPU time from 13.7 ms to 6.2 ms (−54%).
- **Particle effects in this test cost almost nothing** (13.65 vs 13.66 ms).
- **2 cascades matter in the worst case:** with LOD off, 2 cascades keep 60 FPS where 4 cascades drop to 56.6 with 28.9 ms spikes.
- **CPU is not a factor:** under 0.5 ms per frame.
- **Stability:** four runs agreed within about 0.5 FPS; the phone's thermal status stayed normal (0). The short runs don't test sustained heat over a full match.

## Recommendation (librarian)
- Render the 3D scene at about **75% resolution on phones**, with the UI kept at full resolution. That roughly halves GPU time and leaves room for real art, more effects and longer play without heat throttling. It's a trade-off in sharpness, so it needs the owner's approval.
