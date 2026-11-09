---
type: source
raw: ../../RAW/2026-11-09-phase-8-assets-agents-skills.md
added: 2026-11-09
why: Owner asked to adopt game-dev agents and skills, download applicable free assets for characters, scenery, sounds, music and UI, and credit every creator.
---
# Phase 8 — free CC0 assets, game-dev agents and skills
Record of Phase 8:
- 14 agents (MIT) and 23 skills (Apache-2.0) adopted for game work.
- CC0 assets by Kay Lousberg (KayKit), Kenney and cynicmusic give seven heroes rigged models, add skeleton summons, scenery around the arena, pack sounds, music and skinned menus.
- An in-game Credits screen names every creator.
- itch.io's bot check meant the assets came from the creators' GitHub and OpenGameArt copies.

## Key points
- **Agents and skills:**
  - The agents come from Claude Code Game Studios, each with a project preamble.
  - The skills come from awesome-gamedev-agent-skills, with LICENSE and NOTICE kept.
  - The studio's own skills were skipped: they run shell hooks.
- **Applicable only:**
  - Low-poly and toon 3D packs that match the stylized look.
  - No 2D sprites and no icon packs; the original skill icons stay.
- **Heroes and summons:**
  - Seven heroes use KayKit characters; Barrow stays a primitive stone giant.
  - Barrow-Dead summons are skeleton warriors that rise from the ground.
  - Vael carries a sword now, not a hammer.
- **Scenery:** a castle, towers and banners per base, camp props, mountains and forest outside the walls, all merged into a single draw call.
- **Audio:**
  - Pack sounds have random variants; generated sounds remain where no pack sound fits.
  - MP3 menu and battle music loop.
- **UI:** Kenney 9-slice skins tinted toward the stone-and-gold palette.
- **Size:** animations trimmed with `glb_strip.py`; the APK is 40 MB.
- **Results:** all tests pass; the phone check is pending.

## Topics
- [Assets and licensing](../topics/assets-and-licensing.md)
- [Art direction](../topics/art-direction.md)
- [UI and audio direction](../topics/ui-and-audio-direction.md)
- [Roster](../topics/roster.md)

## Open questions
- Phone frame rate with rigged heroes and the scenery mesh.
- Whether selected toggle buttons stand out enough on the tinted skin.
- Whether sound effects for skills (slam, transform) should come from a pack too.
