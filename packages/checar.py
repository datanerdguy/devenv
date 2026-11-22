#!/usr/bin/env python3
"""Confere os grupos do metapac. Roda no `just lint`.

- Um pacote aparece uma vez só entre todos os grupos.
- Todo grupo de groups/ está em alguma máquina de config.toml, e toda máquina só cita grupos que existem.
- Todo grupo começa com um comentário dizendo para que serve (é onde se decide em qual grupo vai um pacote).
- O ci-completo testa todos os grupos, menos o debug (comentado) e os de maquinas/ (o hardware de cada uma).
"""

import sys
import tomllib
from collections import defaultdict
from pathlib import Path

PASTA = Path(__file__).resolve().parent
FORA_DO_CI = {"debug"}


def nome(pacote) -> str:
    return pacote if isinstance(pacote, str) else pacote["name"]


def main() -> int:
    grupos = {p.relative_to(PASTA / "groups").with_suffix("").as_posix(): p for p in (PASTA / "groups").rglob("*.toml")}
    maquinas = tomllib.loads((PASTA / "config.toml").read_text())["hostname_groups"]
    erros = []

    onde = defaultdict(list)
    for grupo, arquivo in grupos.items():
        if not arquivo.read_text().startswith("# "):
            erros.append(f"packages/groups/{grupo}.toml: comece com um comentário (# ...) dizendo para que serve o grupo.")
        for backend, tabela in tomllib.loads(arquivo.read_text()).items():
            for pacote in tabela.get("packages", []):
                onde[(backend, nome(pacote))].append(grupo)
    for (backend, pacote), lista in sorted(onde.items()):
        if len(lista) > 1:
            erros.append(f"{pacote} ({backend}) está em mais de um grupo: {', '.join(lista)}. Deixe em um só.")

    citados = {g for lista in maquinas.values() for g in lista}
    for g in sorted(citados - grupos.keys()):
        erros.append(f"config.toml cita o grupo {g}, mas não existe packages/groups/{g}.toml.")
    for g in sorted(grupos.keys() - citados):
        erros.append(f"O grupo {g} não está em nenhuma máquina de config.toml: ele nunca seria instalado.")

    esperado = {g for g in grupos if g not in FORA_DO_CI and not g.startswith("maquinas/")}
    faltam = sorted(esperado - set(maquinas.get("ci-completo", [])))
    if faltam:
        erros.append(f"O ci-completo de config.toml não testa: {', '.join(faltam)}. Acrescente lá.")

    for erro in erros:
        print(erro, file=sys.stderr)
    return 1 if erros else 0


if __name__ == "__main__":
    sys.exit(main())
