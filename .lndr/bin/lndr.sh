#!/usr/bin/env bash

if [[ -z "${LANDER_HOME}" ]]
then
    echo "LANDER_HOME is not set."
    exit 1
fi

# if [[ -z "$1" ]]
# then
#     echo "No zone provided."
#     exit 1
# fi

ZONE_FORMAT_STRING="%-15s | %-20s | %s\n"

function loadZone {
    # check is a zone is loaded first, only load if not already in a zone
    if [[ -z "$ZONE" ]]; then
        export ZONE=$1
        bash
    else
        echo "Already in zone \"${ZONE}\"."

        name=$(grep -e "#lz.name " "${ZONE_ROOT}/.lz" | sed 's/\#lz\.name //')
        desc=$(grep -e "#lz.desc " "${ZONE_ROOT}/.lz" | sed 's/\#lz\.desc //')

        echo ""
        formatString="${ZONE_FORMAT_STRING}"
        printf "${formatString}" "Zone ID"         "Zone Name"            "Zone Description"
        printf "${formatString}" "---------------" "--------------------" "--------------------"
        printf "${formatString}" "${ZONE}" "${name}" "${desc}"
        echo ""

        echo "Exit this shell to load a new zone."
    fi
}

function listZones {
    case "$1" in 
        "-l"|"--long")
            echo ""
            formatString="${ZONE_FORMAT_STRING}"

            printf "${formatString}" "Zone ID"         "Zone Name"            "Zone Description"
            printf "${formatString}" "---------------" "--------------------" "--------------------"
            for zone in $(ls ${LANDER_HOME}/zones); do 
                name=$(grep -e "#lz.name " "${LANDER_HOME}/zones/${zone}" | sed 's/\#lz\.name //')
                desc=$(grep -e "#lz.desc " "${LANDER_HOME}/zones/${zone}" | sed 's/\#lz\.desc //')
                printf "${formatString}" "${zone}" "${name}" "${desc}"
            done
            echo ""
            ;;
        *)
            echo "$(ls ${LANDER_HOME}/zones)"
            ;;
    esac
}

function createZone {
    zonePath=${1:-$(pwd)}
    echo ${zonePath}
    zoneDirname=`basename ${zonePath}`
    echo ${zoneDirname}
    cp ${LANDER_HOME}/bin/initial.lz ${zonePath}/.lz
    echo "" >> ${zonePath}/.lz
    echo "initZone ${zonePath}" >> ${zonePath}/.lz
    ln -s ${zonePath}/.lz ${LANDER_HOME}/zones/${zoneDirname}
}


case "$1" in 
    "new")
        shift
        createZone $@
        ;;
    "ls"|"list")
        shift
        listZones $@
        ;;
    *)
        loadZone $@
        ;;
esac



