#!/usr/bin/env bash

config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/conda"
mkdir -p "$config_dir"

rm -f "$config_dir/.condarc"
cat << EOF > "$config_dir/.condarc"
channels:
    - conda-forge
    - defaults
channel_priority: strict
allow_softlinks: False
create_default_packages:
    # - mamba
    - pip
default_threads: $(getconf _NPROCESSORS_ONLN 2>/dev/null || getconf NPROCESSORS_ONLN 2>/dev/null || echo 1)
EOF
