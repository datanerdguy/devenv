-- Tema do Neovim: segue o comando `theme` (docs/themes.md).
-- Lê ~/.local/state/devenv/theme/current/id e a opacidade; só o colorscheme escolhido carrega.
-- `theme <nome>` manda SIGUSR1 e todo Neovim aberto troca na hora.
local pack = require("devenv.pack")
local gh = function(x) return "https://github.com/" .. x end

local M = {}

local state = (vim.env.XDG_STATE_HOME or vim.fs.normalize("~/.local/state")) .. "/devenv/theme"

local function read(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*l")
  f:close()
  return s and vim.trim(s) or nil
end

-- Com o fundo do terminal transparente, o Neovim deixa o fundo vazio para ele aparecer.
local function transparent()
  local o = tonumber(read(state .. "/active-opacity") or "")
  return o ~= nil and o < 1
end

---@type table<string, { plugin: string, apply: fun(transparent: boolean) }>
M.schemes = {
  everforest = {
    plugin = "everforest",
    apply = function(t)
      vim.g.everforest_background = "medium"
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_transparent_background = t and 1 or 0
      vim.cmd.colorscheme("everforest")
    end,
  },
  ["rose-pine"] = {
    plugin = "rose-pine",
    apply = function(t)
      require("rose-pine").setup({ variant = "main", styles = { transparency = t } })
      vim.cmd.colorscheme("rose-pine")
    end,
  },
  catppuccin = {
    plugin = "catppuccin",
    apply = function(t)
      require("catppuccin").setup({ flavour = "mocha", transparent_background = t })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  dracula = {
    plugin = "dracula.nvim",
    apply = function(t)
      require("dracula").setup({ transparent_bg = t })
      vim.cmd.colorscheme("dracula")
    end,
  },
}

M.default = "everforest"

function M.current()
  local id = read(state .. "/current/id")
  return (id and M.schemes[id]) and id or M.default
end

--- Aplica um tema (sem argumento: o atual do `theme`).
---@param id? string
function M.apply(id)
  id = id or M.current()
  local s = M.schemes[id] or M.schemes[M.default]
  pack.load(s.plugin)
  local ok, err = pcall(s.apply, transparent())
  if not ok then vim.notify(("[tema] erro ao aplicar %s:\n%s"):format(id, err), vim.log.levels.ERROR) end
end

pack.add({
  { src = gh("sainnhe/everforest"), lazy = true },
  { src = gh("rose-pine/neovim"), name = "rose-pine", lazy = true },
  { src = gh("catppuccin/nvim"), name = "catppuccin", lazy = true },
  { src = gh("Mofiqul/dracula.nvim"), lazy = true },
})

M.apply()

vim.api.nvim_create_autocmd("Signal", {
  group = vim.api.nvim_create_augroup("devenv.theme", { clear = true }),
  pattern = "SIGUSR1",
  callback = function() vim.schedule(M.apply) end,
})

return M
