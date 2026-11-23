-- Notas em ~/notas (Markdown), de qualquer pasta: a nota do dia, uma nota nova
-- com título e as buscas pelo fzf-lua. A nota abre numa janela flutuante, para
-- anotar rápido e voltar ao que estava fazendo: q salva e fecha. O `ns` do fish
-- guarda no GitHub.

local fzf = require("fzf-lua")
local dir = vim.fs.normalize("~/notas")

-- Abre o arquivo numa janela flutuante no meio da tela, na linha pedida.
local function float(path, line)
  local width = math.min(100, vim.o.columns - 8)
  local height = math.floor(vim.o.lines * 0.7)
  local buf = vim.fn.bufadd(path)
  vim.bo[buf].buflisted = true
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2) - 1,
    border = "rounded",
    title = " " .. vim.fn.fnamemodify(path, ":t") .. " ",
    title_pos = "center",
    footer = " q salva e fecha ",
    footer_pos = "center",
  })
  if line then vim.api.nvim_win_set_cursor(0, { line, 0 }) end
  vim.keymap.set("n", "q", "<cmd>update | close<cr>", {
    buffer = true,
    desc = "[Notas] Salvar e fechar",
  })
end

-- Abre a nota; se ela ainda não existe, começa com o título.
local function open(name, title)
  vim.fn.mkdir(dir, "p")
  local path = vim.fs.joinpath(dir, name .. ".md")
  local exists = vim.uv.fs_stat(path) ~= nil
  float(path)
  if not exists then
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

-- O Enter nas buscas também abre a nota na janela flutuante.
local actions = {
  enter = function(selected, opts)
    local entry = fzf.path.entry_to_file(selected[1], opts)
    local line = entry.line and entry.line > 0 and entry.line or nil
    float(entry.path, line)
  end,
}

-- A mais recente primeiro.
local function find()
  fzf.files({
    cwd = dir,
    prompt = "nota ❯ ",
    winopts = { title = " Notas " },
    cmd = "fd --type file --extension md --strip-cwd-prefix=always"
      .. " --exec-batch ls -t",
    actions = actions,
  })
end

local function grep()
  fzf.live_grep({
    cwd = dir,
    prompt = "nota ❯ ",
    winopts = { title = " Texto nas notas " },
    actions = actions,
  })
end

local map = vim.keymap.set
map("n", "<leader>nn", today, { desc = "[Notas] Nota do dia" })
map("n", "<leader>nc", new, { desc = "[Notas] Nota nova com título" })
map("n", "<leader>nf", find, { desc = "[Notas] Achar uma nota" })
map("n", "<leader>ng", grep, { desc = "[Notas] Buscar texto nas notas" })
