#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TARGET="${XDG_CONFIG_HOME:-${HOME}/.config}/kitty"
rm -rf "$TARGET"
ln -sf "$DIR" "$TARGET"
