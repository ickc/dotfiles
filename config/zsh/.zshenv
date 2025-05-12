#!/usr/bin/env bash

# * These variables can be customized per __HOST
# __PREFERRED_SHELL
# SCRATCH <- decicated filesystem for scratch, often not backed up and purged periodically
# __CMN <- dedicated filesystem for softwares, potentially read-only on compute nodes
# __APPDIR <- could be just __CMN, or a subdir of __CMN if shared with other users
# * important prefixes exported
# __LOCAL_ROOT <- arch-indep software prefix
# __OPT_ROOT <- arch-dep software prefix
# MAMBA_ROOT_PREFIX
# PIXI_HOME
# CARGO_PREFIX
# GOPATH
# ZIM_HOME

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

# defaults unless overridden otherwise
__PREFERRED_SHELL=zsh
# this can be defined by the system already
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
        __PREFERRED_SHELL=bash

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
    __PREFERRED_SHELL \
    SCRATCH

if [[ -n ${__APPDIR} ]]; then
    __LOCAL_ROOT="${__APPDIR}/local"
    __OPT_ROOT="${__APPDIR}/opt/${__OSTYPE}-${__ARCH}"
else
    __LOCAL_ROOT="${HOME}/.local"
    __OPT_ROOT="${__LOCAL_ROOT}/opt/${__OSTYPE}-${__ARCH}"
fi
export \
    __LOCAL_ROOT \
    __OPT_ROOT
[[ -n ${MAMBA_ROOT_PREFIX} ]] || MAMBA_ROOT_PREFIX="${__OPT_ROOT}/miniforge3"
export MAMBA_ROOT_PREFIX
[[ -n ${PIXI_HOME} ]] || PIXI_HOME="${__OPT_ROOT}/pixi"
export PIXI_HOME

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
# these are same as the defaults if __APPDIR is not set
export XDG_DATA_HOME="${__LOCAL_ROOT}/share"
export XDG_STATE_HOME="${__LOCAL_ROOT}/state"

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
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
# misc
# LS_COLORS copied from https://github.com/perplexa/dotfiles/blob/master/.gruvbox.dircolors
# and run dircolors ~/.gruvbox.dircolors
export \
    CARGO_PREFIX="${__OPT_ROOT}/cargo" \
    EDITOR=nano \
    GOBIN="${__OPT_ROOT}/go/bin" \
    GOPATH="${__OPT_ROOT}/go" \
    LANG=en_US.UTF-8 \
    LS_COLORS='no=0;38;15:rs=0:di=1;34:ln=01;35:mh=00:pi=40;33:so=1;38;211:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=30;42:st=37;44:ex=1;30;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;33:*.au=01;33:*.flac=01;33:*.mid=01;33:*.midi=01;33:*.mka=01;33:*.mp3=01;33:*.mpc=01;33:*.ogg=01;33:*.ra=01;33:*.wav=01;33:*.axa=01;33:*.oga=01;33:*.spx=01;33:*.xspf=01;33:*.doc=01;91:*.ppt=01;91:*.xls=01;91:*.docx=01;91:*.pptx=01;91:*.xlsx=01;91:*.odt=01;91:*.ods=01;91:*.odp=01;91:*.pdf=01;91:*.tex=01;91:*.md=01;91:' \
    MAKEFLAGS="-j${__NCPU}" \
    SMAN_APPEND_HISTORY=false \
    SMAN_EXEC_CONFIRM=false \
    SMAN_SNIPPET_DIR="${HOME}/git/source/sman-snippets" \
    ZIM_HOME="${__LOCAL_ROOT}/zim"

# misc #################################################################

# shellcheck disable=SC1091
[[ -e "${ZDOTDIR}/.env" ]] && . "${ZDOTDIR}/.env"
