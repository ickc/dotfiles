#!/usr/bin/env bash

# since __HOST is used, for those hosts this needed to be run twice
# first time to setup the env for __HOST
# log in again to run second time for this script to write correctly

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# .bash_profile
case "$__HOST" in
    gordita|bolo) echo '[[ "$HOSTNAME" == gordita* ]] && exec $HOME/mambaforge/envs/system39-conda-forge/bin/zsh || exec zsh' > "$HOME/.bash_profile"   ;;
    *)            : > "$HOME/.bash_profile"                                                                                                             ;;
esac

cat << EOF >> "$HOME/.bash_profile"
[[ -s "$DIR/env" ]] && . "$DIR/env"
[[ -s "$DIR/.env" ]] && . "$DIR/.env"
EOF

# .bashrc
cat << EOF > "$HOME/.bashrc"
[[ -s "$DIR/env" ]] && . "$DIR/env"
[[ -s "$DIR/.env" ]] && . "$DIR/.env"
[[ \$- == *i* && -s "$DIR/interactive" ]] && . "$DIR/interactive"
EOF

# assume zprezto always at ~/.zprezto

# .zshenv
cat << EOF > "$HOME/.zshenv"
[[ -s "$DIR/env" ]] && . "$DIR/env"
[[ -s "$DIR/.env" ]] && . "$DIR/.env"
[[ -s "$HOME/.zprezto/runcoms/zshenv" ]] && . "$HOME/.zprezto/runcoms/zshenv"
EOF

# .zprofile
cat << EOF > "$HOME/.zprofile"
if [[ -s "$HOME/.zprezto/runcoms/zprofile" ]]; then
    # prevent zprezto to modify path, c.f. https://github.com/sorin-ionescu/prezto/pull/1997
    ORIGINAL_PATH="\$PATH"
    . "$HOME/.zprezto/runcoms/zprofile"
    export PATH="\$ORIGINAL_PATH"
    unset ORIGINAL_PATH
fi
EOF
# .zshrc
cat << EOF > "$HOME/.zshrc"
[[ -s "$DIR/interactive" ]] && . "$DIR/interactive"
[[ -s "$HOME/.zprezto/runcoms/zshrc" ]] && . "$HOME/.zprezto/runcoms/zshrc"
EOF
# .zlogin
cat << EOF > "$HOME/.zlogin"
[[ -s "$HOME/.zprezto/runcoms/zlogin" ]] && . "$HOME/.zprezto/runcoms/zlogin"
EOF
# .zlogout
cat << EOF > "$HOME/.zlogout"
[[ -s "$HOME/.zprezto/runcoms/zlogout" ]] && . "$HOME/.zprezto/runcoms/zlogout"
EOF
