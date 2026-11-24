-- Confere a config do Neovim já carregada (roda pelo tests/check-nvim.sh) e
-- falha com a lista do que estiver errado.
local problems = {}
local function problem(text) table.insert(problems, text) end

-- Abriu sem erro nem aviso, e com o tema.
local messages = vim.trim(vim.fn.execute("messages"))
if messages ~= "" or vim.v.errmsg ~= "" then
  problem("mensagem ao abrir: " .. messages .. vim.v.errmsg)
end
if not vim.g.colors_name then problem("o tema não carregou") end

-- Cada servidor de plugins/lsp.lua existe no nvim-lspconfig e tem o comando
-- instalado. Servidor com o comando montado por função fica de fora.
for _, name in ipairs(require("plugins.lsp").servers) do
  local cmd = vim.lsp.config[name] and vim.lsp.config[name].cmd
  if not vim.lsp.config[name] then
    problem("LSP " .. name .. ": o nvim-lspconfig não tem esse nome")
  elseif type(cmd) == "table" and vim.fn.executable(cmd[1]) == 0 then
    problem("LSP " .. name .. ": falta o comando " .. cmd[1])
  end
end

-- Cada linguagem de plugins/treesitter.lua tem o parser, e um .py abre com o
-- realce do treesitter.
for _, language in ipairs(require("plugins.treesitter").languages) do
  if not vim.treesitter.language.add(language) then
    problem("treesitter: falta o parser de " .. language)
  end
end
vim.cmd.edit(vim.fn.tempname() .. ".py")
if not vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] then
  problem("treesitter: o realce não ligou num .py")
end

-- O lua_ls, com os tipos do Neovim e dos plugins, não avisa nada em nenhum
-- arquivo da config. Ele não avisa o fim: acabou quando ficou 5 s quieto.
for _, file in
  ipairs(vim.fn.globpath(vim.fn.stdpath("config"), "**/*.lua", false, true))
do
  vim.cmd.edit(file)
end
local last = vim.uv.now()
vim.api.nvim_create_autocmd({ "LspAttach", "LspProgress" }, {
  callback = function() last = vim.uv.now() end,
})
local idle = vim.wait(
  120000,
  function()
    return #vim.lsp.get_clients({ name = "lua_ls" }) > 0
      and vim.uv.now() - last > 5000
  end,
  500
)
if not idle then problem("lua_ls: não terminou a tempo") end
for _, d in ipairs(vim.diagnostic.get()) do
  if vim.bo[d.bufnr].filetype == "lua" then
    local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(d.bufnr), ":~")
    problem(("lua_ls: %s:%d: %s"):format(file, d.lnum + 1, d.message))
  end
end

if #problems > 0 then
  io.stderr:write(
    "Neovim com problema:\n- " .. table.concat(problems, "\n- ") .. "\n"
  )
  vim.cmd.cquit(1)
end
vim.cmd.qall()
