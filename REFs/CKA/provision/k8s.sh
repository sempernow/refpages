# /etc/profile.d/k8s.sh
##################################################
# Configure bash shell for kubectl + minikube.
# source this script from /etc/profile.d/k8s.sh
##################################################
echo "@ ${BASH_SOURCE:-/etc/profile.d/k8s.sh}"

set -a # Export all

[[ $(type -t docker) ]] && {
    # Docker
    alias registry='echo "docker-ng-untrusted-group.northgrum.com"'

    # `docker image ...` does NOT produce valid JSON. This fixes that.
    alias dij='docker image ls --digests --format "{{json .}}" |jq -Mr . --slurp'
    # `di[t] --digests` okay too.
    alias di='docker image ls' 
    alias dit='docker image ls --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}"'
    alias dps='docker container ls'
    alias dpsa='docker container ls --all'
}

[[ $(type -t kubectl ) ]] && {
    # @ kubectl installed

    all='deploy,sts,rs,pod,ep,svc,ingress,cm,secret,pvc,pv'

    # kubectl completion
    set +o posix # Abide non-POSIX syntax 
    source <(kubectl completion bash)

    # k + completion
    alias k=kubectl
    complete -o default -F __start_kubectl k

    # kube-apiserver process : `psk` lists all options currently running 
    alias psk="echo '=== ps @ kube-apiserver';ps aux |grep kube-apiserver |tr ' ' '\n' |grep -- -- |grep -v color"

    # Get/Set kubectl namespace : Usage: kn [NAMESPACE]
    kn() { 
        [[ "$1" ]] && {
            kubectl config set-context --current --namespace $1
        } || {
            kubectl config view --minify |grep namespace |cut -d" " -f6
        }
    }
    
    # Get/Set kubectl context : Usage: kx [CONTEXT_NAME]
    kx() { 
        [[ "$1" ]] && {
            kubectl config use-context $1
        } || {
            #kubectl config current-context
            kubectl config get-contexts
        }
    }

    # Get/Set cluster's default StorageClass 
    # (minikube reverts to "standard" per `minikube start`)
    ksc(){
        [[ $1 ]] && {
            default=$(kubectl get sc |grep default |awk '{print $1}')
            [[ $default ]] && { 
                ## If current default exists, then unset it
                kubectl patch sc $default -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
            }
            ## Set default to $1
            kubectl patch sc $1 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
        }
        kubectl get sc
    }
}

[[ $(type -t minikube) ]] && {
    # @ minikube intalled

    # Minikube will not run on NFS, and requires ftype=1 if an XFS volume.
    export MINIKUBE_HOME=/opt/k8s/minikube
    export CHANGE_MINIKUBE_NONE_USER=true # Does nothing
    [[ -d $MINIKUBE_HOME ]] || {
        echo '=== MINIKUBE_HOME: path NOT EXIST.'
    }

    source <(minikube completion bash)
    
    # d2m : Configure host's Docker client (docker) to Minikube's Docker server.
    d2m(){ [[ $(echo $DOCKER_HOST) ]] || eval $(minikube -p minikube docker-env); }

    # Set proxy environment (make idempotent)
    #mini_netwk_addr=$(minikube node list |awk '{print $2}' |awk '{split($1,p,"."); $1=p[1]"."p[2]"."p[3]} 1')
    no_proxy_minikube="10.96.0.0/12,192.168.59.0/24,192.168.49.0/24,192.168.39.0/24"

    # Configure all the HTTP(S) proxy environment vars (once) 
    [[ $(echo "$NO_PROXY" |grep $no_proxy_minikube) ]] || {

        HTTP_PROXY="$http_proxy"
        HTTPS_PROXY="$https_proxy"

        no_proxy_core_static="localhost,127.0.0.1,192.168.0.0/16,172.16.0.0/16,.entds.ngisn.com,.edn.entds.ngisn.com,.dilmgmt.c4isrt.com,.dil.es.northgrum.com,.ms.northgrum.com,.es.northgrum.com,.northgrum.com"
        [[ $no_proxy ]] || no_proxy="$no_proxy_core_static"
        no_proxy_core="${no_proxy}"
        no_proxy_minikube="10.96.0.0/12,192.168.59.0/24,192.168.49.0/24,192.168.39.0/24"

        NO_PROXY="$no_proxy_core,$no_proxy_minikube"
        no_proxy="$NO_PROXY"
    }

    #echo "=== TEST : USER : '$USER'"

    # mperms : Reset all config.json file permissions 
    # that are recurringly misconfigured per `minikube start`.
    mperms(){ 
        [[ -d $MINIKUBE_HOME ]] && {
            find $MINIKUBE_HOME -type f -name 'config.json' \
                -exec sudo chmod 0664 {} \; 
        }
    }

    # Restart minikube if not running, and 
    # reset permissions on all /config.json if user is its owner.
    [[ $(minikube status -o json 2>/dev/null |jq -Mr .Host) != 'Running' ]] && {
        minikube start && [[ $USER == '4n52626' ]] && mperms
    }
    
    mdns() { 
        # TODO : Find a better method (Perhaps resolve @ /etc/hosts)
        # If Minikube's ingress-dns addon is enabled, 
        # then add Minikube's IP as a nameserver for this machine's DNS resolver (idempotently).
        # See manual page /etc/resolv.conf(5)
        [[ $(cat /etc/resolv.conf |grep $(minikube ip)) ]] || {
            [[ $(minikube addons list |grep ingress-dns) && $(minikube ip |grep 192.168) ]] && {
                printf "%s\n%s\n" "nameserver $(minikube ip)" "options rotate" \
                    |sudo tee -a /etc/resolv.conf
            }
        }
    }
}

# Helm : Save (.tar) all Docker-image dependencies of a chart 
# using three helper functions: hdi (list), hvi (validate), dis (save).
[[ $(type -t helm) ]] && {
    # List all Docker images of an extracted Helm chart $1 (directory).
    hdi(){
        [[ -d $1 ]] && {
            helm template "$@" \
                |grep image: \
                |sed '/^#/d' \
                |awk '{print $2}' \
                |awk -F '@' '{print $1}' \
                |tr -d '"' \
                |sort -u |tee ${FUNCNAME}@${1##*/}.log
        } || {
            echo "=== USAGE : $FUNCNAME [Any and all options required by helm install] PATH_TO_CHART_FOLDER"
        }
    }

    # Validate all Docker images listed in file $1 against those in Docker's cache
    hvi(){
        [[ -f $1 ]] && {
            [[ -n $(echo $DOCKER_HOST) ]] || eval $(minikube -p minikube docker-env)
            while read -r
            do docker image ls --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" |grep ${REPLY##*/}
            done < $1 |tee ${FUNCNAME}@${1##*/}
        } || {
            echo "=== USAGE : $FUNCNAME PATH_TO_IMAGES_LIST_FILE (E.g., hdi@CHART-VER.log)"
        }
    }

    # Perform `docker save` (to *.tar) on all images listed in file $1.
    # (To load these *.tar, use `docker load` *NOT* `docker import`.)
    dis(){
        [[ -f $1 ]] && {
        while read -r
        do 
            img="$(echo $REPLY |awk '{print $1}')"
            out="$(echo $img |sed 's#/#.#g' |sed 's/:/_/').tar"
            docker image save ${img} -o $out
            printf "%s\t%s\n" $img $out |tee -a ${FUNCNAME}@${1##*/}
        done < $1
        } || {
            echo "=== USAGE : $FUNCNAME PATH_TO_IMAGES_LIST_FILE (E.g., hvi@hdi@CHART-VER.log)"
        }
    }
}

set +a # End export all

