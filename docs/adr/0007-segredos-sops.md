# 0007. Segredos com sops-nix e uma chave age guardada no Bitwarden

Data: 2026-10-23 · Status: aceita

## Contexto

O repo é público, e ainda assim cada máquina precisa de dados que não podem ficar nele em texto puro: o e-mail do
git, tokens de API (Hugging Face, Context7). O Bitwarden (`rbw`) já guarda as senhas, mas só entrega um valor
quando é pedido. Ele não monta arquivos de config nem funciona sem rede na primeira vez. A solução também tem de
ser leve: abrir um shell não pode esperar o cofre.

Opções avaliadas: [documento da fase 8](https://claude.ai/artifact/1pHwyXL6yBqFXK9HpKRwmr).

## Decisão

- **sops-nix** no home-manager: `secrets/<host>.yaml`, cifrado com age e versionado no repo. Um serviço do
  systemd do usuário abre os segredos no login, em `$XDG_RUNTIME_DIR` (RAM).
- **Uma chave age por pessoa**, em `~/.config/sops/age/keys.txt`, com cópia no Bitwarden. O comando `secrets`
  cria a chave e o arquivo (`init`), edita (`edit`) e restaura numa máquina nova (`restore`).
- **Liga sozinho** quando `secrets/<host>.yaml` existe. Sem a chave, a troca só avisa e não falha.
- Primeiros usos: a identidade do git (um trecho de gitconfig gerado por template) e variáveis de ambiente
  lidas pelo fish e pelo bash sem processo novo.
- O `rbw` continua para senhas e segredos de uso pontual (`.envrc.local` dos projetos).

## Consequências

- Os nomes das chaves ficam visíveis no repo; só os valores são cifrados.
- Perder a chave e a cópia no Bitwarden é perder os segredos. Eles podem ser recriados, mas não recuperados.
- Chaves SSH e o login do `gh` ficam de fora: eles têm lugar próprio.
- **Alternativas descartadas**: agenix (um arquivo por segredo e sem templates) e só o rbw (nada declarativo, e
  o e-mail do git continuaria sem lugar).
