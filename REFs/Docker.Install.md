# Docker Install | [Kill Docker Auto Updates](https://github.com/RektInator/kill-docker-auto-update "GitHub")

UPDATE : 2023-07-03 : Docker Desktop 4.19.0 (106363) 

```
wsl --update
```
- BREAKS Docker Desktop; requiring reset to "factory defaults".

Docker for Windows a.k.a. Docker Desktop

Current setup &hellip;

```shell
choco install docker-desktop --version 3.2.2
```
- With auto-updater disabled per `dnSpy.exe`. (See details below.)

History &hellip;

```shell
:: Tested : ok : Updater disabled
choco install docker-desktop --version 3.1.0
:: Tested : ok : Updater disabled
choco install docker-desktop --version 3.2.2
:: Tested : FAILs @ recompile to disable Updater
choco install docker-desktop --version 3.3.3
:: Tested : FAILs @ WSL
choco install docker-desktop --version 3.5.0
```
- Disable the auto-updater using [`dnSpy.exe`](https://github.com/dnSpy/dnSpy "GitHub")
    - Run as Administrator
    - File > Open > `Docker.ApiServices.dll` (copy) 
        - Copy from `%ProgramFiles%\Docker\Docker\`
    - Find function "`Updater`" (class) > "`CheckForUpdates`" (function)
        - Replace entire function body with "return;"
    - Compile (button)
    - File > Save Module
    - Copy the file back to origin.

# 2021-07-01

## ~~FIX~~ : [Expose `tcp://0.0.0.0:2376`](https://stackoverflow.com/questions/63416280/how-to-expose-docker-tcp-socket-on-wsl2-wsl-installed-docker-not-docker-deskt "StackOverflow.com 2020") (for WSL etal)

Does nothing.

### Add these key-val pair(s) to `~/.docker/daemon.json`

Insecure

```json
"hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"],
```
+Secure

```json
"hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"],
"tlscacert": "~/.docker/certs/ca.pem",
"tlscert": "~/.docker/certs/server-cert.pem",
"tlskey": "~/.docker/certs/server-key.pem",
"tlsverify": true
```

```bash
mkdir ~/.docker/certs
cd ~/.docker/certs
openssl genrsa -aes256 -out ca-key.pem 4096  # enter passphrase
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem  # enter localhost or FQDN
openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=localhost" -sha256 -new -key server-key.pem -out server.csr
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem
echo subjectAltName = DNS:localhost,IP:127.0.0.1 >> extfile.cnf
echo extendedKeyUsage = serverAuth >> extfile.cnf
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf
openssl genrsa -out key.pem 4096
openssl req -subj '/CN=client' -new -key key.pem -out client.csr
echo extendedKeyUsage = clientAuth > extfile-client.cnf
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile-client.cnf
```


## 2020-09-14 

- `docker-credential-desktop` @ WSL/Ubuntu 
    - ISSUE: Fail @ `docker-compose up` of `openzipkin/zipkin` (Tag: `2.11`):
        ```plaintext 
        docker.credentials.errors.InitializationError: docker-credential-desktop not installed or not available in PATH
        ```
    - SOLN: Delete `credsStore` key-val pair @ `~/.docker/config.json`

## @ Windows 10 (Pro/Ent)
1. Enable Hyper-V (Win10 OS Feature), and reboot
2. Download and install 
    - per [~~Docker-for-Windows~~ Docker Desktop]( https://store.docker.com/editions/community/docker-ce-desktop-windows "store.docker.com") installer (2018)
    - per [Chocolatey](https://chocolatey.org/packages?q=docker "@ chocolatey.org/packages") (2019-11-07) 
    ```powershell
    choco install -y docker-desktop docker-cli docker-compose docker-machine
    ```
- Installs as a VM (~~`MobyLinuxVM`~~ `DockerDesktopVM`) under Hyper-V, which is a Type-1 (hardware virtualization) hypervisor. Requires an Intel CPU with `VT-x`. 
    - Docker VM: `2` 
    - CPU, `2GB` 
    - RAM, `DockerNAT` 
    - Virtual Switch, `60GB` 
    - @ `MobyLinuxVM.vhdx` 
        (`docker-for-win.iso`) @ `%ProgramFiles%\Docker\Docker\Resources`. 
- PowerShell native, but can get other shells to work.
    - Also works @ WSL, but for certain __credentials__ access, (`credstore`), e.g., can't `push` to Docker Hub. 
        - [To fix certain related issues](https://github.com/docker/docker-credential-helpers/issues/24 "GitHub.com/docker/.../issues"), remove: `"credsStore": "wincred"` [@ `~/.docker/config.json`](file:///c:/HOME/.docker/config.json). 
            ```json
            {
                "stackOrchestrator": "swarm",
                "auths": {},
                "credsStore": "wincred"
            }
            ```

### @ Win7/8/8.1/10-Home  
- Use __Docker Toolbox__  

## @ Linux
The main Docker CLI tool, `docker`, is the "Docker Engine" (tool). Depending on Linux distro/version,   the package manager/repo may identify it only by `docker`, `docker-ce`, `docker-engine`, or something else. (See [`install.docker.sh`](install.docker.sh))

### @ CentOS/RHEL 7

Method 1

```bash
sudo yum update -y             # Update pkg-mgr index
sudo yum install -y docker     # Install latest Docker CE 
```

Method 2

```bash
# Setup repo
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    'https://download.docker.com/linux/centos/docker-ce.repo'
sudo yum makecache fast
# Install
sudo yum install -y docker-ce # latest version
```

### @ Debian/Ubuntu 18

```bash
# per Docker repo
export DOCKER_CHANNEL='edge'
export DOCKER_COMPOSE_VERSION='1.21.0'
sudo apt-get update -y  # Update pkg-mgr index
# Install packages that allow apt to use a repo over HTTPS.
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
# Add Docker's official GPG key.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Verify the fingerprint.
sudo apt-key fingerprint 0EBFCD88
# Pick the release channel.
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   ${DOCKER_CHANNEL}"
# Update the apt package index.
sudo apt-get update
# Install the latest version of Docker CE.
sudo apt-get install -y docker-ce
```

## Config 

```bash
systemctl start docker   # systemd
service docker start     # equiv. non-systemd (AWS AMI)

# Allow user access Docker CLI, sans root.
sudo usermod -aG docker $USER  # 'ec2-user' @ AWS EC2, 'vagrant' @ Vagrant box, ... 
# Update to take effect now
sudo newgrp docker
```

- If no `usermod`, then tool requires `sudo ...`, e.g.,  
    ```bash
    sudo docker build .
    ```

Docker bash completion    
(_Had no effect whatsoever @ WSL Ubuntu_.)

```bash  
sudo curl https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh
```

## Test Install

```bash
# Test (sans sudo) 
docker info                # prints Docker env. info 
# Docker's "Hello World" container 
docker run hello-world     # prints to STDOUT
# Busybox
docker run -it busybox sh  # interactive terminal  
# Alpine Linux
docker run -it alpine      # default (auto) CMD is `sh` (ash shell)
# Nginx server @ bkgnd process ...
docker run -d -p 80:80 --name 'proxy' nginx  
# ... then browse or curl http://localhost:80 
```

## Install other Docker CLI tools

###  Docker Compose ([releases](https://github.com/docker/compose/releases "GitHub repo"))

```bash
# Install Docker Compose
export _v='1.23.2'  # https://github.com/docker/compose/releases
base=https://github.com/docker/compose/releases/download/${_v} \
    && sudo curl -L $base/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose \
    && sudo chmod +x /usr/local/bin/docker-compose
```

### Docker Machine ([releases](https://github.com/docker/machine/releases "GitHub repo"))

```bash
# Install Docker Machine
export _v='v0.16.0'  # https://github.com/docker/machine/releases
base=https://github.com/docker/machine/releases/download/${_v} \
    && curl -L $base/docker-machine-$(uname -s)-$(uname -m) -o /tmp/docker-machine \
    && sudo install /tmp/docker-machine /usr/local/bin/docker-machine

# Config CURRENT SHELL per SWARM_MGR so can use docker CLI tool
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.1.11:2376"  
# port 2376 supposedly problematic, but lack certs for 2377
export DOCKER_CERT_PATH="/c/Users/X1/.docker/machine/machines/$_SWARM_MGR"
export DOCKER_MACHINE_NAME="$_SWARM_MGR"
export COMPOSE_CONVERT_WINDOWS_PATHS="true"
```

## [Docker @ WSL](https://nickjanetakis.com/blog/setting-up-docker-for-windows-and-wsl-to-work-flawlessly)  

Install/setup such that Docker _client_ @ WSL communicates with Docker-for-Windows _server_, instead of its own. This is analogous to the Kubernetes method for integrating the Docker-for-Windows client with Minikube's docker-server. See `Minikube.Install.md` ([MD](file:///D:/1%20Data/IT/Container/Kubernetes/Minikube.Install.md) | [HTML](file:///D:/1%20Data/IT/Container/Kubernetes/Minikube.Install.html "@ browser")).  

1. Select @ Docker-for-Windows (GUI) 
    - > Settings > "Expose daemon on `tcp://loc...`"  (check-box)  
1. Install Docker (`docker-engine`), @ WSL console, per distro (methods above)
1. @ `~/.bashrc`   

    ```bash
    export DOCKER_HOST=tcp://0.0.0.0:2375
    ```

1. Ensure Volume Mounts Work   

    - @ `/etc/wsl.conf`

        ```conf
        [automount]
        root = /
        options = "metadata"
        ```

        ```bash
        # fix /mnt/c (if need be)
        sudo mkdir /c
        sudo mount --bind /mnt/c /c
        ```

    - Test @ WSL, while Docker-for-Windows is running ... 

        ```bash
        docker info  # should print its settings
        ```

## `Docker.md` ([MD](Docker.html "@ browser"))  

## [`Docker.sh` (link)](file:///D:/1%20Data/IT/Container/Docker/Docker.sh) 

### &nbsp;