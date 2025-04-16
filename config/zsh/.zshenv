#!/usr/bin/env bash

# * These variables should exist on all systems:
# __CONDA_PREFIX
# __PREFERRED_SHELL
# SCRATCH <- often not backed up and purged periodically
# SOFTWARE_ROOT <- for softwares
# e.g. SOFTWARE_ROOT=.../opt or SOFTWARE_ROOT=~/.opt
# ${SOFTWARE_ROOT}/${__OSTYPE}-${__ARCH}/${DISTRIBUTION_NAME}/... <- for architecture dependent, "distribution-like" such as a conda env
# ${SOFTWARE_ROOT}/${__OSTYPE}-${__ARCH}/local <- for architecture dependent, local-like stuffs
# ${SOFTWARE_ROOT}/local <- for architecture independent stuffs
# * CONDA_PREFIX is defined by conda, and can be changed by conda as new environments are activated

# __OSTYPE, __ARCH detection ###########################################

# set __OSTYPE as normalized OSTYPE
# shellcheck disable=SC2312
read -r __OSTYPE __ARCH <<< "$(uname -sm)"
export __OSTYPE
export __ARCH

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
# depends on __OSTYPE

# default to zsh unless overridden otherwise
__PREFERRED_SHELL=zsh

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
        __PREFERRED_SHELL=bash

        if [[ -n ${SLURM_JOB_PARTITION} ]]; then
            # running on a compute node
            COSMA_HOST="${SLURM_JOB_PARTITION}"
        else
            case "${HOSTNAME}" in
                login5?.pri.cosma.local)
                    # running on a login node
                    COSMA_HOST=cosma5
                    ;;
                login7?.pri.cosma.local)
                    # running on a login node
                    COSMA_HOST=cosma7
                    ;;
                login8?.pri.cosma.local)
                    # running on a login node
                    COSMA_HOST=cosma8
                    ;;
                *)
                    COSMA_HOST="${HOSTNAME}"
                    ;;
            esac
        fi
        export COSMA_HOST
        __HOST="${COSMA_HOST}"

        export CMN="/cosma/apps/durham/${USER}"
        export SOFTWARE_ROOT="${CMN}/opt"
        export PIXI_HOME="${SOFTWARE_ROOT}/pixi"
        __CONDA_PREFIX="${SOFTWARE_ROOT}/miniforge3"

        if [[ -d /snap8 ]]; then
            export SCRATCH="/snap8/scratch/do009/${USER}"
        else
            export SCRATCH="/cosma5/data/durham/${USER}"
        fi
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
        # this should be systems I have sudo access to
        __HOST="${HOSTNAME}"
        SCRATCH="${SCRATCH:-/var/scratch/${USER}}"
        export PIXI_HOME=/opt/pixi

        for conda_prefix in "${HOME}/.mambaforge" "${HOME}/.miniforge3" /opt/miniforge3; do
            command -v "${conda_prefix}/bin/conda" > /dev/null 2>&1 && __CONDA_PREFIX="${conda_prefix}"
        done
        unset conda_prefix
        ;;
esac
[[ -n ${SCRATCH} ]] && export SCRATCH

export __HOST __PREFERRED_SHELL
[[ -n ${__CONDA_PREFIX} ]] && export __CONDA_PREFIX

# XDG setup ############################################################
# depends on __HOST detection

# see https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html
# https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
# https://numba.pydata.org/numba-doc/dev/reference/envvars.html?highlight=numba_threading_layer

export XDG_CONFIG_HOME="${HOME}/.config"
if [[ -n ${COSMA_HOST} ]]; then
    export \
        XDG_DATA_HOME="${CMN}/local/share" \
        XDG_STATE_HOME="${CMN}/local/state"
else
    export \
        XDG_DATA_HOME="${HOME}/.local/share" \
        XDG_STATE_HOME="${HOME}/.local/state"
fi
# as SCRATCH is subjected to be purged, only put cache in SCRATCH in sites
if [[ -n ${BOLO_HOST} && -n ${SCRATCH} ]]; then
    export XDG_CACHE_HOME="${SCRATCH}/.cache"
elif [[ -n ${COSMA_HOST} ]]; then
    export XDG_CACHE_HOME="${CMN}/.cache"
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
if [[ -n ${ZSH_VERSION} ]]; then
    export \
        ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
# elif [[ -n ${BASH_VERSION} ]]; then
fi
# misc
# LS_COLORS copied from https://github.com/perplexa/dotfiles/blob/master/.gruvbox.dircolors
# and run dircolors ~/.gruvbox.dircolors
export \
    CARGO_PREFIX="${HOME}/.cargo" \
    EDITOR=nano \
    GOBIN="${HOME}/go/bin" \
    GOPATH="${HOME}/go" \
    LANG=en_US.UTF-8 \
    LS_COLORS='no=0;38;15:rs=0:di=1;34:ln=01;35:mh=00:pi=40;33:so=1;38;211:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=30;42:st=37;44:ex=1;30;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;33:*.au=01;33:*.flac=01;33:*.mid=01;33:*.midi=01;33:*.mka=01;33:*.mp3=01;33:*.mpc=01;33:*.ogg=01;33:*.ra=01;33:*.wav=01;33:*.axa=01;33:*.oga=01;33:*.spx=01;33:*.xspf=01;33:*.doc=01;91:*.ppt=01;91:*.xls=01;91:*.docx=01;91:*.pptx=01;91:*.xlsx=01;91:*.odt=01;91:*.ods=01;91:*.odp=01;91:*.pdf=01;91:*.tex=01;91:*.md=01;91:' \
    MAKEFLAGS="-j${__NCPU}" \
    SMAN_APPEND_HISTORY=false \
    SMAN_EXEC_CONFIRM=false \
    SMAN_SNIPPET_DIR="${HOME}/git/source/sman-snippets" \
    ZIM_HOME="${HOME}/.zim"

# misc #################################################################

# shellcheck disable=SC1091
[[ -e "${ZDOTDIR}/.env" ]] && . "${ZDOTDIR}/.env"
