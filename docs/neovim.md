# Neovim

O Neovim é o nightly 0.13, instalado pelo `bob` (grupo `editor`). A config fica em `home/dot_config/nvim/`.

A regra é usar o que é nativo do Neovim primeiro; plugin só entra quando o nativo não cobre: os temas, a busca
(fzf-lua, o mesmo fzf do shell), o explorer (oil), a config dos LSPs (nvim-lspconfig, lazydev e SchemaStore), os erros na tela
(tiny-inline-diagnostic), os parsers do treesitter (nvim-treesitter), o formatar (conform), o completar (blink.cmp)
e o Claude no editor (claudecode.nvim).

## Estrutura

```text
home/dot_config/nvim/
  init.lua              a ordem em que os módulos carregam
  lua/config/           o que é nativo, sem plugin
    options.lua         líder (Espaço), números das linhas, linha na coluna 80, indentação, clipboard, busca, menu da linha de comando
    cursor.lua          cursor em bloco, com a cor do modo igual à do fish
    keymaps.lua         atalhos sem plugin (jk, <leader>w, <leader>R)
    navigation.lua      Ctrl+j/k/l/; entre janelas do Neovim e painéis do tmux
    watch.lua           segue um arquivo que o `theme` regrava (usado pelo cursor e pelo tema)
  lua/plugins/          um arquivo por assunto: os plugins dele, a config e os atalhos
    theme.lua           os temas e qual deles segue o desktop
    search.lua          busca de arquivos, pastas e texto (fzf-lua)
    explorer.lua        explorer de arquivos (oil)
    lsp.lua             quais servidores LSP ligam e os atalhos deles (nvim-lspconfig, lazydev, SchemaStore)
    treesitter.lua      realce e fold pela estrutura do código (nvim-treesitter)
    diagnostics.lua     como os erros aparecem (tiny-inline-diagnostic)
    format.lua          formatador de cada linguagem, ao salvar (conform)
    completion.lua      completar enquanto digita (blink.cmp)
    claude.lua          o Claude Code do painel do tmux conectado ao Neovim (claudecode.nvim)
  after/lsp/            ajuste de um servidor LSP, por cima do nvim-lspconfig
  nvim-pack-lock.json   versões dos plugins, gravada pelo vim.pack
```

O estilo do Lua fica no `.stylua.toml` e o dos scripts no `.editorconfig`, na raiz do repo. O Neovim formata assim
ao salvar, e o `just lint` confere.

Assunto novo ganha um arquivo: em `lua/config/` se for nativo, em `lua/plugins/` se precisar de plugin (o
`vim.pack.add` dele fica no próprio arquivo). Depois, uma linha `require` no `init.lua`. Para o que o Neovim já
procura sozinho, use as pastas dele, criadas quando o primeiro arquivo entrar:

- `after/lsp/<servidor>.lua`: ajuste de um LSP, que vale por cima do nvim-lspconfig;
- `after/ftplugin/<linguagem>.lua`: ajustes por tipo de arquivo (indentação, por exemplo).

O chezmoi liga cada arquivo, inclusive os das subpastas. Arquivo novo só aparece em `~/.config/nvim` depois do
`just apply`; editar um que já existe vale na hora (`<leader>R` para o Neovim ler de novo).

## Atalhos

O `<leader>` é o **Espaço**.

| Tecla | O que faz |
| --- | --- |
| `<leader>ff` | Arquivos do projeto |
| `<leader>fd` | Pastas do projeto; a escolhida abre no explorer |
| `<leader>fz` | Pastas do zoxide (as que você mais usa, de qualquer projeto); abre no explorer |
| `<leader>/` | Texto no arquivo atual, com a linha na prévia |
| `<leader>fg` | Texto no projeto, enquanto digita |
| `<leader>fw` | A palavra do cursor no projeto |
| `<leader>fb` | Arquivos abertos |
| `<leader>fr` | Arquivos recentes |
| `<leader>fh` / `<leader>fk` | Ajuda do Neovim / atalhos |
| `<leader>fe` / `<leader>fE` | Erros e avisos do arquivo / do projeto |
| `<leader>fs` | Símbolos do projeto (funções, tipos), pelo LSP |
| `<leader>f.` | Volta à última busca, como estava |
| `-` ou `<leader>e` | Explorer na pasta do arquivo atual |
| `<leader>E` | Explorer na raiz do projeto |
| `jk` | Sai do modo de inserção, como o `Esc` |
| `<leader>w` | Salva o arquivo (e formata) |
| `y` / `d` / `p` | Usam o clipboard do sistema (o mesmo do navegador) |
| `<leader>R` | Salva tudo e reinicia o Neovim, que lê a config de novo e volta com os mesmos arquivos |
| `Ctrl-j/k/l/;` | Janela à esquerda, abaixo, acima, à direita (as teclas do niri, com Ctrl). Na borda, segue para o painel do tmux ([tmux.md](tmux.md#neovim)) |

`nvim .` (ou `nvim <pasta>`) abre direto no explorer.

## Buscar

A busca é o fzf-lua: o mesmo `fzf` do shell, com prévia ao lado e as cores do tema. A busca é fuzzy (letras fora de
ordem valem: `tmuxconf` acha `home/dot_config/tmux/tmux.conf`). Arquivos e pastas vêm do `fd` e o texto vem do
`rg`: os ocultos aparecem, e o `.git` e o que o git ignora não.

Dentro da busca:

| Tecla | O que faz |
| --- | --- |
| `Enter` | Abre |
| `Ctrl-v` / `Ctrl-s` / `Ctrl-t` | Abre ao lado / embaixo / numa aba |
| `Tab` | Marca vários (o `Enter` abre todos) |
| `Alt-q` | Manda os resultados para o quickfix (`]q` e `[q` andam entre eles) |
| `Alt-h` / `Alt-i` | Mostra ou esconde os ocultos / o que o git ignora |
| `Esc` | Modo normal (o prompt mostra `NORMAL`): `j` / `k` andam na lista, `i` volta a escrever, `q` ou `Esc` fecham. O mesmo de toda lista do fzf no shell ([shell.md](shell.md#atalhos)) |
| `Ctrl-j` / `Ctrl-k` | Andam na lista sem sair do modo de escrever |

Na linha de comando (`:`) e na busca com `/`, um menu fuzzy de sugestões aparece enquanto você digita. `Tab` e
`Shift-Tab` andam no menu.

## Explorer (oil)

O oil abre a pasta como um texto, e você mexe nos arquivos editando as linhas. Nada muda no disco até o `:w`, que
mostra o que vai acontecer quando a mudança é grande.

| Para | Faça |
| --- | --- |
| Abrir | `Enter` (pasta ou arquivo); `Ctrl-s` / `Ctrl-h` abre ao lado / embaixo, `Ctrl-t` numa aba |
| Subir uma pasta | `-` |
| Renomear | Edite o nome (`cw`, `A`...) e `:w` |
| Criar | Uma linha nova com o nome; com `/` no fim é pasta (`a/b/c.txt` cria as pastas no caminho). `:w` |
| Copiar | `yy` no arquivo, vá até a outra pasta, `p` e `:w` |
| Mover | `dd` no arquivo, vá até a outra pasta, `p` e `:w` |
| Apagar | `dd` e `:w`. Vai para a lixeira (`g\` mostra a lixeira) |
| Desfazer antes do `:w` | `u`, como num texto |
| Prévia | `Ctrl-p` |
| Ocultos | `g.` mostra ou esconde (começam à mostra) |
| Abrir fora do Neovim | `gx` |
| Ajuda | `g?` lista todas as teclas |

Vários de uma vez também valem: `Vjj` e `d` ou `y` em várias linhas. Renomear ou mover um arquivo pelo oil avisa o
LSP, que corrige os imports.

## Tema

O Neovim usa o tema do desktop ([temas.md](temas.md)): cada paleta do Noctalia abre o tema oficial equivalente.
Quando o `theme` troca a paleta, os Neovims abertos trocam junto. O `plugins/theme.lua` lê a paleta escolhida em
`~/.local/state/noctalia/settings.toml` e vigia esse arquivo; sem escolha (máquina nova), fica o Nord.

O fundo é transparente: aparece o do Ghostty, com a mesma cor e a mesma opacidade (`background-opacity`). Janelas
flutuantes e a barra de status ficam com o fundo do tema.

| Paleta | Plugin |
| --- | --- |
| `catppuccin-*` | `catppuccin/nvim` |
| `kanagawa-*` | `rebelot/kanagawa.nvim` |
| `rose-pine`, `rose-pine-moon` | `rose-pine/neovim` |
| `everforest-*` | `sainnhe/everforest` (o contraste vai em `g:everforest_background`) |
| `nord` | `gbprod/nord.nvim` (o oficial é de Vim e não cobre treesitter nem LSP) |
| `dracula` | `Mofiqul/dracula.nvim` (pelo mesmo motivo) |

Variante nova em `temas/gerar.py` precisa de uma linha na tabela `themes` do `plugins/theme.lua`.

## Plugins

O gerenciador é o nativo, `vim.pack`. Na primeira vez, ele baixa os plugins sozinho. As versões ficam em
`nvim-pack-lock.json`, no repo, então toda máquina instala as mesmas.

| Comando | O que faz |
| --- | --- |
| `:packupdate` | Mostra as atualizações; `:write` confirma, `:quit` descarta. Depois, commit do `nvim-pack-lock.json` |
| `:packdel <nome>` | Apaga um plugin que saiu da config |

## LSP

Os servidores vêm do metapac (`packages/groups/linguagens.toml`, a tabela do [ADR 0010](adr/0010-devenv-sem-nix-chezmoi-metapac.md)),
sem Mason. A config de cada um (comando, tipos de arquivo, raiz do projeto) vem do nvim-lspconfig, e o `plugins/lsp.lua`
liga a lista. Um servidor só sobe quando um arquivo do tipo dele abre. No Python, o ty cuida dos tipos e da
documentação, e o ruff do lint e das correções. O basedpyright fica instalado, mas desligado.

O completar e a documentação enxergam as bibliotecas do projeto:

- **Lua da config do Neovim:** o lazydev ensina ao lua_ls a API do Neovim (`vim.`, `vim.o.`, `vim.api.`...) e a de
  cada plugin que o arquivo usa com `require`. O `vim.g.` é a exceção: ele guarda variáveis livres, sem lista do que
  existe; as de cada plugin estão no `:help` dele.
- **Python:** o ty lê o `.venv` do projeto (o do `uv`), então as bibliotecas instaladas nele aparecem.
- **Go, Rust, TypeScript:** o gopls lê o `go.mod`, o rust-analyzer o `Cargo.toml` e o vtsls o `node_modules`.

| Tecla | O que faz |
| --- | --- |
| `K` | Documentação do que está no cursor |
| `gd` | Definição |
| `grr` / `gri` / `grt` | Referências / implementação / definição do tipo (no fzf, com prévia) |
| `gO` | Símbolos do arquivo |
| `grn` | Renomeia em todo o projeto |
| `gra` | Ações de código (corrigir, importar...) |
| `Ctrl-s` (no modo de inserção) | Assinatura da função |
| `]d` / `[d` | Próximo erro / anterior |
| `Ctrl-w d` | O erro inteiro numa janela |
| `<leader>lf` | Formata (o arquivo ou a seleção) |
| `<leader>lh` | Liga e desliga as dicas inline (tipos e nomes de parâmetros no meio do código) |
| `<leader>lr` | Reinicia os servidores |

`:checkhealth vim.lsp` mostra quais servidores estão ligados no arquivo atual. Servidor novo: o pacote em
`linguagens.toml` e o nome (o do nvim-lspconfig) na lista `servers` do `plugins/lsp.lua`. O smoke confere que o comando de
cada servidor da lista existe.

Regras de lint e de estilo ficam na config de cada projeto (`pyproject.toml`, `Cargo.toml`, `.golangci.yml`), para
valer igual no Neovim, no CI e em outro editor. O `after/lsp/` só tem o que é do editor:

| Servidor | Ajuste |
| --- | --- |
| `rust_analyzer` | Ao salvar, roda o `clippy` em vez do `cargo check` |
| `gopls` | staticcheck, parâmetro sem uso, variável que esconde outra; estilo do gofumpt |
| `clangd` | Avisos do clang-tidy; o completar não acrescenta `#include` sozinho |
| `vtsls` | Usa o TypeScript do projeto (`node_modules`) quando ele existe |
| `lua_ls` | Sem o formatador dele: quem formata é o stylua |
| `jsonls`, `yamlls` | Os formatos de centenas de arquivos (`package.json`, workflows do GitHub, `docker-compose.yml`...), pelo SchemaStore: completa as chaves e acusa a chave errada |

## Treesitter

O realce do código, o fold e o realce de uma linguagem dentro de outra (SQL numa string do Python, JS no HTML) vêm
do treesitter, que é do Neovim. O nvim-treesitter só baixa e compila os parsers, com o `tree-sitter-cli` (grupo
`editor`). As linguagens são as dos servidores do `plugins/lsp.lua`, então linguagem nova no LSP ganha o parser
junto. Na primeira vez que o Neovim abre, ele compila todos (uns minutos); depois, só o que faltar. Linguagem sem
parser fica com o realce antigo, por regex.

| Tecla | O que faz |
| --- | --- |
| `zc` / `zo` | Fecha / abre o bloco do cursor (função, classe, `if`) |
| `zM` / `zR` | Fecha / abre todos (o arquivo abre com tudo aberto) |
| `za` | Fecha ou abre o bloco |

O `:packupdate` do nvim-treesitter atualiza os parsers junto (`:TSUpdate`). `:checkhealth nvim-treesitter` mostra
o que está instalado.

## Erros

Todo erro e aviso ganha um emoji na margem, e o número da linha fica com a cor dele: ⛔ erro, ⚠️ aviso, ℹ️
informação, 💡 dica. Na linha do cursor, a mensagem aparece numa caixa ao lado do código, com o emoji e o servidor
que a deu (tiny-inline-diagnostic); mensagem longa quebra em várias linhas. A barra de status mostra quantos há no
arquivo (`⛔ 2 ⚠️ 1`), e o erro vem sempre antes do aviso.

## Formatar

O `:w` formata pelo conform, com o formatador de cada linguagem: stylua, ruff, gofumpt, rustfmt, `mix format`,
clang-format, google-java-format, shfmt, `fish_indent`, tombi e `just --fmt`. Sem formatador na lista, vale o do
LSP. O conform prefere o formatador do projeto (`node_modules/.bin`) ao da máquina.

O prettier (JavaScript, TypeScript, HTML, CSS, JSON, YAML, Markdown) só roda em projeto que tem config dele
(`.prettierrc` e afins). Sem isso, ele reescreveria os arquivos num estilo que não é o do projeto.

## Completar

O blink.cmp abre as sugestões enquanto você digita: do LSP, caminhos, snippets, palavras do arquivo e, no Lua, os
módulos em `require("...")`, com a
documentação ao lado. A assinatura da função aparece enquanto você escreve os argumentos.

| Tecla | O que faz |
| --- | --- |
| `Ctrl-n` / `Ctrl-p` | Próxima / anterior |
| `Ctrl-y` | Aceita |
| `Ctrl-e` | Fecha |
| `Ctrl-Space` | Abre as sugestões (ou a documentação) |
| `Ctrl-k` | Mostra ou esconde a assinatura da função |
| `Tab` / `Shift-Tab` | Anda nos campos de um snippet |

A linha de comando (`:`) fica com o menu nativo.

## Cursor

O cursor é sempre um bloco, e a cor diz o modo, igual ao fish: verde no de inserção, vermelho no normal e amarelo no
visual. As cores vêm do mesmo arquivo que o Noctalia gera para o fish (`~/.local/state/devenv/fish-cursor.fish`), e
mudam junto com o `theme`.

## Números das linhas

A linha do cursor mostra o número dela; as outras mostram a distância até o cursor, para pular com `5j` ou `3k`.

## Arquivos

O Neovim não cria swap (`.swp`) nem backup (`arquivo~`). O histórico fica com o git.

## Reiniciar

`<leader>R` é `:wall` seguido do `:restart` nativo. Ele salva a sessão (janelas e arquivos), fecha, abre um Neovim
novo com a config relida e restaura a sessão. `ZR` faz o mesmo sem salvar os arquivos antes.

## Claude

O Claude Code roda num painel do tmux, ao lado do Neovim. O claudecode.nvim conecta os dois pelo mesmo protocolo da
extensão do VS Code: no Claude, `/ide` escolhe este Neovim. Conectado, o Claude vê o arquivo aberto e a seleção, e a
mudança que ele propõe abre no Neovim como diff: `:w` aceita (dá para editar antes), `:q` recusa.

| Tecla | O que faz |
| --- | --- |
| `<leader>as` | Manda a seleção (modo visual) ou, no explorer, o arquivo da linha. O foco vai para o painel do Claude |
| `<leader>ab` | Manda o arquivo atual |
| `<leader>aa` / `<leader>ad` | Aceita / recusa a mudança proposta |
