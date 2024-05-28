#!/usr/bin/env bash

: # for shellcheck scope
# shellcheck disable=SC1091
[[ -e "$HOME/.config/zsh/.zshenv" ]] && . "$HOME/.config/zsh/.zshenv"
if [[ $- == *i* ]]; then
    # if $0 is -bash, then it means I cannot chsh to zsh, so we start zsh manually
    if [[ $0 == -bash ]]; then
        # shellcheck disable=SC1091
        [[ -e "$HOME/.config/zsh/.zshrc" ]] && . "$HOME/.config/zsh/.zshrc" > /dev/null 2>&1
        _SHELL="$(command -v zsh)"
        if [[ $? -eq 0 ]]; then
            export SHELL="$_SHELL"
            exec "$SHELL" -l
        fi
    # otherwise, it means I start bash deliberately, so we stay in bash
    else
        # shellcheck disable=SC1091
        [[ -e "$HOME/.config/zsh/.zshrc" ]] && . "$HOME/.config/zsh/.zshrc"
    fi
fi
