# PATH / MANPATH / INFOPATH / CONDA_ENVS_PATH and the optional Lmod set.
# Mirrors the PATH wiring in ~/.config/sh/rc.sh, but lives in conf.d so it applies
# to non-interactive fish too. Homebrew is prepended (via `brew shellenv`); the
# personal prefixes are appended so system binaries keep precedence.

# homebrew (mirrors env.sh detection, then `brew shellenv`)
if not set -q HOMEBREW_PREFIX
    switch $__OSTYPE
        case Linux
            set -g HOMEBREW_PREFIX /home/linuxbrew/.linuxbrew
        case Darwin
            switch $__ARCH
                case arm64
                    set -g HOMEBREW_PREFIX /opt/homebrew
                case '*'
                    set -g HOMEBREW_PREFIX /usr/local
            end
    end
end
if set -q HOMEBREW_PREFIX; and test -x $HOMEBREW_PREFIX/bin/brew
    set -gx HOMEBREW_NO_ANALYTICS 1
    $HOMEBREW_PREFIX/bin/brew shellenv fish | source
else
    set -e HOMEBREW_PREFIX
end

# personal software prefixes on PATH/MANPATH/INFOPATH. Replaces the old `core`
# module now that PATH is wired without Lmod: micromamba/pixi/etc. live under
# these prefixes and must work even when Lmod is unavailable. Appended (not
# prepended) so system-provided binaries win — a deliberate, security-minded
# change from the older prepend behaviour.
function __path_append_all --argument-names root
    test -d $root/bin; and not contains $root/bin $PATH; and set -gx PATH $PATH $root/bin
    test -d $root/share/man; and not contains $root/share/man $MANPATH; and set -gx MANPATH $MANPATH $root/share/man
    test -d $root/share/info; and not contains $root/share/info $INFOPATH; and set -gx INFOPATH $INFOPATH $root/share/info
end
test -n "$__LOCAL_ROOT"; and __path_append_all $__LOCAL_ROOT
if test -n "$__OPT_ROOT"
    __path_append_all $__OPT_ROOT
    __path_append_all $__OPT_ROOT/system
end
test -n "$PIXI_HOME"; and __path_append_all $PIXI_HOME
functions -e __path_append_all

# conda/mamba env discovery (≈ the old conda modulefile). Prepended so __OPT_ROOT
# ends up ahead of the XDG location.
function __conda_envs_path_prepend --argument-names dir
    test -d $dir; and not contains $dir $CONDA_ENVS_PATH; and set -gx CONDA_ENVS_PATH $dir $CONDA_ENVS_PATH
end
__conda_envs_path_prepend $XDG_DATA_HOME/conda/envs
__conda_envs_path_prepend $__OPT_ROOT
functions -e __conda_envs_path_prepend

# module system (Lmod), optional. Priority: host-provided module first, then
# Homebrew's Lmod, then envoy's conda-bootstrapped Lmod from __LMOD_INIT.
if not type -q module
    if set -q HOMEBREW_PREFIX; and test -f $HOMEBREW_PREFIX/opt/lmod/init/fish
        set -gx __LMOD_INIT $HOMEBREW_PREFIX/opt/lmod/init
    end
    if set -q __LMOD_INIT; and test -f $__LMOD_INIT/fish
        source $__LMOD_INIT/fish
    end
end

if type -q module
    # personal modulefiles take precedence over any host-provided ones; each
    # self-guards on directory existence, so an absent tool (or wrong OS) is a
    # harmless no-op. brew is already wired via `brew shellenv` above.
    module use $XDG_CONFIG_HOME/modulefiles
    module load cuda lms mactex
end
