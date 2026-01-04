# [Agnhost](https://github.com/kubernetes/kubernetes/tree/master/test/images/agnhost#agnhost "GitHub.com/kubernetes/.../test/images")

Agnostic Host

[`registry.k8s.io/e2e-test-images/agnhost:2.39`](https://github.com/kubernetes/kubernetes/blob/master/test/images/agnhost/Dockerfile "Dockerfile")


>Container image having an extendable CLI that **outputs the same** expected content, **regardless of host** (Linux or Windows) OS. The `agnhost` binary has several subcommands which are [used to test various K8s features](https://github.com/kubernetes/kubernetes/tree/master/test/images/agnhost#usage).


## [`netexec`](https://github.com/kubernetes/kubernetes/tree/master/test/images/agnhost#netexec)


@ Server 

```bash
kubectl exec test-agnhost -- \
    /agnhost netexec --http-port 8080
```

@ Client

```bash
curl http://localhost:8080/echo?msg=hello%20$(hostname)
hello XPC
```

### @ `kind` cluster

```bash
☩ dps
CONTAINER ID  NAMES                IMAGE                  PORTS 
adfc57f39b37  kind-control-plane   kindest/node:v1.31.0   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 127.0.0.1:44235->6443/tcp ...

☩ k get node
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   16h   v1.31.0

☩ k get pod -o wide
NAME   READY   STATUS    RESTARTS   AGE   IP            NODE               ...
bar    1/1     Running   0          16h   10.244.0.14   kind-control-plane ...
foo    1/1     Running   0          16h   10.244.0.13   kind-control-plane ...
...

☩ k get pod bar -o jsonpath='{.spec.containers[*].image}'
registry.k8s.io/e2e-test-images/agnhost:2.39
```
- Reference:
```bash
☩ type dps
dps is aliased to `docker container ps --format "table {{.ID}}  {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"'
```
```bash
☩ type k           
k is a function    
k ()               
{                  
    kubectl "$@"   
}
```

@ Server

```bash
# Override default command (/agnhost netexec) with another (/agnhost fake-gitserver)
☩ docker exec -it kind-control-plane \
    kubectl exec -it bar -- \
        /agnhost fake-gitserver

# Equivalent
☩ k exec -it bar -- \
        /agnhost fake-gitserver

```

@ Client 

```bash
☩ docker exec -it kind-control-plane \
    kubectl exec -it bar -- \
        curl http://localhost:8000/get
I am a fake git server

# Equivalent
☩ k exec -it bar -- \
    curl http://localhost:8000/get
I am a fake git server

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

