# [Podman : Rootless Containers](https://chatgpt.com/share/66fb4da2-017c-8009-9aa7-645e0640605b "ChatGPT.com")

## Q: 

Rootless podman containers stop when user logs out?

## A:

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

### UPDATE : Use Quadlets 

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

