# 0011. Agentes e git

Data: 2026-11-21 · Status: aceita

## Contexto

A área de agentes e git é a segunda depois da base (ADR 0010). O agente é o Claude Code com a assinatura Pro,
sem chave de API. A config antiga (ADR 0003) mesclava o settings por um script Python, usava o workmux no tmux e
dois MCPs. As decisões abaixo saíram de uma sessão de perguntas e respostas.

## Decisão

- **Instruções.** O `~/.claude/CLAUDE.md` é um link para `agents/AGENTS.md`. Não há pasta intermediária.
- **Settings mesclado, não ligado.** O Claude também grava no `~/.claude/settings.json` (tema, plugins) e no
  `~/.claude.json` (login, estado). Um link faria o Claude escrever no repo. O chezmoi usa scripts `modify_`:
  o `agents/merge-json.sh` mescla com o `jq` as chaves de `agents/settings.json` e `agents/mcp.json` no arquivo
  atual. As chaves do devenv vencem; as outras ficam. O `~/.claude.json` continua 0600.
- **Pacote.** `claude-code` pelo metapac (grupo `agentes`), com o auto-update desligado: quem atualiza é o pacman.
- **Modelo.** Sonnet é o padrão da sessão. O pstack usa `agents/pstack-models.md`, sem Fable em nenhum papel,
  para não gastar a cota do Pro.
- **Plugins.** pstack e mattpocock-skills ficam declarados no settings. Sem skills próprias por enquanto.
- **MCP.** Só o `context7`, que é remoto e não pede chave. O índice local `docs-mcp` sai (pedia Node e npx).
- **Sandbox.** O Bash do Claude roda isolado (bubblewrap + socat): escreve só no projeto e sai só para os domínios
  liberados. Dentro dele, roda sem pedir permissão. Regras `deny` impedem ler a chave age, `~/.ssh`, o `rbw`, as
  credenciais do Claude e os `.env`. Os caches das linguagens são graváveis; as pastas dos binários das
  toolchains não.
- **Workmux fica de fora.** Ele depende do tmux, que é área do Lucas, e volta junto com ela se fizer falta.
- **Git.** O config fica em `~/.config/git/config` (link); o `~/.gitconfig` fica para o helper do `gh`.
  Delta é o pager, lazygit é a interface. HTTPS pelo `gh`, sem assinar commits.
- **Identidade sem age.** Nome e email ficam em texto. O email é o noreply do GitHub e já é público em cada
  commit, então cifrar não protege nada e faria o git depender da chave age numa máquina nova.

## Alternativas

- **Link para o settings:** simples, mas o Claude escreveria no repo a cada `/plugin` ou troca de tema.
- **Template completo do settings (sem mesclar):** apagaria o que o Claude grava.
- **Email cifrado com age:** proteção nula para um endereço público, e mais um passo para a máquina nova.
- **Assinar commits com chave SSH:** dá o selo "Verified", mas cria uma chave para guardar. Liga depois sem custo.

## Consequências

- O `jq` entra no bootstrap antes do `chezmoi apply`, porque os `modify_` precisam dele.
- Mudanças no settings valem no próximo `just apply`, não na hora. Uma chave do settings que você mudar pelo
  Claude e que o devenv também gerencia volta ao valor do repo no próximo apply.
- Um comando que o sandbox barra (`sudo`, `paru`, escrever fora do projeto, site não liberado) roda de novo fora
  dele, pedindo permissão.
- A chave age e o item `devenv-age-key` no Bitwarden ficam para o primeiro segredo de verdade.
