#!/usr/bin/env bash

# Prompt for a LANDER_HOME directory (default ~/.lndr)
# curl down the bin/ and res/ directories to $LANDER_HOME/
# append an export to the user's ~/.bashrc to establish the LANDER_HOME env var
# smoke test the installation. ... somehow?

BASE_URL="https://gitlab.com/mattwiley/lz/-/raw/main/"

function download_component {
    curl -sSL "${BASE_URL}/${1}" -o "${lander_home}/${1}"
}

function main {
    


    local lander_home="./.local/.lndr"

    echo -n "Where you you like to install LZ? (Default: ${lander_home}): "
    read -r user_lander_home_dir

    lander_home=${user_lander_home_dir:-$lander_home}

    mkdir -p "${lander_home}/bin" "${lander_home}/res"

    download_component "res/master.lz"

}
main "${@}"
