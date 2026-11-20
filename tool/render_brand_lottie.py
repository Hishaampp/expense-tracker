# Renders the Ample mark as Lottie animations for the website, from the same
# geometry as tool/render_brand_mark.py (viewBox 17..83: ring r28 stroke 10
# at 50,50; bar x73 y17 w10 h66 rx5; honey r19.5 below y=40).
# Run: python3 tool/render_brand_lottie.py web/public/brand
import json, math, sys

FPS = 60
SIZE = 240
S = 3.0                      # px per mark unit
OFF = SIZE / 2 - 50 * S      # mark centre (50,50) at the canvas centre
K = 0.5523                   # circle bezier constant
HONEY = [0xF2/255, 0xB3/255, 0x3D/255, 1]
HONEY_INK = [0x7A/255, 0x52/255, 0x00/255, 1]

def P(x, y): return [x * S + OFF, y * S + OFF]

def static(v): return {"a": 0, "k": v}

def anim(frames):
    """frames: [(t, value, ease)], ease 'out' | 'in' | 'inout' | 'linear'."""
    curves = {"out": ([0.16, 1], [0.3, 1]), "in": ([0.55, 0], [0.9, 0.5]),
              "inout": ([0.65, 0], [0.35, 1]), "linear": ([0, 0], [1, 1]),
              "bounce": ([0.34, 1.56], [0.64, 1])}
    ks = []
    for i, (t, v, ease) in enumerate(frames):
        v = v if isinstance(v, list) else [v]
        k = {"t": t, "s": v}
        if i < len(frames) - 1:
            o, inn = curves[ease]
            k["o"] = {"x": [o[0]], "y": [o[1]]}
            k["i"] = {"x": [inn[0]], "y": [inn[1]]}
        ks.append(k)
    return {"a": 1, "k": ks}

def circle_path(cx, cy, r):
    k = K * r
    return {"c": True,
            "v": [[cx, cy - r], [cx + r, cy], [cx, cy + r], [cx - r, cy]],
            "i": [[-k, 0], [0, -k], [k, 0], [0, k]],
            "o": [[k, 0], [0, k], [-k, 0], [0, -k]]}

def wave_path(phase, amp):
    """Honey body in px, top edge a gentle wave; y=0 is the honey surface."""
    left, right, depth = -70.0, 70.0, 140.0
    n = 4
    v, i_, o_ = [], [], []
    for j in range(n + 1):
        x = left + (right - left) * j / n
        y = amp * math.sin(phase + j * math.pi / 2 * 1.6)
        h = (right - left) / n / 3
        slope = amp * math.cos(phase + j * math.pi / 2 * 1.6) * 0.6
        v.append([x, y]); i_.append([-h, -slope]); o_.append([h, slope])
    v += [[right, depth], [left, depth]]
    i_ += [[0, 0], [0, 0]]; o_ += [[0, 0], [0, 0]]
    return {"c": True, "v": v, "i": i_, "o": o_}

def tr(p=None, s=None, o=None, r=None):
    return {"ty": "tr", "a": static([0, 0]),
            "p": p or static([0, 0]), "s": s or static([100, 100]),
            "r": r or static(0), "o": o or static(100),
            "sk": static(0), "sa": static(0)}

def layer(ind, name, shapes, op, masks=None, ks_o=None):
    l = {"ddd": 0, "ind": ind, "ty": 4, "nm": name, "sr": 1,
         "ks": {"o": ks_o or static(100), "r": static(0), "p": static([0, 0, 0]),
                "a": static([0, 0, 0]), "s": static([100, 100, 100])},
         "ao": 0, "shapes": shapes, "ip": 0, "op": op, "st": 0, "bm": 0}
    if masks:
        l["hasMask"] = True
        l["masksProperties"] = masks
    return l

def ring_layer(ind, ink, op):
    cx, cy = P(50, 50)
    bx, by = P(78, 50)
    # Separate groups: a fill paints every path above it in its group.
    return layer(ind, "ring", [
        {"ty": "gr", "nm": "bar", "it": [
            {"ty": "rc", "p": static([bx, by]), "s": static([10 * S, 66 * S]),
             "r": static(5 * S), "d": 1},
            {"ty": "fl", "c": static(ink), "o": static(100), "r": 1},
            tr()]},
        {"ty": "gr", "nm": "ring", "it": [
            {"ty": "el", "p": static([cx, cy]), "s": static([56 * S, 56 * S]), "d": 1},
            {"ty": "st", "c": static(ink), "o": static(100), "w": static(10 * S),
             "lc": 2, "lj": 2},
            tr()]}], op)

def honey_layer(ind, level, wave, op):
    """level: animated y (px) of the honey surface; wave: animated path."""
    cx, cy = P(50, 50)
    mask = {"inv": False, "mode": "a", "nm": "bowl",
            "pt": static(circle_path(cx, cy, 19.5 * S)),
            "o": static(100), "x": static(0)}
    return layer(ind, "honey", [
        {"ty": "gr", "nm": "honey", "it": [
            {"ty": "sh", "ks": wave, "d": 1},
            {"ty": "fl", "c": static(HONEY), "o": static(100), "r": 1},
            tr(p=level)]}], op, masks=[mask])

def coin_layer(ind, x, start, op):
    cx = P(x, 0)[0]
    top, land = P(0, -2)[1], P(0, 54)[1]
    fall = 26
    return layer(ind, f"coin{ind}", [
        {"ty": "gr", "nm": "coin", "it": [
            {"ty": "gr", "nm": "rim", "it": [
                {"ty": "el", "p": static([0, 0]), "s": static([4.2 * S, 4.2 * S]), "d": 1},
                {"ty": "st", "c": static(HONEY_INK), "o": static(100),
                 "w": static(1.1 * S), "lc": 2, "lj": 2},
                tr()]},
            {"ty": "gr", "nm": "face", "it": [
                {"ty": "el", "p": static([0, 0]), "s": static([7.5 * S, 7.5 * S]), "d": 1},
                {"ty": "fl", "c": static(HONEY), "o": static(100), "r": 1},
                tr()]},
            tr(p=anim([(start, [cx, top], "in"), (start + fall, [cx, land], "linear"),
                       (op, [cx, land], "linear")]),
               s=anim([(start, [100, 100], "linear"), (start + fall - 4, [100, 100], "out"),
                       (start + fall + 3, [20, 20], "linear"), (op, [20, 20], "linear")]),
               o=anim([(0, 0, "linear"), (start, 0, "linear"), (start + 1, 100, "linear"),
                       (start + fall - 1, 100, "out"), (start + fall + 3, 0, "linear"),
                       (op, 0, "linear")]))]}], op)

def sway(op, amp, start=0, cycles=2):
    frames, steps = [], 8
    for j in range(steps * cycles + 1):
        t = start + (op - start) * j / (steps * cycles)
        frames.append((round(t, 2), [wave_path(j * 2 * math.pi / steps, amp)], "linear"))
    return {"a": 1, "k": [dict({"t": t, "s": v},
                               **({"o": {"x": [0.5], "y": [0.5]}, "i": {"x": [0.5], "y": [0.5]}}
                                  if n < len(frames) - 1 else {}))
                          for n, (t, v, _) in enumerate(frames)]}

def comp(name, op, layers):
    return {"v": "5.12.0", "fr": FPS, "ip": 0, "op": op, "w": SIZE, "h": SIZE,
            "nm": name, "ddd": 0, "assets": [], "layers": layers}

def pour(ink):
    op = 150
    empty, full = P(0, 69.5)[1], P(0, 40)[1]
    level = anim([(0, [P(50, 0)[0], empty], "linear"), (22, [P(50, 0)[0], empty], "inout"),
                  (96, [P(50, 0)[0], full], "out"), (op, [P(50, 0)[0], full], "linear")])
    return comp("ample-pour", op, [
        coin_layer(1, 44, 0, op), coin_layer(2, 52, 14, op), coin_layer(3, 47, 28, op),
        ring_layer(4, ink, op),
        honey_layer(5, level, sway(op, 2.2 * S), op)])

def idle(ink):
    op = 240
    level = static([P(50, 0)[0], P(0, 40)[1]])
    return comp("ample-sway", op, [ring_layer(1, ink, op),
                                   honey_layer(2, level, sway(op, 1.6 * S, cycles=2), op)])

out = sys.argv[1]
inks = {"dark": [0xF4/255, 0xF1/255, 0xEA/255, 1], "light": [0x12/255, 0x12/255, 0x12/255, 1]}
for theme, ink in inks.items():
    for fn, name in ((pour, "pour"), (idle, "sway")):
        with open(f"{out}/ample-{name}-{theme}.json", "w") as f:
            json.dump(fn(ink), f, separators=(",", ":"))
print("ok")
