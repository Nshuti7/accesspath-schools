"""Builds the AccessPath logo files. Usage: python3 make_brand.py OUT_DIR"""
import sys, os
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen

NAVY = "#142D52"
GOLD = "#F5B323"
WHITE = "#FFFFFF"

PIN = "M100 236 C88 214 20 160 20 90 A80 80 0 0 1 180 90 C180 160 112 214 100 236 Z"
ROAD = "M96.5 45 Q100 38 103.5 45 L154 162 L46 162 Z"
# Centre markings shrink toward the horizon so the road reads as a path ahead.
DASHES = [(127, 146, 8), (101, 115, 6), (82, 91, 4.4), (68, 73, 3.2)]


def symbol(pin=NAVY, disc=WHITE, road=GOLD, marks=NAVY, cid="d"):
    """Symbol group in a 200 x 240 box."""
    dashes = "".join(
        f'<rect x="{100 - w / 2:.2f}" y="{y0}" width="{w}" height="{y1 - y0}" rx="{w / 2:.2f}" fill="{marks}"/>'
        for (y0, y1, w) in DASHES
    )
    return (
        f'<defs><clipPath id="{cid}"><circle cx="100" cy="90" r="56"/></clipPath></defs>'
        f'<path d="{PIN}" fill="{pin}"/>'
        f'<circle cx="100" cy="90" r="56" fill="{disc}"/>'
        f'<g clip-path="url(#{cid})"><path d="{ROAD}" fill="{road}"/>{dashes}</g>'
    )


def text_paths(text, font, size, x, baseline, fill):
    gs = font.getGlyphSet()
    cmap = font.getBestCmap()
    upm = font["head"].unitsPerEm
    s = size / upm
    out, cx = [], x
    for ch in text:
        name = cmap[ord(ch)]
        pen = SVGPathPen(gs)
        gs[name].draw(TransformPen(pen, (s, 0, 0, -s, cx, baseline)))
        out.append(pen.getCommands())
        cx += gs[name].width * s - size * 0.02  # slight tightening for a bold display wordmark
    return f'<path fill="{fill}" d="{" ".join(out)}"/>', cx - x


def svg(w, h, body, bg=None):
    rect = f'<rect width="{w}" height="{h}" fill="{bg}"/>' if bg else ""
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">{rect}{body}</svg>\n'


def main(out):
    os.makedirs(out, exist_ok=True)
    font = TTFont("/usr/share/fonts/opentype/inter/Inter-ExtraBold.otf")

    # Symbol on its own (transparent).
    open(f"{out}/accesspath-symbol.svg", "w").write(svg(200, 240, symbol()))

    # Full logo: symbol above the wordmark.
    size = 96
    _, w_access = text_paths("Access", font, size, 0, 0, NAVY)
    _, w_path = text_paths("Path", font, size, 0, 0, GOLD)
    word_w = w_access + w_path
    W = int(word_w + 160)
    sym_h = 220
    sym_w = sym_h * 200 / 240
    top = 80
    H = int(top + sym_h + 48 + size * 0.73 + 80)
    baseline = top + sym_h + 48 + size * 0.73
    x0 = (W - word_w) / 2
    a, _ = text_paths("Access", font, size, x0, baseline, NAVY)
    p, _ = text_paths("Path", font, size, x0 + w_access, baseline, GOLD)
    sym = f'<g transform="translate({(W - sym_w) / 2:.2f} {top}) scale({sym_h / 240:.4f})">{symbol()}</g>'
    open(f"{out}/accesspath-logo.svg", "w").write(svg(W, H, sym + a + p, bg=WHITE))

    # Horizontal lockup for headers and slides.
    hs = 150
    hw = hs * 200 / 240
    gap = 36
    W2 = int(48 + hw + gap + word_w + 48)
    H2 = int(hs + 96)
    base2 = H2 / 2 + size * 0.73 / 2
    a2, _ = text_paths("Access", font, size, 48 + hw + gap, base2, NAVY)
    p2, _ = text_paths("Path", font, size, 48 + hw + gap + w_access, base2, GOLD)
    sym2 = f'<g transform="translate(48 48) scale({hs / 240:.4f})">{symbol(cid="h")}</g>'
    open(f"{out}/accesspath-logo-horizontal.svg", "w").write(svg(W2, H2, sym2 + a2 + p2, bg=WHITE))

    # App icon: white pin on navy so it stands out on a home screen.
    icon = (
        f'<rect width="1024" height="1024" rx="224" fill="{NAVY}"/>'
        f'<g transform="translate({512 - 640 * 200 / 240 / 2:.2f} 192) scale({640 / 240:.4f})">'
        f'{symbol(pin=WHITE, disc=NAVY, road=GOLD, marks=NAVY, cid="i")}</g>'
    )
    open(f"{out}/accesspath-app-icon.svg", "w").write(svg(1024, 1024, icon))

    # Full-bleed square for Android adaptive and web maskable icons:
    # the symbol stays inside the central safe zone (66% of the width).
    bleed = (
        f'<rect width="1024" height="1024" fill="{NAVY}"/>'
        f'<g transform="translate({512 - 540 * 200 / 240 / 2:.2f} 242) scale({540 / 240:.4f})">'
        f'{symbol(pin=WHITE, disc=NAVY, road=GOLD, marks=NAVY, cid="m")}</g>'
    )
    open(f"{out}/accesspath-app-icon-maskable.svg", "w").write(svg(1024, 1024, bleed))


if __name__ == "__main__":
    main(sys.argv[1])
