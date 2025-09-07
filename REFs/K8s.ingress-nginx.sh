#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Idempotent:
# - Apply ingress-nginx Ingress Controller configured for kind cluster.
# - Apply E2E test of Ingress/App
#
# ARGs: FUNCTION  MANIFEST
# -----------------------------------------------------------------------------
manifest=${2:-ingress-nginx-baremetal-v1.12.0.yaml}
usage=ingress-nginx-usage.yaml
v=v1.12.0
url=https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-$v/deploy/static/provider/baremetal/deploy.yaml

_download(){
    [[ -r $manifest ]] && return 200 ||
        curl -fsSL $url -o $manifest || return $?
    
    return 0
}
export -f _download
update(){
    _download && return 400 #... else install/update

    # Install/update from (edited) manifest else of url 
    [[ -r $manifest ]] && kubectl apply -f $manifest || {
        [[ $url ]] && kubectl apply -f $url
    } &&
        kubectl wait -n ingress-nginx \
            --for=condition=ready pod \
            --selector=app.kubernetes.io/component=controller \
            --timeout=90s
}
e2e(){
    _e2e(){
        # See ingress-nginx-kind-usage.yaml
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
        # Each control node is a cluster endpoint, so find first:
        ip=$(kubectl get node -o jsonpath='{.items[0].status.addresses[*].address}' \
                |cut -d' ' -f1
        )
        # Each service (http/https) port is wired to a nodePort (@ baremetal settings), 
        # so get NodePort of HTTP svc:
        p=$(kubectl get -n ingress-nginx svc ingress-nginx-controller \
                -o jsonpath='{.spec.ports[?(@.name=="'http'")].nodePort}'
        )
        # Concat response bodies:
        curl -s http://$ip:$p/foo/hostname &&
            curl -s http://$ip:$p/bar/hostname #> foobar
    }
    export -f get 
    echo '=== E2E connectivity test : Ingress/Service/Pod/container'
    _e2e || return 503
    echo "  Want: foobar"
    seq 10 |xargs -n1 /bin/bash -c ' 
        got="$(get)"
        echo "  Got : $got"
        [[ $got == foobar ]] && exit 0 || sleep 5 
    ' _ || return 404
}
teardown(){

    kubectl delete -f $usage
    kubectl delete -f $manifest || kubectl delete -f $url
    kubectl get $all,validatingwebhookconfigurations,clusterrole,clusterrolebinding |grep -- -nginx
}

pushd ${BASH_SOURCE%/*} 2>/dev/null || push . || exit 
"$@"
popd