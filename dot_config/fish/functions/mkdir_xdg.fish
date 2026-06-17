# mkdir_xdg — create the XDG base directories (and astropy's, which ignores XDG).
# Mirrors mkdir_xdg() in ~/.config/sh/rc.sh.
function mkdir_xdg --description 'create the XDG base directories'
    mkdir -p \
        $XDG_DATA_HOME \
        $XDG_STATE_HOME \
        $XDG_CONFIG_HOME \
        $XDG_CACHE_HOME \
        $XDG_CONFIG_HOME/astropy \
        $XDG_CACHE_HOME/astropy
end
