#!/usr/bin/env bash

# since __HOST is used, for those hosts this needed to be run twice
# first time to setup the env for __HOST
# log in again to run second time for this script to write correctly

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# .bash_profile
case "$__HOST" in
    datatran)
      echo 'SHELL="/global/u2/${USER:0:1}/$USER/.mambaforge/envs/system311-conda-forge/bin/zsh"; export SHELL; [[ -e "$SHELL" ]] && exec "$SHELL" -l' > "$HOME/.bash_profile"
      ;;
    gordita|bolo)
      echo '[[ "$HOSTNAME" == gordita* ]] && SHELL="$HOME/mambaforge/envs/system39-conda-forge/bin/zsh" || SHELL="$(which zsh)"; export SHELL; [[ -e "$SHELL" ]] && exec "$SHELL" -l' > "$HOME/.bash_profile"
      ;;
    centaurus|fornax)
      echo 'SHELL=/home/$USER/scratch/.local/share/conda/envs/system311-conda-forge/bin/zsh; export SHELL; [[ -e "$SHELL" ]] && exec "$SHELL" -l' > "$HOME/.bash_profile"
      ;;
    simons1)
      echo 'SHELL=/mnt/so1/users/$USER/.mambaforge/envs/system311-conda-forge/bin/zsh; export SHELL; [[ -e "$SHELL" ]] && exec "$SHELL" -l' > "$HOME/.bash_profile"
      ;;
    *)
      : > "$HOME/.bash_profile"
      ;;
esac

cat << EOF >> "$HOME/.bash_profile"
[[ -s "$DIR/env" ]] && . "$DIR/env"
[[ -s "$DIR/.env" ]] && . "$DIR/.env"
EOF

# .bashrc
# interactive is not put here because it causes some problems when launching zsh from bash
# as I don't really use bash interactively, it should be fine
cat << EOF > "$HOME/.bashrc"
[[ -s "$DIR/env" ]] && . "$DIR/env"
[[ -s "$DIR/.env" ]] && . "$DIR/.env"
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
bindkey "\$terminfo[kcuu1]" history-substring-search-up
bindkey "\$terminfo[kcud1]" history-substring-search-down

# Initialize modules.
source "\${ZIM_HOME}/init.zsh"
EOF
# .zlogin
rm -f "$HOME/.zlogin"
# .zlogout
rm -f "$HOME/.zlogout"

# .login for tcsh
case "$__HOST" in
    styx)
      cat << EOF > "$HOME/.login"
if ( "\`uname -s\`" == Linux ) then
  setenv SHELL "\$HOME/.local/bin/zsh"
  [[ -e "\$SHELL" ]] && exec "\$SHELL" -l
endif
EOF
      ;;
esac
