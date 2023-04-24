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

# .zshenv
cat << EOF > "$HOME/.zshenv"
[[ -s "$DIR/env" ]] && . "$DIR/env"
[[ -s "$DIR/.env" ]] && . "$DIR/.env"
EOF

# .zprofile
rm -f "$HOME/.zprofile"
# .zshrc
cat << EOF > "$HOME/.zshrc"
[[ -s '$DIR/interactive' ]] && . '$DIR/interactive'

# Install missing modules, and update \${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! "\${ZIM_HOME}/init.zsh" -nt "\${ZDOTDIR:-\${HOME}}/.zimrc" ]]; then
  source "\${ZIM_HOME}/zimfw.zsh" init -q
fi

# ssh
zstyle ':zim:ssh' ids id_ed25519
# zsh-users/zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Initialize modules.
source "\${ZIM_HOME}/init.zsh"
EOF
# .zlogin
rm -f "$HOME/.zlogin"
# .zlogout
rm -f "$HOME/.zlogout"
