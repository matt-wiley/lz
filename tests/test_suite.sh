#!/usr/bin/env bash

# TODO Should we reimplement these tests using shellspec? (https://github.com/shellspec/shellspec)

TEST_LANDER_HOME='/tmp/.lndr'
export LANDER_HOME=${TEST_LANDER_HOME}

function print_test_header {
    echo " ====================================================================== "
    echo ""
    echo " > ${1}"
    echo ""
}

function print_test_footer {
    echo ""
    echo " ====================================================================== "
    echo ""
}

function install_lz {
    echo -n "Running LZ installation ... "
    LANDER_HOME="${TEST_LANDER_HOME}" BASE_URL=http://host.docker.internal:8080 SKIP_CA_UPDATE=1 ../install.sh
    echo "done."
    echo ""
}

function uninstall_lz {
    rm -rf "${TEST_LANDER_HOME}"
    rm -f /usr/local/bin/lz
    rm -f /usr/local/bin/lndr
    echo "" > ~/.bashrc
}


function beforeTest {
    install_lz
}

function afterTest {
    uninstall_lz
}

function assert_equal {
    if [[ "${1}" != "${2}" ]]; then 
        printf "$RED [x] Assertion FAILED  | %s \n\tExpected: %s \n\t  Actual: %s\n" "${3}" "${1}" "${2} $CLEAR"
    else
        printf "$GREEN [ ] Assertion PASSED | \n\tExpected: %s \n\t  Actual: %s\n" "${1}" "${2} $CLEAR"
    fi
}


function test_cli_installed {
    beforeTest
    print_test_header "test_cli_commands_are_present"
    source ~/.bashrc

    assert_equal "${TEST_LANDER_HOME}" "${LANDER_HOME}"

    output=$(lz test)
    assert_equal "No zone for \"test\" is registered." "${output}" 

    output=$(lndr test)
    assert_equal "No zone for \"test\" is registered." "${output}" 

    print_test_footer
    afterTest
}


function test_lz_creates_new_zone {
    beforeTest
    print_test_header "test_lz_creates_new_zone"
    source ~/.bashrc

    local temp_dir="/tmp"
    local test_zone_dir="test_zone_dir"

    mkdir -p "${temp_dir}/${test_zone_dir}"

    cd "${temp_dir}/${test_zone_dir}"
    lz new
    cd ..

    expected_zone_link="${LANDER_HOME}/zones/${test_zone_dir}"
    test -e "${expected_zone_link}"
    assert_equal "0" "$?" "Zone with '${expected_zone_link}' was not found"

    afterTest
}


function main {
    test_cli_installed
    test_lz_creates_new_zone
    # TODO Add test for bash_completion.sh
}
main