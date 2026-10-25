-- Notas (zettelkasten) no mesmo cofre do app Obsidian, com o obsidian.nvim.
-- Cofre: $DEVENV_NOTES ou ~/notes. Tudo em <leader>z; carrega só ao usar ou ao abrir uma nota do cofre.
local pack = require("pcastr.pack")
local gh = function(x) return "https://github.com/" .. x end

local vault = vim.fs.normalize(vim.env.DEVENV_NOTES or "~/notes")
local templates = vim.fn.stdpath("config") .. "/templates/notes" -- no repo, ligado pelo ~/.config/nvim

-- ID no estilo zettelkasten: data e hora + título curto (ex.: 202610231815-joins-no-polars).
local function zettel_id(title)
  local slug = (title or ""):lower():gsub("[^%w%s-]", ""):gsub("%s+", "-"):sub(1, 48)
  local stamp = os.date("%Y%m%d%H%M")
  return slug ~= "" and (stamp .. "-" .. slug) or stamp
end

local function ob(cmd) return "<cmd>Obsidian " .. cmd .. "<cr>" end

pack.add({
  {
    src = gh("obsidian-nvim/obsidian.nvim"),
    version = vim.version.range("3.*"),
    cmd = "Obsidian",
    keys = {
      { "<leader>zn", ob("new"), desc = "[Notas] Nova nota" },
      { "<leader>zz", ob("quick_switch"), desc = "[Notas] Abrir nota" },
      { "<leader>zs", ob("search"), desc = "[Notas] Buscar texto" },
      { "<leader>zd", ob("today"), desc = "[Notas] Nota do dia" },
      { "<leader>zy", ob("yesterday"), desc = "[Notas] Nota de ontem" },
      { "<leader>zt", ob("new_from_template"), desc = "[Notas] Nova nota a partir de modelo" },
      { "<leader>zb", ob("backlinks"), desc = "[Notas/Links] Backlinks desta nota" },
      { "<leader>zl", ob("links"), desc = "[Notas/Links] Links desta nota" },
      { "<leader>z#", ob("tags"), desc = "[Notas] Tags" },
      { "<leader>zp", ob("paste_img"), desc = "[Notas] Colar imagem" },
      { "<leader>zr", ob("rename"), desc = "[Notas] Renomear (atualiza os links)" },
      { "<leader>zo", ob("open"), desc = "[Notas] Abrir no app Obsidian" },
      { "<leader>ze", ob("extract_note"), desc = "[Notas] Extrair seleção para nota nova", mode = "x" },
      { "<leader>zk", ob("link_new"), desc = "[Notas/Links] Seleção vira link para nota nova", mode = "x" },
    },
    config = function()
      vim.fn.mkdir(vault, "p")
      require("obsidian").setup({
        legacy_commands = false,
        workspaces = { { name = "notas", path = vault } },
        notes_subdir = "zettel",
        new_notes_location = "notes_subdir",
        note_id_func = zettel_id,
        picker = { name = "snacks.picker" },
        templates = { folder = templates },
        daily_notes = { folder = "diario", template = "diario.md", workdays_only = false },
        attachments = { folder = "anexos" },
        ui = { ignore_conceal_warn = true },
      })
    end,
  },
})

-- Abrir uma nota do cofre carrega o plugin e esconde a sintaxe dos links.
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = vault .. "/*.md",
  callback = function() pack.load("obsidian.nvim") end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = vault .. "/*.md",
  callback = function() vim.opt_local.conceallevel = 2 end,
})
