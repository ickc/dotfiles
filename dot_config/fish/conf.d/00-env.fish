# Shared environment for fish (environment variables only).
# Keep dotfile-specific exports in sync with ~/.config/sh/env.sh. Envoy-managed
# path defaults come from envoy/env.fish when installed.

# __OSTYPE / __ARCH — normalized `uname -sm`
set -l _uname (uname -sm | string split ' ')
set -gx __OSTYPE $_uname[1]
set -gx __ARCH $_uname[2]

# __NCPU
switch $__OSTYPE
    case Linux
        set -gx __NCPU (nproc 2>/dev/null; or echo 1)
    case Darwin
        set -gx __NCPU (sysctl -n hw.physicalcpu_max)
    case '*'
        set -gx __NCPU (getconf _NPROCESSORS_ONLN 2>/dev/null; or echo 1)
end

# __HOST — short hostname (host-specific *_HOST overrides omitted in fish)
set -q HOSTNAME; or set -gx HOSTNAME (hostname -f 2>/dev/null; or hostname)
set -l _host (string split -m1 . $HOSTNAME)
set -gx __HOST $_host[1]
set -q SCRATCH; or set -gx SCRATCH $HOME/.scratch

# XDG base dirs
if test "$SCRATCH" != "$HOME/.scratch"
    set -gx XDG_CACHE_HOME $SCRATCH/.cache
else
    set -gx XDG_CACHE_HOME $HOME/.cache
end
set -gx XDG_CONFIG_HOME $HOME/.config
if set -q __APPDIR; and test -n "$__APPDIR"
    set -gx XDG_DATA_HOME $__APPDIR/local/share
    set -gx XDG_STATE_HOME $__APPDIR/local/state
else
    set -gx XDG_DATA_HOME $HOME/.local/share
    set -gx XDG_STATE_HOME $HOME/.local/state
end

set -q XDG_DATA_DIRS; or set -gx XDG_DATA_DIRS /usr/local/share/ /usr/share/
set -q XDG_CONFIG_DIRS; or set -gx XDG_CONFIG_DIRS /etc/xdg/

# envoy's env.fish sets __LOCAL_ROOT, __OPT_ROOT, MAMBA_ROOT_PREFIX, PIXI_HOME,
# and __LMOD_INIT using __APPDIR if already set above; XDG vars are respected.
if test -f "$XDG_DATA_HOME/envoy/env.fish"
    source "$XDG_DATA_HOME/envoy/env.fish"
end
# fallback defaults when envoy is absent (mirrors envoy/env.fish)
if not set -q __LOCAL_ROOT; or test -z "$__LOCAL_ROOT"
    if set -q __APPDIR; and test -n "$__APPDIR"
        set -gx __LOCAL_ROOT $__APPDIR/local
    else
        set -gx __LOCAL_ROOT $HOME/.local
    end
end
if not set -q __OPT_ROOT; or test -z "$__OPT_ROOT"
    set -gx __OPT_ROOT $__LOCAL_ROOT/opt/$__OSTYPE-$__ARCH
end
if not set -q MAMBA_ROOT_PREFIX; or test -z "$MAMBA_ROOT_PREFIX"
    set -gx MAMBA_ROOT_PREFIX $__OPT_ROOT/micromamba
end
if not set -q PIXI_HOME; or test -z "$PIXI_HOME"
    set -gx PIXI_HOME $__OPT_ROOT/pixi
end
if not set -q __LMOD_INIT; or test -z "$__LMOD_INIT"
    set -gx __LMOD_INIT $__OPT_ROOT/system/lmod/lmod/init
end

# package caches + tool config (mirror env.sh exports)
set -gx CONDA_BLD_PATH $XDG_CACHE_HOME/conda-bld/
set -gx CONDA_PKGS_DIRS $XDG_CACHE_HOME/conda/pkgs
set -gx INPUTRC $XDG_CONFIG_HOME/readline/inputrc
set -gx IPYTHONDIR $XDG_CONFIG_HOME/jupyter
set -gx JUPYTER_CONFIG_DIR $XDG_CONFIG_HOME/jupyter
set -gx MATHEMATICA_USERBASE $XDG_CONFIG_HOME/mathematica
set -gx NUMBA_CACHE_DIR $XDG_CACHE_HOME/numba
set -gx PARALLEL_HOME $XDG_CONFIG_HOME/parallel
set -gx PIXI_CACHE_DIR $XDG_CACHE_HOME/$__OSTYPE-$__ARCH/pixi
set -gx WGETRC $XDG_CONFIG_HOME/wgetrc

# shell / misc
set -gx ZDOTDIR $HOME
set -gx CARGO_PREFIX $__OPT_ROOT/cargo
set -gx EDITOR nano
set -gx GOBIN $__OPT_ROOT/go/bin
set -gx GOPATH $__OPT_ROOT/go
set -gx LANG en_US.UTF-8
set -gx MAKEFLAGS "-j$__NCPU"
set -gx SMAN_APPEND_HISTORY false
set -gx SMAN_EXEC_CONFIRM false
set -gx SMAN_SNIPPET_DIR $XDG_DATA_HOME/sman/snippets
