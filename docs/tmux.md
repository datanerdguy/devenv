# tmux + sesh

tmux configurado do zero, **sem plugins** (abre na hora), e [sesh](https://github.com/joshmedeski/sesh) para sessões por projeto.
Módulo: [`modules/tmux`](../modules/tmux/default.nix) (`devenv.tmux.enable`); atalhos em [`tmux.conf`](../modules/tmux/tmux.conf).

## Atalhos

Prefixo: **`Ctrl-Space`**. Na tabela, `P` = prefixo.

| Tecla | O que faz |
| --- | --- |
| `Ctrl-h/j/k/l` | anda entre painéis do tmux **e** janelas do Neovim (sem prefixo) |
| `P h/j/k/l` | anda entre painéis (o mesmo, com prefixo) |
| `P H/J/K/L` | redimensiona (repete sem o prefixo; no Neovim, `Ctrl-setas`) |
| `P \|` / `P -` | divide na vertical / horizontal, na pasta atual |
| `P c` | nova janela na pasta atual |
| `P p` / `P n` | janela anterior / próxima |
| `P Tab` | última janela |
| `P z` | zoom no painel |
| `P x` | fecha o painel |
| `P s` | **sesh**: lista de sessões e projetos (fzf) |
| `P S` | volta para a sessão anterior |
| `P g` | lazygit em popup |
| `P a` | painel dos agentes (workmux dashboard) |
| `P u` | uso e custo dos agentes (tokscale) |
| `P t` | shell em popup |
| `P v` | modo de cópia (vi: `v` seleciona, `Ctrl-v` bloco, `y` copia para o clipboard) |
| `P Ctrl-l` | limpa a tela do shell (o `Ctrl-l` sozinho é navegação) |
| `P r` | recarrega a config |

O mouse funciona (selecionar painel, rolar, redimensionar).

Nenhum atalho usa Alt: ele é do niri ([desktop.md](desktop.md#atalhos-niri)).

## Sessões com sesh

`P s` abre a lista: sessões abertas, projetos do zoxide (as pastas que você mais visita) e as sessões configuradas.
Escolher um projeto cria a sessão nele, ou volta para ela se já existir.

Sessões fixas ficam em `programs.sesh.settings.session` no módulo. Hoje há uma: `devenv`, que abre o Neovim em `~/devenv`.

## Integração com o Neovim

O Neovim marca o painel com `@pane-is-vim` ao abrir (`lua/pcastr/plugins/editor.lua`). O tmux vê a marca e
repassa `Ctrl-h/j/k/l` ao Neovim, que usa o smart-splits para mudar de janela ou sair para o painel vizinho na borda.
Imagens (molten/image.nvim) passam pelo tmux com `allow-passthrough`.

## Barra de status

No topo: sessão, janelas (com o ícone de status dos agentes do workmux), cota do Claude e hora.
As cores seguem o tema atual ([themes.md](themes.md)): `theme <nome>` troca a barra na hora.

## Por que sem plugins

TPM e plugins como tmux-sensible, resurrect e catppuccin somam segundos de abertura e mais coisas para atualizar.
O que eles dariam aqui é coberto por poucas linhas de config, pelo sesh (sessões) e pelo workmux (janelas dos agentes).
