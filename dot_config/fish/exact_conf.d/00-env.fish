# Shared environment for fish (environment variables only).
# Mirrors ~/.config/sh/env.sh. Kept in conf.d so it applies to non-interactive
# fish too. Envoy provides the platform facts, software prefixes and XDG base
# dirs; the rest mirrors env.sh's own exports.

# envoy sets __OSTYPE/__ARCH, the software prefixes (__LOCAL_ROOT, __OPT_ROOT,
# MAMBA_ROOT_PREFIX, PIXI_HOME, __LMOD_INIT) and the XDG base dirs. Prefer the
# live install; fall back to the vendored copy (refresh with `make vendor-envoy`)
# so these dotfiles work even when envoy is not installed.
if test -f ~/.local/share/envoy/env.fish
    source ~/.local/share/envoy/env.fish
else
    set -l _cfg $HOME/.config
    set -q XDG_CONFIG_HOME; and set _cfg $XDG_CONFIG_HOME
    test -f $_cfg/envoy/env.fish; and source $_cfg/envoy/env.fish
end

# parallel make. nproc honours the CPU affinity mask (a Slurm allocation,
# taskset), where getconf counts every core on the node; getconf is the fallback
# for macOS.
set -gx MAKEFLAGS "-j"(nproc 2>/dev/null; or getconf _NPROCESSORS_ONLN 2>/dev/null; or echo 1)

# set HOSTNAME by hostname if undefined
set -q HOSTNAME; or set -gx HOSTNAME (hostname -f 2>/dev/null; or hostname)

# override XDG_CACHE_HOME on systems with a dedicated SCRATCH filesystem
set -q SCRATCH; and test -n "$SCRATCH"; and set -gx XDG_CACHE_HOME $SCRATCH/.cache

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

# Homebrew (mirrors env.sh): detect the prefix and export what brew and the Lmod
# `brew` module read. PATH itself is wired by that module in 10-path.fish.
if not set -q HOMEBREW_PREFIX; or test -z "$HOMEBREW_PREFIX"
    switch $__OSTYPE
        case Linux
            set -g HOMEBREW_PREFIX /home/linuxbrew/.linuxbrew
        case Darwin
            switch $__ARCH
                case x86_64
                    set -g HOMEBREW_PREFIX /usr/local
                case arm64
                    set -g HOMEBREW_PREFIX /opt/homebrew
            end
    end
end
if test -n "$HOMEBREW_PREFIX"; and test -x $HOMEBREW_PREFIX/bin/brew
    set -gx HOMEBREW_PREFIX $HOMEBREW_PREFIX
    set -gx HOMEBREW_CELLAR $HOMEBREW_PREFIX/Cellar
    set -gx HOMEBREW_NO_ANALYTICS 1
    # the repository is a Homebrew/ subdirectory of the prefix everywhere except
    # Apple Silicon, where it is the prefix itself
    if test -d $HOMEBREW_PREFIX/Homebrew
        set -gx HOMEBREW_REPOSITORY $HOMEBREW_PREFIX/Homebrew
    else
        set -gx HOMEBREW_REPOSITORY $HOMEBREW_PREFIX
    end
else
    set -e HOMEBREW_PREFIX
end

# misc exports
set -gx EDITOR nano
set -gx LANG en_US.UTF-8
set -gx SMAN_APPEND_HISTORY false
set -gx SMAN_EXEC_CONFIRM false
set -gx SMAN_SNIPPET_DIR $XDG_DATA_HOME/sman/snippets
