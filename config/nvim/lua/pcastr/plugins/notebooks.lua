-- Notebooks.
--   molten-nvim: roda células Jupyter direto no buffer (saída inline, imagens no terminal).
--   marimo: notebooks Python reativos, guardados como .py puro (bom para git).
-- Tudo carrega só ao usar uma tecla de <leader>n.
local pack = require("pcastr.pack")
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

pack.add({
  {
    src = gh("3rd/image.nvim"),
    keys = {}, -- só carrega como dependência do molten
    config = function()
      require("image").setup({
        backend = "kitty", -- protocolo de imagens do kitty, que o Ghostty também entende
        processor = "magick_cli", -- usa o ImageMagick instalado pelo Nix, sem rock de Lua
        integrations = { markdown = { enabled = false } },
        max_height_window_percentage = 50,
        tmux_show_only_in_active_window = true,
      })
    end,
  },
  {
    src = gh("benlubas/molten-nvim"),
    version = vim.version.range("1.*"),
    deps = { "image.nvim" },
    -- Plugin remoto em Python: registra os comandos depois de instalar ou atualizar.
    build = function() vim.cmd("UpdateRemotePlugins") end,
    keys = {
      { "<leader>ni", molten("MoltenInit"), desc = "[Notebook/Molten] Iniciar kernel" },
      { "<leader>ne", molten("MoltenEvaluateOperator"), desc = "[Notebook/Molten] Rodar com operador" },
      { "<leader>nl", molten("MoltenEvaluateLine"), desc = "[Notebook/Molten] Rodar linha" },
      { "<leader>nv", ":<C-u>MoltenEvaluateVisual<cr>gv", desc = "[Notebook/Molten] Rodar seleção", mode = "x" },
      { "<leader>nr", molten("MoltenReevaluateCell"), desc = "[Notebook/Molten] Rodar célula de novo" },
      { "<leader>no", molten("noautocmd MoltenEnterOutput"), desc = "[Notebook/Molten] Abrir saída" },
      { "<leader>nh", molten("MoltenHideOutput"), desc = "[Notebook/Molten] Esconder saída" },
      { "<leader>nd", molten("MoltenDelete"), desc = "[Notebook/Molten] Apagar célula" },
      { "<leader>nI", molten("MoltenInterrupt"), desc = "[Notebook/Molten] Interromper kernel" },
    },
  },
})

vim.keymap.set("n", "<leader>nm", marimo("edit"), { desc = "[Notebook/marimo] Editar notebook" })
vim.keymap.set("n", "<leader>nM", marimo("run"), { desc = "[Notebook/marimo] Rodar como app" })
