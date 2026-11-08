---
type: source
raw: ../../RAW/2026-11-08-decision-90-percent-resolution-and-touch-joystick.md
added: 2026-11-08
why: Record the owner's render-resolution choice with its phone measurement, and the touch joystick.
---
# Decision — 90% render resolution on phones; touch joystick

The owner chose 90% 3D resolution on phones (over the proposed 75%) and asked for a touch joystick. On the Infinix NOTE 30, 90% cuts GPU time from 13.7 to 7.4 ms (−46%), nearly matching 75%'s saving with a sharper image. A floating joystick was added and verified on the phone; the game now fills wide screens.

## Key points
- **Resolution:** 3D at 90% on phones, UI full resolution. Two-round measurement: 100% 13.7 ms, 90% 7.4 ms, 75% 6.2 ms GPU; ~9 ms headroom at 90%; 60 FPS throughout.
- **Non-linear saving:** 81% of the pixels for 54% of the GPU time.
- **Method lesson:** a long run showed mid-run throttling; repeated short rounds are needed.
- **Joystick:** floating, lower-left zone (left 45%, below top 30%), 110 px travel, 15% deadzone, analog strength through the existing movement inputs. Verified with simulated drags and screenshots on the phone.
- **Wide screens:** the layout now expands to fill 20.5:9 instead of showing black bars.

## Topics
- [Art direction](../topics/art-direction.md#phone-infinix-note-30)
- [Hero arena genre](../topics/hero-arena-genre.md#adapting-for-mobile)
