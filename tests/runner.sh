#!/usr/bin/env bash

for file in *.sh; do 
    if [[ "runner.sh" != "$file" ]]; then 
        bash -c "./${file}"
    fi
done