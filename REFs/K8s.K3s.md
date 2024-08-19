# [K3S](https://docs.k3s.io/ "docs.k3s.io")

>*K3s is a lightweight "batteries included" Kubernetes distribution created by Rancher Labs, and is a CNCF project. K3s is __highly available and production-ready__. It has a very small binary size and very low resource requirements.* &mdash; [traefiklabs.io](https://traefik.io/glossary/k3s-explained/)


- CRI: containerd / cri-dockerd container runtime (CRI)
- CNI: Flannel Container Network Interface (CNI)
- CSI: Local-path-provisioner Persistent Volume controller
- DNS: CoreDNS Cluster DNS
- Ingress: Traefik Ingress controller
- LB: [ServiceLB](https://docs.k3s.io/networking/networking-services#service-load-balancer "docs.k3s.io") Load-Balancer controller
    - Formerly [Klipper LB](https://github.com/k3s-io/klipper-lb "GitHub : /k3s-io/klipper-lb") : `docker.io/rancher/klipper-lb:v0.4.7`
    - [*&hellip; to set up those DNAT iptables rules on the node.*](https://github.com/k3s-io/k3s/discussions/9927)
        - &hellip; watches Kubernetes Services with the `spec.type` field set to `LoadBalancer`. 
        - For each __LoadBalancer__ Service, a __DaemonSet__ is created in the `kube-system` namespace. This DaemonSet in turn creates Pods with a `svc-` prefix, on each node. These Pods use __iptables__ to forward traffic from the Pod's __NodePort__, to the Service's __ClusterIP__ address and port.
- Network Policy: Kube-router Network Policy controller
- Registry: Spegel distributed container image registry mirror
- Host configuration: Host utilities (iptables, socat, etc)


## TL;DR

Unconventional distro. Installs quickly and includes *All The Things*; CRI, CNI, service load balancer, and ingress controller. It is designed for use by root, yet tooling is installed canonically (`/usr/local/bin`), so ensure root `PATH` has that path.

Includes a [`k3s` CLI](https://docs.k3s.io/cli), 
which functions as some kind of wrapper 
for some or all of the related tools 
to perform a variety of common cluster-administration tasks.

The distro also includes an [embedded Helm](https://docs.k3s.io/helm), 
which is deployed as a K8s resource.

K3s requires **zero configuration** for its default "*batteries included*" cluster,

```bash
sudo k3s server
```
but here are the locations of all configuration files, 
if and where created to further configure:

- `/etc/rancher/k3s/config.yaml`
    - @ CLI : `k3s --config $file`
- `/etc/systemd/system/k3s.service.env`
    - @ systemd : `systemctl status k3s.service` 

## [Quick Start](https://docs.k3s.io/quick-start)

### [Requirements](https://docs.k3s.io/installation/requirements?os=rhel#inbound-rules-for-k3s-nodes)


@ RHEL 9

```bash
# Configure host
sudo su
systemctl disable firewalld --now
sudo setenforce 0 
sudo sed -i -e 's/^SELINUX=disabled/SELINUX=permissive/' /etc/selinux/config
sudo sed -i -e 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
[[ $(systemctl list-unit-files |grep nm-cloud) ]] && 
    systemctl disable nm-cloud-setup.service nm-cloud-setup.timer

reboot

```

### [Installation](https://docs.k3s.io/installation) 

#### Script method

```bash
# Install 
curl -sfL https://get.k3s.io |sh - &&
    sudo chmod 0644 /etc/rancher/k3s/k3s.yaml

# Configure for root user
path=/usr/local/bin
[[ $(sudo -i env |grep 'PATH=' |grep $path) ]] || 
    [[ $(sudo cat /root/.bashrc |grep 'PATH=' |grep $path) ]] ||
        echo 'export PATH=$PATH:'"$path" |sudo tee -a /root/.bashrc

# Check config
k3s check-config

# Configure for regular user 
alias k='k3s kubectl'
```
- See [`get.k3s.io.sh`](get.k3s.io.sh) for configuration by environment
- The K3s service is **configured to automatically restart** 
  after node reboots or if process crashes or is killed:
    ```plaintext
    $ pstree |grep -B100 k3s
    systemd-+-2*[agetty]
            ...
            |-k3s-server-+-containerd---22*[{containerd}]
    ```
    - [`systemctl status k3s.service`](systemctl.status.k3s.service.log)
- Additional utilities are installed; `kubectl`, `crictl`, `ctr`, `k3s-killall.sh`, and `k3s-uninstall.sh`
- The `kubeconfig` for "`k3s kubectl`&hellip;" is created at [`/etc/rancher/k3s/k3s.yaml`](etc.rancher.k3s.yaml). 
  This does *not* affect `/usr/local/bin/kubectl` unless further configured to do so.
- [`ca-certificate-data`](kubeconfig.certificate-authority-data.openssl.x509.log)
    ```bash
    $ k3s kubectl config view --raw \
        -o jsonpath='{.clusters[].cluster.certificate-authority-data}' \
        |base64 -d \
        |openssl x509 -text
    
    ```
- [`k get node,deploy,ds,sts,svc,ingress`](k.get.objs-A.log)
- [`k top node`](k.top.node.log)
- [`k top pod -A`](k.top.pod-A.log)

#### [Binary method](https://docs.k3s.io/installation/configuration#configuration-with-binary)

```bash
# Select release : https://github.com/k3s-io/k3s/releases
v=1.30.3 # K8s version available at K3s
# Pull k3s CLI
curl -sSLO https://github.com/k3s-io/k3s/releases/download/v${v}%2Bk3s1/k3s
# Init cluster
sudo k3s server --cluster-init

```

### [Teardown](https://docs.k3s.io/upgrades/killall#killall-script)

Use the [`k3s-killall.sh`](k3s-killall.sh) script 
to stop all of the K3s containers and reset the `containerd` state. 
**It cleans up** containers, K3s directories, and networking components 
while also removing the `iptables` chain with all the associated rules. 

The cluster data will not be deleted.

```bash
/usr/local/bin/k3s-killall.sh
```

### [Uninstall](https://docs.k3s.io/installation/uninstall)

>Uninstalling K3s deletes the local cluster data, configuration, and all of the scripts and CLI tools.

```bash
# Server (Control) teardown
/usr/local/bin/k3s-uninstall.sh
# Agent (Worker) teardown
/usr/local/bin/k3s-agent-uninstall.sh
```

## [Configuration](https://docs.k3s.io/advanced)

>In general, CLI arguments map to their respective YAML key, 
>with repeatable CLI arguments being represented as YAML lists. 
>Boolean flags are represented as `true` or `false` in the YAML file.

```bash
k3s server \
    --write-kubeconfig-mode "0644"    \
    --tls-san "foo.local"             \
    --node-label "foo=bar"            \
    --node-label "something=amazing"  \
    --cluster-init

# OR
k3s server --config /etc/rancher/k3s/config.yaml --cluster-init
```
- @ `/etc/rancher/k3s/config.yaml`
    ```yaml
    write-kubeconfig-mode: "0644"
    tls-san:
    - "foo.local"
    node-label:
    - "foo=bar"
    - "something=amazing"
    cluster-init: true
    ```

Equivalent syntaxes:

```bash
K3S_KUBECONFIG_MODE="644" k3s server
# OR
k3s server --write-kubeconfig-mode=644
```

### [Air-gap Install](https://docs.k3s.io/installation/airgap)

1. Configure host
1. Install `containerd`
1. Load images of a K3s release into private registry
    - [Releases](https://github.com/k3s-io/k3s/releases)

Preliminaries requiring internet access

```bash
# Select release : https://github.com/k3s-io/k3s/releases
v=1.30.3 # K8s version available at K3s

# Pull K3s-images tarball
tarball=k3s-airgap-images-amd64.tar.gz
curl -sSLO https://github.com/k3s-io/k3s/releases/download/v${v}%2Bk3s1/$tarball

# Load all images (later/elsewhere) into local cache 
# for subsequent tag/push to private registry of target air-gap environment.
docker load -i $tarball

# Pull k3s CLI
curl -sSLO https://github.com/k3s-io/k3s/releases/download/v${v}%2Bk3s1/k3s
```

### [HA K3s](https://docs.k3s.io/architecture#high-availability-k3s)


## Usage 

```bash
sudo k3s kubectl 
# OR
alias k='sudo k3s kubectl'
```

K3s installs `ServiceLB` as Service `traefic` of type `LoadBalancer` 
to provide a "public" entrypoint to the cluster; **`EXTERNAL-IP`** address. 

```bash
$ k -n kube-system get svc traefik
NAME      TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
traefik   LoadBalancer   10.43.77.118   172.27.240.169   80:32083/TCP,443:30823/TCP   128m

$ ip=$(k -n kube-system get svc traefik -o jsonpath='{.status.loadBalancer.ingress[].ip}')

```

```bash
curl -ki https://172.27.240.169:6443/version/
```
```plaintext
HTTP/2 401
audit-id: 955d99ca-9427-41b1-9e7d-c1377f630d00
cache-control: no-cache, private
content-type: application/json
...
```
```json

{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}
```
[Authenticate by Bearer token](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#service-account-tokens) created of a `ServiceAccount`:

```bash
$ k -n kube-system get sa
NAME                                          SECRETS   AGE
...
default                                       0         150m
...

$ k -n kube-system create token default
```
Adding that raw token string (`TOKEN`) at "`Authorization: Bearer TOKEN`" request-header value:

```bash
ip=$(k -n kube-system get svc traefik -o jsonpath='{.status.loadBalancer.ingress[].ip}')

curl -k -H "Authorization: Bearer $(k -n kube-system create token default)" https://$ip:6443/healthz?verbose
```
```plaintext
[+]ping ok
[+]log ok
[+]etcd ok
[+]poststarthook/start-apiserver-admission-initializer ok
...
healthz check passed
```

Authenticate using certificate and key of `kubeconfig`.

```bash
alias k='sudo k3s kubectl'
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

ip=$(k -n kube-system get svc traefik -o jsonpath='{.status.loadBalancer.ingress[].ip}')

k config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' \
    |base64 -d \
    |tee client.crt

k config view --raw -o jsonpath='{.users[0].user.client-key-data}' \
    |base64 -d \
    |tee client.key

curl -k --cert client.crt \
        --key client.key \
        https://$ip:6443/healthz?verbose

# OR, all in one:
curl -k \
    --cert <(k config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' |base64 -d) \
    --key <(k config view --raw -o jsonpath='{.users[0].user.client-key-data}' |base64 -d) \
    https://$(k -n kube-system get svc traefik -o jsonpath='{.status.loadBalancer.ingress[].ip}'):6443/healthz?verbose
```

@ `/healthz?verbose`

```plaintext
[+]ping ok
[+]log ok
[+]etcd ok
[+]poststarthook/start-apiserver-admission-initializer ok
...
healthz check passed
```

@ `/version`

```json
{
  "major": "1",
  "minor": "30",
  "gitVersion": "v1.30.3+k3s1",
  "gitCommit": "f646604010affc6a1d3233a8a0870bca46bf80cf",
  "gitTreeState": "clean",
  "buildDate": "2024-07-31T20:30:52Z",
  "goVersion": "go1.22.5",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

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

