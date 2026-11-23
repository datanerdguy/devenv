-- Os formatos de centenas de arquivos YAML (workflows do GitHub,
-- docker-compose.yml...), pelo SchemaStore. O catálogo que o yamlls baixaria
-- sozinho fica desligado: o do plugin já traz os mesmos.
return {
  settings = {
    yaml = {
      schemaStore = { enable = false, url = "" },
      schemas = require("schemastore").yaml.schemas(),
    },
  },
}
