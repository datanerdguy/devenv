# lt pelo eza. Função, não abreviação: a linha de comando continua mostrando só "lt".
function lt --wraps eza
    eza -T --level=2 --group-directories-first --icons=auto $argv
end
