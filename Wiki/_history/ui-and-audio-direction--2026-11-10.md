---
type: topic
category: Game design
sources: [2026-11-08-ui-and-audio-direction, 2026-11-08-game-build-plan-and-phase-1, 2026-11-08-ui-polish-and-phase-2, 2026-11-08-phase-5-heroes-and-music, 2026-11-09-phase-8-assets-agents-skills]
updated: 2026-11-09
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

## Menus in the prototype
Phase 1 of the game build put the UI direction into practice ([src](../sources/2026-11-08-game-build-plan-and-phase-1.md)):
- **Main menu:** Single Player · Play with Friends · Settings · Quit on a stone panel with gold trim and parchment text, over Kindled Vael in an ember-lit scene — the classic fantasy-RTS feel, built from scratch, not a replica of any game's UI.
- **Hero select by category** (Bruiser / Speed / Giant) with locked planned slots and a scrolling detail panel.
- **Settings** (audio buses; 3D resolution, shadows, FPS cap) in the main menu and in game; **pause menu** with Resume · Settings · Quit to Menu · Quit Game.
- **Polish:** safe-area insets for the camera cutout, a stone backing behind HUD text, slide/pulse/pop-in animations, press feedback on every button, and ten **original sounds synthesised from code** (click, confirm, back, hit, slam, dash, transform, kill, victory, defeat). The app icon is an original hammer-and-slash emblem. A generator script rebuilds the icon and sounds, documenting their originality ([src](../sources/2026-11-08-ui-polish-and-phase-2.md)).
- **Music (Phase 5):** an original slow minor menu theme with bells and a 110 BPM war-drum battle loop, generated from code and played on the Music bus — the orchestral, folk-with-drums direction above, made without any existing recording ([src](../sources/2026-11-08-phase-5-heroes-and-music.md)).
- **Phase 8 pack assets:**
  - Buttons and menu panels use Kenney's RPG UI pack as 9-slice skins, tinted toward the stone-and-gold palette ([src](../sources/2026-11-09-phase-8-assets-agents-skills.md)).
  - Sounds come from Kenney packs with random variants: three hit sounds, dash, coins on buy and sell, error, and menu click/confirm/back ([src](../sources/2026-11-09-phase-8-assets-agents-skills.md)).
  - Menu and battle music are cynicmusic's CC0 themes ([src](../sources/2026-11-09-phase-8-assets-agents-skills.md)).
  - The generated sounds stay for slam, transform, kill, victory, defeat, level-up and duel, and as fallbacks ([src](../sources/2026-11-09-phase-8-assets-agents-skills.md)).
- **Credits screen** in the main menu lists every creator, work, licence and use ([src](../sources/2026-11-09-phase-8-assets-agents-skills.md)).
- A phone check caught hero-select text pushing buttons off screen; detail text now scrolls in a fixed box — long text needs a fixed area on phones *(inference)*.

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
- [Art direction](art-direction.md) — the high-poly stylized look the UI should match
- [Assets and licensing](assets-and-licensing.md)
- [Copyright vs game mechanics](copyright-vs-game-mechanics.md)
- [Hero transformations](hero-transformations.md)
- [Fight Of Characters](fight-of-characters.md)
