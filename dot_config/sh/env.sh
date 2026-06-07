#!/usr/bin/env bash
# Shared environment for bash + zsh (the "env" concern).
# Sourced by ~/.zshenv (every zsh) and ~/.bashrc (bash). Keep this POSIX/bash/zsh
# agnostic — no interactive-only or shell-specific syntax.

# * These variables can be customized per __HOST
# SCRATCH <- dedicated filesystem for scratch, often not backed up and purged periodically
# __CMN <- dedicated filesystem for softwares, potentially read-only on compute nodes
# __APPDIR <- could be just __CMN, or a subdir of __CMN if shared with other users
# * important prefixes (set by envoy/env.sh if envoy is installed)
# __LOCAL_ROOT <- arch-indep software prefix
# __OPT_ROOT <- arch-dep software prefix
# MAMBA_ROOT_PREFIX
# PIXI_HOME
# * personal exports
# CARGO_PREFIX
# GOPATH

# __OSTYPE, __ARCH detection ###########################################

# set __OSTYPE as normalized OSTYPE
# shellcheck disable=SC2312
read -r __OSTYPE __ARCH <<< "$(uname -sm)"
export __OSTYPE __ARCH

# __NCPU detection #####################################################
# depends on __OSTYPE

# c.f. https://stackoverflow.com/a/23378780/5769446
case "${__OSTYPE}" in
    Linux)
        # shellcheck disable=SC2312
        __NCPU="$(lscpu -p | grep -E -v '^#' | sort -u -t, -k 2,4 | wc -l)"
        ;;
    Darwin)
        # shellcheck disable=SC2312
        __NCPU="$(sysctl -n hw.physicalcpu_max)"
        ;;
    FreeBSD)
        # shellcheck disable=SC2312
        __NCPU="$(sysctl -n hw.ncpu)"
        ;;
    *)
        # shellcheck disable=SC2312
        __NCPU="$(getconf _NPROCESSORS_ONLN 2> /dev/null || getconf NPROCESSORS_ONLN 2> /dev/null || echo 1)"
        ;;
esac
export __NCPU

# __HOST detection #####################################################
# depends on __OSTYPE, __ARCH

# resolving order: system-defined, default to ~/.scratch, then host-specific definition below
SCRATCH="${SCRATCH:-${HOME}/.scratch}"

# set HOSTNAME by hostname if undefined
if [[ -z ${HOSTNAME} ]]; then
    # be careful that different implementation of hostname has different options
    HOSTNAME="$(hostname -f 2> /dev/null || hostname)"
    export HOSTNAME
fi
# host-specific
# define *_HOST for different computing sites
case "${HOSTNAME}" in
    *.pri.cosma.local)
        # running on a compute node
        if [[ -n ${SLURM_JOB_PARTITION} ]]; then
            COSMA_HOST="${SLURM_JOB_PARTITION}"
        # running on a login node
        else
            case "${HOSTNAME}" in
                login5?.pri.cosma.local)
                    COSMA_HOST=cosma5
                    ;;
                login7?.pri.cosma.local)
                    COSMA_HOST=cosma7
                    ;;
                login8?.pri.cosma.local)
                    COSMA_HOST=cosma8
                    ;;
                # unknown
                *)
                    COSMA_HOST="${HOSTNAME}"
                    ;;
            esac
        fi
        export COSMA_HOST
        __HOST="${COSMA_HOST}"

        export __CMN="/cosma/apps/durham/${USER}"
        export __APPDIR="${__CMN}"

        # cosma8
        if [[ -d /snap8 ]]; then
            SCRATCH="/snap8/scratch/do009/${USER}"
        # cosma5, cosma7
        else
            SCRATCH="/cosma5/data/durham/${USER}"
        fi
        ;;
    *.cluster.local)
        export ISCA_HOST="${HOSTNAME%%.*}"
        __HOST="${ISCA_HOST}"
        ;;
    gordita.physics.berkeley.edu)
        export BOLO_HOST=gordita
        __HOST="${BOLO_HOST}"
        SCRATCH="/scratch2/${USER}"
        ;;
    bolo.berkeley.edu)
        export \
            BOLO_HOST=bolo \
            HOME="/home/${USER}"
        __HOST="${BOLO_HOST}"
        SCRATCH="/tank/scratch/${USER}"
        ;;
    *)
        # these should be systems I have sudo access to
        __HOST="${HOSTNAME}"
        ;;
esac
export \
    __HOST \
    SCRATCH

# XDG setup ############################################################
# depends on __HOST detection

# see https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html
# https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
# https://numba.pydata.org/numba-doc/dev/reference/envvars.html?highlight=numba_threading_layer

# For systems that has dedicated SCRATCH filesystem,
# we put cache there, as they are data-like, such as package cache
if [[ ${SCRATCH} != "${HOME}/.scratch" ]]; then
    export XDG_CACHE_HOME="${SCRATCH}/.cache"
# systems without a dedicated SCRATCH filesystem
else
    export XDG_CACHE_HOME="${HOME}/.cache"
fi

# because not all softwares respect XDG_CONFIG_HOME
# and I want to capture all of them in this repo
# it is best to use the default location
export XDG_CONFIG_HOME="${HOME}/.config"
# derive data/state from __APPDIR (same as the defaults if __APPDIR is not set)
if [[ -n ${__APPDIR} ]]; then
    export XDG_DATA_HOME="${__APPDIR}/local/share"
    export XDG_STATE_HOME="${__APPDIR}/local/state"
else
    export XDG_DATA_HOME="${HOME}/.local/share"
    export XDG_STATE_HOME="${HOME}/.local/state"
fi

# envoy's env.sh sets __LOCAL_ROOT, __OPT_ROOT, MAMBA_ROOT_PREFIX, PIXI_HOME
# using __APPDIR if already set above; XDG vars already set are respected
# shellcheck disable=SC1091
[[ -f "${XDG_DATA_HOME}/envoy/env.sh" ]] && . "${XDG_DATA_HOME}/envoy/env.sh"
# fallback defaults when envoy is absent (mirrors envoy/env.sh)
: "${__LOCAL_ROOT:=${__APPDIR:+${__APPDIR}/local}}"
: "${__LOCAL_ROOT:=${HOME}/.local}"
: "${__OPT_ROOT:=${__LOCAL_ROOT}/opt/${__OSTYPE}-${__ARCH}}"

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
# depends on __OSTYPE, __ARCH

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
# depends on XDG setup

# shell
export ZDOTDIR="${HOME}"
# misc
# LS_COLORS copied from https://github.com/perplexa/dotfiles/blob/master/.gruvbox.dircolors
# and run dircolors ~/.gruvbox.dircolors
export \
    CARGO_PREFIX="${__OPT_ROOT}/cargo" \
    EDITOR=nano \
    GOBIN="${__OPT_ROOT}/go/bin" \
    GOPATH="${__OPT_ROOT}/go" \
    LANG=en_US.UTF-8 \
    MAKEFLAGS="-j${__NCPU}" \
    SMAN_APPEND_HISTORY=false \
    SMAN_EXEC_CONFIRM=false \
    SMAN_SNIPPET_DIR="${XDG_DATA_HOME}/sman/snippets"
