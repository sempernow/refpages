# [Minikube](https://github.com/kubernetes/minikube "Kubernetes @ GitHub") :: Kubernetes Local Dev/Ops  

![Minikube](Minikube0.png)

Minikube is a single-node Kubernetes cluster on a local VM; for development (local) ONLY.   
Its CLI tool, `minikube`, is the cluster manager. It can configure the Kubernetes `kubectl` tool,  
which is used in both development and production, to communicate with the Minikube cluster.

- Typically runs on a hypervisor (Hyper-V or VirtualBox).  
It's a huge CPU/RAM hog, on Hyper-V (`vmmem.exe`),  
even if nothing is deployed.  
 
- Sans hypervisor, @  __`none` driver option__,  
it runs Kubernetes on the host instead of a VM.   
This option requires Docker; has __security issues__. ([MD](REF.Kubernetes.minik_NONE_DRIVER.md "REF.Kubernetes.minik_NONE_DRIVER.md") | [HTML](REF.Kubernetes.minik_NONE_DRIVER.html "@ browser"))  
    - `minikube start --vm-driver=none`  

## Globally Applicable References

- [Minikube @ GitHub](https://github.com/kubernetes/minikube) 
- Install [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)   

- [Tools](https://kubernetes.io/docs/reference/tools/)
- [Running Kubernetes Locally via Minikube](https://kubernetes.io/docs/setup/minikube/)
- [Hello Minikube :: QuickStart](https://kubernetes.io/docs/tutorials/hello-minikube/) | Local Reference ( [MD](REF.Kubernetes.QuickStart.html "If @ browser"))

- [Interactive Tutorials](https://kubernetes.io/docs/tutorials/)
- [`minikube` commands](https://kubernetes.io/docs/setup/minikube/#managing-your-cluster "kubernetes.io/docs/setup/minikube/...")
- [`kubectl` commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands "kubernetes.io/docs/reference/...")
- [Web UI (Dashboard)](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

## @ Mac &mdash; xhyve  

```bash
# Install client (kubectl)
brew install kubectl 
# Validate
kubectl version --client
# Install minikube
brew cask install minikube
# Install xhyve 
brew install docker-machine-driver-xhyve
# Requires/Instructs to set privileges 
sudo chown root:wheel /usr/local/opt/docker-machine...
sudo chmod u+s /usr/local/opt/docker-machine...
```

## [@ Linux &mdash; VirtualBox](https://github.com/kubernetes/minikube#linux "Minikube @ GitHub")  

### Install VirtualBox ([MD](REF.VirtualBox.Install.html "@ browser"))
- This does __not__ work if Linux is on VM @ Hyper-V ([MD](REF.Hyper-V.Nested-Virtualization.html "If @ browser")) .

### [Install `kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) 
```bash
# @ CentOS
# Add Kubernetes repo 
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl  # (x86_64/1.12.2-0)
```

### [Install `minikube`](https://github.com/kubernetes/minikube#linux) 

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && sudo install minikube-linux-amd64 /usr/local/bin/minikube
```


## [@ Win10 (R4) &mdash; Hyper-V](https://www.c-sharpcorner.com/article/getting-started-with-kubernetes-on-windows-10-using-hyperv-and-minikube/ "Getting Started With Kubernetes On Windows 10 Using HyperV And MiniKube [2018]")
### CLI Tools @ PowerShell: `minikube` (@ `SystemDrive` only)  + `kubectl`

### References @ Win10/Hyper-V

- [Get Started with Kubernetes on Win 10 using Hyper-V and Minikube](https://www.c-sarpcorner.com/article/getting-started-with-kubernetes-on-windows-10-using-hyperv-and-minikube/ "Jan 2018")   

- [Running your own Docker containers in Minikube for Windows](https://medium.com/@maumribeiro/running-your-own-docker-images-in-minikube-for-windows-ea7383d931f6 "Medium.com 2017")

- Others   
May 2018  https://www.marksei.com/minikube-kubernetes-windows/   
Jun 2018  https://learnk8s.io/blog/installing-docker-and-kubernetes-on-windows   

### Prep/Download/Install

- [Enable Hyper-V](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v "Microsoft 2016")
    ```powershell
    PS> Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    ```

- _Check for a Docker-for-Windows installed version of `kubectl`._  

- Install [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) per [Chocolatey](https://chocolatey.org/search?q=minikube "Package Manager for Windows")  
    ```powershell
    choco install minikube -y        # minikube; ~/.minikube/config.json   
    choco install kubernetes-cli -y  # kubectl;  ~/.kube/config
    ```     

- [Install manually](https://kubernetes.io/docs/tasks/tools/install-minikube/) per Kubernetes.io  
Download `kubectl.exe` and `minikube.exe`, and place in folder `C:\Minikube`; add to `PATH`.
    ```bash
    # kubectl.exe
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/windows/amd64/kubectl.exe
    ```
    - Download Minikube [latest version @ Kubernetes.io](https://storage.googleapis.com/minikube/releases/v0.30.0/minikube-windows-amd64.exe), rename and place in folder with `kubectl.exe`

- __Docker for Windows__ (Optional Install)  
(Minikube runs its own Docker server/client inside the VM.)
    - [Docker for Windows Installer](https://docs.docker.com/v17.09/docker-for-windows/install/#download-docker-for-windows)
    - `choco install docker-for-windows -y` 

### Configure

- Using PowerShell, or Hyper-V GUI, __create__ an [External Virtual Switch](https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-switch-for-hyper-v-virtual-machines) for it, __from__ a ___physical___ network interface (e.g., Intel 1219V Gigabit Ethernet Adapter):
    ```powershell
    PS> New-VMSwitch -name minikube-GbE -NetAdapterName GbE -AllowManagementOS $true  
    ```  

- `config.json` @ `~/.minikube/config/`
    ```json
    {
        "WantReportError": false,
        "WantReportErrorPrompt": false,
        "hyperv-virtual-switch": "minikube-GbE",
        "profile": "minikube",
        "v": 1,
        "vm-driver": "hyperv",
        "memory": 2048
    }
    ```
    - [__All__ configurable settings (__keys__)](https://github.com/kubernetes/minikube/blob/master/cmd/minikube/cmd/config/config.go "config.go #46")
- On 1<sup>st</sup> Start, (re)set hypervisor &amp; virtual-switch, and tee verbose log to `STDERR`. The minikube-titled VM is created upon this 1<sup>st</sup> `start` command.   

    ```powershell
    PS> minikube start --vm-driver=hyperv --hyperv-virtual-switch=minikube-GbE --v=7 --alsologtostderr
    ```
    - Such command options are handled per `config.json` (above) if exist. 

    - 1st run may fail if not run from system drive. 
- Then stutdown the VM to tweak its Hyper-V setting(s) 

    ```powershell
    PS> minikube ssh   # ssh into the running Minikube
    $ sudo poweroff    # turn it off 
    ```

    ```powershell 
    PS> minikube stop  # don't use; hangs and fails.
    ```

- Disable __dynamic memory__ for the VM. (Use either method.)

    - @ Hyper-V (GUI)   
`Hyper-V > minikube > Settings > Memory > "Enable Dynamic Memory" > UNCHECK (check-box)`

    - @ Powershell [Set-VMMemory](https://docs.microsoft.com/en-us/powershell/module/hyper-v/set-vmmemory?view=win10-ps#required-parameters "docs.microsoft.com/.../hyper-v/... 2016")

        ```powershell
        # disable dynamic memory, set static size, and validate the changes
        PS> Set-VMMemory "minikube" -DynamicMemoryEnabled $false -StartupBytes 2GB 
        PS> Get-VMMemory "minikube"
        ```

- Minikube VM config, including `IPAddress` and such, set   
    @ `~/.minikube/machines/minikube/config.json`

- Configure `kubectl` for Minikube   
`kubectl config use-context minikube` 
    ```bash
    # Check kubectl "context"
    kubectl config get-contexts
    # If need be, switch kubectl to Minikube context
    kubectl config use-context minikube
    # Get config  
    kubectl config view 
    # Get the Minikube system (VM) pods
    kubectl get pods -n kube-system
    ```

### Configure Docker for Minikube (_temporarily_)  
`minikube docker-env`   
Use to configure ___the current shell___ such that the `docker` CLI tool (Docker-for-Windows client) binds to Minikube's Docker server instead of its own. 

![Multiple Docker Installations @ minikube docker-env (StephenGrider/DockerCasts)](Multiple.Docker.Installations-@-minikube.docker-env.jpg "StephenGrider/DockerCasts @ GitHub")

- @ Windows 

    ```powershell
    PS> minikube docker-env | Invoke-Expression
    ```
- @ Unix (Mac/Linux)

    ```bash
    $ eval $(minikube docker-env)
    ```

Verify ...
```powershell
# List containers running @ minikube pod(s) ...
PS> docker ps 
# List all images thereof 
PS> docker images
```

The command itself prints Minikube's Docker (server) Env. vars., and instructs

```powershell
PS> minikube docker-env
$Env:DOCKER_TLS_VERIFY = "1"
$Env:DOCKER_HOST = "tcp://192.168.1.105:2376"
$Env:DOCKER_CERT_PATH = "C:\Users\X1\.minikube\certs"
$Env:DOCKER_API_VERSION = "1.35"
# Run this command to configure your shell:
# & minikube docker-env | Invoke-Expression
```

## Kubernetes (`kubectl`) @ WSL [MD](file:///D:/1%20Data/IT/OS/Windows/Win10/WSL/REF.WSL.md "See REF.WSL.md") | [HTML](file:///D:/1%20Data/IT/OS/Windows/Win10/WSL/REF.WSL.html "If @ browser")

- Problematic integration.

## Hello Minikube :: Quickstart  [MD](file:///D:/1%20Data/IT/Container/Kubernetes/REF.Kubernetes.QuickStart.md "See REF.Kubernetes.QuickStart.md") | [HTML](file:///D:/1%20Data/IT/Container/Kubernetes/REF.Kubernetes.QuickStart.html "If @ browser")

- A one-pod cluster exposed to the standard HTTP listening port. 

## Environment variables read by `minikube`

```bash
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
mkdir -p $HOME/.kube
mkdir -p $HOME/.minikube
touch $HOME/.kube/config
```

## Profile, per VM, defined at its `config.json` file   
The values therein are dynamically set per `minikube start`. However, `NodeIP` (the __public IP address__ of the minikube VM; cluster endpoint) can be set at the Gateway router > LAN > DHCP ... ;  "Manually Assigned" around the Gateway's specified/limited range of dynamically assigned IPs, per client (minikube) MAC.

@ [~/.minikube/profiles/minikube/config.json](file:///C:/HOME/.minikube/profiles/minikube/config.json)

```json
{
    "MachineConfig": {
        "MinikubeISO": "https://storage.googleapis.com/minikube/iso/minikube-v0.30.0.iso",
        "Memory": 2048,
        "CPUs": 2,
        "DiskSize": 20000,
        "VMDriver": "hyperv",
        ...
        "HostOnlyCIDR": "192.168.99.1/24",
        "HypervVirtualSwitch": "minikube-GbE",
        ...
        "NFSSharesRoot": "/nfsshares",
        ...
    },
    "KubernetesConfig": {
        "KubernetesVersion": "v1.10.0",
        "NodeIP": "192.168.1.105",  
        "NodeName": "minikube",
        "APIServerName": "minikubeCA",
        ...
        "DNSDomain": "cluster.local",
        ...
        "ServiceCIDR": "10.96.0.0/12",
        ...
    }
}
```


.
