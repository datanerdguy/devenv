-- No Python, o ruff cuida do lint e das correções; a documentação (K), o erro
-- de sintaxe e o nome não definido (F821) ficam com o ty, que conhece os tipos
-- e o .venv. Assim nada aparece duas vezes, em qualquer projeto.
return {
  on_attach = function(client) client.server_capabilities.hoverProvider = false end,
  init_options = { settings = { showSyntaxErrors = false } },
  handlers = require("config.lsp_without")(
    function(d) return d.code == "F821" end
  ),
}
