#!/usr/bin/env bash

# streamlink: https://streamlink.github.io/cli.html#configuration-file
filename=config
if [[ "$(uname)" == Darwin ]]; then
	outdir="${HOME}/Library/Application Support/streamlink"
else
	outdir="${XDG_CONFIG_HOME:-${HOME}/.config}/streamlink"
fi
mkdir -p "$outdir"
cp -f "$filename" "$outdir"
