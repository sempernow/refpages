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