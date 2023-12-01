#!/usr/bin/env bash
# Delete cluster

#>>>  WIP  <<<

K8S_WORKER_NODES='a2 a3'
K8S_MASTER_NODES='a1'

master=$(echo $K8S_MASTER_NODES |cut -d' ' -f1)

ssh $master /bin/bash -s < delete-charts.sh

# Drain all nodes
opts='--delete-local-data --force --ignore-daemonsets'
[[ "$K8S_WORKER_NODES" ]] && {
    ssh $master printf '%s\\n' "$K8S_WORKER_NODES" \
        |xargs -I{} kubectl drain {}.local $opts
}
[[ "$K8S_MASTER_NODES" ]] && {
    ssh $master printf '%s\\n' "$K8S_MASTER_NODES" \
        |xargs -I{} kubectl drain {}.local $opts
}

ssh $master /bin/bash -s < delete-resources.sh

# Delete all nodes
[[ "$K8S_WORKER_NODES" ]] && {
    ssh $master printf "%s\\n" $K8S_WORKER_NODES \
        |xargs -I{} kubectl delete node {}.local 
}
[[ "$K8S_MASTER_NODES" ]] && {
    ssh $master printf "%s\\n" $K8S_MASTER_NODES \
        |xargs -I{} kubectl delete node {}.local
}

ssh $master /bin/bash -s < crictl-stop.sh

# Reset K8s client and server at every node
printf "%s\n" $K8S_WORKER_NODES $K8S_MASTER_NODES \
    |xargs -IX ssh X '
        rm $HOME/.kube/config
        sudo rm /etc/cni/net.d/*
        sudo kubeadm reset --force
    '

