#!/usr/bin/env bash

# Prompt for a LANDER_HOME directory (default ~/.lndr)
# curl down the bin/ and res/ directories to $LANDER_HOME/
# append an export to the user's ~/.bashrc to establish the LANDER_HOME env var
# smoke test the installation. ... somehow?

BASE_URL="https://gitlab.com/mattwiley/lz/-/raw/main/"

function download {
    echo -n " > Installing ${1} ... "
    # TODO Stop using the -k option. Get the Haxx Certs installed.
    curl -ksL "${BASE_URL}/${1}" -o "${lander_home}/${1}"
    echo "done."
}

function is_installed {
    local cmd_text="${1} -h"
    $cmd_text 2>/dev/null 1>/dev/null
    if [[ $? -gt 0 ]]; then
        echo 1
    else
        echo 0
    fi
}

function ensure_dependencies_installed {
    local dependencies=(
        "curl"
    )

    dependencies_met=$((0))
    for dep in "${dependencies[@]}"; do 
        echo -n " > Checking for ${dep} ... "
        dep_met=$(is_installed "${dep}")
        dependencies_met=$((dependencies_met+dep_met))
        echo "done. (${dep_met})"
    done

    if [[ $dependencies_met -gt 0 ]]; then 
        echo " > Installing missing dependencies. (${dependencies_met})"
        apt-get update
        apt-get install -yq --no-install-recommends "${dependencies[@]}"
    fi
}


function main {
    

    echo ""
    echo " ----------------------------------------------------------------------"
    echo "  Installing LZ "
    echo ""

    local lander_home="${HOME}/.lndr"

    if [[ -z "${LANDER_HOME}" ]]; then 
        echo -n "Where would you like to install LZ? (Default: ${lander_home}): "
        read -r user_lander_home_dir
        lander_home=${user_lander_home_dir:-$lander_home}
    else
        lander_home="${LANDER_HOME}"
    fi

    ensure_dependencies_installed

    mkdir -p \
        "${lander_home}/bin" \
        "${lander_home}/res" \
        "${lander_home}/zones"

    download "res/master.lz"
    download "res/initial.lz"
    download "res/lz.bashrc"
    download "res/bash_completion.sh"
    download "bin/lander.sh"

    echo -n " > Installing the cli ..."
    chmod +x "${lander_home}/bin/lander.sh"
    ln -sf  "${lander_home}/bin/lander.sh" /usr/local/bin/lndr
    ln -sf "${lander_home}/bin/lander.sh" /usr/local/bin/lz
    echo "done."

    echo -n " > Exporting LANDER_HOME=${lander_home} into ~/.bashrc file ..."
    echo "export LANDER_HOME='${lander_home}'" >> ~/.bashrc
    echo "done."

    echo ""
    echo " ----------------------------------------------------------------------"
    echo ""
}
main "${@}"
