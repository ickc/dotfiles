# Fish entry point.
#
# Fish auto-loads conf.d/*.fish (for every session, before this file) and
# functions/*.fish (lazily). bash/zsh are the reference (~/.config/sh/env.sh and
# rc.sh); this mirrors them, scope included: only the environment applies to
# every fish, and everything else guards with `status is-interactive` so that
# scripts cannot come to depend on prompt conveniences.
#
#   conf.d/00-env.fish        env vars (every session) ≈ sh/env.sh; sources
#                             envoy/env.fish for prefixes + XDG
#   conf.d/10-path.fish       personal prefixes on PATH; conda envs; Lmod
#   conf.d/20-tools.fish      title, starship/fzf/direnv/navi/sman hooks + greeting
#   conf.d/30-aliases.fish    ls -> lsd, etc. (≈ ml_lsd)
#   conf.d/40-ssh-agent.fish  ssh-agent bootstrap (same socket path as bash/zsh)
#
# Helper functions mirroring sh/rc.sh are autoloaded from functions/:
# conda-shell (on-demand conda/mamba hook), mkdir_xdg, startsudo/stopsudo.
#
# Fish ships autosuggestions, syntax highlighting and prefix history-search
# built in, so the zsh plugins.zsh line-editing stack needs no fish equivalent.
