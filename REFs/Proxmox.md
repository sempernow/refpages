# [**P**roxmox **V**irtual **E**nvironment](https://www.proxmox.com/en/proxmox-virtual-environment/overview "Proxmox.com") (PVE)

## Install

[Download ISO](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview "Proxmox.com")

1. Copy ISO, e.g., `proxmox-ve_8.4-1.iso`, onto USB using Rufus. 
2. Boot from USB at target machine, and follow the installation prompts. 
3. Select the misleading "GUI" install, which is the normal, ***headless*** install.

---

## Overview

Proxmox is an open-source server-management platform for enterprise virtualization;
managing VMs, containers, LXC, HA clusters, and integrated disaster recovery. 

Built upon __Debian__, it installs __headless__ by default, 
providing web UI and CLI interfaces:

MiniPC:

- **WebUI** : https://192.168.28.181:8006
- **SSH**: root@192.168.28.181


>Compute, network, and storage in a single solution. 

- <def title="Kernel-based Virtual Machine">__KVM__</def> __hypervisor__ : Manage VMs; run almost any OS.
- <def title="Linux Containers">__LXC__</def> : A kind of lightweight VM; a container that behaves more like a full Linux OS with its own `systemd` (init system) and user space. 
- SDS : [Software-defined Storage](https://en.wikipedia.org/wiki/Software-defined_storage "Wikipedia")
    - [Ceph](https://en.wikipedia.org/wiki/Ceph_(software)) : Run [__Ceph RBD__](https://docs.ceph.com/en/reef/rbd/ "docs.ceph.com/rbd") and [__Ceph FS__](https://docs.ceph.com/en/reef/cephfs/ "docs.ceph.com/reef") (Reef) directly on nodes of VE cluster.
- SDN : Software-defined Networking
- Web UI

### Image Formats

- `.vmdk` : VMware (ESXi) proprietary
- `.qcow2`
- `.vdi`

---

## [Configuration](https://www.youtube.com/watch?v=GoZaMgEgrHw)

- Allow _updates sans subscription_
    - __Enable__ non-production updates at `/etc/apt/sources.list`
    - __Comment out__ the enterprise list at `/etc/apt/sources.list.d/pve-enterprise.list`
- Storage 
    - ZFS 
- IOMMU
    - Enables host device passthrough; must be supported by cpu and mainboard and enabled in bios.

---

## Proxmox Storage 

The setup matters quite a bit for VM performance and flexibility &hellip;

**What Proxmox expects by default:**

__The installer__ typically creates an LVM volume group (`pve`) with:

- `pve-root` — ext4 for the OS (~30-100GB)
- `pve-swap` — swap
- `pve-data` — **LVM-thin pool** for VM disks

The key is that `pve-data` _should_ be an **LVM-thin** pool, 
_not a regular logical volume_. 
LVM-thin gives you __thin provisioning__, 
__snapshots__, and __efficient cloning__; 
all critical for VM operations.

If you manually create _regular_ LVM logical volumes, you'll lose those features. 
Proxmox will still work, but you'll be stuck with _raw disk images_ and _no snapshot capability_.

**Quick check**:

`lvs -o lv_name,vg_name,lv_attr,lv_size,pool_lv`

```bash
root@pve [06:07:30] [1] [#0] ~
# lvs -o lv_name,vg_name,lv_attr,lv_size,pool_lv
  LV                VG  Attr       LSize    Pool
  base-9000-disk-0  pve Vri-a-tz-k    3.00g data
  data              pve twi-aotz-- <348.82g         # Thin LVM
  root              pve -wi-ao----   96.00g         # Plain LVM
  swap              pve -wi-ao----    8.00g
  vm-9000-cloudinit pve Vwi-a-tz--    4.00m data
```
- The `t` attribute indicates _thin pool_; `V` indicates _thin volume_.   
  Plain LVM reports `-wi-a-----` attributes.

**Recommendations for a single 512GB NVMe:**

| Option | Pros |
|--------|------|
| **LVM-thin** (default) | Simple, snapshots, thin provisioning |
| **ZFS** | Compression, checksums, snapshots, better for your RAM (64GB is plenty for ARC) |

Given your 64GB RAM, **ZFS** is actually a strong option — it'll use ~8-16GB for ARC cache which dramatically improves I/O. You could reinstall selecting ZFS, or:

**What's in that 100GB you left unallocated?** Was that intentional for something specific, or were you unsure about the partitioning?


### Proxmox VE Ceph Reef cluster 

>Reef clusters are an evolution in Ceph's long-term release series, bringing improvements in scalability, performance, security, and Kubernetes integration. These advancements make [CephFS](https://docs.ceph.com/en/reef/cephfs/ "docs.ceph.com/reef") more capable of handling large-scale, distributed storage requirements across various industries, while still leveraging Ceph's robust object storage foundation, <def title="Reliable Autonomic Distributed Object Store">__RADOS__</def>. 

#### See Ceph ([HTML](Ceph.md "Ceph"))   

---

## Proxmox VMs

### Create VM (button)

1. OS tab — select ISO from `local`
    - But don't do this GUI method. Using a `*.iso` would an interactive install.
    Rather, use __`qm`__-automated __`cloud-init`__ script method on a __`*.qcow2`__ artifact:
        - https://cloud.debian.org/images/cloud/bookworm/latest/ , e.g.,
        - https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2
2. Disks tab — select `local-lvm` for the VM's virtual hard drive

### Create VM by CLI [`qm`](https://pve.proxmox.com/pve-docs/qm.1.html)

Proxmox CLI for managing QEMU/KVM VMs

| Command | What it does |
|---------|--------------|
| `qm create` | Create a VM |
| `qm set` | Modify VM config |
| `qm start/stop` | Power control |
| `qm importdisk` | Import a disk image |
| `qm template` | Convert VM to template |
| `qm clone` | Clone a VM or template |
| `qm list` | List all VMs |

There's also `pct` for LXC containers, and `pvesm` for storage (which you used earlier).

### Create VM Template 

```bash
bash debian12-template.sh
```

Debian 12 (bookworm) configured for `cloud-init` method (__`*.qcow2`__)

@ [__`debian12-template.sh`__](debian12-template.sh)

---

## K0s on Proxmox

Build Network and VMs for Kubernetes cluster 

### @ `./pve/k0s-lab`

See  README ([MD](pve/k0s-lab/README.md)|[HTML](pve/k0s-lab/README.html)) 

### Infra Architecture and Resources Plan

Here's our preliminiary design goal for this private network: 

* One 3-node K0s cluster (1 control, 2 worker) on Debian 12.
* One RHEL 9 IdM domain controller having cross-forest trust *under* AD (WinSrv 2019) domain controller 
  that is on another subnet (NAT network on 10.0.11.0/24). 
  AD is the authoritative IdP. 

Guest VMs on this pve should be on segregated network (10.0.33.0/24, perhaps) having access to, but protected from, upstream gateway router (192.168.28.1) that connects this network to the internet.

### Storage

The 100GB is default install. Is that too much? Regarding ZFS, taking some 8-16 GB of memory, not sure if we can afford that.

### CPU/RAM

Ryzen 7 has 16 threads. Each is a vCPU under a type-1 hypervisor (pve). 
So, regarding resources (cpu, ram), perhaps  :

* IdM : 2 vCPU / 4 GB 
* K0s control: 2 vCPU / 4 GB
* K0s worker: 4 vCPU / 16 GB

Guest VMs total: 12 CPU / 40 GB

That leaves 4 vCPU / 24 GB for the hypervisor (pve) *and* ZFS

So, if ZFS takes 16 GB, that leaves only 6 GB for pve.

### Assessment

Good plan overall. A few corrections and suggestions:

### CPU Misconception

vCPUs aren't "reserved" — they're scheduled. Proxmox (KVM) time-slices physical cores across VMs. You can safely overcommit for bursty workloads. Your 12 vCPU allocation across 16 threads is conservative and fine.

### RAM Reality

| Component | RAM |
|-----------|-----|
| Proxmox host | ~1-2 GB |
| IdM | 4 GB |
| K0s controller | 4 GB |
| K0s workers (2×16) | 32 GB |
| **Total** | ~42 GB |

Leaves ~22 GB free. You're not using ZFS (you have LVM-thin), so that concern doesn't apply unless you reinstall.

### Assessment by Component

**Storage (100GB root):** Oversized but harmless. Default installer is cautious. Not worth reinstalling.

**IdM (2 vCPU / 4 GB):** Tight but workable for lab. FreeIPA runs LDAP + Kerberos + DNS + CA. If sluggish, bump to 6GB.

**K0s controller (2 vCPU / 4 GB):** Fine for a 3-node cluster.

**K0s workers (4 vCPU / 16 GB each):** Generous — good if you're running real workloads. Could start at 8GB and scale up.

### Network Topology

For the segregated 10.0.33.0/24:

```
                    ┌─────────────────┐
                    │  192.168.28.1   │
                    │  (gateway/NAT)  │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │ pve host (vmbr0)            │
              │ 192.168.28.x                │
              └──────────────┬──────────────┘
                             │
         ┌───────────────────┴───────────────────┐
         │ vmbr1 (internal only, 10.0.33.0/24)   │
         │ no gateway, or pve as router          │
         └───────────────────┬───────────────────┘
                             │
        ┌────────────┬───────┴────────┬────────────┐
        │            │                │            │
    k0s-ctrl     k0s-w1          k0s-w2         IdM
   10.0.33.11   10.0.33.12      10.0.33.13    10.0.33.10
```

You'll need:

1. Create `vmbr1` (no physical interface, internal only)
2. Either run a router VM, or enable IP forwarding on pve host with iptables NAT

### Revised Resource Allocation

| VM | vCPU | RAM | Disk | Network |
|----|------|-----|------|---------|
| IdM | 2 | 4-6 GB | 40 GB | vmbr1 (+ vmbr0 for AD trust?) |
| k0s-ctrl | 2 | 4 GB | 32 GB | vmbr1 |
| k0s-w1 | 4 | 12 GB | 32 GB | vmbr1 |
| k0s-w2 | 4 | 12 GB | 32 GB | vmbr1 |
| **Total** | 12 | 32-34 GB | 136 GB | |

This leaves ~30GB RAM headroom for growth or burst.

---

## **W**ake **o**n **L**an (WoL) 

### How to Wake a __headless__ Proxmox node:

- **Configure** for WoL:
    - BIOS/UEFI: 
        - Disable: "`ERP Ready`"
        - Enable: "`Resume By PCI-E Device`"
    - Install `ethtool` (installed by default at pve v8.4.1): 
        ```bash
        apt install ethtool -y
        ```
    - Enable WoL on the public-facing interface (__`$ifc`__): 
        ```bash
        ethtool -s $ifc wol g # Wake on Magic Packet
        ethtool -s $ifc wol u # Wake on any traffic
        ```
    - Make it persistent by appending to the interfaces file &hellip; 
        ```bash
        tee -a /etc/network/interfaces <<-EOH
        post-up /sbin/ethtool -s $ifc wol g
        EOH
        ```
- **Wake Proxmox** (pve):
    - Send Magic Packet:   
        -   Use a WoL app on remote machine to send magic packet to Proxmox's MAC address.
        - SSH config
            ```ini
            Host proxmox pve
                HostName 192.168.1.181
                User root
                # Runs WoL cmd locally before SSH session
                ProxyCommand sh -c "wakeonlan <MAC_ADDR> && sleep 30; nc %h %p"
            ```
- **Wake guest VM** on pve:  
    ```bash
    qm sendkey $vm_id # Wake via SSH ProxyCommand method
    ```
- Automation: Tools like Home Assistant can be configured to detect network activity and automatically send the wake-on-lan packet to boot the server. 

Note: Ensure the NIC supports WOL, as indicated by `Wake-on: g` in the `ethtool` `<interface>` output. 

---

## [Proxmox v. ESXi v. OpenStack](https://chatgpt.com/share/f5522c3c-a597-42ac-adee-4d445b0836f6 "ChatGPT.com")

>VMware is now owned by Broadcom, which has __discontinued the Free ESXi Hypervisor__ : [End Of General Availability of the free vSphere Hypervisor](https://knowledge.broadcom.com/external/article?legacyId=2107518 "knowledge.broadcom.com")"

### &nbsp;
<!-- 
… ⋮ ︙ • ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
☢ ☣ ☠ ¦ ¶ § † ‡ ß µ Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 🡸 🡺 ➔
ℹ️ ⚠️ ✅ ⌛ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🥇 ✨️ 🔚

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

