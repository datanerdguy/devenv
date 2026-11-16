"""Junta as chaves gerenciadas pelo devenv num arquivo de config que o próprio agente também edita.

Uso: merge-config.py <destino> <fragmento.json>

- O destino é JSON. Se não existir, é criado.
- Dicionários são mesclados recursivamente; o resto (listas, valores) é substituído pelo
  fragmento. Chaves que o agente ou você criaram e o fragmento não cita ficam como estão.
- Um JSON inválido no destino é guardado em <destino>.bak e recomeçado do fragmento.
"""

import json
import shutil
import sys
from pathlib import Path


def merge(base, extra):
    for key, value in extra.items():
        if isinstance(value, dict) and isinstance(base.get(key), dict):
            merge(base[key], value)
        else:
            base[key] = value
    return base


def main() -> int:
    target, fragment = Path(sys.argv[1]), Path(sys.argv[2])
    extra = json.loads(fragment.read_text())
    target.parent.mkdir(parents=True, exist_ok=True)

    text = target.read_text() if target.exists() else ""
    try:
        base = json.loads(text) if text.strip() else {}
    except Exception as err:  # arquivo quebrado: guarda e recomeça
        shutil.copy2(target, target.with_name(target.name + ".bak"))
        print(f"aviso: {target} inválido ({err}); cópia em {target.name}.bak", file=sys.stderr)
        base = {}

    merge(base, extra)
    out = json.dumps(base, indent=2, ensure_ascii=False) + "\n"
    if out != text:
        tmp = target.with_name(target.name + ".devenv-tmp")
        tmp.write_text(out)
        tmp.replace(target)  # escrita atômica: o agente nunca lê um arquivo pela metade
    return 0


if __name__ == "__main__":
    sys.exit(main())
