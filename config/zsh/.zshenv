#!/usr/bin/env bash

# These variables must exist on all systems
# SCRATCH, __CONDA_PREFIX
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

# also set env var here if possible
# priority: NERSC_HOST > BLACKETT_HOST > SO_HOST > PRINCETON_HOST > BOLO_HOST

if [[ -n ${NERSC_HOST} ]]; then
    __HOST="${NERSC_HOST}"
    # TODO: update by running
    # module load python; . activate && echo ${CONDA_PREFIX}
    # or scan everything:
    #  find /global/common/software -type d -name bin -exec sh -c 'for dir; do [ -x "${dir}/mamba" ] && [ -x "${dir}/conda" ] && [ -x "${dir}/activate" ] && echo "${dir}"; done' sh {} + 2>/dev/null
    # e.g.
    # /global/common/software/lsst/gitlab/td_env-prod/stable/conda
    # /global/common/software/lsst/gitlab/td_env-dev/dev/conda
    # /global/common/software/lsst/gitlab/desc-stack-weekly/weekly-latest/conda
    # /global/common/software/lsst/gitlab/desc-python-prod/prod
    # /global/common/software/lsst/gitlab/desc-forecasts-int/prod/py
    # /global/common/software/lsst/gitlab/desc-python-dev/dev
    # /global/common/software/sobs/perlmutter/conda_base
    __CONDA_PREFIX=/global/common/software/sobs/perlmutter/conda_base
    # CFS=/global/cfs/cdirs
    export CMN=/global/common/software
else
    # set HOSTNAME by hostname if undefined
    if [[ -z ${HOSTNAME} ]]; then
        # be careful that different implementation of hostname has different options
        HOSTNAME="$(hostname -f 2> /dev/null || hostname)"
        export HOSTNAME
    fi
    case "${HOSTNAME}" in
        vm77.tier2.hep.manchester.ac.uk)
            BLACKETT_HOST="${HOSTNAME%%.*}"
            export BLACKETT_HOST
            __HOST="${BLACKETT_HOST}"
            ;;
        *.tier2.hep.manchester.ac.uk)
            BLACKETT_HOST="${HOSTNAME%%.*}"
            export BLACKETT_HOST BLACKETT_CVMFS_ENV=1
            __HOST="${BLACKETT_HOST}"
            ;;
        cvmfs-uploader*.gridpp.rl.ac.uk)
            BLACKETT_HOST="${HOSTNAME%%.*}"
            export BLACKETT_HOST BLACKETT_CVMFS_ENV=1
            __HOST="${BLACKETT_HOST}"
            ;;
        *.simonsobs.org)
            SO_HOST="${HOSTNAME%%.*}"
            export SO_HOST
            __HOST="${SO_HOST}"
            ;;
        *.princeton.edu)
            # seems like nobel is load balanced and it can lands on different __HOST here...
            PRINCETON_HOST="${HOSTNAME%%.*}"
            export PRINCETON_HOST
            __HOST="${PRINCETON_HOST}"
            ;;
        simons1)
            PRINCETON_HOST="${HOSTNAME}"
            export PRINCETON_HOST
            __HOST="${PRINCETON_HOST}"
            SCRATCH="/mnt/so1/users/${USER}"
            __CONDA_PREFIX=${SCRATCH}/.mambaforge
            export CFS=/mnt/physicsso
            export WWW_DIR="/mnt/so1/public_html/${USER}"
            ;;
        gordita.physics.berkeley.edu)
            BOLO_HOST=gordita
            export BOLO_HOST
            __HOST="${BOLO_HOST}"
            SCRATCH="/scratch2/${USER}"
            __CONDA_PREFIX="${HOME}/mambaforge"
            ;;
        bolo.berkeley.edu)
            BOLO_HOST=bolo
            export BOLO_HOST
            __HOST="${BOLO_HOST}"
            SCRATCH="/tank/scratch/${USER}"
            export HOME="/home/${USER}"
            ;;
        *)
            __HOST="${HOSTNAME}"
            if [[ ${__OSTYPE} == darwin ]]; then
                SCRATCH="${SCRATCH:-${HOME}/scratch}"

                conda_prefix="${HOME}/.mambaforge"
                command -v "${conda_prefix}/bin/conda" > /dev/null 2>&1 && __CONDA_PREFIX="${conda_prefix}"
                unset conda_prefix
            fi
            ;;
    esac
fi
export __HOST

# XDG setup ############################################################

# __HOST-specific env var may depends on these,
# but XDG_CACHE_HOME is set later as that depends on __HOST

# see https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html
# https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
# https://numba.pydata.org/numba-doc/dev/reference/envvars.html?highlight=numba_threading_layer

export \
    XDG_CONFIG_HOME="${HOME}/.config" \
    XDG_DATA_HOME="${HOME}/.local/share" \
    XDG_STATE_HOME="${HOME}/.local/state"

export \
    CONDA_ENVS_PATH="${XDG_DATA_HOME}/conda/envs" \
    IPYTHONDIR="${XDG_CONFIG_HOME}"/jupyter \
    JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}"/jupyter \
    MATHEMATICA_USERBASE="${XDG_CONFIG_HOME}"/mathematica \
    PARALLEL_HOME="${XDG_CONFIG_HOME}"/parallel \
    WGETRC="${XDG_CONFIG_HOME}/wgetrc"

# set remaining __HOST-specific env var ################################

if [[ -n ${NERSC_HOST} ]]; then
    export CONDA_ENVS_PATH="${CONDA_ENVS_PATH}:${CMN}/polar/opt/conda/envs"
elif [[ -n ${BLACKETT_HOST} ]]; then
    export \
        CVMFS_ROOT=/cvmfs/northgrid.gridpp.ac.uk/simonsobservatory \
        XROOTD_ROOT=root://bohr3226.tier2.hep.manchester.ac.uk:1094//dpm/tier2.hep.manchester.ac.uk/home/souk.ac.uk
    export CONDA_ENVS_PATH="${CONDA_ENVS_PATH}:${CVMFS_ROOT}/opt:${CVMFS_ROOT}/pmpm:${CVMFS_ROOT}/conda"
    if [[ -n ${BLACKETT_CVMFS_ENV} ]]; then
        __CONDA_PREFIX="${CVMFS_ROOT}/opt/miniforge3"
    elif [[ ${BLACKETT_HOST} == vm77 ]]; then
        __CONDA_PREFIX=/opt/miniforge3
        export CONDA_ENVS_PATH="/opt:${CONDA_ENVS_PATH}"
        export HOMEBREW_CURL_PATH=/home/linuxbrew/.linuxbrew/bin/curl
    fi
    if [[ -n ${_CONDOR_SCRATCH_DIR} ]]; then
        SCRATCH="${_CONDOR_SCRATCH_DIR}"
    fi
elif [[ -n ${SO_HOST} ]]; then
    SCRATCH="/so/scratch/${USER}"
    __CONDA_PREFIX="${HOME}/.mambaforge"
elif [[ -n ${PRINCETON_HOST} ]]; then
    # simons1 is not PRINCETON_HOST!
    SCRATCH="/n/lowrie-scratch/${USER}"
    __CONDA_PREFIX=${SCRATCH}/.mambaforge
    export CFS=/n/lowrie-scratch
fi
[[ -n ${SCRATCH} ]] && export SCRATCH
[[ -n ${__CONDA_PREFIX} ]] && export __CONDA_PREFIX

# set XDG_CACHE_HOME ###################################################

# as SCRATCH is subjected to be purged, only put cache here
if [[ -n ${NERSC_HOST} && -n ${SCRATCH} ]]; then
    export XDG_CACHE_HOME="${SCRATCH}/.cache"
else
    export XDG_CACHE_HOME="${HOME}/.cache"
fi
export CONDA_PKGS_DIRS="${XDG_CACHE_HOME}/conda/pkgs" \
    CONDA_BLD_PATH="${XDG_CACHE_HOME}/conda-bld/" \
    NUMBA_CACHE_DIR="${XDG_CACHE_HOME}/numba"

# zsh setup ############################################################

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
[[ -n ${ZSH_VERSION} ]] && export HISTFILE="${XDG_STATE_HOME}/zsh/history"

# HOMEBREW_PREFIX detection ############################################

# set HOMEBREW_PREFIX if undefined and discovered
if [[ -z ${NERSC_HOST} && -z ${HOMEBREW_PREFIX} ]]; then
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
export HOMEBREW_PREFIX

# export variables #####################################################

if [[ -n ${HOMEBREW_PREFIX} ]]; then
    export HOMEBREW_NO_ANALYTICS=1 \
        HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar" \
        HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
fi
if [[ -n ${BLACKETT_HOST} && -d /opt/rh/rust-toolset-7/root/usr ]]; then
    export CARGO_PREFIX=/opt/rh/rust-toolset-7/root/usr
elif [[ -d "${HOME}/.cargo" ]]; then
    export CARGO_PREFIX="${HOME}/.cargo"
fi
export \
    EDITOR=nano \
    GOBIN="${HOME}/go/bin" \
    GOPATH="${HOME}/go" \
    LANG=en_US.UTF-8 \
    MAKEFLAGS="-j${__NCPU}" \
    SMAN_APPEND_HISTORY=false \
    SMAN_EXEC_CONFIRM=false \
    SMAN_SNIPPET_DIR="${HOME}/git/source/sman-snippets" \
    ZIM_HOME=~/.zim

# alias ################################################################

# set alias (putting this in "interactive" does not help)
# this is needed to make sure mosh can see mosh-server not from PATH
# this is to avoid can't find tmux after `mu`
if [[ ${__OSTYPE} == darwin ]]; then
    __PREFIX=/opt/local
elif [[ -n ${NERSC_HOST} || -n ${PRINCETON_HOST} ]]; then
    __PREFIX="${HOME}/.local"
elif [[ -n ${BLACKETT_HOST} ]]; then
    if [[ -n ${BLACKETT_CVMFS_ENV} ]]; then
        __PREFIX="${CVMFS_ROOT}/usr"
    else
        __PREFIX=/opt/local
    fi
else
    # shellcheck disable=SC2249
    case "${__HOST}" in
        gordita)
            __PREFIX="${HOME}/mambaforge/envs/system39-conda-forge"
            ;;
    esac
fi
if [[ -n ${__PREFIX} ]]; then
    for i in mosh-server tmux exa eza lsd; do
        j="${__PREFIX}/bin/${i}"
        # shellcheck disable=SC2139
        [[ -f ${j} ]] && alias "${i}"="${j}"
    done
fi

command -v squeue > /dev/null 2>&1 &&
    alias sqs='squeue -o "%16i %2t %9u %12j  %5D %.10l %.10M  %20V %15q %20S %14f %15R" --me'

# CONDARC ##############################################################

# https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html#searching-for-condarc
export CONDARC="${HOME}/git/source/dotfiles/config/conda/.condarc"

# basher ###############################################################

BASHER_ROOT="${HOME}/.basher"
if [[ -n ${BASHER_ROOT} ]]; then
    export BASHER_ROOT \
        BASHER_PREFIX="${BASHER_ROOT}/cellar"
    export BASHER_PACKAGES_PATH="${BASHER_PREFIX}/packages"
    if [[ -n ${ZSH_VERSION} ]]; then
        export BASHER_SHELL=zsh
    elif [[ -n ${BASH_VERSION} ]]; then
        export BASHER_SHELL=bash
    fi
fi

# functions ############################################################

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
