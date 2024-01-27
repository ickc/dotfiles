#!/usr/bin/env bash

CONDA_CONFIG_DIR="$XDG_CONFIG_HOME/conda"
rm -f "$CONDA_CONFIG_DIR/.condarc"
rmdir "$CONDA_CONFIG_DIR" 2> /dev/null || true
