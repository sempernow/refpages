# [CentOS 7 on VM @ Hyper-V](https://www.altaro.com/hyper-v/centos-linux-hyper-v/ "altaro.com, 'CentOS Linux on Hyper-V', 2017")
 
- Virtual Machine (VM) Specs 

    - External Virtual Switch, `CentOS-GbE`, created.
    - ISO [CentOS-7 List](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1804.iso "centos.org") | [mirror.vcu.edu](http://mirror.vcu.edu/pub/gnu_linux/centos/7.5.1804/isos/x86_64/ "mirror.vcu.edu") | [torrent](http://mirror.vcu.edu/pub/gnu_linux/centos/7.5.1804/isos/x86_64/CentOS-7-x86_64-Everything-1804.torrent "Drag link to torrent client")  

        `D:\SCRATCH\[NO_SYNCH]\VMs\CentOS\CentOS-7-x86_64-DVD-1804.iso`

    - Generation `2` (VM)

    - `2` vCPUs

    - Dynamic Memory: `512MB`/`256MB`/`1GB` (START/MIN/MAX)

    - VHDX: `40GB` (`42949672960 byte`); `1MB` block size  
    Modified on 1<sup>st</sup> launch @ VM creation. (See PowerShell script).

        ```powershell
        Stop-VM -VM $VMname -Force
        New-VHD -Path $VHDStoragePath -SizeBytes $VHDXSizeBytes -Dynamic -BlockSizeBytes 1MB
        ```
- Create VM @ PowerShell   
[CentOS@Hyper-V.ps1](CentOS@Hyper-V.ps1)

- Start + Connect   
Hyper-V launches a VM window, as the install-media loads. 

## Install CentOS per GUI ([MD](RHEL.Install.html "@ browser"))  

### Hyper-V specific settings ...
- Installation Destination 
    - Local Standard Disks  
        `40 GiB`   
        `Msft Virtual Disk`  
        `sda / 2014.5 KiB free`   

        - per VM config @ [CentOS@Hyper-V.ps1](CentOS@Hyper-V.ps1)


- Software Selection  
    - Base Environment  
        - __Virtualization Host__
    - Add-Ons  
        - Network File System Client
        - Virtualization Platform 
        - Development Tools 
        - System Administration Tools 

- Security Policy  
    - "Standard __Docker Host__ Security Profile"

### Admin

#### [SSH](Network.SSH.sh "Network.SSH.sh") setup
- @ CentOS (VM)   

    ```bash
    # Config client (user acct)
    mkdir ~/.ssh 
    chmod 700 ~/.ssh
    touch ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys

    # Config server (sshd)
    sudo vim /etc/ssh/sshd_config
    PubkeyAuthentication yes
    # required by ssh-copy-id (to receive pub key):
    PasswordAuthentication yes
    ```
    - `ssh ...` Pubkey login WILL FAIL if owner|perms|SELinux-context is wrong.  
    Debug login issues:
        ```
        ls -ZA ~/.ssh
        systemctl status sshd -l     
        grep AVC /var/log/{secure,audit.log}
        ``` 

- @ host  

    - Create key-pair; send public key to VM.

        ```bash 
        # Generate key pair 
        ssh-keygen -t ed25519 -a 100  
        # ... prompts for save-path & passphrase 
        # Send newly generated pub key to VM user acct @ ~/.ssh/authorized_keys
        ssh-copy-id -i $_ID_FILE $_USER@$_VM
        # ... prompts for password
        ```

        - Sending the key requires `PasswordAuth...` enabled @ `sshd_config` .   
        Disable that afterward (at VM) to better secure.

    - Add [identity @ `~/.ssh/config`](file:///S:/HOME/.ssh/config)

        ```bash
        Host $_VM 
          HostName 192.168.1.10 # IP or HOST.DOMAIN
          User $_USER
          CheckHostIP yes
          IdentityFile ~/.ssh/centosvm_ed25519
        ``` 

        - Note that "Host" here is the VM, not the host accessing it.   
        And "Host" _name_ (`$_VM`) has no meaning beyond this SSH tool;   
        can be any name; is merely the SSH configuration reference.  

#### SSH access (thereafter)

- `ssh $_VM`, or override User with `$_USER@$_VM`.  
        Either one references this configuration. 

    - Sessions (concurrent)    
    `tty1` @ first connect (terminal 1).  
    `tty2`-`tty6` (Up @ `Alt+RightArrow`; Down @ `Alt  +LeftArrow`)  
    `tty` to see current terminal number.  
        - `Alt+Arrows` work only @ Hyper-V > Connect, __not__ @ any external console (`cmd.exe`, PowerShell, WSL, ConEmu, or `mintty`).

#### Backup `/home` 

- @ VM

    ```bash
    cd /home
    sudo tar -caf /home/$USER.tgz -C /home $USER
    ```

- @ host 

    ```bash
    rsync -auz root@$_VM:/home/$_USER.tgz ~/etc/platforms/$_VM/$_USER.tgz
    ```

#### Update home 

- @ host

    ```bash
    # .tgz selected files and folders @ ~
    find ~ -maxdepth 1 \( \
        -name 'etc' \
        -o -name '.passgo' \
        -o -name '.bash*' \
        \) | tar -caf updates.tgz --files-from -
    # push the .tgz
    rsync -auz updates.tgz $_USER@$_VM:/home/$_USER/updates.tgz
    ```

#### Enable Dynamic Memory In-Guest  
@ `/etc/udev/rules.d/100-balloon.rules` (create)  
`SUBSYSTEM=="memory", ACTION=="add", ATTR{state}="online"`

- No; removed it; perhaps unnecessary @ Gen 2 Hyper-V

- Install Extra Hyper-V Tools  
`yum install -y hyperv-daemons`

- Disable CentOS Disk I/O Scheduler (Hyper-V handles optimization) 

    ```bash
    su root 
    cat /sys/block/sda/queue/scheduler
    noop [deadline] cfq
    echo noop > /sys/block/sda/queue/scheduler
    cat /sys/block/sda/queue/scheduler
    [noop] deadline cfq
    exit
    ```

#### Other install/search 

```bash
su
yum check-update
yum update
# EPEL [Extra Packages for Enterprise Linux]  https://fedoraproject.org/wiki/EPEL
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# And to better handle dependencies (though does not work @ Hyper-V, nor containers):
#subscription-manager repos --enable "rhel-*-optional-rpms" --enable "rhel-*-extras-rpms"
yum list installed | grep hyperv 
yum list install httpd 
shutdown now     # poweroff
shutdown -r now  # reboot 
reboot           # works too
```

```bash
# Install VS Code
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

yum check-update
sudo yum install code
```
