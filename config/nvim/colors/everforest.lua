-- Everforest Dark (fundo medium) no padrão do tema oficial do VS Code: sainnhe/everforest-vscode @ b17f8af.
-- Paleta de src/palette/dark; os comentários citam a regra (`name`) ou a chave de `colors` do themes/everforest-dark.json.
-- Cores com alfa do VS Code viram a mistura com o fundo, porque o Neovim não tem transparência por cor.
-- vim.g.everforest_transparent = true deixa o fundo vazio (terminal com opacidade, pcastr/theme.lua).

local p = {
  bg0 = "#21272b",
  bg1 = "#272e33",
  bg = "#2d353b",
  bg2 = "#343f44",
  bg3 = "#3d484d",
  bg4 = "#475258",
  bg5 = "#4f585e",
  grey0 = "#7f897d",
  grey1 = "#859289",
  grey2 = "#9aa79d",
  fg = "#d3c6aa",
  red = "#e67e80",
  orange = "#e69875",
  yellow = "#dbbc7f",
  green = "#a7c080",
  aqua = "#83c092",
  blue = "#7fbbb3",
  purple = "#d699b6",
  dim_red = "#da6362",
  dim_orange = "#d77f48",
  dim_yellow = "#bf983d",
  dim_green = "#899c40",
  dim_aqua = "#569d79",
  dim_blue = "#5a93a2",
  dim_purple = "#b87b9d",
}

local function blend(color, alpha)
  local a = tonumber(alpha, 16) / 255
  local function ch(hex, i) return tonumber(hex:sub(i, i + 1), 16) end
  local out = "#"
  for i = 2, 6, 2 do
    out = out .. string.format("%02x", math.floor(ch(color, i) * a + ch(p.bg, i) * (1 - a) + 0.5))
  end
  return out
end

local transparent = vim.g.everforest_transparent == true
local bg = transparent and "NONE" or p.bg
local float_bg = transparent and "NONE" or p.bg2

---@type table<string, vim.api.keyset.highlight>
local hl = {
  -- Editor (colors)
  Normal = { fg = p.fg, bg = bg }, -- editor.background / editor.foreground
  NormalNC = { link = "Normal" },
  NormalFloat = { fg = p.fg, bg = float_bg }, -- editorHoverWidget.background
  FloatBorder = { fg = p.bg4, bg = float_bg }, -- editorHoverWidget.border
  FloatTitle = { fg = p.green, bg = float_bg, bold = true }, -- peekViewTitleLabel.foreground
  Cursor = { fg = p.bg, bg = p.fg }, -- editorCursor.foreground
  lCursor = { link = "Cursor" },
  TermCursor = { link = "Cursor" },
  CursorLine = { bg = blend(p.bg3, "90") }, -- editor.lineHighlightBackground
  CursorColumn = { link = "CursorLine" },
  ColorColumn = { bg = blend(p.bg4, "a0") }, -- editorRuler.foreground
  LineNr = { fg = blend(p.grey0, "a0") }, -- editorLineNumber.foreground
  CursorLineNr = { fg = blend(p.grey2, "e0") }, -- editorLineNumber.activeForeground
  SignColumn = { bg = bg }, -- editorGutter.background
  FoldColumn = { fg = p.grey0, bg = bg },
  Folded = { fg = p.grey1, bg = blend(p.bg5, "80") }, -- editor.foldBackground
  Visual = { bg = blend(p.bg4, "c0") }, -- editor.selectionBackground
  VisualNOS = { link = "Visual" },
  Search = { bg = blend(p.dim_green, "40") }, -- editor.findMatchHighlightBackground
  CurSearch = { bg = blend(p.dim_orange, "40") }, -- editor.findMatchBackground
  IncSearch = { link = "CurSearch" },
  Substitute = { link = "CurSearch" },
  MatchParen = { bg = p.bg5 }, -- editorBracketMatch.background
  NonText = { fg = p.bg4 }, -- editorWhitespace.foreground
  Whitespace = { fg = p.bg4 },
  SpecialKey = { fg = p.bg4 },
  EndOfBuffer = { fg = p.bg },
  WinSeparator = { fg = p.bg5 }, -- editorWidget.border
  Directory = { fg = p.green },
  Title = { fg = p.green, bold = true },
  Conceal = { fg = p.grey0 },
  QuickFixLine = { bg = blend(p.dim_aqua, "50") }, -- peekViewResult.selectionBackground

  -- Menu de completar (editorSuggestWidget.*)
  Pmenu = { fg = p.fg, bg = p.bg3 },
  PmenuSel = { bg = p.bg4 },
  PmenuMatch = { fg = p.green },
  PmenuMatchSel = { fg = p.green, bg = p.bg4 },
  PmenuSbar = { bg = blend(p.bg5, "80") }, -- scrollbarSlider.background
  PmenuThumb = { bg = p.grey2 }, -- scrollbarSlider.activeBackground
  PmenuKind = { fg = p.blue, bg = p.bg3 },
  PmenuExtra = { fg = p.grey1, bg = p.bg3 },
  WildMenu = { link = "PmenuSel" },

  -- Barras (statusBar.*, tab.*)
  StatusLine = { fg = p.grey2, bg = bg },
  StatusLineNC = { fg = p.grey0, bg = bg },
  TabLine = { fg = p.grey0, bg = bg }, -- tab.inactiveForeground
  TabLineSel = { fg = p.fg, bg = bg, underline = true, sp = p.green }, -- tab.activeBorder
  TabLineFill = { bg = bg },
  WinBar = { fg = p.grey2, bg = bg },
  WinBarNC = { fg = p.grey0, bg = bg },

  ErrorMsg = { fg = p.red, bold = true },
  WarningMsg = { fg = p.yellow, bold = true },
  MoreMsg = { fg = p.green },
  ModeMsg = { fg = p.fg, bold = true },
  Question = { fg = p.yellow },
  MsgArea = { fg = p.fg },

  -- Diff (diffEditor.*, gitDecoration.*)
  DiffAdd = { bg = blend(p.dim_aqua, "30") },
  DiffDelete = { bg = blend(p.dim_red, "30") },
  DiffChange = { bg = blend(p.dim_blue, "30") },
  DiffText = { bg = blend(p.dim_blue, "60") },
  Added = { fg = p.green },
  Changed = { fg = p.blue },
  Removed = { fg = p.red },

  SpellBad = { undercurl = true, sp = p.red },
  SpellCap = { undercurl = true, sp = p.blue },
  SpellLocal = { undercurl = true, sp = p.aqua },
  SpellRare = { undercurl = true, sp = p.purple },

  -- Diagnósticos (editor*.foreground no sublinhado)
  DiagnosticError = { fg = p.red },
  DiagnosticWarn = { fg = p.yellow },
  DiagnosticInfo = { fg = p.blue },
  DiagnosticHint = { fg = p.purple },
  DiagnosticOk = { fg = p.green },
  DiagnosticUnderlineError = { undercurl = true, sp = p.dim_red },
  DiagnosticUnderlineWarn = { undercurl = true, sp = p.dim_yellow },
  DiagnosticUnderlineInfo = { undercurl = true, sp = p.dim_blue },
  DiagnosticUnderlineHint = { undercurl = true, sp = p.dim_purple },
  DiagnosticUnnecessary = { fg = p.grey0 },
  DiagnosticDeprecated = { strikethrough = true },
  LspInlayHint = { fg = blend(p.grey0, "a0") }, -- editorInlayHint.foreground
  LspCodeLens = { fg = blend(p.grey0, "a0") }, -- editorCodeLens.foreground
  LspReferenceText = { bg = blend(p.bg4, "58") }, -- editor.wordHighlightBackground
  LspReferenceRead = { link = "LspReferenceText" },
  LspReferenceWrite = { bg = blend(p.bg4, "b0") }, -- editor.wordHighlightStrongBackground
  LspSignatureActiveParameter = { fg = p.green, bold = true },

  -- Sintaxe (tokenColors, regras gerais)
  Comment = { fg = p.grey1, italic = true }, -- Comment
  Keyword = { fg = p.red }, -- Keyword
  Statement = { link = "Keyword" },
  Conditional = { link = "Keyword" },
  Repeat = { link = "Keyword" },
  Exception = { link = "Keyword" },
  Debug = { fg = p.red }, -- Debug
  StorageClass = { fg = p.orange }, -- Storage
  Operator = { fg = p.orange }, -- Operator
  String = { fg = p.yellow }, -- String
  Character = { link = "String" },
  SpecialChar = { fg = p.green }, -- String Escape
  Special = { fg = p.green },
  Function = { fg = p.green }, -- Function
  PreProc = { fg = p.aqua }, -- Preproc
  Include = { link = "PreProc" },
  Define = { link = "PreProc" },
  PreCondit = { link = "PreProc" },
  Label = { fg = p.aqua }, -- Label
  Type = { fg = p.blue }, -- Type
  Structure = { link = "Type" },
  Typedef = { link = "Type" },
  Number = { fg = p.purple }, -- Number
  Float = { link = "Number" },
  Boolean = { fg = p.purple }, -- Boolean
  Macro = { fg = p.purple }, -- Macro
  Constant = { fg = p.purple }, -- Constant
  Identifier = { fg = p.fg }, -- Identifier
  Delimiter = { fg = p.fg }, -- Delimiter
  Tag = { fg = p.orange }, -- Storage (entity.name.tag)
  Underlined = { underline = true },
  Error = { fg = p.red },
  Todo = { fg = p.purple, bold = true },

  -- Treesitter: o escopo do TextMate equivalente decide a cor
  ["@variable"] = { fg = p.fg }, -- Identifier
  ["@variable.builtin"] = { fg = p.purple }, -- Special identifier (self, this)
  ["@variable.parameter"] = { fg = p.fg }, -- Identifier (variable.parameter)
  ["@variable.member"] = { fg = p.fg }, -- Property
  ["@property"] = { fg = p.fg }, -- Property
  ["@constant"] = { fg = p.fg }, -- Identifier (variable.other.constant)
  ["@constant.builtin"] = { fg = p.purple }, -- Constant (constant.language)
  ["@constant.macro"] = { fg = p.purple }, -- Macro
  ["@module"] = { fg = p.aqua }, -- Modules
  ["@module.builtin"] = { fg = p.aqua },
  ["@label"] = { fg = p.aqua }, -- Label
  ["@string"] = { link = "String" },
  ["@string.escape"] = { fg = p.green }, -- String Escape
  ["@string.special"] = { fg = p.green },
  ["@string.regexp"] = { link = "String" },
  ["@string.special.url"] = { fg = p.green, underline = true },
  ["@character"] = { link = "String" },
  ["@character.special"] = { fg = p.green },
  ["@boolean"] = { link = "Boolean" },
  ["@number"] = { link = "Number" },
  ["@number.float"] = { link = "Number" },
  ["@type"] = { link = "Type" },
  ["@type.builtin"] = { link = "Type" }, -- Type (support.type)
  ["@type.definition"] = { link = "Type" },
  ["@attribute"] = { fg = p.aqua }, -- Annotation
  ["@attribute.builtin"] = { fg = p.aqua },
  ["@function"] = { link = "Function" },
  ["@function.builtin"] = { link = "Function" }, -- Function (support.function)
  ["@function.call"] = { link = "Function" },
  ["@function.macro"] = { fg = p.purple }, -- Macro
  ["@function.method"] = { link = "Function" },
  ["@function.method.call"] = { link = "Function" },
  ["@constructor"] = { link = "Function" }, -- Function (meta.function-call)
  ["@operator"] = { link = "Operator" },
  ["@keyword"] = { link = "Keyword" },
  ["@keyword.function"] = { link = "Keyword" }, -- Keyword (storage.type.function)
  ["@keyword.type"] = { link = "Keyword" }, -- Keyword (storage.type.class)
  ["@keyword.operator"] = { link = "Keyword" }, -- Keyword (keyword.operator.expression)
  ["@keyword.modifier"] = { fg = p.orange }, -- Storage (storage.modifier)
  ["@keyword.import"] = { fg = p.aqua }, -- Preproc (keyword.control.import)
  ["@keyword.directive"] = { fg = p.aqua }, -- Preproc
  ["@keyword.directive.define"] = { fg = p.aqua },
  ["@keyword.debug"] = { link = "Debug" },
  ["@keyword.exception"] = { link = "Keyword" },
  ["@keyword.conditional"] = { link = "Keyword" },
  ["@keyword.repeat"] = { link = "Keyword" },
  ["@keyword.return"] = { link = "Keyword" },
  ["@keyword.coroutine"] = { link = "Keyword" },
  ["@punctuation"] = { fg = p.fg }, -- Delimiter
  ["@punctuation.bracket"] = { fg = p.fg },
  ["@punctuation.delimiter"] = { fg = p.fg },
  ["@punctuation.special"] = { fg = p.green }, -- String Escape (punctuation.section.embedded)
  ["@comment"] = { link = "Comment" },
  ["@comment.documentation"] = { link = "Comment" },
  ["@comment.todo"] = { link = "Todo" },
  ["@comment.note"] = { fg = p.blue, bold = true },
  ["@comment.warning"] = { fg = p.yellow, bold = true },
  ["@comment.error"] = { fg = p.red, bold = true },
  ["@tag"] = { link = "Tag" }, -- Html orange
  ["@tag.builtin"] = { link = "Tag" },
  ["@tag.attribute"] = { fg = p.yellow }, -- Attribute
  ["@tag.delimiter"] = { fg = p.green }, -- Html green (punctuation.definition.tag)
  ["@diff.plus"] = { fg = p.green }, -- Diff green
  ["@diff.minus"] = { fg = p.red }, -- Diff red
  ["@diff.delta"] = { fg = p.blue }, -- Diff blue

  ["@markup.heading.1"] = { fg = p.red, bold = true }, -- Markdown heading1
  ["@markup.heading.2"] = { fg = p.orange, bold = true },
  ["@markup.heading.3"] = { fg = p.yellow, bold = true },
  ["@markup.heading.4"] = { fg = p.green, bold = true },
  ["@markup.heading.5"] = { fg = p.blue, bold = true },
  ["@markup.heading.6"] = { fg = p.purple, bold = true },
  ["@markup.heading"] = { fg = p.orange, bold = true },
  ["@markup.link"] = { fg = p.purple }, -- Markdown link
  ["@markup.link.label"] = { fg = p.purple },
  ["@markup.link.url"] = { fg = p.green, underline = true }, -- Markdown link text
  ["@markup.raw"] = { fg = p.green }, -- Markdown code block
  ["@markup.raw.block"] = { fg = p.green },
  ["@markup.list"] = { fg = p.red }, -- Markdown list mark
  ["@markup.list.checked"] = { fg = p.green },
  ["@markup.list.unchecked"] = { fg = p.grey1 },
  ["@markup.quote"] = { fg = p.grey1, italic = true },
  ["@markup.italic"] = { italic = true }, -- Markdown italic
  ["@markup.strong"] = { bold = true }, -- Markdown bold
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@punctuation.special.markdown"] = { fg = p.grey1 }, -- Markdown heading delimiter
  ["@label.markdown"] = { fg = p.yellow }, -- Markdown code type

  ["@keyword.import.python"] = { fg = p.purple }, -- Python purple
  ["@constant.builtin.python"] = { fg = p.aqua }, -- Python aqua (constant.language.python)
  ["@boolean.python"] = { fg = p.aqua },
  ["@attribute.python"] = { fg = p.green }, -- Function (entity.name.function.decorator)
  ["@constant.builtin.lua"] = { fg = p.aqua }, -- Lua aqua
  ["@boolean.lua"] = { fg = p.aqua },
  ["@keyword.import.go"] = { fg = p.purple }, -- Go purple
  ["@keyword.type.go"] = { fg = p.red }, -- Go red
  ["@module.go"] = { fg = p.aqua }, -- Go aqua
  ["@module.rust"] = { fg = p.fg }, -- Rust white
  ["@keyword.modifier.rust"] = { fg = p.orange }, -- Rust orange
  ["@attribute.rust"] = { fg = p.purple }, -- Rust purple
  ["@variable.builtin.rust"] = { fg = p.purple },
  ["@property.json"] = { fg = p.orange }, -- JSON orange
  ["@string.json"] = { fg = p.green }, -- JSON green
  ["@property.yaml"] = { fg = p.orange }, -- Storage (entity.name.tag.yaml)
  ["@string.yaml"] = { fg = p.green }, -- YAML green
  ["@property.toml"] = { fg = p.orange }, -- TOML orange
  ["@string.toml"] = { fg = p.green }, -- TOML green
  ["@boolean.toml"] = { fg = p.blue }, -- TOML blue
  ["@string.bash"] = { fg = p.green }, -- Shell green
  ["@function.builtin.bash"] = { fg = p.yellow }, -- Shell yellow
  ["@function.bash"] = { fg = p.yellow },
  ["@variable.bash"] = { fg = p.purple }, -- Shell purple
  ["@variable.parameter.bash"] = { fg = p.purple },

  -- Tokens semânticos do LSP (semanticTokenColors)
  ["@lsp.type.operator"] = { fg = p.orange }, -- operatorOverload
  ["@lsp.type.class.python"] = { fg = p.aqua },
  ["@lsp.type.module.python"] = { fg = p.blue },
  ["@lsp.typemod.function.defaultLibrary.python"] = { fg = p.purple }, -- intrinsic:python
  ["@lsp.type.class.typescript"] = { fg = p.aqua },
  ["@lsp.type.interface.typescript"] = { fg = p.aqua },
  ["@lsp.type.enum.typescript"] = { fg = p.purple },
  ["@lsp.type.enumMember.typescript"] = { fg = p.blue },
  ["@lsp.type.namespace.typescript"] = { fg = p.purple },
  ["@lsp.typemod.variable.defaultLibrary.typescript"] = { fg = p.purple },
  ["@lsp.typemod.property.defaultLibrary.typescript"] = { fg = p.purple },
  ["@lsp.typemod.variable.defaultLibrary.javascript"] = { fg = p.purple },
  ["@lsp.typemod.property.defaultLibrary.javascript"] = { fg = p.purple },
  ["@lsp.type.macro.rust"] = { fg = p.aqua },
  ["@lsp.type.namespace.rust"] = { fg = p.purple },
  ["@lsp.type.selfKeyword.rust"] = { fg = p.purple },

  -- Plugins: gitsigns (editorGutter.*Background)
  GitSignsAdd = { fg = blend(p.dim_green, "a0") },
  GitSignsChange = { fg = blend(p.dim_blue, "a0") },
  GitSignsDelete = { fg = blend(p.dim_red, "a0") },
  -- snacks (editorIndentGuide.*)
  SnacksIndent = { fg = blend(p.grey2, "20") },
  SnacksIndentScope = { fg = blend(p.grey2, "50") },
  SnacksPickerMatch = { fg = p.green },
  SnacksPickerDir = { fg = p.grey1 },
  TreesitterContext = { bg = p.bg2 },
  TreesitterContextLineNumber = { fg = p.grey1, bg = p.bg2 },
  -- blink.cmp (editorSuggestWidget.*)
  BlinkCmpMenu = { link = "Pmenu" },
  BlinkCmpMenuBorder = { fg = p.bg3, bg = p.bg3 },
  BlinkCmpMenuSelection = { link = "PmenuSel" },
  BlinkCmpLabelMatch = { fg = p.green },
  BlinkCmpDoc = { link = "NormalFloat" },
  BlinkCmpDocBorder = { link = "FloatBorder" },
  MiniStatuslineModeNormal = { fg = p.bg, bg = p.green, bold = true },
  MiniStatuslineModeInsert = { fg = p.bg, bg = p.blue, bold = true },
  MiniStatuslineModeVisual = { fg = p.bg, bg = p.purple, bold = true },
  MiniStatuslineModeReplace = { fg = p.bg, bg = p.orange, bold = true },
  MiniStatuslineModeCommand = { fg = p.bg, bg = p.yellow, bold = true },
  MiniStatuslineModeOther = { fg = p.bg, bg = p.aqua, bold = true },
  MiniStatuslineDevinfo = { fg = p.grey2, bg = p.bg3 },
  MiniStatuslineFilename = { fg = p.grey2, bg = float_bg },
  MiniStatuslineFileinfo = { fg = p.grey2, bg = p.bg3 },
  MiniStatuslineInactive = { fg = p.grey0, bg = bg },
  WhichKey = { fg = p.green },
  WhichKeyGroup = { fg = p.blue },
  WhichKeyDesc = { fg = p.fg },
  WhichKeySeparator = { fg = p.grey1 },
  OilDir = { fg = p.green },
}

vim.cmd.highlight("clear")
vim.g.colors_name = "everforest"
vim.o.background = "dark"
for name, spec in pairs(hl) do
  vim.api.nvim_set_hl(0, name, spec)
end

-- terminal.ansi*
local term = {
  p.bg2,
  p.red,
  p.green,
  p.yellow,
  p.blue,
  p.purple,
  p.aqua,
  p.fg,
  p.grey1,
  p.red,
  p.green,
  p.yellow,
  p.blue,
  p.purple,
  p.aqua,
  p.fg,
}
for i, c in ipairs(term) do
  vim.g["terminal_color_" .. (i - 1)] = c
end
