"""Gera docs/keyboard.md a partir dos layouts do Vial (.vil) em keyboard/corne/.

Uso: python3 keyboard/render.py          (reescreve o doc)
     python3 keyboard/render.py --check  (falha se o doc estiver desatualizado; usado no lint)
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LAYOUTS = [
    ("corne.vil", "Seu layout atual"),
    ("corne-devenv.vil", "Sugestão do devenv"),
]
DOC = ROOT / "docs" / "keyboard.md"

NAMES = {
    "NO": "", "TRNS": "▽", "GESC": "Esc/`", "LSHIFT": "Shift", "RSHIFT": "Shift",
    "LCTRL": "Ctrl", "RCTRL": "Ctrl", "LALT": "Alt", "RALT": "AltGr", "LGUI": "Super",
    "RGUI": "Super", "CAPSLOCK": "Caps", "TAB": "Tab", "ENTER": "Enter", "SPACE": "Espaço",
    "BSPACE": "⌫", "DELETE": "Del", "ESCAPE": "Esc", "QUOTE": "'", "SCOLON": ";",
    "COMMA": ",", "DOT": ".", "SLASH": "/", "BSLASH": "\\", "GRAVE": "`", "MINUS": "-",
    "EQUAL": "=", "LBRACKET": "[", "RBRACKET": "]", "VOLU": "Vol+", "VOLD": "Vol-",
    "MUTE": "Mudo", "MPLY": "⏯", "MNXT": "⏭", "MPRV": "⏮", "BRIU": "Brilho+",
    "BRID": "Brilho-", "LEFT": "←", "DOWN": "↓", "UP": "↑", "RIGHT": "→", "HOME": "Home",
    "END": "End", "PGUP": "PgUp", "PGDOWN": "PgDn", "PSCREEN": "Print", "WSCH": "Busca",
    "MS_L": "🖱←", "MS_D": "🖱↓", "MS_U": "🖱↑", "MS_R": "🖱→", "BTN1": "Clique", "BTN2": "Clique dir.",
}
SHIFTED = {
    "1": "!", "2": "@", "3": "#", "4": "$", "5": "%", "6": "^", "7": "&", "8": "*", "9": "(",
    "0": ")", "MINUS": "_", "EQUAL": "+", "LBRACKET": "{", "RBRACKET": "}", "BSLASH": "|",
    "COMMA": "<", "DOT": ">", "GRAVE": "~", "QUOTE": '"', "SCOLON": ":", "SLASH": "?",
}


def label(code, macros):
    if code == -1:
        return None
    if m := re.fullmatch(r"LSFT\(KC_(\w+)\)", code):
        return SHIFTED.get(m[1], "Shift+" + m[1])
    if m := re.fullmatch(r"MO\((\d)\)", code):
        return f"Camada {m[1]}"
    if m := re.fullmatch(r"M(\d+)", code):
        text = "".join(a[1] for a in macros[int(m[1])] if a and a[0] == "text")
        return f"macro `{text}`" if text else f"macro {m[1]}"
    key = code.removeprefix("KC_")
    return NAMES.get(key, key)


def cell(text):
    return text.replace("|", "\\|").replace("`", "\\`") if not text.startswith("macro") else text.replace("|", "\\|")


def render_layout(path, title):
    data = json.loads(path.read_text())
    out = [f"## {title} (`keyboard/corne/{path.name}`)", ""]
    for i, layer in enumerate(data["layout"]):
        if all(code in ("KC_TRNS", -1) for row in layer for code in row):
            continue
        out += [f"### Camada {i}", ""]
        cols = len(layer[0])
        out.append("| " + " | ".join(str(c) for c in range(cols)) + " |")
        out.append("|" + " --- |" * cols)
        for row in layer:
            cells = [label(c, data["macro"]) for c in row]
            out.append("| " + " | ".join("·" if c is None else cell(c) for c in cells) + " |")
        out.append("")
    combos = [c for c in data["combo"] if c[-1] != "KC_NO"]
    if combos:
        out += ["### Combos", "", "| Teclas juntas | Resultado |", "| --- | --- |"]
        for c in combos:
            keys = " + ".join(cell(label(k, data["macro"])) for k in c[:-1] if k != "KC_NO")
            out.append(f"| {keys} | {cell(label(c[-1], data['macro']))} |")
        out.append("")
    return out


def main():
    lines = [
        "# Teclado: Corne v4.1 (Vial)",
        "",
        "<!-- Gerado por keyboard/render.py a partir dos .vil. Não edite à mão: rode `just keyboard-doc`. -->",
        "",
        "As tabelas seguem a matriz do firmware, na ordem em que o Vial salva o arquivo (4 linhas × 12 colunas).",
        "As colunas 0–5 são a metade esquerda; as teclas extras e os polegares ficam nas linhas e colunas do fim.",
        "`▽` = transparente (usa a camada de baixo), `·` = sem tecla nessa posição.",
        "",
        "Para mudar: abra o Vial (comando `Vial`), edite ao vivo e salve com *File → Save current layout* por cima do",
        "`.vil` do repo. Para testar a sugestão: *File → Load saved layout* e escolha `corne-devenv.vil`.",
        "Detalhes em [desktop.md](desktop.md#teclado).",
        "",
    ]
    for name, title in LAYOUTS:
        lines += render_layout(ROOT / "keyboard" / "corne" / name, title)
    text = "\n".join(lines).rstrip() + "\n"
    if "--check" in sys.argv:
        if not DOC.exists() or DOC.read_text() != text:
            print("docs/keyboard.md desatualizado: rode `just keyboard-doc`", file=sys.stderr)
            return 1
        return 0
    DOC.write_text(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
