---
title: UI polish and Phase 2 — 3v3 arena against adaptive AI
date: 2026-11-08
type: implementation + measurement
decided-by: owner asked for layout fixes, menu animation and click sounds, an app icon "like the Frozen Throne icon or an anime fighting one", Phase 2 onwards, and for the map's models to be applied or reverse-engineered into originals; scope and design by the librarian
---

# UI polish and Phase 2

## Scope line on models
- The owner suggested reverse-engineering the map's models so they could be used without legal issues. Not done: those models belong to Blizzard and the anime owners, and converting or tracing them produces a derivative copy with the same legal problem. The project's analyst rules forbid it for the same reason.
- Instead, the project's own original models were polished (below); licensed third-party models remain possible under the asset rules.

## UI polish
- **Layout:** the HUD and menus are inset to the phone's safe area (camera cutout, rounded corners); HUD stats sit on a translucent stone backing; settings tabs styled; the skill-1 button widened and its label shrunk after it overlapped TRANSFORM on the phone.
- **Animation:** the main menu panel slides in, the title pulses gold, panels pop in (fade and grow), and every button shrinks on press and springs back.
- **Sound:** ten original effects (click, confirm, back, hit, slam, dash, transform, kill, victory, defeat), synthesised from code, played on the SFX bus; every button clicks automatically.
- **App icon:** an original emblem — Vael's hammer with anime-style slash streaks in a gold ring over an ember glow — plus Android adaptive-icon layers. Not a copy of any game's icon.
- **Reproducible:** `tools/generate_assets.py` regenerates the icon and every sound from code, documenting their originality.
- **Vael model:** rounded pauldrons, barrel hammer, round shield carrying a team-coloured emblem, a belt blending torso and legs; glow added on top-visible shoulder vents and a helm crest.
- **Settings:** Reset to Defaults added.

## Phase 2 — 3v3 arena
- **Map (original):** 64×40 field; blue base west and red base east with healing fountains (90 HP/s within 5 units); stone central lane; rune circle at the centre; symmetric pillars and boulders; two neutral camps (north and south) of stone sentinels respawning every 25 s.
- **Teams:** the player and two bot allies (blue) against three bots (red). Rings mark sides (gold for the player); health bars float overhead.
- **Combat:** heroes and neutral units share one targeting system; killing a hero pays the killer the victim's bounty (spree multipliers apply); neutral kills pay kill gold.
- **Win condition:** first to 15 kills, or the leader after 8:00 (draw if tied). Scoreboard, kill feed, and a Victory / Defeat / Draw screen with Play Again and Main Menu.
- **Adaptive AI:** bots use the same controls as the player. One skill value (0–1) changes only decisions: reaction time 0.7 → 0.15 s; retreat threshold 0% → 38% HP; nearest target vs weakest target; skill accuracy 30% → 95%; using the form at once vs saving it for a fight; dashing onto wounded targets. Enemy skill = 0.5 + 0.1 per kill the player's team leads (clamped 0.15–0.95); allies stay at 0.55. Stats never change. Bots sidestep when stuck on pillars.
- **Menus:** Start Match opens the arena; a Training button opens the dummy training ground.

## Verification
- New arena test, 9/9: 3v3 spawn; bots score on their own (3 kills in 26 s simulated); fountain heals 200 → 402 HP in 2 s; enemy skill 0.95 when the player leads by 6 and 0.15 when trailing by 6, allies 0.55; reaching the kill target shows the victory screen.
- The arena test exposed a real bug: hero auto-attacks could only target training dummies, so heroes couldn't hit each other except with skills. Fixed.
- All seven test suites pass with zero script errors; tests now run with per-test time limits.

## Performance lessons (Infinix NOTE 30)
- First arena run: 35–37 FPS, GPU 25.5 ms, ~890k triangles.
- **Godot's primitive shapes default to high detail and get no automatic LODs** (a sphere is ~4,000 triangles). Setting segment counts cut the arena to ~50k triangles, but GPU time only fell to ~21–23 ms — consistent with the phone being pixel-bound.
- **The real cause:** the phone's saved settings held desktop values (100% resolution, 4 shadow cascades, FPS counter on), most likely changed by a stray simulated tap during an automated walkthrough. Opening Settings alone doesn't save anything (tested).
- **With phone defaults (90%, 2 cascades): locked 60 FPS, GPU 10.2 ms.**
- Also: shadow distance limited to 40 units (the camera sees about 30); flat ground pieces don't cast shadows.
- A debug-build performance log (FPS, GPU, CPU, draw calls, triangles, active settings) now prints every 2 s for diagnosis.
