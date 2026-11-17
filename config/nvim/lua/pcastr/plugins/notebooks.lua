-- Notebooks.
--   molten-nvim: roda células Jupyter direto no buffer (saída inline, imagens no terminal).
--   marimo: notebooks Python reativos, guardados como .py puro (bom para git).
-- Tudo carrega só ao usar uma tecla de <leader>n.
local lazy = require("pcastr.lazy")
local gh = function(x) return "https://github.com/" .. x end

-- Opções do molten precisam existir antes de o plugin carregar.
vim.g.molten_image_provider = "image.nvim"
vim.g.molten_output_win_max_height = 20
vim.g.molten_auto_open_output = false -- saída abre com <leader>no
vim.g.molten_virt_text_output = true -- resumo da saída embaixo da célula
vim.g.molten_virt_lines_off_by_1 = true
vim.g.molten_wrap_output = true

local function molten(cmd) return "<cmd>" .. cmd .. "<cr>" end

-- marimo em um terminal do snacks: `marimo edit` abre o notebook no navegador.
local function marimo(sub)
  return function()
    local file = vim.fn.expand("%:p")
    local cmd = { "uvx", "marimo", sub }
    if file ~= "" and file:match("%.py$") then table.insert(cmd, file) end
    Snacks.terminal(cmd, { win = { position = "bottom", height = 0.3 }, auto_close = false })
  end
end

-- Os comandos do molten (plugin remoto em Python) vêm do manifesto que o :UpdateRemotePlugins grava.
-- Sem ele (o molten chegou antes deste build), gera e carrega na hora, sem reiniciar.
local function register_molten()
  vim.cmd.packadd("molten-nvim")
  vim.cmd("UpdateRemotePlugins")
  vim.cmd.source(vim.fn.stdpath("data") .. "/rplugin.vim")
end
lazy.on_change("molten-nvim", register_molten)
lazy.install({ gh("3rd/image.nvim"), { src = gh("benlubas/molten-nvim"), version = vim.version.range("1.*") } })

lazy.keys(
  lazy.loader({ "image.nvim", "molten-nvim" }, function()
    vim.cmd.runtime("plugin/rplugin.vim") -- no `nvim -l` (tests/nvim/check.lua) os plugins do runtime não carregam
    if vim.fn.exists(":MoltenInit") ~= 2 then register_molten() end
    -- O molten grava o arquivo de conexão do kernel em <data_dir do jupyter>/runtime e não cria a pasta
    -- (rplugin/python3/molten/runtime.py).
    local data = vim.env.JUPYTER_DATA_DIR
      or vim.fs.joinpath(vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share"), "jupyter")
    vim.fn.mkdir(vim.fs.joinpath(data, "runtime"), "p")
    require("image").setup({
      backend = "kitty", -- protocolo de imagens do kitty, que o Ghostty também entende
      processor = "magick_cli",
      integrations = { markdown = { enabled = false } },
      max_height_window_percentage = 50,
      tmux_show_only_in_active_window = true,
    })
  end),
  {
    { "<leader>ni", molten("MoltenInit"), desc = "[Notebook/Molten] Iniciar kernel" },
    { "<leader>ne", molten("MoltenEvaluateOperator"), desc = "[Notebook/Molten] Rodar com operador" },
    { "<leader>nl", molten("MoltenEvaluateLine"), desc = "[Notebook/Molten] Rodar linha" },
    { "<leader>nv", ":<C-u>MoltenEvaluateVisual<cr>gv", desc = "[Notebook/Molten] Rodar seleção", mode = "x" },
    { "<leader>nr", molten("MoltenReevaluateCell"), desc = "[Notebook/Molten] Rodar célula de novo" },
    { "<leader>no", molten("noautocmd MoltenEnterOutput"), desc = "[Notebook/Molten] Abrir saída" },
    { "<leader>nh", molten("MoltenHideOutput"), desc = "[Notebook/Molten] Esconder saída" },
    { "<leader>nd", molten("MoltenDelete"), desc = "[Notebook/Molten] Apagar célula" },
    { "<leader>nI", molten("MoltenInterrupt"), desc = "[Notebook/Molten] Interromper kernel" },
  }
)

vim.keymap.set("n", "<leader>nm", marimo("edit"), { desc = "[Notebook/marimo] Editar notebook" })
vim.keymap.set("n", "<leader>nM", marimo("run"), { desc = "[Notebook/marimo] Rodar como app" })
