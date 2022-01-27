#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ln -sf "$DIR/ignore" "${XDG_CONFIG_HOME:-${HOME}/.config}/git"
