if [[ -z ${BASHRC_SOURCED} ]]; then
    export BASHRC_SOURCED=1
    # shellcheck disable=SC1090
    . ~/.bashrc
fi
