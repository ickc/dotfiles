# ssh-agent bootstrap — fish port of auto_ssh_agent() in ~/.config/sh/rc.sh.
# Shares the same ~/.ssh-agent file as bash/zsh: ssh-agent writes Bourne syntax
# (`-s`), which bash/zsh source directly and fish parses via sed, so all three
# shells reuse a single agent.

function __ssh_agent_load --argument-names f --description 'load sh-syntax agent env into fish'
    sed -nE 's/^(SSH_[A-Z_]+)=([^;]+);.*/set -gx \1 \2/p' $f | source
end

function __ssh_agent_start --description 'start ssh-agent if none reachable, then load the key'
    set -l ssh_env $HOME/.ssh-agent

    ssh-add -l >/dev/null 2>&1
    if test $status -eq 2
        # no reachable agent: try the stored connection info first
        test -r $ssh_env; and __ssh_agent_load $ssh_env
        ssh-add -l >/dev/null 2>&1
        if test $status -eq 2
            # stored agent is dead/absent: start a fresh one
            ssh-agent -s >$ssh_env
            chmod 600 $ssh_env
            __ssh_agent_load $ssh_env
        end
    end
    # agent reachable but holds no identities: add the default key
    ssh-add -l >/dev/null 2>&1
    if test $status -eq 1
        ssh-add $HOME/.ssh/id_ed25519 2>/dev/null; or ssh-add 2>/dev/null
    end
end

if status is-interactive; and type -q ssh-agent
    __ssh_agent_start
end
