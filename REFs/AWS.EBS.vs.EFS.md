# AWS : EBS (SAN) vs. EFS (NAS) Performance

- EBS is SAN scoped to AZ
- EBS is NAS scoped to Region

Amazon EBS (Elastic Block Store) provides high, predictable IOPS with steady, provisioned performance, ideal for single-instance, mission-critical databases. Amazon EFS (Elastic File System) delivers higher aggregate throughput for concurrent workloads, scaling its performance linearly as your capacity grows, making it perfect for shared file storage. [1, 2]  
IOPS (Input/Output Operations Per Second) 

| Storage Type [1, 2, 3, 4, 5, 6] | Max IOPS | Performance Model | Best Use Case  |
| --- | --- | --- | --- |
| EBS | Up to 256,000 IOPS (per volume) | Provisioned or dynamically scaled based on volume type (e.g., , ). Independent of storage capacity. | High-transaction databases, enterprise applications, and highly parallelized block-level I/O.  |
| EFS | Up to 500,000+ IOPS | Scales automatically with total storage volume (1 IOPS per 1 GB of storage in Standard mode). Max IOPS requires highly parallel operations across multiple compute instances. | Concurrent file access, web serving, big data analytics, and CI/CD pipelines.  |

Throughput 

| Storage Type [2, 4, 5, 6, 7] | Max Throughput | Performance Model | Best Use Case  |
| --- | --- | --- | --- |
| EBS | Up to 4,000 MB/s (4 GB/s) (per volume) | Provisioned independently of volume size (e.g.,  Block Express). | Big data, data warehousing, and log processing requiring large, sequential data transfers.  |
| EFS | Up to 10+ GB/s (and up to 3 GB/s per single client) | Scales with the size of the file system footprint, with Max I/O mode for highly parallel, distributed compute nodes. | Media processing, machine learning, and genomic sequencing requiring massive shared datasets.  |

Key Trade-Offs 

- Instance Attachment: EBS acts as a block device and can only be attached to a single Amazon EC2 instance at a time. EFS acts as a file system and can be mounted by thousands of EC2 instances simultaneously. 
- Latency: Because EBS attaches directly as a block device, it offers sub-millisecond to low-single-digit millisecond latency. EFS features a slightly higher latency overhead due to its distributed, networked file architecture. 
- Configuration: EBS gives you tight control over exactly how much performance you pay for, allowing you to fine-tune IOPS and throughput. EFS performance is generally paired with the amount of data stored (in Provisioned Throughput mode) or your aggregate storage size. [1, 2]  

For more detailed specs, you can refer to the  Amazon EBS Volume Types 
 and Amazon EFS Performance documentation. 
If you are trying to choose between the two, tell me: 

1. What application or workload are you running? 
2. How many instances need to access the data concurrently? 

I can help you narrow down the exact service or configuration you need. 

AI can make mistakes, so double-check responses

[1] https://zesty.co/blog/ebs-vs-efs-which-is-right/
[2] https://n2ws.com/blog/aws-ebs-snapshot/aws-fast-storage-efs-vs-ebs
[3] https://medium.com/@syedhassaniiui/efs-performance-metrics-and-iops-vs-throughput-615fdb1cdd38
[4] https://blogs.businesscompassllc.com/2026/05/ebs-vs-efs-performance-and-scalability.html
[5] https://aws.amazon.com/efs/when-to-choose-efs/
[6] https://www.youtube.com/watch?v=f3wp7ZGe2VU
[7] https://builder.aws.com/content/2nk3oQI9gXbgeO5Wft3sjEBkeGS/storage-options-for-eks-comparing-amazon-efs-ebs-s3-and-fsx-for-ontap
[8] https://dev.to/ooye_sanket/exploring-aws-ebs-and-efs-for-efficient-storage-2leg




---

<!-- 

… ⋮ ︙ - ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
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
