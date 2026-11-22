#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Idempotent:
# - Install kind.
# - Create kind cluster configured for Ingress and having mount of host PWD. 
# - Install kubectl, preferably of kind's K8s-server version.
# - Apply ingress-nginx Ingress Controller configured for kind cluster.
# - Apply E2E test of Ingress/App
# -----------------------------------------------------------------------------
[[ $(type -t docker) ]] || { echo '  REQUIREs: docker'; exit 1; }

unset arch
[[ $(uname -m) == x86_64 ]]  && arch=amd64
[[ $(uname -m) == aarch64 ]] && arch=arm64
kindconf=kind-config-ingress-nginx.yaml
ingress=ingress-nginx-kind.yaml
usage=ingress-nginx-kind-usage.yaml

# Install latest else $v : https://github.com/kubernetes-sigs/kind/releases
type -t jq &&
    v="$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest |jq -Mr .tag_name)"
[[ $v ]] || v=0.24.0
v=${v/v/}
to=/usr/local/bin/kind
type -t kind && kind --version |grep $v || {
    [[ $arch ]] && { 
        sudo curl -sSLo $to https://kind.sigs.k8s.io/dl/v$v/kind-linux-$arch ||
            sudo curl -sSLo $to https://kind.sigs.k8s.io/dl/latest/kind-linux-$arch && 
                sudo chmod +x $to && 
                    kind --version |grep $v ||
                        exit 11
    }
}

# K8s API-server version and release cycle differ from those of kind.
k8sVer(){ 
    v="$(docker container ps --format "{{.Image}}" |grep kindest |cut -d':' -f2)"
    [[ $v ]] && echo "$v" || return 1
}

# https://kind.sigs.k8s.io/docs/user/configuration/#extra-mounts
k8sVer || kind create cluster --config $kindconf || exit 22

# Prefer client version that of kind's K8s server, else latest
k8sVer && ver=$(k8sVer) || exit 33
type -t kubectl && kubectl version --client=true |grep Client |grep $ver || {
    src=kubernetes/client/bin
    rm -rf $src
    to=/usr/local/bin
    tarball=kubernetes-client-linux-$arch.tar.gz
    [[ $arch ]] && 
    wget -nv https://dl.k8s.io/$ver/$tarball && 
    tar -xaf $tarball && 
    sudo cp $src/* $to/
    rm -rf kubernetes $tarball
    kubectl version --client=true || {
        rm -f kubectl
        k8s=https://storage.googleapis.com/kubernetes-release/release
        v=$(curl -s $k8s/stable.txt) &&
        curl -LO $k8s/$v/bin/linux/$arch/kubectl &&
        chmod +x kubectl &&
        sudo install kubectl $to/ &&
        kubectl version --client=true || exit 44
        rm -f kubectl
    }
}

# ingress-nginx : kind-specific deployment manifest
url=https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
[[ $(kubectl -n ingress-nginx get pod 2>/dev/null |grep ingress-nginx-controller) ]] ||
    kubectl apply -f $ingress ||
        kubectl apply -f $url &&
            kubectl wait -n ingress-nginx \
                --for=condition=ready pod \
                --selector=app.kubernetes.io/component=controller \
                --timeout=90s

# See ingress-nginx-kind-usage.yaml
e2e(){
    [[ $(kubectl -n stack-test get pod -l app=foo 2>/dev/null) ]] ||
        kubectl config set-context --current --namespace stack-test
    
    kubectl apply -f $usage
    for pod in foo bar;do 
        kubectl wait -n stack-test \
            --for=condition=ready pod \
            --selector=app=$pod \
            --timeout=90s 
    done 
    for pod in foo bar;do 
        [[ $(kubectl -n stack-test get pod -l app=$pod 2>/dev/null) ]] || {
            echo "Pod $pod not ready. Wait a bit and try again."
            return 1
        }
    done

}
get(){
    node_ip=$(kubectl get node kind-control-plane -o jsonpath='{.status.addresses[0].address}')
    curl -s $node_ip/foo/hostname &&
        curl -s $node_ip/bar/hostname
}
export -f get 

echo '=== E2E connectivity test : Ingress/Service/Pod/container'
e2e 
echo "  Want: foobar"
seq 10 |xargs -n1 /bin/bash -c ' 
    echo "  Got : $1"
    [[ $1 != foobar ]] && sleep 5 
' _ $(get) 

[[ $1 && $1 != 'teardown' ]] && {
    kubectl get pod -A
    type -t docker &&
    docker exec -it kind-control-plane /bin/bash -c '
        crictl images
        crictl pods
        touch /mnt/host/foo-from_$(hostname)_$(date '+%Y-%m-%dT%H.%M.%S-%Z')
        chown 1000:1000 /mnt/host/foo-*
        ls -hlnrt /mnt/host
    '
}

exit 0
######
