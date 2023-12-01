# SELinux

## Troubleshoot

```bash
sudo ausearch -m avc -ts recent | audit2why

```

## Solutions

```bash
# Set context
sudo chcon -t container_file_t $file
# z (container)
docker run --mount type=bind,source=$host_path,target=$ctnr_path,z ...
# 
podman ... --security-opt label=type:container_file_t
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
