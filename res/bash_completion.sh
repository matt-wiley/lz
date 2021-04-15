# completion function
function _lndr {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $( compgen -W "$( lndr list )" -- $cur ) )
}

# attach the completion function to the command and the default alias
complete -F _lndr lndr
complete -F _lndr lz