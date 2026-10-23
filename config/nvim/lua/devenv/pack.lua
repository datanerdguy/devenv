-- Camada fina sobre o vim.pack: carregamento sob demanda + gerenciador (:Pack).
--
-- Uso:
--   local pack = require("devenv.pack")
--   pack.add({
--     src = "https://github.com/folke/flash.nvim",
--     event = "BufReadPost",   -- ou ft = {...}, cmd = {...}, keys = {...}
--     config = function() require("flash").setup() end,
--   })
--
-- Sem event/ft/cmd/keys o plugin carrega na abertura.
local M = {}

---@class devenv.Plugin
---@field name string
---@field src string
---@field version? string|vim.VersionRange
---@field event? string|string[]
---@field ft? string|string[]
---@field cmd? string|string[]
---@field keys? table[] { lhs, rhs, mode?, desc? }
---@field deps? string[] nomes de plugins que precisam carregar antes
---@field config? fun()
---@field build? fun(path: string) roda após instalar ou atualizar
---@field loaded? boolean
---@field load_ms? number

---@type table<string, devenv.Plugin>
M.plugins = {}
---@type string[]
M.order = {}

local function list(x)
  if x == nil then return {} end
  return type(x) == "table" and x or { x }
end

local function name_of(src) return (src:gsub("%.git$", ""):match("[^/]+$")) end

--- Carrega um plugin (e as dependências) uma única vez.
---@param name string
function M.load(name)
  local p = M.plugins[name]
  if not p or p.loaded then return end
  p.loaded = true -- marca antes, evita ciclos
  for _, dep in ipairs(list(p.deps)) do
    M.load(dep)
  end
  local t = vim.uv.hrtime()
  vim.cmd.packadd(name)
  if p.config then
    local ok, err = pcall(p.config)
    if not ok then
      p.error = err
      vim.notify(("[pack] erro ao configurar %s:\n%s"):format(name, err), vim.log.levels.ERROR)
    end
  end
  p.load_ms = (vim.uv.hrtime() - t) / 1e6
end

local function is_lazy(p) return p.event or p.ft or p.cmd or p.keys end

local function setup_triggers(p)
  local group = vim.api.nvim_create_augroup("devenv.pack." .. p.name, { clear = true })
  local function once()
    pcall(vim.api.nvim_del_augroup_by_id, group)
    M.load(p.name)
  end

  local events = list(p.event)
  if #events > 0 then vim.api.nvim_create_autocmd(events, { group = group, once = true, callback = once }) end

  local fts = list(p.ft)
  if #fts > 0 then
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = fts,
      once = true,
      callback = function(ev)
        once()
        -- reaplica o FileType para o plugin recém-carregado enxergar o buffer
        vim.api.nvim_exec_autocmds("FileType", { buffer = ev.buf, modeline = false })
      end,
    })
  end

  for _, cmd in ipairs(list(p.cmd)) do
    vim.api.nvim_create_user_command(cmd, function(args)
      pcall(vim.api.nvim_del_user_command, cmd)
      once()
      local range = args.range > 0 and (args.line1 .. "," .. args.line2) or ""
      vim.cmd(range .. cmd .. (args.bang and "!" or "") .. " " .. args.args)
    end, { nargs = "*", bang = true, range = true })
  end

  for _, k in ipairs(p.keys or {}) do
    local lhs, rhs = k[1], k[2]
    vim.keymap.set(k.mode or "n", lhs, function()
      once()
      if type(rhs) == "function" then
        rhs()
      else
        vim.api.nvim_feedkeys(vim.keycode(rhs), "m", false)
      end
    end, { desc = k.desc, silent = true })
  end
end

--- Registra e instala (se faltar) um ou mais plugins.
---@param specs devenv.Plugin|devenv.Plugin[]
function M.add(specs)
  if specs.src then specs = { specs } end
  local to_add = {}
  for _, p in ipairs(specs) do
    p.name = p.name or name_of(p.src)
    M.plugins[p.name] = p
    table.insert(M.order, p.name)
    table.insert(to_add, { src = p.src, name = p.name, version = p.version })
  end
  -- load = noop: só instala/registra; quem decide quando carregar somos nós.
  vim.pack.add(to_add, { confirm = false, load = function() end })
  for _, p in ipairs(specs) do
    if is_lazy(p) then
      setup_triggers(p)
    else
      M.load(p.name)
    end
  end
end

-- Hooks de build (ex.: :UpdateRemotePlugins do molten) após instalar/atualizar.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("devenv.pack.build", { clear = true }),
  callback = function(ev)
    local d = ev.data
    local p = M.plugins[d.spec.name]
    if p and p.build and (d.kind == "install" or d.kind == "update") then
      local function run()
        local ok, err = pcall(p.build, d.path)
        if not ok then vim.notify(("build de %s falhou: %s"):format(d.spec.name, err), vim.log.levels.WARN) end
      end
      -- Na primeira instalação o init.lua ainda está rodando: comandos dos plugins
      -- do runtime (ex.: :UpdateRemotePlugins) só existem depois do VimEnter.
      if vim.v.vim_did_enter == 1 then
        vim.schedule(run)
      else
        vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = run })
      end
    end
  end,
})

--- Carrega todos os plugins (usado pelos testes).
function M.load_all()
  for _, name in ipairs(M.order) do
    M.load(name)
  end
end

-- Gerenciador -----------------------------------------------------------------

local function short(rev) return rev and rev:sub(1, 8) or "" end

local function trigger_of(p)
  if p.event then return "event " .. table.concat(list(p.event), ",") end
  if p.ft then return "ft " .. table.concat(list(p.ft), ",") end
  if p.cmd then return "cmd " .. table.concat(list(p.cmd), ",") end
  if p.keys then return "teclas" end
  return "início"
end

--- Abre o gerenciador. `online = true` busca atualizações antes de listar.
function M.ui(online)
  local infos = vim.pack.get(nil, { info = true, offline = not online })
  local items = {}
  for _, info in ipairs(infos) do
    local p = M.plugins[info.spec.name] or {}
    local pending = info.rev_to and info.rev_to ~= info.rev
    table.insert(items, {
      text = info.spec.name,
      name = info.spec.name,
      info = info,
      plugin = p,
      pending = pending,
      orphan = not info.active,
    })
  end
  table.sort(items, function(a, b)
    if a.pending ~= b.pending then return a.pending end
    return a.name < b.name
  end)

  Snacks.picker.pick({
    title = online and "Plugins (com atualizações verificadas)" or "Plugins  (<a-c> verificar atualizações)",
    items = items,
    layout = { preset = "default" },
    format = function(item)
      local p, info = item.plugin, item.info
      local state = item.orphan and { "✗ fora da config", "DiagnosticError" }
        or p.loaded and { "● carregado", "DiagnosticOk" }
        or { "○ sob demanda", "Comment" }
      local ms = p.load_ms and ("%.1fms"):format(p.load_ms) or ""
      return {
        { ("%-28s"):format(item.name), "SnacksPickerFile" },
        { ("%-18s"):format(state[1]), state[2] },
        { ("%-9s"):format(short(info.rev)), "Comment" },
        { item.pending and ("↑ " .. short(info.rev_to) .. "  ") or "", "DiagnosticWarn" },
        { ("%-22s"):format(trigger_of(p)), "Comment" },
        { ms, "Number" },
      }
    end,
    preview = function(ctx)
      local info = ctx.item.info
      local lines = {
        "# " .. ctx.item.name,
        "",
        "fonte:   " .. info.spec.src,
        "versão:  " .. tostring(info.spec.version or "branch padrão"),
        "commit:  " .. (info.rev or "?"),
        "pasta:   " .. info.path,
        "",
        "## últimos commits",
        "",
      }
      local log = vim.system({ "git", "-C", info.path, "log", "--oneline", "-15" }, { text = true }):wait()
      vim.list_extend(lines, vim.split(log.stdout or "", "\n", { trimempty = true }))
      ctx.preview:set_lines(lines)
      ctx.preview:highlight({ ft = "markdown" })
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        M.load(item.name)
        vim.notify("[pack] " .. item.name .. " carregado")
      end
    end,
    actions = {
      pack_update = function(picker)
        local names = vim.tbl_map(function(i) return i.name end, picker:selected({ fallback = true }))
        picker:close()
        vim.pack.update(names)
      end,
      pack_update_all = function(picker)
        picker:close()
        vim.pack.update()
      end,
      pack_delete = function(picker)
        local names = vim.tbl_map(function(i) return i.name end, picker:selected({ fallback = true }))
        picker:close()
        if vim.fn.confirm("Remover " .. table.concat(names, ", ") .. "?", "&Sim\n&Não", 2) == 1 then
          vim.pack.del(names, { force = true })
        end
      end,
      pack_check = function(picker)
        picker:close()
        vim.notify("[pack] verificando atualizações...")
        vim.schedule(function() M.ui(true) end)
      end,
    },
    win = {
      input = {
        keys = {
          ["<a-u>"] = { "pack_update", mode = { "n", "i" }, desc = "atualizar selecionados" },
          ["<a-U>"] = { "pack_update_all", mode = { "n", "i" }, desc = "atualizar todos" },
          ["<a-d>"] = { "pack_delete", mode = { "n", "i" }, desc = "remover" },
          ["<a-c>"] = { "pack_check", mode = { "n", "i" }, desc = "verificar atualizações" },
        },
      },
    },
  })
end

--- Resumo rápido no :messages.
function M.status()
  local total, loaded, ms = 0, 0, 0
  for _, p in pairs(M.plugins) do
    total = total + 1
    if p.loaded then
      loaded = loaded + 1
      ms = ms + (p.load_ms or 0)
    end
  end
  vim.notify(
    ("[pack] %d plugins, %d carregados agora (%.1fms), %d sob demanda"):format(total, loaded, ms, total - loaded)
  )
end

vim.api.nvim_create_user_command(
  "Pack",
  function(a) M.ui(a.bang) end,
  { bang = true, desc = "Gerenciador de plugins (! verifica atualizações)" }
)
vim.api.nvim_create_user_command(
  "PackUpdate",
  function(a) vim.pack.update(#a.fargs > 0 and a.fargs or nil) end,
  { nargs = "*", complete = function() return M.order end, desc = "Atualiza plugins (todos ou os nomes passados)" }
)
vim.api.nvim_create_user_command(
  "PackClean",
  function() vim.cmd("packdel ++all") end,
  { desc = "Remove plugins que saíram da config" }
)
vim.api.nvim_create_user_command(
  "PackRestore",
  function(a) vim.pack.update(#a.fargs > 0 and a.fargs or nil, { target = "lockfile", offline = true }) end,
  { nargs = "*", complete = function() return M.order end, desc = "Volta os plugins às versões do lockfile" }
)
vim.api.nvim_create_user_command("PackStatus", M.status, { desc = "Resumo dos plugins" })

return M
