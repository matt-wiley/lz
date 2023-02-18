
function install_lz {
    cp "${HOME}/.bashrc" "${HOME}/.bashrc.bak"

    LANDER_HOME="${LANDER_HOME:-./tmp/lander}" \
    BASE_URL="${BASE_URL}" \
    SKIP_CA_UPDATE="${SKIP_CA_UPDATE:-1}" \
    ./install.sh
}

function cleanup {
    rm -rf ./tmp
    cp "${HOME}/.bashrc.bak" "${HOME}/.bashrc"
    rm "${HOME}/.bashrc.bak"
}

function run_tests {
    shellspec --jobs 1 -f t --output junit
}

function main {
    case "${1}" in 
        "docker")
            BASE_URL="http://host.docker.internal:8080"
            ;;
        *)
            ;;
    esac

    install_lz
    run_tests
    cleanup
}
main "${@}"