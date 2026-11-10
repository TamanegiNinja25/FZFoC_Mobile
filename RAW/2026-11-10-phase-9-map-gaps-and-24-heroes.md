---
title: Phase 9 — the reference map's remaining systems and 24 heroes (v0.9.0)
date: 2026-11-10
type: design + implementation
decided-by: owner asked to implement every gap from the second read of Fight Of Characters 7.7b E in the suggested order, then add the 24 heroes with skills, items, voice lines and per-skill sounds, and "finish it all" (phone connected for simulation); release once done
---
# Phase 9 — the reference map's remaining systems and 24 heroes

## What the second map read found (from the trigger code)
- **Scoreboard:** a per-player board of kills and deaths with team totals; leavers are marked.
- **Cast callout:** every hero cast floats "*skill name* !!" over the caster in a random colour.
- **Respawn:** heroes revive at base after 4 s.
- **Duels off:** the host can remove duels with a chat command.
- **Recall point:** a chat command saves the hero's position; a recall item teleports there.
- **Stacking:** charged items stack two to a slot.
- **Capture ball:** the creature stays the owner's; the item toggles it out and back, selling it removes it.
- **Creep rooms:** five teleport-pad pairs lead to four rooms. Entering a room spawns its units (four mixed level 5–10; two of level 15/20; ten level 10; three level 15 + two level 20), with no more than 20 of a type alive.
- **Evolution:** one hero is replaced by an evolved unit at 250 strength and 250 agility, keeping level, XP, stats and items, with four new skills.
- **Chained forms:** several heroes transform in chains of up to three stages.

## Built
- **Scoreboard, callouts and respawn:** always-on scoreboard (leaver marks synced online), cast callouts, 4 s respawn.
- **Classic and duels:**
  - Classic is first to 100 kills, no time limit, no passive gold.
  - Duels on/off: a host lobby option, or a hero-select toggle offline.
- **Chained forms:**
  - While transformed, the meter charges 6× faster; a full meter ascends a stage. Each stage resets the timer, tops up the shield, adds +20% damage, grows the hero and adds 0.5× bounty.
  - The transform button reads ASCEND.
  - Three stages: Tamsin, Pyre, Thane. Two stages: Vael, Ryn, Barrow, Morrow, Seraphine, Oren, Isolde, Halvard, Corin, Lys.
- **Creep rooms:**
  - Four walled rooms south of the field with the map's room units (original names), a cap of 20 per type, and a pad back.
  - The camera follows into rooms.
  - Bots use them too: they farm when the field is quiet and leave when a room is empty or they're hurt.
- **Evolution:** Corin becomes Corin Unbound for good at 250 STR + 250 AGI, keeping level, XP, attributes, items and skill ranks, with a new kit and look.
- **Inventory:**
  - **Satchel of Holding:** a 6-slot bag whose items give no stats (BAG button).
  - **Capture orb:** keeps its creature until it dies; bots buy and use it.
  - **MARK:** sets the recall point.
  - **Stacking:** potions, flasks and knives stack two to a slot.
- **24 heroes, six per realm:**
  - 16 new original heroes:

    | Realm | Heroes |
    |---|---|
    | Ember Forge | Pyre, Brannoc, Seraphine, Ashka |
    | Gale Peaks | Isolde, Oren, Kestrel, Thane |
    | Stone Barrows | Dunmar, Mire, Halvard, Wren |
    | Hollow Moon | Corin, Velka, Nyx, Lys |

  - Each has four skills (configurable skill types), an innate blink with a 2 s cooldown (the map's innate skills; BLINK button or Shift), a 10,000-gold signature item and a voice.
  - Bots draw from the whole roster each match (a seeded shuffle; online the host sends the seed).
- **Sound and voice:**
  - 117 skill sounds synthesised from code (`tools/skill_sounds.py`), one per skill.
  - Voices: HaelDB's yells (CC0), thebardofblasphemy's death grunts (CC0) and JeanMyna_VA's "Aha!" (CC-BY 3.0, credited), pitched per hero. Battle cry on ultimate, form, ascension, evolution and multi-kill; death cry on death.
  - Announcer: Kenney's Voiceover Pack: Fighter (CC0) for begin, "choose your character", the duel countdown, multi-kill, win/lose/tie and flawless victory.
- **Looks:**
  - KayKit bodies recoloured and re-armed per hero.
  - Six Quaternius RPG characters (CC0) for Oren, Ashka, Nyx, Velka, Corin (both forms) and Lys.
- **UI:**
  - Selected toggles glow gold (the button tint was the owner's open task; filled in at their request to finish everything).
  - The hero cards scroll.
  - BLINK sits in the free corner under pause.
- **Fixes:**
  - Sky-falling bolts no longer trigger a look_at error.
  - The pacing test accepts a match won before the first duel.

## Balance (24 all-bot Mobile matches, 3–10 games per hero)
- Most heroes landed between 25% and 75%.
- **Outliers** (wins / games):

  | Hero | Win rate | Note |
  |---|---|---|
  | Mire | 0 / 7 | |
  | Wren | 0 / 5 | |
  | Ashka | 1 / 7 | |
  | Lys | 1 / 6 | 9.5 deaths per minute |
  | Kestrel | 1 / 4 | 10 deaths per minute |
  | Seraphine | 5 / 7 | |

- **Tuning pass:**
  - Mire, Wren, Ashka, Lys, Kestrel and Isolde gained HP (+100 to +130) and damage on their main skill; Mire calls three bog spawn.
  - Seraphine's Radiant Cut heals for a third instead of half.
- Samples are small: a longer run is recommended.

## Results
- All 13 headless suites and the two-process network test pass.
- Phone (Infinix NOTE 30): a 4v4 Classic match with up to 424 units ran at 42–58 FPS (average 49.6) with no script errors.
- Debug APK: 48.5 MB.

## Not done
- Spoken per-hero dialogue: the free packs give battle cries and grunts, not lines; real lines need recorded voice acting.
