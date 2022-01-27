#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/conda"
mkdir -p "$config_dir"
ln -sf "$DIR/.condarc" "$config_dir"
