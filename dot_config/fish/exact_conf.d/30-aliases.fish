# Aliases ≈ ml_lsd. Interactive shells only, as in ~/.config/sh/rc.sh: scripts
# keep the real ls and tree.
if status is-interactive; and type -q lsd
    alias ls lsd
    alias tree 'lsd --tree'
end
