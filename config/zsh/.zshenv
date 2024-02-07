#!/usr/bin/env bash

# These variables must exist on all systems
# SCRATCH, __CONDA_PREFIX
# for non-compute system, SCRATCH can be undefined
# CONDA_PREFIX is defined by conda, and can be changed by conda as new environments are activated

# CONDARC ##############################################################

# https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html#searching-for-condarc
export CONDARC="$HOME/git/source/dotfiles/conda/.condarc"

# __OSTYPE detection ###################################################

# set __OSTYPE as normalized OSTYPE
# c.f. https://stackoverflow.com/a/18434831
case "$OSTYPE" in
    solaris*) __OSTYPE=solaris ;;
    darwin*) __OSTYPE=darwin ;;
    linux*) __OSTYPE=linux ;;
    *bsd*) __OSTYPE=bsd ;;
    msys*) __OSTYPE=msys ;;
    *) __OSTYPE="$OSTYPE" ;;
esac

# __HOST detection #####################################################

# set HOSTNAME by hostname if undefined
if [[ -z $HOSTNAME ]]; then
    # be careful that different implementation of hostname has different options
    HOSTNAME="$(hostname -f)"
    export HOSTNAME
fi

if [[ -n $NERSC_HOST ]]; then
    __HOST="$NERSC_HOST"
else
    case "$HOSTNAME" in
        vm77.tier2.hep.manchester.ac.uk)
            BLACKETT_HOST="${HOSTNAME%%.*}"
            export BLACKETT_HOST
            __HOST="$BLACKETT_HOST"
            ;;
        *.tier2.hep.manchester.ac.uk)
            BLACKETT_HOST="${HOSTNAME%%.*}"
            export BLACKETT_HOST BLACKETT_CVMFS_ENV=1
            __HOST="$BLACKETT_HOST"
            ;;
        cvmfs-uploader*.gridpp.rl.ac.uk)
            BLACKETT_HOST="${HOSTNAME%%.*}"
            export BLACKETT_HOST BLACKETT_CVMFS_ENV=1
            __HOST="$BLACKETT_HOST"
            ;;
        dtn0?.nersc.gov)
            # permutter has NERSC_HOST defined at this stage, but not dtn
            NERSC_HOST=datatran
            export NERSC_HOST
            __HOST=datatran
            ;;
        *.simonsobs.org)
            SO_HOST="${HOSTNAME%%.*}"
            export SO_HOST
            __HOST="$SO_HOST"
            ;;
        *.jb.man.ac.uk)
            JBCA_HOST="${HOSTNAME%%.*}"
            export JBCA_HOST
            __HOST="$JBCA_HOST"
            ;;
        *.princeton.edu)
            # seems like nobel is load balanced and it can lands on different __HOST here...
            PRINCETON_HOST="${HOSTNAME%%.*}"
            export PRINCETON_HOST
            __HOST="$PRINCETON_HOST"
            ;;
        simons1)
            PRINCETON_HOST="$HOSTNAME"
            export PRINCETON_HOST
            __HOST="$PRINCETON_HOST"
            ;;
        # TODO: check `hostname --fqdn` on these hosts
        centaurus | fornax)
            JBCA_HOST="$HOSTNAME"
            export JBCA_HOST
            __HOST="$JBCA_HOST"
            ;;
        gordita.physics.berkeley.edu)
            BOLO_HOST=gordita
            export BOLO_HOST
            __HOST="$BOLO_HOST"
            ;;
        bolo.berkeley.edu)
            BOLO_HOST=bolo
            export BOLO_HOST
            __HOST="$BOLO_HOST"
            ;;
        lpc-mini) __HOST=lpc-mini ;;
        *) __HOST="$HOSTNAME" ;;
    esac
fi

# HOMEBREW_PREFIX detection ############################################

# set HOMEBREW_PREFIX if undefined and discovered
if [[ -z $HOMEBREW_PREFIX ]]; then
    if [[ $__OSTYPE == darwin ]]; then
        for homebrew_prefix in /opt/homebrew "$HOME/.homebrew" /usr/local; do
            command -v "$homebrew_prefix/bin/brew" > /dev/null 2>&1 && HOMEBREW_PREFIX="$homebrew_prefix"
        done
    elif [[ $__OSTYPE == linux ]]; then
        for homebrew_prefix in /home/linuxbrew/.linuxbrew "$HOME/.homebrew"; do
            command -v "$homebrew_prefix/bin/brew" > /dev/null 2>&1 && HOMEBREW_PREFIX="$homebrew_prefix"
        done
    fi
    unset homebrew_prefix
fi

# set __HOST-specific env var ##########################################

case "$__HOST" in
    perlmutter | datatran)
        case "$__HOST" in
            perlmutter)
                SCRATCH="/pscratch/sd/${USER:0:1}/$USER"

                # TODO: update by running
                # module load python...
                # . activate && echo $CONDA_PREFIX
                # __CONDA_PREFIX=/global/common/software/nersc/cori-2022q1/sw/python/3.9-anaconda-2021.11
                ;;
            datatran)
                # TODO: update by running
                # module load python...
                # . activate && echo $CONDA_PREFIX
                # __CONDA_PREFIX=/global/common/datatran2/usg/python/Miniconda3-latest-Linux-x86_64
                ;;
        esac
        __CONDA_PREFIX="/global/u2/${USER:0:1}/$USER/.mambaforge"
        PROJ_ROOT=/global/cfs/cdirs
        COMMON_ROOT=/global/common/software
        # common polar
        export PBCOMMON="$COMMON_ROOT/polar"

        # NERSC's home is a symbolic link, and vscode's git doesn't like that
        # see https://github.com/microsoft/vscode/issues/5970
        # so we resolve to the realpath here
        HOME="$(realpath ~)"
        export HOME
        ;;
    centaurus | fornax)
        # TODO: nowhere else I can call it SCRATCH
        __CONDA_PREFIX="$HOME/.mambaforge"
        ;;
    soukdev1)
        # TODO: move to HDD later
        SCRATCH="/mnt/scratch/$USER"
        __CONDA_PREFIX=/opt/mambaforge
        ;;
    simons1)
        SCRATCH="/mnt/so1/users/$USER"
        __CONDA_PREFIX=$SCRATCH/.mambaforge
        PROJ_ROOT=/mnt/physicsso
        WWW_DIR="/mnt/so1/public_html/$USER"
        export WWW_DIR
        ;;
    sirius7)
        SCRATCH="/nvme/scratch/$USER"
        __CONDA_PREFIX="$SCRATCH/.mambaforge"
        ;;
    gordita)
        SCRATCH="/scratch2/$USER"

        __CONDA_PREFIX="$HOME/mambaforge"
        ;;
    bolo)
        SCRATCH="/tank/scratch/$USER"
        HOME="/home/$USER"
        export HOME
        ;;
    lpc-mini)
        SCRATCH=/scratch

        __CONDA_PREFIX=/opt/mambaforge
        ;;
    *)
        # macOS catalina doesn't allow /scratch anymore
        # on macOS, SCRATCH is ~/scratch, else /scratch
        if [[ $__OSTYPE == darwin ]]; then
            SCRATCH="${SCRATCH:-$HOME/scratch}"

            conda_prefix="$HOME/.mambaforge"
            command -v "$conda_prefix/bin/conda" > /dev/null 2>&1 && __CONDA_PREFIX="$conda_prefix"
            unset conda_prefix
        elif [[ -n $BLACKETT_HOST ]]; then
            export CVMFS_ROOT=/cvmfs/northgrid.gridpp.ac.uk/simonsobservatory \
                XROOTD_ROOT=root://bohr3226.tier2.hep.manchester.ac.uk:1094//dpm/tier2.hep.manchester.ac.uk/home/souk.ac.uk
            if [[ -n $BLACKETT_CVMFS_ENV ]]; then
                __CONDA_PREFIX="$CVMFS_ROOT/opt/miniforge3"
            else
                __CONDA_PREFIX=/opt/miniforge3
            fi
            if [[ -n $_CONDOR_SCRATCH_DIR ]]; then
                SCRATCH="$_CONDOR_SCRATCH_DIR"
            fi
        elif [[ -n $PRINCETON_HOST ]]; then
            # simons1 is not PRINCETON_HOST!
            SCRATCH="/n/lowrie-scratch/$USER"
            __CONDA_PREFIX=$SCRATCH/.mambaforge
            PROJ_ROOT=/n/lowrie-scratch
        elif [[ -n $SO_HOST ]]; then
            SCRATCH="/so/scratch/$USER"
            __CONDA_PREFIX="$HOME/.mambaforge"
        elif [[ -z $JBCA_HOST ]]; then
            SCRATCH="${SCRATCH:-/scratch}"

            conda_prefix="$HOME/.mambaforge"
            command -v "$conda_prefix/bin/conda" > /dev/null 2>&1 && __CONDA_PREFIX="$conda_prefix"
            unset conda_prefix
        fi
        ;;
esac

# XDG setup ############################################################

# general XDG related setup: add all systems that we want to setup XDG away from the default
if [[ (-n $NERSC_HOST || -n $JBCA_HOST) && -n $SCRATCH ]]; then
    # see https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
    # https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html
    # https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
    # https://numba.pydata.org/numba-doc/dev/reference/envvars.html?highlight=numba_threading_layer
    export XDG_CONFIG_HOME="$SCRATCH/.local/config" \
        XDG_CACHE_HOME="$SCRATCH/.local/cache" \
        XDG_DATA_HOME="$SCRATCH/.local/share" \
        XDG_STATE_HOME="$SCRATCH/.local/state"
    export CONDA_ENVS_PATH="$XDG_DATA_HOME/conda/envs" \
        CONDA_PKGS_DIRS="$XDG_CACHE_HOME/conda/pkgs" \
        CONDA_BLD_PATH="$XDG_CACHE_HOME/conda-bld/" \
        IPYTHONDIR="$XDG_CONFIG_HOME"/jupyter \
        JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter \
        MATHEMATICA_USERBASE="$XDG_CONFIG_HOME"/mathematica \
        PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel \
        WGETRC="$XDG_CONFIG_HOME/wgetrc" \
        NUMBA_CACHE_DIR="$XDG_CACHE_HOME/numba"
else
    export XDG_CONFIG_HOME="$HOME/.config" \
        XDG_CACHE_HOME="$HOME/.cache" \
        XDG_DATA_HOME="$HOME/.local/share" \
        XDG_STATE_HOME="$HOME/.local/state"
fi
# specific XDG related setup
if [[ -n $NERSC_HOST ]]; then
    # https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html
    export CONDA_ENVS_PATH="$CONDA_ENVS_PATH:$COMMON_ROOT/polar/.conda/envs"
    # doesn't work, see https://github.com/conda/conda/issues/10719
    # export CONDA_PKGS_DIRS="$(find /usr/common/software/python -maxdepth 2 -mindepth 2 -type d -name pkgs | sort -r | tr '\n' ':')$XDG_CACHE_HOME/conda/pkgs"
elif [[ -n $BLACKETT_HOST ]]; then
    export CONDA_ENVS_PATH="$CONDA_ENVS_PATH:$CVMFS_ROOT/opt:$CVMFS_ROOT/pmpm:$CVMFS_ROOT/conda"
    if [[ $BLACKETT_HOST == vm77 ]]; then
        export CONDA_ENVS_PATH="/opt:$CONDA_ENVS_PATH" HOMEBREW_CURL_PATH=/home/linuxbrew/.linuxbrew/bin/curl
    fi
fi

# zsh setup ############################################################

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
[[ -n $ZSH_VERSION ]] && export HISTFILE="$XDG_STATE_HOME/zsh/history"

[[ -e "$ZDOTDIR/.env" ]] && . "$ZDOTDIR/.env"

# export all variables #################################################

[[ -n $SCRATCH ]] && export SCRATCH
export __OSTYPE __HOST
if [[ -n $HOMEBREW_PREFIX ]]; then
    export HOMEBREW_PREFIX \
        HOMEBREW_NO_ANALYTICS=1 \
        HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar" \
        HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
fi
[[ -n $__CONDA_PREFIX ]] && export __CONDA_PREFIX
[[ -n $PROJ_ROOT ]] && export PROJ_ROOT
if [[ -n $BLACKETT_HOST && -d /opt/rh/rust-toolset-7/root/usr ]]; then
    export CARGO_PREFIX=/opt/rh/rust-toolset-7/root/usr
elif [[ -d "$HOME/.cargo" ]]; then
    export CARGO_PREFIX="$HOME/.cargo"
fi

# c.f. https://stackoverflow.com/a/23378780/5769446
case "$__OSTYPE" in
    darwin)
        __NCPU="$(sysctl -n hw.physicalcpu_max)"
        ;;
    linux)
        __NCPU="$(lscpu -p | grep -E -v '^#' | sort -u -t, -k 2,4 | wc -l)"
        ;;
    bsd)
        __NCPU="$(sysctl -n hw.ncpu)"
        ;;
    *)
        __NCPU="$(getconf _NPROCESSORS_ONLN 2> /dev/null || getconf NPROCESSORS_ONLN 2> /dev/null || echo 1)"
        ;;
esac
export \
    __NCPU \
    EDITOR=nano \
    GOBIN="$HOME/go/bin" \
    GOPATH="$HOME/go" \
    LANG=en_US.UTF-8 \
    MAKEFLAGS="-j$__NCPU" \
    SMAN_APPEND_HISTORY=false \
    SMAN_EXEC_CONFIRM=false \
    SMAN_SNIPPET_DIR="$HOME/git/source/sman-snippets" \
    ZIM_HOME=~/.zim

# alias ################################################################

# set alias (putting this in "interactive" does not help)
# this is needed to make sure mosh can see mosh-server not from PATH
# this is to avoid can't find tmux after `mu`
if [[ $__OSTYPE == darwin ]]; then
    __PREFIX=/opt/local/bin
elif [[ -n $NERSC_HOST || -n $PRINCETON_HOST || (-n $JBCA_HOST && -n $SCRATCH) ]]; then
    __PREFIX="$HOME/.local/bin"
elif [[ -n $BLACKETT_HOST ]]; then
    if [[ -n $BLACKETT_CVMFS_ENV ]]; then
        __PREFIX="$CVMFS_ROOT/usr/bin"
    else
        __PREFIX=/opt/local/bin
    fi
else
    case "$__HOST" in
        gordita)
            __PREFIX="$HOME/mambaforge/envs/system39-conda-forge/bin"
            ;;
    esac
fi
if [[ -n $__PREFIX ]]; then
    for i in mosh-server tmux exa eza lsd; do
        j="$__PREFIX/$i"
        [[ -f $j ]] && alias $i="$j"
    done
fi

command -v squeue > /dev/null 2>&1 &&
    alias sqs='squeue -o "%16i %2t %9u %12j  %5D %.10l %.10M  %20V %15q %20S %14f %15R" --me'

# basher ###############################################################

BASHER_ROOT="$HOME/.basher"
if [[ -n $BASHER_ROOT ]]; then
    export BASHER_ROOT \
        BASHER_PREFIX="$BASHER_ROOT/cellar"
    export BASHER_PACKAGES_PATH="$BASHER_PREFIX/packages"
    if [[ -n $ZSH_VERSION ]]; then
        export BASHER_SHELL=zsh
    elif [ -n "$BASH_VERSION" ]; then
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
    kill "$SUDO_PID"
    trap - SIGINT SIGTERM
    sudo -k
}
