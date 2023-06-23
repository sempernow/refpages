
# [Helm](https://helm.sh/docs/) | [Releases](https://github.com/helm/helm/releases) | [`ArtifactHUB.io`](https://artifacthub.io/packages/search?category=7&sort=relevance&page=1)

## TL;DR 

Helm Charts install @ `minikube` sans `helm-tiller` 
or any other non-default addon.


## [Install Helm](https://helm.sh/docs/intro/install/)

Install a select version ([Releases](https://github.com/helm/helm/releases))

```bash
release='helm-v3.12.1-linux-amd64.tar.gz'
tar -zaf $release
sudo mv linux-amd64/helm /usr/local/bin/helm
```

Or install the latest

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
vim get_helm.sh # Examine it.
sudo /bin/bash ./get_helm.sh
```

Verify

```bash
helm version
```
```text
version.BuildInfo{Version:"v3.12.1", GitCommit:"f32a52...", GitTreeState:"clean", GoVersion:"go1.20.4"
```

## Commands

```bash
# Search for a chart @ ArtifactHub.io (hub)
helm search hub $app |grep $repo
# Search for chart locally (against all repos of `helm list`)
helm search repo $app_or_keyword # All versions : --versions, -l
## Or
chart=$repo/$app #=> bitnami/nginx
docker image ls |grep $chart_or_keyword
## Or, if apropos
minikube ssh docker image ls |grep $chart_or_keyword

# Add repo of ArtifactHUB.io 
helm repo add hub $url
# Update repos list (cache)
helm repo update
# List installed chart(s) : k8s resources created per chart(s)
helm list 

# Install a chart : $release is any name (Service name).
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
```

## Charts Examples

|App               |Repo/Chart           |Version |Image|
|------------------|---------------------|--------|-----|
|Jenkins CI Server |`jenkinsci/jenkins`  |`4.3.30`|`jenkins/jenkins:2.401.2-jdk11`|
|Hadoop HDFS       |`gaffer/hdfs`        |`2.0.0` |`:3.3.3`|
|Keycloak SSO      |`bitnami/keycloak`   |`21.1.2`|`bitnami/keycloak:15.1.6`|
|Nexus Repo Manager|`sonatype/nexus3`    |`57.0.0`|`sonatype/nexus3:3.57.0`|
|Nexus Repo Manager|`stevehipwell/nexus3`|`4.31.0`|`sonatype/nexus3:3.57.0`|
|MySQL DB          |`bitnami/mysql`      |`9.10.5`|`bitnami/mysql:8.0.33`|


```bash
$ helm repo list

jenkinsci   	https://charts.jenkins.io/                 
bitnami     	https://charts.bitnami.com/bitnami         
gaffer      	https://gchq.github.io/gaffer-docker       
sonatype    	https://sonatype.github.io/helm3-charts/   
stevehipwell	https://stevehipwell.github.io/helm-charts/

```
```bash
$ helm list

NAME       	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART         	APP VERSION
gaffer-hdfs	default  	1       	2023-07-11 10:22:12.015571783 -0400 EDT	deployed	hdfs-2.0.0    	3.3.3      
my-release 	default  	1       	2023-07-11 08:52:55.327007108 -0400 EDT	deployed	jenkins-12.2.3	2.401.2    
```

## Install [`bitnami/mysql`](https://artifacthub.io/packages/helm/bitnami/mysql) Chart

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


## [`bitnami/jenkins`](https://artifacthub.io/packages/helm/bitnami/jenkins) Chart

### TL;DR 

Success!

### Install 

```bash
helm install my-release oci://registry-1.docker.io/bitnamicharts/jenkins
```

### Monitor 

```bash
watch kubectl get all
```
```text
NAME                                      READY   STATUS    RESTARTS   AGE
pod/my-release-jenkins-6958dcfd54-lxrkg   1/1     Running   0          5m44s

NAME                         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
service/kubernetes           ClusterIP      10.96.0.1      <none>        443/TCP                      19h
service/my-release-jenkins   LoadBalancer   10.108.7.113   <pending>     80:30043/TCP,443:30814/TCP   5m44s

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-release-jenkins   1/1     1            1           5m44s

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/my-release-jenkins-6958dcfd54   1         1         1       5m44s
```
```bash
$ release='my-release'
$ kubectl describe pod ${release}-jenkins-6958dcfd54-lxrkg 
$ kubectl describe secret ${release}-jenkins 
$ helm status my-release # Useful info : user/pass, etc.
$ pw=$(kubectl get secret --namespace default ${release}-jenkins -o jsonpath="{.data.jenkins-password}" | base64 -d)
```
- Note: `-o jsonpath="{.data.jenkins-password}"`
  - [Configuration Params keys-vals for `bitnami/jenkins`](https://artifacthub.io/packages/helm/bitnami/jenkins#jenkins-configuration-parameters) 

Hit the loadbalancer (`10.108.7.113`) from inside the control node:

```bash
$ minikube ssh "curl -I 10.108.7.113"               #=> HTTP 403 Access Denied
$ minikube ssh "curl -I -u 'user:' 10.108.7.113"    #=> HTTP 401 Unauthorized
$ minikube ssh "curl -I -u 'user:$pw' 10.108.7.113" #=> HTTP 200 OK
```
- See `helm status $release`

## Install [`gaffer/hdfs`](https://artifacthub.io/packages/helm/gaffer/hdfs) Chart | [GitHub](https://github.com/gchq/Gaffer) Chart

Deployment of Hadoop by Helm Chart onto K8s/Minikube

Repo has guides for deployment @:

- `kind` (Kubernetes IN Docker) cluster
- AWS EKS cluster

### TL;DR 

Success at deploying a single node (`minikube`) HDFS. The helm chart is configured for for 3 datanodes and 1 namenode, but can run all on one. 

The Hadoop client (`hdfs`) is used to verify the existence of HDFS, 
as well as its read/write methods by push/pull between HDFS and local FS.


### @ `minikube` (@ `vm078`)

PWD @ Dropbox/CIFS share dir : `[4n52626@ONXWQBLCS078 gaffer-hadoop]`

```bash
# Add the repo
helm repo add gaffer https://gchq.github.io/gaffer-docker
helm repo update
# Install the chart
helm install gaffer-hdfs gaffer/hdfs --version 2.0.0

# Monitor the Deployment 
kubectl get all
```
```text
NAME                                      READY   STATUS    RESTARTS   AGE
pod/gaffer-hdfs-datanode-0                1/1     Running   0          3m14s
pod/gaffer-hdfs-datanode-1                1/1     Running   0          3m14s
pod/gaffer-hdfs-datanode-2                1/1     Running   0          3m14s
pod/gaffer-hdfs-namenode-0                1/1     Running   0          3m14s
pod/gaffer-hdfs-shell-6dcf4c7966-rk4bc    1/1     Running   0          3m14s

NAME                            TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                               AGE
service/gaffer-hdfs-datanodes   ClusterIP      10.111.248.213   <none>        80/TCP                                3m15s
service/gaffer-hdfs-namenodes   ClusterIP      None             <none>        9870/TCP,8020/TCP,8021/TCP,8022/TCP   3m15s
service/kubernetes              ClusterIP      10.96.0.1        <none>        443/TCP                               21h

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/gaffer-hdfs-shell    1/1     1            1           3m14s

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/gaffer-hdfs-shell-6dcf4c7966    1         1         1       3m14s

NAME                                    READY   AGE
statefulset.apps/gaffer-hdfs-datanode   3/3     3m14s
statefulset.apps/gaffer-hdfs-namenode   1/1     3m14s

```

### Exec shell @ Datanode(s)

#### Run client (`hdfs`) command(s):

```bash
# Get environment
$ kubectl exec -it pod/gaffer-hdfs-datanode-0 -- \
  hdfs envvars 

JAVA_HOME='/usr/lib/jvm/java-8-openjdk-amd64/jre/'
HADOOP_HDFS_HOME='/opt/hadoop'
HDFS_DIR='share/hadoop/hdfs'
HDFS_LIB_JARS_DIR='share/hadoop/hdfs/lib'
HADOOP_CONF_DIR='/etc/hadoop/conf'
HADOOP_TOOLS_HOME='/opt/hadoop'
HADOOP_TOOLS_DIR='share/hadoop/tools'
HADOOP_TOOLS_LIB_JARS_DIR='share/hadoop/tools/lib'

# No write permssions for USER:
$ kubectl exec -it pod/gaffer-hdfs-datanode-0 -- \
    ls -ahl /opt/hadoop/share/hadoop/hdfs

total 20M
drwxr-xr-x. 6 root root 4.0K May  9  2022 .
drwxr-xr-x. 8 root root   88 May  9  2022 ..
-rw-r--r--. 1 root root 5.8M May  9  2022 hadoop-hdfs-3.3.3-tests.jar
-rw-r--r--. 1 root root 6.0M May  9  2022 hadoop-hdfs-3.3.3.jar
-rw-r--r--. 1 root root 127K May  9  2022 hadoop-hdfs-client-3.3.3-tests.jar
-rw-r--r--. 1 root root 5.3M May  9  2022 hadoop-hdfs-client-3.3.3.jar
-rw-r--r--. 1 root root 246K May  9  2022 hadoop-hdfs-httpfs-3.3.3.jar
-rw-r--r--. 1 root root 9.4K May  9  2022 hadoop-hdfs-native-client-3.3.3-tests.jar
-rw-r--r--. 1 root root 9.4K May  9  2022 hadoop-hdfs-native-client-3.3.3.jar
-rw-r--r--. 1 root root 113K May  9  2022 hadoop-hdfs-nfs-3.3.3.jar
-rw-r--r--. 1 root root 431K May  9  2022 hadoop-hdfs-rbf-3.3.3-tests.jar
-rw-r--r--. 1 root root 1.1M May  9  2022 hadoop-hdfs-rbf-3.3.3.jar
drwxr-xr-x. 2 root root 4.0K May  9  2022 jdiff
drwxr-xr-x. 2 root root 4.0K May  9  2022 lib
drwxr-xr-x. 2 root root 4.0K May  9  2022 sources
drwxr-xr-x. 9 root root  106 May  9  2022 webapps

# USER : 1000 (hadoop)
$ kubectl exec -it pod/gaffer-hdfs-datanode-2 -- \
  id 

uid=1000(hadoop) gid=1000(hadoop) groups=1000(hadoop)

# The only local FS dirs allowing USER to write are data0, data1, ...

$ kubectl exec -it pod/gaffer-hdfs-datanode-0 -- \
    ls -ahl /

total 4.0K
...
drwxrwxrwx.   3 root   root     17 Jul 11 14:23 data0
drwxr-x---.   2 hadoop hadoop    6 Jun  2 17:34 data1
drwxr-x---.   2 hadoop hadoop    6 Jun  2 17:34 data2
drwxr-x---.   2 hadoop hadoop    6 Jun  2 17:34 data3
drwxr-x---.   2 hadoop hadoop    6 Jun  2 17:34 data4
drwxr-x---.   2 hadoop hadoop    6 Jun  2 17:34 data5
drwxr-x---.   2 hadoop hadoop    6 Jun  2 17:34 data6
drwxr-x---.   2 hadoop hadoop    6 Jun  2 17:34 data7
drwxr-x---.   2 hadoop hadoop    6 Jun  2 17:34 data8
...

$ kubectl exec -it pod/gaffer-hdfs-datanode-0 -- \
    ls -ahl /opt/hadoop/share/hadoop/hdfs

total 4.0K
drwxr-xr-x. 3 hadoop hadoop  67 Jul 11 14:23 .
drwx------. 3 hadoop hadoop  40 Jul 11 14:23 ..
drwx------. 4 hadoop hadoop  54 Jul 11 14:23 BP-915664161-10.244.0.19-1689085364256
-rw-r--r--. 1 hadoop hadoop 229 Jul 11 14:23 VERSION

```

#### Push from local FS to HDFS

HDFS Write/Read a directory

```bash
# Make dir @ datanode-0
$ kubectl exec -it pod/gaffer-hdfs-datanode-0 -- \
  hdfs dfs -mkdir -p /foo/bar/baz

# Read dir @ datanode-1
$ kubectl exec -it pod/gaffer-hdfs-datanode-1 -- \
  hdfs dfs -ls /foo/bar

Found 1 items
drwxr-xr-x   - hadoop supergroup          0 2023-07-11 15:27 /foo/bar/baz

# Read dir @ datanode-2
$ kubectl exec -it pod/gaffer-hdfs-datanode-2 -- \
  hdfs dfs -ls /foo/

Found 1 items
drwxr-xr-x   - hadoop supergroup          0 2023-07-11 15:27 /foo/bar

```

HDFS Write/Read a file

```bash
# Create file on local FS
$ kubectl exec -it pod/gaffer-hdfs-datanode-2 -- \
  touch /data0/foo

# Verify @ local
$ kubectl exec -it pod/gaffer-hdfs-datanode-2 -- \
  ls -hal /data0/foo

-rw-r--r--. 1 hadoop hadoop 0 Jul 11 15:47 /data0/foo

# Put local file on HDFS : @ datanode-2
$ kubectl exec -it pod/gaffer-hdfs-datanode-2 -- \
  hdfs dfs -put /data0/foo /foo/bar/

# Verify @ HDFS : @ datanode-0
$ kubectl exec -it pod/gaffer-hdfs-datanode-0 -- \
  hdfs dfs -ls /foo/bar/

Found 2 items
drwxr-xr-x   - hadoop supergroup          0 2023-07-11 15:27 /foo/bar/baz
-rw-r--r--   3 hadoop supergroup          0 2023-07-11 15:48 /foo/bar/foo

```

#### Pull from HDFS to local FS 

```bash
# Verify local FS file is on datanode-2
$ kubectl exec -it pod/gaffer-hdfs-datanode-2 -- \
  ls -hal /data0/foo

-rw-r--r--. 1 hadoop hadoop 0 Jul 11 15:47 /data0/foo

# Verify local FS file is NOT on datanode-0
$ kubectl exec -it pod/gaffer-hdfs-datanode-0 -- \
  ls -hal /data0/foo

ls: cannot access '/data0/foo': No such file or directory

# Pull from HDFS to local FS @ datanode-0
$ kubectl exec -it pod/gaffer-hdfs-datanode-0 -- \
  hdfs dfs -get /foo/bar/foo /data0/foo

# Verify
$ kubectl exec -it pod/gaffer-hdfs-datanode-0 -- \
  ls -ahl /data0/foo

-rw-r--r--. 1 hadoop hadoop 0 Jul 11 16:14 /data0/foo

```


## Install [`bitnami/keycloak`](https://artifacthub.io/packages/helm/bitnami/keycloak) Chart

#### TL;DR

Success.

#### Install @ its own namespace

```bash
release=bitnami-keycloak
chart=bitnami/keycloak

# Install Chart @ kc namespace
$ kubectl create ns kc
$ helm install $release $chart --version 15.1.6 --namespace kc

# Monitor
$ watch kubectl get all -n kc

NAME                                READY   STATUS    RESTARTS   AGE
pod/bitnami-keycloak-0              1/1     Running   0          5m16s
pod/bitnami-keycloak-postgresql-0   1/1     Running   0          5m16s

NAME                                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/bitnami-keycloak                 ClusterIP   10.99.68.120    <none>        80/TCP     5m18s
service/bitnami-keycloak-headless        ClusterIP   None            <none>        80/TCP     5m18s
service/bitnami-keycloak-postgresql      ClusterIP   10.109.63.109   <none>        5432/TCP   5m18s
service/bitnami-keycloak-postgresql-hl   ClusterIP   None            <none>        5432/TCP   5m18s

NAME                                           READY   AGE
statefulset.apps/bitnami-keycloak              1/1     5m17s
statefulset.apps/bitnami-keycloak-postgresql   1/1     5m17s

# Helm
$ helm list -n kc

NAME            	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART          	APP VERSION
bitnami-keycloak	kc       	1       	2023-07-11 14:29:28.178045319 -0400 EDT	deployed	keycloak-15.1.6	21.1.2     

```

## Install [`sonatype/nexus`](https://artifacthub.io/packages/helm/sonatype/nexus-repository-manager) Chart

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


## Install [`stevehipwell/nexus3`](https://artifacthub.io/packages/helm/stevehipwell/nexus3) Chart

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







