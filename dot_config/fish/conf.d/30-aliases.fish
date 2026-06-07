# Aliases ≈ ml_lsd. `alias` defines a function, so this is safe for every session
# (it only shadows ls/tree when lsd is actually installed).
if type -q lsd
    alias ls 'lsd'
    alias tree 'lsd --tree'
end
