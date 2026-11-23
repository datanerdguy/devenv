-- Segue um arquivo de ~/.local/state que o Noctalia regrava a cada `theme`:
-- chama on_change(path) agora e a cada mudança. Vigia a pasta, e não o arquivo,
-- porque o arquivo pode ser trocado por outro (e o vigia perderia o rastro).
local state = vim.env.XDG_STATE_HOME or vim.fs.normalize("~/.local/state")

return function(dir, file, on_change)
  dir = vim.fs.joinpath(state, dir)
  local path = vim.fs.joinpath(dir, file)
  on_change(path)
  local watcher = vim.uv.new_fs_event()
  if not (watcher and vim.uv.fs_stat(dir)) then return end
  watcher:start(dir, {}, function(_, changed)
    if changed == file then vim.schedule(function() on_change(path) end) end
  end)
end
