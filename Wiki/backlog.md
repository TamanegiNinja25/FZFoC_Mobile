---
type: index
updated: 2026-11-08
---
# Backlog

Open questions, gaps, wanted sources and proposals awaiting the user's approval.

## Awaiting approval
*Nothing pending.* (Taxonomy approved 2026-11-08.)

## Unsourced claims
Marked *(inference)* in the wiki; each needs a RAW source:
- MPQ map header size and publicly known table-encryption keys — [Warcraft III map format](topics/warcraft-iii-map-format.md)
- The game finds files by hash, so stripping the file list doesn't stop it loading — [Warcraft III map format](topics/warcraft-iii-map-format.md)
- Copyright principles vary by country — [Copyright vs game mechanics](topics/copyright-vs-game-mechanics.md)
- Save licence screenshots in case pages change — [Assets and licensing](topics/assets-and-licensing.md)
- A public release would still need online matchmaking — [Hero arena genre](topics/hero-arena-genre.md#local-multiplayer)
- Long-press tooltips as the mobile tooltip pattern; transformation as its own sound moment — [UI and audio direction](topics/ui-and-audio-direction.md)

## Needs runtime verification
Claims a source marks as its own inference about Warcraft III engine behaviour; confirming them would need runtime observation (REA or play):
- Timed forms can't be cancelled early; level, XP, items and shared skills carry over through a morph; when the form cooldown starts — [Hero transformations](topics/hero-transformations.md)
- Hero A's form duration and cooldown (60 s / 180 s, stock defaults) — [Hero transformations](topics/hero-transformations.md)

## Recorded conflicts
- MP3s: "music tracks" vs measured 0.2–6.1 s clips — resolved in favour of the measurement; see [Fight Of Characters](topics/fight-of-characters.md#conflicts) and [Copyright vs game mechanics](topics/copyright-vs-game-mechanics.md#conflicts).
- Hero count: "36 hero forms" vs 25 playable heroes — different counting methods; the wiki uses 25 playable heroes; see [Fight Of Characters](topics/fight-of-characters.md#conflicts).

## Open questions
- ~~Which mechanics define Fight Of Characters' appeal and should be prototyped first?~~ Narrowed: hero transformations are the core candidate — see [Hero transformations](topics/hero-transformations.md#design-direction-for-fzfoc-mobile). Still open: what else belongs in the first prototype.
- Transformation design: meter or cooldown? Every hero or only some? Stages per match or per activation? Does a form end on death or crowd control? ([source](sources/2026-11-08-spec-hero-transformations.md))
- What setting and art style would make an original roster distinctive? ([source](sources/2026-11-08-fight-of-characters-mobile-feasibility.md))
- Target casual short sessions, or competitive ranked play? ([source](sources/2026-11-08-fight-of-characters-mobile-feasibility.md))

- Which 1–2 visual styles should the game commit to? ([source](sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md))
- Godot or Unity for the project? ([source](sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md))

- Who records the voices — friends, the user, or a hired actor? ([source](sources/2026-11-08-ui-and-audio-direction.md))
- Which UI kit or style anchors the look? ([source](sources/2026-11-08-ui-and-audio-direction.md))

## Wanted sources
- Sketchfab's official licence documentation and the Creative Commons licence texts (to confirm the licence table).
- Godot high-level multiplayer and Unity Netcode documentation for LAN play.
- Technical documentation of the MPQ archive and Warcraft III map file formats (would back the unsourced claims above).
- Mobile hero-arena / MOBA design references: match length, control schemes and monetisation in successful titles.
- Unity vs Godot for real-time mobile multiplayer; Photon vs Nakama comparisons.
- A plain-language guide to copyright and game mechanics (e.g. how courts have treated game rules versus expression).
