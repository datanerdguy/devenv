"""Gera as imagens das camadas do Corne e o keyboard/README.md a partir do layout do Vial (.vil).

Uso: python3 keyboard/render.py          (gera keyboard/img/*.svg e keyboard/README.md; `just keyboard`)
     python3 keyboard/render.py --check  (falha se algo estiver desatualizado; usado no lint)

O desenho é do keymap-drawer (https://github.com/caksoylar/keymap-drawer), que vem do devShell (`nix develop`).
Este script traduz o .vil para o formato dele, com as posições físicas do Corne v4.1 (keyboard/corne/layout.json).
"""

import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
VIL = ROOT / "corne" / "corne.vil"
PHYSICAL = ROOT / "corne" / "layout.json"
STYLE = ROOT / "keymap-drawer.yaml"
README = ROOT / "README.md"
IMG = ROOT / "img"

# O Vial salva cada camada como 4 linhas × 12 colunas (a matriz do firmware), que não é a ordem física.
# Posição no .vil (linha, coluna) → índice da tecla no LAYOUT_split_3x6_3_ex2 (layout.json):
#   linhas 0–2, colunas 0–5: as 3 linhas da metade esquerda, de fora para dentro
#   linhas 0–2, colunas 7–11: as 5 colunas de dentro da metade direita; a coluna de fora fica na linha 3 (9–11)
#   coluna 6 (linhas 0–1): as 2 teclas extras do meio, à direita; linha 3 (0–1): as 2 extras à esquerda
#   linha 3, colunas 3–5 e 6–8: polegares esquerdos (de fora para dentro) e direitos (de dentro para fora)
POSITION = {}
for r, base in enumerate((0, 14, 28)):
    for c in range(6):
        POSITION[(r, c)] = base + c
for r, base in enumerate((8, 22, 34)):
    for c in range(5):
        POSITION[(r, 7 + c)] = base + c
POSITION.update({
    (3, 9): 13, (3, 10): 27, (3, 11): 39,  # coluna de fora, à direita
    (0, 6): 7, (1, 6): 21,  # extras do meio, à direita
    (3, 0): 6, (3, 1): 20,  # extras do meio, à esquerda
    (3, 3): 40, (3, 4): 41, (3, 5): 42,  # polegares esquerdos
    (3, 6): 43, (3, 7): 44, (3, 8): 45,  # polegares direitos
})
KEYS = 46

NAMES = {
    "NO": "", "GESC": "Esc/`", "LSHIFT": "Shift", "RSHIFT": "Shift",
    "LCTRL": "Ctrl", "RCTRL": "Ctrl", "LALT": "Alt", "RALT": "AltGr", "LGUI": "Super",
    "RGUI": "Super", "CAPSLOCK": "Caps", "TAB": "Tab", "ENTER": "Enter", "SPACE": "Espaço",
    "BSPACE": "⌫", "DELETE": "Del", "ESCAPE": "Esc", "QUOTE": "'", "SCOLON": ";",
    "COMMA": ",", "DOT": ".", "SLASH": "/", "BSLASH": "\\", "GRAVE": "`", "MINUS": "-",
    "EQUAL": "=", "LBRACKET": "[", "RBRACKET": "]", "VOLU": "Vol+", "VOLD": "Vol-",
    "MUTE": "Mudo", "MPLY": "⏯", "MNXT": "⏭", "MPRV": "⏮", "BRIU": "Brilho+",
    "BRID": "Brilho-", "LEFT": "←", "DOWN": "↓", "UP": "↑", "RIGHT": "→", "HOME": "Home",
    "END": "End", "PGUP": "PgUp", "PGDOWN": "PgDn", "PSCREEN": "Print", "WSCH": "Busca",
    "MS_L": "Mouse ←", "MS_D": "Mouse ↓", "MS_U": "Mouse ↑", "MS_R": "Mouse →",
    "BTN1": "Clique", "BTN2": "Clique dir.",
}
# O que LSFT(tecla) manda.
SHIFTED = {
    "1": "!", "2": "@", "3": "#", "4": "$", "5": "%", "6": "^", "7": "&", "8": "*", "9": "(",
    "0": ")", "MINUS": "_", "EQUAL": "+", "LBRACKET": "{", "RBRACKET": "}", "BSLASH": "|",
    "COMMA": "<", "DOT": ">", "GRAVE": "~", "QUOTE": '"', "SCOLON": ":", "SLASH": "?",
}


def layer_name(i):
    return f"Camada {i}"


def key(code, macros):
    """Legenda de uma tecla no formato do keymap-drawer."""
    if code in (-1, "KC_NO"):
        return ""
    if code == "KC_TRNS":
        return {"t": "▽", "type": "trans"}
    if m := re.fullmatch(r"LSFT\(KC_(\w+)\)", code):
        return SHIFTED.get(m[1], "Shift+" + m[1])
    if m := re.fullmatch(r"MO\((\d)\)", code):
        return {"t": layer_name(int(m[1])), "h": "segure"}
    if m := re.fullmatch(r"M(\d+)", code):
        text = "".join(a[1] for a in macros[int(m[1])] if a and a[0] == "text")
        return {"t": text or f"Macro {m[1]}", "h": "macro"}
    name = code.removeprefix("KC_")
    return NAMES.get(name, name)


def to_positions(layer):
    codes = [None] * KEYS
    for (r, c), i in POSITION.items():
        codes[i] = layer[r][c]
    return codes


def build(data):
    """Monta o keymap (formato do keymap-drawer) e a lista de camadas usadas."""
    macros = data.get("macro", [])
    layers = {}
    codes_by_layer = {}
    for i, layer in enumerate(data["layout"]):
        if all(code in ("KC_TRNS", "KC_NO", -1) for row in layer for code in row):
            continue
        codes = to_positions(layer)
        codes_by_layer[i] = codes
        layers[layer_name(i)] = [key(c, macros) for c in codes]

    # Tecla que segura cada camada, marcada como "held" na imagem da camada.
    for i, codes in codes_by_layer.items():
        for j, other in codes_by_layer.items():
            for pos, code in enumerate(other):
                if code == f"MO({i})" and j < i:
                    k = layers[layer_name(i)][pos]
                    k = k if isinstance(k, dict) else {"t": k}
                    layers[layer_name(i)][pos] = {**k, "type": "held"}

    # Combos do Vial são por código de tecla: desenha na primeira camada que tem todas elas.
    combos = []
    for combo in data.get("combo", []):
        *trigger, result = combo
        trigger = [t for t in trigger if t != "KC_NO"]
        if result == "KC_NO" or not trigger:
            continue
        for i, codes in codes_by_layer.items():
            if all(t in codes for t in trigger):
                combos.append({
                    "p": [codes.index(t) for t in trigger],
                    "k": key(result, macros),
                    "l": [layer_name(i)],
                })
                break
    return {
        "layout": {"qmk_info_json": str(PHYSICAL), "layout_name": "LAYOUT_split_3x6_3_ex2"},
        "layers": layers,
        "combos": combos,
    }


def legend_text(k):
    return k if isinstance(k, str) else k.get("t", "")


def readme(keymap):
    layers = list(keymap["layers"])
    lines = [
        "# Teclado: Corne v4.1 (Vial)",
        "",
        "<!-- Gerado por keyboard/render.py a partir de keyboard/corne/corne.vil. Não edite à mão: rode `just keyboard`. -->",
        "",
        "O layout vive no teclado (firmware Vial) e o arquivo [`corne/corne.vil`](corne/corne.vil) guarda a cópia no repo.",
        "",
        "**Para mudar:** abra o Vial (comando `Vial`, ou [vial.rocks](https://vial.rocks) num navegador Chromium), mude ao vivo,",
        "salve com *File → Save current layout* por cima de `keyboard/corne/corne.vil` e rode `just keyboard`.",
        "As imagens e este README são refeitos; faça commit dos três.",
        "",
        "Legenda: `segure` = vale enquanto a tecla está apertada. `▽` = transparente (vale a",
        "camada de baixo). Na camada ativa, a tecla que você está segurando aparece destacada.",
        "",
        "## Todas as camadas",
        "",
        "![Todas as camadas](img/corne.svg)",
        "",
    ]
    for name in layers:
        slug = name.lower().replace(" ", "-")
        lines += [f"## {name}", "", f"![{name}](img/{slug}.svg)", ""]
    if keymap["combos"]:
        lines += ["## Combos", "", "Teclas apertadas juntas.", "", "| Teclas | Resultado | Camada |", "| --- | --- | --- |"]
        for c in keymap["combos"]:
            keys = " + ".join(legend_text(keymap["layers"][c["l"][0]][p]) for p in c["p"])
            lines.append(f"| {keys} | {legend_text(c['k'])} | {c['l'][0]} |")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def draw(keymap, out_dir):
    exe = shutil.which("keymap")
    if not exe:
        sys.exit("keymap-drawer não encontrado: rode dentro do `nix develop` (ou `just keyboard`).")
    out_dir.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        src = Path(tmp) / "keymap.json"  # JSON também é YAML
        src.write_text(json.dumps(keymap, ensure_ascii=False))
        base = [exe, "-c", str(STYLE), "draw", str(src)]
        subprocess.run([*base, "-o", str(out_dir / "corne.svg")], check=True)
        for name in keymap["layers"]:
            slug = name.lower().replace(" ", "-")
            subprocess.run([*base, "-s", name, "-o", str(out_dir / f"{slug}.svg")], check=True)


def main():
    keymap = build(json.loads(VIL.read_text()))
    text = readme(keymap)
    if "--check" in sys.argv:
        with tempfile.TemporaryDirectory() as tmp:
            draw(keymap, Path(tmp))
            stale = [p.name for p in Path(tmp).iterdir() if not (IMG / p.name).exists() or (IMG / p.name).read_bytes() != p.read_bytes()]
        if stale or not README.exists() or README.read_text() != text:
            print("keyboard/README.md ou keyboard/img desatualizados: rode `just keyboard`", file=sys.stderr)
            return 1
        return 0
    if IMG.exists():
        shutil.rmtree(IMG)
    draw(keymap, IMG)
    README.write_text(text)
    print(f"Pronto: {README.relative_to(ROOT.parent)} e {len(list(IMG.iterdir()))} imagens em keyboard/img/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
