# [VirtualBox 7](https://www.virtualbox.org/ "VirtualBox.org") | [HOWTOs](https://www.virtualbox.org/wiki/User_HOWTOS) | [User Manual](https://www.virtualbox.org/manual/)

## [Install](https://www.virtualbox.org/wiki/Downloads "VirtualBox.org :: Downloads")

### @ Windows 

```powershell
chocolatey install virtualbox
```

Else use their [installer](https://www.virtualbox.org/wiki/Downloads "VirtualBox.org : Downloads")

### @ Ubuntu
```bash
sudo apt-get -y install virtualbox
```

### @ [@ RHEL/CentOS](https://www.virtualbox.org/wiki/Linux_Downloads)  

```bash 
# Download/Import its public key
sudo rpm --import https://www.virtualbox.org/download/oracle_vbox.asc
# Download/Install VirtualBox 5.5.20 (.rpm) 
sudo yum install -y \
    https://download.virtualbox.org/virtualbox/5.2.20/VirtualBox-5.2-5.2.20_125813_el7-1.x86_64.rpm  
```
- Fails if Linux @ VM on Hyper-V  ([MD](Hyper-V.Nested-Virtualization.html "@ browser"))  

    ```bash
    There were problems setting up VirtualBox.  
    To re-start the set-up process, run
      /sbin/vboxconfig  
    # ... did, as root, to same/repeated effect.
    ```

## [Networking Modes](https://www.virtualbox.org/manual/ch06.html#networkingmodes)

Manually set @ VirtualBox menu > Settings : `NAT` or `Host-only Adapter`

### Network Mode : Host-only Adapter

Use for host-to-guest (WSL to VMs) and guest-to-guest (VM to VM) connectivity.

>*&hellip; VirtualBox creates a (virtual) loopback interface on the host  &hellip; used to create a network containing the host and a set of virtual machines, without the need for the host's physical network interface.*

```bash
# Get VM's IP CIDR per VirtualBox DHCP (File > Tools > Network Manager)
# Get VM IP of VM from VM : `ip -4 route` (src ...)
host='192.168.56.101'

ssh -i ~/.ssh/vm02 $user@$host
```

### Network Mode : NAT

Use for standalone VMs requiring nothing more than web connectivity.
Not as useful for inter-vm comms. 

>*VirtualBox VMs are on separate network, but can use local-port forwarding through WWSL nameserver.*

```bash
# @ VM Creation
user=x1 
# @ /etc/resolv.conf
wsl_nameserver='172.31.16.1'
host_port=2222

ssh -p $host_port ${user}@$wsl_nameserver
```
- Port Forwarding Rules
    - Host (Windows) Port : 2222
    - Guest (VM) Port : 22

## PKI Setup

```bash
keyname=vm02

ssh-keygen -f ~/.ssh/$keyname
ssh-copy-id -i ~/.ssh/$keyname $user@$host

# Session:
ssh -i ~/.ssh/vm02 $user@$host
```

@ `~/.ssh/config`

```text
Host vm02
    HostName 192.168.56.101
    User x1
    IdentityFile ~/.ssh/vm02

Host github github.com
    HostName github.com
    User git
    RequestTTY no
    IdentityFile ~/.ssh/github_sempernow
```

So, simply

```bash
# Session:
ssh vm02
```


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

