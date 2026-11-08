---
type: index
updated: 2026-11-08
---
# Index

The map of the wiki: every page with a one-line summary, grouped by category. Start here.

**Status:** 20 sources · 9 topic articles · 3 categories · 3 recorded conflicts · nothing awaiting approval

**Decisions so far:** transformations use a charge meter · prototype engine is Godot 4.7.2 ([record](sources/2026-11-08-decisions-meter-and-godot.md)) · charge rule tuned to a ~90 s fill, aggression rewarded, kill-spree economy ([record](sources/2026-11-08-decisions-charge-rule-and-spree.md)) · transformed heroes carry a higher bounty as risk/reward ([record](sources/2026-11-08-decision-transformed-bounty.md)) · visual style is high-poly stylized ([record](sources/2026-11-08-decision-visual-style.md)) with toon shading ([record](sources/2026-11-08-toon-shading-and-stress-benchmark.md)) · phones use 2 shadow cascades ([record](sources/2026-11-08-decision-phone-shadow-cascades.md)) and 90% 3D resolution; floating touch joystick ([record](sources/2026-11-08-decision-90-percent-resolution-and-touch-joystick.md))

## Topics

### Warcraft III modding
- [Fight Of Characters](topics/fight-of-characters.md) — Korean 4v4 anime crossover hero arena map; 25 playable heroes (11 can transform), 246 abilities, unpublishable outside modding because of copyrighted characters.
- [Warcraft III map format](topics/warcraft-iii-map-format.md) — Maps are MPQ archives holding script, data and assets; how protection scrambles them and how to check a map's script for harm.

### Game design
- [Hero transformations](topics/hero-transformations.md) — Three transformation models in Fight Of Characters (timed form, stage chain, awakening) with full numbers, and a keep/change/drop design direction for a mobile 3v3.
- [Hero arena genre](topics/hero-arena-genre.md) — Team hero fights with items and kill-based victory; adapting it to mobile with 3v3, short matches and touch controls; local Wi-Fi multiplayer in Godot; the kill-spree economy.
- [Roster](topics/roster.md) — The three original heroes: Vael (Bruiser), Ryn (Speed), Barrow (Giant) — kits, transformations, and how heroes are built.
- [Art direction](topics/art-direction.md) — High-poly stylized look with toon shading: style rules, phone polygon/LOD budget, Sketchfab sourcing, and stress-test measurements on PC and on the Infinix NOTE 30 (locked 60 FPS; pixel-bound).
- [UI and audio direction](topics/ui-and-audio-direction.md) — Keeping the classic feel with original assets: UI and sound patterns, how the map uses sound, and where to source replacements.

### Legal and IP
- [Copyright vs game mechanics](topics/copyright-vs-game-mechanics.md) — Characters, art, music and code are protected, rules and mechanics aren't; why a fan crossover can't ship but an original game can.
- [Assets and licensing](topics/assets-and-licensing.md) — Free model licences (CC0 to Editorial) and what each allows; fan-made character models can't license the character; a checklist for using Sketchfab assets.

## Sources
- [Fight Of Characters 7.7b E — analysis and mobile feasibility](sources/2026-11-08-fight-of-characters-mobile-feasibility.md) — Inspection of a 4v4 anime crossover Warcraft III map; a direct mobile port isn't feasible, an original game using its mechanics is.

- [Using free Sketchfab assets and local multiplayer](sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md) — Per-model Sketchfab licences, the fan-art catch, best uses of free assets, and server-free local multiplayer.
- [UI and audio direction](sources/2026-11-08-ui-and-audio-direction.md) — Why the map's UI and audio can't be reused, the patterns behind the nostalgia, asset sources, and a sound-event analysis correcting the "music tracks" claim.
- [Hero transformations — mechanic spec](sources/2026-11-08-spec-hero-transformations.md) — Clean-room analyst spec: 11 of 25 heroes transform via timed forms, a stage chain or an awakening; numbers, archetypes, bounties, mobile design notes.
- [Decisions — transformation meter and Godot engine](sources/2026-11-08-decisions-meter-and-godot.md) — The owner's decisions: a charge meter unlocks forms; the prototype is built in Godot.
- [Decisions — meter charge rule and kill-spree economy](sources/2026-11-08-decisions-charge-rule-and-spree.md) — Owner's tuning direction, the prototype's rates, and the measured 87.2 s fill.
- [Decision — transformed-hero bounty as risk/reward](sources/2026-11-08-decision-transformed-bounty.md) — Bounty kept, reframed from comeback lever to risk/reward; prototype 300 gold ×1.75 in form.
- [Decision — high-poly stylized visual style](sources/2026-11-08-decision-visual-style.md) — Owner's style decision plus recommended style rules, phone budget, sourcing tips and stress-test plan.
- [Toon shading decision and first stress-test benchmark](sources/2026-11-08-toon-shading-and-stress-benchmark.md) — Toon chosen; 6 × 40k-triangle stress scene; PC baseline shows LODs and shadow cost.
- [Decision — 2 shadow cascades on phones](sources/2026-11-08-decision-phone-shadow-cascades.md) — Phones 2 cascades, desktop 4; PC benchmark: shadow geometry halved, +12% FPS worst case.
- [Phone stress-test benchmark — Infinix NOTE 30](sources/2026-11-08-phone-benchmark-infinix-note-30.md) — First real-phone run: locked 60 FPS at realistic settings, ~3 ms headroom; pixel-bound, so 75% resolution halves GPU time.
- [Decision — 90% render resolution on phones; touch joystick](sources/2026-11-08-decision-90-percent-resolution-and-touch-joystick.md) — 90% cuts phone GPU time 13.7 → 7.4 ms; floating joystick verified on the phone; wide-screen fix.
- [Hero design — Vael, the Kiln Knight](sources/2026-11-08-hero-design-vael.md) — First original hero: concept, kit, Kindled transformation, prototype build and phone readability check.
- [Vael's Eruption — empowered skill design](sources/2026-11-08-vael-eruption.md) — Radius ×1.5, damage ×1.2 (180 effective while Kindled); area favoured; verified end to end.
- [Game build plan and Phase 1](sources/2026-11-08-game-build-plan-and-phase-1.md) — Full-game request, the original-content scope line, five phases, and Phase 1 (menus, settings, hero select, pause) verified on the phone.
- [UI polish and Phase 2](sources/2026-11-08-ui-polish-and-phase-2.md) — Animations, original sounds and icon, smoother Vael; the 3v3 arena with adaptive AI; locked 60 FPS after fixing primitive detail and stale settings.
- [Phase 3 — item shop with categories](sources/2026-11-08-phase-3-item-shop.md) — 13 original items in 5 categories, fountain shop rules, bot builds.
- [Phase 4 — play with friends over local Wi-Fi](sources/2026-11-08-phase-4-local-multiplayer.md) — Host-authoritative LAN play, lobby with discovery, verified with a real phone-hosted match.
- [Phase 5 — heroes Ryn and Barrow, original music](sources/2026-11-08-phase-5-heroes-and-music.md) — Speed and Giant heroes with new haste, slow and projectile systems; generated menu and battle music.
- [Phase 6 — the reference map's systems](sources/2026-11-08-phase-6-map-systems.md) — Levels 1–50, attributes and ranked skills, the duel, creep waves, boss chains, win boss, stat shop, exclusive items, recipes, Mobile and Classic modes.

## Admin
- [Log](log.md) — what changed and when
- [Backlog](backlog.md) — open questions, wanted sources, proposals
