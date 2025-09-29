#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  Helm : Kubernetes Package Manager
# 
#  Repos/Charts : ArtifactHUB.io
#  @ https://artifacthub.io/packages/search?category=7&sort=relevance&page=1
#
#  Docs     : https://helm.sh/docs/
#  Releases : https://github.com/helm/helm/releases
# -----------------------------------------------------------------------------

########################################################
## Install Helm : https://helm.sh/docs/intro/install/
## Releases    : https://github.com/helm/helm/releases

## Option 1. Latest release binary by trusted script:
ok(){
    url=https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    curl -sSL $url |/bin/bash 
    which helm && helm version ||
        return 1
}
## Option 2. Declared version binary if not already (idempotent)
ok(){
    ver=v3.18.6
    arch=linux-amd64
    url=https://get.helm.sh/helm-$ver-$arch.tar.gz
    type -t helm >/dev/null 2>&1 &&
        helm version 2>/dev/null |grep -q $ver || {
            curl -sSfL $url |tar -xzf - &&
                sudo install $arch/helm /usr/local/bin/ &&
                    rm -rf $arch &&
                        echo ok ||
                            return $?
        }
}

########
## Chart
repo=csi-driver-nfs
url=https://raw.githubusercontent.com/kubernetes-csi/$repo/master/charts
chart=csi-driver-nfs
version=4.11.0
release=nfs-csi
ns=kube-system
template=helm.template.yaml
values=values.lime.yaml

repo(){
    # Adds repo metadata to fasciliate all downstream commands
    helm repo add $repo $url &&
        helm repo update $repo || {
            echo "⚠️  ERR on helm repo add/update : $repo"

            return 22
        }
}

pullChart(){
    # The chart is not required locally unless target environment is air-gap.
    repo &&
        helm pull $repo/$chart --version $version &&
            tar -xaf ${chart}-$version.tgz &&
                cp $chart/values.yaml . &&
                    rm -rf $chart ||
                        return 33
}

pullValues(){
    # Extract the chart's default values.yaml
    curl -fsSL $url/v$version/${chart}-$version.tgz \
        |tar -xzOf - $chart/values.yaml \
        |tee values.yaml
}

values(){
    # Process the values template file into the values file 
    # used at template, install and uprade.
    envsubst < $values.tpl > $values
    valuesDiff
}

diffValues(){ diff $values values.yaml |grep -- '<'; }

template(){
    # Generate manifest (YAML) file containing all K8s resources 
    # of the chart under this particular set of $values declarations.
    helm template $release $repo/$chart \
        --namespace $ns \
        --values $values \
        |tee $template ||
            return 44
}

install(){
    helm upgrade $release $repo/$chart \
        --install \
        --namespace $ns \
        --version $version \
        --values $values
}

installBySet(){
    helm upgrade $release $repo/$chart \
        --install \
        --namespace $ns \
        --version $version \
        --set externalSnapshotter.enabled=true \
        --set controller.runOnControlPlane=true \
        --set controller.replicas=2
}

manifest(){
    helm -n $ns get manifest $release \
        |tee helm.manifest.yaml
}

diffManifest(){
    # Running v. Declared states
    diff helm.manifest.yaml helm.template.yaml #|grep -- '<'
}

teardown(){
    helm delete $release --namespace $ns
}
