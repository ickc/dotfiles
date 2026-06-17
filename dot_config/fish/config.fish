# Fish entry point.
#
# Fish auto-loads conf.d/*.fish (for every session, before this file) and
# functions/*.fish (lazily). The setup is split across conf.d so that env + PATH
# apply to non-interactive fish too, while interactive-only pieces guard with
# `status is-interactive`:
#
#   conf.d/00-env.fish        env vars; sources envoy/env.fish for prefixes + XDG
#   conf.d/10-path.fish       Homebrew + personal prefixes on PATH; conda envs; Lmod
#   conf.d/20-tools.fish      title, starship/fzf/direnv/navi/sman hooks + greeting
#   conf.d/30-aliases.fish    ls -> lsd, etc. (≈ ml_lsd)
#   conf.d/40-ssh-agent.fish  ssh-agent bootstrap (shares ~/.ssh-agent with bash/zsh)
#
# Helper functions mirroring sh/rc.sh are autoloaded from functions/:
# conda-shell (on-demand conda/mamba hook), mkdir_xdg, startsudo/stopsudo.
#
# Fish ships autosuggestions, syntax highlighting and prefix history-search
# built in, so the zsh plugins.zsh line-editing stack needs no fish equivalent.
