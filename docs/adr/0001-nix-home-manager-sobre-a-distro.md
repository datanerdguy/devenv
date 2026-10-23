# 0001. Nix + home-manager sobre a distro

Data: 2026-10-23 · Status: aceita

## Contexto

O ambiente precisa ser reproduzível, rastreável e adaptável, rodar em Fedora e em outras distros populares, e servir para aprender Nix sem trocar o sistema operacional.

## Decisão

- Todo o ambiente de usuário (CLIs, shell, editor, terminal, agentes) é declarado com **Nix flakes + home-manager**. O `flake.lock` fixa a versão exata de cada pacote.
- O que precisa de root ou de integração direta com a GPU (driver NVIDIA, compositor, binário do Ghostty) vem da distro, por `system/<distro>.sh`.
- Cada parte é um módulo com `devenv.<nome>.enable`; cada máquina é um arquivo em `hosts/` que liga o que usa.

## Alternativas consideradas

- **NixOS completo:** reprodutibilidade máxima, mas só funciona no NixOS. Fica como caminho futuro; os módulos home-manager são reaproveitados.
- **chezmoi + mise:** curva menor, mas não fixa as versões do sistema nem dá rollback.
- **Omarchy:** ótima referência de experiência, mas é só para Arch e baseado em scripts.

## Consequências

- Apps gráficos instalados pelo Nix fora do NixOS podem precisar de ajuda para achar a GPU; por isso o binário do Ghostty vem da distro.
- Atualizar é explícito (`just update`) e revisável (`just diff`); voltar atrás é trocar de geração.
