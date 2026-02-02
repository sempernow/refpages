# ISO vs. QCOW2

**Static vs. Dynamic File Formats**

## ISO (**I**nternational **O**rganization for **S**tandardization)

ISO is a **static**, read-only disc image (like a CD/DVD) used as bootable installation media. Used to install an OS into a virtual disk (like a QCOW2 file).

- **Purpose**: A universal format for disc images (CD, DVD, Blu-ray) used for installation or live systems.
- **Key Features**:
    - **Static**: A fixed snapshot of disc content, generally read-only.
    - **Bootable**: Contains boot sectors for installing operating systems or running live environments.
- **Use Case**: Providing **installation media** for `virt-install`, `virt-manager`, or physical hardware.


## QCOW2 (**Q**EMU **C**opy-**O**n-**W**rite v**2**)

QCOW2 is a **dynamic**, feature-rich virtual disk format for KVM/QEMU, 
offering snapshots, thin provisioning, and compression. The QCOW file is used as the actual storage for a running virtual machine.

- **Purpose**: A virtual hard disk storage format for virtual machines (VMs).
- **Key Features**:
    - **Copy-On-Write** (COW): Efficiently stores changes in separate files, using backing images.
    - **Snapshots**: Allows taking snapshots of VM states for easy rollback.
    - **Thin Provisioning**: Grows dynamically as needed, saving space.
    - **Compression & Encryption**: Supports built-in compression and encryption.
- **Use Case**: The primary storage format for both OS and data of a _running_ __KVM/QEMU VM__.

---

## Copy-on-Write (CoW) 

An optimization technique where resources (like memory or files) are shared instead of immediately copied when a duplicate is requested. 

The system delays copying until a process actually modifies the data, creating a private copy only when necessary. This boosts efficiency, reduces memory usage, and speeds up operations like system calls (e.g., fork()) and file system snapshots. 

### Key Aspects of CoW:

- **How it Works**: **When a resource is duplicated, both the original and the new copy point to the same physical memory**. When a write operation occurs on either, the system detects this, copies the data to a new location, and updates the references.
- **Performance Benefits**: Because copying is deferred, operations that would otherwise be slow (like duplicating large data structures) become near-instantaneous, improving overall system responsiveness.
- **Applications**:
    - **Operating Systems**: Used in virtual memory management, particularly when creating new processes (fork), allowing the child process to share memory pages with the parent until modifying them.
    - **File Systems**: Used in systems like **Btrfs** and **ZFS** to allow for fast snapshotting and to prevent data corruption.
    - **Programming Languages & Data Science**: Implemented in libraries like **pandas** (Python) and **Swift** to optimize data manipulation by preventing unnecessary copying of dataframes or objects.
- **Limitations**: While efficient for read-heavy workloads, CoW _can introduce latency during write operations_, as the first modification requires time to create the copy. 

### Benefits of CoW:

- **Memory Efficiency**: Reduces memory footprint by sharing unmodified data.
- **Reduced Overhead**: Speeds up processes by avoiding unnecessary data duplication.
- **Instant Snapshots**: Enables near-instant creation of data, file, or virtual machine clones. 

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
