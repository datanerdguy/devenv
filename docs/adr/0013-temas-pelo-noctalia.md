# 0013. Temas pelo Noctalia

Data: 2026-11-22 · Status: aceita. Substitui a parte de temas do ADR 0005 (já substituído pelo 0010).

## Contexto

O Lucas quer um comando que troque o tema do desktop inteiro, entre as variantes escuras oficiais de Nord,
Everforest, Rosé Pine, Catppuccin, Dracula e Kanagawa. Na `dev`, um script de 240 linhas escrevia a config de cada
app. O Noctalia 5 já carrega paletas próprias, troca de paleta por comando (`color-scheme-set`) e regenera a config
de outros apps a partir de modelos, com modelos prontos para Ghostty, niri, GTK, Qt e btop e outros na comunidade.

## Decisão

- **O Noctalia é o motor.** O `theme` (função do fish) só escolhe a variante e chama
  `noctalia msg color-scheme-set custom <variante>`. Cada app segue por um modelo.
- **Paletas geradas** por `temas/gerar.py` a partir dos temas oficiais que vêm no Ghostty. As 12 paletas ficam no
  repo, e o lint confere que batem com o gerador.
- **Linhas fixas nas configs.** O `theme = noctalia` do Ghostty e o `include optional=true "noctalia.kdl"` do niri
  ficam no repo. Sem elas, os scripts dos modelos editariam essas configs, que são links para o repo.
- **lazygit por modelo nosso**, sem o script da comunidade, que reescreve o `config.yml`. O lazygit lê as cores por
  `LG_CONFIG_FILE`.
- **Papel de parede à parte do tema**, numa pasta do repo ligada à pasta do seletor do Noctalia.

## Alternativas

- **Script próprio para cada app**, como na `dev`: não depende do Noctalia, mas é muito código para manter, e cada
  app novo pede outro trecho de script.
- **Paletas prontas do Noctalia** (`builtin`): não têm o Everforest nem todas as variantes.
- **Papel de parede por tema:** fica para depois; dá para ligar sem refazer nada.

## Consequências

- A troca precisa do Noctalia aberto. Ele é a barra do desktop e está sempre aberto.
- Numa máquina nova, até o Noctalia abrir, o Ghostty usa um `themes/noctalia` inicial com o Nord, que o chezmoi
  cria só se ele faltar.
- Modelo novo da comunidade: antes de ligar, confira se o script dele não edita um arquivo que é link para o repo.
