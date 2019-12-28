# zone loader
if [[ -n "$ZONE" ]]
then 
    zoneLink="${LANDER_HOME}/zones/${ZONE}"
    if [[ -f "${zoneLink}" ]]
    then
        source "${zoneLink}"
    else
        echo "No zone for \"${ZONE}\" is registered."
        exit 1
    fi
fi

# default alias
alias lz=lndr

# completion function
function _lndr {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $( compgen -W "$( lndr list )" -- $cur ) )
}

# attach the completion function to the command and the default alias
complete -F _lndr lndr
complete -F _lndr lz