#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  Kubernetes tools : kubectl
# -----------------------------------------------------------------------------
# Shell config : kubectl completion 
set +o posix # else redirect of process substitution (@script) fails.
source <(kubectl completion bash)
# Shell config : k completion 
alias k=kubectl
complete -o default -F __start_kubectl k

# Help
kubectl $command -h |less
kubectl explain $_OBJECT.$_FIELD.$_SUB_FIELD
kubectl explain pod.spec.containers.securityContext
kubectl explain pod.metadata
kubectl explain pod.spec.containers.volumeMounts
kubectl explain --recursive deployment.spec.strategy
kubectl api-resources # List all K8s objects, i.e., kind: OBJECT

# Manage workloads
kubectl apply -f . # Create/Update all objects of all manifests in PWD 
#... lest mod(s) of immutable key(s) if update.
kubectl create deploy $any --image=$img
kubectl scale deploy $any --replicas=3 
kubectl get all -n kube-system # 'all' is *not* all : See `kubectl api-resources` 
all='pod,deploy,ds,sts,svc,ingress,cm,secret,pvc,pv'
kubectl get $all -A # Across all namespaces
kubectl get pods -o wide # Monitor the startup process including node
## Get all pod names of this namespace
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
## Get all images running in this cluster
kubectl get pods -A -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}'
## Get all Pods having Label/Selector (--selector KEY=VAL, -l KEY=VAL)
kubectl get po -l type=canary
## Get the keys 'name' and 'podID' of all Pods so labelled.
kubectl get po -l type=canary -o json |jq '.items[] | .metadata.name,.status.podIP'
## Get using JSONPath : List node names, one per line.
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'

kubectl get deploy $any -o yaml |less  # Get deployment details
kubectl edit deploy $any               # Edit any mutable key(s) of any existing object.
kubectl describe pod $any  # Examine State / Reason, and Last State / Reason
kubectl delete pods $any

# Examine a Pod status
kubectl describe pod $any |less
    ###  Containers:
    ###    ...
    ###    State: Waiting
    ###      Reason: PodInitializing
    ###  Events:
# Examine container logs
kubectl logs $any # If multi-container pod, 
#... then TAB/select for (required) ctnr name  

## Connect : launch shell into container 
kubectl exec -it $pod -- sh # /bin/bash instead of sh, if available
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
# Namespace : See namespaces
kubectl get ns 

# Namespaces / Contexts 
## Namespaces MUST be valid DNS Label (RFC 1123/1035)
## K8s DNS pattern
## $_SVC_NAME.$_NAMESPACE.svc.cluster.local
## Create a namespace : alphanum and dashes ONLY.
kubectl create namespace $ns
## OR
cat <<-EOH > namespace-01.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: namespace-01
EOH
kubectl create -f namespace-01.yaml
## List Namespaced Resources
kubectl api-resources --namespaced=true # Those that are namespaced (true)
##... cluster-wide resources are NOT namespaced; nodes, PersistentVolumes

# Create a Deployment (imperatively)
kubectl create deploy $name --image nginx --replicas 3
# Scale a Deployment
kubectl scale deploy $dname  --replicas=9
# Label : Add
kubectl label deploy $dname k1=v1
# Label : Modify
kubectl label deploy $dname k1=vZ --overwrite=true
# Label : Delete
kubectl label deploy $dname k1-

# Create a service
kubectl expose deploy $dname --port=80
kubectl describe svc $dname # Look for endpoints
kubectl get svc $dname -o=yaml
kubectl get endpoints

# Execute a shell into a container
kubectl exec -it $pod -c $ctnr -- cat /etc/resolv.conf 

# Port forwarding : Cluster network to Host network
# Expose a service to node (host) network : Port forward a service (@ loopback interface)
kubectl port-forward svc $svc $svc_port:$ctnr_port 
# Listen on all interfaces : make available to another VM
kubectl port-forward svc $svc $svc_port:$ctnr_port --address='0.0.0.0'

# Create an App declaratively: Apply manifest (YAML)
manifest='app.yaml' # May declare many K8s objects; concat documents.
## Creates resource(s) if exist, else updates per change(s)
kubectl apply -f $manifest
## Replace resource(s)
kubectl replace -f $manifest
## Delete resources(s)
kubectl delete -f $manifest

# See all objects created
kubectl get all       # All (subset of all objects) @ current namespace
kubectl get all -A    # All namespaces; --all-namespaces
all='po,deploy,rs,sts,ep,svc,ingress,pvc,pv'
kubectl get $all # Larger subset of all K8s objects

# Labels & Selectors : List & Watch : filter
## Equality-based
kubectl get pods -l environment=production,tier=frontend
## Set-based (more expressive; allows for logic)
kubectl get pods -l 'environment in (production),tier in (frontend)'
kubectl get pods -l 'environment in (production, qa)' # OR syntax
kubectl get pods -l 'environment,environment notin (frontend)'
kubectl get po,deploy -l 'type in (webshop)' -l 'app in (ngx2)'

# Run app as a NAKED POD : Don't do this lest dev/test. Use apply instead.
kubectl run $appName --image=$imageName --env AN_ENV_VAR=a_value --env ANOTHER=33
# Inspect
kubectl get pods $appName 
kubectl get pods $appName -o yaml # Full description
kubectl get all
# Delete the pod
kubectl delete pod $appName

# Generate manifest (YAML)
## - Using kubernetes.io/docs : cut/paste from examples
## - Using `kubectl run...--dry-run=client -o yaml`
kubectl run bbox --image=busybox --dry-run=client -o yaml -- sleep 1d |tee bbox-pod.yaml
## - Using `kubectl get ...-o yaml`
kubectl get deploy ngx -o yaml |tee ngx-deploy.yaml

# Nodes
kubectl get nodes -o wide
kubectl cordon node $hostname # Prevent new pods from being scheduled to this node.
kubectl drain $node --ignore-daemonsets --force # Remove all pods from this node lest of ds.
# jsonpath : https://kubernetes.io/docs/reference/kubectl/jsonpath/
kubectl get node -o jsonpath={.items[*].spec.podCIDRs}
# ["10.240.0.0/24"] ["10.240.1.0/24"] ["10.240.2.0/24"] ["10.240.3.0/24"]
kubectl get node -o jsonpath='{range .items[*]}{.spec.podCIDRs}{"\n"}{end}'
## template : equivalent
kubectl get node -o template='{{range .items}}{{.spec.podCIDRs}}{{"\n"}}{{end}}'
# ["10.240.0.0/24"]
# ["10.240.1.0/24"]
# ["10.240.2.0/24"]
# ["10.240.3.0/24"]

# Patch : https://chatgpt.com/share/a45d346d-270e-4919-94a7-dccabb1e1246
## JSON Patch (RFC 6902)
kubectl patch $kind $name --type='json' \
    -p='[{"op": "replace", "path": "/spec/replicas", "value": 3}]'
## JSON Merge Patch (RFC 7396) : concise syntax
kubectl patch $kind $name --type='merge' \
    -p='{"spec": {"replicas": 3}}'
## K8s Strategic Merge Patch
kubectl patch $kind $name --type='strategic' \
    -p='{"spec": {"template": {"spec": {"containers": [{"name": "nginx", "image": "nginx:1.15.4"}]}}}}'
## Using Kustomize / YAML 
kustomize build $folder |kubectl apply -f -
## Equivalent:
kubectl kustomize $folder |kubectl apply -f -

# Pull file from container to (local) host path 
ctnr=pname-7bb6f649c6-stl26
from=/usr/share/nginx/html/index.html
to_local=index.pulled.html
kubectl cp $ctnr:$from $to_local

# API Server info @ minikube
kubectl -n kube-system describe pod kube-apiserver-minikube 

# API Access : RBAC 
## Role : scoped to namespace 
### Allow get, watch, and list on pods
name='a-role-name'
kubectl create role $name --verb=get --verb=list --verb=watch --resource=pods
### Allow get on Pods of declared names
kubectl create role $name --verb=get --resource=pods --resource-name=$pod_name_1 --resource-name=$pod_name_2
### apiGroups
kubectl create role $name --verb=get,list,watch --resource=replicasets.apps 
### Subresource 
kubectl create role $name --verb=get,list,watch --resource=pods,pods/status
## ClusterRole : scoped to cluster
### Allow get on Pods of declared names
kubectl create clusterrole $name --verb=get --resource=pods --resource-name=$pod_name_1 --resource-name=$pod_name_2
### nonResourceURL 
kubectl create clusterrole $name --verb=get --non-resource-url=/logs/*
### aggregationRule
kubectl create clusterrole $name --aggregation-rule="rbac.example.com/aggregate-to-monitoring=true"
## RoleBinding : Bind EITHER role or clusterrole definition (either are bound/scoped to namespace, not cluster)
kubectl create rolebinding $name --clusterrole=$clusterrole_name --user=$user --namespace=$ns
kubectl create rolebinding $name --role=$role_name --serviceaccount=acme:myapp --namespace=$ns
## ClusterRoleBinding 
kubectl create clusterrolebinding $name --clusterrole=$cluserrole_name --user=$user

# kubeconfig 
## https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
## Explicitly 
config=/path/to/any/valid/kubectl/config
kubectl --kubeconfig=$config ... 
## Else 
export KUBECONFIG=$config
kubectl ... # Implicit
## Else
~/.kube/config 
kubectl ... # Implicit
## Merge multiple kubeconfig (contexts)
export KUBECONFIG=$pathConf1:$pathConf2:$pathConf3
kubectl config view --flatten |tee /path/to/new/merged/kubeconfig
kubectl use-context $context # Set context 
## Get clusters
kubectl config get-clusters
## Set clusters 
kubectl config set-cluster $cluster_name_1 \
    --server=https://192.168.0.100:8443 \
    --certificate-authority=$ca_file
kubectl config set-cluster $cluster_name_2 \
    --server=https://10.0.111.123:6443 \
    --insecure-skip-tls-verify 
## Unset cluster 
kubectl  config unset clusters.$cluster_name
## Set users
kubectl config set-credentials $user_name_1 \
    --client-certificate=$client_cert \
    --client-key=$client_key
kubectl config set-credentials $user_name_2 \
    --username=$creds_username \
    --password=$creds_password # Instead of user creds here, use client-go credential plugin
    # https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
## Unset user
kubectl config unset users.$user_name 
## Set contexts
kubectl set-context $context_1 \
    --cluster=$cluster_name_1 \
    --namespace=$ns_1 \
    --user=$user_name_1
kubectl config set-context $context_2 \
    --cluster=development \
    --namespace=$ns_2 \
    --user=$user_name_1
kubectl config set-context $context_3 \
    --cluster=$cluster_name_2 \
    --namespace=$ns_3 \
    --user=$user_name_2
## Unset context
kubectl config unset contexts.$context_name_1
# Switch between clusters
kubectl config use-context $cluster_name
## Switch between namespaces 
kubectl config set-context --current --namespace=$ns
#kubens $ns # OTHER UTILITY : https://github.com/ahmetb/kubectx
## Validate it
kubectl config view --minify |grep namespace:

# Parse a TLS cert : 
☩ cat ~/.kube/config |yq .users[].user.client-certificate-data |base64 -d |openssl x509 -text -noout
# Certificate:
#     Data:
#         Version: 3 (0x2)
#         Serial Number: 2004000483929044595 (0x1bcfa3d28e4d3673)
#         Signature Algorithm: sha256WithRSAEncryption
#         Issuer: CN = kubernetes
#         Validity
#             Not Before: Jan  6 22:45:28 2024 GMT
#             Not After : Jan  5 22:50:29 2025 GMT
#         Subject: O = system:masters, CN = kubernetes-admin
#         Subject Public Key Info:
#             Public Key Algorithm: rsaEncryption
#                 Public-Key: (2048 bit)
#                 Modulus:
#                     REDACTED
#                 Exponent: 65537 (0x10001)
#         X509v3 extensions:
#             X509v3 Key Usage: critical
#                 Digital Signature, Key Encipherment
#             X509v3 Extended Key Usage:
#                 TLS Web Client Authentication
#             X509v3 Basic Constraints: critical
#                 CA:FALSE
#             X509v3 Authority Key Identifier:
#                 FD:4F:AD:29:59:BF:4E:8D:5A:94:BD:30:96:2C:22:5A:03:3C:02:94
#     Signature Algorithm: sha256WithRSAEncryption
#     Signature Value:
#         REDACTED