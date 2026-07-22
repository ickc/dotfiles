#!/usr/bin/env bash
# Shared interactive setup for bash + zsh.
# Sourced by ~/.zshrc and (when interactive) ~/.bashrc. Loads the PATH/module
# system, the per-shell interactive setup, the prompt/navigation tool hooks, and
# the ssh-agent (which only ensures an agent is reachable; ~/.ssh/config's
# AddKeysToAgent loads the key on first use).

# set title of prompt. c.f. https://tldp.org/HOWTO/Xterm-Title-3.html
printf "\033]0;%s\007" "${HOSTNAME%%.*}"

# greeting #####################################################################
command -v fastfetch > /dev/null 2>&1 && fastfetch

# functions ####################################################################

# Append a prefix's bin/man/info dirs to PATH/MANPATH/INFOPATH. Appended (not
# prepended) on purpose: system binaries keep precedence over the personal
# prefixes — a deliberate, security-minded reversal of the old module behaviour.
path_append_all() {
    if [[ -d "$1/bin" ]]; then
        case ":${PATH}:" in
            *":$1/bin:"*) : ;;
            *) export PATH="${PATH:+${PATH}:}${1}/bin" ;;
        esac
    fi
    if [[ -d "$1/share/man" ]]; then
        case ":${MANPATH}:" in
            *":$1/share/man:"*) : ;;
            *) export MANPATH="${MANPATH:+${MANPATH}:}${1}/share/man" ;;
        esac
    fi
    if [[ -d "$1/share/info" ]]; then
        case ":${INFOPATH}:" in
            *":$1/share/info:"*) : ;;
            *) export INFOPATH="${INFOPATH:+${INFOPATH}:}${1}/share/info" ;;
        esac
    fi
}

# CONDA_ENVS_PATH
conda_envs_path_prepend() {
    if [[ -d $1 ]]; then
        case ":${CONDA_ENVS_PATH}:" in
            *":$1:"*) : ;;
            *) export CONDA_ENVS_PATH="${1}${CONDA_ENVS_PATH:+:${CONDA_ENVS_PATH}}" ;;
        esac
    fi
}

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

# micromamba/mamba/conda are on PATH (via the personal opt prefix), but the shell
# function needed for `activate` is not wired by default. Call this to source the
# hook on demand when you actually need to activate an environment. Prefers
# micromamba, falling back to mamba then conda.
conda-shell() {
    if command -v micromamba > /dev/null 2>&1; then
        # shellcheck disable=SC1090,SC2312
        . <(micromamba shell hook --shell "${__SHELL}")
    elif command -v mamba > /dev/null 2>&1; then
        # shellcheck disable=SC1090,SC2312
        . <(mamba shell hook --shell "${__SHELL}")
    elif command -v conda > /dev/null 2>&1; then
        # shellcheck disable=SC1090,SC2312
        . <(conda "shell.${__SHELL}" hook)
    fi
}

# ssh: make sure SSH_AUTH_SOCK points at a live agent. Keys are *not* loaded
# here — ssh adds them on first use via `AddKeysToAgent yes` (~/.ssh/config) —
# so this never prompts for a passphrase and is safe to run at every startup.
#
# The socket sits at a path every shell computes the same way, so there is no
# state file to source, race on, or clobber. Two shells starting at once are
# harmless: one binds the socket, the other finds it already listening.
#
# A UNIX socket is reachable only from the host that bound it (a socket file on
# a shared home does not work across nodes), so an agent is per host by nature:
# one loaded on an HPC login node is not visible from a compute node. Use a
# scoped deploy key or token for jobs that need to reach a private repo.

# True if $1 is a directory we own with mode 0700, creating it if needed.
# Whatever answers on SSH_AUTH_SOCK is trusted implicitly — ssh hands it the
# decrypted key — so a predictable name straight in a world-writable /tmp is
# not safe: any local user can pre-bind it first and collect the key, and the
# sticky bit would stop us removing theirs. Refuse anything we do not own.
_ssh_agent_dir_ok() {
    local d=$1 uid info
    uid=${UID:-$(id -u)}
    mkdir -p "${d}" 2> /dev/null
    # Checked before the chmod so we never follow a symlink into someone else's
    # directory.
    [[ -d ${d} && ! -L ${d} ]] || return 1
    chmod 700 "${d}" 2> /dev/null
    info=$(stat -c '%u %a' "${d}" 2> /dev/null) || info=$(stat -f '%u %Lp' "${d}" 2> /dev/null) || return 1
    [[ ${info} == "${uid} 700" ]]
}

auto_ssh_agent() {
    local dir sock candidate uid rc

    # An inherited agent that answers wins — forwarded (ForwardAgent), macOS
    # launchd, systemd. rc 0 (holds keys) and 1 (empty) both mean reachable;
    # only 2 means nothing is there. A missing ssh-add (127) also exits here.
    ssh-add -l > /dev/null 2>&1
    rc=$?
    [[ ${rc} -ne 2 ]] && return 0

    # This host's own agent, in the first private directory that works.
    # XDG_RUNTIME_DIR is already per-user and 0700, but logind removes it at
    # last logout (so the agent dies with the session unless `loginctl
    # enable-linger`); the TMPDIR and /tmp fallbacks persist. /tmp is also the
    # retry when a long TMPDIR would overflow sun_path (~108 bytes).
    uid=${UID:-$(id -u)}
    sock=
    for dir in "${XDG_RUNTIME_DIR}" "${TMPDIR:-/tmp}/ssh-agent-${uid}" "/tmp/ssh-agent-${uid}"; do
        [[ -n ${dir} ]] || continue
        candidate="${dir%/}/ssh-agent.sock"
        [[ ${#candidate} -gt 100 ]] && continue
        if _ssh_agent_dir_ok "${dir%/}"; then
            sock=${candidate}
            break
        fi
    done
    # Nowhere private to put it: leave ssh to prompt per connection rather than
    # trust a socket anyone could have planted.
    [[ -n ${sock} ]] || return 0
    export SSH_AUTH_SOCK="${sock}"
    ssh-add -l > /dev/null 2>&1
    rc=$?
    [[ ${rc} -ne 2 ]] && return 0

    # Nothing listening. ssh-agent removes its own socket on exit, so anything
    # still here is stale and would only make the bind fail; the directory is
    # ours alone, so this cannot clobber another user's socket. SSH_AGENT_PID is
    # deliberately left unset: nothing needs it except `ssh-agent -k`, which
    # would kill an agent every other shell on this host is sharing.
    rm -f -- "${sock}"
    ssh-agent -s -a "${sock}" > /dev/null 2>&1
}

# PATH MANPATH INFOPATH CONDA_ENVS_PATH ########################################

[[ -n ${__LOCAL_ROOT} ]] && path_append_all "${__LOCAL_ROOT}"
if [[ -n ${__OPT_ROOT} ]]; then
    path_append_all "${__OPT_ROOT}"
    path_append_all "${__OPT_ROOT}/system"
fi
[[ -n ${PIXI_HOME} ]] && path_append_all "${PIXI_HOME}"
[[ -n ${CARGO_HOME} ]] && path_append_all "${CARGO_HOME}"
export PATH MANPATH INFOPATH

conda_envs_path_prepend "${XDG_DATA_HOME}/conda/envs"
conda_envs_path_prepend "${__OPT_ROOT}"
export CONDA_ENVS_PATH

# per-shell interactive setup (early) ##########################################

# shell identity drives the unified tool-hook arguments below
if [[ -n ${ZSH_VERSION} ]]; then
    __SHELL=zsh
elif [[ -n ${BASH_VERSION} ]]; then
    __SHELL=bash
else
    echo "rc.sh: unsupported shell: ${0}" >&2
    return 1
fi
export __SHELL

# loaded before the prompt/navigation hooks below so zsh's compinit is ready
# shellcheck disable=SC1090
. "${XDG_CONFIG_HOME:-${HOME}/.config}/${__SHELL}/interactive.${__SHELL}"

# module system (Lmod) #########################################################
# Priority: host-provided module (HPC sites, homebrew, etc.) first, and fallback to envoy's conda-bootstrapped Lmod (__LMOD_INIT).
if ! command -v module > /dev/null 2>&1; then
    [[ -n ${HOMEBREW_PREFIX} && -f ${HOMEBREW_PREFIX}/opt/lmod/init/${__SHELL} ]] && __LMOD_INIT="${HOMEBREW_PREFIX}/opt/lmod/init"
    # shellcheck disable=SC1090
    [[ -n ${__LMOD_INIT} && -f ${__LMOD_INIT}/${__SHELL} ]] && . "${__LMOD_INIT}/${__SHELL}"
fi

if command -v module > /dev/null 2>&1; then
    # personal modulefiles take precedence over any host-provided ones
    module use "${XDG_CONFIG_HOME:-${HOME}/.config}/modulefiles"
    # each modulefile self-guards on directory existence, so loading one for an
    # absent tool (or wrong OS) is a harmless no-op.
    module load \
        brew \
        cuda \
        lms \
        mactex
fi

if command -v lsd > /dev/null 2>&1; then
    alias ls=lsd
    alias tree="lsd --tree"
fi

# limits / umask  ##############################################################
ulimit -c 0                      # No core dumps
ulimit -s unlimited 2> /dev/null # Limited stack size can cause segfaults with ifort
# even if this doesn't mask the world readability
# the parent directories should protect it already
umask 022

# git external diff ############################################################
# PATH is only fully built after ml above
command -v difft > /dev/null 2>&1 && export GIT_EXTERNAL_DIFF=difft

# prompt / navigation tool hooks (unified across bash & zsh) ####################
[[ -f "${XDG_DATA_HOME}/sman/sman.rc" ]] && {
    # shellcheck disable=SC1091
    . "${XDG_DATA_HOME}/sman/sman.rc"
}
# shellcheck disable=SC1090,SC2312
command -v fzf > /dev/null 2>&1 && . <(fzf "--${__SHELL}")
# shellcheck disable=SC1090,SC2312
command -v starship > /dev/null 2>&1 && . <(starship init "${__SHELL}")
# shellcheck disable=SC2312
command -v direnv > /dev/null 2>&1 && eval "$(direnv hook "${__SHELL}")"
# shellcheck disable=SC2312
command -v navi > /dev/null 2>&1 && eval "$(navi widget "${__SHELL}")"

# per-shell interactive setup (late) ###########################################
# line-editing plugins; loaded after the hooks so syntax-highlighting is last
if [[ -n ${ZSH_VERSION} ]]; then
    # shellcheck disable=SC1091
    . "${XDG_CONFIG_HOME:-${HOME}/.config}/zsh/plugins.zsh"
fi

# ssh-agent (single unified call for both shells) ##############################
# Idempotent and silent; keys load on demand via AddKeysToAgent, not here.
command -v ssh-agent > /dev/null 2>&1 && auto_ssh_agent
