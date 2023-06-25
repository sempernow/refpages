#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  Kubernetes tools : kubectl
# -----------------------------------------------------------------------------

# Managed Kubernetes Environment @ Google Cloud Platform 
## Kubernetes Engine > Cluster > Create > GKE Standard

# kubectl is the main k8s client utility
kubectl $command -h |less

# Workflow
kubectl create deploy $dname --image=$img
kubectl scale deploy $dname --replicas=3 
# OR
kubectl apply -f . # Process all kubeconfig files (YAML) in $PWD
kubectl get all [-ns $ns] 
kubectl get pods   # Monitor the startup process
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