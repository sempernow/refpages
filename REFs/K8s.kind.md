# `kind` : [Kubernetes in Docker](https://kind.sigs.k8s.io/ "kind.sigs.k8s.io") | [Releases](https://github.com/kubernetes-sigs/kind/releases)

## TL;DR

`kind` is a tool for running local Kubernetes clusters 
using Docker container(s) as "node(s)". 
The app was designed for testing Kubernetes itself, 
but is widely used **for local development** or CI.


```bash
bash kind-install.sh
```
- [`kind-install.sh`](kind-install.sh)

## Install

```bash
unset arch
[[ $(uname -m) == x86_64 ]]  && arch=amd64
[[ $(uname -m) == aarch64 ]] && arch=arm64
# https://github.com/kubernetes-sigs/kind/releases
v=0.24.0
to=/usr/local/bin/kind
type -t kind && kind --version |grep $v || {
    [[ $arch ]] && { 
        sudo curl -sSLo $to https://kind.sigs.k8s.io/dl/v$v/kind-linux-$arch && 
        sudo chmod +x $to && 
        kind --version |grep $v || exit 1
    }
}

```

## Useage

```bash
# Create K8s cluster 
kind create cluster 
kind create cluster --name kind-other
kind create cluster --config custom-kind-config.yaml

# Create K8s cluster of a declared version 
img=kindest/node:v1.29.4@sha256:3abb816a5b1061fb15c6e9e60856ec40d56b7b52bcea5f5f1350bc6e2320b6f8
cat <<-EOH |kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: $img
- role: worker
  image: $img 
EOH

# Build kind from source (of declared version) and then create K8s cluster
ver=0.23.0
go install sigs.k8s.io/kind@v$ver && kind create cluster

```
- `kind create cluster` also creates `~/.kube` file(s).
- `kind delete cluster` also purges `~/.kube/config`
- [Configuration](#configuration) section has more of that.

&nbsp;

```bash
# Inspect
kind get clusters

# Use K8s-API client 
kubectl cluster-info # --context kind-kind
kubectl get ds,deploy,pod,cm,svc -A
kubectl get node -o wide
kubectl apply -f appx.yaml

# Load image(s) into cluster "node(s)" 
kind load docker-image $img_1 $img_2 --name kind-2
# Load image archive(s) into cluster "node(s)" 
kind load image-archive $img_1_tarball --name $cluster

# List images of a "node"
node=kind-control-plane
docker exec -it $node crictl images

# Teardown
kind delete cluster 
```

## [Configuration](https://kind.sigs.k8s.io/docs/user/configuration/) (YAML) <a name="configuration"></a>

Multi-node cluster 

```yaml
# Multi-node : 1 control-plane nodes and 2 worker nodes
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kind                      # Default
networking:
  podSubnet: "10.244.0.0/16"    # Default
networking:
  serviceSubnet: "10.96.0.0/12" # Default
networking:
  kubeProxyMode: "ipvs"         # iptables (default), nftables (v1.31+), or ipvs
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "my-label=true"  
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
        extraArgs:
          enable-admission-plugins: NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook 
- role: worker
- role: worker

```

Multi-node HA cluster 

```yaml
# Multi-node HA : 3 control and 3 workers
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: control-plane
- role: control-plane
- role: worker
- role: worker
  labels:
    tier: backend 
  extraMounts:
  - hostPath: /path/at/host
    containerPath: /whereever
- role: worker
  labels:
    tier: frontend
```

Map extra ports to host : `extraPortMappings`

```yaml
# Map extra ports to host 
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    listenAddress: "0.0.0.0"    # Optional, defaults to "0.0.0.0"
    protocol: udp               # Optional, defaults to tcp
```

Set the (K8s) [version](https://github.com/kubernetes-sigs/kind/releases "github.com/kubernetes-sigs/kind/releases")  

That versions page implies kind does not support all K8s versions.
Also note that version numbers of kind and kubernetes do not match. 
For example, kind `v0.23.0` defaults to K8s `v1.30.0` (`kindest/node:v1.30.0`) .

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.29.4@sha256:3abb816a5b1061fb15c6e9e60856ec40d56b7b52bcea5f5f1350bc6e2320b6f8
- role: worker
  image: kindest/node:v1.29.4@sha256:3abb816a5b1061fb15c6e9e60856ec40d56b7b52bcea5f5f1350bc6e2320b6f8
```

- `kind` supports multi-node (including HA) clusters
- `kind` supports building Kubernetes release builds from source
    - support for `make` / `bash` or `docker`, in addition to pre-published builds
- `kind` supports Linux, macOS and Windows
- `kind` is a CNCF certified conformant Kubernetes installer


**`kind` requires** one of: `docker`, `podman`, `nerdctl`.

If rootless (`podman`'s default configuration), 
then "`kind create cluster`" will fail. 
[The workaround for rootless-user environments](https://kind.sigs.k8s.io/docs/user/rootless/) 
is known to cause system-performance issues.

RHEL 8+ has `podman` already installed, and it (purposefully) conflicts with `docker`, 
so installing (switching to) the latter requires flags `--allowerasing` and (typically) `--nobest` :

### How to install Docker @ RHEL 8+

(This does *not* install the unnecessary [Docker Desktop](https://www.docker.com/ "docker.com").)

```bash
# Prep to install Docker
sudo dnf install -y dnf-utils
[[ -f /etc/yum.repos.d/docker-ce.repo ]] \
    || sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf makecache 

# Latest stable version
pkgs='docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin'
# Else a declared version 
## 1. Find it
yum list docker-ce --showduplicates |sort -r
  # docker-ce.x86_64     3:27.0.3-1.el9     docker-ce-stable
  # ...
  # docker-ce.x86_64     3:26.1.4-1.el9     docker-ce-stable
  # docker-ce.x86_64     3:26.1.3-1.el9     docker-ce-stable
  # ...
## 2. Select it
arch=x86_64
ver=27.0.3-1.el9
pkgs="docker-ce-$ver.$arch docker-ce-cli-$ver.$arch containerd.io docker-buildx-plugin docker-compose-plugin"

# Install Docker Engine (the server), client apps, and all their dependencies
sudo dnf install --allowerasing --nobest $pkgs
```
- Docker v1.12+ has `containerd` as its default (CRI-compliant) container runtime, yet Docker is *not* CRI-compliant, so Kubernetes requires a shim (`dockershim`) to interface with Docker regardless. It is not advised to use Docker with Kubernetes in production.


## [`ingress-nginx` : Install / Configure](https://kind.sigs.k8s.io/docs/user/ingress/) / Test

Ingress NGINX Controller

Docs/Configs per context:

- [K8s @ `kubernetes.github.io`](https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters)
- [kind @ `kind.sigs.k8s.io`](https://kind.sigs.k8s.io/docs/user/ingress/)

Create a cluster configured for ingress (controller) at ports `80` (HTTP) and `443` (HTTPS)

### @ `Ubuntu [14:20:12] [1] [#0] /s/DEV/devops/infra/kubernetes/kind`

```bash
kind create cluster --config kind-config-ingress-nginx.yaml
```
- @ [`kind-config-ingress-nginx.yaml`](kind-config-ingress-nginx.yaml)


Deploy Ingress NGINX Controller (`ingress-nginx`) using manifest configured for kind 

```bash
# kind-specific deployment manifest
url=https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# Install it
kubectl apply -f $url
# Verify it
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s
```

Save the ingress-nginx controller installation manifest 

```bash
curl -sSLo ingress-nginx-kind.yaml $url
```
- @ [`ingress-nginx-kind.yaml`](ingress-nginx-kind.yaml)

Usage : Deploy a test app

```bash
☩ k apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml
pod/foo-app created
service/foo-service created
pod/bar-app created
service/bar-service created
Warning: path /foo(/|$)(.*) cannot be used with pathType Prefix
Warning: path /bar(/|$)(.*) cannot be used with pathType Prefix
ingress.networking.k8s.io/example-ingress created

☩ curl localhost/foo/hostname
foo-app

☩ curl localhost/bar/hostname
bar-app
```
- Despite warnings, it works.
- Docker config may require use `node`'s `INTERNAL-IP` (Docker bridge network) __instead of `localhost`__.
  Obtain from either:
    - `ip=$(k get node kind-control-plane -o jsonpath='{.status.addresses[0].address}')`
    - `ip=$(docker network inspect kind |jq -Mr .[].Containers[].IPv4Address)`
    ```bash
    ☩ curl $ip/bar/hostname
    ```

Save the usage manifest

```bash
curl -sSLo ingress-nginx-kind-usage-oem.yaml https://kind.sigs.k8s.io/examples/ingress/usage.yaml
```
- @ [`ingress-nginx-kind-usage-oem.yaml`](ingress-nginx-kind-usage-oem.yaml)
- @ [`ingress-nginx-kind-usage.yaml`](ingress-nginx-kind-usage.yaml) 
    - Modify `hostname`s, from `foo-app` to `foo` (similary for `bar`), 
      and allow apply to `stack-test` namespace.

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

