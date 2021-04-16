#!/usr/bin/env bash

function main {
    if [[ -n "${1}" ]] && [[ -n "${2}" ]]; then
        local user="${1}"
        local pass="${2}"
        mkdir -p .tmp
        cd .tmp
        git clone --bare "https://gitlab.com/mattwiley/lz.git"
        git checkout main
        git push --mirror "https://${user}:${pass}@github.com/matt-wiley/lz"
        cd ..
        rm -rf .tmp
    else 
        echo "A Github Username and Token must be provided in order to mirror."
    fi 
    
}
main "${@}"