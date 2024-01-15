#!/usr/bin/env bash

CONDA_CONFIG_DIR="$XDG_CONFIG_HOME/conda"
mkdir -p "$CONDA_CONFIG_DIR"

DEFAULT_THREADS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || getconf NPROCESSORS_ONLN 2>/dev/null || echo 1)"

rm -f "$CONDA_CONFIG_DIR/.condarc"
while IFS= read -r line; do
  eval echo "\"$line\""
done <condarc.yml >"$CONDA_CONFIG_DIR/.condarc"
