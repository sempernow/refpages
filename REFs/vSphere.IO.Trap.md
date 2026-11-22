# Disk I/O @ vSphere Guest VMs : __Write Stall__ AKA __I/O Trap__ ? Yes!

**Yes, absolutely. This is a classic and well-known issue on vSphere as well, often referred to as the "vSphere etcd latency problem."** Using default settings for a VM that will host etcd is very likely to lead to the same kind of `fsync` delays and cluster instability.

The root cause is the same: the default configuration for virtual disks in most hypervisors is optimized for capacity and general-purpose workloads, not for the extreme low-latency synchronous writes that etcd requires.

### Default vSphere Settings That Cause Problems

1.  **Default Virtual Disk Type:** The default is often **"Thin Provision"** (the vSphere equivalent of Hyper-V's dynamic disk). This introduces overhead for space allocation during writes, which can cause significant latency for `fsync` operations.

2.  **Default Caching Policy:** The default is often **"Caching from the host"** which is not aggressive enough. The critical setting for etcd is the **Disk Write Cache** policy *inside the guest OS*, which is often disabled by default for VMs due to fear of data loss on host failure.

3.  **Paravirtualized Controller (PVSCSI):** While the VMware Paravirtual SCSI (PVSCSI) controller is high-performance, its default behavior with the `vmw_pvscsi` driver in Linux guests can still introduce latency if not tuned correctly alongside the disk type.

### How to Configure a vSphere VM for etcd (Best Practices)

To avoid this exact problem on vSphere, you must change the defaults. Here is the standard checklist for a production-ready etcd node on vSphere:

| Setting | Default (Problematic) | Recommended for etcd |
| :--- | :--- | :--- |
| **Disk Provisioning** | Thin Provision | **Thick Provision Eager Zeroed** |
| **Controller Type** | LSI Logic SAS | **Paravirtual (PVSCSI)** |
| **Guest OS Cache** | Usually `none` or `writethrough` | **`writeback`** |
| **VMware Tools** | Installed | **Installed & Updated** (for optimal driver performance) |

---

### Step-by-Step vSphere Configuration

#### 1. Disk Type: Use "Thick Provision Eager Zeroed"
This is the single most important change. It pre-allocates all space and zeros it out on creation, eliminating the allocation overhead that causes `fsync` delays in thin-provisioned disks.
*   **Power off the VM.**
*   In the vSphere Client, edit the VM's settings.
*   For the virtual disk, change the provisioning from "Thin Provision" to **"Thick Provision Eager Zeroed"**.
*   This is the vSphere equivalent of using a Fixed disk in Hyper-V.

#### 2. Disk Controller: Use "Paravirtual SCSI (PVSCSI)"
This provides the best performance and lowest CPU overhead for virtualized storage.
*   In the VM's settings, change the SCSI controller type to **VMware Paravirtual**.

#### 3. Enable Write Caching *inside the Guest OS*
Just like with Hyper-V, you need to ensure the guest OS is configured for write-back caching. Since you're using RHEL, the process is similar.

    ```bash
    # Check current cache policy for your etcd disk (e.g., /dev/sdb)
    sudo lsblk # to identify the disk
    sudo hdparm -W /dev/sdb

    # If supported, enable it (this often works for PVSCSI disks)
    sudo hdparm -W1 /dev/sdb

    # Make it persistent across reboots with a udev rule
    echo 'ACTION=="add|change", KERNEL=="sdb", ATTR{queue/write_cache}="write_back"' | sudo tee /etc/udev/rules.d/99-enable-write-cache.rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    ```
    *Note: With PVSCSI and modern kernels, the cache policy is often better handled by the `vmw_pvscsi` driver, but explicitly setting it is good practice.*

#### 4. (Optional but Recommended) VM Advanced Settings
You can add these advanced parameters to the VM's configuration file (.vmx) to further optimize for latency:
*   `disk.EnableUUID = "TRUE"` - Ensures consistent disk device identification.
*   `scsiX:Y.virtualSSD = 1` - (Where X is controller number, Y is disk number) hints to the ESXi host that the disk is SSD-backed, which can influence scheduling.
*   `scsiX:Y.throughputCap = "off"` - Removes any artificial I/O throughput cap.

### Summary: vSphere vs. Hyper-V

| Hypervisor | Problem | Solution |
| :--- | :--- | :--- |
| **Hyper-V** | Dynamic Disk + no guest write cache | Use **Fixed Disk** + enable write caching on host |
| **vSphere** | **Thin Provisioned Disk** + default guest cache | Use **Thick Provision Eager Zeroed** disk + **PVSCSI controller** + enable `writeback` in guest |

**Conclusion: Yes, using default vSphere settings will very likely cause the same etcd `fsync` latency issues.** The virtualized storage stack must be properly configured for low-latency, synchronous I/O in any hypervisor environment. The principles are the same: use pre-allocated (thick/fixed) disks and ensure write caching is appropriately enabled.




---

<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# … ⋮ ︙ • “” ‘’ – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻  ⚐ ⚑
# ☢  ☣  ☠  ¦ ¶ § † ‡ ß µ ø Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦  ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 𝐋𝐀𝐁
# ⚠️ ✅ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🧳 🥇 ✨️ 🔚

# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>


-->
