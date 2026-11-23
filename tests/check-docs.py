#!/usr/bin/env python3
"""Confere que os arquivos citados nos docs existem no repo. Roda no `just lint`.

Um arquivo que muda de lugar ou de nome deixa o doc apontando para o antigo. Isto confere:
- caminho entre crases que começa numa pasta do repo (`home/...`, `tests/...`) ou da config do Neovim (`lua/...`);
- nome de arquivo de código entre crases (`theme.lua`, `smoke.sh`): precisa existir em algum lugar do repo;
- as árvores de pastas (bloco ```text que começa numa pasta do repo, como `home/dot_config/nvim/`).
Caminho com * vale se casar com algum arquivo; exemplos com <...> ficam de fora. Os ADRs também: são o registro de
quando foram escritos e citam arquivos que já saíram.
"""

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
NVIM = REPO / "home/dot_config/nvim"
REPO_DIRS = {"home", "docs", "tests", "packages", "agents", "keyboard", "themes", "wallpapers", "templates", ".github", ".githooks"}
NVIM_DIRS = {"lua", "after"}
CODE_EXTENSIONS = {".lua", ".sh", ".py", ".fish", ".kdl"}
DOCS = [*REPO.glob("*.md"), *REPO.glob("docs/*.md"), *REPO.glob("keyboard/*.md"), *REPO.glob("templates/*.md")]
BACKTICKS = re.compile(r"`([^`\s]+)`")
REPO_NAMES = {p.name for p in REPO.rglob("*") if ".git" not in p.parts}


def is_broken_citation(path: str) -> bool:
    path = path.rstrip("/").split(":", 1)[0]  # `arquivo.lua:12` aponta uma linha
    if "<" in path:
        return False
    if "/" not in path:
        return Path(path).suffix in CODE_EXTENSIONS and path not in REPO_NAMES
    first = path.split("/", 1)[0]
    root = REPO if first in REPO_DIRS else NVIM if first in NVIM_DIRS else None
    if root is None:
        return False
    return not (any(root.glob(path)) if "*" in path else (root / path).exists())


def broken_tree_items(lines: list[str]) -> list[tuple[int, str]]:
    """Linhas de uma árvore (`pasta/` e, abaixo, os itens indentados) cujo item não existe."""
    stack = [(-1, REPO / lines[0][1].strip())]
    broken = []
    for n, line in lines[1:]:
        name = line.split()[0] if line.strip() else ""
        if not name:
            continue
        indent = len(line) - len(line.lstrip())
        while indent <= stack[-1][0]:
            stack.pop()
        path = stack[-1][1] / name.rstrip("/")
        if not path.exists():
            broken.append((n, name))
        stack.append((indent, path))
    return broken


def main() -> int:
    errors = []
    for doc in DOCS:
        doc_name = doc.relative_to(REPO)
        lines = doc.read_text().splitlines()
        tree = None
        for n, line in enumerate(lines, 1):
            if line.startswith("```"):
                if tree is not None:
                    errors += [f"{doc_name}:{m}: `{item}` não existe" for m, item in broken_tree_items(tree)]
                    tree = None
                elif line == "```text" and n < len(lines) and lines[n].split("/", 1)[0] in REPO_DIRS:
                    tree = []
                continue
            if tree is not None:
                tree.append((n, line))
                continue
            errors += [f"{doc_name}:{n}: `{c}` não existe" for c in BACKTICKS.findall(line) if is_broken_citation(c)]
    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
