# Podman : Rootless Containers | [Chat 2](https://chatgpt.com/share/673a11b8-165c-8009-8412-2dec016a61b7 "ChatGPT.com")

## [Rootless Containers](https://chatgpt.com/share/6700711a-5b14-8009-82f9-decd11ce4f0c "ChatGPT.com")

>In rootless Podman, the container’s root user is actually a non-root user on the host, mapped via user namespaces.

### Namespace and UID

Mappings in Rootless Podman:

- Automatic Namespace Setup: When you run a rootless container with Podman, it automatically sets up the user namespace for that container. Podman uses entries in__ `/etc/subuid` and `/etc/subgid` __to map UIDs and GIDs from the container to the host.__ This means that the __root user inside the container__ (UID `0`) is __mapped to a non-root user on the host__ (typically starting at a high UID, like `100000`, __from host user’s `subuid`/`subgid` range__). 
    - `myuser:100000:65536` : the root user (UID 0) in the container is mapped to UID 100000 on the host, and this mapping extends for `65536` UIDs (so UID `1` inside the container maps to `100001` on the host, and so on).

__Create__ `subuid`/`subgid` range __per user__

```bash
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 auser
```
- This allocates `65536` subordinate UIDs and GIDs to `auser`, starting from `100000`.

### `Dockerfile` mods

```dockerfile
RUN useradd -m auser
USER auser
RUN chown -R auser /path/to/app
```

### Host : User Namespaces

In Podman rootless mode, a __container runs in a separate user namespace__, which isolates the user and group IDs inside the container from the ones on the host. Even though a process may run as __`UID 0` (`root`) inside the container__, it is actually __mapped to a non-root user ID on the host__.

### Customizing UID/GID Mappings

You can modify the default UID/GID mappings by editing `/etc/subuid` and `/etc/subgid`. You can also specify custom mappings when running a container using the `--uidmap` and `--gidmap` options in podman run.

```bash

podman run --uidmap 0:100000:1000 --gidmap 0:100000:1000 my-image
```

#### Issues

- Mounts: When mounting directories from the host into the container, you may run into permission issues if the UIDs/GIDs inside the container don’t map cleanly to the host.
- Ports: Containers in rootless mode can’t bind to privileged ports (ports < 1024) because the user on the host is not root.


## [Persist a Rootless Container](https://chatgpt.com/share/673d366e-0384-8009-a6d3-d7a0c96c41f2 "ChatGPT.com")


### Q: 

Rootless podman containers stop when user logs out?

### A:

Yes, rootless Podman containers will stop when the user logs out by default. This is because __they are tied to the user's session__ and their processes terminate when the session ends.

__To prevent rootless Podman containers from stopping upon logout__, 
you can use the Podman service or systemd integration: 

```bash
app=bbox

# Configure to always restart
podman run -d --restart=always --name $app busybox sleep 1d

# Generate user-scoped systemd service file : DEPRICATED : use Quadlets
podman generate systemd --new --name $app --files

# Move the systemd service file:
mkdir -p ~/.config/systemd/user 
mv container-$app.service ~/.config/systemd/user/

# Enable/Start the service on user login
systemctl --user enable --now container-$app.service

# Enable lingering
loginctl enable-linger $(whoami)

# Teardown
podman container stop $app
podman container rm $app 
```
- The `loginctl enable-linger` command allows user-specific services (including systemd units managed by the `--user` flag) to keep running even when the user is not logged in. __Without enabling lingering, systemd will stop all user services when you log out__, which includes your Podman containers.

This approach ensures that your rootless Podman containers 
remain running even when you log out.

#### UPDATE : Use Quadlets 

__Quadlets are essentially a systemd unit generator specifically for containers__. Instead of manually writing complex `.service` files, you can use `.container` files (a simplified format) to define container behaviors, such as the image to use, environment variables, volumes, and restart policies.

These `.container` files are easier to write and maintain compared to traditional `.service` files that might call podman run commands. __Systemd then reads these Quadlet `.container` files and generates the appropriate `.service` units behind the scenes.__

Setup:

```bash
app=bbox

# Create the systemd .container file
mkdir -p ~/.config/systemd/user 
cat <<-EOH |tee ~/.config/systemd/user/$app.container
[Container]
Image=docker.io/library/busybox:latest
Name=$app
Command=/usr/bin/start-app --flag
Volume=/host/data:/data:rw
Volume=/host/config:/config:ro
Network=host
Port=8080:80
Environment=ENV_VAR=value
Environment=TLS_CERT=/config/cert.pem
Environment=TLS_KEY=/config/key.pem
WorkDir=/app
Restart=always
EOH

# Enable/Start the service on user login
systemctl --user enable --now $app.container

# Enable lingering
loginctl enable-linger $(whoami)

```

This approach is cleaner and recommended if you are seeing warnings about Quadlets. Quadlets simplify the management of containers using systemd while retaining the flexibility of systemd service management.



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

