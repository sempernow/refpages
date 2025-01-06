# K8s mTLS : How to rotate control-plane certificates 

>By default, a vanilla cluster automatically updates its (mTLS) control-plane certificates. 
In case it fails to do so (not unheard of), this is the recovery procedure.

1. Backup existing configuration
    - Process is cluster/distro dependent.
1. __Renew certificates__
    ```bash
    kubeadm certs renew all
    ```
    - If control plane is multi-node, then distribute new certs.
1. __Update the manifest of all Static Pods__ with the new TLS certificates. 
   This __requires the `ClusterConfiguration` manifest__ (`$kubeadm_config`).
    ```bash
    kubeadm init phase kubeconfig all --config $kubeadm_config
    ```
    - The `ClusterConfiguration` manifest may exist   
      at `/var/lib/kubelet/config.yaml`.   
      If not, capture it from its ConfigMap key: 
        ```bash
        kubectl get cm -n kube-system kubeadm-config -o jsonpath='{.data.ClusterConfiguration}'
        ```
1. __Delete all the old__ (existing) __Static Pods__ by temporarily 
  emptying the folder in which `kubelet` expects to find them.
    ```bash
    k8s=/etc/kubernetes/manifests
    tmp=/tmp/k8s-$(date '+%F')
    mkdir -p $tmp &&
        mv $k8s/*.yaml $tmp/ &&
            sleep 100 &&
                mv $tmp/*.yaml $k8s/
    ```


## Example using Kind cluster

Backup the existing cluster; snapshot the kind cluster's "node" (container):

```bash
# Commit container to new image (Imperative method of image creation)
☩ docker commit kind-control-plane kind-control-plane:$(date '+%F')
# Verify image 
☩ docker image ls --format "table {{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}" |grep kind-control
cc3dbd9204e6   kind-control-plane:2024-11-01                  1.04GB
```

Renew certificates

```bash
☩ docker exec -it kind-control-plane bash
root@kind-control-plane:/# kubeadm certs renew all
```

Distribute to all control-plane nodes @ `/etc/kubernetes/pki/`

Update manifests of all Static Pods with new kubeconfig (TLS certificates).

This requires the `ClusterConfiguration`, so first verify that we have that.

If it exists, e.g., `/etc/kubernetes/kubeadm-config.yaml`, use that.
Else extract it from the relevant ConfigMap
working from the node (container) to capture it:

```bash
☩ docker exec -it kind-control-plane bash
root@kind-control-plane:/# kubectl get cm -n kube-system kubeadm-config \
    -o jsonpath='{.data.ClusterConfiguration}' \
    |tee /etc/kubernetes/kubeadm-config.yaml
```

Having the `ClusterConfiguration` (YAML), 
we now update the Static Pod manifests:

```bash
☩ docker exec -it kind-control-plane bash
root@kind-control-plane:/# [[ -f /etc/kubernetes/kube-config.yaml ]] &&
    kubeadm init phase kubeconfig all --config /etc/kubernetes/kubeadm-config.yaml
```

Kind's `ClusterConfiguration` (example)
@ `/etc/kubernetes/kubeadm-config.yaml`

```yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
apiServer:
  certSANs:
  - localhost
  - 127.0.0.1
  extraArgs:
  - name: runtime-config
    value: ""
caCertificateValidityPeriod: 87600h0m0s
certificateValidityPeriod: 8760h0m0s
certificatesDir: /etc/kubernetes/pki
clusterName: kind
controlPlaneEndpoint: kind-control-plane:6443
controllerManager:
  extraArgs:
  - name: enable-hostpath-provisioner
    value: "true"
encryptionAlgorithm: RSA-2048
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.k8s.io
kubernetesVersion: v1.31.0
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/16

```
- Keys order of K8s objects (Golang maps) is irrelevant.  
  These are reordered for clarity, 
  but expect inconsistent order on capture/extract from K8s API.

Update the running Static Pods. These are controlled by `kubelet.service`, not the K8s API. 
Simply removing them (temporarily) from their home triggers the kubelet to terminate their Pods. 
After a time (seconds, or upon verification using `crictl`), 
restore these Static Pod manifests to their home:

```bash
k8s=/etc/kubernetes/manifests
tmp=/tmp/k8s-$(date '+%F')
mkdir -p $tmp &&
    mv $k8s/*.yaml $tmp/ &&
        sleep 10 &&
            mv $tmp/*.yaml $k8s/
```

Update client kubeconfig 

The usual method is to use `/etc/kubernetes/admin.conf`

```bash
☩ docker exec -it kind-control-plane cat /etc/kubernetes/admin.conf \
    |yq '.users[] |select(.name == "kubernetes-admin") | .user["client-certificate-data"]' \
    |tee ~/.kube/kind
```

But this fails at Kind cluster lest modify several keys, 
so rather __use "`kind export kubeconfig`" method__. 

```bash
# Export the updated client kubeconfig
kind export kubeconfig --kubeconfig ~/.kube/kind

# Merge with K3s
export KUBECONFIG=~/.kube/k3s:~/.kube/kind
kubectl config view --flatten |tee ~/.kube/config
# Set context to kind
kubectl config use-context kind-kind

```

Verify 

```bash
☩ date
Fri Nov  1 18:00:22 EDT 2024

# Verify mTLS rotated at host by kubeadm
☩ docker exec -it kind-control-plane \
    openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout \
        | grep "Not After"

            Not After : Nov  1 20:29:28 2025 GMT

# Verify mTLS rotation at /etc/kubernetes/admin.conf
☩ docker exec -it kind-control-plane cat /etc/kubernetes/admin.conf |yq '.users[] |select(.name == "kubernetes-admin") | .user["client-certificate-data"]' |base64 -d |openssl x509 -n
oout -subject -enddate
subject=O = kubeadm:cluster-admins, CN = kubernetes-admin
notAfter=Nov  1 20:29:28 2025 GMT

# Verify mTLS rotation at client kubeconfig
☩ k config view --raw -o json \
    |jq -Mr '.users[] |select(.name == "kind-kind") | .user["client-certificate-data"]' \
    |base64 -d \
    |openssl x509 -noout -subject -enddate

subject=O = kubeadm:cluster-admins, CN = kubernetes-admin
notAfter=Nov  1 20:29:28 2025 GMT

# Verify client-side kubeconfig
☩ k get node
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   61d   v1.31.0
```

### &nbsp;
