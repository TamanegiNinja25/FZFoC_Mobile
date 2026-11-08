---
type: topic
category: Legal and IP
sources: [2026-11-08-fight-of-characters-mobile-feasibility, 2026-11-08-ui-and-audio-direction, 2026-11-08-spec-hero-transformations]
updated: 2026-11-08
---
# Copyright vs game mechanics

Copyright protects how a game is expressed — characters, art, music, names and code — but not its rules and mechanics. That is why a fan-made crossover like Fight Of Characters can't be published, while an original game using the same mechanics can.

## The line
| Protected (can't reuse without a licence) | Free to reuse |
|---|---|
| Characters and their names | Team arena structure |
| Art, models, icons | Item shops and builds |
| Music and sound | Kill-based win conditions |
| Code | Mid-fight transformations as a mechanic |

Basis: the source's feasibility assessment ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)). This is a general principle, not legal advice; details vary by country *(inference)*.

## Applied to Fight Of Characters
Three blockers to a direct mobile port ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)):
1. **Engine and assets:** the map runs only in Warcraft III, which has no mobile version and isn't licensed out; most of its art is Blizzard's, and Blizzard's licence forbids redistributing it.
2. **Characters and audio:** all 25 playable heroes ([src](../sources/2026-11-08-spec-hero-transformations.md)) and their forms belong to Japanese publishers and studios (Shueisha, Toei, Type-Moon and others); the 60 imported MP3 clips are likely copyrighted recordings too (see [Conflicts](#conflicts)). App stores remove unlicensed games like this, even free ones, and licensing so many franchises is impractical.
3. **Code:** the script is scrambled, belongs to the original modders and is written for Blizzard's engine.

## What that leaves
Keep the mechanics and replace everything protected: original characters, art and music ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)). See [hero arena genre](hero-arena-genre.md#adapting-for-mobile) for the design changes.

## Applied to UI and sound
The same line applies to presentation: the map's UI art, voices and clips can't be reused, but their *patterns* and mood can be rebuilt with original assets. Style isn't protected; specific recordings, images and melodies are ([src](../sources/2026-11-08-ui-and-audio-direction.md)). See [UI and audio direction](ui-and-audio-direction.md).

## Conflicts
- **Music vs clips.** The feasibility analysis called the 60 MP3s music and noted "the music is very likely copyrighted" ([src](../sources/2026-11-08-fight-of-characters-mobile-feasibility.md)). A later measurement shows they're 0.2–6.1 s ability clips ([src](../sources/2026-11-08-ui-and-audio-direction.md)). The copyright conclusion is unchanged — recordings are protected whatever their length — only the description is corrected.

## Related
- [UI and audio direction](ui-and-audio-direction.md)
- [Fight Of Characters](fight-of-characters.md)
- [Hero transformations](hero-transformations.md)
- [Warcraft III map format](warcraft-iii-map-format.md)
- [Assets and licensing](assets-and-licensing.md) — the same principle applied to downloaded models
