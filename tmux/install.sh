#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "${XDG_CONFIG_HOME:-${HOME}/.config}/tmux"
ln -sf "$DIR/tmux.conf" "${XDG_CONFIG_HOME:-${HOME}/.config}/tmux"
