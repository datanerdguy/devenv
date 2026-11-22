# devenv

O ambiente de desenvolvimento do Lucas, montado sobre a distro e guardado neste repo para ser refeito em
qualquer máquina.

## Linguagem

**Máquina**:
Um computador onde o devenv é aplicado, com a sua distro e o seu hardware.
_Evite_: host, sistema

**Área**:
Uma parte do ambiente que muda e é revisada sozinha, num PR próprio (shell, terminal, Neovim, desktop...).
_Evite_: módulo, fase

**Pacote da máquina**:
Programa instalado para a máquina toda e para sempre, presente na lista declarativa de pacotes.
_Evite_: dependência global, ferramenta do sistema

**Versão do projeto**:
A versão de uma linguagem que um projeto fixa nos seus próprios arquivos e que vale só dentro dele.
_Evite_: runtime, toolchain global

**Ferramenta do projeto**:
Ferramenta que o próprio projeto declara e instala para si (por exemplo, um linter nas dependências dele), e que
tem prioridade sobre a mesma ferramenta como pacote da máquina.
_Evite_: ferramenta local, dev dependency

**Tema**:
Uma família de cores com nome próprio, que vale para o desktop inteiro de uma vez (Nord, Catppuccin, Kanagawa...).
_Evite_: esquema de cores, colorscheme

**Variante**:
Uma versão de um tema, com as suas próprias cores oficiais (o Mocha e o Frappé do Catppuccin). É o que se escolhe ao
trocar de tema.
_Evite_: flavor, sabor, estilo
