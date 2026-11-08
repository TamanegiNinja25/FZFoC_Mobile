---
type: source
raw: ../../RAW/2026-11-08-decisions-meter-and-godot.md
added: 2026-11-08
why: Record the project owner's decisions on the transformation trigger and the engine.
---
# Decisions — transformation meter and Godot engine

The project owner decided that transformations are triggered by a charge meter (replacing level gates and cooldowns) and that the prototype is built in Godot (4.7.2 installed locally).

## Key points
- **Meter:** a full charge meter unlocks the form; it replaces both the level gate and the cooldown. Still open: what fills it (damage dealt, damage taken, kills, passive trickle), how fast, and whether it drains.
- **Context for the meter:** reference level gates (10–50) can't be reached in 5–8 minutes; the spec suggested a form ready about every 60–90 s.
- **Godot:** chosen over Unity; built-in ENet multiplayer covers local Wi-Fi play without servers. Models come in as glTF/GLB. The prototype lives in the project repository.

## Topics
- [Hero transformations](../topics/hero-transformations.md#decisions)
- [Hero arena genre](../topics/hero-arena-genre.md#local-multiplayer)

## Open questions
- What fills the meter, how fast, and does it drain?
