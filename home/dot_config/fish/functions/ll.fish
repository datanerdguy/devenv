# ll pelo eza. Função, não abreviação: a linha de comando continua mostrando só "ll".
function ll --wraps eza
    eza -l --git --group-directories-first --icons=auto $argv
end
