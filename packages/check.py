#!/usr/bin/env python3
"""Confere os grupos do metapac. Roda no `just lint`.

- Um pacote aparece uma vez só entre todos os grupos.
- Todo grupo de groups/ está em alguma máquina de config.toml, e toda máquina só cita grupos que existem.
- Todo grupo começa com um comentário dizendo para que serve (é onde se decide em qual grupo vai um pacote).
- O ci-full testa todos os grupos, menos o debug (comentado) e os de machines/ (o hardware de cada uma).
"""

import sys
import tomllib
from collections import defaultdict
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
OUTSIDE_CI = {"debug"}


def package_name(package) -> str:
    return package if isinstance(package, str) else package["name"]


def main() -> int:
    groups = {p.relative_to(BASE_DIR / "groups").with_suffix("").as_posix(): p for p in (BASE_DIR / "groups").rglob("*.toml")}
    machines = tomllib.loads((BASE_DIR / "config.toml").read_text())["hostname_groups"]
    errors = []

    groups_by_package = defaultdict(list)
    for group, file in groups.items():
        if not file.read_text().startswith("# "):
            errors.append(f"packages/groups/{group}.toml: comece com um comentário (# ...) dizendo para que serve o grupo.")
        for backend, table in tomllib.loads(file.read_text()).items():
            for package in table.get("packages", []):
                groups_by_package[(backend, package_name(package))].append(group)
    for (backend, package), group_names in sorted(groups_by_package.items()):
        if len(group_names) > 1:
            errors.append(f"{package} ({backend}) está em mais de um grupo: {', '.join(group_names)}. Deixe em um só.")

    cited = {g for group_names in machines.values() for g in group_names}
    for g in sorted(cited - groups.keys()):
        errors.append(f"config.toml cita o grupo {g}, mas não existe packages/groups/{g}.toml.")
    for g in sorted(groups.keys() - cited):
        errors.append(f"O grupo {g} não está em nenhuma máquina de config.toml: ele nunca seria instalado.")

    expected = {g for g in groups if g not in OUTSIDE_CI and not g.startswith("machines/")}
    missing = sorted(expected - set(machines.get("ci-full", [])))
    if missing:
        errors.append(f"O ci-full de config.toml não testa: {', '.join(missing)}. Acrescente lá.")

    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
