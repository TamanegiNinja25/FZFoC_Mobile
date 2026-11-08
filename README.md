# FZFoC Mobile

An original mobile hero arena game inspired by the gameplay of **Fight Of Characters**, a Warcraft III: The Frozen Throne custom map.

> **Status: research.** This repo currently holds the project's knowledge base — the research, design notes and decisions that will guide the game. No game code yet.

## The idea

Fight Of Characters is a 4v4 hero arena where players pick a hero, buy items and fight until one team wins on kills. Its standout mechanic is **mid-fight hero transformations**. This project takes those *mechanics* to phones with:

- **An original cast.** No characters, art, music or code from the map, from Blizzard or from any anime franchise. Game rules and mechanics are free to reuse; their expression is not — see [Copyright vs game mechanics](Wiki/topics/copyright-vs-game-mechanics.md).
- **Mobile-first design.** 3v3, 5–8 minute matches, virtual joystick plus skill buttons.
- **Offline play with friends.** Local Wi-Fi multiplayer; no servers or accounts.

## Knowledge base

The research is kept as a self-maintaining markdown wiki, modelled on Andrej Karpathy's "LLM Knowledge Bases" workflow and run locally with Claude Code acting as librarian.

```
├── CLAUDE.md   librarian instructions: rules, workflows, modes
├── RAW/        source material (added by hand, never edited)
├── Wiki/       compiled wiki, maintained by the librarian
│   ├── index.md     start here — every page with a one-line summary
│   ├── log.md       change history
│   ├── backlog.md   open questions, gaps, wanted sources
│   ├── sources/     one summary note per RAW file
│   └── topics/      concept articles, every claim cited
└── Outputs/    reports, templates and other derived work
```

**Start reading at [Wiki/index.md](Wiki/index.md).**

How it works:
1. Source material goes into `RAW/`.
2. The librarian ingests it: a source note per file, then concept articles that link and cite each other.
3. Questions are answered from the wiki; useful answers are filed back in so knowledge accumulates.
4. A monthly health check flags contradictions, unexplained topics and unsourced claims.

Workflow details are in [CLAUDE.md](CLAUDE.md).

## Roadmap

- [x] Analyse the original map and assess mobile feasibility
- [x] Asset licensing rules and a credits template
- [x] Choose engine: **Godot 4.7**
- [x] Analyse the reference transformation mechanic; decide the trigger: **charge meter**
- [x] Greybox prototype in Godot: charge meter, timed form, kill-spree economy ([Prototype/](Prototype/README.md))
- [x] Tune the transformation meter: ~90 s fill, aggression rewarded (measured 87.2 s)
- [x] Choose a visual style: **high-poly stylized, toon shaded** ([art direction](Wiki/topics/art-direction.md))
- [x] Build the stress-test scene and a PC baseline (506 FPS at the game camera)
- [x] Run the stress test on a target phone: **Infinix NOTE 30, locked 60 FPS** at realistic settings
- [x] Decide the phone render resolution: **90%** (GPU 13.7 → 7.4 ms on the NOTE 30)
- [x] Touch controls: floating joystick, verified on the phone
- [x] First original hero: **Vael, the Kiln Knight**, with the Kindled transformation and Eruption ([roster](Wiki/topics/roster.md))
- [x] Game build Phase 1: main menu, settings, hero select by category, in-game pause menu
- [x] UI polish: animations, original sounds and app icon, safe-area layout
- [x] Phase 2: single player 3v3 vs adaptive AI on an original arena map (60 FPS on the NOTE 30)
- [x] Phase 3: item shop with categories (13 original items, 5 categories)
- [ ] Phase 4: play with friends over local Wi-Fi
- [ ] Phase 5: heroes 2 and 3, original icons, audio
- [ ] Local multiplayer

Open decisions live in [Wiki/backlog.md](Wiki/backlog.md).

## Assets

Third-party assets (e.g. free Sketchfab models) are used only under licences that allow it, and every one is recorded in a credits file — see [Assets and licensing](Wiki/topics/assets-and-licensing.md) and the [credits template](Outputs/2026-11-08-asset-credits-template.md). Warcraft III game files and map files are never committed (`.gitignore` blocks them).

## Disclaimer

This is an independent fan project. It is not affiliated with or endorsed by Blizzard Entertainment, the authors of Fight Of Characters, or the owners of any franchise mentioned in the research notes. Warcraft is a trademark of Blizzard Entertainment, Inc.; other names belong to their respective owners and are referenced for research purposes only.

## License

[MIT](LICENSE) — covers this repository's own content. Third-party assets keep their own licences, listed in the credits file.
