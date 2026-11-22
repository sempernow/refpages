# [KubeVirt](https://kubevirt.io/ "KubeVirt.io")

>Building a virtualization API for Kubernetes

Under the hood, KubeVirt does not reinvent hypervisor technology. Instead, it serves as a highly specialized translation layer and management fabric. It forces standard, battle-tested Linux virtualization tools to operate entirely within the constraints and life cycle of a Kubernetes container pod. [1, 2, 3] 

The core architectural engine relies on a dual-plane model to convert declarative YAML instructions into hardware-isolated operating environments. [3, 4] 

------------------------------

## 1. The Core Infrastructure Stack

At the bare metal level, a KubeVirt virtual machine is managed by the exact same virtualization components that power OpenStack and legacy Linux data centers: [2, 5] 

+-------------------------------------------------------+

|                Virtual Machine Guest OS               |
+-------------------------------------------------------+

|       QEMU (Emulates disks, network cards, BIOS)      |  <-- Runs inside the Pod
+-------------------------------------------------------+

|  libvirt / libvirtd (Orchestrates the QEMU process)   |  <-- Container Process Sandbox
+=======================================================+

|           Linux Kernel Namespaces & cgroups           |  <-- Standard Pod boundary
+=======================================================+

|       KVM (Kernel-based VM: Hardware Acceleration)    |  <-- Host Linux Kernel
+-------------------------------------------------------+


* **KVM** (Kernel-based Virtual Machine): KVM is a module built directly into the host machine's Linux kernel. It transforms the physical CPU into a Type-1 hypervisor, exposing the /dev/kvm interface to provide the guest VM with native hardware execution speeds.
* **QEMU**: Because KVM only virtualizes the CPU and memory, QEMU runs as a standard Linux user-space process to emulate the remainder of the computer system. This includes simulating the motherboard, PCI buses, BIOS/UEFI, network interface cards (NICs), and disk controllers.
* [**libvirt**](https://libvirt.org/): Virtualization API; an open-source, vendor-neutral API, daemon, and management toolkit designed to manage virtualization technologies like KVM, QEMU, Xen, and LXC. Acting as the programmatic manager for QEMU, libvirt exposes clean API entry points and XML-based configurations to build, snapshot, and alter running virtual guest configurations without interacting with raw QEMU command-line parameters. [1, 5, 6, 7, 8, 9] 

------------------------------

## 2. The Internal Control Flow Components

When you apply a VirtualMachine manifest (kubectl apply -f vm.yaml), a precise chain of internal KubeVirt components translates that resource into a running workload: [2, 3, 9] 

[ User Manifest ] 
       │
       ▼
 [ virt-api ] ──► [ Custom Resources (VM / VMI) ]
                        │
                        ▼
                [ virt-controller ] ──► (Schedules & creates target runner Pod)
                                              │
                                              ▼
                                      [ virt-handler ] (Runs on target worker node)
                                              │
                                              ▼
                                      [ virt-launcher ] (Launches QEMU/libvirt inside Pod)


* virt-api: Serves as the primary entry point for all virtualization commands. It handles custom API validation and mutation webhooks, adjusting standard Kubernetes behaviors to support specific VM needs (like checking if a host supports hardware virtualization).
* virt-controller: This cluster-wide management loop monitors the cluster for VirtualMachineInstance (VMI) changes. It performs the crucial task of generating a corresponding Kubernetes Pod definition tailored to encapsulate that specific VM.
* virt-handler: Running as a privileged DaemonSet on every single physical worker node in the cluster, virt-handler behaves like a virtualization-specific companion to the kubelet. It sits on the host node, waiting for a VM pod to be assigned to its machine by the native Kubernetes scheduler, and then configures host-level networking or storage devices.
* virt-launcher: For every running VM, a dedicated container helper called virt-launcher executes directly inside that specific Pod. Its primary duty is to run a local libvirtd daemon, invoke the local QEMU process, and pass the lifecycle signals (such as shutdown, reboot, or pause commands) received from virt-handler down into the VM. [3, 6, 8, 10, 11, 12] 

------------------------------

## 3. How It Tricks Kubernetes Into Running a VM

**The "Pod as a Hypervisor Sandbox" Illusion**

To native Kubernetes nodes, a VM is simply a standard containerized process bounded by namespaces and cgroups. [KubeVirt](https://kubevirt.io/) exposes `/dev/kvm` into the `virt-launcher` pod container using a standard volume mount or host device plugin. The QEMU process starts inside this container sandbox. If the guest OS inside the VM triggers an Out-Of-Memory (OOM) error or panic, the Linux kernel isolates the crash entirely within that specific pod wrapper. [1, 6, 9, 10, 13] 

## Storage Integration (Containerized Data Importer - CDI)

Instead of using complex storage protocols specific to virtualization, KubeVirt maps Kubernetes Persistent Volume Claims (PVCs) directly to the VM. It utilizes a sidecar utility called the Containerized Data Importer (CDI). CDI watches for special DataVolume manifests, spins up a temporary helper pod to pull a raw operating system image (`.qcow2`, `.img`, or ISO) from a registry or HTTP URL, and copies it directly onto a standard Container Storage Interface (CSI) disk. This disk is then mapped by QEMU as a block device or virtual disk (`vda`). [3, 7, 9, 10, 14] 

## Networking Integration

The virtual network adapter (`eth0`) seen by the guest operating system inside the VM is actually connected to the primary network interface inside the Kubernetes Pod network namespace via a virtual ethernet pair or bridge. Because the traffic terminates inside the pod boundary, the VM automatically inherits the existing Container Network Interface (CNI) framework. Consequently, native cluster NetworkPolicies or Service routing frameworks operate transparently against the VM without needing any specialized nested network configuration. [3, 6, 10, 14] 


- [1] [https://www.reddit.com](https://www.reddit.com/r/kubernetes/comments/13zaybe/where_is_vm_works_in_kubevirt_in_a_pod/)
- [2] [https://www.kubermatic.com](https://www.kubermatic.com/learn/kubevirt/what-is-kubevirt/)
- [3] [https://www.kubermatic.com](https://www.kubermatic.com/blog/what-is-kubevirt-and-how-does-it-fit-into-kubermatic-virtualization/)
- [4] [https://www.spectrocloud.com](https://www.spectrocloud.com/blog/the-future-of-vms-on-kubernetes-building-on-kubevirt)
- [5] [https://portworx.com](https://portworx.com/blog/kubevirt-the-bridge-between-worlds/)
- [6] [https://bespinian.io](https://bespinian.io/en/blog/kubevirt/)
- [7] [https://www.youtube.com](https://www.youtube.com/watch?v=a4C1_RrIRTU)
- [8] [https://trilio.io](https://trilio.io/openshift-virtualization/kubevirt/)
- [9] [https://www.linkedin.com](https://www.linkedin.com/pulse/kubevirt-deep-dive-from-vmware-vsphere-admin-part-1-salim-reza-ormdc)
- [10] [https://kubevirt.io](https://kubevirt.io/user-guide/architecture/)
- [11] [https://github.com](https://github.com/kubevirt/kubevirt/blob/main/docs/README.md)
- [12] [https://www.redhat.com](https://www.redhat.com/en/blog/a-first-look-at-kubevirt)
- [13] [https://www.hackingnote.com](https://www.hackingnote.com/en/kubernetes/kubevirt/)
- [14] [https://www.youtube.com](https://www.youtube.com/watch?v=JniNepFJHLs&t=10)



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
