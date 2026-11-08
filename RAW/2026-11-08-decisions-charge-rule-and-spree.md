---
title: Decisions — meter charge rule and kill-spree economy
date: 2026-11-08
type: decision
decided-by: project owner (in chat); values tuned and measured in the Godot prototype
---

# Decisions — meter charge rule and kill-spree economy

## Owner's direction
- **Fill target:** the transformation meter fills in about **90 seconds** of fighting.
- **Aggression is rewarded**, and there is **no comeback mechanic**: the game shouldn't help a losing player overwhelm a winning one.
- **Kills:** consecutive kills (a killing spree) greatly reward the player with **gold and gold income per second**.
- **Passive trickle:** a small amount per second guarantees a form even for a struggling player; a **drain when out of combat** rewards staying in the fight.
- **Caps:** no single hit should fill the meter; cap the charge per event.

## Implementation in the prototype (Prototype/scripts/transform_meter.gd, hero.gd)
| Source | Rate | Share of a fill |
|---|---|---|
| Damage dealt | 0.019 per damage, max 3 per hit | ≈ 64% |
| Damage taken | 0.008 per damage (under half the dealt rate), max 1.5 per hit | ≈ 9% |
| Kill | +2 | ≈ 10% |
| In combat | +0.2 per second | ≈ 18% |
| Out of combat (5 s without dealing or taking damage) | −0.5 per second | — |

- The meter is locked while transformed and restarts from zero after the form.
- **Kill-spree economy:** 2 gold/s passive income; kill gold 100, +50% per spree step; a spree builds when the next kill lands within 15 s; each step adds +2 gold/s while it lasts (cap ×10); dying or missing the window ends it.
- **Survivability:** hero health regeneration 5 HP/s was added so a hero survives a 90 s fight against one dummy.

## Measured result (headless balance test, Godot 4.7.2)
- **Fill time: 87.2 s** against one dummy (target 90 ± 15 s), 5 kills, no deaths, 435 HP left.
- **Idle drain:** 60 → 52.5 over 15 s out of combat.
- **Spree:** two kills in quick succession paid 100 + 150 gold and raised income from 2 to 4 gold/s.
- **Lesson:** the first budget assumed continuous damage and measured 113 s; dummies are dead about 25% of each kill cycle, so effective damage was 37.5/s, not 50/s. Rates were scaled by about 1.25 to hit the target.
