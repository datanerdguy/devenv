-- Análises extras (staticcheck, parâmetro sem uso, variável que esconde outra)
-- e o mesmo estilo do formatador (gofumpt, plugins/format.lua).
return {
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      analyses = { unusedparams = true, shadow = true },
    },
  },
}
