-- Ctrl+j/k/l/;: anda entre as janelas do Neovim e, na borda, segue para o painel vizinho do tmux.
-- As mesmas teclas do niri (Alt+j/k/l/;), com Ctrl: esquerda, baixo, cima, direita. docs/tmux.md.

local pane = vim.env.TMUX_PANE

local function tmux(...) return vim.system({ "tmux", ... }) end

local function go(wincmd, tmux_dir)
  return function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(wincmd)
    if pane and vim.api.nvim_get_current_win() == win then tmux("select-pane", "-t", pane, "-" .. tmux_dir) end
  end
end

local map = vim.keymap.set
map("n", "<C-j>", go("h", "L"), { desc = "[Janela] Esquerda" })
map("n", "<C-k>", go("j", "D"), { desc = "[Janela] Abaixo" })
map("n", "<C-l>", go("k", "U"), { desc = "[Janela] Acima" })
map("n", "<C-;>", go("l", "R"), { desc = "[Janela] Direita" })

-- A marca @pane-is-vim diz ao tmux que as teclas são do Neovim enquanto ele está aberto neste painel.
if pane then
  local group = vim.api.nvim_create_augroup("devenv_tmux", {})
  vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
    group = group,
    callback = function() tmux("set-option", "-p", "-t", pane, "@pane-is-vim", "1") end,
  })
  vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
    group = group,
    -- Espera o tmux: o Neovim pode sair antes de a marca sumir.
    callback = function() tmux("set-option", "-p", "-u", "-t", pane, "@pane-is-vim"):wait() end,
  })
end
