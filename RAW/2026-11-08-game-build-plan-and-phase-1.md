---
title: Game build plan and Phase 1 — menus, settings, hero select, pause
date: 2026-11-08
type: plan + implementation
decided-by: owner requested the full game (menus, settings, single player vs adaptive AI, local play with friends, items and hero select by category, in-game settings); scope line and phases set by the librarian
---

# Game build plan and Phase 1

## Owner's request
- A pre-game UI in the spirit of the classic Frozen Throne menus, with Quit and Settings.
- Modes: play with friends locally, and single player against adaptive AI for a more strategic experience; a properly ordered menu.
- In-game settings for audio and video, and quitting.
- The same mechanics, game style, map feel, skills, icons, itemization by category and character selection by category as the Fight Of Characters map, as an Android game that keeps the nostalgic feel.

## Scope line
- **Built:** the same *kind* of game — the team hero arena mechanics already in the wiki (auto-attack, skills, meter transformations, kill-spree economy, bounties), category-based hero selection and itemization, and a classic fantasy-RTS feel — with **original** characters, skills, icons, items, map and UI art.
- **Not built:** copies of the map's characters, skills, icons, map layout or character categories, or a replica of Blizzard's UI. These belong to Blizzard, the anime publishers and the map's authors; the project repository is public. This matches the project's existing position (copyright vs game mechanics; clean-room analyst rule).
- The title "FZFoC" is shown as a working title; an original title is recommended before any release.

## Phases
| Phase | Scope |
|---|---|
| 1 | Main menu (Single Player, Play with Friends, Settings, Quit); settings (audio, video); hero select by category; in-game pause menu |
| 2 | Single player: 3v3 against adaptive AI bots on an original arena map; team win condition |
| 3 | Item shop with categories; gold spent on items |
| 4 | Play with friends: host/join over local Wi-Fi (Godot ENet) |
| 5 | Heroes 2–3, original icons, audio |

## Phase 1 — delivered
- **Main menu:** Single Player · Play with Friends · Settings · Quit, in that order, on a stone panel with gold trim and parchment text; backdrop of Kindled Vael turning in an ember-lit scene. The theme is built in code from flat styles; no external assets.
- **Hero select by category:** tabs All / Bruiser / Speed / Giant; Vael under Bruiser; planned Speed and Giant heroes shown as locked "coming soon" slots; scrolling detail panel with role, description, skills and transformation; Back / Start Match.
- **Play with Friends:** explains local Wi-Fi play (one phone hosts, friends on the same network join, no servers); Host/Join disabled until Phase 4.
- **Settings (main menu and in game):** Audio — master, music, sound effects (audio buses); Video — 3D resolution 75/90/100%, shadows off/2/4 cascades, 30/60 FPS cap, FPS counter. Saved to the device; phone defaults 90% and 2 cascades. The stress test moved from the HUD to the main menu's Settings.
- **In-game pause:** a pause button (and Android back) pauses the match: Resume · Settings · Quit to Menu · Quit Game.
- **Verification:** new menu-flow test 10/10; all seven test suites pass; walked through on the Infinix NOTE 30 with screenshots.
- **Phone-found bug fixed:** hero-select details pushed the panel off screen (title and Start/Back cut off); details now scroll in a fixed-height box.
- **Observation:** first launch on the phone took about 15 s on the splash screen (shader compilation); later launches are faster.
