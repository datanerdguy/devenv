-- Ao salvar, roda o clippy em vez do cargo check: mais avisos, pelo mesmo
-- custo.
return {
  settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
}
