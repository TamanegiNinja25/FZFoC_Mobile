"""Generates FZFoC's original app icon and UI/game sound effects from code.

Everything here is synthesised from math (numpy), so the assets are original
and reproducible: run `python Prototype/tools/generate_assets.py` to rebuild
them. No samples, fonts or images from any other game are used.

Outputs:
  assets/icon/icon.png                 512x512 app icon (project icon)
  assets/icon/android_foreground.png   432x432 adaptive-icon foreground
  assets/icon/android_background.png   432x432 adaptive-icon background
  assets/sfx/*.wav                     44.1 kHz mono 16-bit sound effects
"""
import os, struct, zlib, wave
import numpy as np

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets")
RATE = 44100
rng = np.random.default_rng(7)  # fixed seed → identical output every run


# ---------------------------------------------------------------- PNG writer
def save_png(path, rgba):
    """rgba: float array (h, w, 4) in 0..1."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img = (np.clip(rgba, 0, 1) * 255 + 0.5).astype(np.uint8)
    h, w, _ = img.shape
    raw = b"".join(b"\x00" + img[y].tobytes() for y in range(h))
    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
    open(path, "wb").write(png)


# ----------------------------------------------------------- drawing helpers
def grid(size, ss):
    n = size * ss
    y, x = np.mgrid[0:n, 0:n].astype(np.float32)
    return (x + 0.5) / n * 2 - 1, (y + 0.5) / n * 2 - 1  # -1..1, y down


def over(dst, color, alpha):
    a = np.clip(alpha, 0, 1)[..., None] * color[3]
    dst[..., :3] = dst[..., :3] * (1 - a) + np.array(color[:3]) * a
    dst[..., 3] = np.maximum(dst[..., 3], a[..., 0])


def soft(d, edge):
    """Coverage from a signed distance (negative inside) with an AA edge."""
    return np.clip(0.5 - d / edge, 0, 1)


def rect_sdf(x, y, cx, cy, hw, hh, angle):
    c, s = np.cos(angle), np.sin(angle)
    u = (x - cx) * c + (y - cy) * s
    v = -(x - cx) * s + (y - cy) * c
    return np.maximum(np.abs(u) - hw, np.abs(v) - hh)


def streak_sdf(x, y, x0, y0, x1, y1, w0, w1):
    """Tapered slash: width w0 at the start, w1 at the end."""
    px, py, dx, dy = x - x0, y - y0, x1 - x0, y1 - y0
    t = np.clip((px * dx + py * dy) / (dx * dx + dy * dy), 0, 1)
    dist = np.hypot(px - t * dx, py - t * dy)
    return dist - (w0 + (w1 - w0) * t)


def downsample(img, ss):
    h, w, c = img.shape
    return img.reshape(h // ss, ss, w // ss, ss, c).mean(axis=(1, 3))


# ---------------------------------------------------------------- the icon
IRON = (0.22, 0.23, 0.27, 1)
IRON_HI = (0.42, 0.44, 0.5, 1)
GOLD = (0.86, 0.68, 0.32, 1)
GOLD_HI = (1.0, 0.88, 0.55, 1)
EMBER = (1.0, 0.45, 0.1, 1)
SLASH = (1.0, 0.96, 0.82, 1)


def draw_background(x, y):
    img = np.zeros(x.shape + (4,), np.float32)
    r = np.hypot(x, y)
    base = np.clip(1 - r * 0.75, 0, 1)
    img[..., 0] = 0.08 + 0.22 * base
    img[..., 1] = 0.05 + 0.06 * base
    img[..., 2] = 0.05 + 0.03 * base
    img[..., 3] = 1
    return img


def draw_emblem(img, x, y, edge, frame=True):
    r = np.hypot(x, y)
    # ember glow behind the hammer
    over(img, EMBER, np.clip(1 - r / 0.62, 0, 1) ** 1.6 * 0.85)
    # anime-style slash streaks crossing behind (opposite diagonal to the hammer)
    for (x0, y0, x1, y1, w0, w1, a) in [
        (-0.78, 0.30, 0.70, -0.42, 0.010, 0.050, 0.95),
        (-0.70, 0.48, 0.62, -0.18, 0.006, 0.030, 0.75),
        (-0.55, 0.62, 0.48, 0.05, 0.004, 0.020, 0.55),
    ]:
        over(img, SLASH, soft(streak_sdf(x, y, x0, y0, x1, y1, w0, w1), edge) * a)
    # hammer: handle then head, both on a 45° diagonal, gold outline + iron fill
    ang = np.deg2rad(-45)
    hx, hy = 0.10, -0.10   # head centre (upper right)
    handle = rect_sdf(x, y, -0.12, 0.12, 0.42, 0.055, ang)
    head = rect_sdf(x, y, hx, hy, 0.16, 0.30, ang)
    shape = np.minimum(handle, head)
    over(img, GOLD, soft(shape - 0.035, edge))            # outline
    over(img, (0.33, 0.22, 0.14, 1), soft(handle, edge))   # wooden handle
    over(img, IRON, soft(head, edge))
    # head highlight (top bevel) and ember core in the head
    over(img, IRON_HI, soft(rect_sdf(x, y, hx - 0.07, hy - 0.07, 0.05, 0.26, ang), edge) * 0.8)
    over(img, EMBER, soft(rect_sdf(x, y, hx + 0.02, hy + 0.02, 0.05, 0.12, ang), edge))
    over(img, GOLD_HI, soft(rect_sdf(x, y, hx + 0.02, hy + 0.02, 0.02, 0.06, ang), edge) * 0.9)
    if frame:
        ring = np.abs(r - 0.86) - 0.05
        over(img, GOLD, soft(ring, edge))
        over(img, GOLD_HI, soft(np.abs(r - 0.885) - 0.012, edge) * np.clip(-y * 1.5 + 0.3, 0, 1))
        img[..., 3] *= soft(r - 0.93, edge)                # round icon, transparent corners
    return img


def make_icons():
    ss = 4
    x, y = grid(512, ss)
    edge = 2.0 / (512 * ss) * 2
    icon = draw_emblem(draw_background(x, y), x, y, edge)
    save_png(os.path.join(ROOT, "icon", "icon.png"), downsample(icon, ss))

    # Android adaptive icon: 432 px canvas, the launcher masks the outer third.
    x, y = grid(432, ss)
    x, y = x * 1.5, y * 1.5   # keep the emblem inside the 288 px safe zone
    edge = 2.0 / (432 * ss) * 3
    fg = np.zeros(x.shape + (4,), np.float32)
    save_png(os.path.join(ROOT, "icon", "android_foreground.png"), downsample(draw_emblem(fg, x, y, edge, frame=False), ss))
    save_png(os.path.join(ROOT, "icon", "android_background.png"), downsample(draw_background(x / 1.5, y / 1.5), ss))


# ---------------------------------------------------------------- sounds
def t_axis(seconds):
    return np.arange(int(RATE * seconds)) / RATE


def env(t, attack, decay):
    return np.minimum(t / max(attack, 1e-4), 1) * np.exp(-t / decay)


def lowpass(signal, cutoff):
    a = np.exp(-2 * np.pi * cutoff / RATE)
    out = np.empty_like(signal)
    acc = 0.0
    for i, s in enumerate(signal):
        acc = (1 - a) * s + a * acc
        out[i] = acc
    return out


def sweep(t, f0, f1):
    f = f0 * (f1 / f0) ** (t / t[-1])
    return np.sin(2 * np.pi * np.cumsum(f) / RATE)


def save_wav(name, signal, gain=0.9):
    os.makedirs(os.path.join(ROOT, "sfx"), exist_ok=True)
    peak = np.max(np.abs(signal)) or 1
    data = (signal / peak * gain * 32767).astype(np.int16)
    with wave.open(os.path.join(ROOT, "sfx", name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data.tobytes())


def make_sounds():
    t = t_axis(0.09)  # click: stone tap
    save_wav("click", lowpass(rng.normal(size=t.size), 2500) * env(t, 0.001, 0.012) * 3
             + np.sin(2 * np.pi * 170 * t) * env(t, 0.002, 0.03), 0.7)

    t = t_axis(0.45)  # confirm: two-note metallic chime
    bell = lambda f, d: (np.sin(2 * np.pi * f * t) + 0.4 * np.sin(2 * np.pi * f * 2.76 * t)) * env(t - d, 0.002, 0.12) * (t >= d)
    save_wav("confirm", bell(660, 0) + bell(990, 0.07), 0.6)

    t = t_axis(0.18)  # back: soft falling tone
    save_wav("back", sweep(t, 520, 330) * env(t, 0.004, 0.06), 0.5)

    t = t_axis(0.12)  # hit: hammer impact
    save_wav("hit", lowpass(rng.normal(size=t.size), 1200) * env(t, 0.001, 0.02) * 2
             + sweep(t, 140, 60) * env(t, 0.002, 0.05), 0.8)

    t = t_axis(0.55)  # slam: low boom with debris
    save_wav("slam", sweep(t, 90, 35) * env(t, 0.003, 0.18) * 1.5
             + lowpass(rng.normal(size=t.size), 900) * env(t, 0.002, 0.09), 0.95)

    t = t_axis(0.25)  # dash: short airy whoosh
    save_wav("dash", lowpass(rng.normal(size=t.size), 3000) * np.sin(np.pi * t / t[-1]) ** 2, 0.6)

    t = t_axis(0.9)   # transform: rising roar of the kiln
    roar = lowpass(rng.normal(size=t.size), 1800) * (t / t[-1]) * env(t, 0.5, 0.6)
    save_wav("transform", roar * 2 + sweep(t, 110, 440) * env(t, 0.3, 0.5) * 0.8, 0.95)

    t = t_axis(0.5)   # kill: bright arpeggio sting
    notes = [523.25, 659.25, 783.99]
    sting = sum(np.sin(2 * np.pi * f * t) * env(t - i * 0.06, 0.003, 0.15) * (t >= i * 0.06) for i, f in enumerate(notes))
    save_wav("kill", sting, 0.6)

    t = t_axis(1.6)   # victory: rising fanfare
    notes = [392.0, 523.25, 659.25, 783.99]
    fanfare = sum((np.sin(2 * np.pi * f * t) + 0.3 * np.sin(4 * np.pi * f * t)) * env(t - i * 0.18, 0.01, 0.5) * (t >= i * 0.18)
                  for i, f in enumerate(notes))
    save_wav("victory", fanfare, 0.7)

    t = t_axis(1.4)   # defeat: falling minor phrase
    notes = [392.0, 311.13, 261.63]
    phrase = sum(np.sin(2 * np.pi * f * t) * env(t - i * 0.3, 0.01, 0.4) * (t >= i * 0.3) for i, f in enumerate(notes))
    save_wav("defeat", phrase, 0.6)


if __name__ == "__main__":
    make_icons()
    make_sounds()
    for d in ("icon", "sfx"):
        for f in sorted(os.listdir(os.path.join(ROOT, d))):
            print(f"{d}/{f}: {os.path.getsize(os.path.join(ROOT, d, f)) // 1024} KB")
