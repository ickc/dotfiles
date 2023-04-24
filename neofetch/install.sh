#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "${HOME}/.config/neofetch/"
rm -f "${HOME}/.config/neofetch/config.conf"
ln -sf "$DIR/config.conf" "${HOME}/.config/neofetch/"
