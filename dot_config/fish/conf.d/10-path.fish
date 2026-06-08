# PATH setup ≈ ml_clean (the minimal "clean" module set). The full ml_*/mu
# dynamic module loader is intentionally not ported to fish. `man` auto-derives
# its search path from PATH entries (sibling share/man), so MANPATH is left alone.

# clean prefixes — iterate system -> opt -> local so the final precedence ends up
# local/bin, opt/bin, opt/system/bin (matches ml_clean's prepend order).
for _d in $__OPT_ROOT/system $__OPT_ROOT $__LOCAL_ROOT
    test -d $_d/bin; and fish_add_path -gp $_d/bin
end

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

# lmod (brew-provided; after homebrew so HOMEBREW_PREFIX is confirmed set)
if set -q HOMEBREW_PREFIX; and test -f $HOMEBREW_PREFIX/opt/lmod/init/fish
    source $HOMEBREW_PREFIX/opt/lmod/init/fish
end

# pixi / cargo / go (≈ ml_pixi / ml_cg)
test -d $PIXI_HOME/bin; and fish_add_path -gp $PIXI_HOME/bin
test -d $CARGO_PREFIX/bin; and fish_add_path -ga $CARGO_PREFIX/bin
test -d $GOBIN; and fish_add_path -ga $GOBIN
