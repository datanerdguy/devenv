-- Cursor sempre em bloco, com a cor do modo igual à do fish: verde escreve, vermelho normal, amarelo visual.
-- As cores vêm do mesmo arquivo do fish, que o Noctalia regrava a cada `theme` (docs/temas.md).

vim.o.guicursor = "n-c-o-r-cr-sm:block-CursorNormal,i-ci-ve:block-CursorInsert,v:block-CursorVisual"

local state_dir = vim.fs.joinpath(vim.env.XDG_STATE_HOME or vim.fs.normalize("~/.local/state"), "devenv")
local colors_file = vim.fs.joinpath(state_dir, "fish-cursor.fish")

-- O padrão é o Nord, como no fish antes do primeiro `theme`.
local function read_colors()
  local colors = { insert = "A3BE8C", normal = "BF616A", visual = "EBCB8B" }
  local ok, lines = pcall(io.lines, colors_file)
  if ok then
    for line in lines do
      local mode, hex = line:match("devenv_cursor_(%a+)%s+(%x+)")
      if mode then
        colors[mode] = hex
      end
    end
  end
  return colors
end

local function apply()
  local colors = read_colors()
  for mode, group in pairs({ insert = "CursorInsert", normal = "CursorNormal", visual = "CursorVisual" }) do
    vim.api.nvim_set_hl(0, group, { bg = "#" .. colors[mode], fg = "NONE" })
  end
end

apply()
-- O tema novo apaga os grupos de realce; o cursor volta logo depois.
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })

-- O Noctalia regrava o arquivo de cores a cada `theme` (vigia a pasta, como o theme.lua).
local watcher = vim.uv.new_fs_event()
if watcher and vim.uv.fs_stat(state_dir) then
  watcher:start(state_dir, {}, function(_, file)
    if file == "fish-cursor.fish" then
      vim.schedule(apply)
    end
  end)
end
