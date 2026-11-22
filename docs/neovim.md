# Neovim

O Neovim é o nightly, instalado pelo `bob` (grupo `editor`). A config fica em `nvim/`, na raiz do repo, e o chezmoi
liga a pasta inteira em `~/.config/nvim`. Por isso o que o Neovim grava ali, como o `nvim-pack-lock.json`, vai
direto para o repo.

Por enquanto a config só tem o básico para entrar e andar pelos arquivos. O resto entra aos poucos.

## Atalhos

O `<leader>` é o **Espaço**.

| Tecla | O que faz |
| --- | --- |
| `<leader><space>` | Busca arquivos: os recentes primeiro, depois os do projeto |
| `<leader>ff` | Busca arquivos do projeto |
| `<leader>fg` | Busca texto no projeto |
| `<leader>fb` | Arquivos abertos |
| `<leader>fr` | Arquivos recentes |
| `<leader>e` | Abre ou fecha a árvore de pastas |
| `<leader>R` | Salva tudo e reinicia o Neovim, que lê a config de novo e volta com os mesmos arquivos |

`nvim .` (ou `nvim <pasta>`) abre direto na árvore. Nas buscas, os arquivos ocultos aparecem, e os ignorados pelo
git não.

Na árvore: `Enter` ou `l` abre, `h` fecha a pasta, `a` cria (termine com `/` para pasta), `d` apaga (vai para a
lixeira), `r` renomeia, `c` copia, `m` move, `H` mostra os ocultos, `I` os ignorados e `?` lista todas as teclas.

## Plugins

Pelo `vim.pack`, nativo do Neovim. As versões ficam em `nvim/nvim-pack-lock.json`, no git.

| Plugin | Para que |
| --- | --- |
| snacks.nvim | Busca de arquivos e de texto, e a árvore de pastas |

Para atualizar: `:lua vim.pack.update()`. Ele mostra o que muda antes; `:w` confirma. Depois, faça commit do
lockfile.
