# Podman : Rootless Containers | [Chat 2](https://chatgpt.com/share/673a11b8-165c-8009-8412-2dec016a61b7 "ChatGPT.com") | [Chat 3](https://chatgpt.com/share/6700711a-5b14-8009-82f9-decd11ce4f0c "ChatGPT.com") | [Chat 4](https://chatgpt.com/share/6817bc76-62bc-8009-8003-baf013ec9781)

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
    - A more sophisticated method is required if multiple users are to run podman rootless, 
    because each user must have their own unique range of `subuid`/`subgid`.

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

## Quadlets 

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



## `podman play kube` 

Define the pod and its containers declaratively using **Podman's `podman play kube`** feature. 
This allows you to describe the entire pod (including its containers, volumes, and networking) 
in a **K8s-compatible YAML file**. The systemd service can then use this YAML file 
to start and manage the pod without requiring out-of-band `podman` commands.

Here’s how to do it:

---

### 1. **Create a K8s-Compatible YAML File**
Define the pod and its containers in a YAML file. Save it as `/path/to/registry-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: registry-pod
spec:
  containers:
    - name: registry
      image: docker.io/library/registry:2
      volumeMounts:
        - name: registry-data
          mountPath: /var/lib/registry
      ports:
        - containerPort: 5000

    - name: nginx
      image: docker.io/library/nginx:alpine
      volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/conf.d
        - name: nginx-ssl
          mountPath: /etc/nginx/ssl
      ports:
        - containerPort: 443

  volumes:
    - name: registry-data
      hostPath:
        path: /path/to/registry/data
        type: Directory
    - name: nginx-config
      hostPath:
        path: /path/to/nginx/conf.d
        type: Directory
    - name: nginx-ssl
      hostPath:
        path: /path/to/nginx/ssl
        type: Directory
```

- Replace `/path/to/registry/data` with the directory for the registry data.
- Replace `/path/to/nginx/conf.d` and `/path/to/nginx/ssl` with the paths to your NGINX configuration and TLS certificates.

---

### 2. **Create the NGINX Configuration**
Create the NGINX configuration file for the registry at `/path/to/nginx/conf.d/registry.conf`:

```nginx
server {
    listen 443 ssl;
    server_name registry.example.com;

    ssl_certificate /etc/nginx/ssl/registry.crt;
    ssl_certificate_key /etc/nginx/ssl/registry.key;

    client_max_body_size 0; # Disable body size check for large uploads

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

- Replace `registry.example.com` with your domain.
- Place your TLS certificate and key in `/path/to/nginx/ssl/registry.crt` and `/path/to/nginx/ssl/registry.key`.

---

### 3. **Create a Systemd Service**
Create a systemd service file to manage the pod using the YAML file. Save it as `/etc/systemd/system/registry-pod.service`:

```ini
[Unit]
Description=CNCF Distribution Registry Pod (Podman)
After=network.target

[Service]
ExecStart=/usr/bin/podman play kube /path/to/registry-pod.yaml
ExecStop=/usr/bin/podman pod stop -t 10 registry-pod
ExecStopPost=/usr/bin/podman pod rm -f registry-pod
Restart=always

[Install]
WantedBy=multi-user.target
```

- Replace `/path/to/registry-pod.yaml` with the path to your YAML file.

Reload systemd and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl start registry-pod
sudo systemctl enable registry-pod
```

---

### 4. **Verify the Setup**
- Test the registry by pushing/pulling an image using the NGINX proxy:
  ```bash
  docker pull alpine
  docker tag alpine registry.example.com/alpine
  docker push registry.example.com/alpine
  ```
- Check the status of the pod and containers:
  ```bash
  podman pod ps
  podman ps
  ```

---

### 5. **Optional: Secure the Registry**
- Add authentication to the registry by configuring HTTP basic auth or integrating with an external authentication service.
- Use Podman's secrets management for secure handling of credentials.

---

### Summary
This approach uses a **declarative YAML file** to define the pod and its containers, which is then managed by a **systemd service**. The `podman play kube` command reads the YAML file and creates the pod, ensuring that the entire setup is self-contained and reproducible without requiring out-of-band `podman` commands.


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

