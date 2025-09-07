# [MinIO Operator](https://github.com/minio/operator/ "GitHub")

[MinIO on K8s v. Host](https://chatgpt.com/share/6724d4f3-c96c-8009-bef9-5d90921fc464 "ChatGPT")

## Install @ [MinIO/Docs](https://min.io/docs/minio/kubernetes/upstream/operations/installation.html) | [`minio/operator`](https://github.com/minio/operator/tree/master )

A labyrinth of methods are involved, and at least one adjacent project is required, 
to perform the basic installation. 

Pods failing to deploy are due, at least in part, 
to cluster being single-node and lacking StorageClass/Provisioner.

### [`minio-operator`](docs/minio-operator-v6.0.4.yaml)

```bash
ver=6.0.4
app=minio-operator-v$ver.yaml

# Step 1 : Method 1
kubectl apply -k "github.com/minio/operator?ref=v6.0.4" --dry-run=client -o yaml \
    |yq '.items | .[]' |sed '1!s/^apiVersion/---\napiVersion/' \
    |tee $app

# Step 1 : Method 2
k kustomize github.com/minio/operator\?ref=v$ver |tee $app

# Deploy the app
k apply -f $app
k -n minio-operator get all
```
```plaintext
NAME                                  READY   STATUS    RESTARTS   AGE
pod/minio-operator-5dc4f5748f-7p4cn   1/1     Running   0          55m
pod/minio-operator-5dc4f5748f-99hp9   0/1     Pending   0          55m

NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/operator   ClusterIP   10.43.43.208   <none>        4221/TCP   55m
service/sts        ClusterIP   10.43.35.79    <none>        4223/TCP   55m

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/minio-operator   1/2     2            1           55m

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/minio-operator-5dc4f5748f   2         2         1       55m
```

### [`minio-tenant`](docs/minio-operator-tenant.yaml)

```bash
☩ k -n minio-tenant get all
```
```plaintext
NAME                   READY   STATUS    RESTARTS   AGE
pod/myminio-pool-0-0   0/2     Pending   0          11m
pod/myminio-pool-0-1   0/2     Pending   0          11m
pod/myminio-pool-0-2   0/2     Pending   0          11m
pod/myminio-pool-0-3   0/2     Pending   0          11m

NAME                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/minio             ClusterIP   10.43.146.30   <none>        443/TCP    11m
service/myminio-console   ClusterIP   10.43.89.165   <none>        9443/TCP   11m
service/myminio-hl        ClusterIP   None           <none>        9000/TCP   11m

NAME                              READY   AGE
statefulset.apps/myminio-pool-0   0/4     11m
```

## Install @ [OperatorHub.io/OLM](https://operatorhub.io/operator/minio-operator) 

Utilizes Operator Lifecycle Manager (OLM) project.

Install fails regardless of the multiple methods provided.

The installation script presented in its "Install" pop-up of 
"How to install an Operator from OperatorHub.io" page breaks by HTTP 404, even after finding and downloading the script itself, at all other resources tested. 

See [`olm/install.sh`](olm/install.sh)

The hand-crafted install script built by reverse engineering the install script and manually pulling those manifests ([`olm/install-minio.sh`](olm/install-minio.sh))
installs all assets of that script, yet the result of applying those manifests is a failure to deploy its pods due to some sort of security issue regarding its own declarations.

## Project Meta

```plaintext
    .
    ├── docs
    │   ├── minio-operator-tenant-dry-run.yaml
    │   └── minio-operator-v6.0.4-dry-run.yaml
    ├── olm
    │   ├── crds.yaml
    │   ├── install-minio.sh
    │   ├── install.sh
    │   ├── minio-operator.yaml
    │   └── olm.yaml
    ├── README.html
    └── README.md

    2 directories, 9 files
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

