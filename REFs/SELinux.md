# SELinux

## Troubleshoot

Verify it's an SELinux issue:

1. Set to Permissive
2. Restart the problemed service or whatever
3. If the problem goes away, then it's an SELinux issue.

__Troubleshoot SELinux__:

```bash

getenforce  # Shows: Enforcing, Permissive, or Disabled
sestatus    # More detailed output

# Install/Verify SELinux troubleshooting tools are available
dnf install -y selinux-policy-targeted libselinux-utils policycoreutils setroubleshoot-server policycoreutils-python-utils

# Automatically Diagnose via sealert 
sudo sealert -a /var/log/audit/audit.log
# List all known SELinux alerts that the setroubleshoot daemon has logged and categorized.
sudo sealert -l "*"

# 1. Most recent AVC denials
sudo ausearch -m avc -ts recent 
# 2. All recent SELinux audit messages:
sudo journalctl -t setroubleshoot --since "1 hour ago"
# 3. Explain Denials with audit2why
sudo ausearch -m avc -ts recent |audit2why
# 4. Suggest Allow Rules with audit2allow : USE WITH CAUTION
sudo ausearch -m avc -ts recent |sudo audit2allow -a
# 5. Fix Wrong File Contexts
ls -Z $file                 # Show current SELinux context of a file (path)
sudo restorecon -v $file    # Restore expected context @ file
ls -Z $dir                  # Show current SELinux context of dir (path)
sudo restorecon -vR $dir    # Restore expected context @ dir (recursively)
# 6. Check File’s Expected Context
sudo matchpathcon $file
# 7. Set to permissive (temporarily)
sudo setenforce 0
# 8. Rebuild or Reload Policies
sudo semodule -l        # List installed modules
sudo semodule -B        # Rebuild and reload policy modules

# Clear audit log
sudo logrotate -f /etc/logrotate.d/audit
sudo truncate -s 0 /var/log/audit/audit.log

```

## Policies

RHEL's  default policy is `selinux-policy-targeted`


__Check policy__:

```bash
☩ sestatus 
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
```

This misleading report, "`Policy MLS status:      enabled`",  
wrongly implies the system has __Multi-Level Security__ (MLS) enabled.
    
- MLS is __extremely strict__ and __rarely used outside classified environments__ 
      (military, government, etc.).
- Many tools and daemons assume the targeted policy and may misbehave or log extra AVCs under MLS.
- Some policy modules may not behave the same under mls as they do under targeted.

MLS is not enforced, even though the policy has MLS support enabled.

This just allows contexts like `s0:c123,c456` to exist and be meaningful 
(common in containers and multi-tenant environments).
It does not mean you're in a DoD-style sensitivity hierarchy.

## FS (folder/file) Solutions

### `fcontext` : `cotnainer_file_t`

```bash
# Set context
sudo chcon -t container_file_t $file
# z (container)
docker run --mount type=bind,source=$host_path,target=$ctnr_path,z ...
# 
podman ... --security-opt label=type:container_file_t
```

### `fcontext` : `public_content_rw_t`

```bash
# Fix at NFS server export /srv/nfs/k8s
sudo semanage fcontext -a -t public_content_rw_t '/srv/nfs/k8s(/.*)?'
sudo restorecon -Rv /srv/nfs/k8s
```


## Container Bind Mount

Changing a file that is bind-mounted between a host and a container to a symbolic link can cause an SELinux denial. This is because SELinux enforces strict access controls based on security contexts, and symbolic links can introduce unexpected behavior that violates SELinux policies.

Here’s why this can happen:

1. **Security Context Mismatch**: 

   - SELinux assigns security contexts (labels) to files, which define their type, role, and domain. A bind-mounted file has a specific SELinux context based on its original location on the host. When you replace this file with a symbolic link, the link may have a different context or point to a file with a context that doesn't match the expectations of the SELinux policy for the container or the process accessing it.
   - For example, if the container expects a file with a context like `container_file_t` but the symbolic link resolves to a file with a different context (e.g., `default_t` or `user_home_t`), SELinux may deny access.

2. **Symbolic Link Resolution**:

   - When a symbolic link is followed, SELinux evaluates the security context of the target file, not just the link itself. If the target file’s context is not permitted by the SELinux policy for the process (e.g., the container’s runtime), a denial occurs.
   - Containers often run in confined SELinux domains (e.g., `container_t`), which restrict access to files outside specific labeled directories. If the symbolic link points to a file outside the allowed paths or with an incompatible context, SELinux will block access.

3. **Bind Mount Behavior**:

   - Bind mounts expose host files directly to the container, and SELinux enforces policies on these files based on their host context. If the bind-mounted file is replaced with a symbolic link, the link’s target might not align with the expected context or permissions, leading to a denial.
   - For instance, if the link points to a file in a location that the container’s SELinux domain cannot access (e.g., `/home/user` instead of `/var/lib/docker`), SELinux will deny the operation.

4. **SELinux Policy Restrictions**:

   - SELinux policies for containers (e.g., those defined by container runtimes like Docker or Podman) are often strict, allowing access only to specific file types or paths. Replacing a file with a symbolic link might violate these policies if the link’s target is not explicitly allowed.

### Example Scenario

- You bind-mount a file `/host/data.txt` into a container at `/container/data.txt`.
- The file `/host/data.txt` has the SELinux context `container_file_t`, which the container’s process (`container_t`) is allowed to access.
- You replace `/host/data.txt` with a symbolic link pointing to `/host/other_data.txt`, which has a context like `user_home_t`.
- The container tries to access `/container/data.txt`, which now resolves to `/host/other_data.txt`. Since `container_t` is not allowed to access `user_home_t`, SELinux issues a denial.

### How to Diagnose

- Check the SELinux denial logs using `audit2why` or `sealert`:
  ```bash
  sudo ausearch -m avc -ts recent | audit2why
  ```
  This will show the specific denial and the SELinux rule that caused it.
- Inspect the file contexts:
  ```bash
  ls -Z /host/data.txt
  ls -Z /host/other_data.txt
  ```
  Compare the contexts to ensure they match what the container’s SELinux policy expects.

### Possible Fixes

1. **Ensure Correct SELinux Context**:

   - Set the correct SELinux context on the target file to match what the container expects:
     ```bash
     sudo chcon -t container_file_t /host/other_data.txt
     ```
   - Alternatively, use a context specifically allowed by the container runtime, such as `svirt_sandbox_file_t`.

2. **Use SELinux Mount Options**:

   - When bind-mounting, specify the correct SELinux context using mount options. For example, with Docker:
     ```bash
     docker run --mount type=bind,source=/host/data.txt,target=/container/data.txt,z ...
     ```
     The `z` option sets a shared SELinux label (`container_file_t`) for the bind-mounted file.

3. **Avoid Symbolic Links**:

   - If possible, avoid replacing bind-mounted files with symbolic links. Instead, copy or move the actual file to the bind-mounted location to maintain consistent SELinux contexts.

4. **Update SELinux Policy**:

   - If the symbolic link is necessary and the target file’s context cannot be changed, create a custom SELinux policy module to allow the container’s domain (`container_t`) to access the target file’s context:
     ```bash
     audit2allow -a -M mypolicy
     semodule -i mypolicy.pp
     ```
     Be cautious, as this may reduce security.

5. **Use Container-Specific Paths**:

   - Ensure the symbolic link’s target is in a directory that the container’s SELinux policy allows, 
     such as `/var/lib/docker` or a directory labeled with `container_file_t`.


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
