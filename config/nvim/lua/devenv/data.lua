-- Dados (D): sem plugin. Abre as ferramentas do terminal numa janela flutuante e roda SQL no DuckDB.
--   harlequin: IDE de SQL (bancos e arquivos)   tabiew (tw): ver CSV, Parquet, Excel com SQL
-- Fluxos e atalhos: docs/data.md.
local map = vim.keymap.set

-- Raiz do projeto (pasta com .git), senão a pasta atual: é de lá que caminhos relativos no SQL partem.
local function root(buf) return vim.fs.root(buf or 0, ".git") or vim.uv.cwd() end

local function float(cmd, opts)
  if vim.fn.executable(cmd[1]) == 0 then
    return vim.notify(cmd[1] .. " não encontrado (vem do módulo de CLI do devenv)", vim.log.levels.WARN)
  end
  Snacks.terminal(cmd, vim.tbl_extend("force", { cwd = root(), win = { width = 0.92, height = 0.9 } }, opts or {}))
end

local tabular =
  { csv = true, tsv = true, parquet = true, json = true, jsonl = true, xlsx = true, xls = true, arrow = true }

map("n", "<leader>Dh", function() float({ "harlequin" }) end, { desc = "Harlequin (IDE de SQL)" })
map("n", "<leader>Dt", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or not tabular[vim.fn.fnamemodify(file, ":e"):lower()] then
    -- Fora de um arquivo de tabela: escolhe um no projeto.
    return Snacks.picker.files({
      title = "Abrir no tabiew",
      ft = vim.tbl_keys(tabular),
      confirm = function(picker, item)
        picker:close()
        if item then float({ "tw", Snacks.picker.util.path(item) }) end
      end,
    })
  end
  float({ "tw", file })
end, { desc = "Tabiew (ver tabela)" })

-- Roda SQL no DuckDB e mostra o resultado num split abaixo.
-- Banco: vim.b.duckdb, senão vim.g.duckdb, senão em memória (lê CSV/Parquet direto: from 'dados.csv').
local result_buf
local function show(lines)
  if not (result_buf and vim.api.nvim_buf_is_valid(result_buf)) then
    result_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[result_buf].bufhidden = "hide"
    vim.api.nvim_buf_set_name(result_buf, "duckdb://resultado")
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = result_buf, silent = true })
  end
  vim.api.nvim_buf_set_lines(result_buf, 0, -1, false, lines)
  local win = vim.fn.bufwinid(result_buf)
  if win == -1 then
    vim.cmd("botright 15split")
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, result_buf)
    vim.wo[win].wrap = false
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.cmd("wincmd p")
  end
end

local function run_sql(sql)
  if vim.fn.executable("duckdb") == 0 then return vim.notify("duckdb não encontrado", vim.log.levels.WARN) end
  local cmd = { "duckdb", "-box" }
  local db = vim.b.duckdb or vim.g.duckdb
  if db then table.insert(cmd, db) end
  local started = vim.uv.hrtime()
  vim.system(cmd, { stdin = sql, cwd = root(), text = true }, function(out)
    vim.schedule(function()
      local text = (out.stdout or "") .. (out.stderr or "")
      local lines = vim.split(text, "\n", { trimempty = true })
      table.insert(
        lines,
        1,
        ("-- %s · %.0f ms%s"):format(
          db or "em memória",
          (vim.uv.hrtime() - started) / 1e6,
          out.code ~= 0 and " · erro" or ""
        )
      )
      show(lines)
    end)
  end)
end

map(
  "n",
  "<leader>Dr",
  function() run_sql(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")) end,
  { desc = "Rodar o arquivo no DuckDB" }
)
map("x", "<leader>Dr", function()
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  run_sql(table.concat(lines, "\n"))
end, { desc = "Rodar a seleção no DuckDB" })
map("n", "<leader>Db", function()
  vim.ui.input(
    { prompt = "Banco do DuckDB (vazio = em memória): ", default = vim.b.duckdb or "", completion = "file" },
    function(v)
      if v == nil then return end
      vim.b.duckdb = v ~= "" and v or nil
      vim.notify("DuckDB: " .. (vim.b.duckdb or "em memória"))
    end
  )
end, { desc = "Escolher o banco do DuckDB" })
