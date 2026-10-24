# Temas

Quatro temas escuros que mudam tudo de uma vez: terminal, Neovim, tmux, bordas do niri, barra e painéis do
Noctalia, e o papel de parede. A troca é na hora, sem `just switch`.

Módulo: [`modules/theme`](../modules/theme/default.nix) (`devenv.theme.enable`). Temas: [`themes/`](../themes/).
Decisão: [ADR 0005](adr/0005-temas.md).

| Tema | Nome no comando | Variante |
| --- | --- | --- |
| [Everforest](https://github.com/sainnhe/everforest) | `everforest` | Dark, contraste médio |
| [Rosé Pine](https://rosepinetheme.com) | `rose-pine` | Main |
| [Catppuccin](https://catppuccin.com) | `catppuccin` | Mocha |
| [Dracula](https://draculatheme.com) | `dracula` | Dracula |

## Trocar

- `Super+T` abre a lista com a prévia das cores. `Enter` troca.
- No terminal: `theme dracula`, ou só `theme` para a lista. `theme current` mostra o atual.
- `theme opacity 0.85` deixa o fundo do terminal mais transparente; `theme opacity 1` deixa sólido;
  `theme opacity reset` volta ao valor do host.

A escolha fica salva e vale no próximo login. O tema de cada máquina, até você escolher outro, fica no host:

```nix
devenv.theme = {
  enable = true;
  default = "everforest";
  opacity = 0.85; # 1 = sólido
};
```

## O que muda e como

| App | Como |
| --- | --- |
| Ghostty | as 16 cores e a opacidade do fundo; recarrega sozinho |
| fish, starship, fzf, bat, delta, lazygit, yazi, eza | usam as 16 cores do terminal, então mudam junto com o Ghostty |
| Neovim | o colorscheme oficial de cada tema; todo Neovim aberto troca na hora. Com o fundo transparente, o Neovim também fica |
| tmux | cores da barra e das bordas |
| niri | cor da borda da janela em foco |
| Noctalia | paleta da barra e dos painéis, papel de parede e transparência dos painéis |
| apps GTK (Rnote, GPU Screen Recorder, portais) | CSS do GTK 3 e 4 gerado pelo Noctalia; os abertos mudam em parte, os novos já abrem com o tema |
| apps Qt da distro (Flameshot) | paleta do qt6ct gerada pelo Noctalia; vale ao reabrir |
| btop | tema `devenv`; troca com ele aberto |
| zathura | cores da interface; `Ctrl+R` pinta o PDF com as cores do tema. Vale ao reabrir |
| Flameshot | cor da seleção e dos botões |
| Obsidian | snippet de CSS no cofre (veja abaixo) |
| sway e i3 | bordas das janelas e, no i3, a barra; recarregam sozinhos |

A opacidade também decide os painéis do Noctalia: 1 é sólido, de 0.9 a 0.99 é suave e abaixo de 0.9 é vidro.

Na sessão i3 o Noctalia não roda (ele é só Wayland). Terminal, Neovim, tmux, btop e as bordas do i3 trocam igual;
o Noctalia e os apps GTK e Qt pegam o tema na próxima vez que você entrar no niri ou no sway.

### Obsidian

O `theme` grava `~/notes/.obsidian/snippets/devenv-theme.css` (só depois que o cofre foi aberto no app uma vez).
Ligue uma vez em *Ajustes → Aparência → Trechos de CSS → devenv-theme*, com o app no modo escuro.
Daí em diante o Obsidian troca junto, na hora.

### O que não muda

- **Zen**: o Firefox não lê o tema do sistema sem uma extensão (Pywalfox) e um programa auxiliar, que não
  funcionam bem com o Zen do Flatpak. Use o modo escuro dele; um tema do Zen à mão continua possível.
- **Bitwarden, OBS** e outros apps Electron ou Qt do Flathub ficam com o tema escuro deles.

## Papéis de parede

Cada tema vem com dois, das coleções da comunidade de cada tema ([Everforest](https://github.com/Apeiros-46B/everforest-walls),
[Rosé Pine](https://github.com/rose-pine/wallpapers), [Catppuccin](https://github.com/zhichaoh/catppuccin-wallpapers),
[Dracula](https://github.com/dracula/wallpaper)). O Nix baixa no primeiro switch, com versão e hash fixos; as
imagens não ficam no repo.

- Para ver e escolher os do tema atual: o seletor de papel de parede do Noctalia.
- Para usar os seus: ponha imagens em `~/Pictures/Wallpapers/<tema>/` (ex.: `~/Pictures/Wallpapers/dracula/`).
  Se a pasta tiver imagens, o `theme` usa ela no lugar da do tema.

## Como funciona

Os arquivos de cada tema são gerados no build a partir de uma paleta só, `themes/<tema>/palette.json`
(no formato de paleta do Noctalia, com as cores da interface e as 16 do terminal):

```text
~/.local/share/devenv/themes/<tema>/   gerado pelo Nix: ghostty, tmux.conf, niri.kdl, btop.theme, zathurarc,
                                       wm-colors.conf (sway/i3), obsidian.css, palette.json, wallpapers/
~/.local/state/devenv/theme/
  current -> ~/.local/share/devenv/themes/<tema>   o tema escolhido
  ghostty, niri.kdl, noctalia.toml                 gerados pelo `theme` (cores + opacidade)
~/.config/btop/themes/devenv.theme               copiado pelo `theme` (o btop.conf continua seu)
  opacity                                          só se você mudou com `theme opacity`
```

O `theme <nome>` troca o link `current`, gera esses arquivos e avisa os apps abertos: o Ghostty recarrega
a config (sinal `USR2`), o Neovim troca o colorscheme (sinal `USR1`), o btop também (`USR2`), o tmux relê as
cores, o sway e o i3 recarregam, e o Noctalia recebe a paleta e o papel de parede pelo `noctalia msg`.
O niri recarrega sozinho quando o arquivo muda. A cada paleta nova, o Noctalia regera o CSS do GTK e a paleta
do qt6ct (`[theme.templates]` em `config/noctalia/devenv.toml`).

O `just switch` roda `theme apply`, que regera os arquivos do tema salvo.

## Adicionar um tema

1. Crie `themes/<nome>/palette.json`. O jeito mais fácil é partir de um dos quatro, ou de uma paleta do
   [repositório de paletas do Noctalia](https://github.com/noctalia-dev/noctalia-colorschemes).
2. Em [`themes/default.nix`](../themes/default.nix), dê o nome e os papéis de parede (`url` e `hash`; o hash
   sai de `nix store prefetch-file <url>`).
3. Em [`config/nvim/lua/pcastr/theme.lua`](../config/nvim/lua/pcastr/theme.lua), diga qual colorscheme o Neovim usa.
4. `just desktop-check` valida as configs com o tema novo, igual ao CI.
