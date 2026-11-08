---
type: source
raw: ../../RAW/2026-11-08-sketchfab-assets-and-local-multiplayer.md
added: 2026-11-08
why: The user has a Sketchfab account with free resources and wants to know if they can supply characters, models and arenas for an offline hero arena game with local play among friends.
---
# Using free Sketchfab assets and local multiplayer

Free Sketchfab models are usable, but each has its own licence and "free to download" isn't "free for any use"; fan-made models of existing characters can't grant rights to those characters. Environments and original characters are the best fit, and local multiplayer removes the need for servers.

## Key points
- **Per-model licences:** CC0 (no conditions), CC BY (credit), CC BY-SA (credit, share changes alike), CC BY-NC (never sell), CC BY-ND (no modifications — rigging, retexturing and polygon reduction count), Editorial (not for games).
- **Fan art:** uploaders license only their modelling work, not the character; a CC tag on a fan-made Goku doesn't make Goku usable. Private offline use is low practical risk; public sharing, even free, is not. An original cast is recommended.
- **Best uses:** arenas and environments (safest, most plentiful), original characters, and reference for original designs.
- **Technical:** prefer glTF/GLB; many models need rigging (Mixamo, if the licence allows changes); phones want ~5–20k polygons per character; pick 1–2 visual styles to keep the game consistent.
- **Credits:** keep a credits file from day one; CC BY requires attribution.
- **Local multiplayer:** Godot's built-in multiplayer (ENet) or Unity's Netcode for GameObjects + Unity Transport work over local Wi-Fi with one phone hosting; no servers, accounts or monthly costs; UDP broadcast for discovery.

## Topics
- [Assets and licensing](../topics/assets-and-licensing.md)
- [Hero arena genre](../topics/hero-arena-genre.md#local-multiplayer)
- [Copyright vs game mechanics](../topics/copyright-vs-game-mechanics.md)

## Open questions
- Which 1–2 visual styles should the game commit to?
- Godot or Unity for the project?
