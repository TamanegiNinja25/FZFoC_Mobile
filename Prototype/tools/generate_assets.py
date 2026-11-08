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

    t = t_axis(0.7)   # levelup: quick rising shimmer of four notes
    notes = [523.25, 659.25, 783.99, 1046.5]
    shimmer = sum((np.sin(2 * np.pi * f * t) + 0.25 * np.sin(6 * np.pi * f * t)) * env(t - i * 0.07, 0.003, 0.22) * (t >= i * 0.07)
                  for i, f in enumerate(notes))
    save_wav("levelup", shimmer, 0.55)

    t = t_axis(1.1)   # duel: war-horn swell over a drum hit
    horn = (sweep(t, 147, 196) + 0.5 * sweep(t, 294, 392)) * env(t, 0.15, 0.6)
    drum = sweep(t, 120, 45) * env(t, 0.002, 0.15) * 1.4
    save_wav("duel", lowpass(horn, 1400) * 1.2 + drum, 0.9)


# ---------------------------------------------------------------- item icons
CATEGORY_COLORS = {
    "Weapons": (0.55, 0.16, 0.08), "Armor": (0.2, 0.3, 0.45), "Mobility": (0.16, 0.42, 0.2),
    "Relics": (0.38, 0.2, 0.5), "Consumables": (0.1, 0.4, 0.42),
    "Stats": (0.42, 0.32, 0.12), "Exclusive": (0.5, 0.1, 0.28), "Artifacts": (0.48, 0.36, 0.06),
}
# Artifacts show their recipe's first two parts, small and overlapped (see glyph()).
ARTIFACT_PARTS = {
    "pyreheart_brand": ("forgebreaker_maul", "kindling_rune"), "bastion_aegis": ("bulwark_plate", "riveted_mail"),
    "titans_cleaver": ("forgebreaker_maul", "riveted_mail"), "galestride_boots": ("windstep_greaves", "quickening_gauntlets"),
    "champions_medallion": ("emberheart_amulet", "kindling_rune"), "wellspring_stone": ("emberheart_amulet", "sages_hourglass"),
    "sovereign_blade": ("tempered_blade", "bulwark_plate"),
}
TOME_COLORS = {"str": (0.75, 0.2, 0.15, 1), "agi": (0.2, 0.6, 0.25, 1), "all": (0.95, 0.75, 0.25, 1), "xp": (0.3, 0.45, 0.85, 1)}
STEEL = (0.82, 0.84, 0.88, 1)
WOODC = (0.5, 0.33, 0.18, 1)
LIQUID = (1.0, 0.42, 0.15, 1)


def circle_sdf(x, y, cx, cy, r):
    return np.hypot(x - cx, y - cy) - r


def tri_sdf(x, y, a, b, c):
    """Signed distance to a triangle (negative inside)."""
    def edge(p0, p1):
        ex, ey = p1[0] - p0[0], p1[1] - p0[1]
        px, py = x - p0[0], y - p0[1]
        t = np.clip((px * ex + py * ey) / (ex * ex + ey * ey), 0, 1)
        return np.hypot(px - t * ex, py - t * ey), ex * py - ey * px
    d0, s0 = edge(a, b)
    d1, s1 = edge(b, c)
    d2, s2 = edge(c, a)
    d = np.minimum(np.minimum(d0, d1), d2)
    inside = ((s0 >= 0) & (s1 >= 0) & (s2 >= 0)) | ((s0 <= 0) & (s1 <= 0) & (s2 <= 0))
    return np.where(inside, -d, d)


def glyph(img, x, y, e, item):
    deg = np.deg2rad
    if item in ARTIFACT_PARTS:
        a, b = ARTIFACT_PARTS[item]
        glyph(img, (x + 0.22) / 0.7, (y + 0.18) / 0.7, e / 0.7, a)
        glyph(img, (x - 0.24) / 0.62, (y - 0.24) / 0.62, e / 0.62, b)
        over(img, GOLD, soft(np.abs(circle_sdf(x, y, 0, 0, 0.66)) - 0.035, e))
        return
    if item.startswith("tome_"):
        kind = item.split("_")[1]
        cover = TOME_COLORS["all" if kind == "all" else kind]
        over(img, (0.92, 0.88, 0.78, 1), soft(rect_sdf(x, y, 0.06, 0.04, 0.36, 0.48, 0) - 0.02, e))   # pages
        over(img, cover, soft(rect_sdf(x, y, -0.02, 0, 0.36, 0.48, 0) - 0.03, e))                   # cover
        over(img, GOLD, soft(rect_sdf(x, y, -0.3, 0, 0.04, 0.46, 0), e))                            # spine
        pips = {"2": 1, "5": 2, "100": 3, "minor": 1, "greater": 2}.get(item.split("_")[2], 1)
        for i in range(pips):
            py = -0.18 + i * 0.18 - (pips - 1) * 0.0
            over(img, GOLD, soft(rect_sdf(x, y, 0.02, py, 0.1, 0.1, deg(45)), e))
        return
    if item == "kilnheart_core":
        hexagon = np.maximum(np.abs(x) * 0.866 + np.abs(y) * 0.5, np.abs(y)) - 0.46
        over(img, (0.35, 0.33, 0.33, 1), soft(hexagon, e))
        over(img, LIQUID, soft(circle_sdf(x, y, 0, 0, 0.26), e))
        over(img, (1, 0.9, 0.5, 1), soft(circle_sdf(x, y, 0, 0, 0.12), e))
        return
    if item == "galeheart_ribbon":
        for i, oy in enumerate((-0.3, 0.0, 0.3)):
            over(img, (0.55, 0.95, 1.0, 1), soft(streak_sdf(x, y, -0.55, oy + 0.15, 0.55, oy - 0.15, 0.03, 0.09), e))
        over(img, GOLD, soft(circle_sdf(x, y, 0, 0, 0.12), e))
        return
    if item == "cairnstone_heart":
        for cx, cy, r in ((0, 0.3, 0.3), (0.02, -0.1, 0.24), (-0.02, -0.4, 0.16)):
            over(img, (0.6, 0.57, 0.52, 1), soft(circle_sdf(x, y, cx, cy, r), e))
        over(img, (1, 0.7, 0.25, 1), soft(rect_sdf(x, y, 0, -0.1, 0.06, 0.12, deg(45)), e))
        return
    if item == "tempered_blade":
        over(img, STEEL, soft(rect_sdf(x, y, 0.05, -0.12, 0.09, 0.5, deg(45)), e))
        over(img, GOLD, soft(rect_sdf(x, y, -0.22, 0.22, 0.3, 0.06, deg(-45)), e))
        over(img, WOODC, soft(rect_sdf(x, y, -0.36, 0.36, 0.06, 0.16, deg(45)), e))
    elif item == "quickening_gauntlets":
        over(img, STEEL, soft(rect_sdf(x, y, 0, 0.12, 0.32, 0.32, 0) - 0.08, e))
        for fx in (-0.24, -0.08, 0.08, 0.24):
            over(img, STEEL, soft(rect_sdf(x, y, fx, -0.32, 0.06, 0.16, 0) - 0.02, e))
        over(img, GOLD, soft(rect_sdf(x, y, 0, 0.42, 0.36, 0.06, 0), e))
    elif item == "forgebreaker_maul":
        over(img, WOODC, soft(rect_sdf(x, y, -0.1, 0.12, 0.06, 0.55, deg(35)), e))
        over(img, STEEL, soft(rect_sdf(x, y, 0.14, -0.26, 0.36, 0.2, deg(35)) - 0.03, e))
        over(img, LIQUID, soft(rect_sdf(x, y, 0.14, -0.26, 0.18, 0.06, deg(35)), e))
    elif item == "riveted_mail":
        over(img, STEEL, soft(rect_sdf(x, y, 0, 0.05, 0.42, 0.5, 0) - 0.06, e))
        for rx in (-0.2, 0.0, 0.2):
            for ry in (-0.2, 0.05, 0.3):
                over(img, (0.35, 0.37, 0.42, 1), soft(circle_sdf(x, y, rx, ry, 0.05), e))
    elif item == "bulwark_plate":
        top = rect_sdf(x, y, 0, -0.18, 0.4, 0.3, 0) - 0.06
        point = tri_sdf(x, y, (-0.46, 0.1), (0.46, 0.1), (0, 0.62))
        over(img, STEEL, soft(np.minimum(top, point), e))
        over(img, GOLD, soft(rect_sdf(x, y, 0, 0.02, 0.05, 0.5, 0), e))
        over(img, GOLD, soft(rect_sdf(x, y, 0, -0.12, 0.38, 0.05, 0), e))
    elif item == "emberheart_amulet":
        over(img, GOLD, soft(np.abs(circle_sdf(x, y, 0, -0.35, 0.22)) - 0.03, e))
        over(img, GOLD, soft(circle_sdf(x, y, 0, 0.15, 0.36), e))
        over(img, LIQUID, soft(circle_sdf(x, y, 0, 0.15, 0.24), e))
    elif item in ("wayfarers_treads", "windstep_greaves"):
        over(img, WOODC if item == "wayfarers_treads" else STEEL, soft(np.minimum(
            rect_sdf(x, y, -0.08, -0.12, 0.16, 0.38, 0), rect_sdf(x, y, 0.1, 0.3, 0.34, 0.14, 0)) - 0.04, e))
        if item == "windstep_greaves":
            for i, wy in enumerate((-0.35, -0.18, -0.01)):
                over(img, (0.9, 1, 0.95, 1), soft(streak_sdf(x, y, -0.62, wy, -0.3, wy - 0.08, 0.01, 0.03), e))
    elif item == "kindling_rune":
        over(img, (0.85, 0.8, 1.0, 1), soft(rect_sdf(x, y, 0, 0, 0.38, 0.38, deg(45)), e))
        over(img, (0.38, 0.2, 0.5, 1), soft(rect_sdf(x, y, 0, 0, 0.26, 0.26, deg(45)), e))
        over(img, LIQUID, soft(tri_sdf(x, y, (0, -0.22), (0.14, 0.16), (-0.14, 0.16)), e))
    elif item == "everflame_sigil":
        over(img, LIQUID, soft(np.minimum(circle_sdf(x, y, 0, 0.18, 0.3), tri_sdf(x, y, (-0.3, 0.12), (0.3, 0.12), (0, -0.55))), e))
        over(img, (1, 0.85, 0.4, 1), soft(np.minimum(circle_sdf(x, y, 0, 0.24, 0.15), tri_sdf(x, y, (-0.15, 0.2), (0.15, 0.2), (0, -0.2))), e))
    elif item == "sages_hourglass":
        over(img, (0.9, 0.85, 0.7, 1), soft(np.minimum(tri_sdf(x, y, (-0.32, -0.45), (0.32, -0.45), (0, 0)),
                                                     tri_sdf(x, y, (-0.32, 0.45), (0.32, 0.45), (0, 0))), e))
        over(img, GOLD, soft(rect_sdf(x, y, 0, -0.5, 0.4, 0.05, 0), e))
        over(img, GOLD, soft(rect_sdf(x, y, 0, 0.5, 0.4, 0.05, 0), e))
        over(img, LIQUID, soft(tri_sdf(x, y, (-0.2, 0.4), (0.2, 0.4), (0, 0.15)), e))
    elif item == "ember_draught":
        over(img, (0.85, 0.9, 0.95, 1), soft(np.minimum(circle_sdf(x, y, 0, 0.15, 0.36), rect_sdf(x, y, 0, -0.32, 0.1, 0.16, 0)), e))
        over(img, LIQUID, soft(np.maximum(circle_sdf(x, y, 0, 0.15, 0.3), -(y - 0.05)), e))
        over(img, WOODC, soft(rect_sdf(x, y, 0, -0.5, 0.12, 0.05, 0), e))
    elif item == "spark_flask":
        over(img, (0.85, 0.9, 0.95, 1), soft(np.minimum(tri_sdf(x, y, (-0.36, 0.45), (0.36, 0.45), (0, -0.15)), rect_sdf(x, y, 0, -0.3, 0.09, 0.2, 0)), e))
        over(img, (1, 0.9, 0.3, 1), soft(tri_sdf(x, y, (-0.26, 0.38), (0.26, 0.38), (0, 0.05)), e))


ITEMS = {
    "tempered_blade": "Weapons", "quickening_gauntlets": "Weapons", "forgebreaker_maul": "Weapons",
    "riveted_mail": "Armor", "bulwark_plate": "Armor", "emberheart_amulet": "Armor",
    "wayfarers_treads": "Mobility", "windstep_greaves": "Mobility",
    "kindling_rune": "Relics", "everflame_sigil": "Relics", "sages_hourglass": "Relics",
    "ember_draught": "Consumables", "spark_flask": "Consumables",
    "tome_str_2": "Stats", "tome_agi_2": "Stats", "tome_str_5": "Stats", "tome_agi_5": "Stats",
    "tome_all_100": "Stats", "tome_xp_minor": "Stats", "tome_xp_greater": "Stats",
    "kilnheart_core": "Exclusive", "galeheart_ribbon": "Exclusive", "cairnstone_heart": "Exclusive",
    **{artifact: "Artifacts" for artifact in ARTIFACT_PARTS},
}


def make_item_icons():
    ss, size = 4, 128
    x, y = grid(size, ss)
    e = 2.0 / (size * ss) * 2
    for item, category in ITEMS.items():
        img = np.zeros(x.shape + (4,), np.float32)
        bg = CATEGORY_COLORS[category]
        tile = rect_sdf(x, y, 0, 0, 0.82, 0.82, 0) - 0.1
        shade = np.clip(1.1 - np.hypot(x, y + 0.3) * 0.6, 0.4, 1.1)
        over(img, (bg[0] * 0.5, bg[1] * 0.5, bg[2] * 0.5, 1), soft(tile, e))
        tint = np.zeros_like(img)
        tint[..., :3] = np.array(bg) * shade[..., None]
        tint[..., 3] = 1
        a = soft(tile + 0.06, e)
        img[..., :3] = img[..., :3] * (1 - a[..., None]) + tint[..., :3] * a[..., None]
        glyph(img, x * 1.25, y * 1.25, e * 1.25, item)
        over(img, GOLD, soft(np.abs(tile) - 0.035, e))
        save_png(os.path.join(ROOT, "icons", "items", item + ".png"), downsample(img, ss))


# ---------------------------------------------------------------- music
MUSIC_RATE = 22050


def save_music(name, signal):
    os.makedirs(os.path.join(ROOT, "music"), exist_ok=True)
    peak = np.max(np.abs(signal)) or 1
    data = (signal / peak * 0.8 * 32767).astype(np.int16)
    with wave.open(os.path.join(ROOT, "music", name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(MUSIC_RATE)
        w.writeframes(data.tobytes())


def note(n):
    """MIDI note number → Hz."""
    return 440.0 * 2 ** ((n - 69) / 12)


def pad(freqs, seconds, attack=0.8):
    t = np.arange(int(MUSIC_RATE * seconds)) / MUSIC_RATE
    tone = sum(np.sin(2 * np.pi * f * t) + 0.3 * np.sin(2 * np.pi * f * 2.003 * t) for f in freqs)
    shape = np.minimum(t / attack, 1) * np.minimum((seconds - t) / attack, 1)
    return tone * shape


def make_music():
    # Menu: slow minor progression (Am – F – C – G), 4 s per chord, soft bells on top.
    chords = [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]
    menu = np.concatenate([pad([note(n) for n in c], 4.0) for c in chords])
    bells = np.zeros_like(menu)
    melody = [76, 72, 69, 72, 77, 72, 69, 67]
    for k, n in enumerate(melody):
        start = int(k * 2.0 * MUSIC_RATE)
        t = np.arange(int(1.6 * MUSIC_RATE)) / MUSIC_RATE
        tone = (np.sin(2 * np.pi * note(n) * t) + 0.4 * np.sin(2 * np.pi * note(n) * 2.76 * t)) * np.exp(-t / 0.5)
        bells[start:start + t.size] += tone[: bells.size - start] * 0.35
    save_music("menu", menu + bells)

    # Battle: 110 BPM war drums over a pulsing bass and a low drone, 8 bars.
    beat = 60.0 / 110.0
    total = int(beat * 32 * MUSIC_RATE)
    t = np.arange(total) / MUSIC_RATE
    battle = 0.35 * (np.sin(2 * np.pi * note(33) * t) + 0.5 * np.sin(2 * np.pi * note(40) * t))  # drone
    def hit(at, freq, decay, gain, noise=0.0):
        i = int(at * MUSIC_RATE)
        tt = np.arange(int(0.5 * MUSIC_RATE)) / MUSIC_RATE
        f = freq * (1 + 1.5 * np.exp(-tt / 0.03))
        s = np.sin(2 * np.pi * np.cumsum(f) / MUSIC_RATE) * np.exp(-tt / decay) * gain
        if noise:
            s += rng.normal(size=tt.size) * np.exp(-tt / 0.05) * noise
        end = min(total, i + tt.size)
        battle[i:end] += s[: end - i]
    for b in range(32):
        hit(b * beat, 55, 0.25, 1.4)                          # war drum on every beat
        if b % 4 == 2:
            hit(b * beat, 180, 0.08, 0.5, noise=0.8)           # rim crack on beat 3
        if b % 2 == 1:
            hit(b * beat + beat / 2, 70, 0.12, 0.6)            # off-beat tom
    bass_line = [45, 45, 48, 43]
    for b in range(32):
        n = bass_line[(b // 8) % 4]
        i = int(b * beat * MUSIC_RATE)
        tt = np.arange(int(beat * 0.9 * MUSIC_RATE)) / MUSIC_RATE
        s = np.sign(np.sin(2 * np.pi * note(n) * tt)) * 0.12 * np.exp(-tt / 0.25)
        battle[i:i + tt.size] += s[: total - i]
    save_music("battle", battle)


if __name__ == "__main__":
    make_icons()
    make_item_icons()
    make_sounds()
    make_music()
    for d in ("icon", "icons/items", "sfx", "music"):
        for f in sorted(os.listdir(os.path.join(ROOT, d))):
            print(f"{d}/{f}: {os.path.getsize(os.path.join(ROOT, d, f)) // 1024} KB")
