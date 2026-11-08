---
title: UI and audio direction — keeping the nostalgic feel without the original assets
date: 2026-11-08
context: The user asked whether the UI and sounds could be taken from the Fight Of Characters map or Warcraft III, or whether close sources could keep the game's nostalgic vibe. Includes findings from a sound-event analysis of the map run the same day.
---

# UI and audio direction

**Summary:** The map's UI and audio can't be extracted. Blizzard owns the UI art, icons, voices and sound effects, and the imported clips are most likely taken from anime. The nostalgia comes from recognisable patterns, which can be rebuilt with original or properly licensed assets.

## 1. Why the original assets can't be used

| What's in the map | Owner | Usable? |
|---|---|---|
| UI frames, fonts, cursors, most icons | Blizzard (Warcraft III) | No — Blizzard's licence forbids extracting or redistributing them |
| 80 imported icons | Mostly Blizzard icons reused by the map | No |
| 60 imported MP3 clips | Most likely anime voice and effect clips | No — copyrighted recordings |
| Unit voices and sound effects | Blizzard | No |

- The project repository is public, so anything extracted would be published.
- Listening to and looking at the originals as **mood reference** is fine. Copyright covers specific recordings, images and melodies, not a general style.
- A sound-alike is still a copy: briefing a composer on a style ("fantasy RTS, war drums") is fine; matching a specific melody, or tracing an icon, is not.

## 2. Where the nostalgia comes from

### UI patterns
- Heavy framed bottom panel: hero portrait, ability-button grid, 6-slot inventory.
- Bevelled stone or metal frames with gold trim; parchment-style tooltips with a coloured title and cost line.
- Top resource bar, corner minimap, XP bar under the portrait.
- Mobile adaptation: portrait in a corner, skill-button arc by the right thumb, inventory you pull up when needed.

### Audio patterns
- Short voice lines when a hero is selected or ordered — the single biggest nostalgia trigger. Write and record your own.
- Chunky, satisfying sounds for clicks, coin purchases and level-ups.
- Orchestral and folk music with heavy percussion; day and night ambient loops.

People remember feelings, not files: rebuilding the experience with new assets keeps most of the nostalgia.

## 3. Legitimate sources with a similar feel
Licences vary per item; check each one and record it in the credits file.

| Need | Sources |
|---|---|
| UI kits | Kenney.nl (CC0 UI packs), itch.io fantasy RPG UI packs, OpenGameArt.org |
| Fonts | Google Fonts: Cinzel, MedievalSharp, IM Fell English |
| Sound effects | Freesound.org (CC0 and CC BY), Sonniss yearly free GDC bundle (royalty-free), Kenney RPG audio |
| Music | OpenGameArt.org, Incompetech (Kevin MacLeod, CC BY), Soundimage.org (Eric Matyas, credit required) |
| Icons | game-icons.net (CC BY) |
| Voice lines | Record your own or with friends, or hire a voice actor for a small set |

## 4. Findings from the sound-event analysis (same day)
- **Correction:** the map's 60 imported MP3s are **short clips of 0.2–6.1 seconds (median 0.8 s)**, not music tracks. They are ability shouts and stings, plus a few hurt sounds.
- 45 abilities play their own clip when cast; no clip is shared between abilities. 29 play globally (everyone hears them) and 23 play positionally on the caster.
- Hero select and order voices come from Warcraft III's stock voice sets (22 heroes explicitly assigned). Music is the game's default playlist; ambience is a stock city day/night loop.
- An original version needs about 46 sounds for a 3-hero prototype. Voice work (cast shouts, select/order lines, hurt grunts) carries most of the nostalgia.
- On phones, play your own team's casts in full and enemy casts quieter and positional, to avoid overlapping announcements.
