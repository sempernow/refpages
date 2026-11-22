# [Minikube](https://minikube.sigs.k8s.io/docs/) | [Kubernetes.io](https://kubernetes.io/docs/tasks/tools/#minikube "Kubernetes.io") | [QuickStart](https://kubernetes.io/docs/tutorials/hello-minikube/) | [GitHub](https://github.com/kubernetes/minikube)


## See [`K8s.minikube-setup.sh`](K8s.minikube-setup.sh)

```bash
# API Server info @ minikube
kubectl -n kube-system describe pod kube-apiserver-minikube 
```

## WARNING : 2018 Notes

### [Commands](https://minikube.sigs.k8s.io/docs/commands/)  

```powershell  
minikube update-check           # list installed v. available
minikube addons list            # list all available addons
minikube start                  # create minikube VM (Hyper-V)
    --vm-driver=hyperv          # Explicitly set driver
    --hyperv-virtual-switch=External-GbE  # set Virtual Switch
    --v=7 --alsologtostderr     # verbose report to STDOUT
    --kubernetes-version="v1.6.0"  # ver
minikube ip                     # IP_ADDR
minikube service NAME --url     # service IP_ADDR:PORT
minikube service NAME --https   # open per https
minikube dashboard              # Web UI (Dashboard)
minikube config view            # ./minikube/config/config.json
minikube update-context         # fix "Misconfigured ..."
minikube status                 # Shows its address if running 
minikube delete                 # delete the entire VM

# Dashboard (Web UI)
minikube dashboard

# Dashboard URL
minikube dashboard --url  
# e.g., http://192.168.1.100:30000
``` 

- Minikube supports a __`none` driver option__  that runs the Kubernetes components ___on the host and not in a VM___. Using this driver __requires Docker__, but __not a hypervisor__. The option has __security issues__. ([MD](Kubernetes.minik_NONE_DRIVER.md "Kubernetes.minik_NONE_DRIVER.md") | [HTML](Kubernetes.minik_NONE_DRIVER.html "@ browser"))   
`minikube start --vm-driver=none`  

- Debug; `tee` verbose log to `STDERR`:   
`minikube COMMAND -v 7 --alsologtostderr`
- On catastrohpy, "Turn off" @ Hyper-V (GUI), shutdown per PowerShell method (below), or reboot. 
- On `start` fail, delete machine folder @ `~/.minikube/machines/minikube`

### Stopping the VM has problems.

- `minikube ssh`  
This method works.

    ```powershell
    minikube ssh           # SSH into VM
    $ sudo poweroff        # turn VM off, from within
    ```

- `minikube stop`  
This method does ___not___ work.

    ```powershell
    minikube stop -v 7     # Nope; fails after long timeout 
    ```

- @ Powershell [Hyper-V command](https://docs.microsoft.com/en-us/powershell/module/hyper-v/stop-vm?view=win10-ps "docs.microsoft.com/.../hyper-v/stop-vm 2016") from guest (Windows OS)

    ```powershell
    PS> Stop-VM -Name minikube           # unsaved data is saved 
    PS> Stop-VM -Name minikube -Force    # unsaved data may be lost
    PS> Stop-VM -Name minikube -TurnOff  # unsaved data is lost
    ```

    - Minikube's `vEthernet` adapter fails to disable as well, so successive starts tend to require successive IPs from the DHCP Server (the Gateway router).

    - @ `cmd.exe` method to `enable` or `disable` the adapter.  
        `NETSH interface set interface name="minikube-GbE" admin=disable`

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

The command itself prints Minikube's Docker (server) Env. vars., and instructs.

```powershell
PS> minikube docker-env
$Env:DOCKER_TLS_VERIFY = "1"
$Env:DOCKER_HOST = "tcp://192.168.1.105:2376"
$Env:DOCKER_CERT_PATH = "C:\Users\X1\.minikube\certs"
$Env:DOCKER_API_VERSION = "1.35"
# Run this command to configure your shell:
# & minikube docker-env | Invoke-Expression
```

## [Kubernetes Object Management](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/ "kubernetes.io/docs/.../object-management-kubectl") 

```bash 
kubectl apply   # Declarative 
kubectl create  # Imperative
```

### [Declarative Management](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/declarative-config/ "kubernetes.io/docs/.../declarative-config")

```bash
kubectl apply -f configs/     # process all @ dir
kubectl apply -R -f configs/  # recursively process dirs
```

### [Imperative Management](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/#imperative-object-configuration "kubernetes.io/docs/.../imperative-object-configuration")

```bash
# Imperative commands
kubectl create  -f nginx.yaml
kubectl delete  -f nginx.yaml -f redis.yaml
kubectl replace -f nginx.yaml

# Two equivalent commands
kubectl run nginx --image nginx
kubectl create deployment nginx --image nginx  # equivalent

```

## [`kubectl` commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands "kubernetes.io/docs/.../kubectl-commands")  

```bash
# View current context
kubectl config current-context
# Get contexts
kubectl config get-contexts
# Set context to local minikube cluster  
kubectl config set-context minikube  
# Get minikube cluster config details  
kubectl config view minikube  
# Master IP:port [ALL the info]
kubectl cluster-info [dump]
# Run
kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.4 --port=8080 

# Get the Minikube system (VM) pods
kubectl get pods -n kube-system
# Get pods|services|DEPLOYMENTS|pv|pvc
kubectl get pods
 # Get pod labels; ensure service label (@ Manifest file) matches 
kubectl get pods --show-labels 
kubectl get pods --selector KEY=VALUE

# Get service ENDPOINTs
kubectl get ep            
# Get ALL POD IPs (unstable) matching service's selector label
kubectl describe ep $_SERVICE  

# Service (Pod/App Access)
kubectl get service          # list all services
# Detailed info, incl internal endpoint (IP:PORT) for comms
kubectl describe service $_SERVICE
...
Port:        <unset> 3000/TCP   # this pod localhost access
NodePort:    <unset> 31172/TCP  # public access
Endpoints:   172.17.0.5:3000    # pod-to-pod access

# storage PERSISTENT VOLUME (pv) CLAIM (pvc)
kubectl get pv
kubectl get pvc 
kubectl get storageclass

# DEPLOYMENTs

# APPLY config to a pod|deploy
kubectl apply -f ./deploy.yml --record
# APPLY all configs @ FOLDER
kubectl apply -f FOLDER --record
# HISTORY (shows command history if `--record` used)
kubectl rollout history deployment NAME
# Rollout Status 
kubectl rollout status deployment NAME
# List Replica Sets 
kubectl get rs  # should show new and old 

# DESCRIBE pod|deploy (current state; detailed info)  
kubectl describe pod|deploy NAME [OBJECT]
# DELETE pod|service per FILE (an imperative update)
kubectl delete -f client-pod.yaml
# DELETE pod|service per RESOURCE (an imperative update)
kubectl delete pod|service NAME
# DELETE ALL deployments|pods|services
kubectl delete pods --all
# DELETE deployment 
kubectl delete deployment NAME
kubectl delete deployments --all
# Get logs from specific container
kubectl logs client-deployment-f97bc8fb6-7lqlz
# Launch SHELL @ specified container
kubectl exec -it client-deployment-f97bc8fb6-7lqlz sh

# K8s Dashboard (Web UI)
# Manually install (if not already)
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
# Access @
https://$_K8S_MASTER_IP/ui

# Get password; browser may require 
kubectl config view
```
 
```powershell
$ kubectl get storageclass
NAME                 PROVISIONER                AGE
standard (default)   k8s.io/minikube-hostpath   4d  
# 'minikube-hostpath' is host machine storage, e.g., SSD|HDD
# stanard changes per host; e.g., EBS @ AWS
$ kubectl describe storageclass  # lots of details
```

## [PowerShell](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/try-hyper-v-powershell) [ Hyper-V commands](https://docs.microsoft.com/en-us/powershell/module/hyper-v/?view=win10-ps "docs.microsoft.com/.../hyper-v/... 2016")

```powershell
# Turn off Minikube VM (only -TurnOff works)
Stop-VM -Name minikube           # data is saved 
Stop-VM -Name minikube -Force    # data may be lost
Stop-VM -Name minikube -TurnOff  # data is lost

# disable dynamic memory, set static size
Set-VMMemory "minikube" -DynamicMemoryEnabled $false -StartupBytes 2GB 
# Get VM memory size (see Vmmem.exe @ TaskManager)
Get-VMMemory "minikube"

# External Virtual Switch
New-VMSwitch -name "External-GbE" -NetAdapterName "GbE" -AllowManagementOS $true  
# Internal Virtual Switch
New-VMSwitch -name "DockerNAT" -SwitchType Internal  
# Private Virtual Switch
New-VMSwitch -name "PrivateSwitch" -SwitchType Private  

# Get IP of "minikube" VM, from Hyper-V
(( Hyper-V\Get-VM minikube ).networkadapters[0]).ipaddresses[0]
```

## Configuration Files (`config.json`)

### `minikube` Command Parameters  
@ [~/.minikube/config/](file:///C:/HOME/.minikube/config/config.json)   


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

- [List of __All__ configurable settings (__keys__)](https://github.com/kubernetes/minikube/blob/master/cmd/minikube/cmd/config/config.go "config.go #46")

### Minikube VM Profile  
@ [~/.minikube/profiles/minikube/](file:///C:/HOME/.minikube/profiles/minikube/config.json)  



### &nbsp;