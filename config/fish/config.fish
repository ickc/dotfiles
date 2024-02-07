if status is-interactive
    if test -f ~/.mambaforge/etc/fish/conf.d/conda.fish
        source ~/.mambaforge/etc/fish/conf.d/conda.fish
    end
    starship init fish | source
    if test -f ~/.sman/sman.fish
        source ~/.sman/sman.fish
    end
end
