#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  Helm : Kubernetes Package Manager
# 
#  Repos/Charts : ArtifactHUB.io
#  @ https://artifacthub.io/packages/search?category=7&sort=relevance&page=1
#
#  Docs     : https://helm.sh/docs/
#  Install  : https://helm.sh/docs/intro/install/
#  Releases : https://github.com/helm/helm/releases
# -----------------------------------------------------------------------------

##########
# Install
## Option 1. Latest release binary by trusted script:
ok(){
    url=https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    curl -sSL $url |/bin/bash 
    which helm &&
        helm version
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
                    rm -rf $arch ||
                        return $?
        }
    
    helm version
}

#######
# Repos
## Add repo of ArtifactHUB.io 
helm repo add hub $url
## Update repos list (cache)
helm repo update
# List Helm's environment variables/settings
helm env
## List installed repos
helm repo list 
## List releases (installed charts) of all namespaces
helm list -A # --all-namespaces

#######################
# Repos/Charts : Search
repo=bitnami
chart=nginx
## Search for chart LOCALLY : Against all repos of `help repo list`
helm search repo $chart 
## Search for chart at ArtifactHub.io (hub)
helm search hub $repo 
helm search hub $repo |grep $chart

########################################
# Charts : Install/Upgrade : Methods (*)
## * Pull and install a chart : Creating a release (Helm lingo)
release=$chart
helm update $release $repo/$chart --install
## * Pull and install a chart : Override chart settings using LOCAL values.yaml file
helm show values $repo/$chart --version $ver |tee $values    # 1. Pull (values.yaml only) then edit.
helm update $release $repo/$chart --install --values $values # 2. Install chart.
## * Pull and install a chart : Override chart settings using REMOTE values.yaml file
helm update $release $repo/$chart --install --values https://$domain/path/$values
## * Pull and install a chart : OFFLINE-INSTALL method
values=values.yaml
## 1. Pull chart for subsequent local install
helm pull $chart --version $ver --repo $url # Ref remote repo
helm pull $repo/$chart --version $ver       # Ref local repo @ `helm repo add` 
tar -xaf ${chart}-${ver}.tgz # Charts *should* extract to a folder named "$chart"
## 2. Copy and edit chart's values.yaml file
cp $chart/values.yaml .
vi values.yaml
## OR Copy by pull
helm show values $repo/$chart --version $ver |tee $values
## 3. Modify values to fit your environment
#  Ok to delete all k-v pairs except for those differing from default values.yaml
vim $values
## 4. Install/Upgrade the local chart, overriding default values with those of $values file.
helm upgrade $release $chart --install --values $values 
    ## Some (other) flags : not all are compatible with --values flag.
    --values, -f FILE   # Specify the values-override (YAML) file (Local or URL).
    --timeout 20s       # Set max install time beyond which fail.
    --atomic            # Teardown on fail; some objects require out-of-band deletion, e.g., pv.
    --debug             # Report progress during install/upgrade
    --dry-run           # YAML(ish) report; use to test viability; catches some fail modes.
    --generate-name     # Auto-generate a release name
    --create-namespace  # Creates ns if necessary
    --namespace $ns     # Declare ns, so `helm -n $ns ...`
    # When upgrading:
    --reset-values      # Reset values to those of chart (default).
    --reuse-values      # Reuse installed values and merge in overrides via --set and -f
                        #... This is *ignored* if '--reset-values' is declared too.
    --set k1=v1,k2=v2   # Set the declared values; multiple --set ... declarations ok
    --wait              # Wait until all K8s-API resources are created else timeout.
 
## Alternate (bad) install method : Don't use; subsequent update requires teardown.
helm install $release $repo/$chart $flags

# Status of deployment (release) : a repeat of that reported on install.
helm status $release

# Test and get useful info on an installed chart (release)
helm test $release

# Desired State : Render chart templates locally and print resulting manifest of current config ($values)
helm template $chart --values $values --namespace $ns

# Running State : Capture manifest of the running release from the K8s API
helm get manifest $release -n $ns

# Show ... {chart,values} are YAML(ish)
helm show {chart,readme,crds,values,all} $chart

# Teardown : Aliases: uninstall, del, delete, un
helm uninstall $release
