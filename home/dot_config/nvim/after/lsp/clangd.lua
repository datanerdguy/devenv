-- Avisos do clang-tidy, e o completar não acrescenta #include sozinho.
return {
  cmd = { "clangd", "--clang-tidy", "--header-insertion=never" },
}
