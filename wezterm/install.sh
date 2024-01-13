#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TARGET="${XDG_CONFIG_HOME:-${HOME}/.config}/wezterm"
rm -rf "$TARGET"
mkdir -p "$TARGET"
ln -sf "$DIR/wezterm.lua" "$TARGET"
