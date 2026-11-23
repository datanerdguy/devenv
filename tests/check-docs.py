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
PASTAS_DO_REPO = {"home", "docs", "tests", "packages", "agents", "keyboard", "temas", "wallpapers", "modelos", ".github", ".githooks"}
PASTAS_DO_NVIM = {"lua", "after"}
EXTENSOES_DE_CODIGO = {".lua", ".sh", ".py", ".fish", ".kdl"}
DOCS = [*REPO.glob("*.md"), *REPO.glob("docs/*.md"), *REPO.glob("keyboard/*.md"), *REPO.glob("templates/*.md")]
CRASES = re.compile(r"`([^`\s]+)`")
NOMES_NO_REPO = {p.name for p in REPO.rglob("*") if ".git" not in p.parts}


def citacao_quebrada(caminho: str) -> bool:
    caminho = caminho.rstrip("/").split(":", 1)[0]  # `arquivo.lua:12` aponta uma linha
    if "<" in caminho:
        return False
    if "/" not in caminho:
        return Path(caminho).suffix in EXTENSOES_DE_CODIGO and caminho not in NOMES_NO_REPO
    primeira = caminho.split("/", 1)[0]
    raiz = REPO if primeira in PASTAS_DO_REPO else NVIM if primeira in PASTAS_DO_NVIM else None
    if raiz is None:
        return False
    return not (any(raiz.glob(caminho)) if "*" in caminho else (raiz / caminho).exists())


def arvore_quebrada(linhas: list[str]) -> list[tuple[int, str]]:
    """Linhas de uma árvore (`pasta/` e, abaixo, os itens indentados) cujo item não existe."""
    pilha = [(-1, REPO / linhas[0][1].strip())]
    quebradas = []
    for n, linha in linhas[1:]:
        nome = linha.split()[0] if linha.strip() else ""
        if not nome:
            continue
        recuo = len(linha) - len(linha.lstrip())
        while recuo <= pilha[-1][0]:
            pilha.pop()
        caminho = pilha[-1][1] / nome.rstrip("/")
        if not caminho.exists():
            quebradas.append((n, nome))
        pilha.append((recuo, caminho))
    return quebradas


def main() -> int:
    erros = []
    for doc in DOCS:
        nome_doc = doc.relative_to(REPO)
        linhas = doc.read_text().splitlines()
        arvore = None
        for n, linha in enumerate(linhas, 1):
            if linha.startswith("```"):
                if arvore is not None:
                    erros += [f"{nome_doc}:{m}: `{item}` não existe" for m, item in arvore_quebrada(arvore)]
                    arvore = None
                elif linha == "```text" and n < len(linhas) and linhas[n].split("/", 1)[0] in PASTAS_DO_REPO:
                    arvore = []
                continue
            if arvore is not None:
                arvore.append((n, linha))
                continue
            erros += [f"{nome_doc}:{n}: `{c}` não existe" for c in CRASES.findall(linha) if citacao_quebrada(c)]
    for erro in erros:
        print(erro, file=sys.stderr)
    return 1 if erros else 0


if __name__ == "__main__":
    sys.exit(main())
