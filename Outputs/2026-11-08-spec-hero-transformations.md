---
type: mechanic-spec
target: Fight Of Characters 7.7b E (Warcraft III map), script and object data
method: Static analysis only. Read-only Python scripts parsed the unit, ability, item and buff object data (every ability level) and traced script triggers to their events and conditions. REA not connected, no runtime observation.
date: 2026-11-08
---
# Hero transformations

11 of the 25 playable heroes can change form. Ten do it with a **learned ultimate-style ability**: it unlocks at a set hero level, costs no mana, lasts a fixed time, then reverts automatically and goes on a long cooldown. One hero has a **permanent, one-time awakening** instead, which fires on its own once the hero's attributes pass a threshold. A transformed hero is worth more gold when killed.

## Behaviour

### Three ways to transform

**1. Timed form ability (10 heroes).** Hero F's form is the simplest example.
- The hero learns the form ability like any other skill. It has its own minimum hero level and a fixed gap of levels between ranks.
- Casting it costs no mana. The hero changes into its alternate form and a buff labelled as the form's duration counts down on the unit.
- When the timer runs out, the hero reverts to its normal form. Nothing in the data or script lets the player end a form early. *(Inference: the morph types used here can't be cancelled by hand.)*
- Higher ranks of the ability give a longer duration, a bigger bonus to max HP and, on some heroes, a shorter cooldown. The alternate form's stats don't change between ranks.
- Nine heroes use one morph type and Hero B uses a second ("rage-style"). Both work the same way: a timed revert, then a cooldown.

**2. Multi-stage chain (Hero A).** This is the map's only three-stage form.
- One form ability has 3 ranks, and **each rank points to a different form**: rank 1 gives stage 1, rank 2 gives stage 2, rank 3 gives stage 3.
- The hero moves up the chain by putting skill points into the ability at hero levels 15, 21 and 27. A cast always goes straight from the normal form to the stage matching the current rank. Stages don't build on each other within one activation.
- All three stage forms have the same base attributes as the normal form. The power gap comes from a flat bonus to all attributes that each stage carries (+50, +100, +150) plus a max-HP bonus (+3,000, +6,000, +9,000).

**3. Permanent awakening (Hero K).** This one is run by the script, not by an ability.
- **Check:** whenever any hero levels up or picks up an item, the script checks whether it's Hero K with **total Strength ≥ 250 and total Agility ≥ 250**. Totals include bonuses from items and skills.
- **Sequence:** the hero is frozen and invulnerable for about 2.5 s while effects play. A new unit of the awakened form is created in its place and the old unit is removed.
- **What carries over:**
  - **Level and XP:** copied exactly.
  - **Items:** all 6 inventory slots move across.
  - **Attributes:** the old form's base attributes are added on top of the new form's own level-scaled attributes. Bonus attributes from items and skills aren't counted in that copy. *(Inference: base attributes roughly double.)*
  - **Abilities:** the four skills are replaced by four awakened versions, each starting at rank 1. The level copy gives back skill points to spend again. *(Inference.)*
- **No revert and no repeat.** The form is permanent, and the check switches itself off after it fires once, so it happens at most once per match.
- **Bug:** the new form's current HP is set from the old form's maximum mana, not its maximum HP. Arriving at full health was clearly the intent.
- **Reachability:** level growth alone never meets the threshold. Even at the level cap of 50, with its attribute ultimate and its +50-all signature item, Hero K is still about 32 Agility short. The awakening is a late-game reward for building stat items.

### HP-threshold states (Hero B, buffs only)
Hero B also has two temporary combat states. The hero's unit doesn't change, so these are buffs, not forms.
- **Uncontrolled last stand:**
  - **Trigger:** Hero B is attacked while in its normal form at **10% HP or less**, and isn't already in this state.
  - **Effect:** HP jumps to 30%, the hero is invulnerable for 1 s, and an 8 s buff starts. While it lasts, every attack deals bonus damage equal to 3 × Agility and teleports the hero beside its target.
  - **Cost:** the hero **dies after 7 s**.
  - The state can repeat in later fights until it's switched off.
- **Controlled version:** learning a separate skill (unlocks at hero level 30) permanently switches the last stand off. Casting that skill gives a 15 s buff on a 120 s cooldown: every attack deals bonus damage equal to 2 × Agility and teleports the hero beside its target, and the hero doesn't die.

### What a form changes
The alternate forms fall into four groups:

| Archetype | Heroes | Change vs normal form |
|---|---|---|
| Speed form | B, F, I | Primary attribute (Agility) and all attribute growth doubled. Move speed 250 → 400. Attack interval 1.5 s → 0.5 s, so 3× attack rate. Hero B also gains an empowered wave attack (fixed 3,000 damage, 20 s cooldown) next to its normal one (400–1,200). |
| Bruiser form | G, H, J | All base attributes roughly doubled (to 60/40–50/40–50) and growth doubled. Base HP 600 → 1,000. Base attack damage 500. Move speed 300. Some armor or HP regeneration. One extra active skill (G, J). |
| Giant form | C, D, E | Base attributes 60/40/40 with doubled growth. Base HP 600 → 2,000, mana 300 → 1,000, armor 50, **base attack damage 2,000**. Larger model. Hero C also gets a splash attack, a damage aura (500 per second in a 200 radius) and a slower 3.0 s attack. |
| Attribute stages | A | Same base unit, plus +50/+100/+150 to all attributes and the max-HP bonus. |

In every group:
- Killing a transformed hero pays more gold: **500 for a normal form, 1,000 for speed and bruiser forms (and the awakened form), 2,000 for giant forms.** Bounty is switched on for all players. Hero A's stage forms stay at 500.
- Some alternate forms drop one skill from their list: the form ability itself (D, G, J) or one other skill (E, F). Whether that skill can still be used while transformed wasn't verified.

### Carry-over across a timed form change
The nine heroes with the standard morph and Hero B's rage-style morph use the engine's built-in morph, which keeps the same unit, so these carry over: level, XP, items, ranks of skills both forms share, and buffs. *(Inference from engine behaviour, not runtime-tested.)*
- **Signature items:** each hero has a personal 10,000-gold item that other heroes can't hold. For Heroes A, D and I, the item is restricted to the **normal form only**. A transformed hero that tries to pick it up drops it, though one already carried stays carried.
- **Cooldowns:** shared skills keep their cooldowns through the swap *(inference)*. The form ability's own cooldown appears to start at cast, so part of it runs during the form *(inference)*.

## Numbers

Map gameplay constants: max hero level 50. Each point of Strength gives +10 HP. Each point of the primary attribute gives +2 attack damage. Each point of Agility gives +0.5 armor. Each point of Intelligence gives +10 mana.

| Parameter | Value | Evidence |
|---|---|---|
| Heroes with a form / roster | 11 / 25 | Pick-area hero list in the script; morph abilities in the ability data (w3a); awakening trigger |
| Mana cost of every form ability | 0 at all ranks | w3a mana-cost field set to 0 explicitly |
| Hero A: unlock levels | 15, 21, 27 (3 ranks) | w3a A003 required level 15, level gap 6 |
| Hero A: stage bonus | +50 / +100 / +150 all attributes; +3,000 / +6,000 / +9,000 max HP | Stage units' attribute-bonus abilities; w3a A003 alternate-form HP bonus |
| Hero A: derived stage totals | about +3,500 / +7,000 / +10,500 HP; +100 / +200 / +300 damage; +25 / +50 / +75 armor | Constants × bonus *(derived)* |
| Hero A: duration / cooldown | 60 s / 180 s per stage *(inferred: stock defaults, not overridden)* | Fields absent in w3a A003; the default shows through as the missing level in other chains |
| Hero B (rage-style): unlock | levels 10, 20, 30, 40, 50 | w3a A00J required level 10, level gap 10 |
| Hero B: duration / cooldown | 10 / 20 / 30 / 40 / 60 s; 120 s | w3a A00J |
| Heroes C, D: unlock | levels 30, 40, 50 | w3a A01Y, A040 |
| Hero E: unlock | levels 28, 38, 48 | w3a A05M |
| Giants C/D/E: duration / cooldown / HP bonus | 30 / 40 / 60 s; 180 / 150 / 120 s; +3,000 / +4,000 / +6,000 | w3a; rank-1 cooldown and rank-3 duration are stock defaults |
| Hero F: unlock / duration / cooldown | 10–50 every 10 levels; 15 / 25 / 35 / 45 / 60 s; 100 s; no HP bonus | w3a A04G (rank-5 duration is the default) |
| Hero G: unlock / duration / cooldown / HP bonus | 15, 23, 31, 39, 47; 40 / 50 / 60 / 70 / 80 s; 90 s; +1,000 to +5,000 | w3a A04H |
| Heroes H, I, J: unlock / duration / cooldown / HP bonus | 10–50 every 10 levels; 30 / 30 / 30 / 60 / 90 s; 90 s; +1,000 to +5,000 | w3a A054, A01Z, A00D |
| Uptime at top rank (duration ÷ cooldown) | A 33%, B 50%, C/D/E 50%, F 60%, G 89%, **H/I/J 100%** | Derived; assumes cooldown starts at cast |
| Speed form: attack interval / move speed | 1.5 → 0.5 s; 250 → 400 | Unit data (w3u) for B, F, I |
| Giant form: base HP / mana / armor / damage | 2,000 / 1,000 / 50 / 2,000 | w3u for C, D, E forms |
| Kill bounty, normal → transformed | 500 → 1,000 (speed/bruiser/awakened) or 2,000 (giant) | w3u gold bounty fields; bounty enabled for all players in script |
| Hero K: awakening threshold | Strength ≥ 250 and Agility ≥ 250, totals incl. bonuses | Script trigger on hero-level and item-pickup events |
| Hero K: transformation lock-out | about 2.5 s frozen and invulnerable | Script waits |
| Hero K: awakened stat growth | Strength +3.5 / Agility +2.5 / Intelligence +2.5 per level (was +3 / +2 / +2) | w3u |
| Hero B last stand | at 10% HP or less: HP set to 30%, 1 s invulnerable, 8 s buff, +3 × Agility damage per hit, death after 7 s | Script trigger on being attacked; buff-carrier ability duration |
| Hero B controlled state | unlocks at level 30; 15 s; 120 s cooldown; +2 × Agility fire damage per hit | w3a A02M / A02Q; script |

## Design notes for an original version (mobile 3v3, 5–8 min match)

**Keep**
- **Form as a timed ultimate, then a cooldown.** It's easy to read, gives the team a power window to plan around, and creates "wait out the form" counterplay. Keep the visible countdown on the hero.
- **No mana cost.** The real costs are the cooldown and the unlock gate. On mobile that's one fewer resource to track.
- **Higher bounty on transformed heroes.** It's a clean risk/reward loop and a comeback lever: killing an enemy in form should pay noticeably more, about 1.5–2× base.
- **Rank decides the stage.** Hero A's approach (each rank of one ability unlocks the next stage) gives multi-stage forms without a new system. It works well as a single signature hero.
- **Distinct archetypes** (speed, bruiser, giant). Each form should change how the hero plays, not just add numbers.

**Change**
- **Unlock gates:** level 10–30 on a 50-level curve can't happen in 5–8 minutes. Use a short level curve (for example, cap at 12) with the form unlocking at level 4–6, or charge a meter from damage dealt and taken so a form is ready about every 60–90 s.
- **Power scale:** giant forms with 2,000 base damage and +6,000 HP decide fights on their own. Aim for roughly +30–50% effective power: about +25% HP as a shield, +20–30% damage or attack speed, and one changed or empowered skill.
- **Uptime:** 100% uptime at top rank (H, I, J) removes the window. Cap it at about 35–50%. A starting point: 15/20/25 s duration and 70/60/50 s cooldown.
- **Transition:** keep a short invulnerable transform of 0.5–1 s, not 2.5 s, so it stays dramatic without stalling a 3v3 fight. Keep HP as a percentage when changing form, and fix the reference's HP bug by design.
- **Permanent awakening:** this works better as an in-match objective (for example, take a shrine or reach N takedowns) than as a hidden stat threshold. Tell the player how close they are.

**Drop**
- **Swapping the whole unit:** in our own engine a form is a state on one character, so there's nothing to copy (level, XP, items, cooldowns).
- **Items only the normal form can pick up**, and 10,000-gold personal items.
- **A last stand that ends in forced death:** it's punishing and hard to read on a small screen. If kept, make it a short, clearly signalled cheat-death once per life.

**Open choices**
- Meter or cooldown?
- Should every hero get a form, or only some, as in the reference (11 of 25)?
- Is stage progression per match (skill points) or per activation (meter tiers)?
- Should a form end early on death or crowd control?

## Unknowns and limitations
- **Hero A's duration and cooldown (60 s / 180 s)** are inferred. The fields aren't set, so the stock morph defaults apply. The same default value appears where other chains leave a rank unset, which supports this, but it isn't proven.
- **Hero B's rage-style morph** probably also gives attack speed, move speed and regeneration bonuses from its stock template. Those values aren't stored in the map, so they're unknown here.
- **Engine behaviour wasn't observed.** These all need runtime testing: how attributes are recalculated on a morph, whether the form ends on death, whether a skill missing from the alternate form's list stays usable, when the cooldown starts, and what happens if a rank is learned mid-form.
- **Hero K's awakened form** takes its starting attributes from a stock unit that the map doesn't override, so the exact post-awakening totals can't be computed from map data.
- **Unused data:** Hero A's form ability has data for a 4th rank pointing at an unrelated hero. It's unused (the ability has 3 ranks) and probably left over.
- **Effects only:** several form abilities also fire script effects or sounds on cast. These are presentation only and weren't analysed further.
- **Method:** static analysis only, with REA not connected. All numbers come from map object data and script conditions, not from play.

### Appendix: label → unit IDs (traceability)
| Label | Normal form → form(s) | Form ability |
|---|---|---|
| Hero A | H00B → H00U / H012 / H013 | A003 |
| Hero B | H00C → O000 (buff states via A02M / A02R / A02Q) | A00J |
| Hero C | O002 → O003 | A01Y |
| Hero D | H00O → O004 | A040 |
| Hero E | H023 → O005 | A05M |
| Hero F | H01D → H01G | A04G |
| Hero G | N00W → H01P | A04H |
| Hero H | H01W → H001 | A054 |
| Hero I | H01A → O008 | A01Z |
| Hero J | N003 → Nbst | A00D |
| Hero K | H00T → Eidm | none (script awakening) |
