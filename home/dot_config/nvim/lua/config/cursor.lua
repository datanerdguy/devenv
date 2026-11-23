-- Cursor sempre em bloco, com a cor do modo igual à do fish: verde escreve, vermelho normal, amarelo visual.
-- As cores vêm do mesmo arquivo do fish, que o Noctalia regrava a cada `theme` (docs/temas.md).

vim.o.guicursor = "n-c-o-r-cr-sm:block-CursorNormal,i-ci-ve:block-CursorInsert,v:block-CursorVisual"

local groups = { insert = "CursorInsert", normal = "CursorNormal", visual = "CursorVisual" }
-- O padrão é o Nord, como no fish antes do primeiro `theme`.
local colors = { insert = "A3BE8C", normal = "BF616A", visual = "EBCB8B" }

local function apply()
  for mode, group in pairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "#" .. colors[mode], fg = "NONE" })
  end
end

require("config.watch")("devenv", "fish-cursor.fish", function(path)
  local ok, lines = pcall(io.lines, path)
  if not ok then return apply() end
  for line in lines do
    local mode, hex = line:match("devenv_cursor_(%a+)%s+(%x+)")
    if groups[mode] then colors[mode] = hex end
  end
  apply()
end)

-- O tema novo apaga os grupos de realce; o cursor volta logo depois.
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })
