# Ceph Distributed Storage Cluster | [Docs](https://docs.ceph.com/en/reef/rados/ "docs.ceph.com") | [ceph.com](https://ceph.com/en/discover/technology/)

A **Ceph Storage Cluster** provides performant read/write access to redundant (HA) 
**File System** (CephFS), **Object Storage** (RGW) and **Block Devices** (RDB), 
as well as unified **API**-based management ([LIBRADOS](https://docs.ceph.com/en/reef/rados/api/)) of all three.

![The RADOS-based Ceph stack](ceph-rados-stack.png)

>NetApp ONTAP generally provides higher performance for traditional 
enterprise, file, and mixed-workload environments, 
while Ceph (Reef) often delivers superior, more cost-effective performance 
for massive-scale object and block storage 
(e.g., in OpenStack or Kubernetes environments). 

## **Ceph**/**Reef**/**RADOS**

The Ceph Storage Cluster is the foundation for all Ceph deployments.   
**Based upon RADOS**, **Ceph Storage Clusters consist of several types of daemons**:

- Ceph OSD Daemon (OSD): stores data as objects on a storage node
- Ceph Monitor (MON): maintains a master copy of the cluster map.
- Ceph Manager: manager daemon

A Ceph Storage Cluster might contain thousands of storage nodes.   
A minimal system has at least one Ceph Monitor and two Ceph OSD Daemons for data replication.

## Ceph OSD (v18.x)

A **Ceph OSD** (**O**bject **S**torage **D**aemon) is the core software daemon 
in a _Ceph distributed storage cluster_ that stores data, handles replication, recovery, and rebalancing. 
Typically, one OSD runs on each physical storage device (HDD or SSD), 
managing data reads and writes for that disk. 
OSDs are the "heart" of Ceph, 
ensuring high availability by storing and managing data objects locally. 
At least three OSDs are typically required for effective redundancy and high availability. 

OSDs are crucial for Ceph's ability to provide **object**, **block**, 
and **file storage** in a *single unified system*, 
with the **CRUSH algorithm** determining the data's location within the cluster. 

[**BlueStore**](https://docs.ceph.com/en/reef/rados/configuration/bluestore-config-ref/) 
is the default and high-performance **storage backend** for Ceph OSDs. 
Introduced in Ceph Luminous (v12), it *replaces the older* **FileStore** backend 
by allowing Ceph to manage storage devices directly, 
rather than relying on an intermediary local file system like XFS or ext4. 

- **BlueStore** *File System* is not a conventional file system like ZFS, XFS, or ext4. 
    It *works directly with raw block devices* (raw disks *or* logical volumes); 
    **writes directly to the disk**, *bypassing the overhead of a standard OS filesystem* and avoiding the "double-write" penalty that older systems (like **FileStore**) suffered.
- **RockDB**: A lightweight key-value database used by BlueStore to manage **metadata**.
- **BlueFS**: A specialized, minimalist "file system" 
  built specifically to allow RocksDB to **run on raw storage devices**. 

## Ceph Reef Cluster

In a **Ceph Reef cluster** , the **Ceph OSD** remains the critical workhorse 
responsible for storing data, handling replication, and ensuring data integrity. 
While its fundamental purpose hasn't changed, 
the Reef release introduces specific enhancements and requirements for OSDs within a modern cluster: 

**Key Role**

- **Primary Data Handler**:  
    OSDs store RADOS *objects* on physical drives 
    and are *the only daemons that clients communicate with directly for data I/O*.
- **Self-Healing & Peering**:   
    In Reef, OSDs continue to "peer" with each other 
    to ensure **PG** (**P**lacement **G**roup) consistency 
    and automatically rebalance or recover data if a drive fails. 

**New & Enhanced Features**

- **Read Balancer**: A major addition in Reef is the Read Balancer, 
    which allows you to balance primary PGs per pool to optimize read performance across OSDs.
- **RocksDB Optimizations**: The underlying **BlueStore** backend in Reef uses RocksDB v7.9.2, 
offering improved performance and reduced iteration overhead for OSD operations.
- **RocksDB Compression**: LZ4 compression is now enabled by default for RocksDB in Reef, 
    which helps OSDs save space on metadata and improves speed on "fast devices" like NVMe.
- **OSD Management**: New `ceph` CLI commands like  
    "`ceph osd rm-pg-upmap-primary-all`"   
    provide more granular control over PG mapping. 

**Hardware & Setup Recommendations**

- **Memory Targets**: For OSDs running on high-performance NVMe drives, 
    it is often recommended to set `osd_memory_target` to **at least 8GB–16GB**
    to _handle the high IOPS Reef can provide_.
- **CPU Allocation**: Reef is optimized for multi-core systems; 
    for NVMe OSDs, providing up to **2–4 CPU threads per OSD** can prevent bottlenecks.
- **Orchestration**: Reef strongly favors cephadm for managing OSD lifecycles, 
    using "service specifications" to automatically transform available disks into OSDs.

**Architecture**: **One Daemon per Physical Disk**

The standard "Ceph Way" is a **1:1:1 ratio**:   
**One physical disk** = **one LVM Volume Group** = **one OSD Daemon**.

- **Concurrency**: A single OSD daemon has a finite number of worker threads. 
    If you put 10 SSDs into a single LVM volume and run one OSD on top, that OSD becomes a massive bottleneck.
- **The BlueStore Factor**: Since Ceph Reef uses BlueStore, it wants to manage the block device directly. 
    Putting an extra layer of - LVM abstraction between Ceph and the disk is fine for management (and required by ceph-volume), but you should not use LVM to "merge" disks.
- **CPU Scaling**: Ceph is CPU-hungry.   
    Running multiple OSDs allows the Linux scheduler to distribute the load across all available CPU cores more effectively.

**The Exception**: **High-Capacity NVMe**

The only time you deviate from the "one disk, one OSD" rule is with extremely high-performance NVMe drives (e.g., 8TB+ NVMe). Because a single NVMe drive is so fast, a single OSD daemon often cannot keep up with the drive's potential.
In this specific case, you would actually split one physical NVMe into 2 or 4 OSDs using LVM to maximize throughput. 
This is the opposite of merging disks; it's subdividing a fast one.

**Recommendation for Reef**

If you are using [**`cephadm`**](https://docs.ceph.com/en/reef/cephadm/) 
(the preferred orchestrator for Reef), 
you should ***simply provide the raw devices***. 
The `cephadm` CLI *automatically creates the LVM* tags and provision one OSD per device:

```bash
# This will find all available disks and create one OSD per disk
ceph orch apply osd --all-available-devices
```

---

## Ceph on Proxmox

### [Ceph Benchmark](https://proxmox.com/en/downloads/proxmox-virtual-environment/documentation/proxmox-ve-ceph-benchmark-2023-12) 

### Fast SSDs and network speeds in a Proxmox VE Ceph Reef cluster

Current fast SSD disks provide great performance, 
and fast network cards are becoming more affordable. 
Hence, this is a good point to reevaluate how quickly different network setups for Ceph 
can be saturated depending on how many OSDs are present in each node.

### TL;DR

The Ceph client becomes the bottleneck only if network bandwidth exceeds 100 Gbit/s.

### Summary

&hellip; the following three key findings 
regarding <dfn title="Hyperconverged Infrastructure">HCI</dfn> Ceph setups with fast disks and high network bandwidth:

- A **10 Gbit/s** network can be easily overwhelmed by Ceph. 
    Even when only using one very fast disk the network becomes a bottleneck quickly.
- A network with a bandwidth of **25 Gbit/s** can also become a bottleneck. 
    Nevertheless, some improvements can be gained through configuration changes. 
    Routing via FRR is preferred for a full-mesh cluster over Rapid Spanning Tree Protocol (RSTP). 
    If no fallback is needed, a simple routed setup may also be a (less resilient) option.
- A **100 Gbit/s** network is where the Ceph client (OSD) becomes the bottleneck (versus the hardware; observed **write speeds of up to 6000 MiB/s** and **read speeds of up to 7000 MiB/s** for a ***single client***. Using multiple **clients in parallel** achieved **writes of 9800 MiB/s** and **reads of 19500 MiB/s**.


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

