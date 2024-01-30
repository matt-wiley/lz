#!/usr/bin/env bash


function createZone {
    ZONE_NAME=$(basename "$(pwd)")
    if [[ -n "${1}" ]]; then
        ZONE_NAME="${1}"
    fi
    ZONE_CFG="$(pwd)/.lz"
    cp "${LANDER_HOME}/res/initial.lz" "${ZONE_CFG}"
    echo "" >> "${ZONE_CFG}"
    echo "initZone $(pwd)" >> "${ZONE_CFG}"
    ln -sf "${ZONE_CFG}" "${LANDER_HOME}/zones/${ZONE_NAME}" || true
}

function loadZone {

    if [[ -n "${ZONE}" ]]; then
        echo "Already in zone \"${ZONE}\"."
        echo "Exit this shell to load a new zone."
        return
    elif [[ -z "${1}" ]]; then
        if [[ -e "./.lz" ]]; then
            export ZONE="$(basename $(pwd))"
            bash --rcfile "${LANDER_HOME}/res/lz.bashrc" -i
        else
            echo "No zonefile found and no zone name provided."
            exit 1
        fi
    elif [[ -z "$ZONE" ]]; then
        # check if a zone is loaded first, only load if not already in a zone
        export ZONE=$1
        bash --rcfile "${LANDER_HOME}/res/lz.bashrc" -i
    else
      : # do nothinge
    fi
}

function postLoadZone {
    if [[ -n "$ZONE" ]]
    then 
        zoneLink="${LANDER_HOME}/zones/${ZONE}"
        if [[ -f "${zoneLink}" ]]; then
            # shellcheck disable=SC1090
            source "${zoneLink}"
        else
            echo "No zone for \"${ZONE}\" is registered."
            exit 1
        fi
    fi
}

function listZones {
    case "$1" in 
        "-l"|"--long")
            listings=$(find "${LANDER_HOME}/zones" -type l)
            COLUMN_WIDTH=15
            ZONE_TABLE_COLUMNS="Id|Name|Description"
            ZONE_COLUMN_DIVIDER="$(bash -c "printf '%.s-' {1..$COLUMN_WIDTH}")|"
            ZONE_TABLE_HEADER_DIVIDER="$(bash -c "printf '%.s${ZONE_COLUMN_DIVIDER}' {1..3}")"
            ZONE_TABLE="${ZONE_TABLE_COLUMNS}\n${ZONE_TABLE_HEADER_DIVIDER}\n"
            for listing in $listings; do
                id=$(basename "${listing}")
                name=$(grep -e "#lz.name " "${listing}" | sed 's/\#lz\.name //')
                if [[ "$name" = "Default name" ]]; then
                    name=''
                fi
                desc=$(grep -e "#lz.desc " "${listing}" | sed 's/\#lz\.desc //')
                if [[ "$desc" == "Default description" ]]; then
                    desc=''
                fi
                ZONE_TABLE="${ZONE_TABLE}${id}|${name}|${desc}\n"
            done
            printf "\n"
            printf "$ZONE_TABLE" | awk -F'|' "{ printf(\"%-${COLUMN_WIDTH}s %-${COLUMN_WIDTH}s %s\n\""', $1, $2, $3) }'
            printf "\n"
            ;;
        *)
            # find "${LANDER_HOME}/zones" -type l -exec basename {} \;
            ls -la "${LANDER_HOME}/zones" | grep -E "^l" | sed -E "s/^l.*[0-9]{2}:?[0-9]{2} //" | sed -E "s/ ->.*$//"
            ;;
    esac
}

function deleteZone {
    local TRUE=1
    local FALSE=0

    DELETE_FILE=$FALSE

    while getopts "f" option; do
        case $option in
            "f")
            DELETE_FILE=$TRUE
            ;;
            *)
            ;;
        esac
    done

    SHOULD_CONTINUE="n"
    USER_ANSWERED=$FALSE
    while [[ $USER_ANSWERED -eq $FALSE ]]; do
        printf "\n"
        if [[ $DELETE_FILE -eq $TRUE ]]; then
            printf "This action will remove this this zone from the registry and delete the config file it points to.\n"
            printf "Are you sure you want to continue? (y/n): "
            read -r SHOULD_CONTINUE
        else
            printf "This action will remove this this zone from the registry.\n"
            printf "This config file it points to will NOT be deleted.\n"
            printf "Are you sure you want to continue? (y/n): "
            read -r SHOULD_CONTINUE
        fi

        if [[ ! "$SHOULD_CONTINUE" =~ ^(y|n)$ ]]; then
            printf "Please enter a 'y' or and 'n'. Try Again.\n"
            continue
        else
            USER_ANSWERED=$TRUE
        fi
    done


    if [[ "$SHOULD_CONTINUE" = "y" ]]; then
        printf "Delete requested.\n"

        ZONE_NAME=$(basename "$(pwd)")
        if [[ $DELETE_FILE -eq $TRUE ]]; then
            if [[ -n "${2}" ]]; then
                ZONE_NAME="${2}"
            fi
        else
            if [[ -n "${1}" ]]; then
                ZONE_NAME="${1}"
            fi
        fi

        foundZone=$(basename "$(find ${LANDER_HOME}/zones -type l -name ${ZONE_NAME})")
        if [[ ! "$foundZone" = "$ZONE_NAME" ]]; then
            echo "No zone for \"${ZONE_NAME}\" is registered."
            exit 1
        fi

        if [[ $DELETE_FILE -eq $TRUE ]]; then
            ZONE_CFG=$(ls -la "${LANDER_HOME}/zones/${ZONE_NAME}" | awk -F ' ' '{ print $NF }')
            directory=$(dirname $ZONE_CFG)
            rm -f "${directory}/.lz"
            # Remove the zone link itself and any alias symlinks that are now broken
            find "${LANDER_HOME}/zones" -xtype l -delete
        else
            # Remove the zone link itself
            rm -f "${LANDER_HOME}/zones/${ZONE_NAME}"
            # Delete any alias symlinks that are now broken
            find "${LANDER_HOME}/zones" -xtype l -delete
        fi
        
    else
        printf "Aborting delete.\n"
    fi

}


function pruneZones {
    #
    # Removes all zones with bad path links
    #
    local back="$(pwd)"
    cd "${LANDER_HOME}/zones"

    pre_prune_count=$(ls | wc -l | grep -oE "[0-9]+")
    echo $pre_prune_count

    listings=$(find . -type l)
    for listing in $listings; do
        total_count=$(($total_count+1))
        if $(cat "${listing}" 1>/dev/null); then
            echo -n ""
        else
            rm "${listing}"
            echo -n ""
        fi
    done 

    post_prune_count=$(ls | wc -l | grep -oE "[0-9]+")
    echo $post_prune_count
}


function backupAllZones {

    OS="Linux"
    
    here="$(pwd)"
    cd ${HOME}
    home_path=$(pwd)
    if [[ "${home_path}" =~ /Users ]]; then
        OS="Mac"
    fi
    cd "$back"

    backup_dir="${LANDER_HOME}/backup"
    backup_file="${backup_dir}/$(hostname)"
    mkdir -p "${backup_dir}"
    echo -n "" > "${backup_file}"
    listings=$(find "${LANDER_HOME}/zones" -type l)
    for listing in $listings; do
        zone_id=$(basename "${listing}")
        zone_root=$(dirname "$(ls -la ${listing} | awk '{print $NF}')")
        if [[ "${OS}" = "Linux" ]]; then
            lz_content=$(gzip -c "${listing}" | base64 -w0 -) 
        elif [[ "${OS}" = "Mac" ]]; then
            lz_content=$(gzip -c "${listing}" | base64 -) 
        fi

        # gzip -c ${listing} | base64 -w0 -                             # Compresses and base64 encodes the lz file for storage
        # base64 -d ${lz_content} | gzip -d - > "${zone_root}/.lz"      # Restores the backup to the registered path 
        echo "${zone_id}|${zone_root}|${lz_content}" >> "${backup_file}"
    done 
    gzip "${backup_file}"
}

function main {
    subcommand="${1}"
    if [[ -z "${subcommand}" ]]; then
        subcommand="load"
    fi

    case "${subcommand}" in
        "new")
            shift;
            createZone "$@"
        ;;
        "load")
            shift;
            loadZone "$@"
        ;;
        "postload_hook")
            shift;
            postLoadZone "$@"
        ;;
        "list"|"ls")
            shift;
            listZones "$@"
        ;;
        "delete")
            shift;
            deleteZone "$@"
        ;;
        "prune")
            shift;
            pruneZones
        ;;
        "backup")
            shift;
            backupAllZones "$@"
        ;;
        *) # load
            main load "$@"
        ;;
    esac

    
}

if [[ -z "${LANDER_HOME}" ]]; then 
    echo "LANDER_HOME not set."
else
    main "$@"
fi
