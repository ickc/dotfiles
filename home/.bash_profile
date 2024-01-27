[[ -e "$HOME/.config/zsh/.zshenv" ]] && . "$HOME/.config/zsh/.zshenv"
[[ -e "$HOME/.config/zsh/.zshrc" ]] && . "$HOME/.config/zsh/.zshrc" > /dev/null 2>&1
_SHELL="$(command -v zsh)"
if [[ $? -eq 0 ]]; then
    export SHELL="$_SHELL"
    exec "$SHELL" -l
fi
