# [Traefik Proxy](https://doc.traefik.io/traefik/providers/kubernetes-ingress/ "doc.traefik.io")

Cloud Native Application Proxy

>Simplify and automate the discovery, routing, and load balancing of microservices.

- [Configuration Discovery](https://doc.traefik.io/traefik/providers/kubernetes-crd/#traefik-kubernetes) via Providers
- [Routing and Load Balancing](https://doc.traefik.io/traefik/routing/overview/)
    - [Providers](https://doc.traefik.io/traefik/providers/overview/#supported-providers) :  infrastructure components, whether orchestrators, container engines, cloud providers, or key-value stores. The idea is that Traefik queries the provider APIs in order to find relevant information about routing, and when Traefik detects a change, it dynamically updates the routes.
        - Declared in Traefik configuration. May be in a ConfigMap, but in K3s, Traefik Proxy is installed by Helm, and so obfuscated:
            ```bash
            ☩ kubectl get secret chart-values-traefik -n kube-system \
                -o jsonpath='{.data.values-01_HelmChart\.yaml}' \
                |base64 -d
            ```
            ```yaml
            deployment:
            ...
            providers:
            kubernetesIngress:
                publishedService:
                enabled: true
            image:
            repository: "rancher/mirrored-library-traefik"
            tag: "2.11.10"
            ...
            ```
            ```bash
            ☩ kubectl get deployment traefik -n kube-system -o json \
                |jq -Mr .spec.template.spec.containers[].args
            ```
            ```json
            [
                "--global.checknewversion",
                "--global.sendanonymoususage",
                "--entrypoints.metrics.address=:9100/tcp",
                "--entrypoints.traefik.address=:9000/tcp",
                "--entrypoints.web.address=:8000/tcp",
                "--entrypoints.websecure.address=:8443/tcp",
                "--api.dashboard=true",
                "--ping=true",
                "--metrics.prometheus=true",
                "--metrics.prometheus.entrypoint=metrics",
                "--providers.kubernetescrd",
                "--providers.kubernetesingress",
                "--providers.kubernetesingress.ingressendpoint.publishedservice=kube-system/traefik",
                "--entrypoints.websecure.http.tls=true"
            ]
            ```
            - Using Kubernetes Ingress provider, LetsEncrypt HA can be achieved by using a Certificate Controller such as Cert-Manager. 
 [Middlewares](https://doc.traefik.io/traefik/middlewares/overview/)
- &vellip;

## URL Rewrite : __`Middleware`__

Traekfik's __chainable__ `Middleware` applies only to objects declaring it.
Use K8s `Ingress` with `annotations` for simple configurations, 
else Traefik's `IngressRoute` for full Traefik configuration control.

### 1.a. `/old-path` --> `/new-path` 

`Middleware` (__ReplacePath__) / __`Ingress`__ (`annotations`)

```yaml
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
## ReplacePath
metadata:
  name: replace-path
  namespace: default
spec:
  replacePath:
    path: "/new-path"
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: default
  annotations:
    ## Having no "middlewares" key, Kubernetes Ingress' 
    ## are unaffected by any middlewares unless declared 
    ## at traefik annotation key using this pattern : <namespace>-<middleware-name>@kubernetescrd
    traefik.ingress.kubernetes.io/router.middlewares: "default-replace-path@kubernetescrd"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /old-path
        pathType: Prefix
        backend:
          service:
            name: svc-x
            port:
              number: 80

```

### 1.b. `/old-path` --> `/new-path`

`Middleware` (__ReplacePath__) / __`IngressRoute`__

```yaml
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
## ReplacePath
metadata:
  name: replace-path
  namespace: default
spec:
  replacePath:
    path: "/new-path"
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: example-ingressroute
  namespace: default
spec:
  entryPoints:
    - web
  routes:
    - middlewares:
        - name: replace-path
      kind: Rule # The only routes.kind 
      match: "Host(`example.com`) && Path(`/old-path`)"
      services:
        - name: svc-x
          port: 80
```

### 2. `/api/v1/(.*)` --> `/v2/$1`

`Middleware` (__ReplacePathRegex__) / __`IngressRoute`__

```yaml
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
## ReplacePathRegex
metadata:
  name: replace-path-regex
  namespace: default
spec:
  replacePathRegex:
    regex: "^/api/v1/(.*)"
    replacement: "/v2/$1"
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: example-ingressroute-regex
  namespace: default
spec:
  entryPoints:
    - web
  routes:
    - match: "Host(`example.com`) && PathPrefix(`/api/v1`)"
      kind: Rule
      services:
        - name: svc-x
          port: 80
      middlewares:
        - name: replace-path-regex

```

### 3. `/app` --> `/`

`Middleware` (__AddPrefix__) / __`IngressRoute`__

```yaml
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: add-prefix
  namespace: default
spec:
  addPrefix:
    prefix: "/app"
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: example-ingressroute-prefix
  namespace: default
spec:
  entryPoints:
    - web
  routes:
    - match: "Host(`example.com`)"
      kind: Rule
      services:
        - name: svc-x
          port: 80
      middlewares:
        - name: add-prefix
```

## Lab 

### [`app.yaml`](app.yaml)

- [`svc.nginx-mock-app.yaml`](svc.nginx-mock-app.yaml)
- [`middleware.nginx-mock-app.yaml`](middleware.nginx-mock-app.yaml)
- [`ingressroute.nginx-mock-app.yaml`](ingressroute.nginx-mock-app.yaml)
- [`pod.nginx-mock-app.yaml`](pod.nginx-mock-app.yaml)

```bash
☩ ip -4 -brief addr show dev eth0
eth0             UP             172.27.240.169/20

☩ sudo vi /etc/hosts && cat /etc/hosts
...
172.27.240.169    app.wsl.lan

☩ cat svc.nginx-mock-app.yaml middleware.nginx-mock-app.yaml ingressroute.nginx-mock-app.yaml pod.nginx-mock-app.yaml \
    |tee app.yaml

☩ k apply -f app.yaml
service/nginx-mock-app created
middleware.traefik.containo.us/nginx-mock-app created
ingressroute.traefik.containo.us/nginx-mock-app created
pod/nginx-mock-app created

☩ k get $all -l app
NAME                     TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/nginx-mock-app   ClusterIP   10.43.63.23   <none>        80/TCP    52m

NAME                                            AGE
middleware.traefik.containo.us/nginx-mock-app   52m

NAME                                              AGE
ingressroute.traefik.containo.us/nginx-mock-app   52m

NAME                 READY   STATUS    RESTARTS   AGE
pod/nginx-mock-app   1/1     Running   0          52m

☩ curl -is http://app.wsl.lan/api/v1/ |head
HTTP/1.1 200 OK
Accept-Ranges: bytes
Content-Length: 615
Content-Type: text/html
Date: Fri, 20 Dec 2024 18:43:25 GMT
Etag: "6745ef54-267"
Last-Modified: Tue, 26 Nov 2024 15:55:00 GMT
Server: nginx/1.27.3

<!DOCTYPE html>
```


## [Hub API Gateway](https://doc.traefik.io/traefik-hub/api-gateway/intro)

Traefik Hub API Gateway is a __drop-in replacement for Traefik Proxy__.
It can do everything Traefik Proxy does, 
with additional capabilities and support out of the box.

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

