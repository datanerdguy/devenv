-- Neovim do devenv (docs/neovim.md). O que é nativo do Neovim 0.13 primeiro;
-- plugin só quando o nativo não cobre: temas, busca, explorer, LSP, treesitter,
-- formatar, completar e o Claude.

-- Nativo (lua/config/): opções e atalhos sem plugin. As opções vêm primeiro,
-- porque definem o <leader>.
require("config.options")
require("config.cursor")
require("config.keymaps")
require("config.navigation")

-- Plugins (lua/plugins/): um arquivo por assunto, com a config e os atalhos
-- dele. O tema vem primeiro, porque os outros tiram as cores dele.
require("plugins.theme")
require("plugins.search")
require("plugins.notes")
require("plugins.explorer")
require("plugins.lsp")
require("plugins.treesitter")
require("plugins.diagnostics")
require("plugins.format")
require("plugins.completion")
require("plugins.csv")
require("plugins.claude")
