# stopsudo — stop the background sudo refresher started by startsudo.
# fish port of stopsudo() in ~/.config/sh/rc.sh.
function stopsudo --description 'stop the background sudo refresher from startsudo'
    set -q __sudo_pid; and kill $__sudo_pid 2>/dev/null
    set -e __sudo_pid
    functions -q __sudo_trap; and functions -e __sudo_trap
    sudo -k
end
