#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
ln -sf "$(pwd)" "$XDG_CONFIG_HOME"
