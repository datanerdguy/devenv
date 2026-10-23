-- Lista de plugins, por área. Cada arquivo chama require("devenv.pack").add(...).
-- O lockfile (nvim-pack-lock.json) fixa o commit de cada um e fica no git.
require("devenv.plugins.ui")
require("devenv.plugins.editor")
require("devenv.plugins.coding")
require("devenv.plugins.ai")
require("devenv.plugins.notebooks")
require("devenv.plugins.debug")
