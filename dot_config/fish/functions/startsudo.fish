# startsudo — keep the sudo timestamp fresh in the background until stopsudo.
# fish port of startsudo() in ~/.config/sh/rc.sh; `--on-signal` replaces the
# bash/zsh `trap`. c.f. https://stackoverflow.com/a/30547074/5769446
function startsudo --description 'refresh sudo in the background until stopsudo'
    sudo -v
    begin
        while true
            sudo -v
            sleep 50
        end
    end &
    set -g __sudo_pid $last_pid
    function __sudo_trap --on-signal INT --on-signal TERM
        stopsudo
    end
end
