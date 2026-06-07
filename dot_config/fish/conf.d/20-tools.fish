# Interactive tool hooks (mirror the unified block in ~/.config/sh/rc.sh).
if status is-interactive
    # conda / mamba (≈ ml_conda) — miniforge ships a fish hook
    if test -f $MAMBA_ROOT_PREFIX/etc/fish/conf.d/conda.fish
        source $MAMBA_ROOT_PREFIX/etc/fish/conf.d/conda.fish
    end

    # prompt + navigation tools
    type -q starship; and starship init fish | source
    type -q fzf; and fzf --fish | source
    type -q direnv; and direnv hook fish | source
    type -q navi; and navi widget fish | source

    # sman (≈ ml_s)
    if test -f $XDG_DATA_HOME/sman/sman.fish
        source $XDG_DATA_HOME/sman/sman.fish
    end

    # git external diff (set in rc.sh for bash/zsh)
    type -q difft; and set -gx GIT_EXTERNAL_DIFF difft

    # greeting — show fastfetch instead of fish's default welcome
    function fish_greeting
        type -q fastfetch; and fastfetch
    end
end
