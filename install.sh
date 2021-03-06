#!/usr/bin/env bash

# function curl { exit 1; }
# function brew { exit 1; }

LINUX="linux"
MACOS="macos"

BASE_URL="https://gitlab.com/mattwiley/lz/-/raw/main/"

function determine_os {
    if [[ "$(test -e /Library && echo yes)" == "yes" ]]; then 
        echo $MACOS
    else 
        echo $LINUX
    fi
}

function download {
    echo -n " > Installing ${1} ... "
    curl -fsSL "${BASE_URL}/${1}" -o "${lander_home}/${1}"
    echo "done."
}

function is_installed {
    local cmd_text="${1} --version"
    if [[ $(test "$($cmd_text)" && echo yes) == "yes" ]]; then
        echo 0
    else
        echo 1
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
        if [[ "${OS}" == "${LINUX}" ]]; then 
            sudo apt-get update
            sudo apt-get install -yq --no-install-recommends "${dependencies[@]}"
        else 
            if [[ "${OS}" == "${MACOS}" ]]; then 
                if [[ $(test -n "$(brew --version)" && echo yes) == "yes" ]]; then 
                    for dep in "${dependencies[@]}"; do
                        brew install "${dep}"
                    done 
                else 
                    echo ""
                    echo "Unable to install required dependencies."
                    echo "Detected MacOS and attempted to install dependencies via Homebrew."
                    echo "Homebrew was not detected."
                    echo "Please visit https://brew.sh to install Homebrew and continue installation."
                    echo ""
                    echo " ----------------------------------------------------------------------"
                    echo ""
                    exit 1
                fi 
            fi 
        fi 
    fi
}


function main {
    

    echo ""
    echo " ----------------------------------------------------------------------"
    echo "  Installing LZ "
    echo ""

    local OS=$(determine_os)

    local lander_home="${HOME}/.lndr"

    if [[ -z "${LANDER_HOME}" ]]; then 
        echo -n "Where would you like to install LZ? (Default: ${lander_home}): "
        read -r user_lander_home_dir
        lander_home=${user_lander_home_dir:-$lander_home}
    else
        lander_home="${LANDER_HOME}"
    fi

    if [[ "${OS}" == "$LINUX" ]]; then
        # Ensure that the CA Certs are installed for curl downloads
        apt-get update
        apt-get install -yq ca-certificates
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
    echo " done."

    echo -n " > Exporting LANDER_HOME=${lander_home} into ~/.bashrc file ..."
    echo "export LANDER_HOME='${lander_home}'" >> ~/.bashrc
    echo " done."

    echo ""
    echo " All set!"
    echo ""
    echo " You'll need to either start a new shell or run 'source ~/.bashrc' to begin using LZ."
    echo ""
    echo " ----------------------------------------------------------------------"
    echo ""
}
main "${@}"
