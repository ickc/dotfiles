#!/usr/bin/env bash

auto_ssh_agent() {
    # modified from https://github.com/zimfw/ssh/blob/master/init.zsh

    # Check if ssh-agent is already running
    ssh-add -l &> /dev/null
    if [[ $? -eq 2 ]]; then
        # Unable to contact the authentication agent

        # Load stored agent connection info
        ssh_env="${HOME}/.ssh-agent"
        if [[ ! -r ${ssh_env} ]]; then
            # Start agent and store agent connection info
            (
                umask 066
                ssh-agent > "${ssh_env}"
            )
        fi
        # shellcheck disable=SC1090
        . "${ssh_env}" > /dev/null

        # there's a chance that the stored process has been killed
        ssh-add -l &> /dev/null
        if [[ $? -eq 2 ]]; then
            # generate a new one
            (
                umask 066
                ssh-agent > "${ssh_env}"
            )
            # shellcheck disable=SC1090
            . "${ssh_env}" > /dev/null
        fi
    fi
    # Load identities
    ssh-add -l &> /dev/null
    if [[ $? -eq 1 ]]; then
        ssh-add 2> /dev/null
    fi
}

# shellcheck source=config/zsh/.zshenv
[[ -e "${HOME}/.config/zsh/.zshenv" ]] && . "${HOME}/.config/zsh/.zshenv"
if [[ $- == *i* ]]; then
    # if $0 is -bash, then it means I cannot chsh to zsh, so we start zsh manually
    if [[ $0 == -bash && ${__PREFERRED_SHELL} == zsh ]]; then
        # shellcheck disable=SC1091
        [[ -e "${HOME}/.config/zsh/.zshrc" ]] && . "${HOME}/.config/zsh/.zshrc" > /dev/null 2>&1
        if _SHELL="$(command -v zsh)"; then
            export SHELL="${_SHELL}"
            exec "${SHELL}" -l
        fi
    # otherwise, it means I start bash deliberately, so we stay in bash
    else
        # Source global definitions (Some distro such as RHEL has this in the default ~/.bashrc)
        if [ -f /etc/bashrc ]; then
            . /etc/bashrc
        fi
        # shellcheck disable=SC1091
        [[ -e "${HOME}/.config/zsh/.zshrc" ]] && . "${HOME}/.config/zsh/.zshrc"

        # Set up ssh-agent
        if command -v ssh-agent > /dev/null; then
            auto_ssh_agent
        fi
    fi
fi
