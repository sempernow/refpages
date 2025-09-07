# [Cilium](https://github.com/cilium/cilium)

## Download 

```bash
ok(){
    # CLI : https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/
    dir="cilium/cilium-cli"
    ./$dir/cilium version 2>&1 || {
        mkdir -p $dir
        pushd $dir 
        url=https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt
        ver=$(curl -s $url) # v0.16.20
        echo $ver |grep 'v' || return 1
        arch=${ARCH:-amd64}
        [[ "$(uname -m)" = "aarch64" ]] && arch=arm64
        tarball="cilium-linux-${arch}.tar.gz"
        url=https://github.com/cilium/cilium-cli/releases/download/${ver}/$tarball{,.sha256sum}
        curl -L --fail --remote-name-all $url &&
            sha256sum --check $tarball.sha256sum &&
                sudo tar xzvfC $tarball . &&
                    rm $tarball{,.sha256sum}
        popd
    }

    # Chart : https://artifacthub.io/packages/helm/cilium/cilium/
    # Images : https://github.com/cilium/cilium/releases
    ver='1.16.4' 
    dir="cilium"
    pushd $dir 
    repo='cilium'
    chart='cilium'
    helm repo update $repo
    helm pull $repo/$chart --version $ver &&
        tar -xaf ${chart}-$ver.tgz &&
            cp -p $chart/values.yaml . &&
                type -t hdi >/dev/null 2>&1 &&
                    hdi $chart                
    rm -rf $chart
    popd
}
ok || echo '=== FAILed'

```

## [Install](https://chatgpt.com/c/6749a5f4-ad00-8009-9166-ad815bc10bfc "ChatGPT")

Both methods are of Helm chart


### CLI method

```bash 
☩ cilium install [flags]

☩ cilium install --set config.ipam=kubernetes,global.k8sServiceHost=192.168.11.101,global.k8sServicePort=6443 --dry-run-helm-values
```
```yaml
cluster:
  name: kubernetes
config:
  ipam: kubernetes
global:
  k8sServiceHost: 192.168.11.101
  k8sServicePort: 6443
operator:
  replicas: 1
routingMode: tunnel
tunnelProtocol: vxlan

```

@ [`values.yaml](values.yaml)

```bash
cilium install --kubeconfig ~/.kube/config --values values.yaml
```
```bash
☩ kw
cilium-dc9cb                       0/1     CrashLoopBackOff    4 (52s ago)   3m4s    192.168.11.101   a1       <none>           <none>
cilium-envoy-dprz2                 1/1     Running             0             7m27s   192.168.11.101   a1       <none>           <none>
cilium-operator-597d7f99c5-kt9kk   1/1     Running             0             7m27s   192.168.11.101   a1       <none>           <none>
coredns-76f75df574-5wtvn           0/1     ContainerCreating   0             36m     <none>           a1       <none>           <none>
coredns-76f75df574-z54n4           0/1     ContainerCreating   0             36m     <none>           a1       <none>           <none>
etcd-a1                            1/1     Running             18            36m     192.168.11.101   a1       <none>           <none>
kube-apiserver-a1                  1/1     Running             0             36m     192.168.11.101   a1       <none>           <none>
kube-controller-manager-a1         1/1     Running             0             36m     192.168.11.101   a1       <none>           <none>
kube-proxy-fnmf7                   1/1     Running             0             36m     192.168.11.101   a1       <none>           <none>
kube-scheduler-a1                  1/1     Running             10            36m     192.168.11.101   a1       <none>           <none>
sysdump-7bs6q                      1/1     Terminating         0             40s     192.168.11.101   a1       <none>           <none>
```

### [Helm method](https://docs.cilium.io/en/stable/installation/k8s-install-helm/ "docs.cilium.io")


```bash
app=cilium
ver=1.16.4
values=values.yaml
tar -xaf ${app}-$ver.tgz &&
    helm upgrade --install -f $values $app $app/ &&
        rm -rf $app

```
- [`values.yaml`](values.yaml)

If we want Cilium to use the HA LB (vIP) 
when communicating with K8s API server:

```bash
vip_or_domain=10.0.10.11 # OR k8s.lime.lan
port=6444 # HALB frontend; upstreams to 6443 (kube-apiserver)
helm install cilium cilium/cilium --namespace kube-system \
    --set k8sServiceHost=$vip_or_domain \
    --set k8sServicePort=$port \
    --set kubeProxyReplacement=partial \
    --set externalIPs.enabled=true
```
- `kubeProxyReplacement` :
    - Enables partial or full replacement of kube-proxy functionality by Cilium.
    - In most cases, partial is sufficient to integrate with external load balancers.
- `externalIPs.enabled` :
    - Allows the use of external IPs for services. 
      This is necessary for external load balancers 
      to direct traffic correctly.
- `hostServices.enabled=true` :
    - Optional. Enables handling of host services by Cilium, 
      which can be helpful in environments with external load balancers.


```bash
helm install cilium cilium/cilium --version 1.16.4 \
    --namespace $CILIUM_NAMESPACE \
    --set ipam.mode=kubernetes \
    --set=kubeProxyReplacement=true \
    --set=securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set=securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set=cgroup.autoMount.enabled=false \
    --set=cgroup.hostRoot=/sys/fs/cgroup \
    --set=k8sServiceHost=localhost \
    --set=k8sServicePort=7445 \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true

```

### [Optimal per ChatGPT](https://chatgpt.com/c/675905de-37fc-8009-ba64-c0f2501df333) : [`values.yaml`](values.yaml)

Datapath : Direct (L3) v. Encapsulated (Overlay/VXLAN)

For the best performance on east-west traffic in a single-subnet cluster, 
the __Direct Datapath__ is usually the industry recommendation.

Query 

```bash
cilium config view | grep tunnel
```
- If `tunnel` is set to `vxlan` or `geneve`, it’s __Encapsulated__.
- If `tunnel` is set to `disabled`, it’s __Direct__.

Verify Cilium's load balancing configuration:

```bash
cilium service list
cilium bpf lb list
```


Test before/after

```bash
iperf3 
``