# SAN Tech Stack


The performant go-to tech stack for a SAN in a SCIF (Sensitive Compartmented Information Facility) environment is Fibre Channel (FC) infrastructure paired with Non-Volatile Memory Express over Fibre Channel (**NVMe/FC**) and hardware-based, FIPS 140-3 validated encryption.

Unlike commercial data centers that lean heavily toward Ethernet-based storage, 
high-security defense and intelligence environments favor Fibre Channel 
because it physically isolates storage traffic from the local area network (LAN), 
drastically reducing the attack surface.

## The Performant SCIF SAN Tech Stack

* Storage Protocol: NVMe over Fibre Channel (NVMe/FC). 
    It delivers microsecond-level latency and massive parallel processing 
    while maintaining the physical isolation of a dedicated fiber network.
* Fabric/Switches: 64Gb/s (Gen 7) Fibre Channel switches from enterprise vendors 
    like Brocade/Broadcom or Cisco MDS. 
    These support hardware-based zoning and strict port-level security.
* Storage Arrays: All-Flash Arrays (AFA) featuring end-to-end NVMe. 
    Go-to systems include **NetApp AFF** series, Dell PowerStore/PowerMax, 
    or Pure Storage FlashArray//XL.
* Host Connectivity: Emulex or QLogic 32Gb/64Gb Host Bus Adapters (HBAs) 
    installed directly in the air-gapped server nodes.

## Critical Security & Compliance Layer

To operate inside a SCIF, performance hardware must be wrapped in rigorous, federally mandated security controls:

* Data-at-Rest Encryption (DARE): Storage arrays must use FIPS 140-3 Level 2 or Level 3 certified Self-Encrypting Drives (SEDs).
* Key Management: Encryption keys cannot reside on the storage array. They must be managed externally via KMIP (Key Management Interoperability Protocol) using validated Hardware Security Modules (HSMs) like Thales CipherTrust.
* Physical & Logical Air-Gapping: The SAN fabric must be completely disconnected from any outside internet or lower-classification networks. Administrative management ports are tied to a dedicated, strictly audited out-of-band (OOB) management network.
* Firmware & Supply Chain TAA Compliance: All hardware must be compliant with the Trade Agreements Act (TAA), ensuring components originate from approved, trusted nations to mitigate supply chain tampering.

## Why Not iSCSI or RoCE (Ethernet) in a SCIF?

While iSCSI or NVMe-over-Fabrics using RoCE v2 (RDMA over Converged Ethernet) are highly performant and cheaper, they are rarely the "go-to" choice for core SCIF SANs due to security trade-offs:

| Metric | Fibre Channel (FC / NVMe-FC) | Ethernet (iSCSI / RoCE) |
|---|---|---|
| Network Isolation | Inherent. Completely separate physical network. | Shared physical switches via VLANs (higher risk of misconfiguration). |
| Attack Surface | Minimal. No IP addresses, routing, or internet protocols. | Vulnerable to standard IP exploits, spoofing, and OS-level network attacks. |
| Performance | Lossless. Zero packet drop guaranteed by hardware. | Requires complex data center bridging (DCB) config to avoid drops. |


---

## Q:

Is there a Rook/Ceph-based solution matching performance and security?

## A:

Yes, but you have to completely invert the architecture. 
Instead of running Rook/Ceph on top of a SAN (which causes performance-killing storage layering), 
you build an enterprise-grade SAN using Rook/Ceph as the underlying engine. [1, 2] 

By deploying a dedicated, bare-metal Rook/Ceph storage cluster and exposing it via native NVMe over Fabrics (NVMe-oF), you can replicate the exact performance profiles and strict security requirements mandated by a SCIF environment. [2, 3] 

A Rook/Ceph-based architecture engineered to match a traditional Fibre Channel SAN looks as follows:

## 1. The Performant Stack: NVMe-oF Gateways [4] 

In a standard configuration, clients talk to Ceph via the RADOS Block Device (RBD) kernel driver. 
For a high-performance SAN replacement, Rook utilizes the SPDK-based Ceph NVMe-oF Gateway. [1, 4, 5] 

* The Mechanism: The cluster exposes storage namespaces over the network using NVMe over TCP or RoCE v2 (RDMA).
* The Performance: External initiators (like VMware ESXi hosts or bare-metal database servers) connect to Ceph using standard NVMe-oF drivers. It bypasses heavy kernel overhead, delivering near-local NVMe IOPS and sub-millisecond latencies that rival traditional 32G/64G Fibre Channel SANs. [2, 4, 5, 6] 

## 2. Securing a Ceph SAN inside a SCIF

To achieve the absolute isolation and compliance of a Fibre Channel network using an Ethernet-based Rook/Ceph stack, the deployment must implement strict physical and logical controls:

* Physical Fabric Air-Gapping: Storage network traffic must run on a completely dedicated, physically isolated switching fabric. Even though it uses Ethernet hardware (e.g., 100GbE switches), it must never plug into the regular LAN or any cross-domain systems, maintaining the exact structural perimeter of a Fibre Channel fabric.
* FIPS 140-3 Cryptography: To pass SCIF accreditation, Ceph's cryptographic elements must be restricted to validated modules. Rook must be compiled and deployed using FIPS-compliant base container images (such as Red Hat Universal Base Image in FIPS mode) utilizing [FIPS 140-3 validated cryptographic canisters](https://csrc.nist.gov/CSRC/media/projects/cryptographic-module-validation-program/documents/security-policies/140sp5010.pdf).
* Data-at-Rest Encryption (DARE): Rook can automatically orchestrate Linux dm-crypt (LUKS) to encrypt the underlying physical NVMe OSDs at creation.
* External Enterprise Key Management: By default, Ceph monitors (MONs) can hold encryption keys, which is a compliance failure in a SCIF. Rook can be configured to offload key management to an external, network-isolated HashiCorp Vault KMS. This Vault instance can be backed by a hardware-based, FIPS 140-3 Level 3 Hardware Security Module (HSM) to secure the root keys.
* Data-in-Transit Encryption: Internal cluster replication traffic and client-to-cluster data communication must be secured using Ceph’s Messenger V2 protocol (msgr2) with encryption enabled (secure mode), which enforces secure on-wire cryptographic sign-off. [3, 7, 8, 9, 10, 11] 

## Commercial vs. Open-Source Implementation

For a SCIF environment, self-compiling community Rook/Ceph is highly difficult due to the rigorous paperwork required for federal risk management frameworks (like NIST SP 800-53).

Defense agencies generally deploy a commercially supported, hardened downstream distribution such as Red Hat OpenShift Data Foundation (ODF) or IBM Storage Ceph. 

These distributions come pre-hardened, fully supply-chain audited (TAA compliant), and feature documentation mapped directly to federal security profiles. [3] 

If you are evaluating this architecture for an upcoming authorization window, tell me:

* Are your target client hosts running VMware ESXi, or are they Linux bare-metal nodes?
* Do your network constraints allow for RoCE v2 (RDMA), or are you limited to standard TCP fabrics?
* Will you need to provide S3-compatible object storage alongside the block SAN functionality? [11, 12] 


[1] [https://www.youtube.com](https://www.youtube.com/watch?v=NKHACaSyO18&t=58)
[2] [https://rook.io](https://rook.io/docs/rook/latest-release/Storage-Configuration/Block-Storage-RBD/nvme-of/)
[3] [https://oneuptime.com](https://oneuptime.com/blog/post/2026-03-31-rook-ceph-storage-government-public-sector/view)
[4] [https://oneuptime.com](https://oneuptime.com/blog/post/2026-03-31-rook-ceph-nvmeof-vm-storage/view)
[5] [https://www.youtube.com](https://www.youtube.com/watch?v=EdH5BCwHrcI&t=14)
[6] [https://intelligentvisibility.com](https://intelligentvisibility.com/nvme-over-fabrics-ethernet-comparison)
[7] [https://www.chainguard.dev](https://www.chainguard.dev/supply-chain-security-101/fips-140-3-everything-you-need-to-know)
[8] [https://csrc.nist.gov](https://csrc.nist.gov/CSRC/media/projects/cryptographic-module-validation-program/documents/security-policies/140sp5010.pdf)
[9] [https://ceph.io](https://ceph.io/assets/pdfs/events/2024/ceph-days-nyc/DATA%20SECURITY%20AND%20STORAGE%20HARDENING%20IN%20ROOK%20AND%20CEPH%20%28CEPH%20DAYS%20NYC%202024%29.pdf)
[10] [https://www.netapp.com](https://www.netapp.com/responsibility/trust-center/compliance/fips-140/)
[11] [https://ceph.io](https://ceph.io/assets/pdfs/events/2024/ceph-days-nyc/DATA%20SECURITY%20AND%20STORAGE%20HARDENING%20IN%20ROOK%20AND%20CEPH%20%28CEPH%20DAYS%20NYC%202024%29.pdf)
[12] [https://www.youtube.com](https://www.youtube.com/watch?v=tTiTzF3Q7Kg)


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
