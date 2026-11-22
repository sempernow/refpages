# K8s mTLS : How to rotate control-plane certificates 

>~~By default, a vanilla cluster automatically updates its (mTLS) control-plane certificates. ~~ Certificates are not updated automatically.


~~In case it fails to do so (not unheard of), this is the recovery procedure.~~

## New : `v1.29+`


Simple, nuclear option

```bash
# 1. Cordon and drain all but one control plane node
kubectl cordon control-plane-2
kubectl cordon control-plane-3
kubectl drain control-plane-2 control-plane-3 --delete-emptydir-data --ignore-daemonsets

# 2. Remove extra control plane nodes
kubectl delete node control-plane-2 control-plane-3

# 3. On remaining control plane node, renew certificates
sudo kubeadm certs renew all
sudo kubeadm certs check-expiration
sudo systemctl restart kubelet

# 4. Join others
# On the surviving good node — generate a fresh certificate key (valid 2h by default)
sudo kubeadm init phase upload-certs --upload-certs
# This prints a certificate-key at the end, e.g.:
# --certificate-key 7e2b3c4d5e6f...

# Create a join token
sudo kubeadm token create --print-join-command
# This prints something like:
# kubeadm join 10.0.0.10:6443 --token abcdef.1234567890abcdef \
#     --discovery-token-ca-cert-hash sha256:...

# To add a new control plane node, combine them:
sudo kubeadm join 10.0.0.10:6443 --token abcdef.1234567890abcdef \
    --discovery-token-ca-cert-hash sha256:... \
    --control-plane --certificate-key 7e2b3c4d5e6f...
```

Complicated and conflicting advice regarding other control nodes
```bash
# 1st control node
sudo kubeadm certs renew all
sudo systemctl restart kubelet

# Copy pki ????

# All control plane nodes:
echo "Updating local kubeconfig files..."
sudo kubeadm init phase kubeconfig all

echo "Restarting control plane components..."
sudo systemctl restart kube-apiserver kube-controller-manager kube-scheduler kubelet

echo "Done on $HOSTNAME"
```

## Prior : `v1.28-`


1. Backup existing configuration
    - Process is cluster/distro dependent.
1. __Renew certificates__ on ***one*** control node
    ```bash
    kubeadm certs renew all --config $clusterconfig
    ```
    - If control plane is multi-node, ~~then distribute new certs.~~
1. __Update the manifest of all Static Pods__ with the new TLS certificates. 
   This __requires the `ClusterConfiguration` manifest__ (`$clusterconfig`).
    ```bash
    kubeadm init phase kubeconfig all --config $clusterconfig
    ```
    - The `ClusterConfiguration` manifest may exist   
      at `/etc/kuberntes/kubeadm-config.yaml`.   
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
1. Recreate the kubeconfig
    ```bash
    sudo kubeadm init phase kubeconfig all
    sudo kubeadm init phase kubeconfig super-admin
    sudo systemctl restart kubelet
    ```
1. Check all X.509
    ```bash
    # Check all kubeconfigs use current certificates
    for conf in admin kubelet controller-manager scheduler; do
    echo "=== $conf.conf ==="
    kubectl --kubeconfig=/etc/kubernetes/${conf}.config config view --raw \
        -o jsonpath='{.users[0].user.client-certificate-data}' | \
        base64 -d | openssl x509 -noout -subject -dates | head -2
    echo
    done
    ```
    - Want: `rotateCertificates: true`


Set to auto rotate

```yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
rotateCertificates: true
serverTLSBootstrap: true  # This enables automatic serving cert rotation

```

Check if the cluster is configured to automatically rotate its mTLS certificates:

```bash
sudo grep rotate /var/lib/kubelet/config.yaml
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
