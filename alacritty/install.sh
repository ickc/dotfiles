#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "${XDG_CONFIG_HOME:-${HOME}/.config}/alacritty"
ln -sf "$DIR/alacritty.toml" "${XDG_CONFIG_HOME:-${HOME}/.config}/alacritty"
