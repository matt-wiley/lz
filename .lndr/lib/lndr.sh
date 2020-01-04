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
        if [[ -n "$1" ]]; then
            export ZONE=$1
            bash
        else 
            echo "No zone id provided."
        fi
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
    
    TRUE=1
    FALSE=0

    zonePath=$(pwd)
    zoneDirname=`basename ${zonePath}`

    zoneId="${1}"
    if [[ -z "${zoneId}" ]]; then
        zoneId="${zoneDirname}"
    fi

    if [[ -e "${LANDER_HOME}/zones/${zoneId}" ]]; then
        echo "Zone ID \"${zoneId}\" is taken. Please use a different zone id."
        exit
    fi

    if [[ -e "${zonePath}/.lz" ]]; then
        echo "Zone file exists at path: ${zonePath}/.lz"
    else
        cp ${LANDER_HOME}/lib/initial.lz ${zonePath}/.lz
        echo "" >> ${zonePath}/.lz
        echo "initZone ${zonePath}" >> ${zonePath}/.lz
        echo "Created Zone File: ${zonePath}/.lz"
    fi

    ln -sf ${zonePath}/.lz ${LANDER_HOME}/zones/${zoneId}
    echo "Registered Zone ID: ${zoneId}"
    
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



