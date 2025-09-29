# Host FS Plan for K8S Cluster 

A **Kubernetes node–friendly FS layout** that follows the FHS spirit, but also reflects how kubeadm-style clusters and container runtimes actually behave in the wild.

## 🔹 Core node layout

| Path                                       | Role                                                             | Notes                                                                 |
| ------------------------------------------ | ---------------------------------------------------------------- | --------------------------------------------------------------------- |
| `/`                                        | Root FS                                                          | Keep lean; don’t fill it with containers or logs.                     |
| `/etc/kubernetes`                          | Control plane + kubelet config                                   | From kubeadm (manifests, kubeconfig, certs).                          |
| `/var/lib/kubelet`                         | Kubelet state + pod sandboxes + volume mounts                    | This is **critical**; make it its own FS if you want crash isolation. |
| `/var/lib/containerd` or `/var/lib/docker` | Container runtime layers + images                                | Put on fast disk (NVMe/SSD) for image pull and unpack speed.          |
| `/var/log/pods`                            | Per-pod log symlinks                                             | Kubelet links container logs here.                                    |
| `/var/log/containers`                      | Symlinks to container runtime logs                               | Used by logging agents (fluent-bit, promtail, etc.).                  |
| `/var/log`                                 | System logs                                                      | journald, syslog, kernel. Don’t let app logs flood it.                |
| `/srv/nfs` or `/srv/storage`               | If this node exports volumes (NFS, Gluster, Ceph gateways, etc.) | Clean separation from kubelet’s internals.                            |
| `/data`                                    | General bulk storage for PV backends                             | For CSI drivers or hostPath experiments.                              |
| `/backup`                                  | Backups of etcd, manifests, configs                              | Keep isolated from `/var`.                                            |

---

## 🔹 Mount strategy (fstab style)

Example `/etc/fstab` for a worker:

```fstab
# Root + boot
UUID=...  /                  xfs  defaults,noatime  0 1
UUID=...  /boot              ext4 defaults          0 2

# Separate FS for kubelet (pods, volumes)
UUID=...  /var/lib/kubelet   xfs  defaults          0 2

# Separate FS for container runtime
UUID=...  /var/lib/containerd xfs defaults          0 2

# Log partition
UUID=...  /var/log           xfs  defaults,nodev,noexec,nosuid  0 2

# Data partition for PV backends
UUID=...  /data              xfs  defaults          0 2

# Backups (etcd snapshots, configs)
UUID=...  /backup            xfs  defaults,noatime  0 2
```

---

## 🔹 Why this helps

* **Blast radius control**

  * If `/var/lib/kubelet` fills up (e.g. stuck PVs), it won’t choke `/`.
  * If `/var/log` fills up, kubelet still runs.
* **Performance**

  * Container images (`/var/lib/containerd`) on SSD → faster pulls & launches.
  * PV backends (`/data`) on slower disks is fine.
* **Ops clarity**

  * `/srv` → for things exported by the node (if you run NFS-server or Ceph).
  * `/backup` → easy scripting, obvious intent.

---

## 🔹 Control plane nodes (extra)

* `/var/lib/etcd` — etcd database.

  * Put this on *fast, durable* disk (low fsync latency).
  * Often its own volume/partition so noisy workloads don’t spike etcd I/O.
* `/etc/kubernetes/pki` — cluster certs.

  * Small, but back it up.

---

✅ TL;DR:

* `/var/lib/kubelet` and `/var/lib/containerd` → **dedicated FS**.
* `/var/log` → **separate FS** with noexec/nodev/nosuid.
* `/var/lib/etcd` (control plane only) → **its own fast FS**.
* `/data` and `/srv` → your playground for persistent volumes and service exports.

---


## 🔹 Key directories & their SELinux types

**RHEL/Kubernetes gotchas**: Splitting things into separate partitions may result in loss of the expected SELinux labels (`system_u:object_r:container_file_t:s0`, etc.). That can break kubelet, containerd, or logging. 

The fix is to assign **fcontext rules** so mounts inherit the right labels:



| Directory                                  | Purpose                    | Expected SELinux type                                         |
| ------------------------------------------ | -------------------------- | ------------------------------------------------------------- |
| `/var/lib/kubelet`                         | Pod dirs, volumes          | `container_file_t`                                            |
| `/var/lib/containerd` or `/var/lib/docker` | Images, layers             | `container_var_lib_t` (RHEL9/8), sometimes `container_file_t` |
| `/var/lib/etcd`                            | etcd DB                    | `etcd_var_lib_t`                                              |
| `/var/log/containers`                      | Symlinks to container logs | `container_log_t`                                             |
| `/var/log/pods`                            | Per-pod log dirs           | `container_log_t`                                             |
| `/var/log` (generic system logs)           | journald, syslog           | `var_log_t`                                                   |
| `/srv/nfs` (if exporting)                  | NFS data                   | `public_content_rw_t` (or `nfs_t` for exports)                |
| `/data` (CSI/PV backends)                  | App volumes                | Usually `container_file_t` if kubelet uses it directly        |

---

## Sizing 

A **capacity planning sketch** for a generic (control or worker) Kubernetes node given **1 TB total disk** to allocate per node:

## 🔹Kubernetes Node Disk Allocation (1 TB total)

| Mount point           | Size (GB) | % of total | Notes                                                                    |
| --------------------- | --------- | ---------- | ------------------------------------------------------------------------ |
| `/` (root)            | 50–75     | ~7%        | OS, packages, `/etc`, system libs. Keep lean.                            |
| `/var/lib/kubelet`    | 200       | 20%        | Pod sandboxes, ephemeral volumes, secrets/configs. Needs breathing room. |
| `/var/lib/containerd` | 300       | 30%        | Container images & unpacked layers. Image-heavy clusters chew disk here. |
| `/var/lib/etcd`       | 50        | ~5%        | **Control-plane only**. Needs __low latency__, not huge size.                |
| `/var/log`            | 50–75     | ~7%        | System + container logs. With log rotation, 50–75 GB is comfortable.     |
| `/data`               | 250–300   | 25–30%     | Bulk storage for PersistentVolumes, NFS-backed paths, testing `hostPath`.  |
| `/backup`             | 50–75     | ~7%        | Etcd snapshots, configs, small dataset archives.                         |

![k8s-node-disk-allocation.webp](k8s-node-disk-allocation.webp)


## 🔹 Why these sizes

* **Root (`/`)**: Modern RHEL installs with GNOME and full tools can bloat >20 GB. 
  50 GB gives you a buffer but avoids waste.

* **`/var/lib/kubelet`**:

  * Pods mount emptyDirs, configMaps, secrets → all live here.
  * Bursty workloads (CI/CD, batch jobs) fill it quickly. 200 GB is safe.
* **`/var/lib/containerd`**:

  * Pulling large images (e.g. AI/ML or Java stacks) eats disk fast.
  * If you keep multiple versions/tags, you want headroom. 300 GB is a healthy balance.
* **`/var/lib/etcd`**:

  * Each etcd member stores a compressed history. Even large clusters rarely need >20 GB.
  * The real requirement is ***low fsync latency*** — give it SSD/NVMe if possible.
* **`/var/log`**:

  * Journal logs + kubelet/containerd logs.
  * With logrotate or fluent-bit shipping, 50–75 GB is safe.
* **`/data`**:

  * Largest flexible bucket.
  * Good for app PVs, experimental workloads, or serving NFS.
* **`/backup`**:

  * Keeps etcd snapshots & config archives separate.
  * If you offload backups elsewhere (NAS, object store), 50 GB is plenty.


The kubelet and the container runtime are *really greedy* about disk, especially once a cluster is busy. 
Here’s why they need so much breathing room:

### 🔹 `/var/lib/kubelet` (pod sandbox + ephemeral volumes)

* Every pod gets a “sandbox” directory under here.
* **emptyDir volumes** → all live on the node’s disk under `/var/lib/kubelet/pods/.../volumes/...`.

  * Think CI jobs unpacking tarballs, ML jobs writing scratch data, etc.
* Secrets and ConfigMaps get materialized here too (lots of small files).
* If a pod crashes and restarts, kubelet may keep the old dirs until garbage collection runs.

👉 On a busy node, this fills up shockingly fast — hence giving it 150–200 GB is sane.

### 🔹 `/var/lib/containerd` (image storage + layers)

* Each image you `pull` gets unpacked into multiple layers under here.
* Multiple tags of the same base image = more layers.
* Even after container exit, unless GC has purged, old layers stay around.
* Large images (e.g. AI/ML with CUDA, or Java stacks) can be **5–10 GB each**. Multiply by dozens of apps and versions → hundreds of GB easily.

👉 250–400 GB is very normal in real-world clusters with active pipelines.


### 🔹 Why it bites ops

* If `/var/lib/containerd` or `/var/lib/kubelet` fill up, kubelet goes into “ImageGC” or “Eviction” mode. That means pods get killed to free space.
* Worse, if it fills *root (`/`)* because you didn’t split partitions, the node can hard crash (`Read-only file system` remounts).


### 🔹 Real-world anecdotes

* **GitLab CI/CD runners** in Kubernetes → constantly pull different images for pipelines. Nodes without big `/var/lib/containerd` partitions churned through disk in hours.
* **ML workloads** pulling PyTorch/TensorFlow images (10–15 GB each) + checkpoints in `emptyDir` → 200 GB per node vanished almost overnight.
* **Default / partition only** → kubelet crashes because journald + container images + pods fight for the same disk.


✅ That’s why in your 1 TB plan, giving **~50% of the disk** (500 GB) to kubelet + containerd combined is advised. It’s not waste — it’s survival.

---


## 🔹 Example partitioning table

Single __1TB__ physical disk (`sda`)
```
/dev/sda1   50G    /                   (xfs)
/dev/sda2  200G    /var/lib/kubelet    (xfs)
/dev/sda3  300G    /var/lib/containerd (xfs)
/dev/sda4   50G    /var/lib/etcd       (xfs)   # control-plane only
/dev/sda5   75G    /var/log            (xfs)
/dev/sda6  250G    /data               (xfs)
/dev/sda7   75G    /backup             (xfs)
```

## 🔹 Variations

* **Workers only**: Drop `/var/lib/etcd` and give that 50 GB to `/data`.
* **Control-plane only**: Keep `/var/lib/etcd` small but *fast*.
* **Storage-heavy nodes**: Bias more towards `/data` (e.g. 400 GB) if you host PVs directly.
* **Image-heavy CI/CD nodes**: Increase `/var/lib/containerd` up to 400 GB.


## 🔹 SELinux : Setting persistent mappings

### Example fcontext rules

```bash
# Kubelet
semanage fcontext -a -t container_file_t "/var/lib/kubelet(/.*)?"

# Container runtime (containerd)
semanage fcontext -a -t container_var_lib_t "/var/lib/containerd(/.*)?"

# Docker alternative
semanage fcontext -a -t container_var_lib_t "/var/lib/docker(/.*)?"

# etcd DB
semanage fcontext -a -t etcd_var_lib_t "/var/lib/etcd(/.*)?"

# Pod & container logs
semanage fcontext -a -t container_log_t "/var/log/containers(/.*)?"
semanage fcontext -a -t container_log_t "/var/log/pods(/.*)?"

# PV backends
semanage fcontext -a -t container_file_t "/data(/.*)?"

# Service exports
semanage fcontext -a -t public_content_rw_t "/srv/nfs(/.*)?"
```

### Apply them

```bash
restorecon -Rv /var/lib/kubelet
restorecon -Rv /var/lib/containerd
restorecon -Rv /var/lib/etcd
restorecon -Rv /var/log/containers
restorecon -Rv /var/log/pods
restorecon -Rv /data
restorecon -Rv /srv/nfs
```

## 🔹 Verify labels

```bash
ls -Zd /var/lib/kubelet
ls -Zd /var/lib/containerd
ls -Zd /var/log/containers
```

Example output:

```
drwx------. root root system_u:object_r:container_file_t:s0 /var/lib/kubelet
```

## 🔹 Why this matters

* Without these, a new FS mounted at `/var/lib/kubelet` could inherit `default_t` or `var_lib_t`, and then kubelet fails to start pods with AVC denials.
* Same for container logs: if they’re not `container_log_t`, your log collector (fluent-bit, promtail) might get blocked.
* With fcontext rules, SELinux auto-applies the right labels after every reboot/remount.


✅ **Best practice on RHEL-based Kubernetes nodes**:

Always run `semanage fcontext` + `restorecon` after introducing new partitions for kubelet, containerd, etcd, or PV backends.

---


A clean **provision script** to run on RHEL-based Kubernetes nodes to set all the right SELinux fcontext mappings in one go.

It’s idempotent:

* If `semanage` rules already exist, it won’t duplicate.
* It runs `restorecon` after to apply labels immediately.

```bash
#!/usr/bin/env bash
#
# provision-selinux-k8s.sh
# Ensure SELinux contexts are correct for Kubernetes node directories.
#
# RHEL / CentOS / Rocky / Alma / Fedora compatible.

set -euo pipefail

# Check for semanage
if ! command -v semanage >/dev/null 2>&1; then
    echo "ERROR: semanage not found. Install policycoreutils-python-utils (RHEL8/9)."
    exit 1
fi

echo "▶ Setting SELinux fcontext rules for Kubernetes node directories..."

# Kubelet
semanage fcontext -a -t container_file_t "/var/lib/kubelet(/.*)?"

# Container runtime (containerd or docker)
semanage fcontext -a -t container_var_lib_t "/var/lib/containerd(/.*)?"
semanage fcontext -a -t container_var_lib_t "/var/lib/docker(/.*)?"

# etcd DB (control-plane nodes only, harmless elsewhere)
semanage fcontext -a -t etcd_var_lib_t "/var/lib/etcd(/.*)?"

# Pod & container logs
semanage fcontext -a -t container_log_t "/var/log/containers(/.*)?"
semanage fcontext -a -t container_log_t "/var/log/pods(/.*)?"

# PV backends (generic /data volume)
semanage fcontext -a -t container_file_t "/data(/.*)?"

# Service exports (if node also exports via NFS/HTTP/etc.)
semanage fcontext -a -t public_content_rw_t "/srv/nfs(/.*)?"

echo "▶ Applying SELinux contexts..."
restorecon -Rv /var/lib/kubelet    || true
restorecon -Rv /var/lib/containerd || true
restorecon -Rv /var/lib/docker     || true
restorecon -Rv /var/lib/etcd       || true
restorecon -Rv /var/log/containers || true
restorecon -Rv /var/log/pods       || true
restorecon -Rv /data               || true
restorecon -Rv /srv/nfs            || true

echo "✅ SELinux fcontexts applied successfully."
```

---

### 🔹 Usage

1. Save it as `provision-selinux-k8s.sh`.
2. Run once on each node (or push via Ansible):

   ```bash
   sudo bash provision-selinux-k8s.sh
   ```
3. Verify:

   ```bash
   ls -Zd /var/lib/kubelet /var/lib/containerd /var/lib/etcd /var/log/containers
   ```

---

## Ansible Playbook

A clean **Ansible role** to drop into a bootstrap playbook. 
It uses Ansible’s `community.general.sefcontext` and `ansible.builtin.command` 
modules to ensure SELinux mappings are persistent and applied.

### 🔹 Role structure

```
roles/
└── selinux_fcontext_k8s/
    ├── tasks/
    │   └── main.yml
    └── meta/
        └── main.yml
```

---

### 🔹 `tasks/main.yml`

```yaml
---
- name: Ensure policycoreutils-python-utils installed (RHEL 8/9)
  ansible.builtin.package:
    name: policycoreutils-python-utils
    state: present

- name: Define SELinux fcontexts for kubelet
  community.general.sefcontext:
    target: "/var/lib/kubelet(/.*)?"
    setype: container_file_t
    state: present

- name: Define SELinux fcontexts for containerd
  community.general.sefcontext:
    target: "/var/lib/containerd(/.*)?"
    setype: container_var_lib_t
    state: present

- name: Define SELinux fcontexts for docker (if used)
  community.general.sefcontext:
    target: "/var/lib/docker(/.*)?"
    setype: container_var_lib_t
    state: present

- name: Define SELinux fcontexts for etcd (control-plane only)
  community.general.sefcontext:
    target: "/var/lib/etcd(/.*)?"
    setype: etcd_var_lib_t
    state: present

- name: Define SELinux fcontexts for container logs
  community.general.sefcontext:
    target: "/var/log/containers(/.*)?"
    setype: container_log_t
    state: present

- name: Define SELinux fcontexts for pod logs
  community.general.sefcontext:
    target: "/var/log/pods(/.*)?"
    setype: container_log_t
    state: present

- name: Define SELinux fcontexts for generic data PVs
  community.general.sefcontext:
    target: "/data(/.*)?"
    setype: container_file_t
    state: present

- name: Define SELinux fcontexts for NFS exports
  community.general.sefcontext:
    target: "/srv/nfs(/.*)?"
    setype: public_content_rw_t
    state: present

- name: Restore SELinux contexts recursively
  ansible.builtin.command: restorecon -Rv {{ item }}
  loop:
    - /var/lib/kubelet
    - /var/lib/containerd
    - /var/lib/docker
    - /var/lib/etcd
    - /var/log/containers
    - /var/log/pods
    - /data
    - /srv/nfs
  register: restorecon_out
  changed_when: restorecon_out.rc == 0
```


### 🔹 `meta/main.yml`

```yaml
---
dependencies: []
```

### 🔹 Playbook example

```yaml
- hosts: k8s_nodes
  become: true
  roles:
    - selinux_fcontext_k8s
```

✅ This ensures:

* fcontext mappings are permanent (in SELinux policy).
* contexts are immediately applied with `restorecon`.
* works idempotently across re-runs.

---

### Ansible tasks for systemd drop-ins

So kubelet/containerd service units depend on the correct mounts being present before they start.
That ties neatly into this partitioning + SELinux scheme.

Tying systemd drop-ins into the Ansible workflow ensures that **kubelet** and **containerd** (or docker) 
only start once their required mount points are present. 
This avoids *race conditions* at boot, 
where services fail because `/var/lib/kubelet` or `/var/lib/containerd` wasn’t mounted yet.

### 🔹 systemd drop-in strategy

* Use `systemd_unit` (or `template` + `systemctl daemon-reload`) to create drop-ins under:

  * `/etc/systemd/system/kubelet.service.d/10-requires-mounts.conf`
  * `/etc/systemd/system/containerd.service.d/10-requires-mounts.conf`
* These add:

  ```ini
  [Unit]
  RequiresMountsFor=/var/lib/kubelet
  ```

  and similar for containerd/docker.

Systemd then ensures the mount unit is active before starting the service.


## 🔹 Updated role structure

```
roles/
└── selinux_fcontext_k8s/
    ├── tasks/
    │   ├── main.yml
    │   └── systemd.yml
    ├── templates/
    │   ├── 10-requires-mounts-kubelet.conf.j2
    │   └── 10-requires-mounts-containerd.conf.j2
    └── meta/
        └── main.yml
```

## 🔹 `tasks/systemd.yml`

```yaml
---
- name: Ensure drop-in directory for kubelet
  ansible.builtin.file:
    path: /etc/systemd/system/kubelet.service.d
    state: directory
    mode: "0755"

- name: Ensure drop-in directory for containerd
  ansible.builtin.file:
    path: /etc/systemd/system/containerd.service.d
    state: directory
    mode: "0755"

- name: Deploy kubelet mount requirement drop-in
  ansible.builtin.template:
    src: 10-requires-mounts-kubelet.conf.j2
    dest: /etc/systemd/system/kubelet.service.d/10-requires-mounts.conf
    mode: "0644"
  notify: Reload systemd

- name: Deploy containerd mount requirement drop-in
  ansible.builtin.template:
    src: 10-requires-mounts-containerd.conf.j2
    dest: /etc/systemd/system/containerd.service.d/10-requires-mounts.conf
    mode: "0644"
  notify: Reload systemd
```

## 🔹 `templates/10-requires-mounts-kubelet.conf.j2`

```ini
[Unit]
RequiresMountsFor=/var/lib/kubelet
RequiresMountsFor=/var/log/pods
RequiresMountsFor=/var/log/containers
```

## 🔹 `templates/10-requires-mounts-containerd.conf.j2`

```ini
[Unit]
RequiresMountsFor=/var/lib/containerd
```

*(If using Docker, just change to `/var/lib/docker`.)*

## 🔹 Add handlers in `tasks/main.yml`

```yaml
handlers:
  - name: Reload systemd
    ansible.builtin.command: systemctl daemon-reload

  - name: Restart kubelet
    ansible.builtin.service:
      name: kubelet
      state: restarted

  - name: Restart containerd
    ansible.builtin.service:
      name: containerd
      state: restarted
```

## 🔹 Playbook snippet

```yaml
- hosts: k8s_nodes
  become: true
  roles:
    - selinux_fcontext_k8s
  tasks:
    - include_role:
        name: selinux_fcontext_k8s
        tasks_from: systemd.yml
```

✅ Now at boot:

* systemd guarantees `/var/lib/kubelet`, `/var/lib/containerd`, `/var/log/pods`, and `/var/log/containers` are mounted *before* kubelet/containerd start.
* Combined with SELinux fcontext setup, you get correct labeling + reliable startup.


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
