---
name: second-opinion
description: Pede uma revisão independente a um subagente com outro modelo do Claude e contexto limpo, sobre um diff, um plano ou uma dúvida. Use antes de um merge importante, quando estiver em dúvida entre duas abordagens, ou quando o usuário pedir uma segunda opinião.
---

# Segunda opinião

Peça a um subagente, com um modelo diferente do que fez o trabalho, que revise algo e devolva só as conclusões.

1. Escolha o revisor pelo modelo de quem escreveu (o da sessão, ou o do subagente que fez a mudança):
   - escreveu com Haiku ou Sonnet: revisor `opus`, effort `high`.
   - escreveu com Opus: revisor `sonnet`, effort `high`.
   - Nunca `fable` (não entra no Pro).
2. Monte um pedido curto e autocontido: o objetivo da mudança, o que revisar (ex.: `git diff <base>...`,
   o arquivo do plano) e o formato da resposta (lista de problemas com severidade e arquivo:linha, ou "sem problemas").
   O revisor começa do zero: não mande o raciocínio de quem escreveu, só o objetivo e o artefato.
3. Rode o subagente com `model` e `effort` explícitos e só leitura: ele lê e roda comandos de inspeção, não edita.
4. Leia a resposta com senso crítico: confira cada ponto no código antes de aceitar.
5. Responda ao usuário com o que você aceitou, o que descartou e por quê, e qual modelo revisou.
