#!/usr/bin/env zsh
# Native zsh interactive setup.
# Sourced from ~/.config/sh/rc.sh before ml/ml_conda so that compinit is
# available. Sets up: environment (options + history), completion (compinit +
# styling), input (key bindings), and run-help. The ssh-agent is started by
# rc.sh (shared with bash);
# starship/direnv/fzf/navi load via their own hooks in rc.sh; the zsh-users/*
# line-editing plugins load via plugins.zsh after those hooks so that
# syntax-highlighting is sourced last.

zmodload zsh/terminfo 2> /dev/null
autoload -Uz is-at-least

# environment: directory, glob, job and I/O options
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME
is-at-least 5.8 && setopt CD_SILENT
setopt EXTENDED_GLOB INTERACTIVE_COMMENTS NO_CLOBBER
setopt LONG_LIST_JOBS NO_BG_NICE NO_CHECK_JOBS NO_HUP

# environment: history
[[ -n ${HISTFILE} ]] || HISTFILE="${ZDOTDIR:-${HOME}}/.zhistory"
HISTSIZE=20000
# shellcheck disable=SC2034  # SAVEHIST is a zsh special variable read by the shell
SAVEHIST=10000
setopt HIST_FIND_NO_DUPS HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY SHARE_HISTORY

if [[ ${TERM} != dumb ]]; then
    # completion: fpath (envoy-generated completions + zsh-completions) then compinit
    # shellcheck disable=SC2206
    fpath=(
        "${XDG_DATA_HOME}/zsh/functions"
        "${XDG_DATA_HOME}/zsh/plugins/zsh-completions/src"
        ${fpath}
    )
    setopt ALWAYS_TO_END COMPLETE_IN_WORD NO_CASE_GLOB NO_LIST_BEEP
    autoload -Uz compinit
    _zcompdump="${ZDOTDIR:-${HOME}}/.zcompdump"
    # Run the full security check at most once a day; trust the dump otherwise.
    # shellcheck disable=SC2312
    if [[ -f ${_zcompdump} && -n "$(find "${_zcompdump}" -mtime -1 2> /dev/null)" ]]; then
        compinit -C -d "${_zcompdump}"
    else
        compinit -d "${_zcompdump}"
    fi
    # Compile the dump for faster subsequent loads.
    [[ ${_zcompdump}.zwc -nt ${_zcompdump} ]] || zcompile -R "${_zcompdump}" 2> /dev/null
    unset _zcompdump

    # completion: styling
    zstyle ':completion::complete:*' use-cache on
    zstyle ':completion:*' menu select
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' verbose yes
    zstyle ':completion:*' squeeze-slashes true
    zstyle ':completion:*' insert-tab false
    zstyle ':completion:*' single-ignored show
    zstyle ':completion:*:matches' group yes
    zstyle ':completion:*:options' description yes
    zstyle ':completion:*:options' auto-description '%d'
    zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
    zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
    zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
    zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
    # Smart case: case-insensitive until an uppercase character is typed.
    zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' '+r:|[._-]=* r:|=*' '+l:|=*'
    zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec)|prompt_*)'
    zstyle ':completion:*:*:-subscript-:*' tag-order 'indexes' 'parameters'
    zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
    zstyle ':completion:*:history-words' stop yes
    zstyle ':completion:*:history-words' remove-all-dups yes
    zstyle ':completion:*:history-words' list false
    zstyle ':completion:*:history-words' menu yes
    zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
    zstyle ':completion:*:rm:*' file-patterns '*:all-files'
    zstyle ':completion:*:manuals' separate-sections true
    zstyle ':completion:*:manuals.(^1*)' insert-sections true

    # input: key bindings
    [[ -n ${terminfo[khome]} ]] && bindkey "${terminfo[khome]}" beginning-of-line
    [[ -n ${terminfo[kend]} ]] && bindkey "${terminfo[kend]}" end-of-line
    [[ -n ${terminfo[kdch1]} ]] && bindkey "${terminfo[kdch1]}" delete-char
    [[ -n ${terminfo[kich1]} ]] && bindkey "${terminfo[kich1]}" overwrite-mode
    [[ -n ${terminfo[kpp]} ]] && bindkey "${terminfo[kpp]}" up-line-or-history
    [[ -n ${terminfo[knp]} ]] && bindkey "${terminfo[knp]}" down-line-or-history
    [[ -n ${terminfo[kcbt]} ]] && bindkey "${terminfo[kcbt]}" reverse-menu-complete
    # Ctrl-Left / Ctrl-Right: move by word (cover common terminal sequences).
    for _k in '^[[1;5C' '^[[5C' '^[Oc'; do bindkey "${_k}" forward-word; done
    for _k in '^[[1;5D' '^[[5D' '^[Od'; do bindkey "${_k}" backward-word; done
    unset _k
    bindkey ' ' magic-space   # expand history references (e.g. !!) on space
    bindkey '^[.' insert-last-word
    bindkey '^[_' insert-last-word
    autoload -Uz edit-command-line && zle -N edit-command-line
    bindkey '^X^E' edit-command-line   # edit the command line in $EDITOR
    # Smart URL pasting/escaping.
    autoload -Uz bracketed-paste-url-magic && zle -N bracketed-paste bracketed-paste-url-magic
    autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic
    # Keep terminfo key sequences valid while editing (application mode).
    if [[ -n ${terminfo[smkx]} && -n ${terminfo[rmkx]} ]]; then
        autoload -Uz add-zle-hook-widget
        _zle_app_start() { echoti smkx; }
        _zle_app_stop() { echoti rmkx; }
        add-zle-hook-widget line-init _zle_app_start
        add-zle-hook-widget line-finish _zle_app_stop
    fi

    # run-help: Esc-h shows help for the command on the current line
    unalias run-help 2> /dev/null
    autoload -Uz run-help
    if [[ -z ${HELPDIR} ]]; then
        for _d in /usr/local/share/zsh/help "/usr/share/zsh/${ZSH_VERSION}/help" /usr/share/zsh/help; do
            if [[ -d ${_d} ]]; then
                HELPDIR="${_d}"
                break
            fi
        done
        unset _d
    fi
    bindkey '^[h' run-help
    bindkey '^[H' run-help
    for _c in git ip openssl sudo svn; do
        command -v "${_c}" > /dev/null 2>&1 && autoload -Uz "run-help-${_c}"
    done
    unset _c
fi
