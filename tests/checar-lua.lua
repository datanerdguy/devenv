-- Passa o lua_ls em cada arquivo da config do Neovim, com os tipos do Neovim e dos plugins (lazydev): pega opção com
-- tipo errado, função com argumentos a mais ou a menos e campo que não existe. Qualquer aviso falha.
-- Roda pelo tests/checar-nvim.sh, com a config do Neovim já carregada.
local files = vim.fn.globpath(vim.fn.stdpath("config"), "**/*.lua", false, true)
for _, file in ipairs(files) do
  vim.cmd.edit(file)
end

-- O lua_ls avisa o progresso (carregar a biblioteca, analisar os arquivos) e não manda nada para arquivo sem aviso.
-- Terminou quando ficou 5 segundos sem progresso nenhum.
local last = vim.uv.now()
vim.api.nvim_create_autocmd({ "LspAttach", "LspProgress" }, { callback = function() last = vim.uv.now() end })
local done = vim.wait(
  120000,
  function() return #vim.lsp.get_clients({ name = "lua_ls" }) > 0 and vim.uv.now() - last > 5000 end,
  500
)
if not done then
  io.stderr:write("O lua_ls não terminou a tempo.\n")
  vim.cmd.cquit(1)
end

local problems = {}
for _, d in ipairs(vim.diagnostic.get()) do
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(d.bufnr), ":~")
  table.insert(problems, ("%s:%d: %s"):format(name, d.lnum + 1, d.message))
end
if #problems > 0 then
  io.stderr:write("Lua da config com aviso do lua_ls:\n", table.concat(problems, "\n"), "\n")
  vim.cmd.cquit(1)
end
vim.cmd.qall()
