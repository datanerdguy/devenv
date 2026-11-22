#!/usr/bin/env python3
"""Gera as paletas do Noctalia a partir dos temas oficiais que vêm no Ghostty.

Uso:
  python3 temas/gerar.py          escreve home/dot_config/noctalia/palettes/<variante>.json
  python3 temas/gerar.py --check  falha se alguma paleta do repo não bate com o que seria gerado

As cores do terminal vêm do arquivo do Ghostty. As cores da interface (barra, bordas, botões) saem delas:
o fundo, o texto e três cores de destaque escolhidas por família na tabela DESTAQUES.
"""

import json
import sys
from pathlib import Path

GHOSTTY = Path("/usr/share/ghostty/themes")
SAIDA = Path(__file__).resolve().parent.parent / "home/dot_config/noctalia/palettes"

# variante -> nome do tema no Ghostty. Só as variantes escuras.
VARIANTES = {
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
DESTAQUES = {
    "nord": (6, 4, 5),  # frost: ciano #88c0d0 em destaque
    "everforest": (2, 4, 5),  # verde
    "rose-pine": (5, 6, 4),  # iris
}
PADRAO = (4, 5, 6)

NOMES_ANSI = ["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]


def ler_ghostty(nome: str) -> dict:
    cores = {}
    for linha in (GHOSTTY / nome).read_text().splitlines():
        chave, _, valor = linha.partition("=")
        chave, valor = chave.strip(), valor.strip()
        if chave == "palette":
            indice, _, cor = valor.partition("=")
            cores[int(indice)] = cor.strip().lower()
        elif chave:
            cores[chave] = valor.lower()
    return cores


def misturar(a: str, b: str, quanto: float) -> str:
    """Cor entre a e b: 0 é a, 1 é b."""
    ca = [int(a[i : i + 2], 16) for i in (1, 3, 5)]
    cb = [int(b[i : i + 2], 16) for i in (1, 3, 5)]
    return "#" + "".join(f"{round(x + (y - x) * quanto):02x}" for x, y in zip(ca, cb))


def paleta(variante: str, g: dict) -> dict:
    fundo, texto = g["background"], g["foreground"]
    familia = next((f for f in DESTAQUES if variante.startswith(f)), None)
    p, s, t = (g[i] for i in DESTAQUES.get(familia, PADRAO))
    return {
        "dark": {
            "mPrimary": p,
            "mOnPrimary": fundo,
            "mSecondary": s,
            "mOnSecondary": fundo,
            "mTertiary": t,
            "mOnTertiary": fundo,
            "mError": g[1],
            "mOnError": fundo,
            "mSurface": fundo,
            "mOnSurface": texto,
            "mSurfaceVariant": misturar(fundo, texto, 0.08),
            "mOnSurfaceVariant": misturar(texto, fundo, 0.25),
            "mOutline": g[8],
            "mShadow": misturar(fundo, "#000000", 0.4),
            "mHover": s,
            "mOnHover": fundo,
            "terminal": {
                "foreground": texto,
                "background": fundo,
                "cursor": g.get("cursor-color", texto),
                "cursorText": g.get("cursor-text", fundo),
                "selectionBg": g.get("selection-background", misturar(fundo, texto, 0.25)),
                "selectionFg": g.get("selection-foreground", texto),
                "normal": {n: g[i] for i, n in enumerate(NOMES_ANSI)},
                "bright": {n: g[i + 8] for i, n in enumerate(NOMES_ANSI)},
            },
        }
    }


def main() -> int:
    checar = "--check" in sys.argv
    if not GHOSTTY.is_dir():
        print(f"Sem os temas do Ghostty em {GHOSTTY}: instale o grupo terminal.", file=sys.stderr)
        return 1
    diferentes = []
    for variante, nome in VARIANTES.items():
        texto = json.dumps(paleta(variante, ler_ghostty(nome)), indent=2) + "\n"
        arquivo = SAIDA / f"{variante}.json"
        if checar:
            if not arquivo.is_file() or arquivo.read_text() != texto:
                diferentes.append(arquivo.name)
        else:
            SAIDA.mkdir(parents=True, exist_ok=True)
            arquivo.write_text(texto)
    sobrando = sorted({a.stem for a in SAIDA.glob("*.json")} - VARIANTES.keys())
    if checar and (diferentes or sobrando):
        print("Paletas fora do gerador (rode `python3 temas/gerar.py`):", *diferentes, *sobrando, file=sys.stderr)
        return 1
    if not checar:
        print(f"{len(VARIANTES)} paletas em {SAIDA}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
