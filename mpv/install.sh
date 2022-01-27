#!/usr/bin/env bash

# usage ./mpv-install.sh [slow|fast]

# https://github.com/bloc97/Anime4K/blob/815b122284304e6e1e244a8cf6a160eeaa07040c/GLSL_Instructions.md
config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/mpv"
file1=mpv.conf
file2="input-$1.conf"
mkdir -p "$config_dir"
cp -f "$file1" "$config_dir/$file1"
cp -f "$file2" "$config_dir/input.conf"
