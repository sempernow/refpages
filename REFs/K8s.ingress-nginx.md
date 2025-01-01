# [Ingress-NGINX Controller](https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters "kubernetes.github.io") | [Releases](https://github.com/kubernetes/ingress-nginx/releases) | [Configuration](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/index.md)


## `Ingress` : Rewrite ([`rewrite-target`](https://github.com/kubernetes/ingress-nginx/blob/main/docs/examples/rewrite/README.md "github.com/kubernetes/ingress-nginx")) Syntax

URL rewrite rules are based on RegEx [Capture Group](https://www.regular-expressions.info/refcapture.html "regular-expressions.info")s, which are saved in numbered placeholders; `$1`, `$2` &hellip; `$n`.
So, rewrite rule `\$n` declares the capture group (of the request) that survives the rewrite, and is sent upstream. 

__Here are some example patterns__:

### 1. `/a` --> `/a`

Here there is no actual rewrite. 
Request for `/a` is sent to upstream app as `/a`.
The pattern is used only to optimize 
handling by NGINX processor.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
...
  annotations:
    # Apply rewrite to the 1st ($1) Capture Group.
    # That is, preserve only that group.
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
 ...
  rules:
    ...
      paths:
        # This 1st (only) capture group to capture everything after leading slash and rewrite to root. So actually rewrite nothing, yet this pattern informs NGINX to fully injest and process, resulting in optimized handling of edge-cases and query params.
      - path: /(.*) 
        # Inform K8s that path interpretation is performed by Ingress Controller (RegEx)
        pathType: ImplementationSpecific
        ...
```

>Different Ingress controllers support different annotations.

###  2. `/a/x` --> `/x`

```yaml
...
  annotations:
    # Apply rewrite to the 2nd ($2) Capture Group.
    # That is, preserve only that group.
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
..
      - path: /a(/|$)(.*)
        pathType: ImplementationSpecific

```
- `/a` is the literal string.
- `(/|$)` is the 1st capture group, 
  matching either a forward slash `/` 
  or the end of the string `($)`.
- `(.*)` is the 2nd capture group, 
   matching anything that comes after `/a/` or `/a`.

So __client request__ `/a/1/2?q=v` is __rewritten__ to `/1/2?q=v`, 
__before it is sent upstream__.

### 3. `/a` --> `/b`

```yaml
...
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /b/$1
..
      - path: /a(.*)
        pathType: ImplementationSpecific

```

### `app-root` : `/a`  --> `/`

```yaml
...
  annotations:
    nginx.ingress.kubernetes.io/app-root: /a
...
      - path: /
        pathType: Prefix
        ...
```
- Response to request of `http://foo.lime.lan/` is a __redirect__:
    - Code: `302 Moved Temporarily`
    - Header: `Location: http://foo.lime.lan/a`

## Deploy (DaemonSet) : Baremetal (On-prem) Configuration


@ [__`ingress-nginx-baremetal.yaml`__](ingress-nginx-baremetal.yaml)

Use this configuration __for on-prem clusters__, 
whether the hosts are "baremetal" (physical sever) or on a hypervisor. 

```bash
# https://github.com/kubernetes/ingress-nginx/releases
v=1.11.3
url=https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v$v/deploy/static/provider/baremetal/deploy.yaml
manifest=ingress-nginx-baremetal.yaml
curl -sSL -o $manifest $url

kubectl apply -f $manifest
```

Else by Helm chart (untested) :

```bash
v=4.11.3
release=ingress-nginx
chart=$release
repo=https://kubernetes.github.io/$chart
values=values.yaml

# Using remote chart
helm show values $chart --repo $repo |tee $values
vi $values # Edit to fit environment
helm upgrade \
    --install \   
    --repo $repo \
    --version $v \
    --values $values \
    --namespace $release \
    --create-namespace \
    $release $chart

# Using local chart
helm pull $chart --repo $repo --version $v
tar -xaf ${chart}-${v}.tgz
cp $chart/$values .
vi $values # Edit to fit environment
helm upgrade \
    --install \
    --values $values \  
    --namespace $release \
    --create-namespace \
    $release $chart

```

The baremetal configuration Service `ingress-nginx-controller` 
wires each service port (names: `http`/`https`) to a `nodePort`. 

```yaml
apiVersion: v1
kind: Service
metadata:
  ...
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  type: NodePort
  ports:

  - appProtocol: http
    name: http
    port: 80
    protocol: TCP
    targetPort: http

  - appProtocol: https
    name: https
    port: 443
    protocol: TCP
    targetPort: https
  ...
```

[Modify the `ConfigMap.data`](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/) to fit environmnet. 
E.g., [if external (downstream) LB utilizes PROXY protocol](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#use-proxy-protocol)
```yaml
---
apiVersion: v1
kind: ConfigMap
data:
  allow-snippet-annotations: "false"
  use-proxy-protocol: "false" # "true" if LB upstreams using PROXY protocol
  ...
...
```


```bash
☩ k get node a1 -o wide
NAME   STATUS   ROLES           AGE   VERSION   INTERNAL-IP      EXTERNAL-IP ...
a1     Ready    control-plane   17h   v1.29.6   192.168.11.101   <none>      ...

☩ kubectl -n ingress-nginx get svc ingress-nginx-controller
NAME                       TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)                     
ingress-nginx-controller   NodePort   10.37.30.17   <none>        80:30409/TCP,443:32390/TCP
```

@ [`ingress-nginx-usage.yaml`](ingress-nginx-usage.yaml)

```bash
☩ curl http://192.168.11.101:30409/foo/hostname
foo
```
- HTTP @ `30409`
- HTTPS @ `32390`

We would declare these if connecting to an external (HA) load balancer (LB).
Those service ports of this Ingress controller would be 
the cluster's data-plane upstreams proxied by that HA LB. 

Typically, a single external loadbalancer (HA LB) 
is configured to proxy both the control and data planes, 
providing a single, stable (HA) entrypoint to the (multi-node) cluster.

### &nbsp;
