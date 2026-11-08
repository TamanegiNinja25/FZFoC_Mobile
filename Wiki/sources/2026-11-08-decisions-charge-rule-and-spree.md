---
type: source
raw: ../../RAW/2026-11-08-decisions-charge-rule-and-spree.md
added: 2026-11-08
why: Record the owner's meter-tuning direction and the kill-spree economy, with the prototype's measured result.
---
# Decisions — meter charge rule and kill-spree economy

The owner set the meter's feel: about 90 s to fill, aggression rewarded, no comeback mechanic, an in-combat trickle and out-of-combat drain, per-hit caps, and kill sprees that pay gold and income. The Godot prototype implements this and measured an 87.2 s fill.

## Key points
- **Direction:** 90 s fill; aggression rewarded; no comeback mechanic; trickle in combat, drain out of combat; per-event caps; sprees reward gold and income per second.
- **Rates:** dealt 0.019/damage (cap 3 per hit, ≈64% of a fill); taken 0.008/damage (cap 1.5, ≈9%); kill +2 (≈10%); +0.2/s in combat (≈18%); −0.5/s after 5 s out of combat. Locked during the form.
- **Spree economy:** 2 gold/s base; kill gold 100 +50% per spree step; chain within 15 s; +2 gold/s per step while active (cap ×10); ends on death or timeout.
- **Regen:** 5 HP/s so a hero survives a 90 s fight with one dummy.
- **Measured:** 87.2 s fill, 5 kills, no deaths; drain 60 → 52.5 in 15 s; spree paid 100 + 150 gold and raised income 2 → 4/s.
- **Lesson:** downtime between kills (≈25%) cut effective damage from 50/s to 37.5/s; the first budget measured 113 s until rates were scaled by ≈1.25.

## Topics
- [Hero transformations](../topics/hero-transformations.md#decisions)
- [Hero arena genre](../topics/hero-arena-genre.md#economy)

## Open questions
- Does the 90 s fill still feel right in 3v3, where damage is higher and spread across targets?
- Does the spree economy snowball too hard without a comeback mechanic?
