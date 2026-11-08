---
type: topic
category: Legal and IP
sources: [2026-11-08-sketchfab-assets-and-local-multiplayer]
updated: 2026-11-08
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
- Keep characters around 5–20k polygons for phones; simplify in Blender if needed ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)).
- Choose 1–2 visual styles before downloading, or the game will look stitched together ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)).
- Track every asset in a credits file from day one; CC BY requires attribution ([src](../sources/2026-11-08-sketchfab-assets-and-local-multiplayer.md)). A ready-made template: `Outputs/2026-11-08-asset-credits-template.md`.
- Save a screenshot of each licence in case the page changes *(inference)*.

## Related
- [Copyright vs game mechanics](copyright-vs-game-mechanics.md)
- [UI and audio direction](ui-and-audio-direction.md) — sources for UI kits, fonts, sound and music
- [Hero arena genre](hero-arena-genre.md)
- [Fight Of Characters](fight-of-characters.md) — the map whose characters can't be reused
