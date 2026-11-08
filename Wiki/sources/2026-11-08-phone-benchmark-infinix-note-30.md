---
type: source
raw: ../../RAW/2026-11-08-phone-benchmark-infinix-note-30.md
added: 2026-11-08
why: First real-phone measurement of the high-poly stylized budget.
---
# Phone stress-test benchmark — Infinix NOTE 30

The stress test ran on the owner's Infinix NOTE 30 (MT6789, Mali-G57 MC2, 60 Hz). Realistic settings hold a locked 60 FPS with ~3 ms GPU headroom. The phone is pixel-bound: triangles barely matter, 75% render resolution cuts GPU time by 54%, particles cost almost nothing. Recommendation: 75% 3D resolution on phones, pending approval.

## Key points
- **Device:** Infinix NOTE 30 (X6833B), Android 14, MT6789, Mali-G57 MC2, Vulkan 1.1, 1080×2460 at 60 Hz; vsync can't be disabled, so GPU ms is the real metric.
- **Realistic settings (6 heroes, LOD on, 2 cascades):** 60.0 FPS, worst frame 16.7 ms, GPU 13.7 ms, CPU 0.3 ms.
- **Worst cases:** LOD off with 4 cascades 56.6 FPS (spikes to 28.9 ms); LOD off with 2 cascades holds 60; 12 heroes LOD off 52.7 FPS.
- **Pixel-bound:** 9k → 486k triangles adds 1.5 ms; 75% resolution → 6.2 ms GPU (−54%); no particles → no change.
- **Stability:** four runs within ~0.5 FPS; thermal status normal; sustained heat over a full match not tested.
- **Recommendation:** 75% 3D render resolution on phones, UI at full resolution — awaiting the owner.

## Topics
- [Art direction](../topics/art-direction.md#measurements)

## Open questions
- Approve 75% 3D render resolution on phones?
- How does the phone behave thermally over a full 5–8 minute match?
- Does 90/120 Hz mode matter, or is 60 FPS the target?
