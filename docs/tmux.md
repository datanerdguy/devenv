# tmux

O tmux fica sem plugins e abre na hora. O sesh cuida das sessões por projeto, e o workmux abre uma janela por
tarefa com o Claude. A config fica em `home/dot_config/tmux/tmux.conf`, e os pacotes ficam no grupo `tmux`.
As decisões estão no [ADR 0014](adr/0014-tmux.md).

O Ghostty abre o fish puro. Para entrar no tmux, rode `t`: ele mostra a lista de sessões e projetos e entra na
escolhida (cria a sessão se ela não existir).

## Atalhos

Prefixo: **`Ctrl-Space`**. Na tabela, `P` é o prefixo.

| Tecla | O que faz |
| --- | --- |
| `Ctrl-h/j/k/l` | Anda entre painéis do tmux e janelas do Neovim (sem prefixo) |
| `P h/j/k/l` | Anda entre painéis (o mesmo, com prefixo) |
| `P H/J/K/L` | Redimensiona (repete sem o prefixo) |
| `P \|` / `P -` | Divide na vertical / horizontal, na pasta atual |
| `P c` | Janela nova na pasta atual |
| `P p` / `P n` / `P Tab` | Janela anterior / próxima / última |
| `P z` | Zoom no painel (a janela mostra 󰊓) |
| `P x` | Fecha o painel |
| `P s` | Sessões e projetos (sesh), a mesma lista do `t` |
| `P S` | Volta para a sessão anterior |
| `P g` | lazygit em popup |
| `P t` | Shell em popup |
| `P a` | Painel dos agentes (workmux) |
| `P u` | Links da tela num fzf; o `Enter` abre no navegador |
| `P v` | Modo de cópia: `v` seleciona, `Ctrl-v` faz bloco, `y` copia para o clipboard do sistema |
| `P Ctrl-l` | Limpa a tela do shell (o `Ctrl-l` sozinho anda entre painéis) |
| `P r` | Recarrega a config |

O mouse funciona: seleciona painel, rola e redimensiona. Nenhum atalho usa Alt, porque o Alt é do niri
([desktop.md](desktop.md)). Por causa do `Ctrl-k`, a busca nos manuais do fish fica no `Ctrl+O`
([shell.md](shell.md)).

## Sessões (sesh)

A lista mostra as sessões abertas, as sessões fixas e os projetos do zoxide (as pastas que você mais visita).
As sessões fixas ficam em `home/dot_config/sesh/sesh.toml`. Hoje há uma: `devenv`, que abre o Neovim no repo.

## Agentes (workmux)

`workmux add <branch>` cria um worktree e uma janela com o Claude em cima e um shell embaixo. A janela mostra o
estado do agente (trabalhando, esperando você, terminou). Esse estado vem dos hooks do Claude em
`agents/settings.json`, que só rodam dentro do tmux. `P a` abre o painel com todos os agentes.

A config fica em `home/dot_config/workmux/config.yaml`. O workmux não copia o `.env` para o worktree: os segredos
vêm do `rbw` na hora.

## Barra

Fica no topo e mostra a sessão (amarela enquanto o prefixo está apertado), as janelas, a cota do Claude e a hora.
A cota vem de `~/.cache/devenv/claude-usage`, que a statusline do Claude grava.

As cores seguem o tema ([temas.md](temas.md)). O Noctalia gera `~/.config/tmux/noctalia.conf` a cada `theme` e
recarrega o tmux aberto. Antes do primeiro `theme`, valem as cores do Nord que estão no `tmux.conf`.

## Neovim

O `Ctrl-h/j/k/l` passa para o Neovim quando o painel tem a marca `@pane-is-vim`. A marca e o lado do Neovim entram
com a área do Neovim. Até lá, essas teclas sempre trocam de painel.
