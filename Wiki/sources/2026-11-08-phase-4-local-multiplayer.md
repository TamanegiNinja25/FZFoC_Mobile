---
type: source
raw: ../../RAW/2026-11-08-phase-4-local-multiplayer.md
added: 2026-11-08
why: Record the local multiplayer design and its verification.
---
# Phase 4 — play with friends over local Wi-Fi

Host-authoritative local multiplayer: the host simulates, clients send input and display 20-per-second snapshots. Lobby with broadcast discovery and IP join, Versus or Co-op, bots filling slots. Verified by a two-process test and a real phone-hosted match the laptop joined.

## Key points
- **Architecture:** host runs the match; clients send stick + button presses; host sends full hero state + score 20×/s; effects and kill feed relayed; client heroes are puppets.
- **Lobby:** host shows Wi-Fi IP; Versus or Co-op vs bots; join by discovered list or IP; bots fill slots; leavers become bots; host leaving returns clients to the menu.
- **Technical:** ENet UDP 24570, discovery UDP 24571; Android Internet/Wi-Fi permissions; no pausing online.
- **Verified:** host 8/8 and client 9/9 on one PC; real match hosted on the NOTE 30 with the laptop joining over Wi-Fi.

## Topics
- [Hero arena genre](../topics/hero-arena-genre.md#modes)
