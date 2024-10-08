# [Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/overview "Proxmox.com")

## Overview

__Proxmox Virtual Environment__ (VE) is an open-source server-management platform for enterprise virtualization; VMs, containers, HA clusters and integrated disaster recovery.

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

## [Proxmox v. ESXi v. OpenStack](https://chatgpt.com/share/f5522c3c-a597-42ac-adee-4d445b0836f6 "ChatGPT.com")

>VMware is now owned by Broadcom, which has __discontinued the Free ESXi Hypervisor__ : [End Of General Availability of the free vSphere Hypervisor](https://knowledge.broadcom.com/external/article?legacyId=2107518 "knowledge.broadcom.com")"

## Proxmox VE Ceph Reef cluster 

>Reef clusters are an evolution in Ceph's long-term release series, bringing improvements in scalability, performance, security, and Kubernetes integration. These advancements make [CephFS](https://docs.ceph.com/en/reef/cephfs/ "docs.ceph.com/reef") more capable of handling large-scale, distributed storage requirements across various industries, while still leveraging Ceph's robust object storage foundation, <def title="Reliable Autonomic Distributed Object Store">__RADOS__</def>. 

### [Ceph Benchmark](https://proxmox.com/en/downloads/proxmox-virtual-environment/documentation/proxmox-ve-ceph-benchmark-2023-12)

Fast SSDs and network speeds in a . Current fast SSD disks provide great performance, and fast network cards are becoming more affordable. Hence, this is a good point to reevaluate how quickly different network setups for Ceph can be saturated depending on how many OSDs are present in each node.
Summary

In this paper we will present the following three key findings regarding hyper-converged Ceph setups with fast disks and high network bandwidth:

- Our benchmarks show that a 10 Gbit/s network can be easily overwhelmed. Even when only using one very fast disk the network becomes a bottleneck quickly.
- A network with a bandwidth of 25 Gbit/s can also become a bottleneck. Nevertheless, some improvements can be gained through configuration changes. Routing via FRR is preferred for a full-mesh cluster over Rapid Spanning Tree Protocol (RSTP). If no fallback is needed, a simple routed setup may also be a (less resilient) option.
- When using a 100 Gbit/s network the bottleneck in the cluster seems to finally shift away from the actual hardware and toward the Ceph client. Here we observed __write speeds of up to 6000 MiB/s and read speeds of up to 7000 MiB/s for a single client__. However, when using multiple clients in parallel, writing at up to 9800 MiB/s and reading at 19 500 MiB/s was possible.


## [TUTORIAL] [Headless building Proxmox server solution](https://forum.proxmox.com/threads/headless-building-proxmox-server-solution.122641/)
   
    Feb 13, 2023 

    Install Proxmox on a headless server without drive swapping or pre-installing Debian, using ZFS (if required), assuming the server will boot from USB and has some form of serial (RS232) access - I used usb-serial adapter. This worked for me -- YMMV.

    Overview

        - use (eg) laptop to install basic Proxmox on a usb stick to make a “prox-live” system
        - modify “prox-live” to work in the headless server
        - boot headless server from “prox-live” usb stick
        - create VM attached to physical disk(s), proxmox installer as boot iso
        - install proxmox in VM
        - modify proxmox vm to work in native host
        - boot headless from it's own disks.
        - Drink coffee while installing updates

    UEFI
    If your headless server uses UEFI and you don't have serial console access to the BIOS, you may have problems here. Make sure the laptop used in the first step boots in UEFI mode to get a UEFI compatible “prox-live” image. This method does not add a UEFI boot entry but my headless server still boots ok.
    If you put in the extra effort to make a UEFI “prox-live” usb drive, it appears to work for both UEFI and legacy BIOS hosts.

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

