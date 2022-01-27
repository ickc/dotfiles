#!/usr/bin/env bash

# usage ./mpv-install.sh [slow|fast]

config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/mpv"
file1=mpv.conf
file2="input-$1.conf"
mkdir -p "$config_dir"
cp -f "$file1" "$config_dir/$file1"
cp -f "$file2" "$config_dir/input.conf"
