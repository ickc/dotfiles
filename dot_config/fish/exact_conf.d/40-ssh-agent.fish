# ssh-agent bootstrap — fish port of auto_ssh_agent() in ~/.config/sh/rc.sh.
# All three shells compute the same socket path, so they converge on one agent
# per host with no state file to share, parse, or race on. Keys load on first
# use via `AddKeysToAgent yes` (~/.ssh/config), so nothing here prompts.

function __ssh_agent_start --description 'point SSH_AUTH_SOCK at a live agent'
    # An inherited agent that answers wins — forwarded, launchd, systemd. Only
    # status 2 means nothing is reachable.
    ssh-add -l >/dev/null 2>&1
    test $status -ne 2; and return 0

    # Keep in sync with auto_ssh_agent() in ~/.config/sh/rc.sh.
    set -l dir /tmp
    if test -n "$XDG_RUNTIME_DIR"
        set dir $XDG_RUNTIME_DIR
    else if test -n "$TMPDIR"
        set dir $TMPDIR
    end
    set -l sock (string trim --right --chars=/ -- $dir)/ssh-agent-(id -u).sock
    # sun_path caps a socket path at ~108 bytes; fall back if TMPDIR is long.
    if test (string length -- $sock) -gt 100
        set sock /tmp/ssh-agent-(id -u).sock
    end
    set -gx SSH_AUTH_SOCK $sock

    ssh-add -l >/dev/null 2>&1
    test $status -ne 2; and return 0

    # Nothing listening: clear the stale socket (ssh-agent removes its own on
    # exit) and start one. SSH_AGENT_PID is left unset on purpose — only
    # `ssh-agent -k` reads it, and it would kill the host's shared agent.
    rm -f $sock
    ssh-agent -s -a $sock >/dev/null 2>&1
end

if status is-interactive; and type -q ssh-agent
    __ssh_agent_start
end
