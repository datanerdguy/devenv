# 0008. Atalhos: Alt nas janelas, como no i3

Data: 2026-10-24 · Status: aceita

## Contexto

O niri e o sway/i3 do devenv usavam Super + `h/j/k/l`. O Lucas usa o i3 padrão há tempo: Alt + `j/k/l/;`, `Shift`
move, `Alt+d` abre o launcher, `Alt+Shift+q` fecha. O Corne (Vial) não tem tecla Super, e o polegar já procura o Alt.
O tmux, o Neovim e o Ghostty do devenv tinham atalhos com Alt (redimensionar, mover linhas, rolar), que brigariam
com um compositor no Alt.

## Decisão

- **Alt** (`mod-key "Alt"` no niri, `Mod1` no sway/i3) cuida das janelas, com as teclas do i3 padrão:
  `j/k/l/;` andam, `Shift` move, `Ctrl` muda de monitor, `Alt+1..0` e `Alt+Shift+1..0` nas áreas.
- **Super** abre apps e o sistema: navegador, notas, arquivos, tema, histórico de cópias, bloqueio, capturas.
  Assim o niri pega o mínimo de combinações com Alt.
- **Sem Alt no tmux, no Neovim e no Ghostty:** o tmux redimensiona com prefixo + `H/J/K/L` (como o tmux antigo do
  Lucas) e troca de janela com `p`/`n`; o Neovim redimensiona com `Ctrl-setas` e move a seleção com `J`/`K`;
  o Ghostty rola e troca de aba com `Ctrl+Shift`.
- O prefixo do tmux continua `Ctrl-Space`, e `Ctrl-h/j/k/l` continua andando entre tmux e Neovim.

## Alternativas consideradas

- **Manter Super + `h/j/k/l`:** um padrão só com o Neovim, mas muda o hábito do i3 e não funciona no Corne sem
  mexer no firmware.
- **Super no polegar do Corne e Alt↔Super no kanata do notebook:** mantém o gesto sem mudar os apps, mas mexe nos
  dois teclados e ainda troca as teclas de navegação.
- **Alt só nesta máquina (`niri-local.kdl`):** sem mexer no repo, mas os atalhos com Alt do tmux e do Neovim
  deixariam de funcionar.

## Consequências

- Combinações com Alt que o compositor usa somem dos apps: no fish, `Alt+l`, `Alt+e`, `Alt+s` e `Alt+h` (o mesmo
  que já acontecia no i3). `Alt+b`, `Alt+f` e o `Alt+c` do fzf continuam, porque ficaram fora do niri.
- No picker do Snacks, `Alt+r`, `Alt+w` e `Alt+f` são do niri; o `:Pack` remove com `Alt-x` (era `Alt-d`).
- O niri não tem divisões nem modos: `Alt+[`/`Alt+]` e `Alt+r` fazem o papel do `split` e do modo de redimensionar.
