#!/usr/bin/env bash
# shellcheck source=config/zsh/.zshenv

# * use `__CLEAN=1 zsh` to load a minimal environment, see notes below
# * use `__PROMPT_THEME=[starship|powerlevel10k]` to set the prompt
export __PROMPT_THEME="${__PROMPT_THEME:-starship}"

# set title of prompt. c.f. https://tldp.org/HOWTO/Xterm-Title-3.html
printf "\033]0;%s\007" "${__HOST%%.*}"

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

# helpers ######################################################################

# * any path-like variables should be remember and reset using this machanism
# keeping the original PATH for cleaning environments
export __PATH="${__PATH:-${PATH}}" \
    __MANPATH="${__MANPATH:-${MANPATH}}" \
    __INFOPATH="${__INFOPATH:-${INFOPATH}}" \
    __PYTHONPATH="${__PYTHONPATH:-${PYTHONPATH}}" \
    __LD_LIBRARY_PATH="${__LD_LIBRARY_PATH:-${LD_LIBRARY_PATH}}"
# reset PATH every time a new interactive shell is started
# berfore any paths are added to it
[[ -n ${__PATH} ]] && export PATH="${__PATH}"
[[ -n ${__MANPATH} ]] && export MANPATH="${__MANPATH}"
[[ -n ${__INFOPATH} ]] && export INFOPATH="${__INFOPATH}"
[[ -n ${__PYTHONPATH} ]] && export PYTHONPATH="${__PYTHONPATH}"
[[ -n ${__LD_LIBRARY_PATH} ]] && export LD_LIBRARY_PATH="${__LD_LIBRARY_PATH}"

printerr() {
    printf '%s\n' "$@" >&2
}

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

TERMINFO_DIRS_append() {
    if [[ -d $1 ]]; then
        case ":${TERMINFO_DIRS}:" in
            *":$1:"*) : ;;
            *) export TERMINFO_DIRS="${TERMINFO_DIRS:+${TERMINFO_DIRS}:}${1}" ;;
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

# TODO: fix this on FreeBSD such as bolo
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

# Powerlevel10k ################################################################

# fallback to starship if not in zsh
if [[ ${__PROMPT_THEME} == powerlevel10k && -z ${ZSH_VERSION} ]]; then
    __PROMPT_THEME=starship
fi

if [[ ${__PROMPT_THEME} == powerlevel10k ]]; then
    # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
    # Initialization code that may require console input (password prompts, [y/n]
    # confirmations, etc.) must go above this block; everything else may go below.
    if [[ -r "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${USER}.zsh" ]]; then
        # shellcheck disable=SC1090
        source "${XDG_CACHE_HOME:-${HOME}/.cache}/p10k-instant-prompt-${USER}.zsh"
    fi
    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    # shellcheck disable=SC1090
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

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
    # shellcheck disable=SC2206
    fpath=("${HOMEBREW_PREFIX}/share/zsh/site-functions" ${fpath})
}

# macports
ml_port() {
    path_prepend /opt/local/sbin
    path_prepend_all /opt/local
    path_prepend /opt/local/libexec/gnubin
}

# conda
ml_conda() {
    # * this source the conda functions but not changing the PATH directly
    # it allows you to put the conda function available without letting it
    # changing your PATH
    local __PATH__="${PATH}"
    # shellcheck disable=SC1091
    . "${__CONDA_PREFIX}/etc/profile.d/conda.sh"
    # shellcheck disable=SC1091
    . "${__CONDA_PREFIX}/etc/profile.d/mamba.sh"
    export PATH="${__PATH__}"

    conda_envs_path_prepend "${XDG_DATA_HOME}/conda/envs"
    if [[ -n ${NERSC_HOST} ]]; then
        conda_envs_path_prepend "${CMN}/polar/opt/conda/envs"
    elif [[ -n ${BLACKETT_HOST} ]]; then
        conda_envs_path_prepend "${CVMFS_ROOT}/opt"
        conda_envs_path_prepend "${CVMFS_ROOT}/conda"
        conda_envs_path_prepend "${CVMFS_ROOT}/pmpm"
        if [[ ${BLACKETT_HOST} == vm77 ]]; then
            conda_envs_path_append /opt
        fi
    fi
}

mu_conda() {
    # from "${__CONDA_PREFIX}/etc/profile.d/conda.sh"
    unset CONDA_EXE
    unset CONDA_PYTHON_EXE
    unset CONDA_SHLVL
    unset _CE_CONDA
    unset _CE_M
}

ml_basher() {
    path_prepend "${BASHER_ROOT}/cellar/bin"
    # shellcheck disable=SC1090
    . "${BASHER_ROOT}/lib/include.${BASHER_SHELL}"
    # shellcheck disable=SC1090
    . "${BASHER_ROOT}/completions/basher.${BASHER_SHELL}"
    if [[ -n ${ZSH_VERSION} ]]; then
        # shellcheck disable=SC2206,SC2128
        fpath=("${BASHER_ROOT}/cellar/completions/zsh/compsys" ${fpath})
        # shellcheck disable=SC1090
        for f in $(command ls "${BASHER_ROOT}/cellar/completions/zsh/compctl"); do source "${BASHER_ROOT}/cellar/completions/zsh/compctl/${f}"; done
    elif [[ -n ${BASH_VERSION} ]]; then
        # shellcheck disable=SC1090
        for f in $(command ls "${BASHER_ROOT}/cellar/completions/bash"); do source "${BASHER_ROOT}/cellar/completions/bash/${f}"; done
    fi
    path_append_all "${BASHER_ROOT}"
    path_append_all "${BASHER_PREFIX}"
}

# sman
ml_s() {
    # shellcheck disable=SC1091
    . "${HOME}/.sman/sman.rc"
}

ml_exa() {
    alias ls=exa
}

ml_eza() {
    alias ls=eza
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

# hosts ========================================================================

if [[ -n ${NERSC_HOST} ]]; then
    ml_toast() {
        module use /global/common/software/polar/.conda/envs/cmbenv/modulefiles
        # module use /global/common/software/cmb/cori/default/modulefiles
        module load cmbenv
        # manually edit /global/common/software/polar/.conda/envs/cmbenv/modulefiles/cmbenv/v1.0.3.dev124
        # to remove PATH editing, sqs alias, PYTHONSTARTUP, PYTHONUSERBASE
        # manual edit /global/common/software/polar/.conda/envs/cmbenv/cmbenv_python/bin/cmbenv
        # to fix zsh error
        # shellcheck disable=SC1091
        . /global/common/software/polar/.conda/envs/cmbenv/cmbenv_python/bin/cmbenv
    }

    ml_toast_conda() {
        TOAST_PREFIX=/global/common/software/polar/.conda/envs/common-20210404-toast-conda
        conda activate "${TOAST_PREFIX}"
    }
elif [[ -n ${BLACKETT_HOST} ]]; then
    if [[ -n ${BLACKETT_CVMFS_ENV} ]]; then
        ml_host() {
            path_prepend_all "${CVMFS_ROOT}/usr"
        }
    else
        ml_host() {
            path_prepend_all /opt/local
        }
    fi
    ml_intel() {
        # shellcheck disable=SC1091
        . "${CVMFS_ROOT}/opt/intel/oneapi/setvars.sh"
    }
else
    case "${__HOST}" in
        simons1)
            ml_host() {
                # shellcheck disable=SC1091
                . /usr/share/modules/init/zsh
                module use --append /mnt/so1/shared/modules/
            }
            ml_toast() {
                module load tod_stack_unstable
            }
            ;;
        gordita)
            ml_host() {
                [[ ${__HOST} == gordita ]] && path_prepend_all "${HOME}/.linux.local"
            }
            ;;
        kolen-server)
            ml_cuda() {
                path_append /usr/local/cuda-11
                ld_library_path_prepend /usr/local/cuda-11/lib64
            }
            ml_cuda_12() {
                path_append /usr/local/cuda-12
                ld_library_path_prepend /usr/local/cuda-12/lib64
            }
            ;;
        *)
            ml_toast_gnu() {
                TOAST_PREFIX="${SCRATCH}/local/toast-gnu"
                conda activate "${TOAST_PREFIX}/conda"
                [[ ${__OSTYPE} == darwin ]] && ld_library_path_prepend /opt/local/lib/mpich-mp
                ld_library_path_prepend "${TOAST_PREFIX}/compile/lib"
                pythonpath_prepend "${TOAST_PREFIX}/compile/lib/python3.8/site-packages"
                path_prepend "${TOAST_PREFIX}/compile/bin:${TOAST_PREFIX}/conda/bin"
            }

            ml_toast_conda() {
                conda activate toast-conda
            }
            ;;
    esac
fi

#===============================================================================

ml_clean() {
    # special case, may generalize something like this to any FreeBSD?
    if [[ ${__HOST} == bolo ]]; then
        remove_home_local_bin_from_PATH
    fi

    # * load minimal environment for interactive use
    path_prepend_all "${HOME}/.local"

    [[ -f "${HOME}/.sman/sman.rc" ]] && ml_s
    # exa: only alias if exist. hash is incorrect on NERSC
    command -v exa > /dev/null 2>&1 && ml_exa
    command -v eza > /dev/null 2>&1 && ml_eza
    # note that this prefers lsd over exa
    command -v lsd > /dev/null 2>&1 && ml_lsd
}

ml() {
    if [[ ${__HOST} == bolo ]]; then
        remove_home_local_bin_from_PATH
    fi

    # * load all installed environments
    # * includes clean, go, ghcup, brew, port, conda, cargo, basher, host
    ml_ghcup
    [[ -n ${HOMEBREW_PREFIX} ]] && ml_brew
    [[ ${__OSTYPE} == darwin ]] && ml_port
    [[ -n ${__CONDA_PREFIX} ]] && ml_conda
    [[ -n ${CARGO_PREFIX} ]] && ml_cg
    [[ -d "${HOME}/.basher" ]] && ml_basher
    [[ -d "${HOME}/Library/Application Support/JetBrains/Toolbox/scripts" ]] && ml_jetbrains

    command -v ml_host > /dev/null 2>&1 && ml_host

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
    [[ -n ${XDG_DATA_HOME} ]] && mkdir -p "${XDG_DATA_HOME}"
    [[ -n ${XDG_STATE_HOME} ]] && mkdir -p "${XDG_STATE_HOME}"
    [[ -n ${XDG_CONFIG_HOME} ]] && mkdir -p "${XDG_CONFIG_HOME}"
    [[ -n ${XDG_CACHE_HOME} ]] && mkdir -p "${XDG_CACHE_HOME}"
    # see https://docs.astropy.org/en/stable/config/index.html#getting-started
    [[ ! -d "${XDG_CONFIG_HOME}/astropy" ]] && mkdir -p "${XDG_CONFIG_HOME}/astropy"
    [[ ! -d "${XDG_CACHE_HOME}/astropy" ]] && mkdir -p "${XDG_CACHE_HOME}/astropy"
}

# main #########################################################################

if [[ -n ${__CLEAN} ]]; then
    ml_clean
else
    ml
fi

# even if this doesn't mask the world readability
# the parent directories should protect it already
umask 022

# for tmux to work properly on macOS
# see https://gpanders.com/blog/the-definitive-guide-to-using-tmux-256color-on-macos/
if [[ ${__OSTYPE} == darwin && ! -d "${HOME}/.local/share/terminfo" ]]; then
    echo "Setting up terminfo for tmux on macOS" >&2
    rm -f "${HOME}/tmux-256color.src"
    /opt/local/bin/infocmp -x tmux-256color > "${HOME}/tmux-256color.src"
    /usr/bin/tic -x -o "${HOME}/.local/share/terminfo" "${HOME}/tmux-256color.src"
    rm -f "${HOME}/tmux-256color.src"
fi
[[ -d "${HOME}/.local/share/terminfo" ]] && TERMINFO_DIRS_append "${HOME}/.local/share/terminfo"

# git external diff
# ${PATH} is not fully set in zshenv so we have to put it here
command -v difft > /dev/null 2>&1 && export GIT_EXTERNAL_DIFF=difft

# fzf
if FZF_PATH="$(command -v fzf)"; then
    FZF_PATH="$(realpath "${FZF_PATH}")"
    FZF_SHARE="${FZF_PATH%/*}/../share/fzf"
    # sometimes it is put inside a "shell" subdirectory
    [[ -d ${FZF_SHARE}/shell ]] && FZF_SHARE="${FZF_SHARE}/shell"
    # check shell is bash or zsh
    if [[ -n ${BASH_VERSION} ]]; then
        # shellcheck disable=SC1091
        [[ -f "${FZF_SHARE}"/completion.bash ]] && source "${FZF_SHARE}"/completion.bash
        # shellcheck disable=SC1091
        [[ -f "${FZF_SHARE}"/key-bindings.bash ]] && source "${FZF_SHARE}"/key-bindings.bash
    elif [[ -n ${ZSH_VERSION} ]]; then
        # shellcheck disable=SC1091
        [[ -f "${FZF_SHARE}"/completion.zsh ]] && source "${FZF_SHARE}"/completion.zsh
        # shellcheck disable=SC1091
        [[ -f "${FZF_SHARE}"/key-bindings.zsh ]] && source "${FZF_SHARE}"/key-bindings.zsh
    fi
    # OpenSUSE
    # shellcheck disable=SC1091
    [[ -f /etc/zsh_completion.d/fzf-key-bindings ]] && source /etc/zsh_completion.d/fzf-key-bindings
    unset FZF_SHARE
fi
unset FZF_PATH

# starship
if [[ -n ${BASH_VERSION} ]]; then
    # shellcheck disable=SC2312
    command -v starship > /dev/null 2>&1 && eval "$(starship init bash)"
    # shellcheck disable=SC2312
    command -v zellij > /dev/null 2>&1 && eval "$(zellij setup --generate-completion bash)"
fi

# zim ##########################################################################

# if zsh
if [[ -n ${ZSH_VERSION} ]]; then

    zstyle ':zim:zmodule' use 'degit'

    # Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
    if [[ ! "${ZIM_HOME}/init.zsh" -nt "${ZDOTDIR:-${HOME}}/.zimrc" ]]; then
        # shellcheck disable=SC1091
        source "${ZIM_HOME}/zimfw.zsh" init -q
    fi

    # ssh
    zstyle ':zim:ssh' ids id_ed25519
    # zsh-users/zsh-history-substring-search
    # shellcheck disable=SC2154
    bindkey "${terminfo[kcuu1]}" history-substring-search-up
    # shellcheck disable=SC2154
    bindkey "${terminfo[kcud1]}" history-substring-search-down

    # Initialize modules.
    # shellcheck disable=SC1091
    source "${ZIM_HOME}/init.zsh"
fi

if command -v fastfetch > /dev/null 2>&1; then
    fastfetch
elif command -v neofetch > /dev/null 2>&1; then
    neofetch
fi
