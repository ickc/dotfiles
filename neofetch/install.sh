#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "${XDG_CONFIG_HOME:-${HOME}/.config}/neofetch/"
rm -f "${XDG_CONFIG_HOME:-${HOME}/.config}/neofetch/config.conf"
ln -sf "$DIR/config.conf" "${XDG_CONFIG_HOME:-${HOME}/.config}/neofetch/"
