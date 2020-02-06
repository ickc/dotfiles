#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

[[ -n "$NERSC_HOST" ]] && EXT='.ext' || EXT=

# .bash_profile
case "$__HOST" in
    gordita|bolo|comet) echo "exec $(which zsh)" > "$HOME/.bash_profile$EXT" ;;
    *)                  : > "$HOME/.bash_profile$EXT"                        ;;
esac

cat << EOF >> "$HOME/.bash_profile$EXT"
[[ -s "$HOME/.bashrc$EXT" ]] && . "$HOME/.bashrc$EXT"
EOF

# .bashrc
cat << EOF > "$HOME/.bashrc$EXT"
[[ -s "$DIR/bin/env" ]] && . "$DIR/bin/env"
[[ -s "$DIR/bin/.env" ]] && . "$DIR/bin/.env"
[[ -s "$DIR/bin/interactive" ]] && . "$DIR/bin/interactive"
EOF

# assume zprezto always at ~/.zprezto

# .zshenv
cat << EOF > "$HOME/.zshenv$EXT"
[[ -s "$DIR/bin/env" ]] && . "$DIR/bin/env"
[[ -s "$DIR/bin/.env" ]] && . "$DIR/bin/.env"
[[ -s "$HOME/.zprezto/runcoms/zshenv" ]] && . "$HOME/.zprezto/runcoms/zshenv"
EOF

# .zprofile
cat << EOF > "$HOME/.zprofile$EXT"
[[ -s "$HOME/.zprezto/runcoms/zprofile" ]] && . "$HOME/.zprezto/runcoms/zprofile"
EOF
# .zshrc
cat << EOF > "$HOME/.zshrc$EXT"
[[ -s "$DIR/bin/interactive" ]] && . "$DIR/bin/interactive"
EOF
# only inserted in this order works
# c.f. https://github.com/sorin-ionescu/prezto/issues/657#issuecomment-52546927
# c.f. https://github.com/ohmyzsh/ohmyzsh/issues/7246#issuecomment-427674055
case "$__HOST" in
    comet) echo "export FPATH=\"$HOME/.linuxbrew/share/zsh/site-functions:$HOME/.linuxbrew/share/zsh/functions:$FPATH\"" >> "$HOME/.zshrc$EXT" ;;
esac
cat << EOF >> "$HOME/.zshrc$EXT"
[[ -s "$HOME/.zprezto/runcoms/zshrc" ]] && . "$HOME/.zprezto/runcoms/zshrc"
EOF
# .zlogin
cat << EOF > "$HOME/.zlogin$EXT"
[[ -s "$HOME/.zprezto/runcoms/zlogin" ]] && . "$HOME/.zprezto/runcoms/zlogin"
EOF
# .zlogout
cat << EOF > "$HOME/.zlogout"
[[ -s "$HOME/.zprezto/runcoms/zlogout" ]] && . "$HOME/.zprezto/runcoms/zlogout"
EOF

# .zpreztorc
cat << EOF > "$HOME/.zpreztorc"
[[ -s "$HOME/.zprezto/runcoms/zpreztorc" ]] && . "$HOME/.zprezto/runcoms/zpreztorc"
# gordita's zsh is too old for this
case "\$__HOST" in
    gordita) :                                                   ;;
    *)       zstyle ':prezto:module:prompt' theme 'powerlevel10k';;
esac
EOF

# powerlevel10k
ln -sf "$DIR/.p10k.zsh" "$HOME"
