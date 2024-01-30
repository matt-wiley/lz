#!/usr/bin/env bash

function start_web_server {
    printf "\nStarting webserver ... "
    python3 -m http.server 8080 2>&1>/dev/null &
    printf "done.\n\n"
    sleep 1
}


function stop_web_server {
    printf "\nStopping webserver ... "
    kill ${1}
    printf "done.\n\n"
}


function main {
    start_web_server
    local server_pid=$(echo $!)
    printf " > webserver pid = ${server_pid}\n\n"
    make test
    stop_web_server $server_pid
}

main