#!/usr/bin/env bash

for file in *.sh; do 
    if [[ "test_runner.sh" != "$file" ]]; then 
        bash -c "./${file}"
    fi
done