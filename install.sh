#!/usr/bin/env bash

# function curl { exit 1; }
# function brew { exit 1; }

TRUE=1
FALSE=0
LINUX="linux"
MACOS="macos"
DEFAULT_BASE_URL="https://raw.githubusercontent.com/matt-wiley/lz/main"


BASE_URL="${BASE_URL:-$DEFAULT_BASE_URL}"
SKIP_CA_UPDATE=${SKIP_CA_UPDATE:-$FALSE}

function bool {
    if [[ $1 -eq $TRUE ]]; then
        echo "true"
    else 
        if [[ $1 -eq $FALSE ]]; then 
            echo "false"
        else
            echo "unknown"
        fi
    fi
}

function determine_os {
    test -e /Library
    result=$(echo $?)
    if [[ $result -eq 0 ]]; then 
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
    test "$(which ${1})"
    echo $?
}


if [[ $(is_installed "sudo") -eq 1 ]]; then 
    function sudo {
        $@
    }
fi


if [[ ("${OS}" == "${MACOS}") || ("$(hostname -i)" =~ 172\.) ]]; then 
    function sudo {
        $@
    }
fi

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
            sudo apt-get --force-depends update
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

    if [[ "${OS}" == "$LINUX" && $SKIP_CA_UPDATE -eq $FALSE ]]; then
        # Ensure that the CA Certs are installed for curl downloads
        sudo apt-get update
        sudo apt-get install -yq ca-certificates
    fi
    ensure_dependencies_installed

    echo "LZ installation directory: ${lander_home}"

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
    sudo ln -sf  "${lander_home}/bin/lander.sh" /usr/local/bin/lndr
    sudo ln -sf "${lander_home}/bin/lander.sh" /usr/local/bin/lz
    echo " done."

    echo -n " > Exporting LANDER_HOME=${lander_home} into ${HOME}/.bashrc file ..."
    echo "export LANDER_HOME='${lander_home}'" >> ${HOME}/.bashrc
    echo " done."

    echo ""
    echo " All set!"
    echo ""
    echo " You'll need to either start a new shell or run 'source ${HOME}/.bashrc' to begin using LZ."
    echo ""
    echo " ----------------------------------------------------------------------"
    echo ""
}

echo "BASE_URL=${BASE_URL}"
echo "SKIP_CA_UPDATE=$(bool ${SKIP_CA_UPDATE})"

main "${@}"
