# Abreviação dotdot: .. vira cd ../, ... vira cd ../../, e assim por diante.
function _devenv_multicd
    echo cd (string repeat --count (math (string length -- $argv[1]) - 1) ../)
end
