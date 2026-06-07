#!/usr/bin/env bash
# Shared PATH / "module" system for bash + zsh.
# Sourced by ~/.config/sh/rc.sh on each interactive shell. Defines the path_*
# helpers and the ml_* / ml / mu module-load functions, and resets PATH to a
# pristine baseline (captured once in __PATH) before ml rebuilds it.

# The XDG_*/__OPT_ROOT/__LOCAL_ROOT/__OSTYPE vars used below are exported by
# env.sh, which is always sourced first; tell shellcheck they are external.
# shellcheck disable=SC2154

# helpers ######################################################################

# * any path-like variables should be remembered and reset using this mechanism,
#   keeping the original PATH for cleaning environments
export __PATH="${__PATH:-${PATH}}" \
    __MANPATH="${__MANPATH:-${MANPATH}}" \
    __INFOPATH="${__INFOPATH:-${INFOPATH}}" \
    __PYTHONPATH="${__PYTHONPATH:-${PYTHONPATH}}" \
    __LD_LIBRARY_PATH="${__LD_LIBRARY_PATH:-${LD_LIBRARY_PATH}}"
# reset PATH every time a new interactive shell is started
# before any paths are added to it
[[ -n ${__PATH} ]] && export PATH="${__PATH}"
[[ -n ${__MANPATH} ]] && export MANPATH="${__MANPATH}"
[[ -n ${__INFOPATH} ]] && export INFOPATH="${__INFOPATH}"
[[ -n ${__PYTHONPATH} ]] && export PYTHONPATH="${__PYTHONPATH}"
[[ -n ${__LD_LIBRARY_PATH} ]] && export LD_LIBRARY_PATH="${__LD_LIBRARY_PATH}"

path_prepend() {
    if [[ -d $1 ]]; then
        case ":${PATH}:" in
            *":$1:"*) : ;;
            *) export PATH="${1}${PATH:+:${PATH}}" ;;
        esac
    fi
}

path_append() {
    if [[ -d $1 ]]; then
        case ":${PATH}:" in
            *":$1:"*) : ;;
            *) export PATH="${PATH:+${PATH}:}${1}" ;;
        esac
    fi
}

pythonpath_prepend() {
    if [[ -d $1 ]]; then
        case ":${PYTHONPATH}:" in
            *":$1:"*) : ;;
            *) export PYTHONPATH="${1}${PYTHONPATH:+:${PYTHONPATH}}" ;;
        esac
    fi
}

pythonpath_append() {
    if [[ -d $1 ]]; then
        case ":${PYTHONPATH}:" in
            *":$1:"*) : ;;
            *) export PYTHONPATH="${PYTHONPATH:+${PYTHONPATH}:}${1}" ;;
        esac
    fi
}

ld_library_path_prepend() {
    if [[ -d $1 ]]; then
        case ":${LD_LIBRARY_PATH}:" in
            *":$1:"*) : ;;
            *) export LD_LIBRARY_PATH="${1}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" ;;
        esac
    fi
}

ld_library_path_append() {
    if [[ -d $1 ]]; then
        case ":${LD_LIBRARY_PATH}:" in
            *":$1:"*) : ;;
            *) export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${1}" ;;
        esac
    fi
}

conda_envs_path_prepend() {
    if [[ -d $1 ]]; then
        case ":${CONDA_ENVS_PATH}:" in
            *":$1:"*) : ;;
            *) export CONDA_ENVS_PATH="${1}${CONDA_ENVS_PATH:+:${CONDA_ENVS_PATH}}" ;;
        esac
    fi
}

# variants of the above with $1 as the prefix only
# modifies PATH, MANPATH, INFOPATH
path_prepend_all() {
    if [[ -d "$1/bin" ]]; then
        case ":${PATH}:" in
            *":$1/bin:"*) : ;;
            *) export PATH="${1}/bin${PATH:+:${PATH}}" ;;
        esac
    fi
    if [[ -d "$1/share/man" ]]; then
        case ":${MANPATH}:" in
            *":$1/share/man:"*) : ;;
            *) export MANPATH="${1}/share/man${MANPATH:+:${MANPATH}}" ;;
        esac
    fi
    if [[ -d "$1/share/info" ]]; then
        case ":${INFOPATH}:" in
            *":$1/share/info:"*) : ;;
            *) export INFOPATH="${1}/share/info${INFOPATH:+:${INFOPATH}}" ;;
        esac
    fi
}

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

# this remove ~/.local/bin from PATH
remove_home_local_bin_from_PATH() {
    # shellcheck disable=SC2312
    PATH="$(echo "${PATH}" | tr ":" "\n" | grep -v "${HOME}/.local/bin" | tr "\n" ":")"
    export PATH
}

# "module" functions ###########################################################

# these should come in pairs of ml and mu stands for module-load, module-unload
# mu is not needed if it only manipulate PATH

# ! known limitation: this isn't truly a module unload system
# ! it probably still has side effects

ml_brew() {
    # adapted from `brew shellenv`
    path_prepend "${HOMEBREW_PREFIX}/sbin"
    path_prepend_all "${HOMEBREW_PREFIX}"
    path_prepend_all "${HOMEBREW_PREFIX}/opt/ruby"
}

# conda
ml_conda() {
    export MAMBA_EXE="${MAMBA_ROOT_PREFIX}/condabin/mamba"

    # just put conda and mamba in the PATH
    path_prepend "${MAMBA_ROOT_PREFIX}/condabin"

    # * this source the conda functions but not changing the PATH directly
    # it allows you to put the conda function available without letting it
    # changing your PATH
    local __PATH__="${PATH}"
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
    export PATH="${__PATH__}"

    conda_envs_path_prepend "${XDG_DATA_HOME}/conda/envs"
    conda_envs_path_prepend "${__OPT_ROOT}"
}

mu_conda() {
    # from sourcing above
    unset \
        CONDA_DEFAULT_ENV \
        CONDA_EXE \
        CONDA_PREFIX \
        CONDA_PROMPT_MODIFIER \
        CONDA_PYTHON_EXE \
        CONDA_SHLVL \
        MAMBA_EXE
}

ml_pixi() {
    path_prepend_all "${PIXI_HOME}"
}

ml_devbox() {
    # shellcheck disable=SC1090,SC2312
    . <(devbox global shellenv --init-hook)
}

# sman
ml_s() {
    # shellcheck disable=SC1091
    . "${XDG_DATA_HOME}/sman/sman.rc"
}

ml_lsd() {
    alias ls=lsd
    alias tree="lsd --tree"
}

ml_ls() {
    alias ls="noglob ls"
}

ml_cg() {
    path_append_all "${CARGO_PREFIX}"
}

ml_ghcup() {
    # See `cat ~/.ghcup/env`.
    path_append_all "${HOME}/.cabal"
    path_append_all "${HOME}/.ghcup"
}

ml_jetbrains() {
    path_append "${HOME}/Library/Application Support/JetBrains/Toolbox/scripts"
}

ml_mactex() {
    path_prepend /Library/TeX/Distributions/Programs/texbin
}

ml_lms() {
    path_prepend_all "${HOME}/.lmstudio"
}

ml_agy() {
    path_prepend_all "${HOME}/.antigravity/antigravity"
}

ml_cuda_toolkit() {
    path_prepend_all /usr/local/cuda
    ld_library_path_prepend /usr/local/cuda/lib64
}

# hosts ========================================================================

if [[ -n ${COSMA_HOST} ]]; then
    ml_host() {
        module load cosma
        if [[ -f /etc/bashrc ]]; then
            # shellcheck disable=SC1091
            . /etc/bashrc
        fi
    }
fi

#===============================================================================

ml_clean() {
    path_prepend_all "${__OPT_ROOT}/system"
    path_prepend_all "${__OPT_ROOT}"
    path_prepend_all "${__LOCAL_ROOT}"

    # * load minimal environment for interactive use
    [[ -f "${XDG_DATA_HOME}/sman/sman.rc" ]] && ml_s
    command -v lsd > /dev/null 2>&1 && ml_lsd
}

ml() {
    # * load all installed environments
    # * includes clean, go, ghcup, brew, port, conda, cargo, host
    ml_ghcup
    [[ -n ${HOMEBREW_PREFIX} ]] && ml_brew
    [[ -n ${MAMBA_ROOT_PREFIX} ]] && ml_conda
    [[ -n ${PIXI_HOME} ]] && ml_pixi
    [[ -n ${CARGO_PREFIX} ]] && ml_cg
    [[ -d ${HOME}/.lmstudio ]] && ml_lms
    [[ -d ${HOME}/.antigravity/antigravity ]] && ml_agy
    [[ -d /usr/local/cuda ]] && ml_cuda_toolkit

    command -v ml_host > /dev/null 2>&1 && ml_host

    case "${__OSTYPE}" in
        Darwin)
            [[ -d "${HOME}/Library/Application Support/JetBrains/Toolbox/scripts" ]] && ml_jetbrains
            [[ -d /Library/TeX/Distributions/Programs/texbin ]] && ml_mactex
            ;;
        *) ;;
    esac

    ml_clean
}

mu() {
    if [[ -n ${__PATH} ]]; then
        export PATH="${__PATH}"
    else
        unset PATH
    fi
    if [[ -n ${__MANPATH} ]]; then
        export MANPATH="${__MANPATH}"
    else
        unset MANPATH
    fi
    if [[ -n ${__INFOPATH} ]]; then
        export INFOPATH="${__INFOPATH}"
    else
        unset INFOPATH
    fi
    if [[ -n ${__PYTHONPATH} ]]; then
        export PYTHONPATH="${__PYTHONPATH}"
    else
        unset PYTHONPATH
    fi
    if [[ -n ${__LD_LIBRARY_PATH} ]]; then
        export LD_LIBRARY_PATH="${__LD_LIBRARY_PATH}"
    else
        unset LD_LIBRARY_PATH
    fi

    mu_conda
    ml_ls
}

mkdir_xdg() {
    mkdir -p "${XDG_DATA_HOME}"
    mkdir -p "${XDG_STATE_HOME}"
    mkdir -p "${XDG_CONFIG_HOME}"
    mkdir -p "${XDG_CACHE_HOME}"
    # see https://docs.astropy.org/en/stable/config/index.html#getting-started
    mkdir -p "${XDG_CONFIG_HOME}/astropy"
    mkdir -p "${XDG_CACHE_HOME}/astropy"
}
