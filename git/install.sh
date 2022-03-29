#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "${XDG_CONFIG_HOME:-${HOME}/.config}/git"
ln -sf "$DIR/ignore" "${XDG_CONFIG_HOME:-${HOME}/.config}/git"
