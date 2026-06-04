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

# shellcheck source=.zshenv
[[ -e "${HOME}/.zshenv" ]] && . "${HOME}/.zshenv"
if [[ $- == *i* ]]; then
    # Source global definitions (Some distro such as RHEL has this in the default ~/.bashrc)
    if [[ -f /etc/bashrc ]]; then
        . /etc/bashrc
    fi
    # shellcheck source=.zshrc
    [[ -e "${HOME}/.zshrc" ]] && . "${HOME}/.zshrc"

    # Set up ssh-agent
    if command -v ssh-agent > /dev/null; then
        auto_ssh_agent
    fi
fi
