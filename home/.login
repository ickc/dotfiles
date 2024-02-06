if ( "`uname -s`" == Linux ) then
  setenv SHELL "$HOME/.local/bin/zsh"
  [[ -e "$SHELL" ]] && exec "$SHELL" -l
endif
