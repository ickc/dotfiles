# ssh-agent bootstrap — fish port of auto_ssh_agent() in ~/.config/sh/rc.sh.
# All three shells compute the same socket path, so they converge on one agent
# per host with no state file to share, parse, or race on. Keys load on first
# use via `AddKeysToAgent yes` (~/.ssh/config), so nothing here prompts.

# True if $d is a directory we own with mode 0700, creating it if needed.
# Whatever answers on SSH_AUTH_SOCK is trusted implicitly — ssh hands it the
# decrypted key — so a predictable name straight in a world-writable /tmp is not
# safe: any local user can pre-bind it first and collect the key.
function __ssh_agent_dir_ok --argument-names d --description 'true if d is a 0700 directory we own'
    mkdir -p $d 2>/dev/null
    # Checked before the chmod so we never follow a symlink elsewhere.
    if not test -d $d; or test -L $d
        return 1
    end
    chmod 700 $d 2>/dev/null
    set -l info (stat -c '%u %a' $d 2>/dev/null; or stat -f '%u %Lp' $d 2>/dev/null)
    test "$info" = (id -u)" 700"
end

function __ssh_agent_start --description 'point SSH_AUTH_SOCK at a live agent'
    # An inherited agent that answers wins — forwarded, launchd, systemd. Only
    # status 2 means nothing is reachable.
    ssh-add -l >/dev/null 2>&1
    test $status -ne 2; and return 0

    # Keep in sync with auto_ssh_agent() in ~/.config/sh/rc.sh. An unset
    # variable makes its whole candidate vanish, so the list self-prunes.
    set -l uid (id -u)
    set -l sock
    for dir in $XDG_RUNTIME_DIR $TMPDIR/ssh-agent-$uid /tmp/ssh-agent-$uid
        set -l d (string trim --right --chars=/ -- $dir)
        set -l candidate $d/ssh-agent.sock
        # sun_path caps a socket path at ~108 bytes; /tmp is the short retry.
        if test (string length -- $candidate) -gt 100
            continue
        end
        if __ssh_agent_dir_ok $d
            set sock $candidate
            break
        end
    end
    # Nowhere private to put it: leave ssh to prompt per connection rather than
    # trust a socket anyone could have planted.
    test -n "$sock"; or return 0
    set -gx SSH_AUTH_SOCK $sock

    ssh-add -l >/dev/null 2>&1
    test $status -ne 2; and return 0

    # Nothing listening: clear the stale socket (ssh-agent removes its own on
    # exit) and start one. SSH_AGENT_PID is left unset on purpose — only
    # `ssh-agent -k` reads it, and it would kill the host's shared agent.
    rm -f -- $sock
    ssh-agent -s -a $sock >/dev/null 2>&1
end

if status is-interactive; and type -q ssh-agent
    __ssh_agent_start
end
