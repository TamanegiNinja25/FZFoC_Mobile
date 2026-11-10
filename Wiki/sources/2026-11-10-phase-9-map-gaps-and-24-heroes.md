---
type: source
raw: ../../RAW/2026-11-10-phase-9-map-gaps-and-24-heroes.md
added: 2026-11-10
why: Owner asked to fill every gap found by the second read of the reference map, add the remaining heroes with skills, items, voices and per-skill sounds, and release once finished.
---
# Phase 9 — the reference map's remaining systems and 24 heroes
Record of Phase 9. A second read of Fight Of Characters 7.7b E, this time of every trigger's code, found the systems still missing; all were built.

**Systems:**
- scoreboard, cast callouts, 4 s respawn;
- Classic at 100 kills with no passive gold, and a duel switch;
- chained transformations, private creep rooms and a stat-threshold evolution;
- storage satchel, lasting capture, recall point, potion stacking.

**Content:**
- The roster grew to 24 original heroes, each with an innate blink and a signature item.
- Every skill has its own generated sound; heroes have CC0/CC-BY voices; an announcer calls the match.
- Six heroes use Quaternius bodies.

## Key points
- **Map facts from the trigger code:**
  - The scoreboard is a per-player kills/deaths board with team totals.
  - Every cast floats "*skill* !!"; heroes revive after 4 s.
  - A host-only chat command removes duels.
  - A chat command saves a point that a recall item returns to.
  - Charged items stack two to a slot; the capture ball's creature stays the owner's until it dies.
  - Five teleport-pad pairs lead to four rooms that spawn creeps on entry, at most 20 alive per type.
  - One hero is replaced by an evolved unit at 250 STR and 250 AGI, keeping level, XP, stats and items, with four new skills.
  - Several heroes transform in chains of up to three stages.
- **Chained forms:** while transformed, the meter charges 6× faster; a full meter ascends a stage (timer reset, shield top-up, +20% damage, larger, +0.5× bounty). Tamsin, Pyre and Thane have three stages; Vael, Ryn, Barrow, Morrow, Seraphine, Oren, Isolde, Halvard, Corin and Lys have two.
- **Creep rooms:** four walled rooms south of the field with the map's room units. Players and bots use them; bots farm when the field is quiet and leave when a room is empty.
- **Roster:** 16 new heroes, six per realm. Kits are built from the configurable skill types. Corin evolves into Corin Unbound. Each match shuffles which heroes the bots take.
- **Audio:** 117 skill sounds synthesised from code. Voices come from HaelDB (CC0), thebardofblasphemy (CC0) and JeanMyna_VA (CC-BY 3.0), pitched per hero. The announcer is Kenney's Voiceover Pack: Fighter (CC0).
- **Looks:** KayKit bodies recoloured and re-armed; Quaternius RPG characters (CC0) for Oren, Ashka, Nyx, Velka, Corin and Lys.
- **Results:**
  - all 13 suites and the network test pass;
  - phone: 4v4 Classic up to 424 units at 42–58 FPS (average 49.6), no errors;
  - APK 48.5 MB.
  Balance: 24 all-bot matches found six outliers (Mire, Wren, Ashka, Lys, Kestrel low; Seraphine high); one tuning pass followed (more HP and damage; less healing on Seraphine). Samples are small.

## Topics
- [Roster](../topics/roster.md)
- [Hero transformations](../topics/hero-transformations.md)
- [Hero arena genre](../topics/hero-arena-genre.md)
- [UI and audio direction](../topics/ui-and-audio-direction.md)
- [Assets and licensing](../topics/assets-and-licensing.md)
- [Art direction](../topics/art-direction.md)

## Open questions
- Spoken per-hero voice lines would need recorded voice acting; the packs give cries and grunts only.
- A longer balance run for the 24-hero roster.
