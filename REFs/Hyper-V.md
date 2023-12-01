# [Hyper-V on Windows 10](https:docs.microsoft.com/en-us/virtualization/hyper-v-on-windows "docs.microsoft.com, 2016")

## TL;DR 

### HOWTO : Create a machine that runs *any Linux distro*:

1. @ GUI Menu > New >  
  Use defaults lest specified here,  
  and click "Next" button as apropos ...
    - "Name:"
    - "Store the virtual machine in a different location" 
        - "Location:" Select a machines-parent folder
    - "Generation 2" (Select)
    - "Connection:" External* (Whatever its name)
    - "Create a virtual hard disk"
        - "Name:" h1.vdx
        - "Location:" ...
        - "Size:" 8GB okay
    - "Install an operating system later" (Select)
        - ___This is what allows us to opt out___ of Microsoft's OS restrictions. 
          That (Secure Boot) opt-out is not available until *after* VM creation.
    - "Finish"
1. Right-click on the machine after it's created
    - "Settings ..."
        - "Security"
            - "Enable Secure Boot" (***Deselect***)
                - This is Microsoft's gatekeeper. 
                  If selected (checked), 
                  it prevents installation of any OS 
                  except a tiny Microsoft-restricted subset.
        - "SCSI Controller";  
        to add/mount the ISO file containing our target OS.
            - "DVD Drive" > "Add"
                - "SCSI Controller"
                    - "Location:" 2
                        - Or whatever is NOT "&hellip; (in use)"
                    - "Image file:"
                        - Browse to ISO path: `jammy-live-server-amd64.iso`  
                        See [Ubuntu 22.04.3 LTS (Jammy Jellyfish) Daily Build](https://cdimage.ubuntu.com/jammy/daily-live/current/) 
        - "Apply"
1. @ GUI > Select the machine > Right Click
    - "Start"
    - "Connect ..."
        - Install the OS per CLI menu or whatever. 
        - Reboot
1. @ GUI > Select the machine > Rigth Click
    - "Settings ..."
        - "SCSI Controller"
            - "DVD Drive" 
                - "Remove"
    - "Connect ..."
        - Login  @ CLI
            - Get this guest-machine's IP address (for SSH access from WSL): 
              from command "`ip -4 route`". See `eth0 ... src ... <THIS_IP_ADDRESS>`.

### HOWTO : SSH into the VM

Working from a shell at your real machine:

1. SSH PKI Setup (one time)
```bash
# IP acquired at host (VM) session : `ip -4 route`
host='192.168.0.68'
# Scan/Print fingerprint(s) (FPR) of host's key(s)
ssh-keyscan $host 2> /dev/null | ssh-keygen -lf -
# Push user's public key to host per private-key reference; 
ssh-copy-id -i ~/.ssh/vm_common $host #... and validate FPR; claimed vs. any scanned.
vim ~/.ssh/config #... add this host's configuration 
# Host h1
#     HostName 192.168.0.68
#     User x1
#     IdentityFile ~/.ssh/vm_common
```
1. SSH Session (henceforth)
```bash
ssh h1
```

### [Integration Services](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/reference/integration-services)

See @ GUI Menu > Settings > Integration Services

>&hellip; *services that allow the virtual machine to communicate with the Hyper-V host. Many of these services are conveniences while others can be quite important to the virtual machine's ability to function correctly.*

## [`Enable/Disable` Hyper-V @ PowerShell](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v#enable-hyper-v-using-powershell "docs.microsoft.com") (Requires reboot.) <a name="ps-hyperv"></a>

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

Or by GUI menu/select method @ Windows > "Control Panel" > "Programs and Features" > "Turn Windows features on and off".

## Virtual Switch (VS) :: [Hyper-V Extensible Switch](https://docs.microsoft.com/en-us/windows-hardware/drivers/network/hyper-v-extensible-switch "docs.microsoft.com, 2017")
- `Default Switch` is "Internal", connecting Hyper-V VMs to OS network using NAT. Its setting cannot be modified. It does _not_ show up as an adapter.  

- `v<PHYNAME> (Default Switch)` is an adapter automatically created (upon reboot) by the Default Switch; an unmodifiable, undeletable, Internal VS. `<PHYNAME>` is the name of the physical adapter to which it binds.
    - ISSUE: Whether Enabled or Disabled, a new adapter spawns with each reboot, with the old(er) one(s) "Not connected". These can be deleted using Device Manager.

- `v<PHYNAME> (External Switch)`, the External VS that we create (preferably by PowerShell). There can be only ___one per physical adapter___. It  ___completely takes over___ the _physical adapter_, (e.g., `Intel(R) Ethernet Connection I219-V`; named, e.g., `GbE`), leaving the physical adapter with only two functions (nominally) which are visible under the adapter's "Properties" menu:  
    1. "Microsoft LLDP Protocol Driver" 
    2. "Hyper-V Extensible Virtual Switch"  

    That's _nominally_ because ___these functions change dynamically___; they're controlled by this VS, which adds or removes functionality as necessary to manage the Hyper-V Virtual Machines (VMs).

    The VS attribute/option check-box of "_Allow management operating system to share this network adapter_", even if unselected, will revert back as soon as any `-ManagementOS` type Network Adapter is created on it. The PowerShell VS option regarding this is `-AllowManagementOS $true` .

    __Gateway router__ sees the MAC of this (`External Switch`) adapter as that for its host machine (not that of the physical adapter it binds to), so adjust any "Manually Assigned IP around the DHCP list" there accordingly. At __AsusWRT__, that's under the `LAN - DHCP Server` menu.

### Virtual Network Adapters :: Two Types

1. Attached to VM 
    - `-VMName <NAME>`
1. Attached to OS 
    - `-ManagementOS` 

## [Hyper-V Switches/Adapters @ Powershell](https://docs.microsoft.com/en-us/powershell/module/hyper-v/?view=win10-ps "powershell/hyper-v @ docs.microsoft.com") 

```powershell  
# List of all Hyper-V commands 
Get-Command -Module hyper-v
# List all VS 
Get-VMSwitch
# Add Internal Virtual Switch (auto-installed by Docker for Windows)
New-VMSwitch -Name "vDockerNAT" -SwitchType Internal  
# Add Private Virtual Switch (no need)
New-VMSwitch -Name "vPrivateSwitch" -SwitchType Private   
# Add External Virtual Switch :: NOTE: 
# - One per physical adapter
# - Do NOT use `-SwitchType` option 
# - Even if `-AllowManagementOS` set to false, reverts upon any such adapter addition 
New-VMSwitch -Name "External Switch" -NetAdapterName "Ethernet" -AllowManagementOS $true
# Add Virtural Adapter to External Switch, attached to Windows OS (rather than a VM).
Add-VMNetworkAdapter -Name 'External Switch' -ManagementOS -SwitchName 'External Switch'  
# Rename Adapter
Rename-NetAdapter -InterfaceAlias 'OldName' -NewName "NewName"
# Remove Adapter
Remove-VMNetworkAdapter -ManagementOS -VMNetworkAdapterName 'NAME'

# Synonymous
    -NetAdapterName "Ethernet"
    –InterfaceAlias 'Ethernet'

# Set Metric of Internet-(IP4)-enabled Interface LOWER than that of the others; Set Metric of TAP HIGHER.
Get-NetIPInterface -InterfaceAlias 'vEthernet (External Switch)' | Set-NetIPInterface -InterfaceMetric   2 -PassThru
Get-NetIPInterface -InterfaceAlias 'vEthernet (Default Switch)*' | Set-NetIPInterface -InterfaceMetric 500 -PassThru
Get-NetIPInterface -InterfaceAlias 'vEthernet (Default Switch)*' | Set-NetIPInterface -InterfaceMetric 500 -PassThru

# Alt; Select the Interface (Adapter) per its Index; Get per ...
Get-NetIPInterface  #... then ...
Set-NetIPInterface -InterfaceIndex 19 -InterfaceMetric 100

# Create Adapther @ Default Switch after deleting its auto-generated one.
Add-VMNetworkAdapter -ManagementOS -SwitchName 'Default Switch' -Name 'vRequired(Default Switch)' 
# ... FAILs @ "The automatic Internet Connection Sharing switch cannot be modified."

Get-NetAdapter
Get-VMNetworkAdapter -ManagementOS
Get-VMNetworkAdapter -VMName *
Get-NetRoute | Format-Table -AutoSize

Get-NetIPInterface
# Filter the list 
Get-NetIPInterface -InterfaceAlias 'vEthernet (Default Switch)*'

# Connect to VM 
Connect-VMNetworkAdapter -VMName Test1,Test2 -Name Internet -SwitchName InternetAccess
# Disable Adapter
Disable-NetAdapter -Name 'NAME' -PassThru -Confirm:$false

# DELETE a VS 
Remove-VMSwitch -Name 'NAME'
# Remove Adapter
Remove-VMNetworkAdapter -ManagementOS -VMNetworkAdapterName 'NAME'

# Get Adapter Alias Name 
(Get-NetConnectionProfile -InterfaceAlias 'vEthernet (WHATEVS NAME)').Name
# @ VM
IF((get-vm XYZ).networkadapters.ipaddresses -eq $Null){Write-Host "Problem Found"}
```


### How To Fix @ FUBAR (Virtual) Network Switches/Adapters 

1. Uninstall all adapters @ Device Manager. 
2. Delete all adapter objects using `netcfg`:

    ```shell
    :: Stop Hyper-V service
    net stop vmms 
    :: Delete all virtual adapters
    netcfg -d 
    :: Delete all physical adapters
    netcfg -x 
    ```
    
3. Reboot.

Else, more drastically, toggle ([`Disable`/`Enable`](#ps-hyperv)) the entire Hyper-V feature of Windows.

## [Hyper-V @ Powershell](https://docs.microsoft.com/en-us/powershell/module/hyper-v/?view=win10-ps "powershell/hyper-v @ docs.microsoft.com") | [Quick Start](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/try-hyper-v-powershell "docs.microsoft.com/.../quick-start/... 2016")

```powershell
# List of all Hyper-V commands 
Get-Command -Module hyper-v

Get-VM -Name $VMname            # status
Start-VM -Name $VMname          # start
Suspend-VM -Name $VMname        # pause
Stop-VM -Name $VMname           # stop; unsaved data is saved 
Stop-VM -Name $VMname -Force    # stop; unsaved data may be lost
Stop-VM -Name $VMname -TurnOff  # stop; unsaved data is lost

# Create checkpoint (VM snapshot)
Checkpoint-VM -Name  $VMname -SnapshotName "PreUpdate"
# Apply checkpoint (not NOT same key:val as create)
Restore-VMCheckpoint -Name "PreUpdate" -VMName  $VMname -Confirm:$false

# Disable dynamic memory; set static size
Set-VMMemory $VMname -DynamicMemoryEnabled $false -StartupBytes 2GB 
# Get VM memory size (see Vmmem.exe @ TaskManager)
Get-VMMemory $VMname

# External Virtual Switch (One per physical adapter)
New-VMSwitch -Name "External-Eth" -NetAdapterName "Ethernet" -AllowManagementOS $true  
# Internal Virtual Switch (Required by Docker for Windows)
New-VMSwitch -Name "DockerNAT" -SwitchType Internal  
# Private Virtual Switch (no need)
New-VMSwitch -Name "PrivateSwitch" -SwitchType Private  

Get-NetRoute | Format-Table -AutoSize

# Change metric on Default Switch, so the host OS prefers the physical adapter.
Get-NetIPInterface -InterfaceAlias 'vEthernet (Default Switch)'
Get-NetIPInterface -InterfaceAlias 'vEthernet (Default Switch)' | Set-NetIPInterface -InterfaceMetric 5000 -PassThru

# Get IP of VM, from Hyper-V
(( Hyper-V\Get-VM $VMname ).networkadapters[0]).ipaddresses[0]

# Create/Delete VM
New-VM -Name $VMName            # create VM
Remove-VM -Name $VMname -Force  # delete VM
```

## `docker-machine`

See Docker `REF.*` files

`docker-machine create` &hellip; installs TinyCore (`boot2docker.iso`); distro has package manager `tce-load`.

```bash
docker@h4:~$ tce-load -w -i tor.tcz
```
- Download and install
- [Index of available TinyCore packages](http://distro.ibiblio.org/tinycorelinux/10.x/x86/tcz/)

## [Docker for Windows](file:///D:/1%20Data/IT/Container/Docker/REF.Docker.sh "REF.Docker.sh")  

- Docker CLI Tools @ PowerShell or WSL ([MD](file:///D:/1%20Data/IT/OS/Windows/Win10/WSL/REF.WSL.md "REF.WSL.md") | [HTML](file:///D:/1%20Data/IT/OS/Windows/Win10/WSL/REF.WSL.html "If @ browser")):   
`docker`, `docker-compose`, `docker-machine` 
- Automatically createsVM (`MobyLinuxVM`) @ Hyper-V   

## Minikube (Kubernetes) [MD](file:///D:/1%20Data/IT/Container/Kubernetes/REF.Kubernetes.Install.md "REF.Kubernetes.Install.md") | [HTML](file:///D:/1%20Data/IT/Container/Kubernetes/REF.Kubernetes.Install.html "If @ browser")

- Kubernetes CLI Tools @ PowerShell: `minikube` + `kubectl`  
(`minikube` @ `SystemDrive` only)   

## Vagrant [MD](REF.Vagrant.html "@ browser")
  

## CentOS 7 

- Vagrant box `centos/7`  [MD](file:///D:/1%20Data/IT/Apps/Dev.Ops/CM/Vagrant/REF.Vagrant.md "REF.Vagrant.md") | [HTML](file:///D:/1%20Data/IT/Apps/Dev.Ops/CM/Vagrant/REF.Vagrant.html "If @ browser")
- Generic (distro ISO) [MD](file:///D:/1%20Data/IT/OS/Linux/Distros/CentOS/REF.RHEL.Install.md "REF.RHEL.Install.md") | [HTML](file:///D:/1%20Data/IT/OS/Linux/Distros/CentOS/REF.RHEL.Install.html "If @ browser")   

## Ubuntu 18.04.1 LTS  

- Generic (distro ISO) [MD](file:///D:/1%20Data/IT/OS/Linux/Distros/Ubuntu/REF.Ubuntu.Install.md "REF.Ubuntu.Install.md") | [HTML](file:///D:/1%20Data/IT/OS/Linux/Distros/Ubuntu/REF.Ubuntu.Install.html "If @ browser")   

## Nested Virtualization ([MD](REF.Hyper-V.Nested-Virtualization.md "REF.Nested-Virtualization.md") | [HTML](REF.Hyper-V.Nested-Virtualization.html "@ browser"))  
