#!/usr/bin/env bash
# -----------------------------------------------------------------------------
#  Minikube : Install + Start (idempotent)
# -----------------------------------------------------------------------------
[[ -d /usr/local/bin ]] || sudo mkdir -p /usr/local/bin/ || exit 11

# Install Minikube
minikube version || {
    rm -f minikube
    release=https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    curl -Lo minikube $release &&
    chmod +x minikube &&
    sudo install minikube /usr/local/bin/ &&
    minikube version || exit 1
    rm -f minikube-linux-amd64
}

# Install client
kubectl version --client=true || {
    rm -f kubectl
    k8s=https://storage.googleapis.com/kubernetes-release/release
    v=$(curl -s $k8s/stable.txt) &&
    curl -LO $k8s/$v/bin/linux/amd64/kubectl &&
    chmod +x kubectl &&
    sudo install kubectl /usr/local/bin/ &&
    kubectl version --client=true || exit 2
    rm -f kubectl
}

# Start Minikube
docker version && minikube status || { 
    minikube start --driver=docker --mount=true --mount-string="$(pwd):/mnt/host" || exit 3
}
