#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  Kubernetes tools : kubectl
# -----------------------------------------------------------------------------

# Managed Kubernetes Environment @ Google Cloud Platform 
## Kubernetes Engine > Cluster > Create > GKE Standard

# kubectl is the main k8s client utility
kubectl $command -h |less

# Copy from a container : pull file(s) to local path.
## Show/Pick ctnr from which to pull the existing ($old) file
kubectl get pods --selector type=canary
ctnr=${old}-7bb6f649c6-stl26
from=/usr/share/nginx/html/index.html
to_local=index.pulled.html
## Copy from $old : pull file(s) to local path.
kubectl cp $ctnr:$from $to_local

# Workflow
kubectl create deploy $dname --image=$img
kubectl scale deploy $dname --replicas=3 
# OR
kubectl apply -f . # Process all kubeconfig files (YAML) in $PWD
kubectl get all [-ns $ns] 
kubectl get pods   # Monitor the startup process
## Get all Pods having Label/Selector (--selector KEY=VAL, -l KEY=VAL)
kubectl get po -l type=canary -o json |jq . > k.get.po-l_type_canary.json
## Get the keys 'name' and 'podID' of all Pods so labelled.
kubectl get po -l type=canary -o json |jq '.items[] | .metadata.name,.status.podIP'

kubectl get deploy $dname -o yaml |less  # Get deployment details
kubectl edit deploy $dname               # Edit (vi; limited per K8s rules)
kubectl describe pod $podName  # Examine the pod's (current) State / Reason, and Last State / Reason
kubectl logs $podName          # Examine the APPLICATIONs logs.
kubectl delete pods $podName

# Examine Pods
## Describe : pod : get the pod info stored in etcd database
kubectl describe pod $podName # -o json|yaml |less
## Describe : any object
kubectl describe ns $ns
kubectl describe pods $podName
    ###  Containers:
    ###    ...
    ###    State: Waiting
    ###      Reason: PodInitializing
    ###  Events:

## Get pod name (POD_NAME) : E.g., 'kubernetes-dashboard-8665bfb777-vx5z2'
export POD_NAME=$(kubectl get pods -n default -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")

## Explain : (sub)field(s) from `kubernetes describe ... -o yaml`
kubectl explain $_OBJECT.$_FIELD.$_SUB_FIELD
kubectl explain pod.metadata
kubectl explain pod.spec.containers.volumeMounts
## Connect : launch shell into container 
kubectl exec -it $podName -- sh # /bin/bash instead of sh, if available
## Examining a container, if ps not available, use Linux /proc FS
cd /proc
ls  # the listing includes PID numbers
cat 1/cmdline   # to examine the process
exit            # if shell NOT @ PID 1
CTRL p;CTRL q    # if shell @ PID 1

# Namespace : Create
kubectl create ns $ns # alphanum and dashes ONLY.
# Namespace : Work in a specified namespace
kubectl ... -n $ns  #... PER COMMAND : DO NOT SET else may forget (fail mode)
# Namespace : See ALL resources of ALL namespaces
kubectl get all -A  # Equiv: --all-namespaces
# Namespace : See default namespaces
kubectl get ns 

# Namespaces / Contexts 
## Namespaces MUST be valid DNS Label (RFC 1123/1035)
## K8s DNS pattern
## $_SVC_NAME.$_NAMESPACE.svc.cluster.local
## Create a namespace : alphanum and dashes ONLY.
kubectl create namespace $nsName
## OR
cat <<-EOH > namespace-01.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: namespace-01
EOH
kubectl create -f ./namespace-01.yaml
## List Namespaced Resources
kubectl api-resources --namespaced=true # Those that are namespaced (true)
##... cluster-wide resources are NOT namespaced; nodes, PersistentVolumes

## Switch between k8s namespaces (NOT on exam; may forget, then fail.)
kubectl config set-context --current --namespace=$ns
kubens $ns # OTHER UTILITY : https://github.com/ahmetb/kubectx
## Validate it
kubectl config view --minify | grep namespace:

# Deploy an application (imperatively)
kubectl create $appName --image $appImage --replicas 3
# Deploy declaratively : per manifest (YAML)
## Create if exist else update resource
kubectl apply -f app.yaml 
## Replace resource
kubectl replace -f app.yaml
## Delete 
kubectl delete -f app.yaml
kubectl delete pods,deployments,namespaces

# See all K8s objects created
kubectl get all       # All @ current namespace
kubectl get all -A    # All namespaces; --all-namespaces

# Labels & Selectors : List & Watch FILTERing
## Equality-based
kubectl get pods -l environment=production,tier=frontend
## Set-based (more expressive; allows for logic)
kubectl get pods -l 'environment in (production),tier in (frontend)'
kubectl get pods -l 'environment in (production, qa)' # OR syntax
kubectl get pods -l 'environment,environment notin (frontend)'

# Run app as a NAKED POD : Don't do this lest dev/test. Use apply instead.
kubectl run $appName --image=$imageName --env AN_ENV_VAR=a_value --env ANOTHER=33
# Inspect
kubectl get pods $appName 
kubectl get pods $appName -o yaml # Full description
kubectl get all
# Delete the pod
kubectl delete pod $appName

# Generate kubeconfig file (YAML)
## Generate YAML per DOCs (copy/paste) : kubernetes.io/docs : pods (sample YAML)
## OR
## Generate YAML per `kubectl run ...`
# Generate YAML (only at single-container pod)
kubectl run $appName --image=$appImage --dry-run=client -o yaml > $appYAML
##... add custom run command : `-- ...` MUST BE LAST ARG(s)
kubectl run $appName --image=$appImage \
    --dry-run=client -o yaml -- sleep 3600 > $appYAML
## Generate YAML per DOCs : kubernetes.io/docs : pods (sample YAML)

# Nodes
kubectl get nodes
kubectl drain $node --ignore-daemonsets --force