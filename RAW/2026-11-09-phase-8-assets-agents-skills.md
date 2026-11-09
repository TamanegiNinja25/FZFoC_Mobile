---
title: Phase 8 — free CC0 assets, game-dev agents and skills
date: 2026-11-09
type: design + implementation
decided-by: owner asked to adopt the agents and skills from Claude-Code-Game-Studios and awesome-gamedev-agent-skills, to download free assets from itch.io's free 3D tags (characters, backgrounds, sound effects, music, user interface, sprites, tilesets, icons) for character visuals, background towers, skill and attack sounds, menu and battle music, game UI, summons and monsters, prefabs and skill icons — "only applicable and credit the creator" — and to continue improving the game
---
# Phase 8 — free CC0 assets, game-dev agents and skills

## Agents and skills
- **14 agents** adopted from *Claude Code Game Studios* (Donchitos, MIT): godot-specialist, godot-gdscript-specialist, godot-shader-specialist, game-designer, systems-designer, economy-designer, technical-artist, art-director, sound-designer, ux-designer, performance-analyst, qa-lead, network-programmer, ai-programmer. Each got a "This project — read first" preamble: project facts and paths, original work only, third-party assets credited in `Prototype/assets/thirdparty/CREDITS.md`, proof = headless suites plus phone PERF readings, version control per CLAUDE.md. The studio's own skills weren't adopted: they run shell hooks and assume its directory layout.
- **23 skills** copied verbatim from *awesome-gamedev-agent-skills* (Apache-2.0, LICENSE and NOTICE kept): 13 Godot skills (GDScript, 3D, animation, audio, export, headless testing, multiplayer, physics, resources, shaders, signals/groups, UI controls, nodes/scenes) and 10 general ones (game feel, performance, asset creation, audio design, game UI/UX, game AI, behaviour trees / utility AI, cameras, physics tuning, level design).

## Sourcing assets
- itch.io pages sit behind a bot check (Cloudflare "verify you are human"), which Claude won't pass. So assets came from the **same creators' official GitHub repositories and OpenGameArt mirrors**. Every file was checked to be **CC0** before download, and each pack's licence file was kept beside it.
- **Applicable only:** low-poly and toon packs that fit the stylized look. No sprite sheets (2D sprites don't fit a 3D arena), and no icon packs: the original generated skill icons already cover every skill and match.

| Need | Asset (creator, CC0) | Used for |
|---|---|---|
| Characters | KayKit Adventurers 1.0 and Skeletons 1.0 (Kay Lousberg) | Seven of eight heroes get rigged, animated models; Barrow-Dead summons become skeleton warriors that rise from the ground |
| Backgrounds and tilesets | KayKit Medieval Hexagon Pack 1.0 (Kay Lousberg) | A castle and towers behind each base, team banners, camp props, mountains, hills and forest outside the walls, trees around the duel arena |
| Sound effects | Kenney: 50 RPG Sound Effects, Interface Sounds | Attack hits (three variants), dash, coins on buy/sell, error, menu click/confirm/back |
| Music | cynicmusic: Town Theme RPG, Battle Theme A | Menu and battle music |
| User interface | Kenney: UI Pack RPG Extension | 9-slice button and panel skins tinted to the stone-and-gold palette |

## Implementation
- **RiggedModel** wraps a KayKit character behind the primitive models' interface. It shows only the weapons the hero carries and attaches separate weapon models to empty skeleton hands. It loops Idle/Running at a speed matched to movement, and plays attack, cast, hit, death and spawn clips. HeroAnimator plays clips for rigged models instead of posing them procedurally.
- Hero looks:

  | Hero | Model | Weapons |
  |---|---|---|
  | Vael | Knight | sword and round shield; his text changes from hammer to sword |
  | Ryn | hooded Rogue | twin knives |
  | Sable | Rogue | crossbow |
  | Tamsin | Mage | staff |
  | Morrow | skeleton Mage | staff |
  | Kael | skeleton Rogue | blade |
  | Hask | Barbarian | axe and shield |
  | Barrow | stays a primitive stone giant | — |

- `tools/glb_strip.py` trims each character to the 14–18 animations the game plays: about 1–1.3 MB per model instead of about 4 MB.
- **Scenery** merges every scenery piece into one mesh, since all KayKit medieval pieces share one texture: one draw call. It has no collision, is placed deterministically (seeded) so all players see the same map, and mountains are sunk so their hex bases don't show.
- **Sfx** maps each sound to variants picked at random. The generated sounds stay as fallbacks for anything without a fitting pack sound (slam, transform, kill, victory, defeat, level-up, duel). Music plays the MP3s with looping and falls back to the generated WAVs.
- **Credits** screen in the main menu lists every creator, work, licence and use; `assets/thirdparty/CREDITS.md` mirrors it.

## Results
- All 13 headless suites and the two-process network test pass.
- Debug APK: 40 MB. Assets add about 17 MB (character GLBs about 10 MB, music 4.4 MB).
- Phone check pending: the phone was locked during the session.
