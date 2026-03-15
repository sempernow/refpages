# Mapping container root to host non-root

## Background : Kernel vs. Root vs. Non-root

The relationship between "kernel processes" and the "`root`" user is often misunderstood because kernel mode and root privileges are *different concepts*.

### Kernel Mode vs. Root User

* Kernel Mode: This is a CPU hardware state. In this mode, code has unrestricted access to hardware and memory.
    * Beyond User Identity: Kernel threads (like `kthreadd` or `kswapd`) run entirely in kernel space. Because they are part of the kernel itself, they do not need to check permissions against a "user".
    * Displayed as Root: When you view these threads in tools like htop or ps, they are typically shown as being owned by root (`UID 0`) for convenience and system compatibility.
    * Initialization: The kernel starts the first process (`init` or `systemd`) as root. All subsequent user-space processes are children of this root process unless privileges are explicitly dropped. 
* Root User (`UID 0`): This is a software-level identity managed by the kernel. The kernel is programmed to grant a process with `UID 0` nearly all permissions. 

### Summary Table

| Feature | User Process (Non-Root) | User Process (Root) | Kernel Thread |
|---|---|---|---|
| CPU Mode | User Mode (usually) | User Mode (usually) | Always Kernel Mode |
| User ID | > 0 | 0 | Typically shown as 0 (Root) |
| Permissions | Restricted | "Superuser" (granted by kernel) | Unrestricted (is part of the kernel) |

### Identify kernel threads

The primary giveaway is that ***kernel threads lack a user-space executable***, 
meaning they have no "command line" or "mapped memory" in the traditional sense. 

1. Using the `ps` Command (The Square Bracket Convention)
By convention, kernel threads are shown with their names inside square brackets in process lists. 
    * Command: `ps aux` or `ps -ef`
    * What to look for: Processes like `[kthreadd],` `[ksoftirqd/0]`, or `[kworker/uX:X]`.
    * Filtering: To see only kernel threads, you can filter for processes whose parent is `PID 2` (`kthreadd`), which is the ancestor of all modern kernel threads.
    * `ps --ppid 2 -p 2`
2. Checking for an Empty Command Line  
A definitive technical way to identify a kernel thread is to check its command line in the `/proc` filesystem. Since kernel threads do not have a binary file on disk, their cmdline file is empty. 
    * Command: `cat /proc/<PID>/cmdline`
    * Result: If the output is completely empty (no text at all), it is a kernel thread. 
3. Using `htop` (Visual Indicators)  
Provides built-in visual cues for kernel threads.
    * Color Coding: In many default configurations, kernel threads are displayed in a different color (often red or green depending on your theme).
    * Toggling: You can press **Shift + K** while inside htop to hide or show kernel threads to see the difference.
    * Setup: In the htop setup menu (**F2**), under "**Display options**," you can specifically check "**Hide kernel threads**" to clean up your view. 
4. Inspecting Memory Maps    
Because kernel threads operate entirely within the kernel's address space, they do not have private user-space memory maps.
    * Command: `cat /proc/<PID>/maps`
    * Result: For a real kernel thread, this file will be empty. If it contains data (like library links), it is a user-space process.

### Container process

An OCI container process is not necessarily running as root on your host system, even if it claims to be "root" inside the container. This is the core functional difference between "rootful" and "rootless" container engines like Podman. 

1. Identity vs. Privilege (The Mapping)   
In rootless mode, Podman uses a kernel feature called User Namespaces to perform a "sleight of hand" with User IDs (UIDs). 
    * Inside the Container: The process sees itself as UID 0 (root). 
    This allows it to perform internal tasks like installing packages via `apt` or `yum`.
    * On the Host: The kernel maps that "root" identity to your regular user UID (e.g., UID 1000).
    * The Result: If the process "breaks out" of the container, it only has the permissions of your normal user. It cannot modify system files, access other users' data, or shut down the machine.
2. Rootless vs. Rootful Comparison
    | Feature | Rootful (e.g., Default Docker) | Rootless (e.g., Podman) |
    |---|---|---|
    | Host Process Owner | root (UID 0) | Your User (e.g., UID 1000) |
    | Container "root" | Real host root | Mapped to your host UID |
    | System Risk | High (can compromise host) | Low (limited to your user) |
    | Capabilities | Full (can load kernel modules) | Restricted (cannot load modules) |
3. Verification Command  
You can see this mapping in action on your own machine. 
Run a container and check the "Host User" (`HUSER`) vs the "Container User" (`USER`):
    ```bash
    podman run -d --name test_user alpine sleep 100
    podman top test_user user huser
    ```
- The output will show root in the USER column but your actual numeric UID in the HUSER column.
4. When it is actually Root  
The process is only truly running as host root if:
    * You prefixed the command with sudo (e.g., sudo podman run...).
    * You are using the default Docker daemon, which runs as a root-privileged service.


## Kubernetes support for root-user mapping

Kubernetes can map container root to a non-root host UID using User Namespaces, but it depends on your specific distribution's version and underlying components (CRI and Kernel). 

This feature allows a process to have full root (UID 0) privileges inside the container (e.g., to run apt-get or yum) while remaining a completely unprivileged non-root user on the host system. 

### Requirements : Host OS and Kubernetes Distros

As of **Kubernetes v1.33** (released April 2025), user namespace support is enabled by default. 

1. Cloud Managed Services
    * AWS **EKS**: Supports user namespaces starting with Kubernetes 1.33. It requires using [**Bottlerocket OS**](https://github.com/bottlerocket-os/bottlerocket/issues/3328) (v1.33 variant) or a kernel version 6.12+ with user.max_user_namespaces enabled.
    * Azure **AKS**: Support is [Generally Available](https://github.com/Azure/AKS/issues/3949) for clusters running v1.33+ using Ubuntu 24.04 or Azure Linux 3.0 nodes.
    * Google **GKE**: While GKE documentation frequently references standard namespaces for multi-tenancy, it follows the upstream K8s release cycle and supports this feature in clusters updated to v1.33+.
2. On-Prem & Lightweight Distributions  
    Support for these depends heavily on the Container Runtime (CRI) version bundled with them. You generally need containerd 2.0+ or CRI-O 1.25+. 
    * **k3s** / **rke2**: Since these are based on upstream Kubernetes and use containerd, they support user namespaces in versions aligned with K8s 1.30 (Beta) or 1.33 (Stable/Default).
    * **k0s**: Built as a "plain vanilla" distribution, k0s supports any feature available in the upstream version it packages. You can use user namespaces in k0s v1.33+.
    * **kind**: Supports user namespaces if the host running the kind nodes (usually your laptop/server) has a modern kernel (6.3+) and you use a kind node image based on Kubernetes 1.30+. 

### Summary of Prerequisites

To successfully map container root to host non-root, your environment must meet these three criteria:

1. Kubernetes Version: 1.30+ (Beta) or 1.33+ (Stable/Default).
2. Container Runtime: containerd v2.0+ or CRI-O v1.25+.
3. Linux Kernel: Ideally **v6.3** or greater to handle "**`idmapped mounts`**", 
    which allow the kernel to correctly map file ownership between the host and container.

### How it Works in Kubernetes

As of **Kubernetes v1.33+**, support for user namespaces is enabled by default.

* Mapping Strategy: When you enable this feature, the kubelet assigns a unique range of UIDs/GIDs from the host to the pod. For example, UID 0 inside the container might be mapped to UID 100,000 on the host.
* Opt-in Requirement: You must explicitly tell Kubernetes to use a separate user namespace for a pod.
* Security Benefit: If a process escapes the container, it only has the permissions of that high-numbered, unprivileged host UID, effectively neutralizing many "container breakout" attacks. 

### Implementation

To use this, your cluster must be running on a compatible Linux kernel and container runtime , e.g.,  [containerd 2.0+](https://kubernetes.io/blog/2025/04/25/userns-enabled-by-default/) 
or CRI-O 1.30+. You then **configure the pod `spec`** as follows: 

```yaml
...
spec:
  hostUsers: false  # This triggers the use of a separate user namespace
  containers:
  - name: my-app
    image: alpine
    securityContext:
      runAsUser: 0  # Still root INSIDE the container
```

### Kubernetes vs. Rootless Podman

While the underlying technology (Linux User Namespaces) is the same, 
the execution differs: 

* **Podman Rootless**: The entire container engine (Podman itself) runs as your user.
* **Kubernetes**: The node components (Kubelet/Runtime) typically still run as host root, 
  but they use kernel features to "jail" the container processes into a non-privileged UID range. 

### Linux Kernel LTS versions

Linux v6.3 is not an LTS release and never will be.
 It reached End-of-Life (EOL) in July 2023, 
 meaning it no longer receives any security patches or bug fixes. 

The Linux kernel maintainers typically designate only one version per year as "Longterm" (LTS). For the 6.x series, the official LTS versions are: 

* Linux 6.1: Supported until December 2027.
* Linux 6.6: Supported until December 2027.
* Linux 6.12: Supported until December 2028.
* Linux 6.18: Supported until December 2028. [4, 7, 8, 9] 

#### Current LTS Status (as of March 2026)

| Kernel Version | Type | Release Date | Projected EOL |
|---|---|---|---|
| 6.19 | Stable (Mainline) | Feb 2026 | ~May 2026 |
| 6.18 | LTS | Nov 2025 | Dec 2028 |
| 6.12 | LTS | Nov 2024 | Dec 2028 |
| 6.6 | LTS | Oct 2023 | Dec 2027 |
| 6.3 | EOL | Apr 2023 | July 2023 (Ended) |

Recently, in early 2026, maintainers extended the support periods for 6.6, 6.12, and 6.18 to provide more stability for enterprise distributions like **Debian 13** and **RHEL 10**.

## RHEL 9 Support for root-user Mapping

To support root-user mapping (User Namespaces) on RHEL 9, you face a specific challenge: while the software (Kubernetes/containerd) supports it, the RHEL 9 kernel (5.14) lacks the critical "**`idmapped mounts`**" feature required for seamless volume support. [1, 2] 
However, you can achieve this mapping using the following version combinations, depending on whether you need volume support (e.g., mounting ConfigMaps or PVCs). [3, 4] 

### 1. **Recommended Combination** (Production-Ready)  

To avoid severe performance penalties, you need containerd 2.0+, which is designed to handle the modern Kubernetes user namespace implementation. [5, 6]   

| Component [5, 6, 7] | Minimum Version | Reason |
|---|---|---|
| Kubernetes | v1.33+ | User namespaces are enabled by default. |
| containerd | v2.0+ | Required for compatibility with K8s 1.27+ redesign. |
| crun | v1.9+ | RHEL 9's default runtime (crun) must be updated to support the mapping. |

### 2. The **RHEL 9 Kernel Limitation**  

RHEL 9 uses Kernel 5.14. [8, 9] 

* The Problem: Standard Kubernetes user namespace support for volumes (like tmpfs for Secrets/Tokens) requires Kernel 6.3+ for idmapped mounts.
* The RHEL Behavior: On RHEL 9, containerd will fall back to manually chowning every file in the container image to the new UID/GID during startup.
* Impact: This causes significantly slower pod startup times and higher disk I/O. [1, 6] 

### 3. Alternative: CRI-O on RHEL 9  

If you are using OpenShift (OKD) or a distribution that supports [CRI-O](https://cri-o.io/), the limitations of containerd 1.7 do not apply as strictly. [6] 

* CRI-O Version: v1.25+.
* Runtime: Use crun (RHEL 9's default) rather than runc. [5, 6] 

### Summary Table for RHEL 9 Setup

| Goal [3, 6] | K8s Version | Runtime Version | Performance |
|---|---|---|---|
| Modern/Default | 1.33+ | containerd 2.0+ | Slow Startup (due to Kernel 5.14) |
| Legacy/Experimental | 1.25 - 1.26 | containerd 1.7 | Slow Startup & Limited Volume Support |

Warning: RHEL 9 security profiles (STIGs) often disable user namespaces by default (`user.max_user_namespaces = 0`). You **must manually enabl**e this via `sysctl` before the mapping will work. 

### Test / Verify

To verify and enable root-user mapping (User Namespaces) on RHEL 9, use the following steps.

#### 1. Enable User Namespaces on the Host [1]   

RHEL 9 often disables user namespaces by default for security hardening (e.g., DISA STIGs). You must enable them and ensure enough namespaces are available for your pods. [2, 3] 

* Temporary Enable:  
`sudo sysctl -w user.max_user_namespaces=1024`
* Persistent Enable:  
Add the following to a new file, e.g., `/etc/sysctl.d/99-userns.conf`:
`user.max_user_namespaces = 10000`
* Apply Changes:  
`sudo sysctl --system` [4, 5] 

#### 2. Configure Subordinate IDs [6]   

The Kubelet requires a range of UIDs/GIDs on the host to map into the container. These ranges must be defined for the user running the container process (or the kubelet identity). [7, 8] 

* Check existing ranges: cat /etc/subuid
* Add a range (Example for a 65k ID range)  [7] :  
    ```bash
    sudo usermod --add-subuids 100000-165535 <user>
    sudo usermod --add-subgids 100000-165535 <user>
    ``` 

#### 3. Test Pod Manifest

This manifest explicitly requests a separate user namespace. 
On RHEL 9 (Kernel 5.14), containerd 2.0+ will use this to map the container's root to a high-numbered host UID. [8, 9] 

```yaml
apiVersion: v1kind: Podmetadata:
name: userns-verifyspec:
hostUsers: false  # Required: Tells K8s to use a separate User Namespace
containers:
- name: alpine
    image: alpine
    command: ["sleep", "3600"]
    securityContext:
    runAsUser: 0   # Root INSIDE the container
```

#### 4. **Verification Commands**  

Once the pod is running, verify the "sleight of hand" mapping:

* Inside the Container:  
`kubectl exec userns-verify -- id`
* Expected Result: u`id=0(root) gid=0(root)`
* On the RHEL 9 Host:  
Find the process ID and check its real owner:  
`ps -ef | grep sleep`
* Expected Result: The process will be owned by a high-numbered UID 
    (e.g., `100000`) rather than `root`. [3, 10] 

Performance Note: Because RHEL 9 uses Kernel 5.14, it lacks "`idmapped mounts`". Expect a delay during pod startup while the runtime recursively changes ownership (`chown`) of the container's filesystem to match your new UID range. [9, 11, 12, 13] 


- [1] [https://unix.stackexchange.com](https://unix.stackexchange.com/questions/602408/how-can-i-enable-user-namespaces-and-have-it-persist-after-reboot)
- [2] [https://www.tenable.com](https://www.tenable.com/audits/items/DISA_STIG_Red_Hat_Enterprise_Linux_9_v1r3.audit:f856b6805cdafa29a742cf7e7e036e84)
- [3] [https://www.redhat.com](https://www.redhat.com/en/blog/rootless-podman-user-namespace-modes)
- [4] [https://www.tenable.com](https://www.tenable.com/audits/items/DISA_STIG_Red_Hat_Enterprise_Linux_9_v2r7.audit:eb666b04677ec48fc4c0685153645dc6)
- [5] [https://ato-pathways.com](https://ato-pathways.com/catalogs/xccdf/benchmarks/ssg-rhel9-ds.xml:latest/items/xccdf_org.ssgproject.content_rule_sysctl_user_max_user_namespaces_no_remediation)
- [6] [https://kubernetes.io](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/)
- [7] [https://oneuptime.com](https://oneuptime.com/blog/post/2026-03-04-configure-user-namespaces-podman-rootless-rhel-9/view)
- [8] [https://kubernetes.io](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/)
- [9] [https://github.com](https://github.com/containerd/containerd/blob/main/docs/user-namespaces/README.md)
- [10] [https://kubernetes.io](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
- [11] [https://sourcegraph.com](https://sourcegraph.com/github.com/containerd/containerd/-/blob/docs/user-namespaces/README.md)
- [12] [https://docs.redhat.com](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/considerations_in_adopting_rhel_9/index)
- [13] [https://www.redhat.com](https://www.redhat.com/en/blog/rootless-podman-user-namespace-modes)

## Talos OS + Kubernetes 

[Talos Linux is a CNCF project](https://www.cncf.io/online-programs/cloud-native-live-talos-linux-for-kubernetes/) that meets the technical requirements for the Kubernetes user namespace remapping feature (often referred to as root-user mapping) due to its modern kernel and container-focused architecture. [1, 2] 

- Talos v1.9.0: Uses Linux kernel 6.12.5
- Talos v1.12.3: Uses Linux kernel 6.18.8

### Compliance Requirements [3] 

* **Kernel Version**:   
Kubernetes user namespace support for pods with volumes (including Secrets and ConfigMaps) requires Linux kernel 6.3 or later for idmap mounts. Talos Linux consistently ships with [current stable Linux versions](https://www.talos.dev/).
* **Container Runtime**:   
The feature requires a CRI-compatible runtime that supports user namespaces, such as containerd (v1.7+). Talos is built specifically to run [containerd](https://cloudkoffer.dev/provisioning/kubernetes/talos/) and includes it as one of its few core binaries.
* **Filesystem Support**:   
For `idmap mounts` to work with persistent volumes, the underlying filesystem must support them. Talos uses XFS for node storage, which supports these mappings. [4, 5, 6, 7, 8] 

### Configuration

While Talos supports the underlying technology, 
you must configure the following to enable the feature: [7, 9] 

* **Feature Gates**:   
Ensure the UserNamespacesSupport feature gate is enabled in your Kubernetes version (it is [enabled by default](https://kubernetes.io/blog/2025/04/25/userns-enabled-by-default/) starting in v1.33).
* **UID/GID Ranges**:   
The kubelet must be configured with a subordinate UID/GID range. This range must be a multiple of 65,536 and cannot use IDs from the 0-65,535 range.
* **Pod Configuration**:   
To trigger the mapping, pods must set "`hostUsers: false`" in their security context. [4, 5, 10] 

- [1] [https://www.safespring.com](https://www.safespring.com/blogg/2025/2025-03-talos-linux-on-openstack/#:~:text=Traditional%20operating%20systems%20are%20designed%20for%20static%2C,integrate%20with%20CI/CD%20pipelines%20and%20infrastructure%2Das%2Dcode%20workflows.)
- [2] [https://dev.to](https://dev.to/sergelogvinov/install-talos-on-any-cloud-servers-2b2e)
- [3] [https://oneuptime.com](https://oneuptime.com/blog/post/2026-03-03-check-talos-linux-system-requirements-before-installation/view)
- [4] [https://kubernetes.io](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/)
- [5] [https://kubernetes.io](https://kubernetes.io/blog/2025/04/25/userns-enabled-by-default/)
- [6] [https://cloudkoffer.dev](https://cloudkoffer.dev/provisioning/kubernetes/talos/)
- [7] [https://blog.yadutaf.fr](https://blog.yadutaf.fr/2024/03/14/introduction-to-talos-kubernetes-os/)
- [8] [https://kubernetes.io](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/#:~:text=To%20use%20user%20namespaces%20with%20Kubernetes%2C%20you,to%20use%20this%20feature%20with%20Kubernetes%20pods:)
- [9] [https://docs.siderolabs.com](https://docs.siderolabs.com/talos/v1.11/security/machine-config-oauth)
- [10] [https://kubernetes.io](https://kubernetes.io/docs/tasks/configure-pod-container/user-namespaces/)


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
