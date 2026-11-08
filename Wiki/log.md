---
type: index
updated: 2026-11-08
---
# Log

Newest entry first.

## 2026-11-08 — Phone check
- Owner tested the v0.6.0 release on their phone: no issues, performance stable even with high creep counts. README, prototype README and backlog updated; the creep caps (10 per camp, 80 total) stay as they are.

## 2026-11-08 — Release
- Released v0.6.0 at the owner's request (tag pushed; the GitHub workflow published `FZFoC.apk`, 29.4 MB). README status and roadmap updated; backlog notes the release came before the phone performance check, which stays pending.

## 2026-11-08 — Ingest (design + implementation)
- Ingested `2026-11-08-phase-6-map-systems.md` (Phase 6, prototype v0.6.0); source note created; [Fight Of Characters](topics/fight-of-characters.md) gains a Systems section (map facts); [Roster](topics/roster.md) gains ranks, ultimates, attributes and exclusive items; [Hero arena genre](topics/hero-arena-genre.md) notes the Mobile and Classic modes; backlog's awaiting-approval item resolved; index updated. History snapshots saved for both changed topic pages (oldest Fight Of Characters snapshot removed under the two-version rule).
- Pending: phone performance check before tagging v0.6.0.

## 2026-11-08 — Question: fidelity audit against the map
- Re-read the map (MPQ contents byte-identical to the earlier extraction) and parsed its items, shops, taverns, 123 hero skills and 267 triggers; simulated 500 matches per kill-rate scenario from the script's rules.
- Answer written to `Outputs/2026-11-08-foc-fidelity-audit.md`: FZFoC keeps the genre skeleton but not the specific systems (duels, levelling, creep waves, bosses, recipes, exclusive items, unique picks, 100-kill win).
- Not filed into topic articles: outputs aren't sources. Backlog item added for the owner to choose systems and optionally move the report to RAW.

## 2026-11-08 — Release pipeline and README
- Root `README.md` rewritten for the playable alpha (v0.5.0): download badge pointing at `releases/latest/download/FZFoC.apk`, install and update steps, feature and hero tables, phone performance, release instructions, refreshed roadmap.
- Added `.github/workflows/release.yml`: a `v*` tag builds the APK with Godot 4.7.2 on Linux and publishes a GitHub Release; the tag sets the game version and Android version code.
- Game: version 0.5.0 (code 500) shown in the menu; an in-game update check offers newer releases (`Prototype/scripts/ui/update_checker.gd`, test `update_check_test.gd`). `export_presets.cfg` is now committed (it holds no credentials in Godot 4).
- Pending: owner adds the `DEBUG_KEYSTORE_BASE64` secret so releases install as updates.

## 2026-11-08 — Ingest (design + implementation)
- Ingested `2026-11-08-phase-5-heroes-and-music.md` (prototype commit 5e7d9c9); source note created; [Roster](topics/roster.md) gains Ryn and Barrow; [UI and audio direction](topics/ui-and-audio-direction.md) gains music; backlog shows all five phases complete; index and README roadmap updated.

## 2026-11-08 — Ingest (implementation)
- Ingested `2026-11-08-phase-4-local-multiplayer.md` (prototype commit 01b3b0a); source note created; [Hero arena genre](topics/hero-arena-genre.md) Modes updated; backlog, index and README roadmap updated.

## 2026-11-08 — Ingest (implementation)
- Ingested `2026-11-08-phase-3-item-shop.md` (prototype commit 2843f84); source note created; [Hero arena genre](topics/hero-arena-genre.md) gains Itemization; backlog, index and README roadmap updated.

## 2026-11-08 — Ingest (implementation + measurement)
- Ingested 1 new RAW file: `2026-11-08-ui-polish-and-phase-2.md` — UI polish and Phase 2 (prototype commits 62a8cb1, 5cf87b7).
- Created source note [2026-11-08-ui-polish-and-phase-2](sources/2026-11-08-ui-polish-and-phase-2.md).
- [Hero arena genre](topics/hero-arena-genre.md): single player built, adaptive AI. [Art direction](topics/art-direction.md): primitive-detail and stale-settings lessons, arena 60 FPS. [UI and audio direction](topics/ui-and-audio-direction.md): polish, original sounds and icon. [Roster](topics/roster.md): polished Vael. [Copyright vs game mechanics](topics/copyright-vs-game-mechanics.md): model reverse-engineering declined.
- [Backlog](backlog.md): Phase 2 done; difficulty and fairness questions. [Index](index.md) and README roadmap updated.

## 2026-11-08 — Ingest (plan + implementation)
- Ingested 1 new RAW file: `2026-11-08-game-build-plan-and-phase-1.md` — the owner's full-game request, the scope line (original content only), the five-phase plan and Phase 1 (prototype commit b874151).
- Created source note [game-build-plan-and-phase-1](sources/2026-11-08-game-build-plan-and-phase-1.md).
- [UI and audio direction](topics/ui-and-audio-direction.md): "Menus in the prototype". [Hero arena genre](topics/hero-arena-genre.md): "Modes". [Copyright vs game mechanics](topics/copyright-vs-game-mechanics.md): "Applied to the game build".
- [Backlog](backlog.md): Phases 2–5 and an original title. [Index](index.md) and README roadmap updated.

## 2026-11-08 — Ingest (design)
- Ingested 1 new RAW file: `2026-11-08-vael-eruption.md` — Eruption's design (prototype commit e2339d6).
- Created source note [vael-eruption](sources/2026-11-08-vael-eruption.md).
- [Roster](topics/roster.md): Vael marked complete in the prototype; Eruption row and rationale added. [Hero transformations](topics/hero-transformations.md): Eruption values.
- [Backlog](backlog.md): Eruption question closed; 3v3 crowd-value watch item added. [Index](index.md) and README roadmap updated.

## 2026-11-08 — Ingest (design)
- Ingested 1 new RAW file: `2026-11-08-hero-design-vael.md` — the first original hero, Vael, with the Kindled transformation (prototype work in progress; commit follows once Eruption is designed).
- Created source note [hero-design-vael](sources/2026-11-08-hero-design-vael.md) and topic [Roster](topics/roster.md) (Game design).
- [Hero transformations](topics/hero-transformations.md): Kindled as the first original form. [Art direction](topics/art-direction.md): new "Readability from the top-down camera" section from the phone check.
- [Backlog](backlog.md): Vael questions and the heroes 2–3 question. [Index](index.md) and README roadmap updated.

## 2026-11-08 — Ingest (decision + measurement)
- Ingested 1 new RAW file: `2026-11-08-decision-90-percent-resolution-and-touch-joystick.md` (prototype commit 170d093).
- Created source note [decision-90-percent-resolution-and-touch-joystick](sources/2026-11-08-decision-90-percent-resolution-and-touch-joystick.md).
- [Art direction](topics/art-direction.md): 90% resolution decision with the two-round phone measurement; resolution question closed.
- [Hero arena genre](topics/hero-arena-genre.md): touch joystick and wide-screen layout recorded under Adapting for mobile.
- [Backlog](backlog.md): pending approval resolved (90% chosen over the proposed 75%). [Index](index.md) and README roadmap updated.

## 2026-11-08 — Ingest (measurement)
- Ingested 1 new RAW file: `2026-11-08-phone-benchmark-infinix-note-30.md` — the first real-phone stress test (prototype commit 516fb99).
- Created source note [phone-benchmark-infinix-note-30](sources/2026-11-08-phone-benchmark-infinix-note-30.md).
- [Art direction](topics/art-direction.md): new "Phone: Infinix NOTE 30" measurements; target-phone question answered.
- [Backlog](backlog.md): phone performance moved from "needs verification" to **verified**; **new item awaiting approval: 75% 3D render resolution on phones**; added thermal and refresh-rate questions. [Index](index.md) and README roadmap updated.

## 2026-11-08 — Ingest (decision + measurement)
- Ingested 1 new RAW file: `2026-11-08-decision-phone-shadow-cascades.md` — 2 cascades on phones, with the 4-vs-2 benchmark (prototype commit 01d37fe).
- Created source note [decision-phone-shadow-cascades](sources/2026-11-08-decision-phone-shadow-cascades.md).
- [Art direction](topics/art-direction.md): cascade decision and comparison table in Measurements; cascade question closed.
- [Backlog](backlog.md) and [index](index.md) updated. Phone run still pending: no device visible to adb, export templates not installed.

## 2026-11-08 — Ingest (decision + measurement)
- Ingested 1 new RAW file: `2026-11-08-toon-shading-and-stress-benchmark.md` — the owner's toon shading decision and the first PC benchmark of the stress-test scene (prototype commit 24c064c).
- Created source note [toon-shading-and-stress-benchmark](sources/2026-11-08-toon-shading-and-stress-benchmark.md).
- [Art direction](topics/art-direction.md): toon decision; new Measurements section (PC baseline, LOD and shadow findings); shading question closed, shadow-cascade question added.
- [Backlog](backlog.md): shading closed; phone performance item updated — scene and PC baseline exist, phone run pending. [Index](index.md) and README roadmap updated.

## 2026-11-08 — Ingest (decision)
- Ingested 1 new RAW file: `2026-11-08-decision-visual-style.md` — the owner's high-poly stylized decision, with the librarian's style rules, phone budget and stress-test plan marked as recommendations.
- Created source note [decision-visual-style](sources/2026-11-08-decision-visual-style.md) and topic [Art direction](topics/art-direction.md) (Game design).
- [Assets and licensing](topics/assets-and-licensing.md): the 5–20k polygon guidance marked **superseded**, not deleted, with a pointer to the new budget.
- Cross-linked UI and audio direction and Hero transformations.
- [Backlog](backlog.md): visual-style question closed; shading and target-phone questions added; phone performance added to "Needs runtime verification". README roadmap updated.

## 2026-11-08 — Ingest (decision)
- Ingested 1 new RAW file: `2026-11-08-decision-transformed-bounty.md`.
- Created source note [decision-transformed-bounty](sources/2026-11-08-decision-transformed-bounty.md).
- **Resolved the pending approval:** the transformed-hero bounty is kept as risk/reward. [Hero transformations](topics/hero-transformations.md#decisions) tension note replaced with the decision; [Hero arena genre](topics/hero-arena-genre.md#economy) Economy section gains the bounty.
- [Backlog](backlog.md): nothing awaiting approval; new question on scaling the multiplier by form. [Index](index.md) updated.
- Prototype implements the bounty (commit d69dd38).

## 2026-11-08 — Ingest (decisions)
- Ingested 1 new RAW file: `2026-11-08-decisions-charge-rule-and-spree.md` — the owner's meter direction plus the prototype's rates and measured results.
- Created source note [decisions-charge-rule-and-spree](sources/2026-11-08-decisions-charge-rule-and-spree.md).
- [Hero transformations](topics/hero-transformations.md): charge-rule decision and table; open questions updated.
- [Hero arena genre](topics/hero-arena-genre.md): new Economy section (kill spree).
- **Flagged for approval:** the spec's transformed-hero bounty was framed as a comeback lever, which conflicts with the owner's "no comeback mechanic" decision. Added to the [backlog](backlog.md) under Awaiting approval rather than resolved.
- [Index](index.md) decisions line and status updated; README roadmap updated.

## 2026-11-08 — Ingest (decisions)
- Ingested 1 new RAW file: `2026-11-08-decisions-meter-and-godot.md`, recording the owner's decisions from chat.
- Created source note [decisions-meter-and-godot](sources/2026-11-08-decisions-meter-and-godot.md).
- [Hero transformations](topics/hero-transformations.md): new Decisions subsection (charge meter); open question narrowed to meter tuning.
- [Hero arena genre](topics/hero-arena-genre.md): Godot recorded as the engine.
- [Index](index.md): decisions line added. [Backlog](backlog.md): engine and meter-vs-cooldown questions closed; meter tuning added.

## 2026-11-08 — Ingest
- Ingested 1 new RAW file: `2026-11-08-spec-hero-transformations.md` (mechanics-analyst spec, moved from Outputs at the user's request; key values spot-checked against map data before commit).
- Created source note [spec-hero-transformations](sources/2026-11-08-spec-hero-transformations.md).
- Rewrote [Hero transformations](topics/hero-transformations.md): three models, archetypes, numbers, bounty and uptime, last stand, keep/change/drop design direction, refined open questions. Corrected an earlier *(inference)*: most forms use the engine's morph on the same unit; only the awakening swaps units. Previous version saved to `_history/`; compared — no information lost beyond the corrected inference.
- **Conflict recorded:** "36 hero forms" (feasibility analysis) vs 25 playable heroes (spec). Added to [Fight Of Characters](topics/fight-of-characters.md#conflicts); content table, play summary and index updated. Previous version saved as `_history/fight-of-characters--2026-11-08b.md` (second same-day copy).
- [Copyright vs game mechanics](topics/copyright-vs-game-mechanics.md): hero count updated with citation.
- [Backlog](backlog.md): new "Needs runtime verification" list, conflict listed, first open question narrowed, transformation design questions added.

## 2026-11-08 — Ingest
- Ingested 1 new RAW file: `2026-11-08-ui-and-audio-direction.md` (saved at the user's request; includes findings from the same-day sound-event analysis, spec at `Outputs/2026-11-08-spec-sound-events.md`).
- Created source note [ui-and-audio-direction](sources/2026-11-08-ui-and-audio-direction.md) and topic [UI and audio direction](topics/ui-and-audio-direction.md) (Game design).
- **Conflict recorded:** the first source called the 60 MP3s "music tracks"; the new source measured them as 0.2–6.1 s clips. Added Conflicts sections to [Fight Of Characters](topics/fight-of-characters.md#conflicts) and [Copyright vs game mechanics](topics/copyright-vs-game-mechanics.md#conflicts), resolved in favour of the measurement. Previous versions saved to `_history/`; compared — nothing removed except the corrected wording.
- Added a Sound section to Fight Of Characters; cross-linked Assets and licensing and Hero transformations.
- [Index](index.md) and [backlog](backlog.md) updated: +2 *(inference)* claims, +2 open questions, conflict listed.

## 2026-11-08 — Ingest
- Ingested 1 new RAW file: `2026-11-08-sketchfab-assets-and-local-multiplayer.md` (saved at the user's request).
- Created source note [sketchfab-assets-and-local-multiplayer](sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md).
- Created topic [Assets and licensing](topics/assets-and-licensing.md) in the existing Legal and IP category.
- Updated [Hero arena genre](topics/hero-arena-genre.md): new Local multiplayer section, second source, summary refreshed. Previous version saved to `_history/hero-arena-genre--2026-11-08.md`; compared — nothing removed.
- Linked [Copyright vs game mechanics](topics/copyright-vs-game-mechanics.md) to the new article; updated the [index](index.md).
- [Backlog](backlog.md): +2 *(inference)* claims, +2 open questions, +2 wanted sources.
- Conflicts: none. The offline local-play advice sits alongside, not against, the online matchmaking advice for a public release.
- Created `Outputs/2026-11-08-asset-credits-template.md` for tracking downloaded assets (project file, not cited in the wiki).

## 2026-11-08 — Topic articles (taxonomy approved)
- User approved 3 categories: Warcraft III modding, Game design, Legal and IP.
- Created 5 topic articles: [Fight Of Characters](topics/fight-of-characters.md), [Warcraft III map format](topics/warcraft-iii-map-format.md), [Hero transformations](topics/hero-transformations.md), [Hero arena genre](topics/hero-arena-genre.md), [Copyright vs game mechanics](topics/copyright-vs-game-mechanics.md).
- Linked the source note to all five; rebuilt the [index](index.md) by category.
- [Backlog](backlog.md): cleared the approved proposal; listed 3 *(inference)* claims needing sources; added 1 wanted source (MPQ / map format docs).
- No contradictions (single source).

## 2026-11-08 — Ingest
- Ingested 1 new RAW file: `2026-11-08-fight-of-characters-mobile-feasibility.md` (moved from Outputs at the user's request).
- Created source note [fight-of-characters-mobile-feasibility](sources/2026-11-08-fight-of-characters-mobile-feasibility.md).
- Created [index](index.md), [backlog](backlog.md) and this log; created `sources/` and `topics/`.
- **Pending:** no topic articles yet — the wiki had no categories, and new categories need approval in Active mode. Proposed 3 categories and 5 topics in the [backlog](backlog.md).
- Added 3 open questions and 3 wanted sources to the backlog.
