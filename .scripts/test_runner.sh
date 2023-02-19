
DEFAULT_LANDER_HOME_FOR_TESTING="$(pwd -P)/tmp/lander"

DEFAULT_TEST_REPORT_PATH="report/results_junit.xml"
TEST_REPORT_PATH=${TEST_REPORT_PATH:-$DEFAULT_TEST_REPORT_PATH}

function install_lz {
    cp "${HOME}/.bashrc" "${HOME}/.bashrc.bak"

    LANDER_HOME="${LANDER_HOME:-$DEFAULT_LANDER_HOME_FOR_TESTING}" \
    BASE_URL="${BASE_URL}" \
    SKIP_CA_UPDATE="${SKIP_CA_UPDATE:-1}" \
    ./install.sh
}

function cleanup {
    read user_continue
    rm -rf ./tmp
    cp "${HOME}/.bashrc.bak" "${HOME}/.bashrc"
    rm "${HOME}/.bashrc.bak"
}

function run_tests {
    shellspec --shell /bin/bash --jobs 1 --format documentation --output junit
}

function adjust_report {
    local adjusted_report="cleaned_report.xml"
    cat "${TEST_REPORT_PATH}" | sed -E 's/classname/file/g' > $adjusted_report
    mv -vf "$adjusted_report" "${TEST_REPORT_PATH}"
    # cat "${TEST_REPORT_PATH}"
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
    adjust_report
    cleanup
}
main "${@}"