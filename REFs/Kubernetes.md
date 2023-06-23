# Kubernetes [`k8s`]

## [Overview](https://kubernetes.io/docs/home/?path=users&persona=app-developer&level=foundational) | [Tools](https://kubernetes.io/docs/reference/tools/ "kubernetes.io/docs/...") | [GitHub](https://github.com/kubernetes "Kubernetes repo") | [Kubernetes.io](https://kubernetes.io/) | [Wikipedia](https://en.wikipedia.org/wiki/Kubernetes)  


# [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

Exposes a Deployment to a port under a protocol, sans IP Address(es). E.g., Create `my-service` to target TCP port 9376 on any Pod having the label `app.kubernetes.ip/name: MyApp` : 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app.kubernetes.io/name: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```

## Auth : [Controlling Access](https://kubernetes.io/docs/concepts/security/controlling-access/)


## `kubectl`

CLI to communicate with Kubernetes API server

## Kubernetes API Server (Master)

### [`kube-apiserver`](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/) 

The Kubernetes API server validates and configures data for the api objects which include pods, services, replicationcontrollers, and others. The API Server services REST operations and provides the frontend to the cluster's shared state through which all other components interact.

The API is extensible. The core is `v1` . An important add-on API is `apps/v1`, which defines the `Deployment` and `ReplicaSet` objects.

## Cluster Management

`kubeadm`

Install/Upgrade tools using zero-downtime method

```bash
# Install kubeadm
sudo apt-get install -y --allow-change-held-packages \
    kubeadm=1.21.1-00
kubeadm version

# Inform the node
sudo kubeadm upgrade node

# Upgrade kubectl and kubelet to match kubeadm version
sudo apt-get install -y --allow-change-held-packages \
    kubectl=1.21.1-00 \
    kubelet=1.21.1-00

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

kubectl get nodes
```

## K8s API Server Objects

### Resources Available 

```bash
# List all API resources (v1)
kubectl api-resources |less
```
```text
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
bindings                                       v1                                     true         Binding
configmaps                        cm           v1                                     true         ConfigMap
endpoints                         ep           v1                                     true         Endpoints
events                            ev           v1                                     true         Event
namespaces                        ns           v1                                     false        Namespace
nodes                             no           v1                                     false        Node
persistentvolumeclaims            pvc          v1                                     true         PersistentVolumeClaim
persistentvolumes                 pv           v1                                     false        PersistentVolume
pods                              po           v1                                     true         Pod
podtemplates                                   v1                                     true         PodTemplate
replicationcontrollers            rc           v1                                     true         ReplicationController
resourcequotas                    quota        v1                                     true         ResourceQuota
secrets                                        v1                                     true         Secret
serviceaccounts                   sa           v1                                     true         ServiceAccount
services                          svc          v1                                     true         Service
...
controllerrevisions                            apps/v1                                true         ControllerRevision
daemonsets                        ds           apps/v1                                true         DaemonSet
deployments                       deploy       apps/v1                                true         Deployment
replicasets                       rs           apps/v1                                true         ReplicaSet
statefulsets                      sts          apps/v1                                true         StatefulSet
...
```

- Extensible API
- `apps/v1` is the most important add-on API.


Have hierarchy:

- `Deployment`: Represents tha deployed app.
    - `ReplicaSet`: Manages app replicas.
        - `Pods`: Adds features required to run the app.
- `ConfigMap`
- `Secrets`
- `PersistentVolumes`

## Object : `Node` (Minion)

- A k8s minion server that runs a `kubelet`.
- A compute unit.
- May run on a multitue of platforms:
    - A server
    - An OS 
    - `systemd` (Linux system and service manager)
    - `kubelet` (node agent) that runs on every node.
    - Container runtime (e.g., Docker engine)
    - Network proxy (`kube-proxy`) that handles K8s Services:
        - ClusterIP; internal Service that load balances k8s Pods
        - NodePort; open port on k8s node that load balances Pods
        - LoadBalancer; external to the cluster
    - Container Network Interface (CNI) provider

### Object : `Pod` 

- An abstraction of a server running an app.
- Can run one or more containers with a single NameSpace, 
  exposed by a single IP address.
- Typically created automatically by `Deployment`, or other API objects. 
- Regarding Docker image tags, do NOT use `latest` . 
- A collection of Kubernetes ___namespaces___ in a specific configuration; contains the following Linux namespaces (kernel filesystem component); provides the base functionality to create a running container from an image, and to scale and load balance per service within the software-defined networking (SDN) system spanning a K8s cluster.
    - PID namespaces
    - A single networking namespace
    - IPC namespace
    - `cgroup` (control group) namespace.
    - `mnt` (mount) namespace
    - `user` (user ID) namespace

### Object : Higer-level Abstractons

Typically spawn one or more Pods; typically create ___replica objects___, which then create Pods.

#### `Deployment`

The most common object; deploys a mircroservice

#### `Job`

Run a Pod as a batch process

#### `StatefulSet`

Host applications requiring specific needs; oftten stateful, e.g., data store.

Features 

- Ordinal Pod naming to ensure unique network identifiers
- Persistent storage always mounted to same Pod
- Ordered start/scale/update

#### `DaemonSet`

Run a single Pod as an "agent" on every node in a cluster; system services, storage, logging, ...

## YAML Manifest 

### Ingredients (fields):

- `apiVersion:` K8s API-server version
- `kind:` K8s Object type
- `metadata:` K8s Object sdministrative information
- `spec:` K8s Object specifics; `container:`(s) `name:`, `image:`, `command:`

Get more info about the field

```bash
kubectl explain $type.$fieldName[.$fieldName]
# E.g., 
kubectl explain pods.metadata
kubectl explain pods.spec.restartPolicy
# ALL possibilities
kubectl explain --recursive  pod.spec
```
- Use JSONPath identifer syntax

### Generate YAML 

```bash
kubectl create|run --dry-run=client -o yaml > app.yaml
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

