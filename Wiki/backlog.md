---
type: index
updated: 2026-11-08
---
# Backlog

Open questions, gaps, wanted sources and proposals awaiting the user's approval.

## Awaiting approval
*Nothing pending.* (Resolved 2026-11-08: the fidelity audit's adoptions — the owner chose all six; built in Phase 6 ([source](sources/2026-11-08-phase-6-map-systems.md)). Unique hero picks were not requested.)
*Nothing pending.* (Last resolved 2026-11-08: phone render resolution — owner chose 90% over the proposed 75% — [Art direction](topics/art-direction.md#phone-infinix-note-30).)

## Unsourced claims
Marked *(inference)* in the wiki; each needs a RAW source:
- MPQ map header size and publicly known table-encryption keys — [Warcraft III map format](topics/warcraft-iii-map-format.md)
- The game finds files by hash, so stripping the file list doesn't stop it loading — [Warcraft III map format](topics/warcraft-iii-map-format.md)
- Copyright principles vary by country — [Copyright vs game mechanics](topics/copyright-vs-game-mechanics.md)
- Save licence screenshots in case pages change — [Assets and licensing](topics/assets-and-licensing.md)
- A public release would still need online matchmaking — [Hero arena genre](topics/hero-arena-genre.md#local-multiplayer)
- Long-press tooltips as the mobile tooltip pattern; transformation as its own sound moment — [UI and audio direction](topics/ui-and-audio-direction.md)
- The chunky low-poly KayKit look may call for revisiting the "high-poly stylized" decision — [Art direction](topics/art-direction.md#rigged-characters-and-scenery-phase-8)
- The original hero models remain as a fallback — [Roster](topics/roster.md)
- A spree economy without a comeback mechanic may snowball — [Hero arena genre](topics/hero-arena-genre.md#economy)

## Needs runtime verification
Claims a source marks as its own inference about Warcraft III engine behaviour; confirming them would need runtime observation (REA or play):
- Timed forms can't be cancelled early; level, XP, items and shared skills carry over through a morph; when the form cooldown starts — [Hero transformations](topics/hero-transformations.md)
- Hero A's form duration and cooldown (60 s / 180 s, stock defaults) — [Hero transformations](topics/hero-transformations.md)
- ~~Phone performance of high-poly heroes~~ **Verified 2026-11-08** on the Infinix NOTE 30: locked 60 FPS at realistic settings — [Art direction](topics/art-direction.md#phone-infinix-note-30)
- Sustained heat over a full 5–8 minute match on the NOTE 30 — [Art direction](topics/art-direction.md#phone-infinix-note-30)

## Recorded conflicts
- MP3s: "music tracks" vs measured 0.2–6.1 s clips — resolved in favour of the measurement; see [Fight Of Characters](topics/fight-of-characters.md#conflicts) and [Copyright vs game mechanics](topics/copyright-vs-game-mechanics.md#conflicts).
- Hero count: "36 hero forms" vs 25 playable heroes — different counting methods; the wiki uses 25 playable heroes; see [Fight Of Characters](topics/fight-of-characters.md#conflicts).

## Open questions
- Difficulty choice for enemy bots' base skill? Does adaptive AI feel fair over a full match? ([source](sources/2026-11-08-ui-polish-and-phase-2.md))
- **Game build:** ~~Phase 2~~, ~~Phase 3~~, ~~Phase 4~~, ~~Phase 5~~, ~~Phase 6 (map systems)~~ done ([source](sources/2026-11-08-phase-6-map-systems.md)) ([source](sources/2026-11-08-phase-5-heroes-and-music.md)); all planned phases complete. v0.6.0 released; ~~phone performance check~~ done by the owner: no issues, stable with high creep counts. ~~Phase 7~~ done ([source](sources/2026-11-09-phase-7-feel-heroes-original-rules.md)): open — a cold-start phone check (the 46–51 FPS reading came from a warm phone after an hour of tests), a fresh balance round after Sable's last buff, and the release signing secret ([source](sources/2026-11-08-phase-4-local-multiplayer.md)) ([source](sources/2026-11-08-phase-3-item-shop.md)); ([source](sources/2026-11-08-ui-polish-and-phase-2.md)). Next: Phases 3–5 ([source](sources/2026-11-08-game-build-plan-and-phase-1.md)): adaptive AI design (what adapts?); original arena map; item categories; local Wi-Fi host/join; heroes 2–3, icons, audio.
- An original title to replace the working title "FZFoC" before any release ([source](sources/2026-11-08-game-build-plan-and-phase-1.md))
- **Vael:** ~~how is Eruption empowered?~~ Radius ×1.5, damage ×1.2 ([source](sources/2026-11-08-vael-eruption.md)). Still open: glow placement on the final model; voice lines and Kindled sound; Eruption's crowd value in 3v3 ([source](sources/2026-11-08-hero-design-vael.md))
- Heroes 2 and 3: which archetypes? *(speed and giant would complete the reference's set)* — [Roster](topics/roster.md)
- ~~Which mechanics define Fight Of Characters' appeal and should be prototyped first?~~ Narrowed: hero transformations are the core candidate — see [Hero transformations](topics/hero-transformations.md#design-direction-for-fzfoc-mobile). Still open: what else belongs in the first prototype.
- Should the transformed bounty multiplier scale with form strength or stage? ([source](sources/2026-11-08-decision-transformed-bounty.md))
- ~~Meter tuning~~ Decided 2026-11-08: charge rule, 87.2 s measured fill ([source](sources/2026-11-08-decisions-charge-rule-and-spree.md)). Still open: does it hold in 3v3? Does the spree economy snowball too hard?
- Transformation design: ~~meter or cooldown~~ (decided: meter). Every hero or only some? Stages per match or per activation? Does a form end on death or crowd control? ([source](sources/2026-11-08-spec-hero-transformations.md))
- What setting and art style would make an original roster distinctive? ([source](sources/2026-11-08-fight-of-characters-mobile-feasibility.md))
- Target casual short sessions, or competitive ranked play? ([source](sources/2026-11-08-fight-of-characters-mobile-feasibility.md))

- ~~Which 1–2 visual styles should the game commit to?~~ Decided 2026-11-08: high-poly stylized ([source](sources/2026-11-08-decision-visual-style.md))
- ~~Toon/ramp shading or simplified PBR?~~ Decided 2026-11-08: toon ([source](sources/2026-11-08-toon-shading-and-stress-benchmark.md))
- ~~Which phone is the stress-test target?~~ The owner's Infinix NOTE 30 ([source](sources/2026-11-08-phone-benchmark-infinix-note-30.md)). Target 60 FPS, or use the phone's 90/120 Hz modes? ([source](sources/2026-11-08-phone-benchmark-infinix-note-30.md))
- ~~Godot or Unity for the project?~~ Decided 2026-11-08: Godot ([source](sources/2026-11-08-decisions-meter-and-godot.md))

- Who records the voices — friends, the user, or a hired actor? ([source](sources/2026-11-08-ui-and-audio-direction.md))
- ~~Which UI kit or style anchors the look?~~ Phase 8: Kenney RPG UI pack, tinted to stone and gold ([source](sources/2026-11-08-ui-and-audio-direction.md)) ([source](sources/2026-11-09-phase-8-assets-agents-skills.md))
- ~~**Release signing**~~ solved 2026-11-09: v0.8.2 is signed with the shared key and installs as an update.
- **Reference-map gaps** (from the 2026-11-09 gap audit output):
  - missing systems: private creep rooms with teleport pads; multi-stage forms; stat-threshold evolution; live K/D scoreboard; storage unit; host duel switch; custom recall point; skill-name callouts; potion stacking;
  - values that differ: Classic 50 vs the map's 100 kills; respawn 6 vs 4 s; passive income the map doesn't have; capture is one-shot, not persistent;
  - scale: 8/24 heroes, 32/120 skills, 45/59 items, no voice or per-skill sound.
- **Phase 8 open:** ~~a phone check of the rigged heroes and single-mesh scenery~~ done 2026-11-09: 4v4 Classic, up to 436 units, 42–56 FPS (average 47), the same as v0.7.0, no errors; whether selected toggle buttons stand out on the tinted skin; skill sound effects (slam, transform) still generated; skill icons and 2D sprites not taken from packs (original icons kept) ([source](sources/2026-11-09-phase-8-assets-agents-skills.md))

## Wanted sources
- Sketchfab's official licence documentation and the Creative Commons licence texts (to confirm the licence table).
- Godot high-level multiplayer and Unity Netcode documentation for LAN play.
- Technical documentation of the MPQ archive and Warcraft III map file formats (would back the unsourced claims above).
- Mobile hero-arena / MOBA design references: match length, control schemes and monetisation in successful titles.
- Unity vs Godot for real-time mobile multiplayer; Photon vs Nakama comparisons.
- A plain-language guide to copyright and game mechanics (e.g. how courts have treated game rules versus expression).
