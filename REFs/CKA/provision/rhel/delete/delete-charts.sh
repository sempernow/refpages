#!/usr/bin/env bash
# Run once at any control node

# Uninstall all Helm charts
echo "$(helm list -A |grep -v NAME)" \
    |xargs -IX /bin/bash -c 'helm delete $1 -n $2' _ X
