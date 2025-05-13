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
export PIXI_CACHE_DIR="${XDG_CACHE_HOME}/${__OSTYPE}-${__ARCH}/pixi"

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
    LS_COLORS='no=00;38;5;223:fi=00:rs=0:di=01;38;5;109:ln=01;38;5;142:mh=00:pi=38;5;126:so=01;38;5;126:do=01;38;5;126:bd=01;38;5;208:cd=01;38;5;214:or=38;5;167:mi=01;05;37;41:su=01;38;5;229;48;5;167:sg=01;38;5;229;48;5;166:ca=30;41:tw=01;38;5;229;48;5;167:ow=01;38;5;166:st=01;38;5;214:ex=01;38;5;208:*.tar=38;5;166:*.tgz=38;5;166:*.arc=38;5;166:*.arj=38;5;166:*.taz=38;5;166:*.lha=38;5;166:*.lz4=38;5;166:*.lzh=38;5;166:*.lzma=38;5;166:*.tlz=38;5;166:*.txz=38;5;166:*.tzo=38;5;166:*.t7z=38;5;166:*.zip=38;5;166:*.z=38;5;166:*.Z=38;5;166:*.dz=38;5;166:*.gz=38;5;166:*.lrz=38;5;166:*.lz=38;5;166:*.lzo=38;5;166:*.xz=38;5;166:*.bz2=38;5;166:*.bz=38;5;166:*.tbz=38;5;166:*.tbz2=38;5;166:*.tz=38;5;166:*.deb=38;5;166:*.rpm=38;5;166:*.jar=38;5;166:*.war=38;5;166:*.ear=38;5;166:*.sar=38;5;166:*.rar=38;5;166:*.ace=38;5;166:*.zoo=38;5;166:*.cpio=38;5;166:*.7z=38;5;166:*.rz=38;5;166:*.cab=38;5;166:*.jpg=38;5;214:*.jpeg=38;5;214:*.gif=38;5;214:*.bmp=38;5;214:*.pbm=38;5;214:*.pgm=38;5;214:*.ppm=38;5;214:*.tga=38;5;214:*.xbm=38;5;214:*.xpm=38;5;214:*.tif=38;5;214:*.tiff=38;5;214:*.png=38;5;214:*.svg=38;5;214:*.svgz=38;5;214:*.mng=38;5;214:*.pcx=38;5;214:*.mov=38;5;214:*.mpg=38;5;214:*.mpeg=38;5;214:*.m2v=38;5;214:*.mkv=38;5;214:*.webm=38;5;214:*.ogm=38;5;214:*.mp4=38;5;214:*.m4v=38;5;214:*.mp4v=38;5;214:*.vob=38;5;214:*.qt=38;5;214:*.nuv=38;5;214:*.wmv=38;5;214:*.asf=38;5;214:*.rm=38;5;214:*.rmvb=38;5;214:*.flc=38;5;214:*.avi=38;5;214:*.fli=38;5;214:*.flv=38;5;214:*.gl=38;5;214:*.dl=38;5;214:*.xcf=38;5;214:*.xwd=38;5;214:*.yuv=38;5;214:*.cgm=38;5;214:*.mkv=38;5;214:*.ogv=38;5;214:*.mp4=38;5;214:*.m4v=38;5;214:*.mp4v=38;5;214:*.vob=38;5;214:*.qt=38;5;214:*.nuv=38;5;214:*.wmv=38;5;214:*.asf=38;5;214:*.rm=38;5;214:*.rmvb=38;5;214:*.flc=38;5;214:*.avi=38;5;214:*.fli=38;5;214:*.flv=38;5;214:*.gl=38;5;214:*.dl=38;5;214:*.xcf=38;5;214:*.xwd=38;5;214:*.yuv=38;5;214:*.cgm=38;5;214:*.aac=38;5;142:*.au=38;5;142:*.flac=38;5;142:*.m4a=38;5;142:*.mid=38;5;142:*.midi=38;5;142:*.mka=38;5;142:*.mp3=38;5;142:*.mpc=38;5;142:*.ogg=38;5;142:*.ra=38;5;142:*.wav=38;5;142:*.oga=38;5;142:*.opus=38;5;142:*.spx=38;5;142:*.xspf=38;5;142:*.pdf=38;5;167:*.ps=38;5;167:*.txt=38;5;223:*.doc=38;5;167:*.docx=38;5;167:*.odt=38;5;167:*.ppt=38;5;167:*.pptx=38;5;167:*.odp=38;5;167:*.xls=38;5;142:*.xlsx=38;5;142:*.ods=38;5;142:*.csv=38;5;142:*.c=38;5;175:*.cpp=38;5;175:*.cc=38;5;175:*.cxx=38;5;175:*.h=38;5;175:*.hpp=38;5;175:*.py=38;5;142:*.rb=38;5;167:*.js=38;5;214:*.html=38;5;208:*.htm=38;5;208:*.css=38;5;175:*.php=38;5;125:*.java=38;5;208:*.sh=38;5;142:*.pl=38;5;208:*.rs=38;5;208:*.go=38;5;109:*.lua=38;5;109:*.vim=38;5;142:*.vimrc=38;5;142:*.conf=38;5;229:*.config=38;5;229:*.cfg=38;5;229:*.ini=38;5;229:*.json=38;5;229:*.yml=38;5;229:*.yaml=38;5;229:*.toml=38;5;229:*.lock=38;5;229:*.xml=38;5;167:*.sql=38;5;167:*.db=38;5;167:*.sqlite=38;5;167:*.log=38;5;245:*.bak=38;5;245:*.tmp=38;5;245:*.temp=38;5;245:*.swp=38;5;245:*.git=38;5;245:*.gitignore=38;5;245:*.gitmodules=38;5;245:*.pid=38;5;245:*.socket=38;5;126:*.service=38;5;175:*Makefile=38;5;142:*makefile=38;5;142:*.mk=38;5;142:*CMakeLists.txt=38;5;142:*.cmake=38;5;142:*.md=38;5;223:*.markdown=38;5;223:*.rst=38;5;223:*.tex=38;5;223:*.org=38;5;223:*.*rc=38;5;229:*.*profile=38;5;229:*.*_history=38;5;245:' \
    MAKEFLAGS="-j${__NCPU}" \
    SMAN_APPEND_HISTORY=false \
    SMAN_EXEC_CONFIRM=false \
    SMAN_SNIPPET_DIR="${HOME}/git/source/sman-snippets" \
    ZIM_HOME="${__LOCAL_ROOT}/zim"

# misc #################################################################

# shellcheck disable=SC1091
[[ -e "${ZDOTDIR}/.env" ]] && . "${ZDOTDIR}/.env"
