"""Original skill icons for every hero skill, drawn from signed-distance shapes
like the item icons (tools/generate_assets.py). Each skill maps to a hero colour
theme and a reusable glyph kind. Writes assets/icons/skills/<skill_id>.png.

    python tools/skill_icons.py
"""
import os
import numpy as np
from generate_assets import (ROOT, GOLD, GOLD_HI, grid, over, soft, rect_sdf, streak_sdf, circle_sdf,
                             tri_sdf, downsample, save_png)

# Hero themes: tile colour and glyph colour.
THEMES = {
    "vael": ((0.42, 0.13, 0.04), (1.0, 0.55, 0.15, 1)),
    "ryn": ((0.06, 0.28, 0.3), (0.55, 1.0, 0.95, 1)),
    "barrow": ((0.28, 0.25, 0.2), (1.0, 0.75, 0.3, 1)),
    "sable": ((0.3, 0.12, 0.1), (1.0, 0.82, 0.5, 1)),
    "morrow": ((0.16, 0.12, 0.26), (0.7, 1.0, 0.75, 1)),
    "kael": ((0.12, 0.12, 0.16), (0.85, 0.9, 1.0, 1)),
    "tamsin": ((0.1, 0.14, 0.34), (0.75, 0.85, 1.0, 1)),
    "hask": ((0.22, 0.24, 0.27), (0.95, 0.8, 0.45, 1)),
}

# skill id (snake_case of the skill's name) → (theme, glyph kind)
SKILLS = {
    "bellows_slam": ("vael", "slam"), "ember_dash": ("vael", "dash"),
    "searing_brand": ("vael", "bolt"), "forge_golem": ("vael", "summon"),
    "cyclone_cut": ("ryn", "crescent"), "flurry": ("ryn", "triple"),
    "razor_wind": ("ryn", "fan"), "thousand_cuts": ("ryn", "star"),
    "quake_stomp": ("barrow", "rings"), "boulder_hurl": ("barrow", "boulder"),
    "stone_grip": ("barrow", "spikes"), "rockfall": ("barrow", "meteor"),
}


def draw(img, x, y, e, kind, ink):
    deg = np.deg2rad
    if kind == "slam":
        over(img, ink, soft(rect_sdf(x, y, 0, -0.18, 0.36, 0.18, 0) - 0.04, e))
        over(img, GOLD, soft(rect_sdf(x, y, 0, 0.12, 0.05, 0.22, 0), e))
        for dx in (-0.45, 0.45):
            over(img, ink, soft(streak_sdf(x, y, dx * 0.6, 0.45, dx, 0.62, 0.05, 0.01), e))
        over(img, ink, soft(rect_sdf(x, y, 0, 0.5, 0.6, 0.03, 0), e))
    elif kind == "dash":
        for i, oy in enumerate((-0.25, 0.0, 0.25)):
            over(img, ink, soft(streak_sdf(x, y, -0.6, oy, 0.15, oy, 0.01, 0.06), e))
        over(img, ink, soft(tri_sdf(x, y, (0.15, -0.3), (0.62, 0.0), (0.15, 0.3)), e))
    elif kind == "bolt":
        over(img, ink, soft(streak_sdf(x, y, -0.6, 0.45, 0.25, -0.2, 0.02, 0.08), e))
        over(img, GOLD_HI, soft(circle_sdf(x, y, 0.3, -0.25, 0.2), e))
        over(img, ink, soft(np.abs(circle_sdf(x, y, 0.3, -0.25, 0.32)) - 0.025, e))
    elif kind == "summon":
        over(img, (0.35, 0.3, 0.28, 1), soft(rect_sdf(x, y, 0, 0.1, 0.32, 0.36, 0) - 0.05, e))
        over(img, (0.35, 0.3, 0.28, 1), soft(rect_sdf(x, y, 0, -0.42, 0.18, 0.14, 0) - 0.04, e))
        for side in (-1, 1):
            over(img, (0.35, 0.3, 0.28, 1), soft(rect_sdf(x, y, side * 0.45, 0.05, 0.1, 0.3, 0) - 0.03, e))
        over(img, ink, soft(circle_sdf(x, y, 0, 0.05, 0.12), e))
        over(img, ink, soft(rect_sdf(x, y, 0, -0.44, 0.12, 0.025, 0), e))
    elif kind == "crescent":
        ring = np.abs(circle_sdf(x, y, 0, 0, 0.42)) - 0.07
        over(img, ink, soft(np.maximum(ring, -(x + y * 0.3 + 0.1)), e))
        over(img, GOLD_HI, soft(streak_sdf(x, y, -0.55, 0.5, 0.55, -0.5, 0.01, 0.04), e))
    elif kind == "triple":
        for i, ox in enumerate((-0.28, 0.0, 0.28)):
            over(img, ink, soft(streak_sdf(x, y, ox - 0.18, 0.45, ox + 0.18, -0.45, 0.01, 0.06), e))
    elif kind == "fan":
        for angle in (-35, 0, 35):
            a = deg(angle)
            over(img, ink, soft(streak_sdf(x, y, 0, 0.55, np.sin(a) * 0.65, 0.55 - np.cos(a) * 0.95, 0.06, 0.01), e))
    elif kind == "star":
        for angle in (0, 45, 90, 135):
            a = deg(angle)
            over(img, ink, soft(streak_sdf(x, y, -np.cos(a) * 0.6, -np.sin(a) * 0.6, np.cos(a) * 0.6, np.sin(a) * 0.6, 0.01, 0.04), e))
        over(img, GOLD_HI, soft(circle_sdf(x, y, 0, 0, 0.1), e))
    elif kind == "rings":
        for r in (0.18, 0.36, 0.55):
            over(img, ink, soft(np.abs(circle_sdf(x, y * 1.6, 0, 0.3, r)) - 0.035, e))
        over(img, (0.45, 0.42, 0.38, 1), soft(rect_sdf(x, y, 0, -0.2, 0.18, 0.22, 0) - 0.06, e))
    elif kind == "boulder":
        over(img, (0.55, 0.5, 0.44, 1), soft(circle_sdf(x, y, 0.15, -0.05, 0.32), e))
        for oy in (-0.2, 0.05, 0.3):
            over(img, ink, soft(streak_sdf(x, y, -0.65, oy, -0.25, oy, 0.01, 0.05), e))
    elif kind == "spikes":
        over(img, (0.4, 0.36, 0.3, 1), soft(circle_sdf(x, y, 0, 0.1, 0.2), e))
        for angle in range(0, 360, 60):
            a = deg(angle)
            cx, cy = np.cos(a) * 0.42, np.sin(a) * 0.42 + 0.05
            over(img, ink, soft(tri_sdf(x, y, (cx - 0.1, cy + 0.12), (cx + 0.1, cy + 0.12), (cx * 0.55, cy * 0.55 - 0.1)), e))
    elif kind == "meteor":
        over(img, ink, soft(streak_sdf(x, y, -0.55, -0.55, 0.05, 0.0, 0.01, 0.16), e))
        over(img, (0.55, 0.48, 0.4, 1), soft(circle_sdf(x, y, 0.12, 0.08, 0.26), e))
        over(img, ink, soft(rect_sdf(x, y, 0.1, 0.52, 0.5, 0.04, 0), e))
    elif kind == "arrow":
        over(img, (0.6, 0.45, 0.3, 1), soft(streak_sdf(x, y, -0.5, 0.5, 0.4, -0.4, 0.035, 0.035), e))
        over(img, ink, soft(tri_sdf(x, y, (0.55, -0.55), (0.25, -0.38), (0.38, -0.25)), e))
        over(img, ink, soft(tri_sdf(x, y, (-0.5, 0.5), (-0.62, 0.3), (-0.3, 0.62)), e))
    elif kind == "volley":
        for i, ox in enumerate((-0.3, 0.0, 0.3)):
            over(img, (0.6, 0.45, 0.3, 1), soft(rect_sdf(x, y, ox, 0.1, 0.025, 0.4, 0), e))
            over(img, ink, soft(tri_sdf(x, y, (ox - 0.1, -0.25), (ox + 0.1, -0.25), (ox, -0.5)), e))
    elif kind == "beam":
        over(img, ink, soft(rect_sdf(x, y, 0, 0, 0.7, 0.09, deg(-30)), e))
        over(img, GOLD_HI, soft(rect_sdf(x, y, 0, 0, 0.7, 0.035, deg(-30)), e))
    elif kind == "skull":
        over(img, ink, soft(circle_sdf(x, y, 0, -0.08, 0.36), e))
        over(img, ink, soft(rect_sdf(x, y, 0, 0.3, 0.2, 0.14, 0), e))
        for side in (-1, 1):
            over(img, (0.1, 0.08, 0.15, 1), soft(circle_sdf(x, y, side * 0.14, -0.08, 0.09), e))
    elif kind == "drain":
        over(img, (0.75, 0.15, 0.2, 1), soft(np.minimum(circle_sdf(x, y, 0, 0.18, 0.26), tri_sdf(x, y, (-0.24, 0.1), (0.24, 0.1), (0, -0.45))), e))
        over(img, ink, soft(np.abs(circle_sdf(x, y, 0, 0, 0.6)) - 0.03, e))
    elif kind == "curse":
        for r, a0 in ((0.5, 0.0), (0.32, 1.0)):
            over(img, ink, soft(np.abs(circle_sdf(x, y, 0, 0, r)) - 0.04, e))
        over(img, ink, soft(circle_sdf(x, y, 0, 0, 0.1), e))
    elif kind == "lightning":
        pts = [(-0.1, -0.6), (0.2, -0.1), (-0.05, -0.05), (0.15, 0.6)]
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            over(img, ink, soft(streak_sdf(x, y, ax, ay, bx, by, 0.07, 0.07), e))
    elif kind == "zone":
        over(img, ink, soft(np.abs(circle_sdf(x, y * 1.8, 0, 0.35, 0.55)) - 0.05, e))
        for ox in (-0.3, 0.0, 0.3):
            over(img, ink, soft(streak_sdf(x, y, ox, -0.5, ox + 0.08, 0.2, 0.05, 0.02), e))
    elif kind == "shield":
        top = rect_sdf(x, y, 0, -0.2, 0.38, 0.28, 0) - 0.06
        point = tri_sdf(x, y, (-0.44, 0.06), (0.44, 0.06), (0, 0.6))
        over(img, (0.6, 0.62, 0.66, 1), soft(np.minimum(top, point), e))
        over(img, ink, soft(rect_sdf(x, y, 0, 0.0, 0.05, 0.42, 0), e))
    elif kind == "hook":
        over(img, ink, soft(np.maximum(np.abs(circle_sdf(x, y, 0.1, 0.2, 0.25)) - 0.06, -(y - 0.2)), e))
        over(img, (0.6, 0.62, 0.66, 1), soft(rect_sdf(x, y, -0.15, -0.25, 0.05, 0.4, 0), e))
    elif kind == "wave":
        for i, r in enumerate((0.35, 0.55)):
            over(img, ink, soft(np.maximum(np.abs(circle_sdf(x, y, 0, 0.55, r)) - 0.05, y - 0.35), e))
    elif kind == "blink":
        over(img, ink, soft(circle_sdf(x, y, 0.32, -0.1, 0.16), e))
        for i, ox in enumerate((-0.45, -0.2)):
            c = (ink[0], ink[1], ink[2], 0.35 + 0.3 * i)
            over(img, c, soft(circle_sdf(x, y, ox, -0.1, 0.12 + 0.02 * i), e))
    else:
        over(img, ink, soft(circle_sdf(x, y, 0, 0, 0.35), e))


def make_skill_icons():
    ss, size = 4, 128
    x, y = grid(size, ss)
    e = 2.0 / (size * ss) * 2
    for skill, (theme, kind) in SKILLS.items():
        bg, ink = THEMES[theme]
        img = np.zeros(x.shape + (4,), np.float32)
        tile = np.hypot(x, y) - 0.9  # round tile: skills read differently from square items
        shade = np.clip(1.15 - np.hypot(x, y + 0.35) * 0.65, 0.4, 1.15)
        over(img, (bg[0] * 0.45, bg[1] * 0.45, bg[2] * 0.45, 1), soft(tile, e))
        a = soft(tile + 0.07, e)
        img[..., :3] = img[..., :3] * (1 - a[..., None]) + (np.array(bg) * shade[..., None]) * a[..., None]
        draw(img, x * 1.2, y * 1.2, e * 1.2, kind, ink)
        over(img, GOLD, soft(np.abs(tile) - 0.035, e))
        save_png(os.path.join(ROOT, "icons", "skills", skill + ".png"), downsample(img, ss))


if __name__ == "__main__":
    make_skill_icons()
    folder = os.path.join(ROOT, "icons", "skills")
    print(len(os.listdir(folder)), "skill icons in", folder)
