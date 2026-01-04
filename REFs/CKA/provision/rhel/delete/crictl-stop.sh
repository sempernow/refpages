#!/usr/bin/env bash
# Run once at any control node

# Stop any remaining containers 
# (K8s core recurringly respawn)
[[ $(type -t crictl) ]] && {
    printf "%s\n" $(sudo crictl stats |cut -d' ' -f1 |grep -v CONTAINER) \
        |xargs -IX sudo crictl stop X

    sudo crictl stats
} 