# [Argo CD](https://argo-cd.readthedocs.io/en/stable/ "argo-cd.readthedocs.io")

>Declarative Continuous Delivery for Kubernetes

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

- https://github.com/argoproj/argo-cd
- https://argo-cd.readthedocs.io/en/stable/
- https://www.youtube.com/watch?v=yrj4lmScKHQ

## [Install](https://argo-cd.readthedocs.io/en/stable/getting_started/)


```bash
kubectl create namespace argocd
url=https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
#curl -sSLo argocd-install.yaml $url 
kubectl apply -n argocd -f $url
```
- That's 23,097 lines of YAML (1.2MB), 
   and includes lots of CRDs.
- [TLS Configuration](https://argo-cd.readthedocs.io/en/stable/operator-manual/tls/#tls-configuration)  
    for use by `argocd-server` are stored in `argocd-server-tls` else `argocd-secret`, 
    else Argo CD will generate a self-signed certificate and persist it in the `argocd-secret` secret.

&nbsp;

```bash
☩ k get deploy,sts,svc,secret,cm
NAME                                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/argocd-applicationset-controller   1/1     1            1           48m
deployment.apps/argocd-dex-server                  1/1     1            1           48m
deployment.apps/argocd-notifications-controller    1/1     1            1           48m
deployment.apps/argocd-redis                       1/1     1            1           48m
deployment.apps/argocd-repo-server                 1/1     1            1           48m
deployment.apps/argocd-server                      1/1     1            1           48m

NAME                                             READY   AGE
statefulset.apps/argocd-application-controller   1/1     48m

NAME                                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/argocd-applicationset-controller          ClusterIP   10.96.51.108    <none>        7000/TCP,8080/TCP            48m
service/argocd-dex-server                         ClusterIP   10.96.105.216   <none>        5556/TCP,5557/TCP,5558/TCP   48m
service/argocd-metrics                            ClusterIP   10.96.153.224   <none>        8082/TCP                     48m
service/argocd-notifications-controller-metrics   ClusterIP   10.96.155.147   <none>        9001/TCP                     48m
service/argocd-redis                              ClusterIP   10.96.254.27    <none>        6379/TCP                     48m
service/argocd-repo-server                        ClusterIP   10.96.123.230   <none>        8081/TCP,8084/TCP            48m
service/argocd-server                             ClusterIP   10.96.206.88    <none>        80/TCP,443/TCP               48m
service/argocd-server-metrics                     ClusterIP   10.96.183.167   <none>        8083/TCP                     48m

NAME                                 TYPE     DATA   AGE
secret/argocd-initial-admin-secret   Opaque   1      48m
secret/argocd-notifications-secret   Opaque   0      48m
secret/argocd-redis                  Opaque   1      48m
secret/argocd-secret                 Opaque   5      48m

NAME                                  DATA   AGE
configmap/argocd-cm                   0      48m
configmap/argocd-cmd-params-cm        0      48m
configmap/argocd-gpg-keys-cm          0      48m
configmap/argocd-notifications-cm     0      48m
configmap/argocd-rbac-cm              0      48m
configmap/argocd-ssh-known-hosts-cm   1      48m
configmap/argocd-tls-certs-cm         0      48m
configmap/kube-root-ca.crt            1      49m
```

### [Ingress Configuration](https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/)

- [ingress-nginx](https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#kubernetesingress-nginx)

### Install CLI


```bash
# Argo-CD CLI releases : https://github.com/argoproj/argo-cd/releases
ver=2.11.5 # Select
url=https://github.com/argoproj/argo-cd/releases/download/v$ver/argocd-linux-amd64
# Else use latest version
#url=https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo curl -sSL -o /usr/local/bin/argocd $url && sudo chmod 755 /usr/local/bin/argocd

```

## [Access The Argo CD API Server](https://argo-cd.readthedocs.io/en/stable/getting_started/#3-access-the-argo-cd-api-server)

```bash
☩ k get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' |base64 -d
lz79nluKZr4J27qT 
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

