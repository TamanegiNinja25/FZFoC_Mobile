---
title: Decisions — transformation meter and Godot engine
date: 2026-11-08
type: decision
decided-by: project owner (in chat)
---

# Decisions — transformation meter and Godot engine

## 1. Transformations are triggered by a charge meter
- **Decision:** a hero's transformation is unlocked by filling a charge meter, not by hero-level gates or a plain cooldown.
- **Context:** the reference map gates forms behind hero levels 10–50, which a 5–8 minute match can't reach. The transformation spec offered two options: a short level curve, or a meter charged by damage dealt and taken so a form is ready about every 60–90 seconds.
- **Implications:**
  - The meter replaces both the level gate and the cooldown: when the meter is full, the form is available.
  - Still to decide: exactly what fills the meter (damage dealt, damage taken, kills, passive trickle), how fast, and whether it drains.

## 2. Godot is the engine for the prototype
- **Decision:** the prototype is built in Godot. Version 4.7.2 (stable, Windows) is installed locally.
- **Context:** the candidates were Godot and Unity. Godot's built-in high-level multiplayer works over local Wi-Fi without servers, which suits the offline play-with-friends goal.
- **Implications:**
  - Local multiplayer will use Godot's built-in multiplayer (ENet).
  - Models should be imported as glTF/GLB.
  - The prototype lives in the project repository.
