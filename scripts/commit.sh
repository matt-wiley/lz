#!/usr/bin/env bash

./scripts/assemble.sh
git add .
git commit -m "$1"