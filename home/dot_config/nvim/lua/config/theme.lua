-- Tema: o mesmo do desktop (docs/temas.md). Cada paleta do Noctalia abre o tema oficial do Neovim
-- equivalente, e o Neovim aberto troca junto quando o `theme` muda a paleta.

vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/rebelot/kanagawa.nvim",
  { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
  "https://github.com/sainnhe/everforest",
  "https://github.com/gbprod/nord.nvim",
  "https://github.com/Mofiqul/dracula.nvim",
}, { confirm = false })

-- Paleta do Noctalia -> tema do Neovim. O Everforest escolhe o contraste por uma variável.
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

-- O `theme` grava a paleta no estado do Noctalia. Sem ela (máquina nova), vale o padrão do repo: Nord.
local state_dir = vim.fs.joinpath(vim.env.XDG_STATE_HOME or vim.fs.normalize("~/.local/state"), "noctalia")
local settings = vim.fs.joinpath(state_dir, "settings.toml")

local function palette()
  for line in io.lines(settings) do
    local name = line:match('^custom_palette%s*=%s*"(.-)"')
    if name then
      return name
    end
  end
end

local current
local function apply()
  local ok, name = pcall(palette)
  name = ok and themes[name] and name or "nord"
  if name == current then
    return
  end
  current = name
  local theme = themes[name]
  vim.o.background = "dark"
  vim.cmd.colorscheme(type(theme) == "function" and theme() or theme)
end

apply()

-- Troca ao vivo: o Noctalia regrava o settings.toml a cada `theme`. Vigia a pasta, porque o arquivo pode ser
-- trocado por outro (e aí quem vigia só o arquivo perde o rastro).
local watcher = vim.uv.new_fs_event()
if watcher and vim.uv.fs_stat(state_dir) then
  watcher:start(state_dir, {}, function(_, file)
    if file == "settings.toml" then
      vim.schedule(apply)
    end
  end)
end
