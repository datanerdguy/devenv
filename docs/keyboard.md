# Teclado: Corne v4.1 (Vial)

<!-- Gerado por keyboard/render.py a partir dos .vil. Não edite à mão: rode `just keyboard-doc`. -->

As tabelas seguem a matriz do firmware, na ordem em que o Vial salva o arquivo (4 linhas × 12 colunas).
As colunas 0–5 são a metade esquerda; as teclas extras e os polegares ficam nas linhas e colunas do fim.
`▽` = transparente (usa a camada de baixo), `·` = sem tecla nessa posição.

Para mudar: abra o Vial (`vial`), edite ao vivo e salve com *File → Save current layout* por cima do
`.vil` do repo. Para testar a sugestão: *File → Load saved layout* e escolha `corne-devenv.vil`.
Detalhes em [desktop.md](desktop.md#teclado).

## Seu layout atual (`keyboard/corne/corne.vil`)

### Camada 0

| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Esc/\` | Q | W | E | R | T | Vol+ | Y | U | I | O | P |
| Shift | A | S | D | F | G | Vol- | H | J | K | L | ; |
| Ctrl | Z | X | C | V | B | · | N | M | , | . | / |
| Caps | Tab | · | Alt | Enter | Camada 2 | Camada 1 | Espaço | AltGr | ⌫ | ' | Shift |

### Camada 1

| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| \` | ! | @ | # | $ | % |  | ^ | & | * | ( | ) |
| Shift | 1 | 2 | 3 | 4 | 5 |  | 6 | 7 | 8 | 9 | 0 |
| Ctrl |  |  |  |  |  | · |  |  |  |  |  |
| Caps | Tab | · | Alt | Enter | Camada 3 | ▽ |  |  | ⌫ |  |  |

### Camada 2

| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  | { | } | - | _ |
| Shift |  |  | < | > |  |  |  | ( | ) | = | + |
| Ctrl |  |  |  |  |  | · |  | [ | ] | < | > |
|  |  | · |  |  | ▽ | Camada 3 | Espaço |  | \ | \| |  |

### Camada 3

| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  | 🖱← | 🖱↓ | 🖱↑ | 🖱→ |  |
|  |  | Busca |  |  |  |  | ← | ↓ | ↑ | → |  |
|  |  |  |  |  |  | · |  | Clique | Clique dir. |  |  |
|  |  | · |  |  | ▽ | ▽ |  |  |  |  |  |

### Combos

| Teclas juntas | Resultado |
| --- | --- |
| Alt + 1 | F1 |

## Sugestão do devenv (`keyboard/corne/corne-devenv.vil`)

### Camada 0

| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Esc/\` | Q | W | E | R | T | Vol+ | Y | U | I | O | P |
| Shift | A | S | D | F | G | Vol- | H | J | K | L | ; |
| Ctrl | Z | X | C | V | B | · | N | M | , | . | / |
| Super | Tab | · | Alt | Enter | Camada 2 | Camada 1 | Espaço | AltGr | ⌫ | ' | Shift |

### Camada 1

| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| \` | ! | @ | # | $ | % |  | ^ | & | * | ( | ) |
| Shift | 1 | 2 | 3 | 4 | 5 |  | 6 | 7 | 8 | 9 | 0 |
| Ctrl |  |  |  |  |  | · |  |  |  |  |  |
| Caps | Tab | · | Alt | Enter | Camada 3 | ▽ |  |  | ⌫ |  |  |

### Camada 2

| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  | macro `->` | macro `=>` | macro `:=` | macro `\|>` |  |  |  | { | } | - | _ |
| Shift | ~ | \` | < | > |  |  |  | ( | ) | = | + |
| Ctrl |  |  |  |  |  | · |  | [ | ] | < | > |
|  |  | · |  |  | ▽ | Camada 3 | Espaço |  | \ | \| |  |

### Camada 3

| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| F1 | F2 | F3 | F4 | F5 | F6 |  | 🖱← | 🖱↓ | 🖱↑ | 🖱→ | PgUp |
| F7 | F8 | F9 | F10 | F11 | F12 |  | ← | ↓ | ↑ | → | PgDn |
| ⏮ | ⏯ | ⏭ | Mudo | Brilho- | Brilho+ | · | Home | Clique | Clique dir. | End | Del |
|  |  | · |  |  | ▽ | ▽ |  |  |  |  | Print |

### Combos

| Teclas juntas | Resultado |
| --- | --- |
| Alt + 1 | F1 |
| J + K | Esc |
| D + F | Tab |
