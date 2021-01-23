#!/usr/bin/env bash

# since __HOST is used, for those hosts this needed to be run twice
# first time to setup the env for __HOST
# log in again to run second time for this script to write correctly

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# .bash_profile
case "$__HOST" in
    gordita|bolo) echo '[[ "$__HOST" == gordita ]] && exec /opt/mambaforge/bin/zsh || exec zsh' > "$HOME/.bash_profile"          ;;
    comet)        echo "exec $(which zsh)" > "$HOME/.bash_profile" ;;
    *)            : > "$HOME/.bash_profile"                        ;;
esac

cat << EOF >> "$HOME/.bash_profile"
[[ -s "$DIR/bin/env" ]] && . "$DIR/bin/env"
[[ -s "$DIR/bin/.env" ]] && . "$DIR/bin/.env"
EOF

# .bashrc
cat << EOF > "$HOME/.bashrc"
[[ -s "$DIR/bin/env" ]] && . "$DIR/bin/env"
[[ -s "$DIR/bin/.env" ]] && . "$DIR/bin/.env"
[[ \$- == *i* && -s "$DIR/bin/interactive" ]] && . "$DIR/bin/interactive"
EOF

# assume zprezto always at ~/.zprezto

# .zshenv
cat << EOF > "$HOME/.zshenv"
[[ -s "$DIR/bin/env" ]] && . "$DIR/bin/env"
[[ -s "$DIR/bin/.env" ]] && . "$DIR/bin/.env"
[[ -s "$HOME/.zprezto/runcoms/zshenv" ]] && . "$HOME/.zprezto/runcoms/zshenv"
EOF

# .zprofile
cat << EOF > "$HOME/.zprofile"
[[ -s "$HOME/.zprezto/runcoms/zprofile" ]] && . "$HOME/.zprezto/runcoms/zprofile"
EOF
# .zshrc
cat << EOF > "$HOME/.zshrc"
[[ -s "$DIR/bin/interactive" ]] && . "$DIR/bin/interactive"
EOF
# only inserted in this order works
# c.f. https://github.com/sorin-ionescu/prezto/issues/657#issuecomment-52546927
# c.f. https://github.com/ohmyzsh/ohmyzsh/issues/7246#issuecomment-427674055
case "$__HOST" in
    comet) echo "export FPATH=\"$HOME/.linuxbrew/share/zsh/site-functions:$HOME/.linuxbrew/share/zsh/functions:$FPATH\"" >> "$HOME/.zshrc" ;;
esac
cat << EOF >> "$HOME/.zshrc"
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

# .zpreztorc
cat << EOF > "$HOME/.zpreztorc"
[[ -s "$HOME/.zprezto/runcoms/zpreztorc" ]] && . "$HOME/.zprezto/runcoms/zpreztorc"
zstyle ':prezto:module:prompt' theme 'powerlevel10k'
EOF

# powerlevel10k
ln -sf "$DIR/.p10k.zsh" "$HOME"
