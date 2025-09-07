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
- `Default Switch` is "Internal", connecting Hyper-V VMs to OS network using NAT, though it may use WSL2 network instead, and may switch from WSL to host subnet subesquently. Its setting cannot be modified. It does _not_ show up as an adapter.

- `v<PHYNAME> (Default Switch)` is an adapter automatically created (upon reboot) by the Default Switch; an unmodifiable, undeletable, Internal VS. `<PHYNAME>` is the name of the physical adapter to which it binds.
    - ISSUE: Whether Enabled or Disabled, a new adapter spawns with each reboot, with the old(er) one(s) "Not connected". These can be deleted using Device Manager.
        - UPDATE: On Windows 11, this may or may not exist.

- `v<PHYNAME> (External Switch)`, the External VS that we create (preferably by PowerShell). Binds to ___one physical adapter___. It  ___completely takes over___ the _physical adapter_, (e.g., `Intel(R) Ethernet Connection I219-V`; named, e.g., `Eth2`), leaving the physical adapter with only two functions (nominally) which are visible under the adapter's "Properties" menu:  
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
New-VMSwitch -Name "External Switch" -NetAdapterName "vEth1" -AllowManagementOS $true
# Add Virtural Adapter to External Switch, attached to Windows OS (rather than a VM).
Add-VMNetworkAdapter -Name 'External Switch' -ManagementOS -SwitchName 'External Switch'  
# Rename Adapter
Rename-NetAdapter -InterfaceAlias 'OldName' -NewName "NewName"
# Remove Adapter
Remove-VMNetworkAdapter -ManagementOS -VMNetworkAdapterName 'NAME'

# Synonymous
    -NetAdapterName "Eth1"
    –InterfaceAlias 'Eth1'

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

Route from WSL to Eth1 or whatever to Gateway router is handled by Windows internally via NAT, 
and so is not visible here:

```powershell
Get-NetRoute | Where-Object { $_.InterfaceAlias -eq "$ethWsl"} | Select-Object DestinationPrefix,NextHop,RouteMetric
```
```plaintext
DestinationPrefix             NextHop RouteMetric
-----------------             ------- -----------
255.255.255.255/32            0.0.0.0         256
224.0.0.0/4                   0.0.0.0         256
172.27.255.255/32             0.0.0.0         256
172.27.240.1/32               0.0.0.0         256
172.27.240.0/20               0.0.0.0         256
ff00::/8                      ::              256
fe80::17cc:f1e1:ece4:7f71/128 ::              256
fe80::/64                     ::              256

```

```bash
☩ ip -4 -brief addr show dev eth0
eth0             UP             172.27.240.169/20
```

### DNS 

WSL2 [__DNS is handled through a "stub" DNS server__](https://chatgpt.com/share/672e8f14-feec-8009-86c7-cd6bea539373 "ChatGPT"), usually configured with an IP like `10.255.255.254`, which is non-standard for typical DNS servers. This stub server acts as an intermediary to forward DNS queries from WSL2 to the Windows host’s DNS resolver:

```bash
☩ cat /etc/resolv.conf
# This file was automatically generated by WSL. To stop automatic generation of this file, add the following entry to /etc/wsl.conf:
# [network]
# generateResolvConf = false
nameserver 10.255.255.254
search SEMPERLAN hsd1.md.comcast.net
```
```bash
☩ nslookup google.com
Server:         10.255.255.254
Address:        10.255.255.254#53

Non-authoritative answer:
Name:   google.com
Address: 172.253.122.102
...
```

Changes to `/etc/resolv.conf` do not persist, even disabling in `wsl.exe` by:

```ini
[network]
generateResolvConf = false
```

Unless the link is removed:

```bash
☩ ls /etc/resolv.conf
lrwxrwxrwx 1 root root 16 Nov  8 16:36 /etc/resolv.conf -> /wsl/resolv.conf
```

So, remove that link, then recreate the file having the desired DNS nameservers:

```bash
dns1=192.168.28.1 # Gateway router
dns2=8.8.8.8      # Google
sudo unlink /etc/resolv.conf
cat <<EOH |sudo tee /etc/resolv.conf
nameserver $dns1
nameserver $dns2 
nameserver fec0:0:0:ffff::1
nameserver fec0:0:0:ffff::2
nameserver fec0:0:0:ffff::3
EOH

```
- Use the IPv6 DNS nameservers, 
which are automatically assigned by Windows for WSL, 
reported by PowerShell's `Get-DnsClientServerAddress` command:

```powershell
$ethWsl = (Get-NetAdapter -includehidden| Where-Object { $_.Name -like "vEthernet (WSL*" }).Name 
Get-DnsClientServerAddress -InterfaceAlias "$ethWsl"
```
- Windows 11 WSL2's default adapter name is "`vEthernet (WSL (Hyper-V firewall))`".

That method of resetting DNS is an override at the Linux distro, 
so PowerShell still reports the IPv6-only DNS settings.

To reset DNS via PowerShell. 


```powershell
$ethWsl = (Get-NetAdapter -includehidden| Where-Object { $_.Name -like "vEthernet (WSL*" }).Name # vEthernet (WSL (Hyper-V firewall))

# Set DNS nameserver 
$dns1 = 192.168.28.1 # Gateway router
$dns2 = 8.8.8.8      # Google
Set-DnsClientServerAddress -InterfaceAlias "$ethWsl" -ServerAddresses ($dns1, $dns2)
```
- This alone may not work, as there are automated OS-level processes managing WSL2 networking. 
  Our results have varied, even under the same OS installation.

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

See Docker `*` files

`docker-machine create` &hellip; installs TinyCore (`boot2docker.iso`); distro has package manager `tce-load`.

```bash
docker@h4:~$ tce-load -w -i tor.tcz
```
- Download and install
- [Index of available TinyCore packages](http://distro.ibiblio.org/tinycorelinux/10.x/x86/tcz/)

## [Docker for Windows](file:///D:/1%20Data/IT/Container/Docker/Docker.sh "Docker.sh")  

- Docker CLI Tools @ PowerShell or WSL ([MD](file:///D:/1%20Data/IT/OS/Windows/Win10/WSL/WSL.md "WSL.md") | [HTML](file:///D:/1%20Data/IT/OS/Windows/Win10/WSL/WSL.html "If @ browser")):   
`docker`, `docker-compose`, `docker-machine` 
- Automatically createsVM (`MobyLinuxVM`) @ Hyper-V   

## Minikube (Kubernetes) [MD](file:///D:/1%20Data/IT/Container/Kubernetes/Kubernetes.Install.md "Kubernetes.Install.md") | [HTML](file:///D:/1%20Data/IT/Container/Kubernetes/Kubernetes.Install.html "If @ browser")

- Kubernetes CLI Tools @ PowerShell: `minikube` + `kubectl`  
(`minikube` @ `SystemDrive` only)   

## Vagrant [MD](Vagrant.html "@ browser")
  

## CentOS 7 

- Vagrant box `centos/7`  [MD](file:///D:/1%20Data/IT/Apps/Dev.Ops/CM/Vagrant/Vagrant.md "Vagrant.md") | [HTML](file:///D:/1%20Data/IT/Apps/Dev.Ops/CM/Vagrant/Vagrant.html "If @ browser")
- Generic (distro ISO) [MD](file:///D:/1%20Data/IT/OS/Linux/Distros/CentOS/RHEL.Install.md "RHEL.Install.md") | [HTML](file:///D:/1%20Data/IT/OS/Linux/Distros/CentOS/RHEL.Install.html "If @ browser")   

## Ubuntu 18.04.1 LTS  

- Generic (distro ISO) [MD](file:///D:/1%20Data/IT/OS/Linux/Distros/Ubuntu/Ubuntu.Install.md "Ubuntu.Install.md") | [HTML](file:///D:/1%20Data/IT/OS/Linux/Distros/Ubuntu/Ubuntu.Install.html "If @ browser")   

## Nested Virtualization ([MD](Hyper-V.Nested-Virtualization.md "Nested-Virtualization.md") | [HTML](Hyper-V.Nested-Virtualization.html "@ browser"))  
