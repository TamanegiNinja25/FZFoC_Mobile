---
title: Using free Sketchfab assets and local multiplayer for an offline hero arena game
date: 2026-11-08
context: Follow-up to the Fight Of Characters mobile feasibility analysis. The user has a Sketchfab account with free downloadable resources and plans an offline project, possibly with local play among friends.
---

# Using free Sketchfab assets and local multiplayer for an offline hero arena game

**Summary:** Free Sketchfab models can be used, but each model carries its own licence, and "free to download" is not "free for any use." Fan-made models of existing characters can't grant rights to those characters. Environments and original characters are the safest and most useful assets. Local multiplayer removes the need for servers.

## 1. Sketchfab licences are per model

Each downloadable model shows its licence on its page.

| Licence | Usable in the game? | Condition |
|---|---|---|
| CC0 (public domain) | Yes | None |
| CC BY | Yes | Credit the creator |
| CC BY-SA | Yes | Credit; share changes under the same licence |
| CC BY-NC | Yes, if never sold | Non-commercial only |
| CC BY-ND | Usually no | No derivatives: rigging, retexturing or reducing polygons counts as modifying |
| Editorial | No | News and editorial use only, not games |

## 2. Fan-made character models

- Many free character models are fan art of existing franchises (e.g. Goku, Naruto).
- The uploader can only license their own modelling work, not the character, which still belongs to its owner (e.g. Toei, Shueisha). A CC tag on a fan model does not make the character legal to use.
- Private, offline use among friends carries very low practical risk, similar to Warcraft III modding. Publishing or sharing publicly, even for free, brings back the copyright problem.
- Recommended: build with an original cast.

## 3. Best uses of Sketchfab for this project

- **Arenas and environments:** terrain, ruins, rocks, buildings, props — the safest and most useful category; CC0/CC BY packs are plentiful.
- **Original characters:** stylised warriors, monsters and creatures that are not fan art.
- **Reference:** studying designs to inform original characters.

## 4. Technical notes

- **Formats:** prefer glTF/GLB; Godot and Unity import it directly.
- **Rigging and animation:** many models are static. Look for "rigged"/"animated", or rig with Mixamo (free) — only if the licence allows modification.
- **Performance:** showcase models may have hundreds of thousands of polygons; phones want roughly 5–20k per character. Filter by polygon count or simplify in Blender.
- **Art consistency:** assets from many creators mix styles, polygon counts and texture setups. Pick 1–2 visual styles (e.g. low-poly stylised) before downloading.
- **Credits:** keep a credits file from day one (model, creator, link, licence). CC BY requires attribution.

## 5. Local multiplayer

- **Godot:** built-in high-level multiplayer (ENet) works over local Wi-Fi; one phone hosts, others join.
- **Unity:** Netcode for GameObjects with Unity Transport supports direct local connections.
- No Photon, Nakama, servers, accounts or monthly costs are needed. Devices can discover each other with a UDP broadcast on the local network.
