#!/usr/bin/env bash
# Shared environment for bash + zsh (the "env" concern).
# Sourced by ~/.zshenv (every zsh) and ~/.bashrc (bash). Keep this POSIX/bash/zsh
# agnostic — no interactive-only or shell-specific syntax.

# envoy sets the software prefixes (__OPT_ROOT, __LOCAL_ROOT, MAMBA_ROOT_PREFIX,
# PIXI_HOME, __LMOD_INIT) and the XDG base dirs. Prefer the live install; fall
# back to the vendored copy (refresh with `make vendor-envoy`) so these dotfiles
# work even when envoy is not installed.
# shellcheck disable=SC1090,SC1091
if [[ -f ~/.local/share/envoy/env.sh ]]; then
    . ~/.local/share/envoy/env.sh
elif [[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/envoy/env.sh" ]]; then
    . "${XDG_CONFIG_HOME:-${HOME}/.config}/envoy/env.sh"
fi

MAKEFLAGS="-j$(getconf _NPROCESSORS_ONLN 2> /dev/null || echo 1)"
export MAKEFLAGS

# set HOSTNAME by hostname if undefined
if [[ -z ${HOSTNAME} ]]; then
    # be careful that different implementation of hostname has different options
    HOSTNAME="$(hostname -f 2> /dev/null || hostname)"
    export HOSTNAME
fi

# XDG setup ############################################################

# override XDG_CACHE_HOME on system with SCRATCH
[[ -n ${SCRATCH} ]] && export XDG_CACHE_HOME="${SCRATCH}/.cache"

export \
    CONDA_BLD_PATH="${XDG_CACHE_HOME}/conda-bld/" \
    CONDA_PKGS_DIRS="${XDG_CACHE_HOME}/conda/pkgs" \
    INPUTRC="${XDG_CONFIG_HOME}"/readline/inputrc \
    IPYTHONDIR="${XDG_CONFIG_HOME}"/jupyter \
    JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}"/jupyter \
    MATHEMATICA_USERBASE="${XDG_CONFIG_HOME}"/mathematica \
    NUMBA_CACHE_DIR="${XDG_CACHE_HOME}/numba" \
    PARALLEL_HOME="${XDG_CONFIG_HOME}"/parallel \
    PIXI_CACHE_DIR="${XDG_CACHE_HOME}/${__OSTYPE}-${__ARCH}/pixi" \
    WGETRC="${XDG_CONFIG_HOME}/wgetrc"

# HOMEBREW_PREFIX detection ############################################
# depends on __OSTYPE, __ARCH (provided by envoy above)

# set HOMEBREW_PREFIX if undefined and discovered
if [[ -z ${HOMEBREW_PREFIX} ]]; then
    case "${__OSTYPE}" in
        Linux) HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew ;;
        Darwin)
            case "${__ARCH}" in
                x86_64) HOMEBREW_PREFIX=/usr/local ;;
                arm64) HOMEBREW_PREFIX=/opt/homebrew ;;
                *) ;;
            esac
            ;;
        *) ;;
    esac
fi
if command -v "${HOMEBREW_PREFIX}/bin/brew" > /dev/null 2>&1; then
    export \
        HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar" \
        HOMEBREW_NO_ANALYTICS=1 \
        HOMEBREW_PREFIX \
        HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
else
    unset HOMEBREW_PREFIX
fi

# export variables #####################################################

export \
    EDITOR=nano \
    LANG=en_US.UTF-8 \
    SMAN_APPEND_HISTORY=false \
    SMAN_EXEC_CONFIRM=false \
    SMAN_SNIPPET_DIR="${XDG_DATA_HOME}/sman/snippets"
