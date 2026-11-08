---
title: Phase 3 — item shop with categories
date: 2026-11-08
type: implementation
decided-by: owner asked for the shop with categories; items, prices and rules designed by the librarian
---

# Phase 3 — item shop with categories

## Rules
- Shop at your own fountain (as in classic hero arenas); the SHOP button glows there. The training ground allows shopping anywhere. The match keeps running while the shop is open, which keeps the design compatible with local multiplayer.
- 6 inventory slots; items sell for half their cost; consumables are used by tapping them in the HUD inventory bar.
- Hero stats are recomputed from the hero definition plus all carried items, so selling cleanly removes a bonus.
- Bots buy a fixed build (blade, mail, treads, rune, plate, maul) whenever they're at their fountain with enough gold.

## Catalogue — 13 original items in 5 categories
Prices assume about 2 gold/s passive income plus kill gold over an 8-minute match.

| Category | Item | Effect | Cost |
|---|---|---|---|
| Weapons | Tempered Blade | +12 attack damage | 300 |
| Weapons | Quickening Gauntlets | +20% attack speed | 350 |
| Weapons | Forgebreaker Maul | +30 damage, +10% attack speed | 900 |
| Armor | Riveted Mail | +200 max HP | 300 |
| Armor | Bulwark Plate | 15% less damage taken | 500 |
| Armor | Emberheart Amulet | +4 HP/s | 350 |
| Mobility | Wayfarer's Treads | +15% move speed | 250 |
| Mobility | Windstep Greaves | +25% move speed | 600 |
| Relics | Kindling Rune | meter charges 25% faster | 450 |
| Relics | Everflame Sigil | transformation +4 s | 600 |
| Relics | Sage's Hourglass | skills recharge 20% faster | 500 |
| Consumables | Ember Draught | heal 400 over 5 s | 100 |
| Consumables | Spark Flask | +25 meter | 200 |

- The **Relics** category is built around the game's own transformation mechanic.
- Names avoid Warcraft III item names; icons are generated from code (category-coloured tiles with original glyphs).

## Verification
- Shop test 17/17: categories, gold/range/full-inventory rules, every stat effect (e.g. Bulwark Plate turns 100 damage into 85; Sage's Hourglass turns a 6 s cooldown into 4.8 s), half-price selling, both consumables, and bots buying items on their own during a match.
- Phone (Infinix NOTE 30): SHOP button glows at the fountain; the shop screen shows category tabs, the icon grid with prices, details, Buy (disabled without gold) and the inventory.
- The joystick now ignores touches that start on HUD controls such as the inventory bar.
