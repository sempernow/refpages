# [Calico : On-prem K8s](https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises)

## Download

```bash
ok(){
    DIR=calico
    VER='v3.29.1'
    BASE=https://raw.githubusercontent.com/projectcalico/calico/$VER/manifests

    # Manifest Method
    ok(){
        dir="$DIR/manifest-method"
        file=calico.yaml
        [[ -f $dir/$file ]] && return 0
        mkdir -p $dir
        pushd $dir
        curl -sSLO $BASE/$file || return 100
        popd
    }
    ok || return $?

    # Operator Method
    ok(){
        dir="$DIR/operator-method"
        mkdir -p $dir

        # Operator
        file=tigera-operator.yaml
        [[ -f $dir/$file ]] || {
            pushd $dir
            curl -sSLO $BASE/$file || return 200
            popd
        }

        # CRDs
        file=custom-resources.yaml
        [[ -f $dir/$file ]] || {
            pushd $dir
            curl -sSLO $BASE/$file || return 300
            popd
        }
    }
    ok || return $?

    # CLI
    ok(){
        # calicoctl
        # https://docs.tigera.io/calico/latest/operations/calicoctl/install
        dir="$DIR/cli"
        url=https://github.com/projectcalico/calico/releases/download/$VER/calicoctl-linux-amd64 
        file=calicoctl
        [[ -f $dir/$file ]] && return 0
        mkdir -p $dir
        pushd $dir
        curl -sSL -o $file $url 
        popd
        chmod 0755 $dir/$file && $dir/$file version |grep $VER || return 404
    }
    ok || return $?
}
ok || echo "ERR: $?"

```

## Install 

### `calicoctl` CLI on Host

```bash
bin=/usr/local/bin/calicoctl
sudo mv calico $bin &&
    sudo chown root:root $bin &&
        sudo chmod 0755 $bin ||
            echo "ERROR : $?"

```


```bash
☩ calicoctl get ippools -o wide
NAME                  CIDR            NAT    IPIPMODE   VXLANMODE   DISABLED   DISABLEBGPEXPORT   SELECTOR
default-ipv4-ippool   10.244.0.0/24   true   Never      Never       false      false              all()

☩ calicoctl ipam show --show-blocks
+----------+-----------------+-----------+------------+-----------+
| GROUPING |      CIDR       | IPS TOTAL | IPS IN USE | IPS FREE  |
+----------+-----------------+-----------+------------+-----------+
| IP Pool  | 10.244.0.0/24   |       256 | 11 (4%)    | 245 (96%) |
| Block    | 10.244.0.128/26 |        64 | 8 (12%)    | 56 (88%)  |
| Block    | 10.244.0.192/26 |        64 | 1 (2%)     | 63 (98%)  |
| Block    | 10.244.0.64/26  |        64 | 2 (3%)     | 62 (97%)  |
+----------+-----------------+-----------+------------+-----------+

☩ calicoctl ipam show --show-configuration
+--------------------+-------+
|      PROPERTY      | VALUE |
+--------------------+-------+
| StrictAffinity     | false |
| AutoAllocateBlocks | true  |
| MaxBlocksPerHost   |     0 |
+--------------------+-------+

☩ calicoctl ipam show --ip=10.244.0.142
IP 10.244.0.142 is in use
Attributes:
  namespace: kube-system
  node: a1
  pod: coredns-76f75df574-fsxvc
  timestamp: 2024-12-14 21:44:05.795537491 +0000 UTC


```

### `calicoctl` CLI as `kubctl` plugin 

At admin node:

```bash
# Install
sudo curl -sSL https://github.com/projectcalico/calico/releases/download/v3.29.1/calicoctl-linux-amd64 -o /usr/local/bin/kubectl-calico

# Use
kubectl calico -h
kubectl calico get node
kubectl calico get ippool
kubectl calico ipam check

```

### CNI by Operator Method

` calico/node` runs three daemons:

1. Felix : the Calico per-node daemon
2. BIRD : speaks the BGP protocol to distribute 
   routing information to other nodes
3. confd : watches the Calico datastore 
   for config changes and updates BIRD's config files

[__Install/Configure for On-prem deployments__](https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises)

#### 1. Intall CRDs and then CRs

```bash
crd=tigera-operator.yaml
cr=custom-resources-bpf-bgp.yaml
kubectl create -f $crd
kubectl apply -f $cr

```

```bash
☩ k api-resources |grep calico |wc -l
37

☩ k get tigerastatuses
NAME        AVAILABLE   PROGRESSING   DEGRADED   SINCE
apiserver   True        False         False      57m
calico      True        False         False      22m
ippools     True        False         False      58m

☩ kubectl logs -n calico-system -l k8s-app=calico-node
```

```bash
☩ ansibash sudo calicoctl node status
=== u1@a1
Connection to 192.168.11.101 closed.
Calico process is running.

IPv4 BGP status
+----------------+-------------------+-------+----------+-------------+
|  PEER ADDRESS  |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+----------------+-------------------+-------+----------+-------------+
| 192.168.11.102 | node-to-node mesh | up    | 11:35:46 | Established |
| 192.168.11.100 | node-to-node mesh | up    | 11:35:41 | Established |
+----------------+-------------------+-------+----------+-------------+

IPv6 BGP status
No IPv6 peers found.
...
```
#### 2. [Configure BGP peering](https://docs.tigera.io/calico/latest/networking/configuring/bgp)

This is advised as best of [__Networking Options__](https://docs.tigera.io/calico/latest/networking/determine-best-networking#on-prem) for __On-prem__

>The most common network setup for Calico on-prem is non-overlay mode using BGP to peer with the physical network ... to make pod IPs routable outside of the cluster. ...This setup provides a rich range of advanced Calico features, including the ability to advertise Kubernetes service IPs (cluster IPs or external IPs), and the ability to control IP address management at the pod, namespace, or node level, to support a wide range of possibilities for integrating with existing enterprise network and security requirements.

___Fantasically tedious configuration___.

Calico offers no single or few manifests having the supposedly-advised configuration. Instead, it's an almost key-by-key configuration.

### by Manifest method

```bash
kubectl apply -f calico.yaml
```

## [Enable __eBPF__ dataplane](https://docs.tigera.io/calico/latest/operations/ebpf/enabling-ebpf)

- [Configure Calico to talk directly to K8s API server](https://docs.tigera.io/calico/latest/operations/ebpf/enabling-ebpf#configure-calico-to-talk-directly-to-the-api-server)

@ Operator method

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubernetes-services-endpoint
  namespace: tigera-operator
data:
  KUBERNETES_SERVICE_HOST: 'K8S_CONTROL_PLANE_IP'
  KUBERNETES_SERVICE_PORT: 'K8S_CONTROL_PLANE_PORT'
```

@ Manifest method

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubernetes-services-endpoint
  namespace: kube-system
data:
  KUBERNETES_SERVICE_HOST: 'K8S_CONTROL_PLANE_IP'
  KUBERNETES_SERVICE_PORT: 'K8S_CONTROL_PLANE_PORT'
```

```bash
sed -i "s,K8S_CONTROL_PLANE_IP,$K8S_CONTROL_PLANE_IP,g" $cm
sed -i "s,K8S_CONTROL_PLANE_PORT,$K8S_CONTROL_PLANE_PORT,g" $cm
kubectl apply -f $cm
kubectl delete pod -n kube-system -l k8s-app=calico-node
kubectl delete pod -n kube-system -l k8s-app=calico-kube-controllers
```


In eBPF mode Calico __replaces `kube-proxy`__, 
so disable it by adding a node selector to `kube-proxy`'s DaemonSet 
that matches no nodes:

```bash
kubectl patch ds -n kube-system kube-proxy -p '{"spec":{"template":{"spec":{"nodeSelector":{"non-calico": "true"}}}}}'

```

