---
type: mechanic-spec
target: Fight Of Characters 7.7b E (Warcraft III map) — script and object data
method: Static analysis of the map script and object data with read-only scripts; every sound call traced to the trigger events and conditions that fire it. No audio extracted or played.
date: 2026-11-08
---
# Sound events — Fight Of Characters

The map's soundscape is almost entirely **reactive combat audio**: a short voice shout or effect sting plays when a hero casts an ability. Hero "voices" when selected or ordered come from Warcraft III's stock voice sets, music is the game's default playlist, and the ambience is a stock city loop. Each event below needs one original replacement sound.

## Inventory

| What | Count | Notes |
|---|---|---|
| Sounds defined in the script | 78 | 66 are actually played |
| Imported clips | 62 (60 MP3, timed) | **0.2–6.1 s, median 0.8 s** — short shouts and stings, not music |
| Stock sound references | 5 | Victory fanfare, a music cue, countdown tick, alert chime, credits music |
| Stock UI cue labels | 11 | Quest new/update/completed/failed, hint, warning, item reward, secret found, rescue |
| Hero units with an assigned stock voice set | 22 | Most often the same paladin-style voice (15 units) |
| Abilities using the object-data "effect sound" field | 3 of 302 | Sound is driven by script, not by ability data |

## Behaviour

### 1. Ability cast → voice shout or sting (the core of the soundscape)
- **45 abilities** play a clip at the moment the spell takes effect; another 6 clips fire on spell effect with conditions not tied to one ability.
- 39 abilities have one clip, 5 have two, 1 has three.
- No clip is shared between abilities: **every signature move has its own sound.**
- Two playback styles, split almost evenly:
  - **Global** (29): every player hears it at full volume, wherever the fight is. It works as an announcement.
  - **Positional** (23): attached to the casting hero, so it fades with camera distance.
- 3 abilities play a clip when channelling begins rather than when the spell lands.

### 2. Taking hits → hurt grunts
- 4 short clips (0.3–0.8 s) play when particular heroes are attacked.

### 3. Selecting and ordering heroes → stock voice sets
- Acknowledgement lines ("ready", "moving out" style) come from Warcraft III's built-in hero voice sets, not from the map.
- 22 hero units are explicitly assigned one; the rest inherit their base unit's voice *(inference)*.

### 4. Match flow
- **Victory:** a stock victory fanfare plays at a location when a key unit dies (2 triggers).
- **Countdown:** 3 tick sounds and an alert chime play when timers expire, as round or event warnings.
- **End:** stock credits music plays on a timer.
- **UI cues:** the standard quest/hint/warning/reward set is created for messages.

### 5. Background
- **Music:** Warcraft III's default random playlist.
- **Ambience:** stock city day loop and night loop.
- **Reverb:** default sound environment.

## Numbers

| Parameter | Value | Evidence |
|---|---|---|
| Clip length (imported) | 0.2–6.1 s, median 0.8 s | MP3 size ÷ bitrate, 60 clips |
| Abilities with a cast sound | 45 (+6 conditional) | Spell-effect triggers traced to ability IDs |
| Global vs positional cast sounds | 29 vs 23 | Playback call type |
| Hurt sounds | 4 | Attacked-unit triggers |
| Countdown cues | 3 ticks + 1 alert | Timer-expiry triggers |

## Design notes for an original version

### Sound shopping list

| # | Event | What to source or record | Suggested source | Qty for 3 heroes |
|---|---|---|---|---|
| 1 | Ability cast | Signature shout or sting per ability, under 1.5 s, punchy start | Record voices; stings from Freesound / Sonniss | 3 × 4 = 12 |
| 2 | Hero selected or ordered | 3–5 original voice lines per hero | Record with friends or hire a voice actor | 3 × 4 = 12 |
| 3 | Taking hits | 2 hurt grunts per hero | Record | 6 |
| 4 | Transformation | One big transformation sting per hero, the moment players remember | Layered stings, Sonniss | 3 |
| 5 | Kill / victory | Victory fanfare, defeat sting | OpenGameArt / Incompetech | 2 |
| 6 | Countdown | Tick, final alert | Kenney UI audio | 2 |
| 7 | UI | Tap, purchase coin, level-up, error | Kenney UI audio / Freesound | 4 |
| 8 | Music | 2–3 loops: menu, battle, victory — orchestral and folk with war drums | Incompetech, Soundimage, OpenGameArt | 3 |
| 9 | Ambience | Arena day loop, night loop | Freesound | 2 |

About 46 sounds for a 3-hero prototype. The voice work (rows 1–3) carries most of the nostalgia.

### Keep, change, drop
- **Keep:** one unique sound per signature move; short, punchy clips; transformation as a sound moment.
- **Change:** the global/positional split. On a phone, play your own team's casts in full and enemy casts quieter and positional, or 8 overlapping announcements turn to mush.
- **Drop:** hurt grunts on every hit (fatiguing on small speakers), and the default random music playlist. Use a loop chosen per match phase instead.

## Unknowns and limitations
- 12 defined sounds have no traced playback. They may be played through helper functions the trace didn't follow.
- 6 spell-effect clips couldn't be tied to a single ability; their conditions use comparisons the trace doesn't read.
- Voice-set inheritance for the 14 heroes without an explicit set is inferred, not confirmed.
- Clip lengths assume a constant bitrate; variable-bitrate files may be slightly off.
