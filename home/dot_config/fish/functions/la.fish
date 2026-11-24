# la pelo eza. Função, não abreviação: a linha de comando continua mostrando só "la".
function la --wraps eza
    eza -la --git --group-directories-first --icons=auto $argv
end
