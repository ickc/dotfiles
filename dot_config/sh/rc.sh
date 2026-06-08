#!/usr/bin/env bash
# Shared interactive setup for bash + zsh.
# Sourced by ~/.zshrc and (when interactive) ~/.bashrc. Loads the PATH/module
# system, the per-shell interactive setup, the prompt/navigation tool hooks, and
# the ssh-agent.
#
# * use `__CLEAN=1 <shell>` to load only the base `core` module instead of the
#   full module set. The module system is Lmod (see ~/.config/modulefiles/).

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

# create the XDG base directories (and astropy's, which ignores XDG)
mkdir_xdg() {
    mkdir -p \
        "${XDG_DATA_HOME}" \
        "${XDG_STATE_HOME}" \
        "${XDG_CONFIG_HOME}" \
        "${XDG_CACHE_HOME}" \
        "${XDG_CONFIG_HOME}/astropy" \
        "${XDG_CACHE_HOME}/astropy"
}

# The `conda` modulefile only puts condabin on PATH (clean load/unload); the
# shell function needed by `conda activate` is not wired there. Call this to
# source the hook on demand when you actually need to activate an environment.
conda-shell() {
    if [[ -n ${ZSH_VERSION} ]]; then
        # shellcheck disable=SC1090,SC2312
        command -v conda > /dev/null 2>&1 && . <(conda shell.zsh hook)
        # shellcheck disable=SC1090,SC2312
        command -v mamba > /dev/null 2>&1 && . <(mamba shell hook --shell zsh)
    else
        # shellcheck disable=SC1090,SC2312
        command -v conda > /dev/null 2>&1 && . <(conda shell.bash hook)
        # shellcheck disable=SC1090,SC2312
        command -v mamba > /dev/null 2>&1 && . <(mamba shell hook --shell bash)
    fi
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
# loaded before the prompt/navigation hooks below so zsh's compinit is ready
if [[ -n ${ZSH_VERSION} ]]; then
    # shellcheck disable=SC1091
    . "${XDG_CONFIG_HOME:-${HOME}/.config}/zsh/interactive.zsh"
elif [[ -n ${BASH_VERSION} ]]; then
    # shellcheck source=dot_config/bash/interactive.bash
    . "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/interactive.bash"
fi

# module system (Lmod) #########################################################
# Priority: host-provided module (HPC sites) > envoy's conda-bootstrapped Lmod
# (__LMOD_INIT) > brew-provided Lmod (HOMEBREW_PREFIX). Lmod reads both Lua and
# TCL modulefiles, so it sits cleanly over an Lmod or a TCL-only host.
if ! command -v module > /dev/null 2>&1; then
    if [[ -n ${__LMOD_INIT} && -f ${__LMOD_INIT}/${_shell} ]]; then
        # shellcheck disable=SC1090
        . "${__LMOD_INIT}/${_shell}"
    elif [[ -n ${HOMEBREW_PREFIX} && -f ${HOMEBREW_PREFIX}/opt/lmod/init/${_shell} ]]; then
        # shellcheck disable=SC1090
        . "${HOMEBREW_PREFIX}/opt/lmod/init/${_shell}"
    fi
fi
if command -v module > /dev/null 2>&1; then
    # personal modulefiles take precedence over any host-provided ones
    module use "${XDG_CONFIG_HOME:-${HOME}/.config}/modulefiles"
    # each modulefile self-guards on directory existence, so loading one for an
    # absent tool (or wrong OS) is a harmless no-op. `module purge` ≈ the old mu;
    # `module purge && module load core` ≈ ml_clean.
    if [[ -n ${__CLEAN} ]]; then
        module load core
    else
        # Load toolchains first, then `core` LAST so the personal local/opt
        # prefixes stay frontmost on PATH (Lmod prepends, so last-loaded wins) —
        # matching the old `ml`, which ran ml_clean last.
        module load brew conda pixi cargo go ghcup lms agy cuda jetbrains mactex
        # host-specific site modules (COSMA): load the site module and bashrc,
        # as the old ml_host did (before core, so local/opt still win).
        if [[ -n ${COSMA_HOST} ]]; then
            module load cosma 2> /dev/null || true
            # shellcheck disable=SC1091
            [[ -f /etc/bashrc ]] && . /etc/bashrc
        fi
        module load core
    fi
fi

# interactive niceties that the old ml_clean carried (always wanted, even clean)
[[ -f "${XDG_DATA_HOME}/sman/sman.rc" ]] && {
    # shellcheck disable=SC1091
    . "${XDG_DATA_HOME}/sman/sman.rc"
}
if command -v lsd > /dev/null 2>&1; then
    alias ls=lsd
    alias tree="lsd --tree"
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
