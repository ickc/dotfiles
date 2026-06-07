#!/usr/bin/env bash
# Shared interactive setup for bash + zsh.
# Sourced by ~/.zshrc and (when interactive) ~/.bashrc. Loads the PATH/module
# system, the per-shell interactive setup, the prompt/navigation tool hooks, and
# the ssh-agent.
#
# * use `__CLEAN=1 <shell>` to load a minimal environment (ml_clean) instead of
#   the full module set (ml).

# __HOST/__OSTYPE used below are exported by env.sh, which is sourced first.
# shellcheck disable=SC2154

# shell identity drives the unified tool-hook arguments below
if [[ -n ${ZSH_VERSION} ]]; then
    _shell=zsh
else
    _shell=bash
fi

# set title of prompt. c.f. https://tldp.org/HOWTO/Xterm-Title-3.html
printf "\033]0;%s\007" "${__HOST%%.*}"

# PATH / module system: defines path_*, ml_*, ml, mu and resets PATH ###########
# shellcheck source=dot_config/sh/modules.sh
. "${XDG_CONFIG_HOME:-${HOME}/.config}/sh/modules.sh"

# functions ####################################################################

# https://stackoverflow.com/a/30547074/5769446
startsudo() {
    sudo -v
    (while true; do
        sudo -v
        sleep 50
    done) &
    SUDO_PID="$!"
    trap stopsudo SIGINT SIGTERM
}
stopsudo() {
    kill "${SUDO_PID}"
    trap - SIGINT SIGTERM
    sudo -k
}

# ssh: start an agent if none is reachable, then load the default identity.
# Unifies the old auto_ssh_agent() (.bashrc) and the inline zsh block. `set +C`
# inside the subshell makes the redirection noclobber-safe in both shells (zsh
# sets NO_CLOBBER via interactive.zsh), replacing zsh's `>!` and bash's bare `>`.
# modified from https://github.com/zimfw/ssh/blob/master/init.zsh
_ssh_env_safe() {
    local f=$1 uid
    # Only source if it's a regular, non-symlink file owned by the current user.
    [[ -f $f && ! -L $f ]] || return 1
    uid=$(stat -c '%u' "$f" 2>/dev/null) || uid=$(stat -f '%u' "$f" 2>/dev/null) || return 1
    [[ $uid -eq $(id -u) ]]
}

auto_ssh_agent() {
    local ssh_env="${HOME}/.ssh-agent" rc

    ssh-add -l > /dev/null 2>&1
    rc=$?
    if [[ ${rc} -eq 2 ]]; then
        # no reachable agent: try the stored connection info first
        # shellcheck disable=SC1090
        _ssh_env_safe "${ssh_env}" && . "${ssh_env}" > /dev/null
        ssh-add -l > /dev/null 2>&1
        rc=$?
        if [[ ${rc} -eq 2 ]]; then
            # stored agent is dead/absent: start a fresh one
            (
                umask 066
                set +C
                ssh-agent > "${ssh_env}"
            )
            # shellcheck disable=SC1090
            _ssh_env_safe "${ssh_env}" && . "${ssh_env}" > /dev/null
        fi
    fi
    # agent reachable but holds no identities: add the default key
    ssh-add -l > /dev/null 2>&1
    rc=$?
    [[ ${rc} -eq 1 ]] && { ssh-add "${HOME}/.ssh/id_ed25519" 2> /dev/null || ssh-add 2> /dev/null; }
}

# per-shell interactive setup (early) ##########################################
# must precede ml: zsh's ml_conda relies on compinit from interactive.zsh
if [[ -n ${ZSH_VERSION} ]]; then
    # shellcheck disable=SC1091
    . "${XDG_CONFIG_HOME:-${HOME}/.config}/zsh/interactive.zsh"
elif [[ -n ${BASH_VERSION} ]]; then
    # shellcheck source=dot_config/bash/interactive.bash
    . "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/interactive.bash"
fi

# load environment modules #####################################################
if [[ -n ${__CLEAN} ]]; then
    ml_clean
else
    ml
fi

# limits / umask (copied from cosma's .bashrc) #################################
ulimit -c 0                      # No core dumps
ulimit -s unlimited 2> /dev/null # Limited stack size can cause segfaults with ifort
# even if this doesn't mask the world readability
# the parent directories should protect it already
umask 022

# git external diff ############################################################
# PATH is only fully built after ml above
command -v difft > /dev/null 2>&1 && export GIT_EXTERNAL_DIFF=difft

# prompt / navigation tool hooks (unified across bash & zsh) ####################
# shellcheck disable=SC1090,SC2312
command -v fzf > /dev/null 2>&1 && . <(fzf "--${_shell}")
# shellcheck disable=SC1090,SC2312
command -v starship > /dev/null 2>&1 && . <(starship init "${_shell}")
# shellcheck disable=SC2312
command -v direnv > /dev/null 2>&1 && eval "$(direnv hook "${_shell}")"
# shellcheck disable=SC2312
command -v navi > /dev/null 2>&1 && eval "$(navi widget "${_shell}")"

# per-shell interactive setup (late) ###########################################
# line-editing plugins; loaded after the hooks so syntax-highlighting is last
if [[ -n ${ZSH_VERSION} ]]; then
    # shellcheck disable=SC1091
    . "${XDG_CONFIG_HOME:-${HOME}/.config}/zsh/plugins.zsh"
fi

# ssh-agent (single unified call for both shells) ##############################
command -v ssh-agent > /dev/null 2>&1 && auto_ssh_agent

# greeting #####################################################################
command -v fastfetch > /dev/null 2>&1 && fastfetch

# alias ########################################################################
if [[ ${__OSTYPE} == Darwin ]]; then
    if [[ -f /Applications/JupyterLab.app/Contents/Resources/app/jlab ]]; then
        alias jlab='bash /Applications/JupyterLab.app/Contents/Resources/app/jlab'
    fi
    if [[ -e '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' ]]; then
        alias code='/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code'
    fi
fi

unset _shell
