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
# bash-completion (v2.10+ then lazily loads per-command completions from
# ${XDG_DATA_HOME}/bash-completion/completions/, incl. envoy's). The OS loads this
# for login shells; source it directly here for non-login interactive shells. One
# path suffices: /usr/share/... is the canonical location on every mainstream
# distro, and the /etc/profile.d + /etc/bash_completion variants only re-source it.
if ! shopt -oq posix && [[ -r /usr/share/bash-completion/bash_completion ]]; then
    # shellcheck disable=SC1091
    . /usr/share/bash-completion/bash_completion
fi
