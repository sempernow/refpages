# Docker : Security

## Login to Docker Hub

If login repeatedly FAIL/ERROR (even HTTP `502`, `503`, ...) &hellip;

```bash
Error response from daemon: Get https://registry-1.docker.io/v2/: received unexpected HTTP status: 503 Service Unavailable
```

FIX: DELETE all `"credStore": ...` key(s) @ [`config.json`](file:///c:/HOME/.docker/config.json)

@ Logout, want &hellip;
```json
    {
        "auths": {
            "https://index.docker.io/v1/": {
                "auth": "Z3n...cHM="
            }
        },
        "HttpHeaders": {
            "User-Agent": "Docker-Client/19.03.11 (linux)"
        }
    }
```

```bash
docker logout #... ALWAYS DO THIS FIRST.
# Login:
docker login
# OR
docker login --u $username 
# ... either prompt for password(|token)
Password: <PASTE password or token>

# OR, use this one liner sans prompt ...
echo $pw_or_token |docker login -u $username --password-stdin
```
- Create access token from Docker Hub account > Security > ...
- Login URL is `https://index.docker.io/v2/`

### [`~/.docker/config.json`](file:///c:/HOME/.docker/config.json)

@ Logout, want &hellip;

```json
    {
        "auths": {},
        "HttpHeaders": {
            "User-Agent": "Docker-Client/19.03.11 (linux)"
        }
    }
```

@ Login, want &hellip;

```json
    {
        "auths": {
            "https://index.docker.io/v1/": {
                "auth": "Z3n...cHM="
            }
        },
        "HttpHeaders": {
            "User-Agent": "Docker-Client/19.03.11 (linux)"
        }
    }
```
- Note credentials,  `"auths": ...`, are UNENCRYPTED, Base64 encoded.
    ```bash
    echo 'Z3n...cHM=' |base64 -d -
    #... returns ...
    <USERNAME>:<PW_OR_TOKEN>
    ```

# [Docker Container Security](https://www.youtube.com/watch?v=JE2PJbbpjsM "YouTube 2020") | [`devops-directive`](https://github.com/sidpalas/devops-directive "GitHub")

## Best Practices 

1. Do not run container as root
    - @ Dockerfile: `USER uzer`
    ```bash
    # Set/Add User and Group
    ARG UNAME=tor
    ARG UID=100
    ARG GID=65533
    RUN groupadd -g $GID $UNAME && useradd -m -u $UID -g $GID -s /bin/bash -c "Docker-image user" $UNAME
    #... else ... && useradd -m -u $UID -g $GID -s /sbin/nologin -c "Docker-image user" $UNAME
    #... forbid login by all but for root.
    USER root

    # Install software etal
    RUN dnf install -y vim

    # Run as unprivileged user
    USER $UNAME
    ...
    ```

1. Multi-stage build producing a distro-less image.
1. Secure the VM/Host OS
    - Goolge COS
    - AppArmor
1. Container Image Scanner


## [Secure Containers @ RedHatGov.io](http://redhatgov.io/workshops/security_containers/exercise1.1/)

### [Remove `setuid`/`setgid` binaries](http://redhatgov.io/workshops/security_containers/exercise1.3/ "RedHatGov.io")

Or just defang the image, as shown below.

SETUID/SETGID Overview

There are two special permissions that can be set on executable files: Set User ID (setuid) and Set Group ID (sgid). These permissions allow the file being executed to be executed with the privileges of the owner or the group. For example, if a file was owned by the root user and has the setuid bit set, no matter who executed the file it would always run with root user privileges.

Chances are that your application does not need any elevated privileges. setuid or setgid binaries. If you can disable or remove such binaries, you stop any chance of them being used for buffer overruns, path traversal/injection and privilege escalation attacks.

Defang the image

```bash
RUN find / -xdev -perm +6000 -type f -exec chmod a-s {} \; || true
```
- [`chmod(1)` man page](https://linux.die.net/man/1/chmod)


## Firewalls : Security Groups etal

The issues below (Docker mucking with `iptables`) are all in the context of deploying sans VPC-based firewalls. That is, they rely upon node-based protections (the node is that hosting the Docker server).

### [Docker / UFW security flaw](https://www.techrepublic.com/article/how-to-fix-the-docker-and-ufw-security-flaw/ "techrepublic.com 2018")

>_UFW is a popular iptables front end on Ubuntu that makes it easy to manage firewall rules. But when Docker is installed, Docker bypass the UFW rules and the published ports can be accessed from outside._ 

&mdash; [`github.com/chaifeng`](https://github.com/chaifeng/ufw-docker)

#### Bad "Fix":

```bash
# Open Docker server config:
vi /etc/default/docker 
# Add k/v:
DOCKER_OPTS="--iptables=false"
# Restart Docker server
sudo systemctl restart docker
```
- But this spwans a new nest of problems

### [Solving UFW-Docker issues](https://github.com/chaifeng/ufw-docker#solving-ufw-and-docker-issues)

[... more ...](https://www.qualityology.com/tech/let-docker-and-ufw-firewall-work-together/)

### 

- [`iptables`](https://linux.die.net/man/8/iptables "man page @ linux.die.net")
    ```bash
    sudo iptables -L
    ```
    - The Linux firewall utility; setup, maintain firewall rules; for node-based protection. Okay, but better to handle upstream at the subnet level.
- [UFW](https://help.ubuntu.com/community/UFW "help.ubuntu.com") (Uncomplicated Firewall)

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

