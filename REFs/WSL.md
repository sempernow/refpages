# [WSL](https://learn.microsoft.com/en-us/windows/wsl/) : Windows Subsystem for Linux

## [Install](https://learn.microsoft.com/en-us/windows/wsl/install)

```powershell
PS> wsl --install
```
- This BREAKS Docker Desktop, but that app is not needed at WSL2. 
  Rather install Docker (server/client),
  or whatever other container handler you prefer,
directly onto the WSL2 distro.

Install a distro either from Microsoft Store, 
or direcly from PS or CMD command line using `wsl` utility:

```powershell
# List all distros available for installation
wsl --list --online 
# Install a distro
wsl --install openSUSE-Leap-15.5
# List installed distros
wsl --list --verbose
# Set a default distro
wsl --set-default Ubuntu-22.04
# Launch default distro
wsl
```

### Configure a WSL2 distro 

1. Edit `/etc/wsl.conf` to configure mount points as `/<DRIVE>` instead of `/mnt/<DRIVE>` .  
    ```plaintext
    [boot]
    systemd=true

    [automount]
    root = /
    options = "metadata,umask=22,fmask=11"
    ```
    - To take effect, must close WSL terminal, then run `wsl --shutdown` from CMD or PS. Then okay.
    - Verify using `df -hT` that mount points at new WSL terminal are, e.g., `/c` instead of `/mnt/c`
        - If that doesn't work, use the `/etc/fstab` method
1. Edit `/etc/passwd` to change user's home dir to our common `$HOME`, e.g., `/c/HOME` 
    - Requires effects of prior step, which require WSL restart, with "`wsl --shutdown`" being the first step.
    - Also mod `root` user's home dir entry at `/etc/passwd`, setting it to that common `$HOME`, 
      so "`sudo su`" invokes the same bash config scripts.


## Configuration | [Advanced Settings](https://learn.microsoft.com/en-us/windows/wsl/wsl-config) 

UPDATE: No longer necessary. Configure only `/etc/wsl.conf` . See below.

- `/etc/wsl.conf` (per distro)
- `~/.wslconfig` (global; WSL 2 only)
- `/etc/fstab` 
    ```conf
    #DEVICE|FS          MOUNT           TYPE    OPTIONS                                         DUMP    PASS
    #//RT-AC66U/etc     /media/share    drvfs   binary,noacl                                    0       0
    #/c/HOME            /home/x1        drvfs   binary,noacl                                    0       0
    #D:                 /d              drvfs   binary,noacl                                    0       0
    D:                  /d              drvfs   defaults,uid=1000,gid=1000,fmask=11,umask=22    0       0
    ```
    - `D:` is an encrypted volume mounted after user login. 
    Regardless of `uid` and `gid` values there
    (`1000` is `$USER` of the WSL2 distro), 
    `fmask=11` and `umask=22` must also be set, 
    else `OWNER:GROUP` of all files thereunder are `root:root` 
    and unchangeable even by "`sudo chown ...`".
    and user may not even have read access on some files.

>WSL mounts some `drvfs` as `type 9p`, which indicates a Windows server using 9P protocol. 
>This is seen at output of `mount` command.

## WSL 2

### Distros

Installed 

```powershell
wsl -l -v
```

Available online

```powershell
wsl --list --online
```

[Import ANY (custom) Linux Distro per Tarball](https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro)

### WSL2 Host IP is NOT `localhost`

See:

```bash
$ cat /etc/resolv.conf
```
- E.g., `nameserver 172.29.144.1`

LAN IP v. WSL2 Host IP

```bash
$ ip -4 addr show dev eth0
5: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    inet 172.29.148.53/20 brd 172.29.159.255 scope global eth0
       valid_lft forever preferred_lft forever

$ ip route
default via 172.29.144.1 dev eth0
172.29.144.0/20 dev eth0 proto kernel scope link src 172.29.148.53
```

### [Fix GUI programs @ WSL 2](https://stackoverflow.com/questions/61860208/running-graphical-linux-desktop-applications-from-wsl-2-error-e233-cannot-op "StackOverflow.com 2021")

On errors of display or clipboard/copy, 
e.g., `... couldn't connect to display:0`, 
set the `DISPLAY` environment variable to :
`WSL_HOST_IP:0.0`

```bash 
export DISPLAY=$(grep nameserver /etc/resolv.conf |awk '{print $2}'):0.0
```
- `DISPLAY=172.29.144.1:0.0`

## [Commands](https://learn.microsoft.com/en-us/windows/wsl/basic-commands?source=recommendations)

- [Verify/Test  the WSL version (per distro)](https://askubuntu.com/questions/1177729/wsl-am-i-running-version-1-or-version-2 "Sep 2019 @ askubuntu.com")
    ```shell
    > wsl.exe --list --verbose
      NAME                   STATE           VERSION
      * Ubuntu-18.04         Running         2
      openSUSE-Leap-15.2     Running         2
      kali-linux             Stopped         1
      docker-desktop-data    Running         2
      Alpine                 Stopped         1
      Debian                 Stopped         1
      docker-desktop         Running         2
      Fedora                 Stopped         2
    ```
    - Or `wsl -l -v`
- Set WSL 2 as the default WSL version
    ```shell
    > wsl.exe --set-default-version 2
    ```
- Switch a distro from WSL 1 to WSL 2 (or back from 2 to 1)
    ```shell
    > wsl.exe --set-version %DISTRO_NAME% 2
    ```
    - List installed distros 
        ```shell
        > wsl.exe --list 
        ```
- Select Distro 
    ```shell
    > wsl -d %DISTRO_NAME%
    ```

### ~~[WSL 2 Issues](https://www.digitalocean.com/community/posts/trying-the-new-wsl-2-its-fast-windows-subsystem-for-linux "2020 Notes @ DigitalOcean.com"):~~ (OBSOLETE)

1. ~~Filesystem (FS); very ___slow FS transfers___ between Win and Linux.~~
    - Transfer/synch everything to the (linux) FS equivalent (per distro?).
1. ~~Networking; no `localhost`; IP Addresses only.~~
    - `localhost:3000` would be, e.g., `192.168.28.2:3000`

## Reset/Uninstall a distro

```bat
wsl.exe --unregister DISTRO_NAME
```



## `/etc/fstab` Mod(s)

This may not be necessary, depending on Windows 10/11 update status.

Want mount points `/<DRIVE>` instead of `/mnt/<DRIVE>`


Persistently mount the desired `HOME` 
to `/home/$USER` per `/etc/fstab` entry.

```bash
sudo vim /etc/fstab
```
```text
/c/HOME /home/x1 drvfs binary,noacl 0 0
```

Prior method:

```bash
vim /etc/passwd             # 2. Edit ...
# ... change home dir of user (NOT root) to, e.g., /c/HOME
# ... save (ZZ)
vim /root/.bashrc           # 3. Edit/Add ...
    [[ -d '/mnt/c/HOME' ]] && export HOME='/mnt/c/HOME'
    [[ -d '/c/HOME' ]] && export HOME='/c/HOME'
    [[ "$HOME" != '/root' ]] && source $HOME/.bashrc
# ... save (ZZ)
```
@ ONCE @ our global `$HOME` 
```bash
vim ~/.bash_profile     # 4. Edit/Add ...
# Bash on Windows improperly sets `umask` to 0000; should be 0022.
# https://www.turek.dev/post/fix-wsl-file-permissions/ 
# Only @ WSL @ ConEMU; @ WSLtty, `umask` is 0022
[[ "$(umask)" == "0000" ]] && umask 0022
# ... save (ZZ)
```
- [Advanced Settings](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)

## Pkgs

```bash
# Ubuntu/Debian
sudo apt update
sudo apt-get install vim screenfetch
```

### __Fix__ GPG Key __fail__ @ `sudo apt update`

```bash
sudo apt update  # ... fails with ERR msg: 
# "signatures couldn't be verified because the public key is not available: NO_PUBKEY 5523BAEEB01FA116"

# Note & set the pubkey (5523BAEEB01FA116) ...
_PUBKEY='5523BAEEB01FA116'

# Fetch and install it ...
curl -sL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${_PUBKEY}" \
    | sudo apt-key add
    
sudo apt udpate  # ... should work now
```

- If @ VScode issue ...  

    ```bash
    curl 'https://packages.microsoft.com/keys/microsoft.asc' | gpg --dearmor > 'microsoft.gpg'
    sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    # or ???
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" \
        > /etc/apt/sources.list.d/vscode.list'
    ```

[Fixing GPG Keys in Ubuntu](http://naveenubuntu.blogspot.com/2011/08/fixing-gpg-keys-in-ubuntu.html) (2011)  

```bash
sudo apt-key adv --keyserver ha.pool.sks-keyservers.net \
    --recv-keys ${_PUBKEY}
```

```
$ screenfetch
         _,met$$$$$gg.           f06y@XPC
      ,g$$$$$$$$$$$$$$$P.        OS: Debian
    ,g$$P""       """Y$$.".      Kernel: x86_64 Linux 4.4.0-17134-Microsoft
   ,$$P'              `$$$.      Uptime: 4m
  ',$$P       ,ggs.     `$$b:    Packages: 333
  `d$$'     ,$P"'   .    $$$     Shell: bash l -i
   $$P      d$'     ,    $$P     WM: Not Found
   $$:      $$.   -    ,d$$'     CPU: Intel Core i5-7400T CPU @ 2.4GHz
   $$\;      Y$b._   _,d$P'      RAM: 8433MiB / 15319MiB
   ...
```

## [Usage](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)  

- Equivalents ...  
    ````bat
    wsl.exe
    bash.exe  
    <distro>.exe
    ````

    ````bat
    wsl.exe 
    wsl [command]
    :: OR 
    bash.exe
    bash -c [command]
    :: OR
    debian.exe /?  :: show available commands (per distro-name) 
    debian.exe     :: launches distro @ CURRENT SHELL ...  
    $  
    ````
- Change default user (per distro) 
    ````bat
    :: set to root
    > debian.exe config --default-user root
    :: restore ... 
    > debian.exe config --default-user $USERNAME
    ````

- [Interoperability](https://docs.microsoft.com/en-us/windows/wsl/interop) 

    - Run __Linux command__ (binary) from Windows command line

        ````bat
        > wsl COMMAND    
        ````

    - Run __bash script__ from Windows command line  

        ```bat
        > wsl bash -c '~/.bin/foo.sh arg1 arg2 ...'
        ```

    - Run Windows tools (`.exe`) from WSL

        ```bash
        $ notepad.exe
        $ ipconfig.exe | grep IPv4 | cut -d: -f2
        ```

        - Does ___not___ work at root user ___unless root is set to the default user___. 
        - Same permission rights.

    - Mix the two; `cmd` and `bash` 
        ```shell
        > dir | wsl grep foo  
        ```

    - Copy/Paste per `CTRL+C/V`, or mouse commands

    - [Share Environment Variables](https://blogs.msdn.microsoft.com/commandline/2017/12/22/share-environment-vars-between-wsl-and-windows/) per `WSLENV` 
    
        ```bash
        WSLENV=GOPATH/l:USERPROFILE/w:SOMEVAR/wp

        /p  # translate paths btwn WSL and Win32
        /l  # if var is colon-delimited list of paths
        /u  # only include when invoking WSL from Win32
        /w  # only include when invoking Win32 from WSL.
        ```  

        - `PATH` environment variable is ___automatically shared___ between Windows and WSL, so _needn't bother with_ `WSLENV`.

    - Mount (removable) `NTFS` volume 

        ```bash  
        # Mount removable media: (e.g. G:)
        sudo mkdir /mnt/g
        sudo mount -t drvfs G: /g

        # Unmount
        sudo umount /g
        ```
    - Mount (`SMB`) network share (sans `smbfs`)
        ```bash
        # Mount network share 
        sudo mount -t drvfs //RT-AC66U/etc /media/share
        ```
        - Mount point (`/media/share`) must exist. 
        - WSL uses [DriveFs](https://blogs.msdn.microsoft.com/wsl/2016/06/15/wsl-file-system-support/ "microsoft.com 2016") for such interoperability.
- Admin   

    ````bash
    $ sudo su  # MUST use; 'su' FAILs 

    # $HOME dir CHANGE; default is /home/$USERNAME
    $ sudo vim /etc/passwd  # E.g., from `/home/uZer` to `/mnt/s/HOME`
    # ... edit @ username, then reboot

    # Reset Password
    $ passwd username
    $ exit
    ````

##  [Distro Management](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)  

### `wslconfig.exe`  
Manage any installed Linux distro(s)    

````
wslconfig /list [/all]  
wslconfig /unregister <DistributionNames> 
wslconfig /setdefault Ubuntu       
````
- To __reinstall__ a distro, after `/unregister`, browse to "Microsoft Store", which erroneously reports "The product is installed". Click on "Launch", which reinstalls it. Apparently, their "installed" merely means downloaded. 

### WSL Config | [Advanced Settings](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)

#### `/etc/wsl.conf`  

>Configure certain functionality per [options](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configuration-options), per distro. E.g., map default `/mnt` to `/`, and allow `chmod`/`chown`. Default behavior, sans `wsl.conf`, __automounts__ all fixed drives  (`NTFS`, etal), and prepends `/mnt`. E.g., `/mnt/c` .

Create the file per distro:

```yaml
[automount]
root = /
#options = "metadata"
options = "metadata,umask=22,fmask=11"
#options = "metadata,uid=1000,gid=1000,umask=022,fmask=111"
```
- Such root setting strips `/mnt` prefix

By default, WSL processes `/etc/fstab` (`mountFsTab` option; defaults to `true`).

### WSL Filesystem Config | [Advanced Settings](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)

#### Per `/etc/fstab`

Use this only for settings that are particular to the specified drive. For common settings across all drives, use `wsl.conf` or `.wslconf` . 

E.g., add SMB drive mount

```bash
sudo vim /etc/fstab
```
```text
...

//RT-AC66U/etc /media/share drvfs binary,noacl 0 0
```
- Mount point ___must exist___ already.
    - `mkdir -p /media/share`
- WSL 1 used Type `smbfs` here, yet type `drvfs` at `mount ...`.

#### Per [`mount(8)`](https://linux.die.net/man/8/mount) 

Mount a drive manually, sans any such declaration at either `/tec/wsl.conf` or `/etc/fstab`:

```bash
# Unmount/Mount
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o 'metadata'
```

Mount (router's) thumb drive.

```bash
# Mount Windows SMB drive. 
sudo mkdir /media/share
sudo mount -t drvfs //RT-AC66U/etc /media/share

# Verify
ls /media/share
```
- [Chmod/Chown WSL Improvements](https://blogs.msdn.microsoft.com/commandline/2018/01/12/chmod-chown-wsl-improvements/) 

Show all mounts 

```bash
☩ mount
rootfs on / type lxfs (rw,noatime)
none on /dev type tmpfs (rw,noatime,mode=755)
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,noatime)
proc on /proc type proc (rw,nosuid,nodev,noexec,noatime)
devpts on /dev/pts type devpts (rw,nosuid,noexec,noatime,gid=5,mode=620)
none on /run type tmpfs (rw,nosuid,noexec,noatime,mode=755)
...
C:\ on /c type drvfs (rw,noatime,uid=1000,gid=1000,umask=22,fmask=11,metadata,case=off)
D:\ on /d type drvfs (rw,noatime,uid=1000,gid=1000,umask=22,fmask=11,metadata,case=off)
...
\\SMB\etc\ on /smb type drvfs (rw,relatime,case=off)
```

### Integration 

- [Mintty :: WSL](https://github.com/mintty/wsltty) &mdash; @ `WSLtty` ([MD](WSLtty.html "@ browser"))   


    ```bash
    # @ current WSL terminal ...
    mintty.exe
    ```

- [ConEmu :: WSL](https://conemu.github.io/en/BashOnWindows.html "@ GitHub.io") &mdash; Tabbed terminal window; integrates all Win-compatible shells, and into Win Explorer  
    - @ ConEmu > Settings > `{Bash::WSL}` 
        ```bat
        set "PATH=%ConEmuBaseDirShort%\wsl;%PATH%" 
            & %ConEmuBaseDirShort%\conemu-cyg-64.exe --wsl 
            -cur_console:pm:""   
        ```
        - `-cur_console:pm:/mnt` to prepend `/mnt` to path

    - @ ConEmu > Settings > `{Bash::Ubuntu}` 
        ```shell
        cmd.exe /c wslconfig /setdefault Ubuntu-18.04 
        & set "PATH=%ConEmuBaseDirShort%\wsl;%PATH%" 
        & %ConEmuBaseDirShort%\conemu-cyg-64.exe --wsl 
        ```
        - Task parameters: '/icon "C:\ICONS\Apps\Linux.Ubuntu.ico"'

    - @ `cmd.exe`
        ```shell
        wslconfig.exe /setdefault DISTRO_FULLNAME
        start ConEmu64.exe -icon C:\ICONS\Apps\Linux.DISTRO.ico -run C:\Windows\System32\wsl.exe
        ```
        - Sets default distro, then lauches it at a standalone ConEmu terminal. 
        - See [`LinuxHere.cmd` @ `cmd_library`](file:///C:/Program%20Files/_unregistered/cmd_library/LinuxHere.cmd).

    - @ Explorer (folder) Context Menu (`HKCR\Directory\Background\shell\...`)
        ```bat
        ; WSL
        [HKEY_CLASSES_ROOT\Directory\Background\shell\WSL]
        @="WSL"
        "Icon"="C:\\ICONS\\Apps\\Linux.tux.ico,0"

        [HKEY_CLASSES_ROOT\Directory\Background\shell\WSL\command]
        @="C:\\windows\\system32\\cmd.exe /c \"C:\\Program Files\\_unregistered\\cmd_library\\LinuxHere.cmd\""

        ; Ubuntu
        [HKEY_CLASSES_ROOT\Directory\Background\shell\LinuxUbuntu]
        @="Linux Ubuntu"
        "Icon"="C:\\ICONS\\Apps\\Linux.Ubuntu.ico,0"

        [HKEY_CLASSES_ROOT\Directory\Background\shell\LinuxUbuntu\command]
        @="C:\\windows\\system32\\cmd.exe /c \"C:\\Program Files\\_unregistered\\cmd_library\\LinuxHere.cmd\" ubuntu"

        ; ConEmu
        [HKEY_CLASSES_ROOT\Directory\Background\shell\ConEmu]
        @="ConEmu"
        "Icon"="C:\\Program Files\\ConEmu\\ConEmu64.exe,0"

        [HKEY_CLASSES_ROOT\Directory\Background\shell\ConEmu\command]
        @="C:\\Program Files\\ConEmu\\ConEmu64.exe -Dir \"%V\""
        ```

        - Launch app @ current directory. 
        - See [`LinuxHere.cmd` @ `cmd_library`](file:///C:/Program%20Files/_unregistered/cmd_library/LinuxHere.cmd).


## [Setup a WSL Development Environment](https://nickjanetakis.com/blog/using-wsl-and-mobaxterm-to-create-a-linux-dev-environment-on-windows "NickJanetakis.com 2018") 

- [Vagrant @ WSL](https://www.vagrantup.com/docs/other/wsl.html) __fails__.

- [ConEmu](https://conemu.github.io/) install ([MD](file:///D:/1%20Data/IT/Apps/Shell/Win/ConEmu/ConEmu.md "ConEmu.md") | [HTML](file:///D:/1%20Data/IT/Apps/Shell/Win/ConEmu/ConEmu.html "@ browser"))  
A tabbed terminal window; `cmd`, `git-bash`, `wsl`, `PowerShell`, ...

- UPDATE on [VS Code](https://code.visualstudio.com/download) / X-Server  
    WSL now (Win10 `R4`) integrates VS Code (`code`) of host natively ...
    ```bash
    $ which code
    /c/Users/X1/AppData/Local/Programs/Microsoft VS Code/bin/code
    ```

    - __No other install is required.__   
    The  command, `code`, launches VS Code (GUI), at host, without running X-server.  

        - [X Server](https://en.wikipedia.org/wiki/X_Window_System) (`X11`)  apps ([MD](file:///D:/1%20Data/IT/Apps/X-Server/X-Server.apps.md "X-Server.md") | [HTML](file:///D:/1%20Data/IT/Apps/X-Server/X-Server.apps.html "@ browser"))  
        Allows GUI apps installed at a session host (WSL distro) to launch as a client GUI app (at Windows).

        - [VS Code](https://code.visualstudio.com/download)  
        Run VS code from inside WSL. (While a Windows X-Server is running.)  
            - Download and install latest 64-bit (`.deb`) into WSL, per distro.  
            Then use method @ `Ubuntu.Install`.

- Node.js ([per Node Version Manager; `nvm`](https://github.com/creationix/nvm "github.com/creationix/nvm"))  

    ```bash
    # Install Node.js per NVM @ WSL (if not already)
    [[ ! "$( type -t nvm )" && "$WSLENV" ]] && {
        sudo apt-get update
        echo "===  Install NVM" 
        curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
        # install.sh clones nvm repos to ~/.nvm; adds source line to bash  profile 
        # https://github.com/creationix/nvm  
        source ~/.bashrc
        echo "===  Install Node.js (LTS) per NVM" 
        nvm install --lts 
    }
    ```

- Docker @ WSL ([MD](Docker.Install.html "@ browser"))  

- [Kubernetes (`kubectl`) @ WSL](https://medium.com/@ddebastiani/install-kubernetes-on-windows-wsl-c36f6b2571d2 "Install Kubernetes on Windows + WSL,  Medium.com, Jan-2018")   
Prerequisite: `minikube.exe` (+`kubectl.exe`) installed @ Windows 

    >Kubernetes development can be _somewhat_ integrated into WSL thru its own `kubectl` tool and respective config.   
    Much like the [Docker-@-WSL](https://nickjanetakis.com/blog/setting-up-docker-for-windows-and-wsl-to-work-flawlessly "Setting Up Docker for Windows and WSL to Work Flawlessly, NickJanetakis.com, May-2018") integration, where the WSL-installed client is configured for   
    the Windows-installed server, instead of its own server.   

- @ WSL, install `kubectl`

    ```bash
    # download kubectl to PWD
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    # make executable
    chmod +x kubectl
    # move it to appropos folder
    sudo mv kubectl /usr/local/bin/
    ```

- @ [~/.kube/config](file:///C%3A/HOME/.kube/config)

    Create a modified copy; convert paths and line-endings from Win to Unix.   
    This config file is spawned by `kubectl` per the current Minikube parameters.   
    Can be created anew; @ PowerShell ...

    ```powershell
    # Get the config file; save to TEMP
    kubectl.exe config view > $env:TEMP/kubectl-config
    ```

    ```bash
    # Change working dir TEMP (WSL path thereof)
    cd /r/TEMP 
    # if HOME is not cross-platform, ...
    mkdir ~/.kube
    # Copy config to its folder 
    cp kubectl-config ~/.kube/config
    # Convert to UNIX line-endings 
    dos2unix ~/.kube/config
    # Convert to UNIX paths 
    sed -i 's|\\|/|g' ~/.kube/config
    # if /mnt/...
    sed -i 's|\([ "]\)\([A-Za-z]\):|\1/mnt/\L\2|' ~/.kube/config
    # if /...
    sed -i 's|\([ "]\)\([A-Za-z]\):|\1/\L\2|' ~/.kube/config
    ```

    - For cross-platform setups, where `$HOME`, i.e., `~/`, is the same for WSL and Git-bash environments,   
    write a script to alternate between Win/Unix vesions of this _one_ config file, per environment.

- @ WSL, check/set `kubectl` __context__

    ```bash
    # Check kubectl "context"
    kubectl config get-contexts
    # If need be, switch kubectl to Minikube context
    kubectl config use-context minikube
    # Validate
    kubectl config view 

    # Test; get Minikube system (VM) pods
    kubectl get pods -n kube-system
    NAME                     READY   STATUS   ...
    coredns-c4cffd6dc-rjg2h  1/1     Running  ...
    default-http-backend...  1/1     Running  ...
    etcd-minikube            1/1     Running  ...
    ...
    ```

## WSL References  
- [Commands](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)  
- [User Accounts & Permissions](https://docs.microsoft.com/en-us/windows/wsl/user-support)   

## @ Debian

````bash 
$ cat /etc/debian_version       # 9.3; version number 
$ cat /etc/os-release           # OS Info  

$ sudo su
# GNU Dev Tools
$ apt-get update                   # pkgs version-info update      
$ apt-get install build-essential  # gcc, make, ...
$ apt-get install dh-autoreconf    # autoreconf 
# @ Kali
$ apt-get dist-upgrade            
$ apt-get install metasploit-framework  # turn off anti-virus
# Apps
$ apt-get install libssl-dev -y      # openssl crypto lib
$ apt-get install openssh-client -y  # ssh client
$ apt-get install openssh-server -y  # ssh server
$ apt-get install man-db -y   # man pages
$ apt-get install vim -y      # vim editor 
$ apt-get install strace -y   # debugger
$ apt-get install rsync -y    # rsync

# NOT needed; ntfs volumes mounted, per WSL default, @ /mnt/... 
$ apt-get install ntfs-3g -y  # Debian|Ubuntu
$ yum install ntfs-3g     -y  # RHEL 

$ ls -la '/mnt/c/Users/X1'      # fixed-drives automount by default
````

