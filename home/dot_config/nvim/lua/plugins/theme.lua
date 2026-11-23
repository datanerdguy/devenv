-- Tema: o mesmo do desktop (docs/temas.md). Cada paleta do Noctalia abre o tema
-- oficial do Neovim equivalente, e o Neovim aberto troca junto quando o `theme`
-- muda a paleta.

vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/rebelot/kanagawa.nvim",
  { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
  "https://github.com/sainnhe/everforest",
  "https://github.com/gbprod/nord.nvim",
  "https://github.com/Mofiqul/dracula.nvim",
}, { confirm = false })

-- Paleta do Noctalia -> tema do Neovim. O Everforest escolhe o contraste por
-- uma variável.
local function everforest(contrast)
  return function()
    vim.g.everforest_background = contrast
    return "everforest"
  end
end

local themes = {
  ["nord"] = "nord",
  ["everforest-hard"] = everforest("hard"),
  ["everforest-medium"] = everforest("medium"),
  ["everforest-soft"] = everforest("soft"),
  ["rose-pine"] = "rose-pine-main",
  ["rose-pine-moon"] = "rose-pine-moon",
  ["catppuccin-mocha"] = "catppuccin-mocha",
  ["catppuccin-macchiato"] = "catppuccin-macchiato",
  ["catppuccin-frappe"] = "catppuccin-frappe",
  ["dracula"] = "dracula",
  ["kanagawa-wave"] = "kanagawa-wave",
  ["kanagawa-dragon"] = "kanagawa-dragon",
}

-- Fundo transparente: o do Ghostty aparece por trás, com a mesma cor e a mesma
-- opacidade (background-opacity). As janelas flutuantes e a barra de status
-- ficam com o fundo do tema, para se destacarem.
local transparent = {
  "Normal",
  "NormalNC",
  "SignColumn",
  "FoldColumn",
  "LineNr",
  "CursorLineNr",
  "EndOfBuffer",
}

local function clear_background()
  for _, group in ipairs(transparent) do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false }) --[[@as vim.api.keyset.highlight]]
    hl.bg, hl.ctermbg = nil, nil
    vim.api.nvim_set_hl(0, group, hl)
  end
end

-- O `theme` grava a paleta no estado do Noctalia; os Neovims abertos trocam
-- junto. Sem paleta (máquina nova), vale o padrão do repo: Nord. O Noctalia
-- regrava esse arquivo também por outros ajustes, então só troca se a paleta
-- mudou.
local function palette(path)
  for line in io.lines(path) do
    local name = line:match('^custom_palette%s*=%s*"(.-)"')
    if name then return name end
  end
end

local current
require("config.watch")("noctalia", "settings.toml", function(path)
  local ok, name = pcall(palette, path)
  name = ok and themes[name] and name or "nord"
  if name == current then return end
  current = name
  local theme = themes[name]
  vim.o.background = "dark"
  vim.cmd.colorscheme(type(theme) == "function" and theme() or theme)
  clear_background()
end)
