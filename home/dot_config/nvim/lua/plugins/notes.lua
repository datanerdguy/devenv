-- Notas em ~/notas (Markdown), de qualquer pasta: a nota do dia, uma nota nova
-- com título e as buscas pelo fzf-lua. O `ns` do fish guarda no GitHub.

local fzf = require("fzf-lua")
local dir = vim.fs.normalize("~/notas")

-- Abre a nota; se ela ainda não existe, começa com o título.
local function open(name, title)
  vim.fn.mkdir(dir, "p")
  local path = vim.fs.joinpath(dir, name .. ".md")
  vim.cmd.edit(vim.fn.fnameescape(path))
  if not vim.uv.fs_stat(path) then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# " .. title, "", "" })
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
  end
end

local function today()
  local date = os.date("%F") --[[@as string]]
  open(date, date)
end

-- O nome do arquivo vem do título: "Ideias do Neovim" vira ideias-do-neovim.md.
local function new()
  vim.ui.input({ prompt = "Título da nota: " }, function(title)
    if not title or title == "" then return end
    local ascii = vim.fn.iconv(title, "utf-8", "ascii//TRANSLIT"):lower()
    local words = vim.iter(ascii:gmatch("%w+")):totable()
    if #words == 0 then return end
    open(table.concat(words, "-"), title)
  end)
end

-- A mais recente primeiro.
local function find()
  fzf.files({
    cwd = dir,
    prompt = "nota ❯ ",
    winopts = { title = " Notas " },
    cmd = "fd --type file --extension md --strip-cwd-prefix=always"
      .. " --exec-batch ls -t",
  })
end

local function grep()
  fzf.live_grep({
    cwd = dir,
    prompt = "nota ❯ ",
    winopts = { title = " Texto nas notas " },
  })
end

local map = vim.keymap.set
map("n", "<leader>nn", today, { desc = "[Notas] Nota do dia" })
map("n", "<leader>nc", new, { desc = "[Notas] Nota nova com título" })
map("n", "<leader>nf", find, { desc = "[Notas] Achar uma nota" })
map("n", "<leader>ng", grep, { desc = "[Notas] Buscar texto nas notas" })
