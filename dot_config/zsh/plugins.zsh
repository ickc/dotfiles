#!/usr/bin/env zsh
# Line-editing plugins (replaces zimfw's zsh-users/* modules).
# Fetched by .chezmoiexternal.toml. Sourced from ~/.zshrc after fzf/starship/
# direnv/navi so that syntax-highlighting loads last and
# history-substring-search loads after it.
if [[ ${TERM} != dumb ]]; then
    _plugins="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/plugins"
    # shellcheck disable=SC1091
    [[ -r "${_plugins}/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && . "${_plugins}/zsh-autosuggestions/zsh-autosuggestions.zsh"
    # shellcheck disable=SC1091
    [[ -r "${_plugins}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && . "${_plugins}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    if [[ -r "${_plugins}/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
        # shellcheck disable=SC1091
        . "${_plugins}/zsh-history-substring-search/zsh-history-substring-search.zsh"
        # Type part of a command, then Up/Down (or Ctrl-P/Ctrl-N) to walk
        # matching history. Bind after sourcing, once the widgets exist.
        # shellcheck disable=SC2154
        bindkey "${terminfo[kcuu1]:-^[[A}" history-substring-search-up
        # shellcheck disable=SC2154
        bindkey "${terminfo[kcud1]:-^[[B}" history-substring-search-down
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
        bindkey '^P' history-substring-search-up
        bindkey '^N' history-substring-search-down
    fi
    unset _plugins
fi
