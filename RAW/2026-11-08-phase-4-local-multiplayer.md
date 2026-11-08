---
title: Phase 4 — play with friends over local Wi-Fi
date: 2026-11-08
type: implementation + measurement
decided-by: owner asked for local play with friends; architecture by the librarian
---

# Phase 4 — play with friends over local Wi-Fi

## Design
- **Host-authoritative:** one device hosts and runs the real match. Clients send their stick direction every physics frame and button presses (skills, transform, buy, sell, use) as they happen. The host sends every hero's state (position, facing, health, shield, form, gold, meter, cooldowns, items) and the score 20 times a second; clients smooth toward it.
- **Relayed events:** slam rings, sounds and kill-feed lines. Client heroes are display-only puppets.
- **Lobby:** the host shows its Wi-Fi address and chooses **Versus** (friends alternate teams) or **Co-op** (friends together against bots); joiners pick a game found by UDP broadcast or type the host's IP. Bots fill empty slots; a friend who leaves is taken over by a bot; if the host leaves, clients return to the menu with a notice.
- **Technical:** Godot ENet on UDP port 24570; discovery broadcast on 24571; Android build declares Internet and Wi-Fi permissions. Online matches can't be paused.

## Verification
- Two Godot processes on one PC over 127.0.0.1 (no firewall prompt): host 8/8, client 9/9 — broadcast discovery, join, team assignment, the client's input moving its hero on the host, snapshots moving it on the client, score reaching the client.
- **Real cross-device match:** the Infinix NOTE 30 hosted on Wi-Fi (192.168.1.5); the laptop joined by IP over the home network, loaded the same Versus arena and moved its hero through the phone's simulation.
- The first test run exposed a test flaw, not a netcode bug: the client measured movement from its spawn, but the host had teleported its hero.
