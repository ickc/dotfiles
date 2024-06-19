#!/usr/bin/env bash

# These variables should exist on all systems:
# __CONDA_PREFIX
# __PREFERRED_SHELL
# SCRATCH
# for non-compute system, SCRATCH can be undefined
# CONDA_PREFIX is defined by conda, and can be changed by conda as new environments are activated

# shellcheck disable=SC1091
[[ -e "${ZDOTDIR}/.env" ]] && . "${ZDOTDIR}/.env"

# __OSTYPE detection ###################################################

# set __OSTYPE as normalized OSTYPE
# c.f. https://stackoverflow.com/a/18434831
case "${OSTYPE}" in
    linux*) __OSTYPE=linux ;;
    darwin*) __OSTYPE=darwin ;;
    freebsd*) __OSTYPE=freebsd ;;
    *)
        case "$(uname -s)" in
            Linux) __OSTYPE=linux ;;
            Darwin) __OSTYPE=darwin ;;
            FreeBSD) __OSTYPE=freebsd ;;
            *) __OSTYPE=unknown ;;
        esac
        ;;
esac
export __OSTYPE

# __NCPU detection #####################################################
# depends on __OSTYPE

# c.f. https://stackoverflow.com/a/23378780/5769446
case "${__OSTYPE}" in
    linux)
        # shellcheck disable=SC2312
        __NCPU="$(lscpu -p | grep -E -v '^#' | sort -u -t, -k 2,4 | wc -l)"
        ;;
    darwin)
        # shellcheck disable=SC2312
        __NCPU="$(sysctl -n hw.physicalcpu_max)"
        ;;
    freebsd)
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
# depends on __OSTYPE

# default to zsh unless overridden otherwise
__PREFERRED_SHELL=zsh

# priority: NERSC_HOST > BLACKETT_HOST > SO_HOST > PRINCETON_HOST > BOLO_HOST
if [[ -n ${NERSC_HOST} ]]; then
    __PREFERRED_SHELL=bash
    __HOST="${NERSC_HOST}"
    __CONDA_PREFIX=/global/common/software/polar/opt/miniforge3
    # CFS=/global/cfs/cdirs
    export CMN=/global/common/software
else
    # set HOSTNAME by hostname if undefined
    if [[ -z ${HOSTNAME} ]]; then
        # be careful that different implementation of hostname has different options
        HOSTNAME="$(hostname -f 2> /dev/null || hostname)"
        export HOSTNAME
    fi
    # host-specific
    # define *_HOST for different computing sites
    case "${HOSTNAME}" in
        vm77.tier2.hep.manchester.ac.uk)
            export \
                BLACKETT_HOST="${HOSTNAME%%.*}" \
                HOMEBREW_CURL_PATH=/home/linuxbrew/.linuxbrew/bin/curl
            __HOST="${BLACKETT_HOST}"
            __CONDA_PREFIX=/opt/miniforge3
            ;;
        *.tier2.hep.manchester.ac.uk)
            export \
                BLACKETT_CVMFS_ENV=1 \
                BLACKETT_HOST="${HOSTNAME%%.*}"
            __HOST="${BLACKETT_HOST}"
            ;;
        cvmfs-uploader*.gridpp.rl.ac.uk)
            export \
                BLACKETT_CVMFS_ENV=1 \
                BLACKETT_HOST="${HOSTNAME%%.*}"
            __HOST="${BLACKETT_HOST}"
            ;;
        *.simonsobs.org)
            export SO_HOST="${HOSTNAME%%.*}"
            __HOST="${SO_HOST}"
            ;;
        simons1)
            export \
                CFS=/mnt/physicsso \
                PRINCETON_HOST="${HOSTNAME}" \
                WWW_DIR="/mnt/so1/public_html/${USER}"
            __HOST="${PRINCETON_HOST}"
            SCRATCH="/mnt/so1/users/${USER}"
            __CONDA_PREFIX=${SCRATCH}/.mambaforge
            ;;
        gordita.physics.berkeley.edu)
            export BOLO_HOST=gordita
            __HOST="${BOLO_HOST}"
            SCRATCH="/scratch2/${USER}"
            __CONDA_PREFIX="${HOME}/mambaforge"
            ;;
        bolo.berkeley.edu)
            export \
                BOLO_HOST=bolo \
                HOME="/home/${USER}"
            __HOST="${BOLO_HOST}"
            SCRATCH="/tank/scratch/${USER}"
            ;;
        *)
            __HOST="${HOSTNAME}"
            SCRATCH="${SCRATCH:-${HOME}/scratch}"

            for conda_prefix in "${HOME}/.mambaforge" "${HOME}/.miniforge3" /opt/miniforge3; do
                command -v "${conda_prefix}/bin/conda" > /dev/null 2>&1 && __CONDA_PREFIX="${conda_prefix}"
            done
            unset conda_prefix
            ;;
    esac
    # site-specific
    if [[ -n ${BLACKETT_HOST} ]]; then
        export \
            CVMFS_ROOT=/cvmfs/northgrid.gridpp.ac.uk/simonsobservatory \
            XROOTD_ROOT=root://bohr3226.tier2.hep.manchester.ac.uk:1094//dpm/tier2.hep.manchester.ac.uk/home/souk.ac.uk
        if [[ -n ${BLACKETT_CVMFS_ENV} ]]; then
            __CONDA_PREFIX="${CVMFS_ROOT}/opt/miniforge3"
        fi
        if [[ -n ${_CONDOR_SCRATCH_DIR} ]]; then
            SCRATCH="${_CONDOR_SCRATCH_DIR}"
        fi
    elif [[ -n ${SO_HOST} ]]; then
        SCRATCH="/so/scratch/${USER}"
        __CONDA_PREFIX="${HOME}/.mambaforge"
    fi
    [[ -n ${SCRATCH} ]] && export SCRATCH
fi
export __HOST __PREFERRED_SHELL
[[ -n ${__CONDA_PREFIX} ]] && export __CONDA_PREFIX

# XDG setup ############################################################
# depends on __HOST detection

# see https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html
# https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
# https://numba.pydata.org/numba-doc/dev/reference/envvars.html?highlight=numba_threading_layer

export \
    XDG_CONFIG_HOME="${HOME}/.config" \
    XDG_DATA_HOME="${HOME}/.local/share" \
    XDG_STATE_HOME="${HOME}/.local/state"
# as SCRATCH is subjected to be purged, only put cache in SCRATCH in sites
if [[ (-n ${NERSC_HOST} || -n ${BLACKETT_HOST} || -n ${SO_HOST} || -n ${PRINCETON_HOST} || -n ${BOLO_HOST}) && -n ${SCRATCH} ]]; then
    export XDG_CACHE_HOME="${SCRATCH}/.cache"
else
    export XDG_CACHE_HOME="${HOME}/.cache"
fi

export \
    CONDA_BLD_PATH="${XDG_CACHE_HOME}/conda-bld/" \
    CONDA_PKGS_DIRS="${XDG_CACHE_HOME}/conda/pkgs" \
    INPUTRC="${XDG_CONFIG_HOME}"/readline/inputrc \
    IPYTHONDIR="${XDG_CONFIG_HOME}"/jupyter \
    JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}"/jupyter \
    MATHEMATICA_USERBASE="${XDG_CONFIG_HOME}"/mathematica \
    NUMBA_CACHE_DIR="${XDG_CACHE_HOME}/numba" \
    PARALLEL_HOME="${XDG_CONFIG_HOME}"/parallel \
    WGETRC="${XDG_CONFIG_HOME}/wgetrc"

# HOMEBREW_PREFIX detection ############################################
# depends on __HOST detection

# set HOMEBREW_PREFIX if undefined and discovered
if [[ -z ${NERSC_HOST} ]]; then
    if [[ -z ${HOMEBREW_PREFIX} ]]; then
        if [[ ${__OSTYPE} == darwin ]]; then
            for homebrew_prefix in /opt/homebrew "${HOME}/.homebrew" /usr/local; do
                command -v "${homebrew_prefix}/bin/brew" > /dev/null 2>&1 && HOMEBREW_PREFIX="${homebrew_prefix}"
            done
            unset homebrew_prefix
        elif [[ ${__OSTYPE} == linux ]]; then
            for homebrew_prefix in /home/linuxbrew/.linuxbrew "${HOME}/.homebrew"; do
                command -v "${homebrew_prefix}/bin/brew" > /dev/null 2>&1 && HOMEBREW_PREFIX="${homebrew_prefix}"
            done
            unset homebrew_prefix
        fi
    fi
    if [[ -n ${HOMEBREW_PREFIX} ]]; then
        export \
            HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar" \
            HOMEBREW_NO_ANALYTICS=1 \
            HOMEBREW_PREFIX \
            HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
    fi
fi

# export variables #####################################################
# depends on XDG setup

# shell
if [[ -n ${ZSH_VERSION} ]]; then
    export \
        BASHER_SHELL=zsh \
        HISTFILE="${XDG_STATE_HOME}/zsh/history" \
        ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
elif [[ -n ${BASH_VERSION} ]]; then
    export BASHER_SHELL=bash
fi
# basher
export BASHER_ROOT="${HOME}/.basher"
export BASHER_PREFIX="${BASHER_ROOT}/cellar"
export BASHER_PACKAGES_PATH="${BASHER_PREFIX}/packages"
# misc
export \
    CARGO_PREFIX="${HOME}/.cargo" \
    EDITOR=nano \
    GOBIN="${HOME}/go/bin" \
    GOPATH="${HOME}/go" \
    LANG=en_US.UTF-8 \
    MAKEFLAGS="-j${__NCPU}" \
    SMAN_APPEND_HISTORY=false \
    SMAN_EXEC_CONFIRM=false \
    SMAN_SNIPPET_DIR="${HOME}/git/source/sman-snippets" \
    ZIM_HOME="${HOME}/.zim"
