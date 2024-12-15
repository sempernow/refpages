#!/usr/bin/env bash
#------------------------------------------------------------------------------
# kubectl : K8s client CLI
# https://kubernetes.io/docs/reference/kubectl/quick-reference/
# https://github.com/kubernetes/website/blob/main/content/en/docs/reference/kubectl/quick-reference.md
# -----------------------------------------------------------------------------
exit # >>>  DO NOT RUN THIS SCRIPT  <<<
# Shell config : kubectl completion 
set +o posix # else redirect of process substitution (@script) fails.
source <(kubectl completion bash)
# Shell config : k completion 
alias k=kubectl
complete -o default -F __start_kubectl k

# HELP 
kubectl COMMAND [SUBCOMMAND] -h |less # Useful info & examples per (sub)command
kubectl explain OBJECT[.FIELD[.SUBFIELD]] [--recursive] # Useful info per object (kind) (sub)key
kubectl explain deploy.spec.selector
kubectl api-resources # List all K8s API objects in cluster's store; API is extensible per CRDs.
kubectl api-resources --verbs=create --namespaced=false #...only those create(able) & having cluster-wide scope.

# LISTs : FLATTEN "items: []" of "- apiVersion: ..." elements to "---" delimited YAML documents
kubectl get $kind -o json |jq -Mr [.items[]] |yq eval .[] -P - |sed '1!s/^apiVersion/---\napiVersion/'

# DEBUG : Get cluster-level info 
# - Events log across all Namespace
kkubect get events -A 
# - Cluster control-plane URL
kubectl cluster-info
# - Debug/diagnostic dump of cluster store
kubectl cluster-info dump
# - Display cluster endpoints and services 
kubectl -n kube-system ep,svc -l 'kubernetes.io/cluster-service=true'

# MANAGE WORKLOADS
# - Declarative commands
kubectl kustomize .   # Process all kustomization (and patch) files @ PWD
kubectl apply -f .    # Create else rolling update per all manifest(s) @ PWD.
#... Update of object is not allowed if any of its immutable keys are changed.
kubectl apply -R -f . # Recurse; process all at and under PWD.
kubectl create -f $manifest --save-config # Adds last-applied annotation to allow for future apply.
kubectl diff -f $manifest # Compare current state with that declared in manifest.
#... K8s API accepts manifests of either YAML or JSON format.
# - Imperative commands
app=ngx
kubectl create -f $app.yaml
kubectl edit $kind $any # Edit any mutable key(s) of any existing object AKA kind.
#... if vim editor ... Save: ZZ, Cancel: ZQ 
kubectl delete -f $app.yaml -f another.yaml
kubectl replace -f $app.yaml # Harsh; deletes all undeclared but existing key(s); prefer apply.
kubectl rollout undo deploy $app # Rollback to previous deployment state
img=bitnami/nginx:1.21.6
# Deployment : Create a Deployment 
kubectl create deploy $app --image=$img
# Deployment : Generate/Capture manifest for future edits & declarative deploy; `kubectl apply -f MANIFEST`
kubectl create deploy bbox --image=busybox --dry-run=client -o yaml |tee deploy.bbox.yaml
# Run a Pod sans Deployment, AKA Naked Pod
kubectl run $any --image=$img --env FOO=bar --env BLAME=$USER
# One-shot pod/container deleted upon command completion
kubectl run $any --image=$img -it --rm -- $command $options 
# Job : Create a Job which prints "Hello World"
kubectl create job hello --image=busybox:1.28 -- echo "Hello World"
# CronJob : create a CronJob that prints "Hello World" every minute
kubectl create cronjob hello --image=busybox:1.28   --schedule="*/1 * * * *" -- echo "Hello World"
# Scale
kubectl scale deploy $any --replicas=3 
# Labels : Key pattern : the.subject.domain.name/{instance,name,managed-by}

# Labels : Add as k=v pair : common keys: app, environment, stage, 
kubectl label $kind $name k1=v1
# Labels : Modify
kubectl label $kind $name k1=vZ --overwrite
# Labels : Delete
kubectl label $kind $name k1-
# Annotations : Key pattern : the.subject.domain.name/{owner,team,poc,repo,expiry,description}
# Annotation : Add as k=v pair
kubectl annotate $kind $name a/b=c
# Annotation : Modify as k=v pair
kubectl annotate $kind $name a/b=x --overwrite
# View : labels||annotations (either)
kubectl get $kind $name -o jsonpath="'{.metadata.$either}'"
kubectl get $kind $name -o jsonpath="'{.metadata.$either."a/b"}'" #=> 'x'
# Execute an interactive shell (bash, sh, ...) into a container 
kubectl exec -it $pod -- /bin/bash    # If single-container Pod
kubectl exec -it $pod -c $ctnr -- sh  # If multi-container Pod : Use TAB completion
# Run command(s) in a container and exit.
kubectl exec -it $pod -- cat /etc/resolv.conf           
    # Examining a container : if ps not available, use Linux /proc FS
        cd /proc
        ls  # the listing includes PID numbers
        cat 1/cmdline   # to examine the process
        exit            # if shell NOT @ PID 1
        CTRL p;CTRL q   # if shell @ PID 1

# GENERATE/CAPTURE MANIFEST (YAML)
# - Using kubernetes.io/docs : cut/paste from examples
# - Using `kubectl run...--dry-run=client -o yaml`
kubectl run bbox --image=busybox --dry-run=client -o yaml -- sleep 1d |tee bbox-pod.yaml
# - Using `kubectl get ...-o yaml`
kubectl get deploy ngx -o yaml |tee deploy.ngx.yaml

# EXPOSE : Create a new service of a resource (kind: po, deploy, rs or svc) based on its selector
kubectl expose $kind $name --port=80
    kubectl describe svc $name # Look for endpoints
    kubectl get svc $dname -o=yaml
    kubectl get ep # endpoints

# PORT FORWARDING : Forward from cluster network to host network
# Expose a resource (svc, pod, deploy) to node (host) network 
# - Listen on 5555 (of host's loopback interface) forwarding to port 8080 of pod "$any":
kubectl port-forward pod $any 5555:8080
# - Listen on port 8443 locally (@ all interfaces; making available to another VM), 
#   forwarding to service targetPort named "https"; 
#   matches port name at Pod(s) selected by this service:
kubectl port-forward svc $any 8443:https --address='0.0.0.0'

# PROXY : Create proxy server (cluster to host) : Default exposes K8s API to localhost:8001
kubectl proxy -h |less # See options
# - Proxy the entire K8s API, running the proxy as a backround process 
kubectl proxy & # Proxy to http://localhost:8001 : To kill, type fg then CTRL+C
# - Proxy some of the API and serve static files from host ~/.local/web
kubectl proxy --port=5555 --www=~/.local/web --www-prefix=/static/ --api-prefix=/api/ &
#... make requests of either the API endpoints, or of static files on host:
# GET K8s API endpoints : only some are available here; can't serve all *and* host static files too.
curl http://localhost:5555/{api/v1/pods/,api/} 
# GET file existing # host ~/.local/web/ 
curl http://localhost:5555/static/$file # Sans $file returns directory listing (HTML)       

# PATCH : https://chatgpt.com/share/a45d346d-270e-4919-94a7-dccabb1e1246
# JSON Patch (RFC 6902) : Modify an existing resource in-place (cluster's data-store content)
kubectl patch $kind $name --type='json' \
    -p='[{"op": "replace", "path": "/spec/replicas", "value": 3}]'
# JSON Merge Patch (RFC 7396) : concise syntax
kubectl patch $kind $name --type='merge' \
    -p='{"spec": {"replicas": 3}}'
# K8s Strategic Merge Patch
kubectl patch $kind $name --type='strategic' \
    -p='{"spec": {"template": {"spec": {"containers": [{"name": "nginx", "image": "nginx:1.15.4"}]}}}}'
# Using Kustomize / YAML 
kustomize build $folder |kubectl apply -f -
# Equivalent:
kubectl kustomize $folder |kubectl apply -f -

# PULL file from container to (local) host path 
ctnr=ngx-7bb6f649c6-stl26
from=/usr/share/nginx/html/index.html
to_local=index.pulled.html
kubectl cp $ctnr:$from $to_local

# ROLLOUT : https://kubernetes.io/docs/reference/kubectl/generated/kubectl_rollout/
# Rollback to previous deployment : All having labels subkey 'type' set to 'canary'
kubectl rollout undo deploy -l type=canary 
# Check the rollout status of a daemonset (ds)
kubectl rollout status ds $any
# Restart a statefulset (sts)
kubectl rollout restart sts $any
# View rollout history
kubectl rollout history deploy $any 

# GET 
kubectl -n $ns get $kind $name # [-o yaml|json|jsonpath|wide|...] [-A] 
kubectl get all -n kube-system # 'all' is *not* all : See `kubectl api-resources` 
all='pod,deploy,ds,sts,svc,ingress,cm,secret,pvc,pv'
kubectl get $all -A # Across all namespaces
# Endpoints and services having label ...
kubectl -n kube-system ep,svc -l 'kubernetes.io/cluster-service=true'
kubectl get pods -o wide # Monitor the startup process including node
# Get all pod names of this namespace
kubectl get po -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
# Get all images running in this cluster, one per line
kubectl get po -A -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}'
# Get all Pods having (selector) label 'type' set to 'canary'
kubectl get po -l type=canary
# Get 'name' and 'podID' of those Pods
kubectl get po -l type=canary -o jsonpath='{.metadata.name}{"\n"}{.status.podIP}'
# Same, but as valid JSON
kubectl get po -l type=canary -o json |jq -Mr '{name: .metadata.name,podIP: .status.podIP}'
# Get node names only, one per line.
kubectl get no -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
# Capture a manifest
kubectl get deploy $any -o yaml # |tee /save/to/here.yaml
# Capture a dynamically-generated (e.g., kustomize) manifest
kubectl apply -k "github.com/minio/operator?ref=v6.0.4" --dry-run=client -o yaml
# Get all (subset of all objects) of current namespace
kubectl get all       
kubectl get all -A # All namespaces; --all-namespaces
all='po,deploy,ds,sts,ep,svc,ingress,pvc,pv'
kubectl get $all # Larger subset of all K8s objects

# Authz : Access protected K8s API endpoints using a ServiceAccount (sa) token
# - GET /healthz
# Set cluster server URL : See `k config view` else `k get node -o wide` else `k get svc -A`
name=default # config.clusters[].cluster.name
url="$(k config view -o jsonpath='{.clusters[?(@.name=="'$name'")].cluster.server}')"
tkn="$(k -n default create token default --duration=10m)" # Create/use its token
curl -k -H "Authorization: Bearer $(k -n kube-system create token default)" $url/healthz?verbose
# Full access requires cluster-admin ClusterRole, so create and bind an sa (gitops) to that. (See RBAC section.)
tkn="$(k -n default create token gitops --duration=10m)" 
# - GET /api/v1/namespaces/{namespace}/pods[/{name}[/log,/status,...]]
curl -k -H "Authorization: Bearer $tkn" https://$ep/api/v1/namespaces/default/pods
# - GET /openapi/v2 : All endpoints : All info 
curl -k -H "Authorization: Bearer $tkn" https://$ep/openapi/v2 \
    |jq -Mr '.paths | to_entries | map(select(.key | test("^/api"))) | from_entries'
        # Then (optionally) filter out a keyname (or CSV list of them)
        |jq '. |walk(if type == "object" then del(.parameters) else . end)'
# - GET /openapi/v2 : All endpoints : List URLs only
curl -k -H "Authorization: Bearer $tkn" https://$ep/openapi/v2 \
    |jq -Mr '.paths | keys[] | select(test("^/api"))' 
    #... |wc -l # Print the number of URLs : @ K3S, 485 of "/api"; 112 of "/api/v1"

# NODES
kubectl get nodes -o wide
kubectl cordon node $hostname # Prevent new pods from being scheduled to this node.
kubectl drain $node --ignore-daemonsets --force # Remove all pods from this node lest of ds.
# jsonpath : https://kubernetes.io/docs/reference/kubectl/jsonpath/
kubectl get node -o jsonpath={.items[*].spec.podCIDRs}
# ["10.240.0.0/24"] ["10.240.1.0/24"] ["10.240.2.0/24"] ["10.240.3.0/24"]
kubectl get node -o jsonpath='{range .items[*]}{.spec.podCIDRs}{"\n"}{end}'
# template : equivalent
kubectl get node -o template='{{range .items}}{{.spec.podCIDRs}}{{"\n"}}{{end}}'

# LABELS & SELECTORS : List & Watch : filter
# - Equality-based
kubectl get pods -l environment=production,tier=frontend
# - Set-based (more expressive; allows for logic)
kubectl get pods -l 'environment in (production),tier in (frontend)'
kubectl get pods -l 'environment in (production, qa)' # OR syntax
kubectl get pods -l 'environment,environment notin (frontend)'
kubectl get po,deploy -l 'type in (webshop)' -l 'app in (ngx2)'

# DESCRIBE (any object) : Examine a Pod status
kubectl describe pod $any |less
    #  Containers:
    #    ...
    #    State: Waiting
    #      Reason: PodInitializing
    #  Events:

# LOGS : Examine container logs
kubectl logs $any # If multi-container pod, 
#... then TAB/select for (required) ctnr name  

# NAMESPACES 
# Namespaces MUST be valid DNS Label (RFC 1123/1035) : 0-9, a-Z and dash (-)
# K8s DNS pattern : SERVICE.NAMESPACE.svc.cluster.local (FQDN)
# If comms is within one namespaces, then SERVICE.NAMESPACE resolves.
# Create a namespace : alphanum and dashes ONLY.
kubectl create namespace $ns
# OR
cat <<-EOH > namespace-01.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: namespace-01
EOH
kubectl create -f namespace-01.yaml

# CONFIGURATION : kubeconfig
# https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
kubectl config view [--raw] 
# Set explicitly 
config=/path/to/any/valid/kubectl/config
kubectl --kubeconfig=$config ... 
# Else implicitly by its env variable
export KUBECONFIG=$config
# Else implicitly per ~/.kube/config 
kubectl $anything  
# Get contexts : A CONTEXT is a set of 3 things : a cluster, a user, and a namespace 
# - config.contexts[*].context (cluster, namespace, user) 
k config get-contexts                        # as table
k config view -o jsonpath='{.contexts[*].context}' # as JSON-ish
k config view -o jsonpath='{.contexts[*].context}' |jq -Mr . --slurp  # Valid JSON
k config view -o jsonpath='{range .contexts[*]}{.context}{"\n"}{end}' # valid JSON per line
# Get CURRENT CONTEXT : clusters[*].cluster.name element at config.current-context
k config view -o jsonpath='{.current-context}'
# Merge multiple kubeconfig (contexts)
export KUBECONFIG=$pathConf1:$pathConf2:$pathConf3
# To save that all as a single kubeconfig file
kubectl config view --flatten |tee /path/to/new/merged/kubeconfig
# Set context 
kubectl use-context $context 
# Get clusters
kubectl config get-clusters
# Set clusters 
kubectl config set-cluster $cluster_name_1 \
    --server=https://192.168.0.100:8443 \
    --certificate-authority=$ca_file
kubectl config set-cluster $cluster_name_2 \
    --server=https://10.0.111.123:6443 \
    --insecure-skip-tls-verify 
# Unset cluster 
kubectl  config unset clusters.$cluster_name
# Set users
kubectl config set-credentials $user_name_1 \
    --client-certificate=$client_cert \
    --client-key=$client_key
kubectl config set-credentials $user_name_2 \
    --username=$creds_username \
    --password=$creds_password # Instead of user creds here, use client-go credential plugin
    # https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
# Unset user
kubectl config unset users.$user_name 
# Set contexts
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
# Unset context
kubectl config unset contexts.$context_name_1
# Switch between clusters
kubectl config use-context $cluster_name
# Switch between namespaces 
kubectl config set-context --current --namespace=$ns
# Validate it
kubectl config view --minify |grep namespace:

# RBAC : API Access (Authz)
group=team-1
role=developer
ns=foo
# Role : Scoped to namespace
kubectl create role $role --verb=get --verb=list --verb=watch --resource=pods
# Allow get on DaemonSet of declared names
kubectl create role $role --verb=get --resource=ds --resource-name=app-1 --resource-name=app-2
# ClusterRole : Scoped to cluster
# Allow get on PersistentVolume of declared names
kubectl create clusterrole $role --verb=get --resource=pv --resource-name=app-1-pv --resource-name=app-2-pv
# - nonResourceURL 
kubectl create clusterrole $role --verb=get --non-resource-url=/logs/*
# - aggregationRule
kubectl create clusterrole $role --aggregation-rule="rbac.example.com/aggregate-to-monitoring=true"
# RoleBinding : Binds EITHER (Cluster)Role to namespace, REGARDLESS.
# - This pattern is commonly used to apply cluster-wide policies (roles) selectively to namespaces (groups).
kubectl create rolebinding $role-rb-$group --clusterrole=$role --user=u1 --user=$USER --namespace=$ns
kubectl create rolebinding $role-rb-$group --role=$role --serviceaccount=acme:myapp --namespace=$ns
# ClusterRoleBinding : Binds ONLY a ClusterRole, NOT any Role.
kubectl create clusterrolebinding $role-crb-$group --clusterrole=$role --group=team-1 --group=team-3 --group=gitops-$role-tester

# Create ServiceAccount and ClusterRoleBinding for accessing to all protected K8s API endpoints
kubectl -n default create sa gitops --save-config=true
kubectl create clusterrolebinding cluster-admin-crb-gitops --clusterrole=cluster-admin --serviceaccount=default:gitops

# Check for subjects of role bindings 
kubectl get rolebindings -n $ns -o=custom-columns=NAME:.metadata.name,ROLE:.roleRef.name,SUBJECTS:.subjects
# Check for subjects of cluster role bindings
kubectl get clusterrolebindings -o=custom-columns=NAME:.metadata.name,ROLE:.roleRef.name,SUBJECTS:.subjects
# Get all Roles (of a declared Namespace) bound to "kind: $sub" (Note K8s has no User object).
ns=kube-system
sub=User # User|Group|ServiceAccount
kubectl get rolebindings -n $ns -o json |jq -Mr '[.items[] | {rolebinding: .metadata.name,role: .roleRef.name,subject: (.subjects[] |select(.kind == "'$sub'")) |{kind:.kind,name:.name}}]' |yq eval -P -o yaml
# Get all roles (of a declared Namespace) bound to a declared .roleRef.name ($name)
name='system:kube-controller-manager'
kubectl get rolebindings -n $ns -o json \
    |jq -Mr '[.items[] | {rolebinding: .metadata.name,role: .roleRef.name,subject: (.subjects[] |select(.name == "'$name'")) |{kind:.kind,name:.name}}]' \
    |yq eval -P -o yaml
# Get ClusterRole of Group having Name (in case of User having same name)
sub=Group
name='kubeadm:cluster-admins'
kubectl get clusterrolebindings -n $ns -o json \
    |jq -Mr '[.items[]? | {rolebinding: .metadata.name,role: .roleRef.name,subject: (.subjects[]? |select(.kind == "'$sub'")|select(.name == "'$grp'")) |{kind:.kind,name:.name}}]' \
    |yq eval -P -o yaml
# Get ClusterRole of Group
# X.509 certificates of "kind: Group"
# - @ K3S : /var/lib/rancher/k3s/server/tls
# - @ K8s : /var/kubernetes/pki, /var/kubernetes/*.conf 
# - Also check pod.volumes for path(s) declared at host process (ps aux)

# X.509 v. RBAC
    # JsonPath https://kubernetes.io/docs/reference/kubectl/jsonpath/
    # COMMON PATTERN using its array filter "?()" :
    # Get value of key-X of an array-element object having a key-Y set to a *declared value*.
    # SYNTAX: $.anArrayKey[?(@.keyB=="foo bar")].keyA
    # EXAMPLE: Get/parse TLS certificate (and extract Subject) of a declared config.users.user:
    user=kind-kind # See config.users[] at `kubectl config view`
    kubectl config view --raw -o yaml \
        |yq '.users[] |select(.name == "'$user'") |.user.client-certificate-data'
        #...
    kubectl config view --raw \
        -o jsonpath='{.users[?(@.name=="'$user'")].user.client-certificate-data}' \
        |base64 -d |openssl x509 -text -noout
        # OR just declared field(s)
        |base64 -d |openssl x509 -noout -startdate -enddate -issuer -subject -ext subjectAltName
            #=> subject=O = kubeadm:cluster-admins, CN = kubernetes-admin
            # X.509 "O" maps to "kind: Group", and "CN" maps to "kind: User"

    # CA
    kubectl config view --raw \
        -o jsonpath='{.clusters[].cluster.certificate-authority-data}' \
        |base64 -d \
        |openssl x509 -noout -issuer -subject -startdate -enddate -ext subjectAltName

    issuer=CN = k3s-server-ca@1734274754
    subject=CN = k3s-server-ca@1734274754
    notBefore=Dec 15 14:59:14 2024 GMT
    notAfter=Dec 13 14:59:14 2034 GMT
    No extensions in certificate

    # User (Group)
    kubectl config view --raw \
        -o jsonpath='{.users[].user.client-certificate-data}' \
        |base64 -d \
        |openssl x509 -noout -issuer -subject -startdate -enddate -ext subjectAltName

    issuer=CN = k3s-client-ca@1734274754
    subject=O = system:masters, CN = system:admin
    notBefore=Dec 15 14:59:14 2024 GMT
    notAfter=Dec 15 14:59:14 2025 GMT
    No extensions in certificate

    # Find ClusterRoleBinding(s) for that Group
    kubectl get clusterrolebinding \
        -o jsonpath='{.items[].metadata.name}{"\n"}{.items[].subjects[?(@.kind=="Group")].name}'
