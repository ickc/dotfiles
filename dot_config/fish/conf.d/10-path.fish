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
    $HOMEBREW_PREFIX/bin/brew shellenv fish | source
else
    set -e HOMEBREW_PREFIX
end

# module system (Lmod). Priority: host-provided module first, then Homebrew's
# Lmod if present, then envoy's conda-bootstrapped Lmod from __LMOD_INIT.
if not type -q module
    if set -q HOMEBREW_PREFIX; and test -f "$HOMEBREW_PREFIX/opt/lmod/init/fish"
        set -gx __LMOD_INIT "$HOMEBREW_PREFIX/opt/lmod/init"
    end
    if set -q __LMOD_INIT; and test -f "$__LMOD_INIT/fish"
        source "$__LMOD_INIT/fish"
    end
end

if type -q module
    # personal modulefiles take precedence over any host-provided ones
    module use "$XDG_CONFIG_HOME/modulefiles"

    if set -q __CLEAN; and test -n "$__CLEAN"
        module load core
    else
        module load brew conda pixi cargo go ghcup lms agy cuda jetbrains mactex
        if set -q COSMA_HOST; and test -n "$COSMA_HOST"
            module load cosma 2>/dev/null; or true
        end
        module load core
    end
end
