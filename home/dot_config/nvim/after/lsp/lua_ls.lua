-- lua_ls: fora de um projeto com .luarc.json próprio, entende o Lua do Neovim (o global vim, as funções da API).
-- Receita do nvim-lspconfig (lsp/lua_ls.lua). Fica em after/ para valer por cima da config dele.
return {
  on_init = function(client)
    local root = client.workspace_folders and client.workspace_folders[1].name
    if root and (vim.uv.fs_stat(root .. "/.luarc.json") or vim.uv.fs_stat(root .. "/.luarc.jsonc")) then return end
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
    })
  end,
  settings = { Lua = {} },
}
