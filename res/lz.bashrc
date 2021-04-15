#!/usr/bin/env bash

if [[ -f /etc/bash.bashrc ]]; then
    source /etc/bash.bashrc
fi
if [[ -f ~/.bashrc ]]; then
    # shellcheck disable=SC1090
    source ~/.bashrc
fi

#  Call the Lander Post Load Hook
#  
#   Note the ". " at the beginning of the line. This is important.
#   Without the ". " the posthook will drop to subshell and the posthook
#   changes will be lost to the subshell when the action completes.
#
# shellcheck disable=SC1090
. "${LANDER_HOME}/bin/lander.sh"  postload_hook "${ZONE}"
if [[ $? -gt 0 ]]; then 
    # The hook exited with an error, kill the shell here
    exit 1; 
fi