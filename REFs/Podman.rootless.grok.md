# Podman Rootless for AD users on RHEL

# Q: 

Scalable solution for provisioning Podman rootless environments for unprivileged AD users on RHEL?

# A:

Provisioning scalable, rootless Podman environments for unprivileged Active Directory (AD) users on Red Hat Enterprise Linux (RHEL) requires careful configuration to ensure each user has an isolated, secure, and functional container environment. Below is a detailed solution to achieve this, leveraging Podman’s rootless capabilities, RHEL’s integration with AD, and best practices for scalability. The solution assumes RHEL 8 or later, as rootless Podman support is more mature in these versions.

---

### Solution: Scalable Rootless Podman Environments for AD Users on RHEL

#### 1. **Prerequisites**
- **RHEL System**: Ensure you’re running RHEL 8 or 9 with Podman installed (`sudo dnf install podman`).
- **AD Integration**: Configure the RHEL system to integrate with Active Directory using `realmd` or `sssd` for user authentication and management.
- **Rootless Podman Requirements**:
  - Enable user namespaces in the kernel: `echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/userns.conf` and apply with `sudo sysctl -p /etc/sysctl.d/userns.conf`.[](https://medium.com/devops-dudes/how-to-setup-root-less-podman-containers-efd109fa4e0d)
  - Install `slirp4netns` or `passt` for user-mode networking (`sudo dnf install slirp4netns` or `sudo dnf install passt`).[](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md)
  - Ensure `cgroup v2` is enabled for resource management: Add `systemd.unified_cgroup_hierarchy=1` to `/etc/default/grub`, then rebuild GRUB config and reboot.[](https://medium.com/devops-dudes/how-to-setup-root-less-podman-containers-efd109fa4e0d)
- **Storage**: Plan for user-specific container storage in home directories (`$HOME/.local/share/containers/storage`) or a centralized location for scalability.[](https://developers.redhat.com/blog/2020/09/25/rootless-containers-with-podman-the-basics)

#### 2. **AD Integration for User Management**
To allow AD users to log in and use rootless Podman, configure RHEL to authenticate against AD:
- Install required packages: `sudo dnf install realmd sssd oddjob oddjob-mkhomedir samba-common-tools`.
- Join the AD domain using `realm join --user=<AD-admin> <domain.example.com>`.
- Enable automatic home directory creation: `sudo authselect select sssd with-mkhomedir --force`.
- Verify AD users can log in: `id <ad-user@domain.example.com>`.

Ensure each AD user has a home directory created upon login, as Podman stores container data in `$HOME/.local/share/containers/storage` by default.[](https://developers.redhat.com/blog/2020/09/25/rootless-containers-with-podman-the-basics)

#### 3. **Configure SubUID/SubGID for Rootless Podman**
Rootless Podman relies on user namespaces, requiring each user to have a range of subordinate UIDs and GIDs defined in `/etc/subuid` and `/etc/subgid`. For AD users, this is challenging because they are not local users. Use the following approach:

- **Centrally Manage SubUID/SubGID**:
  - For AD users, `sssd` can map AD user IDs to a range of sub-UIDs and sub-GIDs. Edit `/etc/sssd/sssd.conf` to include:
    ```ini
    [sssd]
    domains = domain.example.com

    [domain/domain.example.com]
    id_provider = ad
    override_space = local
    subuid_range = 100000-165535
    subgid_range = 100000-165535
    ```
    Restart `sssd`: `sudo systemctl restart sssd`.
  - This assigns a unique range of sub-UIDs and sub-GIDs to each AD user, ensuring no overlap. Verify with `podman unshare cat /proc/self/uid_map` after logging in as an AD user.[](https://access.redhat.com/solutions/6216591)[](https://blog.christophersmart.com/2021/01/26/user-ids-and-rootless-containers-with-podman/)
- **Automate SubUID/SubGID Assignment**:
  - Use a script to dynamically assign ranges for new AD users. For example:
    ```bash
    #!/bin/bash
    USER=$1
    START_UID=$((100000 + $(id -u $USER) * 65536))
    END_UID=$((START_UID + 65535))
    echo "$USER:$START_UID:65536" | sudo tee -a /etc/subuid
    echo "$USER:$START_UID:65536" | sudo tee -a /etc/subgid
    ```
    Run this script for each AD user or integrate it with a user provisioning system. Ensure ranges do not overlap with existing users.

#### 4. **Storage Configuration for Scalability**
By default, Podman stores container images and data in `$HOME/.local/share/containers/storage`, which may not scale well for many users or large images. Consider these options:

- **Centralized Storage**:
  - Create a shared storage location (e.g., `/var/lib/containers/user/<username>`), mounted with appropriate permissions.
  - Configure Podman to use this location by editing `$HOME/.config/containers/storage.conf` for each user:
    ```toml
    [storage]
    driver = "overlay"
    rootless_storage_path = "/var/lib/containers/user/<username>/storage"
    ```
  - Ensure the storage directory is owned by the user: `sudo chown <ad-user>: /var/lib/containers/user/<ad-user>`.[](https://kcore.org/2023/12/13/adventures-with-rootless-containers/)
- **NFS Considerations**:
  - If home directories are on NFS, ensure Podman supports extended attributes (xattrs) for UID/GID mapping. Use `fuse-overlayfs` if native overlayfs is unsupported.[](https://www.redhat.com/ko/blog/podman-rootless-overlay)
  - Alternatively, configure a dedicated storage volume for container data to avoid NFS limitations.

#### 5. **Networking for Rootless Containers**
Rootless Podman uses `slirp4netns` or `passt` for networking, as unprivileged users cannot configure network namespaces.[](https://documentation.suse.com/smart/container/html/rootless-podman/index.html)

- **Install Networking Tools**:
  - For RHEL, install `passt` (preferred since Podman 5.0) or `slirp4netns`: `sudo dnf install passt`.
- **Port Binding**:
  - Unprivileged users cannot bind to ports below 1024. To allow this (e.g., for HTTP on port 80), set: `sudo sysctl net.ipv4.ip_unprivileged_port_start=80`.[](https://kcore.org/2023/12/13/adventures-with-rootless-containers/)
  - Map container ports to host ports above 1024: `podman run -p 8080:80 <image>`.
- **Inter-Container Communication**:
  - Place containers in the same pod to share a network namespace: `podman pod create --name user-pod; podman run --pod user-pod <image>`.[](https://# "___")





---

<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->
