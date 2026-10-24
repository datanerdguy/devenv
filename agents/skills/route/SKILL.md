---
name: route
description: Decide qual agente e modelo deve fazer uma tarefa e delega quando outro for melhor. Use quando o usuário pedir para distribuir tarefas, ao planejar trabalho em paralelo, ou quando a tarefa for de um tipo que a tabela de roteamento manda para outro agente.
---

# Rotear uma tarefa

1. Classifique a tarefa pelas tabelas do AGENTS.md global: agente, modelo e effort.
   Ao delegar a um subagente do Claude, passe o modelo explícito (Haiku busca, Sonnet edita).
2. Se for sua, faça. Se for de outro agente:
   - tarefa curta com resposta direta: rode o agente em modo não interativo e use o resultado
     (`codex exec "<pedido>"`, `gemini -p "<pedido>"`, `opencode run "<pedido>"`).
   - tarefa longa ou que muda código: crie um worktree com o agente certo,
     `workmux add <nome-curto> -a <claude|codex|gemini|opencode> -p "<pedido completo>"`,
     e diga ao usuário onde ela está rodando (`workmux dashboard`).
3. Várias tarefas independentes: uma por worktree (`workmux add`), no máximo 3 ao mesmo tempo.
4. Ao terminar, resuma o que cada agente fez e o que falta.
