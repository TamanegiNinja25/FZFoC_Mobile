---
type: topic
category: Game design
sources: [2026-11-08-ui-and-audio-direction]
updated: 2026-11-08
---
# UI and audio direction

How to keep the nostalgic feel of a classic Warcraft III hero arena without its assets: rebuild the recognisable UI and sound *patterns* with original or properly licensed material. Voice work carries most of the nostalgia.

## Principle
- The originals can't be extracted: Blizzard owns the UI art, icons, voices and effects, and the map's imported clips are most likely anime recordings ([src](../sources/2026-11-08-ui-and-audio-direction.md)). See [copyright vs game mechanics](copyright-vs-game-mechanics.md).
- They can be used as **mood reference**. Style isn't protected; specific recordings, images and melodies are, so sound-alikes and traced icons still count as copies ([src](../sources/2026-11-08-ui-and-audio-direction.md)).
- People remember feelings, not files ([src](../sources/2026-11-08-ui-and-audio-direction.md)).

## UI patterns
| Classic pattern | Mobile adaptation |
|---|---|
| Heavy framed bottom panel: portrait, ability grid, 6-slot inventory | Portrait in a corner, skill-button arc by the right thumb, pull-up inventory |
| Bevelled stone or metal frames with gold trim | Same look in an original UI kit |
| Parchment tooltips with a coloured title and cost line | Long-press tooltips *(inference)* |
| Top resource bar, corner minimap, XP bar under the portrait | Kept, scaled for small screens |

Source for patterns and adaptations: ([src](../sources/2026-11-08-ui-and-audio-direction.md)).

## Audio patterns
How Fight Of Characters uses sound ([src](../sources/2026-11-08-ui-and-audio-direction.md)):
- **Ability casts:** 45 abilities each play their own short clip (0.2–6.1 s, median 0.8 s). 29 play globally and 23 positionally on the caster.
- **Select and order voices:** stock Warcraft III voice sets (22 heroes explicitly assigned).
- **Background:** default music playlist; stock city ambience for day and night.

What creates the feeling ([src](../sources/2026-11-08-ui-and-audio-direction.md)):
- Select and order voice lines — the biggest nostalgia trigger.
- Chunky UI sounds for taps, purchases and level-ups.
- Orchestral and folk music with war drums; day/night ambience.

### For an original version
- About 46 sounds for a 3-hero prototype, mostly voice work: cast shouts, select/order lines, hurt grunts ([src](../sources/2026-11-08-ui-and-audio-direction.md)).
- On phones, play your own team's casts in full and enemy casts quieter and positional, so overlapping announcements don't turn to mush ([src](../sources/2026-11-08-ui-and-audio-direction.md)).
- A transformation deserves its own big sound moment — see [hero transformations](hero-transformations.md) *(inference)*.
- A detailed per-event shopping list exists as an analyst spec: `Outputs/2026-11-08-spec-sound-events.md`.

## Sources for assets
Licences vary per item; record each in the credits file ([src](../sources/2026-11-08-ui-and-audio-direction.md)).

| Need | Where |
|---|---|
| UI kits | Kenney.nl (CC0), itch.io fantasy RPG UI packs, OpenGameArt.org |
| Fonts | Google Fonts: Cinzel, MedievalSharp, IM Fell English |
| Sound effects | Freesound.org, Sonniss GDC bundle, Kenney RPG audio |
| Music | OpenGameArt.org, Incompetech, Soundimage.org |
| Icons | game-icons.net (CC BY) |
| Voices | Own recordings, friends, or a hired voice actor |

## Related
- [Assets and licensing](assets-and-licensing.md)
- [Copyright vs game mechanics](copyright-vs-game-mechanics.md)
- [Hero transformations](hero-transformations.md)
- [Fight Of Characters](fight-of-characters.md)
