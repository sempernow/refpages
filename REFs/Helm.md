# [Helm](https://helm.sh/docs/) | [ArtifactHUB.io](https://artifacthub.io/)

>The defacto Kubernetes package manager. Installs a "chart" (Kubernetes workload) onto a cluster as a "release" (name reference to the Kuberenetes ressources it creates). Contains the set of Kubernetes-resource documents (YAML files) that fully define the workload, along with their templates, and a single `values.yaml` file containing all modifiable values for that chart. AtrifactHUB.io is the main repository for Helm charts, though charts may be pulled from anywhere. A chart is typically stored/pulled as a tarball (`*.tgz`).

## [Install Helm](https://helm.sh/docs/intro/install/)

Install a select version ([Releases](https://github.com/helm/helm/releases))

```bash
# Install Helm : https://helm.sh/docs/intro/install/
## Releases    : https://github.com/helm/helm/releases
ok(){
    os=linux
    arch=amd64
    ver=3.15.3
    curl -sSL https://get.helm.sh/helm-v$ver-$os-$arch.tar.gz |tar -xzf -
    sudo cp $os-$arch/helm /usr/local/bin/helm && rm -rf $os-$arch
    helm version |grep $ver && return 0
    ## Else install the latest release by trusted script:
    curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
        |/bin/bash 
    helm version || return 1
}
ok #|| exit $?

```

## Commands | [`helm.sh`](helm.sh)

### @ Operations

```bash
## Monitor
label="app.kubernetes.io/instance=$release"
all='pod,deploy,rs,sts,ep,svc,cm,secret,pvc,pv'
kn $ns

k get $all -l $label \
    |tee k.get_all-l.instance.$release.log

# YAML
k get $all -l $label -o yaml \
    |tee k.get_all-l.instance.$release.yaml

## Teardown
helm uninstall $release

## Verify
k get $all |grep $release

```

## Example : Install a chart

```bash
# Add repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Set Environment
ns='dev'
release='prometheus'
chart='prometheus-community/prometheus'
ver='23.3.0' # Prometheus v2.46.0

k create ns $ns
# Install the chart : first run with `--dry-run`, then actually.
helm upgrade --install $release $chart \
    --version $ver \
    --namespace ${ns:-default} \
    --atomic \
    --debug \
    --dry-run \
    |& tee helm.install.${ns-default}.$release.log

# Get all (actual) objects of this release
k -n ${ns:-default} get po,deploy,rs,ep,svc,pv,pvc \
    -l app.kubernetes.io/name=$release \
    |tee k-n.${ns:-default}.get_all-l.$release.log

# Get deployment object (YAML)
k -n ${ns:-default} get deploy -l app.kubernetes.io/name=$release \
    -o yaml |tee k-n.${ns:-default}.get.deploy.${release}.yaml
```


### Install [GitLab](https://artifacthub.io/packages/helm/gitlab/gitlab) 

#### [Installing GitLab using Helm](https://docs.gitlab.com/charts/installation/)

>*In a production deployment: The stateful components, like PostgreSQL or Gitaly (a Git repository storage dataplane), must run outside the cluster on PaaS or compute instances. This configuration is required to scale and reliably service the variety of workloads found in production GitLab environments. You should use Cloud PaaS for PostgreSQL, Redis, and object storage for all non-Git repository storage.* [()

#### Dependencies:

- gitlab
- certmanager-issuer
- minio
- registry
- certmanager 1.11.1
    - https://charts.jetstack.io/
- prometheus 15.18.0
    - https://prometheus-community.github.io/helm-charts
    - Our installed chart @ `23.3.0`; Prometheus v2.46.0
- postgresql 12.5.2 
    - https://charts.bitnami.com/bitnami
- gitlab-runner 0.55.0
    - https://charts.gitlab.io/
- redis 16.13.2
    - https://charts.bitnami.com/bitnami
- nginx-ingress



#### Install

To delete `pvc`, `pv` of prior install:

```bash
# Delete PVCs
k get pvc -A |grep gitlab |awk '{print $2}' |xargs -I{} kubectl delete pvc {}
# Delete PVs
k get pv -A |grep gitlab |awk '{print $1}' |xargs -I{} kubectl delete pv {}
```

```bash
# Add repo
helm repo add gitlab http://charts.gitlab.io/

## Set Environment
ns='dev' 
release='gitlab'
chart='gitlab/gitlab'
ver='7.2.4' # GitLab v16.2.4

k create ns $ns

# Install the chart : first run with `--dry-run`, then actually.
helm upgrade --install $release $chart \
    --set global.hosts.domain='gitlab.local' \
    --set global.hosts.externalIP=$(minikube ip) \
    --set certmanager-issuer.email=gary.dostourian@ngc.com \
    --set certmanager.rbac.create=false \
    --set nginx-ingress.rbac.createRole=false \
    --set prometheus.rbac.create=false \
    --set gitlab-runner.rbac.create=false \
    --version $ver \
    --namespace ${ns:-default} \
    --debug \
    |& tee helm.install.${ns-default}.$release.log 

```
- Email addr else: "`Error: INSTALLATION FAILED: ... You must provide an email to associate with your TLS certificates. Please set certmanager-issuer.email`"

```bash
# Get all (actual) objects of this release
all='po,deploy,rs,sts,ep,svc,ingress,cm,secret,pvc,pv'

k -n ${ns:-default} get $all \
    --selector app.kubernetes.io/name=$release \
    --selector name=$release \
    |tee k-n.${ns:-default}.get_all--selector.$release.log

# Get deployment manifest (YAML)
k -n ${ns:-default} get deploy \
    --selector app.kubernetes.io/name=$release \
    --selector name=$release \
    -o yaml \
    |tee k-n.${ns:-default}.get.deploy.${release}-o.yaml

# Teardown
helm uninstall $release # leaves all Secrets, PVC and PV objects.

# Delete secrets (otherwise handled by subsequent helm install)
k delete secret $(k get secrets |grep gitlab |awk '{print $1}')

# Delete PVCs
k get pvc -A |grep gitlab |awk '{print $2}' |xargs -I{} kubectl delete pvc {}
# Delete PVs
k get pv -A |grep gitlab |awk '{print $1}' |xargs -I{} kubectl delete pv {}
```
- GitLab chart install first deletes any of its prior `secret` objects,
  so needn't bother with those.
- May not need to delete PV/PVCs

### Install [Kiali Operator](https://artifacthub.io/packages/olm/community-operators/kiali)

#### TL;DR 

This "chart" is half baked. No actual chart.

Images

```bash
quay.io/kiali/kiali-operator:v1.72.0
```

The INSTALL (button) instructions at the ArtifactHUB.io page is *not* by helm chart.


```bash
# Install 
cat <<EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: my-kiali
  namespace: operators
spec:
  channel: stable
  name: kiali
  source: operatorhubio-catalog
  sourceNamespace: olm
EOF

# Get
kubectl get csv -n operators
```

Try by extracting info from kiali.io page:

```bash
# Add repo
helm repo add kiali https://kiali.org/helm-charts

export ns='dev' 
release='kiali'
chart='kiali'
ver='1.71.0' # Kiali Operator 1.72.0


# Install the chart : first run with `--dry-run`, then actually.
helm upgrade --install $release $chart \
    --version $ver \
    --namespace ${ns:-default} \
    --atomic \
    --debug \
    --dry-run \
    > helm.install.${ns-default}.$release.log 

```

### Install [Jaeger](https://artifacthub.io/packages/helm/jaegertracing/jaeger)

#### TL;DR 

Chart install fails catastrophically, with the Minikube API Server failing repeately thereafter, even after reboot. Helm does not uninstall itself per `--atomic` option, nor could it uninstall per `helm -n $ns uninstall`. Certain `jaeger` pods are in `CrashLoopBackoff`.

Delete manually

```bash
all='po,deploy,rs,ep,svc,pv,pvc,ingress,cm,secret'
kn $ns
k delete $all \
    --selector app.kubernetes.io/name=$release \
    --selector name=$release

```

#### Images

```text
jaegertracing/jaeger-agent:1.45.0
jaegertracing/jaeger-collector:1.45.0
jaegertracing/jaeger-query:1.45.0
cassandra:3.11.6
jaegertracing/jaeger-cassandra-schema:1.45.0
```

#### Install

```bash
# Add repo
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts

## Set Environment
export ns='dev' 
release='jaeger'
chart='jaegertracing/jaeger'
ver='0.71.11' # Jaeger v1.45.0

k create ns $ns

# Install the chart : first run with `--dry-run`, then actually.
helm upgrade --install $release $chart \
    --version $ver \
    --namespace ${ns:-default} \
    --atomic \
    --debug \
    --dry-run \
    > helm.install.${ns-default}.$release.log 

# Get all (actual) objects of this release
all='po,deploy,rs,ep,svc,pv,pvc,ingress,cm,secret'

k -n ${ns:-default} get $all \
    --selector app.kubernetes.io/name=$release \
    --selector name=$release \
    >k-n.${ns:-default}.get_all--selector.$release.log

# Get deployment manifest (YAML)
k -n ${ns:-default} get deploy \
    --selector app.kubernetes.io/name=$release \
    --selector name=$release \
    -o yaml >k-n.${ns:-default}.get.deploy.${release}-o.yaml
```
- `Notes:` @ `helm-n.$ns.install.$release.log` :
```text
NOTES:

...
```

```bash
# Get all (actually)
k -n $ns get po,deploy,rs,ep,svc,pv,pvc,ingress
```
- Sans `ingress`
- Sans `pv`,`pvc`
    - Grafana's default chart settings disable persistence.

@ Service 

```bash
svc_name=''
ns='dev'

# List services of a namespace 
k -n ${ns:-default} get svc

# Cluster DNS : Naming convention
$svc_name.${ns:-default}.svc.cluster.local

abox='ngx'
k exec $abox -- curl -sLI $svc_name.${ns:-default}.svc.cluster.local
#=> HTTP/1.1 405 Method Not Allowed
#   Allow: GET, OPTIONS
#   ...

k exec $abox -- curl -s $svc_name.${ns:-default}.svc.cluster.local
#=> <a href="/graph">Found</a>.
```

### Install [Prometheus](https://artifacthub.io/packages/helm/prometheus-community/prometheus)

#### TL;DR 

Success.

#### Images

```text
quay.io/prometheus/node-exporter:v1.6.0
registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.9.2
quay.io/prometheus/pushgateway:v1.6.0
quay.io/prometheus-operator/prometheus-config-reloader:v0.67.0
quay.io/prometheus/prometheus:v2.46.0
quay.io/prometheus/alertmanager:v0.25.0
```

#### Install

```bash
# Add repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# Install Chart
helm upgrade --install my-prometheus prometheus-community/prometheus --version 23.3.0

## Set Environment
ns='dev'
release='prometheus'
chart='prometheus-community/prometheus'
ver='23.3.0' # Prometheus v2.46.0
ver='24.3.0' # Prometheus v2.46.0
label="app.kubernetes.io/instance=$release"

k create ns $ns
kn $ns

# Install the chart : first run with `--dry-run`, then actually.
helm upgrade --install $release $chart \
    --version $ver \
    --namespace ${ns:-default} \
    --atomic \
    --debug \
    --dry-run \
    |& tee helm.install.${ns-default}.$release.log

# Get all (actual) objects of this release
k get $all --selector $label \
    |tee k-n.${ns:-default}.get_all.selector.$release.log

# YAML
k -n ${ns:-default} get deploy --selector app.kubernetes.io/name=$release \
    -o yaml |tee k-n.${ns:-default}.get.deploy.${release}-o.yaml
```
- `Notes:` @ `helm-n.dev.install.prometheus.log` :
```text
NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.dev.svc.cluster.local


Get the Prometheus server URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace dev -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace dev port-forward $POD_NAME 9090


The Prometheus alertmanager can be accessed via port 9093 on the following DNS name from within your cluster:
prometheus-alertmanager.dev.svc.cluster.local


Get the Alertmanager URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace dev -l "app.kubernetes.io/name=alertmanager,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace dev port-forward $POD_NAME 9093
...
The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
prometheus-prometheus-pushgateway.dev.svc.cluster.local


Get the PushGateway URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace dev -l "app=prometheus-pushgateway,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace dev port-forward $POD_NAME 9091

...
```

```bash
# Get all (actually)
k -n $ns get po,deploy,rs,ep,svc,pv,pvc,ingress
```
- Sans `ingress`
- Sans `pv`,`pvc`
    - Grafana's default chart settings disable persistence.

@ Service 

```bash
svc_name='prometheus-server'
ns='dev'

# List services of a namespace 
k -n ${ns:-default} get svc

# Cluster DNS : Naming convention
$svc_name.${ns:-default}.svc.cluster.local

abox='ngx'
k exec $abox -- curl -sLI $svc_name.${ns:-default}.svc.cluster.local
#=> HTTP/1.1 405 Method Not Allowed
#   Allow: GET, OPTIONS
#   ...

k exec $abox -- curl -s $svc_name.${ns:-default}.svc.cluster.local
#=> <a href="/graph">Found</a>.
```

### Install [Grafana](https://artifacthub.io/packages/helm/grafana/grafana)

#### TL;DR 

UPDATE: See LOG @ `/minikube/` @ `# 2023-09-05` (GitLab chart debug)

Success. Chart is sans `ingress`, and sans `pv`,`pvc` (persistence disabled).

Image(s)

- `grafana/grafana:10.0.3`


```bash
# Add repo
helm repo add grafana https://grafana.github.io/helm-charts

## Set Environment
ns='dev'
release='grafana'
chart='grafana/grafana'
ver='6.58.8' # Grafana 10.0.3
ver='6.59.4' # Grafana 10.1.1
label="app.kubernetes.io/instance=$release"

k create ns $ns
# Install the chart : first run with `--dry-run`, then actually.
helm upgrade --install $release $chart \
    --version $ver \
    --namespace $ns \
    --atomic \
    --debug \
    --dry-run \
    |& tee helm.install.${ns-default}.$release.log

## Monitor
k -n ${ns:-default} get $all --selector $label \
    |tee k-n.${ns:-default}.get_all.selector.instance.$release.log

# Get sts manifest (YAML)
k -n ${ns:-default} get po,deploy,rs --selector $label \
    -o yaml |tee k-n.${ns:-default}.get.po.deploy.sts.${release}.yaml

### Pull chart
helm pull $chart --version $ver # Dumps to $pulled
pulled=$(find . -type f -iname '*.tgz' -printf %f |head -n1 |sed 's#.tgz##')
tar -xaf $pulled.tgz            # Extracts to $extracted
extracted=$(find . -maxdepth 1 -type d ! -iname '.' -printf "%f\n" |head -n1)
mv $extracted $pulled && extracted=$pulled

### upgrade chart            
helm upgrade --install $release $extracted \
    --version $ver \
    --namespace $ns \
    --atomic \
    --debug \
    |& tee helm.upgrade.${ns-default}.$release.log

## Teardown
helm -n ${ns:-default} uninstall $release
## Verify
k -n ${ns:-default} get $all |grep $release

```
- Sans `ingress`
- Sans `pv`,`pvc`
    - Grafana's default chart settings disable persistence.

@ Service 

```bash
## Grafana service
svc_name='grafana'
ns='dev'

# List services of a namespace 
k -n $ns get svc

# Cluster DNS : Naming convention
$svc_name.$ns.svc.cluster.local

abox='ngx'
k exec $abox -- curl -sLI $svc_name.$ns.svc.cluster.local
```
- `curl -L ...` to follow redirects (here: 302)

### Install [OpenLDAP](https://artifacthub.io/packages/helm/helm-openldap/openldap-stack-ha)

```text
bitnami/openldap:2.6.3                 15a5a8aaff11   5 months ago    155MB
osixia/phpldapadmin:0.9.0              78148b61fdb5   3 years ago     302MB
alpine/openssl:latest                  ca8d8f8ad3ed   3 years ago     8.04MB
tiredofit/self-service-password:5.2.3  407cc6751198   13 months ago   428MB

```

```bash
# Add repo
helm repo add helm-openldap https://jp-gouin.github.io/helm-openldap/
# Install chart
helm install my-openldap-stack-ha helm-openldap/openldap-stack-ha --version 4.1.1

## Environment
ns='dev'
release='ldap'
chart='helm-openldap/openldap-stack-ha'
ver='4.1.1' # OpenLDAP 2.6.3

# Install : --dry-run, then actually.
helm upgrade --install $release $chart \
    --version $ver \
    --namespace $ns \
    --atomic \
    --debug \
    --dry-run \
    |& tee helm.install.$ns.$release.log 

### Pull chart
helm pull $chart --version $ver # Dumps to $pulled
pulled=$(find . -type f -iname '*.tgz' -printf %f |head -n1 |sed 's#.tgz##')
tar -xaf $pulled.tgz            # Extracts to $extracted
extracted=$(find . -maxdepth 1 -type d ! -iname '.' -printf "%f\n" |head -n1)

helm upgrade --install $release $extracted \
    --version $ver \
    --namespace $ns \
    --atomic \
    --debug \
    |& tee helm.install.$ns.$release.log 

## Monitor
label="app.kubernetes.io/instance=$release"
all='deploy,sts,rs,pod,ep,svc,ingress,cm,secret,pvc,pv'

k -n ${ns:-default} get $all --selector $label \
    |tee k-n.${ns:-default}.get_all.selector.instance.$release.log

# Get sts manifest (YAML)
k -n ${ns:-default} get sts --selector $label \
    -o yaml |tee k-n.${ns:-default}.get.sts.${release}.yaml

## Teardown
helm -n ${ns:-default} uninstall $release
## Verify
k -n ${ns:-default} get $all |grep $release
```
- `helm.install.ldap.log`


### Install [`gaffer/hdfs`](https://artifacthub.io/packages/helm/gaffer/hdfs) Chart | [GitHub](https://github.com/gchq/Gaffer)

#### TL;DR 

Success at deploying a single node (`minikube`) HDFS. The helm chart is configured for for 3 datanodes and 1 namenode, but can run all on one. 

The Hadoop client (`hdfs`) is used to verify the existence of HDFS, 
as well as its read/write methods by push/pull between HDFS and local FS.

#### See `DevOps/.../Hadoop/LOG.md`

### Install [`bitnami/keycloak`](https://artifacthub.io/packages/helm/bitnami/keycloak) Chart

>Keycloak SSO server runs as an overlay on top of Wildfly (AKA JBoss; Java EE; Java EAP) application server. RedHat project. Latest: `22.0.0`

[Getting Started @ Kubernetes](https://www.keycloak.org/getting-started/getting-started-kube) | [Docs](https://www.keycloak.org/documentation.html) | [GitHub](https://github.com/keycloak/keycloak)

#### TL;DR

Success.

#### Install the chart

```bash
## Set Environment
ns='dev'
release='kc'
chart='bitnami/keycloak'
ver='15.1.8' # Keycloak v21.1.2
ver='16.1.2' # Keycloak v22.0.1

k create ns $ns

## Install the chart : --dry-run, then actually.
helm upgrade --install $release $chart \
    --version $ver \
    --create-namespace \
    --namespace ${ns:-default} \
    --atomic \
    --debug \
    --dry-run \
    |& tee helm.install.$ns.$release.log

### Pull chart
helm pull $chart --version $ver # Dumps to $pulled
tar -xaf $pulled.tgz            # Extracts to $release
mv $release $pulled

### Install/Upgrade chart            
helm upgrade --install -f values.yaml $release $chart |& tee helm.upgrade.$release.log

## Monitor
label="app.kubernetes.io/instance=$release"
all='deploy,sts,rs,pod,ep,svc,ingress,cm,secret,pvc,pv'

k -n ${ns:-default} get $all --selector $label \
    |tee k-n.${ns:-default}.get_all.selector.instance.$release.log

## Teardown
helm -n ${ns:-default} uninstall $release
## Verify
k -n ${ns:-default} get $all |grep $release
```

#### Install Ingress

```bash
k apply -f kc-ingress.yaml
k -n ${ns:-default} get ingress
```

Get all resources at current (`ns=dev`) namespace:

```bash
all='deploy,sts,rs,pod,ep,svc,ingress,cm,secret,pvc,pv'
k -n ${ns:-default} get $all
```

Add Minkiube's IP address as local DNS resolver at `/etc/hosts` entry

```bash
# Append entries 
echo "$(minikube ip) keycloak.local ngx.local" \
    |sudo tee -a /etc/hosts 

```
- Get list of service names
```bash
k -n ${ns:-default} get ingress |awk '{print $3}' |grep -v HOSTS
```

Test @ Reach-in

```bash
export http_proxy='socks5h://127.0.0.1:5522'
curl -sI keycloak.local             # HTTP/1.1 200 OK ...

export https_proxy='socks5h://127.0.0.1:5522'
curl -skI https://keycloak.local    # HTTP/1.1 200 OK ...

```


### Install [`sonatype/nexus`](https://artifacthub.io/packages/helm/sonatype/nexus-repository-manager) Chart

#### TL;DR 

Success! 

~~Deployment failing @ `MinimumReplicasUnavailable`~~ (Be patient!)

Also, ...

>⚠️ Archive Notice
As of October 24, 2023, we will no longer update or support this Helm chart.

>Deploying Nexus Repository in containers with an embedded database has been ___known to corrupt the database___ under some circumstances. We strongly recommend that you use an external PostgreSQL database for Kubernetes deployments.

If you are deploying in AWS, you can use our  to deploy Nexus Repository in an EKS cluster.

>We do not currently provide Helm charts for on-premises deployments using PostgreSQL. For those wishing to deploy on premises, see our []... information](https://help.sonatype.com/repomanager3/planning-your-implementation/resiliency-and-high-availability/single-data-center-on-premises-deployment-example-using-kubernetes) and sample YAMLs to help you plan a resilient on-premises deployment.

Add repo / Install app

```bash
helm repo add sonatype https://sonatype.github.io/helm3-charts/

helm install nex sonatype/nexus-repository-manager --version 57.0.0
```

```bash
$ kubectl get all

NAME                                                READY   STATUS    RESTARTS      AGE
pod/nex-nexus-repository-manager-76dc6d5fb9-59x4n   1/1     Running   6 (28m ago)   56m

NAME                                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/kubernetes                     ClusterIP   10.96.0.1       <none>        443/TCP    27h
service/nex-nexus-repository-manager   ClusterIP   10.111.34.231   <none>        8081/TCP   56m

NAME                                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nex-nexus-repository-manager   1/1     1            1           56m

NAME                                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/nex-nexus-repository-manager-76dc6d5fb9   1         1         1       56m
```


### Install [`stevehipwell/nexus3`](https://artifacthub.io/packages/helm/stevehipwell/nexus3) Chart

#### TL;DR 

Success

#### Add repo / Install app

```bash
helm repo add stevehipwell https://stevehipwell.github.io/helm-charts/

helm install my-nexus3 stevehipwell/nexus3 --version 4.31.0
```

#### Verify

```bash
$ kubectl get all

NAME                             READY   STATUS    RESTARTS   AGE
pod/my-nexus3-69d49695b8-d2dxj   1/1     Running   0          26m

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP    26h
service/my-nexus3    ClusterIP   10.100.128.174   <none>        8081/TCP   26m

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-nexus3   1/1     1            1           26m

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/my-nexus3-69d49695b8   1         1         1       26m

```









### Install [`bitnami/jenkins`](https://artifacthub.io/packages/helm/bitnami/jenkins) Chart

#### TL;DR 

Success!

See `DevOps/.../minikube/jenkins/LOG.md`


### Install [`bitnami/mysql`](https://artifacthub.io/packages/helm/bitnami/mysql) Chart

#### TL;DR 

Success!

Find/Add Bitnami repo at ArtifactHUB.io

```bash
# Get repo page URL
$ helm search hub mysql |grep bitnami
#=> https://artifacthub.io/packages/helm/bitnami/mysql
# Add repo
$ helm repo add bitnami https://charts.bitnami.com/bitnami # info @ webpage
$ helm repo update
```

#### Deploy/Verify

```bash
$ helm install bitnami/mysql --generate-name

$ watch kubectl get all
NAME                     READY   STATUS    RESTARTS   AGE
pod/mysql-1689074637-0   1/1     Running   0          22m

NAME                                TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/kubernetes                  ClusterIP   10.96.0.1     <none>        443/TCP    18h
service/mysql-1689074637            ClusterIP   10.101.2.53   <none>        3306/TCP   22m
service/mysql-1689074637-headless   ClusterIP   None          <none>        3306/TCP   22m

NAME                                READY   AGE
statefulset.apps/mysql-1689074637   1/1     22m

$ helm list
NAME            	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART       	APP VERSION
mysql-1689074637	default  	1       	2023-07-11 07:24:01.814414252 -0400 EDT	deployed	mysql-9.10.5	8.0.33     

$ helm status $(helm list |grep mysql |awk '{print $1}')
#=> Same info as at chart install

$ helm uninstall $(helm list |grep mysql |awk '{print $1}')
```

