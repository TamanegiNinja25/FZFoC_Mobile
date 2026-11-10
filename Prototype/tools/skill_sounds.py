"""Original sound effects, one per skill: every skill name in the roster gets
its own short sound, synthesised from code (no recordings). A skill's element
(fire, frost, storm, wind, stone, water, shadow, light, spirit, nature, steel)
is read from its name and the hero's theme and picks the recipe; a seed from the
name varies pitch, length and texture, so no two skills sound the same.
Writes assets/sfx/skills/<skill_id>.wav (22 kHz mono).

    python tools/skill_sounds.py
"""
import os, re, zlib, wave
import numpy as np

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "sfx", "skills")
SCRIPTS = os.path.join(os.path.dirname(__file__), "..", "scripts")
RATE = 22050

ELEMENTS = [
    ("fire", r"fire|flame|ember|cinder|burn|heat|blaze|pyre|smoulder|star|sun|brand|kiln|forge|bellows|searing|ash"),
    ("frost", r"ice|frost|glacial|winter|rime|freeze"),
    ("storm", r"thunder|lightning|storm|static|arc |spark|sky|heaven|lance"),
    ("wind", r"wind|gale|cyclone|razor|updraft|downdraft|edge|flash|flurry|cut"),
    ("stone", r"stone|rock|boulder|quake|sand|dune|cairn|gate|iron|wall|shock|grip|rune|glyph|fortress|bulwark"),
    ("water", r"tide|wave|whirlpool|undertow|mire|bog|fog|marsh|drown"),
    ("shadow", r"shadow|night|moon|eclipse|shade|umbral|hollow|wither|curse|grave|barrow|drain|death|demon"),
    ("light", r"light|dawn|radiant|sunburst|aegis|judgement|holy|day"),
    ("spirit", r"spirit|wisp|soul|fighting"),
    ("nature", r"hunter|mark|arrow|volley|shot|bolt|spread|pin|splinter|rain|piercer"),
]


def element_of(name):
    low = name.lower()
    for element, pattern in ELEMENTS:
        if re.search(pattern, low):
            return element
    return "steel"


def t_axis(seconds):
    return np.arange(int(RATE * seconds)) / RATE


def env(t, attack, decay):
    return np.minimum(t / max(attack, 1e-4), 1.0) * np.exp(-np.maximum(t - attack, 0) / max(decay, 1e-4))


def lowpass(signal, cutoff):
    a = np.exp(-2 * np.pi * cutoff / RATE)
    out = np.empty_like(signal)
    acc = 0.0
    for i, v in enumerate(signal):
        acc = (1 - a) * v + a * acc
        out[i] = acc
    return out


def sweep(t, f0, f1):
    f = f0 + (f1 - f0) * t / t[-1]
    return np.sin(2 * np.pi * np.cumsum(f) / RATE)


def make(name, element):
    seed = zlib.crc32(name.encode())
    rng = np.random.default_rng(seed)
    p = 2 ** rng.uniform(-0.35, 0.35)          # pitch variation
    length = rng.uniform(0.35, 0.7)
    t = t_axis(length)
    noise = rng.normal(size=t.size)
    if element == "fire":
        s = lowpass(noise, 1400 * p) * env(t, 0.03, length * 0.4) * 2.2 + sweep(t, 160 * p, 70 * p) * env(t, 0.01, 0.15)
    elif element == "frost":
        s = sum(np.sin(2 * np.pi * f * p * t) * env(t - d, 0.002, 0.18) * (t >= d)
                for f, d in [(1800, 0), (2400, 0.04), (3100, 0.08)]) * 0.5 + lowpass(noise, 5000) * env(t, 0.005, 0.06) * 0.6
    elif element == "storm":
        crack = noise * env(t, 0.001, 0.03) * 2.5
        s = crack + lowpass(noise, 300 * p) * env(t, 0.02, length * 0.5) * 3 + sweep(t, 90 * p, 40 * p) * env(t, 0.01, 0.3)
    elif element == "wind":
        s = lowpass(noise, 2600 * p) * np.sin(np.pi * t / t[-1]) ** 2 * 1.6 + sweep(t, 900 * p, 1500 * p) * env(t, 0.05, 0.1) * 0.25
    elif element == "stone":
        s = sweep(t, 110 * p, 40 * p) * env(t, 0.003, 0.2) * 1.4 + lowpass(noise, 700 * p) * env(t, 0.002, 0.12) * 1.5
    elif element == "water":
        bub = sum(np.sin(2 * np.pi * (300 + 120 * k) * p * t * (1 + 0.6 * t)) * env(t - 0.05 * k, 0.005, 0.08) * (t >= 0.05 * k) for k in range(5))
        s = bub * 0.5 + lowpass(noise, 1200 * p) * np.sin(np.pi * t / t[-1]) * 0.8
    elif element == "shadow":
        s = sweep(t, 220 * p, 90 * p) * env(t, 0.06, length * 0.5) * 0.9 + np.sin(2 * np.pi * 233 * p * t) * np.sin(2 * np.pi * 3 * t) * env(t, 0.1, 0.3) * 0.5 \
            + lowpass(noise, 600) * env(t, 0.05, 0.2) * 0.6
    elif element == "light":
        notes = [523.25, 659.25, 783.99, 1046.5]
        s = sum(np.sin(2 * np.pi * f * p * t) * env(t - i * 0.05, 0.004, 0.25) * (t >= i * 0.05) for i, f in enumerate(notes)) * 0.45
    elif element == "spirit":
        s = sweep(t, 400 * p, 900 * p) * env(t, 0.02, 0.2) * 0.7 + np.sin(2 * np.pi * 660 * p * t) * np.sin(2 * np.pi * 7 * t) * env(t, 0.05, 0.25) * 0.4
    elif element == "nature":
        s = lowpass(noise, 4000 * p) * env(t, 0.001, 0.05) * 1.2 + sweep(t, 700 * p, 300 * p) * env(t, 0.003, 0.08) * 0.6
    else:  # steel
        s = sum(np.sin(2 * np.pi * f * p * t) for f in (620, 1480, 2210)) * env(t, 0.001, 0.12) * 0.4 + lowpass(noise, 3000) * env(t, 0.001, 0.03)
    s = s / (np.abs(s).max() or 1.0) * 0.85
    fade = np.minimum(1.0, (t[-1] - t) / 0.03)
    return (s * fade).astype(np.float32)


def skill_names():
    names = set()
    for root, _, files in os.walk(SCRIPTS):
        for f in files:
            if f.endswith(".gd"):
                text = open(os.path.join(root, f), encoding="utf-8").read()
                names.update(re.findall(r'Skill\.new\("([^"]+)"', text))
                names.update(re.findall(r'_blink\("([^"]+)"', text))
                names.update(re.findall(r'skill_name = "([^"]+)"', text))
    return sorted(names)


def snake(name):
    """Godot's String.to_snake_case for plain names: words joined by '_'."""
    s = re.sub(r"[^A-Za-z0-9]+", " ", name).strip()
    s = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", s)
    return "_".join(s.lower().split())


if __name__ == "__main__":
    os.makedirs(ROOT, exist_ok=True)
    total = 0
    for name in skill_names():
        sound = make(name, element_of(name))
        path = os.path.join(ROOT, snake(name) + ".wav")
        w = wave.open(path, "wb")
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes((sound * 32767).astype("<i2").tobytes())
        w.close()
        total += os.path.getsize(path)
    print(len(skill_names()), "skill sounds,", total // 1024, "KB")
