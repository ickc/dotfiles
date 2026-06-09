# Fish entry point.
#
# Fish auto-loads conf.d/*.fish (for every session, before this file) and
# functions/*.fish (lazily). The setup is split across conf.d so that env + PATH
# apply to non-interactive fish too, while interactive-only pieces guard with
# `status is-interactive`:
#
#   conf.d/00-env.fish        native port of ~/.config/sh/env.sh (env vars)
#   conf.d/10-path.fish       Homebrew detection + Lmod module load
#   conf.d/20-tools.fish      starship/fzf/direnv/navi/conda/sman hooks + greeting
#   conf.d/30-aliases.fish    ls -> lsd, etc. (≈ ml_lsd)
#   conf.d/40-ssh-agent.fish  ssh-agent bootstrap (shares ~/.ssh-agent with bash/zsh)
#
# Fish ships autosuggestions, syntax highlighting and prefix history-search
# built in, so the zsh plugins.zsh line-editing stack needs no fish equivalent.
