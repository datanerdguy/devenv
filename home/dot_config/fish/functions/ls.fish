# ls pelo eza. Função, não abreviação: a linha de comando continua mostrando só "ls".
function ls --wraps eza
    eza --group-directories-first --icons=auto $argv
end
