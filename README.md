# FrozenThrone: Fight Of The Characters (FZFoC)

An original mobile hero arena for Android, inspired by the gameplay of **Fight Of Characters**, a Warcraft III: The Frozen Throne custom map. Pick a hero, fight 3v3, buy items, and fill your meter to **transform mid-fight**.

[![Download APK](https://img.shields.io/badge/Download-FZFoC.apk-e8a33d?style=for-the-badge&logo=android&logoColor=white)](https://github.com/TamanegiNinja25/FrozenThrone_FightOfTheCharacters/releases/latest/download/FZFoC.apk)
[![Latest release](https://img.shields.io/github/v/release/TamanegiNinja25/FrozenThrone_FightOfTheCharacters?style=for-the-badge&label=latest)](https://github.com/TamanegiNinja25/FrozenThrone_FightOfTheCharacters/releases/latest)

> **Status: playable alpha (v0.8.2).** Eight build phases are done:
> - menus, 3v3 against adaptive AI, item shop, local Wi-Fi multiplayer;
> - the reference map's systems: levels, ranked skills, the duel, creep waves, bosses, recipes, modes;
> - Phase 7: eight heroes, physical creeps with map-style pile-ups, damage numbers, Classic as the original's 4v4 with unique picks, joining by address;
> - Phase 8: rigged, animated heroes and skeleton summons, castles and mountain scenery, pack sounds and music, skinned menus and a Credits screen. All third-party assets are CC0 and credited.
>
> Phone: a 4v4 Classic match with up to 436 units runs at 42–56 FPS (average 47) on the test phone. Balance is still being tuned.

## Download and install

1. On your Android phone (Android 7 or newer, 64-bit), tap **[Download FZFoC.apk](https://github.com/TamanegiNinja25/FrozenThrone_FightOfTheCharacters/releases/latest/download/FZFoC.apk)**. The link always points to the newest release.
2. Open the downloaded file. If Android asks, allow installs from your browser or file manager ("Install unknown apps").
3. Launch **FZFoC**.

**Updates:** when a new version is released, the main menu shows an **Update available** button that opens the [latest release](https://github.com/TamanegiNinja25/FrozenThrone_FightOfTheCharacters/releases/latest). Download and install it over the old version; your settings are kept.

All releases and their notes are on the [Releases page](https://github.com/TamanegiNinja25/FrozenThrone_FightOfTheCharacters/releases).

## What's in the game

| | |
|---|---|
| **Modes** | Single player against bots · Play with friends over local Wi-Fi (Versus or Co-op, up to 8 players) · Training ground |
| **Rules** | **Mobile:** 3v3, first to 15 kills or the leader after 8:00 · **Classic:** the original's 4v4, first to 50 kills, no time limit, every hero picked once · Either way, killing the 100,000 HP win boss wins |
| **Progression** | Levels 1–50 on Warcraft III's XP curve, shared kill XP · strength / agility / intelligence that grow each level · 4 skills per hero, ranked up with skill points |
| **World events** | A **duel** every ~5 min (one random hero per team, everyone else frozen, winner earns level × 200 gold) · **creep waves** at 12 camps every 30 / 60 / 90 s that pile up like the map's (creeps are physical units) · two **boss chains** · the **win boss** |
| **Feel** | Animated heroes and creeps, skill effects, floating damage numbers, damage totals, skill icons |
| **Heroes** | Vael, the Kiln Knight (Bruiser) · Ryn, the Gale Dancer (Speed) · Barrow, the Living Cairn (Giant) |
| **Transformation** | A meter filled by fighting (~90 s); a timed form with a shield and an upgraded skill. A transformed hero is worth more bounty |
| **Economy** | Passive gold, kill gold, and kill-spree bonuses |
| **Shop** | 45 original items in 8 categories: Weapons, Armor, Mobility, Relics, Consumables (incl. recall scroll, throwing knives, shadow cloak, capture orb), a **stat shop**, **exclusive** items (one per hero) and **artifacts** from 7 recipes at a combining circle · 6 slots, buy at your fountain |
| **AI** | Bots use the same controls as you; their decision skill adapts to the score, but their stats never change |
| **Multiplayer** | Host-authoritative over local Wi-Fi: no servers, no accounts. Find games automatically, or type the host's address (shown on its screen; your network's prefix is pre-filled) |
| **Controls** | Floating touch joystick · a big ATTACK button with the four skills on an arc around it · a **+** badge on a skill when you can rank it up · TRANSFORM button |
| **Settings** | Audio volumes, 3D resolution, shadows, FPS cap, FPS counter |

### Heroes

| Hero | Role | Skills | Ultimate | Transformation |
|---|---|---|---|---|
| **Vael, the Kiln Knight** · Ember Forge | Bruiser (strength) | Bellows Slam (area hit), Ember Dash, Searing Brand (stun) | Forge Golem (summon) | **Kindled**: Bellows Slam becomes Eruption |
| **Ryn, the Gale Dancer** · Gale Peaks | Speed (agility) | Cyclone Cut (dash that slices its path), Flurry (attack-speed burst), Razor Wind (bleed) | Thousand Cuts (untouchable strikes) | **Tempest**: faster; Cyclone Cut becomes Tempest Cut |
| **Barrow, the Living Cairn** · Stone Barrows | Giant (strength) | Quake Stomp (area hit + slow), Boulder Hurl (projectile), Stone Grip (root) | Rockfall (channelled blast + stun) | **Avalanche**: huge, shielded; wider stomp and stronger slow |
| **Sable, the Ashen Archer** · Ember Forge | Ranged (agility) | Splinter Volley, Pinning Shot (stun), Ember Rain (zone) | Sunpiercer (piercing shot) | **Ashfall** |
| **Morrow, the Grave Tender** · Stone Barrows | Caster (intelligence) | Wisp Swarm (summons), Life Drain, Withering Curse | Barrow Rising (4 guardians) | **Lichbloom** |
| **Kael, the Hollow Blade** · Hollow Moon | Bruiser (agility) | Crescent Slash, Flash Step (blink), Severing Edge | Moonless Rend (wide wave) | **Hollowed**, also on its own below 10% HP |
| **Tamsin, the Storm Caller** · Gale Peaks | Caster (intelligence) | Arc Discharge (stun), Thunder Lance, Static Field | Skyfall Wrath (5 bolts) | **Stormcrown** |
| **Hask, the Iron Warden** · Hollow Moon | Giant (strength) | Shield Bash (stun), Iron Bulwark (guard), Chain Hook (pull) | Fortress (knockback slam) | **Unbreakable** |

Every character, model, icon, sound and music track is original. Models are built from code, and icons and audio are synthesised by [`tools/generate_assets.py`](Prototype/tools/generate_assets.py). Nothing is taken from the map, from Blizzard, or from any other game. Game *mechanics* are free to reuse; their *expression* is not ([Copyright vs game mechanics](Wiki/topics/copyright-vs-game-mechanics.md)).

### Performance

Tested on an **Infinix NOTE 30** (Helio G99, Mali-G57): a locked **60 FPS** in a full 3v3 with mixed heroes, about 10 ms GPU per frame at the default 90% resolution and 2 shadow cascades.

## Build from source

The game is a **Godot 4.7.2** project in [`Prototype/`](Prototype/README.md). Open `Prototype/project.godot` and press F5. That README covers the systems, Android export, 13 headless test suites, a two-process network test and the balance simulation.

### Releasing a new version

Releases are built in the cloud by [`.github/workflows/release.yml`](.github/workflows/release.yml):

```bash
git tag v0.6.0
git push origin v0.6.0
```

The workflow exports the APK with Godot and publishes a GitHub Release with `FZFoC.apk` attached. The tag sets the version shown in the menu, the Android version code and the version the update check compares against. The download link above then serves the new APK automatically.

For releases to install as **updates** instead of conflicting with the installed app, they must all be signed with the same key. Add the repository secret `DEBUG_KEYSTORE_BASE64`, a base64-encoded debug keystore, under **Settings → Secrets and variables → Actions**. Without it, each release is signed with a throwaway key.

## Knowledge base

The research and design behind the game are kept as a self-maintaining markdown wiki, modelled on Andrej Karpathy's "LLM Knowledge Bases" workflow and run with Claude Code acting as librarian.

```
├── CLAUDE.md   librarian instructions: rules, workflows, modes
├── RAW/        source material (added by hand, never edited)
├── Wiki/       compiled wiki, maintained by the librarian
│   ├── index.md     start here — every page with a one-line summary
│   ├── log.md       change history
│   ├── backlog.md   open questions, gaps, wanted sources
│   ├── sources/     one summary note per RAW file
│   └── topics/      concept articles, every claim cited
├── Outputs/    reports, templates and other derived work
└── Prototype/  the Godot game
```

**Start reading at [Wiki/index.md](Wiki/index.md).** Workflow details are in [CLAUDE.md](CLAUDE.md).

## Roadmap

- [x] Research: map analysis, mobile feasibility, asset licensing, engine choice (**Godot 4.7**)
- [x] Transformation design: **charge meter**, ~90 s fill, aggression rewarded, risk/reward bounty
- [x] Visual style: **high-poly stylized, toon shaded** ([art direction](Wiki/topics/art-direction.md)); phone stress test at 60 FPS
- [x] Touch controls: floating joystick, 90% render resolution
- [x] Phase 1: main menu, settings, hero select by category, pause menu, UI polish, original app icon and sounds
- [x] Phase 2: single player 3v3 vs adaptive AI on an original arena map
- [x] Phase 3: item shop with categories (13 items)
- [x] Phase 4: play with friends over local Wi-Fi (verified phone ↔ laptop)
- [x] Phase 5: heroes Ryn and Barrow, generated music ([roster](Wiki/topics/roster.md))
- [x] Downloadable releases with an in-game update notice
- [x] Phase 6: the reference map's systems — levels and attributes, ranked skills (+2 per hero), duel, creep waves, boss chains, win boss, stat shop, exclusive items, recipes, Mobile and Classic modes ([fidelity audit](Outputs/2026-11-08-foc-fidelity-audit.md))
- [x] Release v0.6.0
- [x] Phone check for Phase 6: no issues, performance stable with high creep counts
- [x] Phase 7: hero and creep animation, skill effects and icons, damage numbers, physical creeps with map-style pile-ups
- [x] Phase 7: five more heroes (8), utility and exclusive items, balance pass, Classic as the original's 4v4 with unique picks and the leaver rule
- [x] Phase 7: joining by address on the same Wi-Fi (shown address, pre-filled prefix, remembered host, clear timeout)
- [ ] Releases signed with one key (repository secret `DEBUG_KEYSTORE_BASE64`) so updates install over each other
- [ ] Sculpted hero models to replace the primitive ones

Open decisions live in [Wiki/backlog.md](Wiki/backlog.md).

## Assets

Third-party assets (e.g. free Sketchfab models) may only be used under licences that allow it, and each must be recorded in a credits file. See [Assets and licensing](Wiki/topics/assets-and-licensing.md) and the [credits template](Outputs/2026-11-08-asset-credits-template.md). The current build uses none. Warcraft III game files and map files are never committed (`.gitignore` blocks them).

## Disclaimer

This is an independent fan project. It is not affiliated with or endorsed by Blizzard Entertainment, the authors of Fight Of Characters, or the owners of any franchise mentioned in the research notes. Warcraft and The Frozen Throne are trademarks of Blizzard Entertainment, Inc.; other names belong to their respective owners and are referenced for research purposes only.

## License

[MIT](LICENSE) covers this repository's own content. Third-party assets keep their own licences, listed in the credits file.
