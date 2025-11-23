# OCI containers

## Tools

### Full-scope handlers

- docker
- podman
- nerdctl

### Image tags

Various tools/methods to `GET` 
a flat __list of all image tags__ 
available from a particular (OCI/CNCF) registry.

```bash
host=registry.k8s.io
path=sig-storage/smbplugin
img=$host/$path # Sans tag!

# crane
crane ls $img 

# CNCF API
curl -s "https://$host/v2/$path/tags/list" | jq -r '.tags[]'

```

## Containers From Perspective of **System Administrator (SAs)**

---

### 🧱 1. **Foundational Concept**

> "OCI containers are a formalized, standardized way to run isolated processes on a Linux system, with predictable configuration and lifecycle semantics."

---

### 🔐 2. **Parallels with Familiar Concepts**

| Traditional Concept | OCI Container Equivalent             |
| ------------------- | ------------------------------------ |
| `chroot` jail       | Filesystem isolation (`rootfs`)      |
| `cgroups`           | Resource constraints                 |
| `namespaces`        | Network, PID, IPC, and UTS isolation |
| RPM/DEB packages    | Image layers with filesystem diffs   |
| systemd service     | Container runtime process lifecycle  |

---

### 📦 3. **OCI = Open Standard**

* **OCI (Open Container Initiative)** defines:

  * **Image Format** – How container images are packaged and stored.
  * **Runtime Specification** – How containers are executed from images (e.g., via `runc`).
  * **Distribution Specification** – How images are shared over registries (e.g., `docker pull`/`podman pull`).

> "Think of OCI as the 'POSIX' for containers. It's what makes runtimes like Docker, Podman, and containerd __interoperate__ cleanly."

---

### 🚀 4. **Why It Matters to SAs**

* **Standardized Deployment:** Build once, run anywhere across Docker, Kubernetes, CRI-O, etc.
* **Immutable Infrastructure:** Container images are versioned, reproducible, and verifiable.
* **Lifecycle Integration:** You can plug containers into `systemd`, CI/CD pipelines, or even CRON jobs.
* **Security Boundaries:** SELinux/AppArmor, seccomp, and user namespaces offer defense-in-depth.

---

### 🛠 5. **Common Tools Using OCI**

* **Docker/Podman:** Build/run containers.
* **containerd/cri-o:** Runtime daemons used by Kubernetes.
* **Kubernetes:** Schedules and manages OCI-compliant containers.

---

### 🧪 6. **Example Explanation**

> "An OCI container is just a process on the host that’s running in a constrained environment: a chrooted rootfs, with limited CPU/memory, no access to host PID or network unless configured. What makes it powerful is that the environment is described in a portable, declarative JSON file, and the image that backs it is versioned and shareable."

---

## 🧪 Hands-on: Running a Container with `runc` 

> **Goal:** Run `/bin/sh` from a busybox image inside a minimal OCI container using `runc`.

---

### 🔧 1. **Pre-reqs**

```bash
sudo dnf install -y runc  # or apt install runc
```

Make a working directory:

```bash
mkdir ~/runc-test && cd ~/runc-test
```

---

### 📦 2. **Create a Root Filesystem**

Extract it from the image (in cache else pulls it first):

```bash
mkdir -p rootfs
docker export $(docker create busybox) |tar -C rootfs -xvf -

```


### 🧾 3. **Generate Default OCI Config**

```bash
runc spec
```
- `config.json`

This creates a file called `config.json`. It’s the **OCI Runtime Spec**, describing how to run the container.

---

### ✏️ 4. **Edit the `config.json`**

Open in your favorite editor:

```bash
vi config.json
```

Change the following fields:

* **`process.args`**:

  ```json
  "args": ["sh"]
  ```

* Optional (to drop privileges):

  ```json
  "root": {
    "path": "rootfs",
    "readonly": false
  }
  ```

* Optional (to set hostname):

  ```json
  "hostname": "runc-demo"
  ```

---

### 🚀 5. **Run the Container**

```bash
sudo runc run demo
```

You’ll be dropped into a shell (`sh`) inside the container. You can confirm isolation:

```sh
hostname        # should be "runc-demo"
ps              # only shows minimal PID tree
ls /            # comes from BusyBox
```

---

## 🧠 Summary

* `rootfs/` contains the filesystem.
* `config.json` is the OCI Runtime Spec.
* `runc run <container-id>` creates an isolated process from that spec.
* Nothing about registries, Docker, or Kubernetes is required—this is **bare-metal containerization**.

---
