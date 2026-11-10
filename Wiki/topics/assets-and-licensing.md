---
type: topic
category: Legal and IP
sources: [2026-11-08-sketchfab-assets-and-local-multiplayer, 2026-11-08-decision-visual-style, 2026-11-09-phase-8-assets-agents-skills, 2026-11-10-phase-9-map-gaps-and-24-heroes]
updated: 2026-11-10
---
# Assets and licensing

Free 3D assets (e.g. from Sketchfab) carry per-asset licences that decide whether you can use, modify, credit-free or sell them. A licence covers the creator's own work only — never a character owned by someone else.

## Licence types
| Licence | Usable in a game? | Condition |
|---|---|---|
| CC0 | Yes | None |
| CC BY | Yes | Credit the creator |
| CC BY-SA | Yes | Credit; share changes under the same licence |
| CC BY-NC | Yes, if never sold | Non-commercial only |
| CC BY-ND | Usually no | No modifications — rigging, retexturing and polygon reduction all count |
| Editorial | No | News and editorial use only |

Each Sketchfab model shows its own licence on its page ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)).

## Fan-made characters
- An uploader can license only their modelling work, not the character it depicts; a CC-tagged fan model of an existing character doesn't make that character usable ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)). This is the asset-level version of [copyright vs game mechanics](copyright-vs-game-mechanics.md).
- Private offline use among friends is low practical risk; public sharing, even free, is not ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)).

## What to use free assets for
- **Arenas and environments** — the safest and most plentiful category ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)).
- **Original characters and creatures** that aren't fan art ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)).
- **Reference** for designing an original cast ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)).

## Practical checklist
- Prefer glTF/GLB; Godot and Unity import it directly ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)).
- Static models need rigging (e.g. Mixamo) — only if the licence allows modification ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)).
- ~~Keep characters around 5–20k polygons for phones~~ ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)) — **superseded 2026-11-08** by the high-poly stylized decision: heroes 30–50k triangles with LODs, checked by a device stress test ([src](../sources/2026-11-08-decision-visual-style.md)). See [Art direction](art-direction.md#phone-performance-budget). Simplify in Blender or bake normal maps when a model is over budget.
- Choose 1–2 visual styles before downloading, or the game will look stitched together ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)). Chosen: high-poly stylized ([src](../sources/2026-11-08-decision-visual-style.md)).
- Track every asset in a credits file from day one; CC BY requires attribution ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)). A ready-made template: `Outputs/2026-11-08-asset-credits-template.md`.
- Save a screenshot of each licence in case the page changes *(inference)*.

## In practice: the Phase 8 asset pass
- **What was taken:** CC0 packs only, from creators whose licence files ship with each pack, all credited ([src](../sources/2026-11-09-phase-8-assets-agents-skills.md)):
  - Kay Lousberg: KayKit Adventurers, Skeletons and Medieval Hexagon;
  - Kenney: RPG sounds, interface sounds and the RPG UI pack;
  - cynicmusic: menu and battle themes.
- **Where:**
  - itch.io hides pages behind a bot check, so files came from each creator's official GitHub repository or OpenGameArt copy, after checking the licence there ([src](../sources/2026-11-09-phase-8-assets-agents-skills.md)).
  - Passing a bot check is the owner's job, not the assistant's *(inference)*.
- **Only applicable assets:**
  - 2D sprite sheets were skipped (the game is 3D), and so were icon packs (the original skill icons already fit) ([src](../sources/2026-11-09-phase-8-assets-agents-skills.md)).
  - "Choose 1–2 styles" held: everything is low-poly or toon, from one 3D creator plus one UI and sound creator *(inference)*.
- **Credit lives in two places:**
  - `Prototype/assets/thirdparty/CREDITS.md` gives creator, licence, source and use for each pack.
  - An in-game Credits screen names the same creators ([src](../sources/2026-11-09-phase-8-assets-agents-skills.md)).
  - CC0 doesn't require credit; the owner asked for it anyway.
- **Agent and skill licences:**
  - The adopted agents are MIT, and their licence is kept beside them.
  - The skills are Apache-2.0, which requires keeping the NOTICE file; it sits in `.claude/skills/` ([src](../sources/2026-11-09-phase-8-assets-agents-skills.md)).

## Phase 9 additions
- **Voices:**
  - Kenney's Voiceover Pack: Fighter (announcer), HaelDB's yells and thebardofblasphemy's death grunts are CC0 ([src](../sources/2026-11-10-phase-9-map-gaps-and-24-heroes.md)).
  - JeanMyna_VA's "Aha!" pack is **CC-BY 3.0**: the first asset that requires credit. It is credited in `CREDITS.md`, in its pack folder and on the Credits screen as "Voice: JeanMyna_VA (CC-BY 3.0)" ([src](../sources/2026-11-10-phase-9-map-gaps-and-24-heroes.md)).
- **Characters:** Quaternius's RPG Characters (CC0) add six bodies ([src](../sources/2026-11-10-phase-9-map-gaps-and-24-heroes.md)).
- **Licence check before download:** licence and author were read from each pack's own page before downloading; licence files sit beside each pack ([src](../sources/2026-11-10-phase-9-map-gaps-and-24-heroes.md)).

## Related
- [Copyright vs game mechanics](copyright-vs-game-mechanics.md)
- [Art direction](art-direction.md) — the chosen style and its polygon budget
- [UI and audio direction](ui-and-audio-direction.md) — sources for UI kits, fonts, sound and music
- [Hero arena genre](hero-arena-genre.md)
- [Fight Of Characters](fight-of-characters.md) — the map whose characters can't be reused
