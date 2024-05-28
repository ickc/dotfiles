#!/usr/bin/env bash

DEFAULT_THREADS="$(getconf _NPROCESSORS_ONLN 2> /dev/null || getconf NPROCESSORS_ONLN 2> /dev/null || echo 1)"
export DEFAULT_THREADS

while IFS= read -r line; do
    eval echo "\"$line\""
done < condarc.yml > .condarc
