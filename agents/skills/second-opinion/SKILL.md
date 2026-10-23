---
name: second-opinion
description: Pede uma revisão independente a outro agente (Codex ou Gemini) sobre um diff, um plano ou uma dúvida. Use antes de um merge importante, quando estiver em dúvida entre duas abordagens, ou quando o usuário pedir uma segunda opinião.
---

# Segunda opinião

Peça a outro agente, em modo não interativo, que revise algo e devolva só as conclusões.

1. Monte um pedido curto e autocontido: o objetivo, o que revisar e o formato da resposta
   (lista de problemas com severidade, ou "sem problemas").
2. Escolha o revisor pela tabela de roteamento do AGENTS.md:
   - diff ou código: Codex, que lê o diff sozinho no sandbox só de leitura
     `codex exec --sandbox read-only "Rode git diff <base>... e revise: <pedido>"`
   - muito contexto (repo inteiro, documentos longos): Gemini, em modo de plano (não edita nada)
     `gemini --approval-mode plan -p "<pedido>"`
3. Leia a resposta com senso crítico: confira cada ponto no código antes de aceitar.
4. Responda ao usuário com o que você aceitou, o que descartou e por quê.

Se o CLI escolhido não estiver logado, diga isso e sugira `codex login` ou `gemini` (login no primeiro uso).
