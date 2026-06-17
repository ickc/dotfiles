# Interactive tool hooks (mirror the unified block in ~/.config/sh/rc.sh).
# conda/mamba are on PATH but nothing is auto-activated; run the `conda-shell`
# function (functions/conda-shell.fish) on demand when you need `activate`.
if status is-interactive
    # terminal title: short hostname (≈ rc.sh's printf to the xterm title)
    printf '\033]0;%s\007' (string split -m1 . $HOSTNAME)[1]

    # limits / umask (mirror rc.sh)
    ulimit -c 0                       # no core dumps
    ulimit -s unlimited 2>/dev/null   # unlimited stack (ifort segfaults otherwise)
    umask 022

    # prompt + navigation tools
    type -q starship; and starship init fish | source
    type -q fzf; and fzf --fish | source
    type -q direnv; and direnv hook fish | source
    type -q navi; and navi widget fish | source

    # sman (≈ ml_s)
    test -f $XDG_DATA_HOME/sman/sman.fish; and source $XDG_DATA_HOME/sman/sman.fish

    # git external diff (set in rc.sh for bash/zsh)
    type -q difft; and set -gx GIT_EXTERNAL_DIFF difft

    # greeting — show fastfetch instead of fish's default welcome
    function fish_greeting
        type -q fastfetch; and fastfetch
    end
end
