local M = {}

--- Instala sem carregar. Quem usa chama o loader no gatilho.
---@param specs (string|vim.pack.Spec)[]
function M.install(specs)
  vim.pack.add(specs, { confirm = false, load = function() end })
end

--- Função que faz o packadd dos plugins e roda o setup uma única vez.
---@param names string[]
---@param setup? fun()
---@return fun()
function M.loader(names, setup)
  local done = false
  local function load()
    if done then return end
    done = true
    for _, name in ipairs(names) do
      vim.cmd.packadd(name)
    end
    if setup then setup() end
  end
  table.insert(M.loaders, load)
  return load
end

--- Todos os loaders criados, para o teste carregar tudo (tests/nvim/check.lua).
---@type fun()[]
M.loaders = {}

---@class pcastr.LazyKey
---@field [1] string lhs
---@field [2] string|fun() rhs
---@field desc string
---@field mode? string|string[]

--- Teclas que carregam o plugin antes de agir.
---@param load fun()
---@param keys pcastr.LazyKey[]
function M.keys(load, keys)
  for _, k in ipairs(keys) do
    local rhs = k[2]
    vim.keymap.set(k.mode or "n", k[1], function()
      load()
      if type(rhs) == "function" then return rhs() end
      vim.api.nvim_feedkeys(vim.keycode(rhs), "m", false)
    end, { desc = k.desc })
  end
end

--- Comandos que carregam o plugin e rodam de novo com os mesmos argumentos.
---@param load fun()
---@param names string[]
function M.cmds(load, names)
  for _, name in ipairs(names) do
    vim.api.nvim_create_user_command(name, function(a)
      vim.api.nvim_del_user_command(name)
      load()
      vim.cmd({
        cmd = name,
        args = a.fargs,
        bang = a.bang,
        range = a.range > 0 and { a.line1, a.line2 } or nil,
      })
    end, { nargs = "*", bang = true, range = true })
  end
end

--- Roda `fn` depois de instalar ou atualizar o plugin (build). Chame antes do vim.pack.add dele.
---@param name string
---@param fn fun()
function M.on_change(name, fn)
  vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("pcastr.build." .. name, { clear = true }),
    callback = function(ev)
      local d = ev.data
      if d.spec.name ~= name or (d.kind ~= "install" and d.kind ~= "update") then return end
      local function run()
        local ok, err = pcall(fn)
        if not ok then vim.notify(("build de %s falhou: %s"):format(name, err), vim.log.levels.ERROR) end
      end
      -- Na primeira instalação o init.lua ainda roda: os comandos do plugin só existem depois do VimEnter.
      if vim.v.vim_did_enter == 1 then
        vim.schedule(run)
      else
        vim.api.nvim_create_autocmd("VimEnter", { group = ev.group, once = true, callback = run })
      end
    end,
  })
end

return M
