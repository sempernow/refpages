# CentOS 7  Install 
### on VM @ Hyper-V ([MD](RHEL.CentOS@Hyper-V.html "If @ browser"))

## per GUI 

The pre-installation __menu/selection__ scheme is a __star pattern__, not sequenial. Select/click a category from the menu, set the parameters therein, then "Done" (button) back to the main menu, to select another category. __Do not advance__ from that one page ("Begin" button) until satisfied with the settings within each and every category on that menu:

- Installation Source  
    - Auto-detected installation media 
        - Device: `sr0`  
        - Label: `CentOS_7_x86_64` 

- Installation Destination 
    - Local Standard Disks  
        `40 GiB`   
        `... `   
        `sda / 2014.5 KiB free`   

        - E.g., per VM config @ [CentOS@Hyper-V.ps1](CentOS@Hyper-V.ps1)

- Network   
    - Ethernet (`eth0`)
    - Host name: `HOSTNAME.LANDOMAIN`  
    
    All else defaults:  

    ```
              MAC: 00:15:5D:4E:BB:32  
            Speed: 1000 Mb/s   
       IP Address: 192.168.1.10   
      Subnet Mask: 255.255.255.0   
    Default Route: 192.168.1.1   
              DNS: 192.168.1.1   
    ```          

- Software Selection  
    - Base Environment  
        - __Server with GUI__  
        (or whatever)
    - Add-Ons  
        - Network File System Client
        - Virtualization Platform 
        - Development Tools 
        - System Administration Tools 

- Security Policy  
    - "Standard __Docker Host__ Security Profile"   
    (or whatever)

### Configure User Settings 
- Root Password
- User Creation
    - Name  
    - Password 
    - "__Make this user Administrator__" (__check-box__)   
    Else per `root` acct login; add the user to `wheel` group:  
    `usermod -aG wheel TARGET_USERNAME`

### Admin

#### [SSH](Network.SSH.sh "Network.SSH.sh") setup  
- @ Server (CentOS)  
    Enable remote access per SSH public-key.

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

- @ Client (Remote machine)  

    - Create key-pair; send public key to host (CentOS machine).

        ```bash 
        # Generate key pair 
        ssh-keygen -t ed25519 -a 100  
        # ... prompts for save-path & passphrase 
        # Send newly generated pub key to host user acct @ ~/.ssh/authorized_keys
        ssh-copy-id -i $_ID_FILE $_USER@$_HOST_IP_or_HOST_dot_DOMAIN
        # ... prompts for password
        ```

        - Sending the key requires `PasswordAuth...` enabled @ `sshd_config` .   
        Disable that afterward (at server; CentOS) to better secure.

    - Add [identity @ `~/.ssh/config`](file:///S:/HOME/.ssh/config)

        ```bash
        Host $_HOST
          HostName $_HOST_IP_or_HOST_dot_DOMAIN
          User $_USER
          CheckHostIP yes
          IdentityFile ~/.ssh/centosvm_ed25519
        ```

#### SSH access (thereafter)
- `ssh $_HOST`, or override User with `$_USER@$_HOST`.  
        Either one references this configuration. Note "Host" name   
        has no meaning beyond this SSH tool; can be any name;   
        is merely the SSH configuration reference.  

    - Sessions (concurrent)    
    `tty1` @ first connect (terminal 1).  
    `tty2`-`tty6` (Up @ `Alt+RightArrow`; Down @ `Alt  +LeftArrow`)  
    `tty` to see current terminal number.  

#### Backup `/home` 

- @ CentOS

    ```bash
    cd /home
    sudo tar -caf /home/$USER.tgz -C /home $USER
    ```
### Backup `/home` to `~/etc/platforms/$_HOST/`
- @ Remote 

    ```bash
    rsync -auz root@$_HOST:/home/$_USER.tgz ~/etc/platforms/$_HOST/$_USER.tgz
    ```

#### Update home 

- @ Remote

    ```bash
    # .tgz selected files and folders @ ~
    find ~ -maxdepth 1 \( \
        -name 'etc' \
        -o -name '.passgo' \
        -o -name '.bash*' \
        \) | tar -caf updates.tgz --files-from -
    # push the .tgz
    rsync -auz updates.tgz $_USER@$_HOST_:/home/$_USER/updates.tgz
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
