# Graceful Shutdown of kubeadm cluster

UPDATE: [Configure Graceful Node Shutdown](https://kubernetes.io/docs/concepts/cluster-administration/node-shutdown/#configuring-graceful-node-shutdown)

---

To gracefully shut down a Kubernetes cluster: Drain workloads first to prevent data corruption, 
stop the control plane components in order, 
and then shut down the underlying node operating systems. [1, 2, 3, 4, 5] 

## 1. Drain the Worker Nodes

Evict all running pods from your worker nodes so they reschedule gracefully elsewhere or terminate cleanly. 
Run this for each worker node: [6, 7] 

```bash
kubectl drain <worker-node-name> --ignore-daemonsets --delete-emptydir-data
```

## 2. Back Up the Cluster State

Take a final, clean snapshot of the etcd database from a healthy control plane node: [8] 

```bash
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/key.pem \
    snapshot save /tmp/pre-shutdown-etcd.db
```

## 3. Stop the Control Plane Components

To prevent etcd from losing quorum mid-shutdown, stop the services gracefully. 
On every control plane node, move the static pod manifests out of the kubelet's watch directory: [9] 

```bash
mkdir -p /etc/kubernetes/tmp
mv /etc/kubernetes/manifests/* /etc/kubernetes/tmp/
```
- Note: Wait 30 seconds for the containers to fully stop. [10] 

## 4. Stop Kubelet and Container Runtime

On all nodes (control plane and workers), stop the node agent and the underlying container engine:

```bash
sudo systemctl stop kubelet
sudo systemctl stop containerd  # or crio / docker
```

## 5. Shut Down the Operating Systems

Power off the machines. Always shut down the worker nodes first, followed by the control plane nodes: [11, 12] 

```bash
sudo shutdown -h now
```

## Power-On Sequence

When bringing the cluster back up, reverse the process:

1. Power on all control plane nodes simultaneously so etcd can instantly establish quorum.
2. Move the manifests back: `mv /etc/kubernetes/tmp/* /etc/kubernetes/manifests/`
3. Power on the worker nodes.
4. Uncordon the nodes to allow scheduling: `kubectl uncordon <node-name>` [13, 14, 15] 


[1] [https://cloud.google.com](https://cloud.google.com/blog/products/containers-kubernetes/kubernetes-best-practices-terminating-with-grace)
[2] [https://oneuptime.com](https://oneuptime.com/blog/post/2026-02-09-termination-grace-period-clean-shutdowns/view)
[3] [https://medium.com](https://medium.com/@jfpucheu/kubernetes-node-stability-and-performance-tuning-kubelet-for-better-resource-management-e0f95ccfefe9)
[4] [https://www.microfocus.com](https://www.microfocus.com/documentation/arcsight/arcsight-platform-21.1/as_platform_admin_guide/Content/platform_maintain/cluster_node_restart.htm?TocPath=Maintaining%20the%20Platform%20and%20Deployed%20Capabilities%7C_____6)
[5] [https://www.plural.sh](https://www.plural.sh/blog/kubectl-delete-nodes-guide/)
[6] [https://cast.ai](https://cast.ai/blog/kubernetes-cordon-how-it-works-and-when-to-use-it/)
[7] [https://docs.oracle.com](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdeletingworkernodes_topic-Notes_on_cordon_and_drain.htm)
[8] [https://support.scc.suse.com](https://support.scc.suse.com/s/kb/How-to-recover-a-cluster-when-all-control-plane-nodes-have-failed)
[9] [https://sigridjin.medium.com](https://sigridjin.medium.com/building-a-kubernetes-cluster-with-kubeadm-from-theory-to-practice-faebea2eebd5)
[10] [https://www.gruntwork.io](https://www.gruntwork.io/blog/gracefully-shutting-down-pods-in-a-kubernetes-cluster)
[11] [https://support.hpe.com](https://support.hpe.com/hpesc/public/docDisplay?docId=a00111257en_us&page=GUID-9CD02D68-D953-4954-B0F5-250DFCD91CA3.html&docLocale=en_US)
[12] [https://oneuptime.com](https://oneuptime.com/blog/post/2026-03-03-use-talosctl-shutdown-to-power-off-nodes/view)
[13] [https://docs.okd.io](https://docs.okd.io/4.19/backup_and_restore/control_plane_backup_and_restore/disaster_recovery/scenario-2-restoring-cluster-state.html)
[14] [https://oneuptime.com](https://oneuptime.com/blog/post/2026-02-20-kubernetes-etcd-backup-restore/view)
[15] [https://www.kerno.io](https://www.kerno.io/blog/master-kubernetes-with-ease-the-ultimate-kubectl-commands-and-cheat-sheets-guide)



---

<!-- 

… ⋮ ︙ • ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
☢ ☣ ☠ ¦ ¶ § † ‡ ß µ Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 🡸 🡺 ➔
ℹ️ ⚠️ ✅ ⌛ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🥇 ✨️ 🔚

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# README HyperLink

README ([MD](__PATH__/README.md)|[HTML](__PATH__/README.html)) 

# Bookmark

- Target
<a name="foo"></a>

- Reference
[Foo](#foo)

-->
