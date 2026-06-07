#!/usr/bin/env bash
# Bash interactive setup. Mirrors ~/.config/zsh/interactive.zsh where bash can,
# using only built-ins (no framework). GNU readline already provides menu-complete
# on TAB, history-search on the arrows, and colored / case-insensitive completion
# via ~/.config/readline/inputrc (${INPUTRC}); this file adds the shell-option and
# completion-framework pieces readline cannot do.

# history: dedupe + share across sessions (≈ zsh HIST_IGNORE_*, SHARE_HISTORY) ##
HISTFILE="${HISTFILE:-${HOME}/.bash_history}"
HISTSIZE=20000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend cmdhist lithist
# flush + reload history on every prompt so sessions share it (≈ SHARE_HISTORY);
# guarded so re-sourcing does not stack the commands.
case "${PROMPT_COMMAND}" in
    *'history -a'*) : ;;
    *) PROMPT_COMMAND="history -a; history -n;${PROMPT_COMMAND:+ ${PROMPT_COMMAND}}" ;;
esac

# directory / globbing (≈ AUTO_CD, EXTENDED_GLOB, NO_CASE_GLOB, cd spelling) ####
shopt -s cdspell checkwinsize extglob nocaseglob no_empty_cmd_completion
shopt -s autocd dirspell globstar 2> /dev/null # bash >= 4 only

# completion ###################################################################
# Load the bash-completion framework. v2.10+ then lazily discovers envoy's
# generated completions in ${XDG_DATA_HOME}/bash-completion/completions/* (and
# anything else under that XDG dir) — no manual sourcing loop required.
if ! shopt -oq posix; then
    for _bc in \
        "${HOMEBREW_PREFIX:+${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh}" \
        /usr/share/bash-completion/bash_completion \
        /etc/bash_completion; do
        if [[ -n ${_bc} && -r ${_bc} ]]; then
            # shellcheck disable=SC1090
            . "${_bc}"
            break
        fi
    done
    unset _bc
fi
