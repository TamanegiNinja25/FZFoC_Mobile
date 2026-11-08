---
title: Decision — 90% render resolution on phones; touch joystick
date: 2026-11-08
type: decision + measurement
decided-by: project owner (in chat: 90% instead of the proposed 75%, and a touch joystick); implemented and measured by the librarian in the Godot prototype
---

# Decision — 90% render resolution on phones; touch joystick

## Decision 1: phones render the 3D scene at 90% resolution
- The librarian proposed 75%; the owner chose **90%**. The UI and HUD stay at full resolution.
- **Measured on the Infinix NOTE 30** (phone default scene: 6 heroes, LOD on, 2 cascades), two rounds in a fixed order to rule out clock drift:

| 3D resolution | GPU, round 1 | GPU, round 2 |
|---|---|---|
| 100% | 13.71 ms | 13.68 ms |
| 90% | 7.37 ms | 7.44 ms |
| 75% | 6.25 ms | 6.24 ms |

- **90% saves 46% of GPU time** (75% saves 54%) while keeping a sharper image, leaving about 9 ms of the 16.7 ms frame budget free. All steps held 60 FPS; thermal status normal.
- The saving is larger than the pixel count alone suggests (81% of the pixels for 54% of the GPU time): full native resolution carries an extra cost on this phone.
- **Method lesson:** an earlier 10-step run showed the phone slowing mid-run (GPU and CPU times rose together; 75% read 14.7 ms instead of 6.2 ms). Those steps were discarded. Short runs with repeated rounds catch this.

## Decision 2: touch joystick
- A **floating joystick** for the left thumb: it appears wherever the thumb lands in the lower-left area (left 45% of the screen, below the top 30%) and drives movement with analog strength. Maximum travel 110 UI pixels, deadzone 15%.
- It feeds the same movement inputs as the keyboard, so game logic is unchanged.
- **Verified on the phone:** a simulated thumb drag moved the hero (screenshots before and after), and a diagonal drag walked the hero into a dummy, starting combat.

## Related fix: wide screens
- The phone's 20.5:9 screen showed black bars with the original 16:9 layout. The game now expands to fill wide screens; the HUD sits in the screen corners.
