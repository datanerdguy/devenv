# Segredos

Módulo: [`modules/secrets`](../modules/secrets/default.nix) ([sops-nix](https://github.com/Mic92/sops-nix)).
Decisão: [ADR 0007](adr/0007-segredos-sops.md).

O que precisa estar na máquina, como o seu e-mail do git e os tokens de API, fica em `secrets/<host>.yaml`,
cifrado com uma chave [age](https://age-encryption.org). O arquivo vai para o git: só os valores são cifrados,
mas os nomes das chaves ficam visíveis no repo público. No login, um serviço do systemd do usuário (`sops-nix`)
abre os segredos em `$XDG_RUNTIME_DIR`, que fica na RAM. Eles nunca vão para o disco em texto puro, e
`~/.config/sops-nix/secrets` aponta para lá.

A chave fica em `~/.config/sops/age/keys.txt`, e uma cópia fica no Bitwarden (item `devenv-age-key`). Sem a
chave, o host funciona igual, só que sem os segredos.

Para o resto (senhas, segredos que você usa uma vez), continue com o `rbw get <nome>`.

## Primeira vez

```bash
secrets init                 # cria a chave, o .sops.yaml e secrets/fedora-laptop.yaml, e abre o arquivo para editar
rbw add devenv-age-key       # cole como senha a linha AGE-SECRET-KEY-... de ~/.config/sops/age/keys.txt
git add .sops.yaml secrets/ && git commit -m "feat(secrets): segredos do notebook"
just switch
```

Preencha o arquivo assim:

```yaml
git:
  name: Lucas
  email: seu-email@exemplo.com
env:
  HF_TOKEN: hf_...
```

Com o arquivo no repo, o host liga os segredos sozinho (`devenv.secrets.host = "fedora-laptop"`). A partir daí,
o nome e o e-mail do git vêm de `git/name` e `git/email`, e não mais de `hosts/fedora-laptop.nix`.

## Dia a dia

| Comando | O que faz |
| --- | --- |
| `secrets edit` | Abre o arquivo decifrado no `$EDITOR`; o sops cifra de novo ao salvar e os segredos são reabertos |
| `secrets status` | Mostra a chave e os segredos abertos nesta sessão |
| `secrets restore` | Numa máquina nova: traz a chave do Bitwarden e abre os segredos |

**Variável de ambiente nova**: rode `secrets edit`, acrescente `env.MEU_TOKEN`, ponha o nome na lista do host
(`devenv.secrets.env = [ "HF_TOKEN" "MEU_TOKEN" ];`) e rode `just switch`. O fish e o bash leem o arquivo ao
abrir, sem processo novo, então a abertura do shell continua leve. Um nome listado que falte no arquivo faz o
`just switch` falhar, de propósito.

## Máquina nova

1. `./bootstrap.sh <host>`. Sem a chave, a troca avisa `Sem a chave dos segredos` e segue.
2. `rbw config set email <seu e-mail> && rbw login`
3. `secrets restore`

## Outra máquina ou outra pessoa

Cada chave pública no `.sops.yaml` pode abrir os arquivos. Para dar acesso a uma máquina com chave própria,
acrescente a chave pública dela (separada por vírgula) e rode `sops updatekeys secrets/<host>.yaml`. Para tirar
o acesso, remova a chave, rode o mesmo comando e troque os segredos que a máquina conhecia.

## Teste no CI

O host `ci` usa uma chave **só de teste**, com dados falsos (`tests/secrets/`). O teste de instalação abre o
arquivo e confere se o git e o fish recebem os valores (`tests/smoke.sh`).
