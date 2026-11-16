# PATH / MANPATH / INFOPATH / CONDA_ENVS_PATH and the optional Lmod set.
# Mirrors the PATH wiring in ~/.config/sh/rc.sh, including its scope: interactive
# shells only. The personal prefixes are a convenience at the prompt and are not
# imposed on scripts, which therefore cannot come to depend on them.
if status is-interactive
    # personal software prefixes on PATH/MANPATH/INFOPATH. micromamba/pixi/etc.
    # live under these prefixes and must work even when Lmod is unavailable.
    # Appended (not prepended) so system-provided binaries win — a deliberate,
    # security-minded change from the older prepend behaviour.
    function __path_append_all --argument-names root
        test -d $root/bin; and not contains $root/bin $PATH; and set -gx PATH $PATH $root/bin
        test -d $root/share/man; and not contains $root/share/man $MANPATH; and set -gx MANPATH $MANPATH $root/share/man
        test -d $root/share/info; and not contains $root/share/info $INFOPATH; and set -gx INFOPATH $INFOPATH $root/share/info
    end
    test -n "$PIXI_HOME"; and __path_append_all $PIXI_HOME
    test -n "$CARGO_HOME"; and __path_append_all $CARGO_HOME
    test -n "$__LOCAL_ROOT"; and __path_append_all $__LOCAL_ROOT
    if test -n "$__OPT_ROOT"
        __path_append_all $__OPT_ROOT
        __path_append_all $__OPT_ROOT/system
    end
    functions -e __path_append_all

    # conda/mamba env discovery. Prepended so __OPT_ROOT ends up ahead of the
    # XDG location.
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
        # self-guards on directory existence, so an absent tool (or wrong OS) is
        # a harmless no-op. As in rc.sh, Homebrew reaches PATH through its
        # module (which reads HOMEBREW_PREFIX from 00-env.fish).
        module use $XDG_CONFIG_HOME/modulefiles
        module load brew cuda lms mactex
    end
end
