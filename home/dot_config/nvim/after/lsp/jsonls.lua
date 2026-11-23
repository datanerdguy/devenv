-- Os formatos de centenas de arquivos JSON (package.json, tsconfig.json...),
-- pelo SchemaStore: completa as chaves e acusa a chave errada.
return {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
}
