# [Kubernetes : Volumes](https://kubernetes.io/docs/concepts/storage/volumes/ "Kubernetes.io")

## [`local`](https://kubernetes.io/docs/concepts/storage/volumes/#local)

Compared to `hostPath` volumes, `local` volumes are used in a ***durable and portable*** manner ***without manually scheduling pods to nodes***. The system is aware of the volume's node constraints by looking at the node affinity on the PersistentVolume. Both `local` and `hostPath` are analogous to Docker bind mount.

>Where possible, use `local` instead of `hostPath`

- Must set a PersistentVolume nodeAffinity when using local volumes. The Kubernetes scheduler uses the PersistentVolume nodeAffinity to schedule these Pods to the correct node.
- PersistentVolume `volumeMode` can be set to "`Block`" (instead of the default value "Filesystem") to expose the local volume as a raw block device.
- It is recommended to **create a `StorageClass`** having "`volumeBindingMode: WaitForFirstConsumer`". 
- Use an external provisioner:
    - [Rook](https://rook.io/) : Production ready management for File, Block and Object Storage. 
      Rook orchestrates the Ceph storage solution, with a specialized Kubernetes Operator to automate management. 
        - [Rook Operator : Quick Start](https://rook.io/docs/rook/latest-release/Getting-Started/quickstart/#tldr)
        - [Ceph Operator Helm Chart](https://rook.io/docs/rook/latest-release/Helm-Charts/operator-chart/)
    - [Longhorn](https://longhorn.io/) : Cloud native distributed block storage for Kubernetes
    - [Local Persistence Volume Static Provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner) 


`local` @ `PersistentVolume` manifest

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  # Any name here okay
  storageClassName: local-storage
    # Advised for local
    volumeBindingMode: WaitForFirstConsumer
  local:
    path: /mnt/disks/ssd1
  # MUST use nodeAffinity
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - example-node
```

## [`hostPath`](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath)

HostPath is the Kubenetes equivalent to Docker's bind mount. 
Must restrict pod to same node (host) as the volume.

`hostPath` @ `Pod` manifest

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  nodeName: specific-node-name
  containers:
    - name: my-container
      image: your-container-image
      volumeMounts:
        - name: host-path-volume
          mountPath: /path/in/container  # Mount path inside the container
  volumes:
    - name: host-path-volume
      hostPath:
        path: /path/on/host  # Path on the specific node you want to bind

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

