-- No Python, o ty e o ruff acusariam duas vezes o mesmo erro. Ficam com o ty
-- o erro de sintaxe e o nome não definido (F821): ele conhece os tipos e o
-- .venv, e o ruff só olha o arquivo. Vale em todo projeto, com ou sem config
-- do ruff.
return {
  init_options = { settings = { showSyntaxErrors = false } },
  handlers = require("config.lsp_without")(
    function(d) return d.code == "F821" end
  ),
}
