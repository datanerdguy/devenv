#!/usr/bin/env python3
"""Gera as paletas do Noctalia a partir dos temas oficiais que vêm no Ghostty.

Uso:
  python3 themes/generate.py          escreve home/dot_config/noctalia/palettes/<variante>.json
  python3 themes/generate.py --check  falha se alguma paleta do repo não bate com o que seria gerado

As cores do terminal vêm do arquivo do Ghostty. As cores da interface (barra, bordas, botões) saem delas:
o fundo, o texto e três cores de destaque escolhidas por família na tabela ACCENTS.
"""

import json
import sys
from pathlib import Path

GHOSTTY = Path("/usr/share/ghostty/themes")
OUTPUT_DIR = Path(__file__).resolve().parent.parent / "home/dot_config/noctalia/palettes"

# variante -> nome do tema no Ghostty. Só as variantes escuras.
VARIANTS = {
    "nord": "Nord",
    "everforest-hard": "Everforest Dark Hard",
    "everforest-medium": "Everforest Dark Med",
    "everforest-soft": "Everforest Dark Soft",
    "rose-pine": "Rose Pine",
    "rose-pine-moon": "Rose Pine Moon",
    "catppuccin-mocha": "Catppuccin Mocha",
    "catppuccin-macchiato": "Catppuccin Macchiato",
    "catppuccin-frappe": "Catppuccin Frappe",
    "dracula": "Dracula",
    "kanagawa-wave": "Kanagawa Wave",
    "kanagawa-dragon": "Kanagawa Dragon",
}

# Família -> cores ANSI (0-15) usadas como primária, secundária e terciária.
# 2 verde, 4 azul, 5 magenta, 6 ciano. O padrão serve para quem não está na tabela.
ACCENTS = {
    "nord": (6, 4, 5),  # frost: ciano #88c0d0 em destaque
    "everforest": (2, 4, 5),
    "rose-pine": (5, 6, 4),  # iris
}
DEFAULT_ACCENTS = (4, 5, 6)

ANSI_NAMES = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]


def read_ghostty(name: str) -> dict:
    colors = {}
    for line in (GHOSTTY / name).read_text().splitlines():
        key, _, value = line.partition("=")
        key, value = key.strip(), value.strip()
        if key == "palette":
            index, _, color = value.partition("=")
            colors[int(index)] = color.strip().lower()
        elif key:
            colors[key] = value.lower()
    return colors


def mix(a: str, b: str, amount: float) -> str:
    """Cor entre a e b: 0 é a, 1 é b."""
    ca = [int(a[i : i + 2], 16) for i in (1, 3, 5)]
    cb = [int(b[i : i + 2], 16) for i in (1, 3, 5)]
    return "#" + "".join(f"{round(x + (y - x) * amount):02x}" for x, y in zip(ca, cb))


def palette(variant: str, g: dict) -> dict:
    background, foreground = g["background"], g["foreground"]
    family = next((f for f in ACCENTS if variant.startswith(f)), None)
    p, s, t = (g[i] for i in ACCENTS.get(family, DEFAULT_ACCENTS))
    return {
        "dark": {
            "mPrimary": p,
            "mOnPrimary": background,
            "mSecondary": s,
            "mOnSecondary": background,
            "mTertiary": t,
            "mOnTertiary": background,
            "mError": g[1],
            "mOnError": background,
            "mSurface": background,
            "mOnSurface": foreground,
            "mSurfaceVariant": mix(background, foreground, 0.08),
            "mOnSurfaceVariant": mix(foreground, background, 0.25),
            "mOutline": g[8],
            "mShadow": mix(background, "#000000", 0.4),
            "mHover": s,
            "mOnHover": background,
            "terminal": {
                "foreground": foreground,
                "background": background,
                "cursor": g.get("cursor-color", foreground),
                "cursorText": g.get("cursor-text", background),
                "selectionBg": g.get("selection-background", mix(background, foreground, 0.25)),
                "selectionFg": g.get("selection-foreground", foreground),
                "normal": {n: g[i] for i, n in enumerate(ANSI_NAMES)},
                "bright": {n: g[i + 8] for i, n in enumerate(ANSI_NAMES)},
            },
        }
    }


def main() -> int:
    check = "--check" in sys.argv
    if not GHOSTTY.is_dir():
        print(f"Sem os temas do Ghostty em {GHOSTTY}: instale o grupo terminal.", file=sys.stderr)
        return 1
    different = []
    for variant, name in VARIANTS.items():
        content = json.dumps(palette(variant, read_ghostty(name)), indent=2) + "\n"
        file = OUTPUT_DIR / f"{variant}.json"
        if check:
            if not file.is_file() or file.read_text() != content:
                different.append(file.name)
        else:
            OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
            file.write_text(content)
    extra = sorted({a.stem for a in OUTPUT_DIR.glob("*.json")} - VARIANTS.keys())
    if check and (different or extra):
        print("Paletas fora do gerador (rode `python3 themes/generate.py`):", *different, *extra, file=sys.stderr)
        return 1
    if not check:
        print(f"{len(VARIANTS)} paletas em {OUTPUT_DIR}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
