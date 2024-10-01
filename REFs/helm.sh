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

# Install Helm : https://helm.sh/docs/intro/install/
## Releases    : https://github.com/helm/helm/releases
ok(){
    arch=amd64
    ver=3.15.3
    curl -sSL https://get.helm.sh/helm-v${ver}-linux-$arch.tar.gz |tar -xzf -
    sudo cp linux-$arch/helm /usr/local/bin/helm && rm -rf linux-$arch
    helm version |grep $ver && return 0
    ## Else install the latest release by trusted script:
    curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
        |/bin/bash 
    helm version || return 1
}
ok #|| exit $?

# Repos
## Add repo of ArtifactHUB.io 
helm repo add hub $url
## Update repos list (cache)
helm repo update
## List installed repos
helm repo list 

# Charts : Search
## Search for a chart @ ArtifactHub.io (hub)
helm search hub $app |grep $repo
## Search for chart locally (against all repos of `helm list`)
helm search repo $app_or_keyword # All versions : --versions, -l
## Or
chart=$repo/$app #=> bitnami/nginx
docker image ls |grep $chart_or_keyword
## Or, if apropos
minikube ssh docker image ls |grep $chart_or_keyword
## List installed chart(s) : k8s resources created per chart(s)
helm list 

# Charts : Install (A chart version is a RELEASE)
## Install a chart : $release is any name (Service name).
values='values.yaml'
helm install $release $chart 
## OR auto-generate a release name : mysql-169074637
helm install $chart --generate-name
## OR, using a modified values manifest. (See method below).
helm install -f $values $release $chart
## OR from an extracted (and perhaps modified) package
helm pull $chart
tar -xaf $pulled.tgz # Extracts to $extract_dir
pushd $extract_dir
vim $extract_dir/$values #... edit
helm install -f $extract_dir/$values $release $extract_dir/
##... NOT ALL PARAMs are allowed to be modified; see /VALUES_SUMMARY.md
## Options useful on chart install
    --version $ver \
    --create-namespace \
    --namespace $ns \
    --atomic \
    --timeout 20s \
    --dry-run #... YAML(ish) report. 
    ## So, redirect dry run to generate values.yaml and mod before install.
    ## 
    ## Also, may DOWNLOAD PLUGINS BEFOREHAND,  
    ## and disable downloads on install:
    ## Set `installPlugins: false` @ values.yaml .
    ## (Each repo/chart has its own way of handling HTTP_PROXY.)

# Show ... {chart,values} are YAML(ish)
helm show {chart,readme,crds,values,all} $chart

# Status (+usage details) of chart's deployed service (from list)
helm status $release

# Teardown : uninstall|un|delete|del
helm uninstall $release