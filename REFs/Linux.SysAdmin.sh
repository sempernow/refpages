#!/usr/bin/env bash
###############################################################################
# Linux System Administration Basics
# https://www.linode.com/docs/tools-reference/linux-system-administration-basics/
###############################################################################
exit 0
######

# Set default editor
    sudo update-alternatives --config editor

# BOOT CONFIGURATION FILES
    /etc/sysconfig/*

# OS : Get/Set hostname/info
    # System info
    uname --all # --help
    hostnamectl

    # OS info
    cat /etc/os-release
    alias os='cat /etc/os-release'

# NETWORK

    # Host
    hostname    # Get hostname of this machine
    hostname -d # Get domain
    hostname -f # Get FQDN

    # (Re)Set hostname
    hostnamectl set-hostname $newHostName
    systemctl restart systemd-hostnamed.service # static

    # DNS Resolution (locally)
    vim /etc/hosts          # 198.51.100.30   example.com
    vim /etc/resolv.conf    # nameserver 172.56.0.1

    # Connectivity
    ping $remote_ip_or_domain       # Connectivity to remote; RTT/Average, packet loss
    traceroute $remote_ip_or_domain # Path taken node to node (per hop)
    sudo apt install inetutils-traceroute  # Install traceroute
    mtr $remote_ip_or_domain        # ~ ping + traceroute

    # TIME : Network SYNCHRONIZATION
        timedatectl # newer; replces ntpq; FAILS to synch if behind SOCKS5 proxy
        ntpq        # older; more robust; synchs even if behind SOCKS5 proxy

        # timedatectl : https://www.man7.org/linux/man-pages/man1/timedatectl.1.html
            # List all USA Time Zones
            timedatectl list-timezones |grep America
            # Set Time Zone
            timedatectl set-timezone 'America/New_York'
            # Set the Time Zone Manually on a Linux System
            ln -sf /usr/share/zoneinfo/UTC /etc/localtime           # GMT
            ln -sf /usr/share/zoneinfo/EST /etc/localtime           # EST
            ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime    # EDT

            # CLI : Interactive/prompts for timezone settings : Debian / Ubuntu
            dpkg-reconfigure tzdata

            # Reset time service
            service ntpd restart

            # Install
            apt update
            apt install ntp

            # Enable (per timedatectl)
            timedatectl set-ntp true

        # ntpq : https://linux.die.net/man/8/ntpq : https://doc.ntp.org/archives/3-5.93e/ntpq/
            # Vital @ private-subnet nodes whereof network synch is required yet
            # their web access is only thru SOCKS5 proxy; timedatectl FAILs thereof.
            apt update
            apt install ntp

            # Inspect settings : pool of servers
            ntpq -p

            # Enable per timedatectl
            timedatectl set-ntp true  # disable per `false`

# MACHINE RESOURCES

    # Storage
        lsblk
        df -hT      # Per device
        du -h       # Disk usage per directory under PWD
        du -hs $dir # Disk usage summary of all folders thereunder (default is PWD)

    # CPU info
        lscpu    # YAML : Architecture, Model name, CPU(s), Thread(s) per Core, ...
        lscpu -J # JSON : Different structure : {lscpu: [{field: "Architecture", data: "x86_64"},...]}
        /proc # Mount of proc; process information pseudo-filesystem; interface to kernel data structures.
            cat /proc/cpuinfo # Per-thread (redundant) info

            cpuinfo(){
                echo -e "arch\t\t: $(echo $HOSTTYPE |cut -d'"' -f2)"
                cat /proc/cpuinfo |
                    grep -e name -e MHz -e cores -e siblings |
                    sed 's/siblings/threads   /' |
                    sort -u
            }
            alias cpu=cpuinfo

    # Process 
        pstree
        ps -ejH --sort=-rss
        /proc # Mount of proc; process information pseudo-filesystem; interface to kernel data structures.
            # List RSS of a PID
            pid=285
            cat /proc/$pid/status |grep Vm
                # VmPeak:  6115804 kB # Peak virtual memory size.
                # VmSize:  6095096 kB # Virtual memory size.
                # VmHWM:    670232 kB # Peak resident set size (RSS) : "High Water Mark" : .67 GB
                # VmRSS:    670188 kB # Resident set size (INNACURATE @ Linux 4.5+) : Sum of "Rss*:"

        # ps : Process info of declared pattern (command, PID, ...), else all of current user
        psp (){
            ps -axo user,pid,rss,pmem,pcpu,command |
                grep -v grep |
                grep -v 'ps -' |
                grep -e PID -e "${@:-$USER}"
        }

    # Memory info
        free -mh  # Units of Mi
        top -e m -E m # Memory units in MiB : At both Task (-e) and Summary (-E) areas.
        htop # F5 (Tree view), SHIFT+M (Sort by Memory), F4 (Filter; enter name of command), F1 (Help)
            # RSS (Resident Set Size) : Actual physical memory used by a process
            # - Total physical memory of machine *must* exceed sum of all RSS across all running processes.
            # VIRT (VIRTual memory size) : Total virtual memory a process may access;
            # - Includes memory swapped out, memory mapped but not used, and shared memory.
        ps -aux --sort=-%mem |head -n 10
            # RSS (Resident Set Size) : Actual physical memory used by the process
            # - Total physical memory must be greater than sum of all RSS across all running processes.
            # VSZ (Virtual-memory SiZe) in KiB; equivalent to VIRT of htop. (See above.)

            # Example:
            process=containerd
            ps -aux |grep -e RSS -e $process
                USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
                root      1234  0.5  2.1 2097152 43152 ?       Ssl  10:00   1:23 /usr/bin/containerd
                # VSZ (Virtual-memory SiZe) is 2097152 KB (roughly 2GiB).
                # RES (Resident Memory Size) is 43152 KB (roughly 42MiB).

            psrss(){ # RSS usage [MiB] of declared command ($1) else top 12
                e=-e
                [[ "$1" =~ ^-?[0-9]+$ ]] && n=$1 || {
                    n=12;[[ $1 ]] && unset e
                }
                ps -o pid,comm,rss,pmem,pcpu --sort=-rss |
                    awk '{ printf "%-8s %-22s %s[MiB]   %5s %5s\n", $1, $2, $3, $4,$5}' |
                        head -1
                [[ $e ]] || ps -C $1 -o pid,comm,rss,pmem,pcpu --sort=-rss --no-headers |
                    awk '{ printf "%-8s %-20s %6.0f       %5s %5s\n", $1, $2, $3/1024, $4, $5}' |
                        head -$n
                [[ $e ]] && ps $e -o pid,comm,rss,pmem,pcpu --sort=-rss --no-headers |
                    awk '{ printf "%-8s %-20s %6.0f       %5s %5s\n", $1, $2, $3/1024, $4, $5}' |
                        head -$n
            }

        rss(){ # Show actual (phyical) memory usage (RSS, HWM, etc.) of a process by its command ($1)
            pid_of_cmd(){
                ps -C $1 --sort=-rss |grep $1 |awk '{print $1}' |head -1
            }
            [[ $1 ]] || { echo '  USAGE: rss COMMAND';return 1; }
            pid=$(pid_of_cmd $1)
            [[ $pid ]] && cat /proc/$pid/status |grep Vm |
                awk '{ printf "%-8s %5.0f %4s\n", $1, $2/1024,"MiB" }' |
                    grep -v ' 0 '
        }
        meminfo(){
            cat /proc/meminfo |
                awk '{ printf "%-16s %10.2f %4s\n", $1, $2/1024/1024,"GiB" }' |
                    grep -v 0.00
        }

# PERFORMANCE
    # @ ISSUE, Step 1 is ASK:
    # - What metric of performance is the problem?
    # - Has the system ever performed better?
    # - What recent changes might have affected performance?
    # - Can we quantify meaning of "slow"?
    # - Is this issue affecting many users, or only one?

        uptime      # Complex metric of processes running or waiting for resources:
                    # System "load average" (per cpu): @1min, @5min, @15min
                    # So, 1 means 100% of 1 CPU (core), or 75% idle if system has 4 CPU cores
        top/htop    # Dynamic view of resources (CPU/MEM) usage
        sar         # System Activity Report : Historical stats : Configure to collect periodically

    # I/O
        vmstat -SM  # processes (r) blocked (b), memory, paging,
                    # block IO rcv(bi) sent(bo), traps, disks and cpu activity
        vmstat -d   # Per disk
        iostat      # ..., iowait, ... per device
        netstat     # Monitor network connections
        netstat -a  # Active connections; open ports
        netstat -an |grep ':80'  # Number of active connections on a port
        netstat -l  # Listening ports

        lspci               # PCIe specs
        /boot/firmware/     # Configuration file(s), e.g., to enable PCIe


# SERVICEs

    # @ NOT systemd
        service $service status|start|stop|enable|disable

    # @ systemd : See man systemd.service
        systemctl status|is-active|start|stop|enable|disable $service

        # Enable and start
        systemctl enable --now $service

        # Verify service STATUS is 'active'|'activating' : $? is 0|3 respectively.
        systemctl is-active [--quiet] $service # --quite prints nothing

        # Verify service STATUS is 'failed' : $? is 0 if one or more in 'failed' state, else non-zero.
        systemctl is-failed [--quiet] $service # --quite prints nothing

        # Disable and stop
        systemctl disable --now $service

        # List all unit files and their status
        systemctl list-unit-files

        # LOCATION matters
            # If installed by package manager 
            /usr/lib/systemd/system     # Managed by vendor; overrides /usr/...;
            # If *not* installed by package manager
            /etc/systemd/system         # Managed by sudoer; overrides /usr/...; survives updates
            /run/systemd/system         # Managed by sudoer; overrides /usr/...; survives updates; runtime

            systemctl cat $name.service  # Prints the EFFECTIVE config; the merged totality of all its configs.

        # Create a service for COMMAND (quickly)
            systemctl enable --now COMMAND
        # Delete a service
            systemctl disable --now COMMAND

        # Create : Example : ssh-user-sessions.service
            vi /etc/systemd/system/ssh-sessions.service # Edit:

                [Unit]
                Description=Shutdown all ssh sessions before network
                After=network.target
                Before=sleep.target

                [Service]
                TimeoutStartSec=0
                Type=oneshot
                RemainAfterExit=yes
                ExecStart=/bin/true
                ExecStop=/usr/bin/killall sshd

                [Install]
                WantedBy=multi-user.target
                RequiredBy=sleep.target

        # Create : Example : keepAwake.service
            vi /etc/systemd/system/keepAwake.service # Edit:

                [Unit]
                Description=Inhibit suspend
                Before=sleep.target

                [Service]
                Type=oneshot
                ExecStart=/usr/bin/sh -c "(( $( who | grep -cv '(:' ) > 0 )) && exit 1"

                [Install]
                RequiredBy=sleep.target

            # LECAGCY METHODS (RHEL 6)
                # ... runs all executables (hooks) @ ...
                /etc/pm/sleep.d

                # SUSPENSION IS PREVENTED if any script returns [$?] non-zero exit status.
                # So, e.g., to prevent sleep during SSH session, create a file ...
                    /etc/pm/sleep.d/05_ssh_keepawake

                    vi /etc/pm/sleep.d/05_ssh_keepawake # => edit ...
                        #!/bin/sh
                        # check for SSH sessions, and prevent suspending:
                        if (( $( who | grep -cv '(:' ) > 0 ))
                        then
                            echo "SSH session(s) are active. Not suspending."
                            exit 1
                        else
                            exit 0
                        fi
                    # save [ZZ]; then set perms; executable
                    chmod +x /etc/pm/sleep.d/05_ssh_keepawake

    # https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-power
        /sys/power/state # file controls system sleep states.

        # READING from this file returns the available sleep state labels,
        #  which may be "mem" (suspend), "standby" (power-on suspend),
        #  "freeze" (suspend-to-idle) and "disk" (hibernation).

        # WRITING one of the above strings to this file causes the system
        #  to transition into the corresponding state, if available.

            echo standby > /sys/power/state # go into standby mode
            echo mem > /sys/power/state # go into suspend mode

        # set to auto standby|mem when idle ...
        echo standby > /sys/power/autosleep # CentOS 6 : 'no such file or dir'
        echo mem     > /sys/power/autosleep
        echo off     > /sys/power/autosleep # disable autosleep

# PACKAGE MANAGERs
    # RHEL : See REF.RHEL.SysAdmin.sh
        yum
        dnf [options] COMMAND # RHEL 8+
            makecache  # Update/cache data of all enabled repos
            provides $pkg   # Versioninng reported here is often misleading; not the app version
            upgrade  [$pkg] 
            upgrade-minimal # Only updates that fix something
            search $str # Packages having string : Wildcards ok 
            install  $pkg --disablerepo=* --enablerepo=$localrepo # Install using only the local repo
            install  $pkg --nobest --allowerasing 
            reinstall # Overwrite existing installation with new.
            download $pkg --archlist x86_64,noarch --alldeps --resolve
            remove   $pkg               # Remove (delete) the installation.
            info     $pkg               # Application details; version and such
            repoquery -l $pkg           # List package content (CLI utilities, config files, ...)
            list installed $pkg         # Verify package is installed
            list --showduplicates $pkg  # List ALL versions (regardless of what's installed)
            list available $pkg         # List NEWER versions (of that installed currently)
            list installed COMMAND      # List installed version
            repolist
            repodiff --repo-old old1 --repo-new new1
            config-manager --disable $repo 

            rpm -qa # List all installed packages
            rpm -q COMMAND # RPM package + version

    # Ubuntu/Debian
        apt
            update        # Refresh repo index
            upgrade       # Upgrade ALL upgradable pkgs (DON'T)
            upgrade PKG   # Upgrade PKG
            install -y PKG1 PKG2 ...
            autoremove    # Remove unnecessary packages
            remove        # Remove pkg
            purge         # Remove pkg +config   ** NICE
            list          # List pkgs +criteria  ** NEW
            edit-sources  # Edit sources list    ** NEW
            search|show PKG

        # List installed packages
        dpkg -l
        # List all possible residue
        dpkg --get-selections | grep deinstall

        # Remove all packages of KEYWORD
        dpkg -l |grep KEYWORD |awk '{print $2}' |xargs -I {} sudo apt remove -y {}

        # Remove all configuration residue that `apt remove` fails to remove.
        dpkg --purge $(dpkg --get-selections | grep deinstall | cut -f1)

# SYSTEM

    uname -a  # All system info
        -rsv    # kernel release, name, version
        -nmpio  # node (hostname), machine , processor, hardware, os

    # Kernel Modules
        lsmod                   # List all loaded kernel modules
        modprobe $module   # Load a kernel module now (ephemeral)
        # Load a set (containerd.conf) of kernel modules on boot :
        ## @ /etc/modules-load.d/
        kernel_modules='
            overlay
            br_netfilter
        '
        printf "%s\n" $kernel_modules |sudo tee /etc/modules-load.d/containerd.conf
        # Load them all now
        printf "%s\n" $kernel_modules |xargs -IX sudo modprobe X

# STORAGE / FILESYSTEM
    lsblk -o SIZE,LABEL,NAME,MAJ:MIN,TYPE,FSTYPE,MOUNTPOINT,UUID

    df -hT # Disk space per device/mount : human-readable + type
    du -sh # Disk Usage : summary (all therunder) + human-readable

    # Symlink
        # Create
        ln -s SOURCE LINK   # SOURCE is file or directory 
        ln -sf SOURCE LINK  # Omnipotent
        # Delete
        rm LINK # NOT `rm -rf LINK/`, which deletes all SOURCE content
    
    # FILE OWNER
        chown USER:GRP FILE
        chown -R USER:GRP DIR  # Recurse; all thereunder

    # FILE MODE : PERMISSIONs ("0" prefix is optional)
        chmod 0755 DIR   drwxr-xr--
        chmod 0744 FILE  -rwxr--r--
        chmod 0644 FILE  -rw-r--r--
        chmod 0400 FILE  -r--------

        # SET permissions of group to those of user, recursively
        chmod -R g=u /mnt/assets

        # MEANINGs :     File  OR  Dir
                          ----      -------
            4 Read        open      list
            2 Write       modify    add/del
            1 Execute     run       cd

        # PERMISSIONs MASK : File Mode Creation Mask
            umask $mask # Set file mode creation mask; default: 022
            umask -S    # Display file mode creation mask in Symbolic Form

            # Default file-mode permissions
            # Linux sets all new files and folders
            # using defaults mode and umask defaults
            # So, with default umask (0022), the resulting perms are:
            # Final: Sans   Umask
            # ----   ----   ----
            # 0755 : 0777 - 0022 : Folders
            # 0644 : 0666 - 0022 : Files

            # Change per SESSION; to persist, edit @ ~/.profile
            umask 0022  # Default; e.g.,  0755  u=rwx,g=rx,o=rx
            umask 0077  # User only;      0700

            # Symbolic Mode Permissions
            umask -S u=rwx,g=rx,o=rx # 0022 => 0755

            # See REF.RHEL.Storage.sh

# USERS & GROUPS

    # Federated Auth schemes, e.g., Active Directory (AD)
        # Integrate into Linux using : Samba, Winbind, SSSD, or RealmD
        # @ https://chat.openai.com/share/73401243-5ea0-4cdc-9090-d6dd709ada10

        # See REF.Network.LDAP.*

    id [OPTION] [USER] # ID of [CURRENT] USER : user, group, and groups of which user is member
        #> uid=1000(foo) gid=1000(x1) groups=1000(tribe),...,27(sudo),115(docker)
        id -u   # User UID
        id -un  # User name
        id -g   # Group GID
        id -G   # All groups of which $USER is a member : by GID
        id -Gn  # All groups of which $USER is a member : by group name

    # Get MIN MAX values of UID:GID for REGULAR and SYSTEM work (users, groups)
        cat /etc/login.defs

    # user, pass
        # Add user, and set password interactively
            adduser $user            # create new user
            passwd $user             # (re)set user's password
            # (Re)Set password non-interactively
                echo  "$user:$pass" |sudo chpasswd

        # Get username from uid
            uname_uid(){ cat /etc/passwd |grep ":x:${1}:" |awk -F ':' '{print $1}'; }
            uname_uid $uid

        # Add a secure SSH-users account (user:group) at target machines.
            # Add user:group foo:foo having no password, and so disabling password-based shell login.
            # This is useful for remote user(s) to login as this user by ssh;
            # allowing only (ssh) key-based authtentication.
            # Each user would have to add their public key to this user's ~/.ssh/authorized_keys file,
            # and do so by some out-of-band (not ssh-copy-id) process requiring elevated privileges.
            useradd -m -s /bin/bash $u
                -u, --uid
                -g, --gid
                -U, --user-group # Create group having user name and add user to it; default behavior lest -N, -g
                -N, --no-user-group
                -r, --system    # System user : Non-human user having UID < 1000. Okay for Service work too.
                -s, --shell     # Login shell, e.g., /bin/bash, /bin/false, /sbin/nologin
                -M, --no-create-home
                -m, --create-home
                -d, --home-dir  # Unless -M
                -b, --base-dir  # Base dir; default is /home : Required by -d lest -m
                -c, --comment
                --gecos         # GECOS (General Electric Comprehensive Operating System) field : Not all distros; Prefer --comment
                -G, --groups    # CSV list of supplemental groups to which this user is added.
                -p, --password

            # Idempotent
            id -un $u || sudo useradd --create-home --shell /bin/bash $u

        # Add user:group ($u:$u) of declared IDs
            # having UID:GID 1001:1001,
            # having NO HOME DIRECTORY
            groupadd --gid 1001 $u
            adduser --uid 1001 --gid 1001 --gecos "Full Name,Room Number,Phone,Other" --disabled-password --no-create-home $u

        # Add a SYSTEM (-r) user:group $u:$u having no home directory and no login shell
            groupadd -r $u
            useradd -r -M -s /sbin/nologin $u # Message on login attempt
            useradd -r -M -s /bin/false $u    # Silent exit on login attempt

        # Add user having ALT HOME DIR yet /home equivalence regarding SELinux
            # Want to create a user account for podman, configure that for rootless podman in a large home dir,
            # so that many AD users (a developer team) have a stable, workable rootless podman configuration
            # in which to work on a designated RHEL host having SELinux enforced.

            # 1. Provision a system user having an alternate (non-standard) home directory

                # Create a local service account having no login shell
                alt=/srv/git
                mkdir -p $alt/repos
                adduser --system --shell /usr/bin/git-shell -d $alt git

                ## Configure a non-standard ($alt) HOME for local user that SELinux treats as it would those of /home
                ## - Idempotent
                seVerifyHome(){
                    ## Verify SELinux fcontext EQUIVALENCE
                    semanage fcontext --list |grep "$1" |grep "$1 = /home"
                }
                export -f seVerifyHome
                mkdir -p $alt
                seVerifyHome $alt || {
                    ## Force SELinux to accept SELinux declarations REGARDLESS of current state of SELinux objects at target(s)
                    semanage fcontext --delete "$alt(/.*)?" 2>/dev/null # Delete all rules; is okay if no rules exist.
                    restorecon -Rv $alt # Apply the above purge (now).
                    ## Declare SELinux fcontext EQUIVALENCE : "$alt = /home"
                    semanage fcontext --add --equal /home $alt
                    restorecon -Rv $alt # Apply the above rule (now).
                }

            # ELSE : Create in standard /home/$u, and then bind mount /work/home/$u into it.
            mkdir -p /home/$u
            mount --bind $d /home/$u
            # Make it permanent
            grep $d /etc/fstab ||
                echo "$d /home/$u none bind 0 0" |tee -a /etc/fstab

        # Get entitites (GID, name, ...) from Name Service Switch library
            # Useful to test for existence of subject
            getent group foo
            getent passwd foo

        # Add user to group
            usermod -aG $g $u
            newgrp docker # Supposedly to take effect now, but side effects linger. Better to relog.
            # OR
            gpasswd -a $u group

        # Delete a user
            userdel -r $u
            userdel -r -Z $u
        # Remove a user from a group
            gpasswd -d $u $g

        # Lock user account
            passwd -l $u
        # Unlock user account
            passwd -u $u
        # Unlock user in faillock
            faillock --user $u --reset

        # List groups to which user has membership
        groups $u   # Of declared else current user

        # List : group / members
        cat /etc/group
        getent group NAME

        # Change owner (UID:GID) recursively
        chown -R $uid:$gid /top/path
        # Change owner to current user:group
        chown -R $(id -u):$(id -g) /top/path

        # Sudoers GROUP : Add USER | sudoers(5) https://linux.die.net/man/5/sudoers
        usermod -aG wheel $u  # RHEL/CentOS/Fedora (wheel group)
        usermod -aG sudo $u   # Ubuntu/Debian      (sudo group)

        # Change NAME : user
            usermod -l $new -d /home/$new -m $old
        # Change NAME : group
            groupmod -n $new $old
        # Change PASSWORD
            # Set interactively
            passwd $u
            # Set non-interactively :
             echo "$pw" |sudo passwd $u --stdin
            # Set to unknowable password : -base64|-hex :
            openssl rand -base64 33 |sudo passwd $u --stdin
            # Batch password change
                chpasswd  # non-interactive/batch; must be root user
                # E.g.,
                echo  "$user:$pass" |sudo chpasswd
                # @ multiple users
                echo -e "$user1:$pass1\n$user2:$pass2" |sudo chpasswd

        # Delete user's PASSWORD; may/not prevent login with no password
        sudo passwd -d $u
        # LOCK user ACCOUNT to prevent login by password (SSH by key okay).
        sudo passwd -l $u
        # CHANGE : HOME dir : default is /home/$USER
            sudo vim /etc/passwd
            # sudo(8)  https://linux.die.net/man/8/sudo
            # ... edit @ username, then reboot
                sudo COMMAND # has very limited PATH; TERM, PATH, HOME, SHELL, LOGNAME, USER, USERNAME
                # ... to add more paths, modify: | sudoers(5) https://linux.die.net/man/5/sudoers
                /etc/sudoers.d
                    env_check
                    env_keep
                    # a whitelist for environment variables.

        # sudo -u v. su : Shell requirements
            #   Command     Requires Login Shell?      Works with nologin?         Best For
            #   ----------  ---------------------      ----------------------      --------------------
                sudo -u $u  # ❌ No                   ✅ Yes (ignores shell)      Service accounts
                su - $u     # ✅ Yes (/bin/bash)      ❌ No (nologin fails)       Interactive sessions

            # Has dizzying array of affects
            sudo -l                 # List commands allowed a sudoer
            sudo -u $u $command     # Run $command as user $u, sans shell
            sudo su $u              # Shell (/bin/sh) at PWD as user $u 
            sudo su - $u            # Full login shell (/bin/bash) as user $u
    
            sudo -i su $u           # Full login shell (/bin/sh) and PWD at /root
            sudo su -s /bin/bash $u # Force login shell
            sudo -E su $u           # Preserve environment
            su $u                   # Switch User : to $u
            su - $u                 # Switch User : to $u's login shell
    
    sudoedit /a/b # Safe and recommended way for users with sudo privileges to edit arbitrary files. 
        #... editor does *not* run as root
        EDITOR=vim sudoedit /etc/nginx/nginx.conf

    # sudoers FILE
        /etc/sudoers # The baseline sudoers file
        
        visudo # Exclusively for editing /etc/sudoers* files. 

            sudo visudo /etc/sudoers # To edit, but don't. Rather:
            # - Best practice is to leave that file untouched,
            #   and rather add/edit file(s) at /etc/sudoers.d/.
            #   Each of which is named and scoped to a group or user.
            # - The visudo utility is a safety net against user lockout due to wrong syntax,
            #   yet it does *not* protect context-specific errors.
            #   Such errors are uncaught, and fail to apply without hint as to why.

        # ALLOW per file(s) of sudoers statements at /etc/sudoers.d/
            sudo visudo /etc/sudoers.d/$USER  # Create/Edit.
            # - All files under /etc/sudoers.d/ are invoked automatically.
            # - Changes take effect immediately.

            # ALLOW current user to run ALL COMMANDS as sudo SANS PASSWORD:
                echo "$USER ALL=(ALL) NOPASSWD: ALL" |sudo tee /etc/sudoers.d/$USER
                # OR, by UID
                echo "#$(id -u) ALL=(ALL) NOPASSWD: ALL" |sudo tee /etc/sudoers.d/$USER

            # GROUP-SCOPED declarations : group 'ops'
                g=ops

                # FULL access
                echo "%$g ALL=(ALL) NOPASSWD: ALL" |sudo tee /etc/sudoers.d/$g   # ALLOWS impersonate (run as) other users
                # So, `sudo -u postgres psql` is allowed
                echo "%$g ALL=(root) NOPASSWD: ALL" |sudo tee /etc/sudoers.d/$g  # BLOCKS impersonation
                # So, `sudo -u postgres psql` is *not* allowed

                # LIMITED access
                sudo visudo /etc/sudoers/$g
                ## Allow group 'ops' members to run declared (CSV) list of (sub)commands/flags:
                # Cmnd_Alias OPERATOR_CMDS = /usr/bin/systemctl start *, /usr/bin/systemctl stop *, ...
                # Cmnd_Alias LOG_CMDS = /usr/bin/journalctl *, /bin/cat /var/log/*, ...
                # %group-x ALL=(root) OPERATOR_CMDS, LOG_CMDS

                # Cmnd_Alias  GROUP_OPS_CMDS =  /usr/bin/dnf update, \
                #                         /usr/bin/systemctl status *, \
                #                         /usr/bin/systemctl list-unit-files, \
                #                         /usr/bin/systemctl start apache2, \
                #                         /usr/bin/journalctl, \
                #                         /usr/bin/firewalld --list-all *, \
                #                         /usr/bin/firewalld --get-services, \
                #                         /usr/bin/firewalld --permanent --info-service=*
                ##...Allow sans password:
                # %ops ALL=(root) NOPASSWD: GROUP_OPS_CMDS

                ## Modify sudo PATH (secure_path) for group 'ops' to include /usr/local/bin :
                # Defaults:%ops secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
                ## Similar, but password required (per timestamp_timeout setting):
                # %ops ALL=(ALL) GROUP_OPS_CMDS
                ## Similar, but group declared by its GID
                # %#2222 ALL=(ALL) GROUP_OPS_CMDS

1            # Set TTL on sudo PASSWORD ENTRY
                # Defaults timestamp_timeout=-1 # Once per terminal session
                # Defaults timestamp_timeout=60 # 60 minutes
                ## Scoped to user
                # Defaults:u1 timestamp_timeout=-1
                ## Scoped to group
                # Defaults:%ops timestamp_timeout=60
        # Set default editor
            sudo update-alternatives --config $editor

    # MONITOR users
        users # print user names of users currently logged in @ current host
            # E.g., monitor if user $1 logged in; send email to root on login
            until users | grep $1 > /dev/null
            do; sleep 15; done
            mail -s "$1 just logged in" root < .

    # TEST if user has elevated privileges
    ls /root
    # Show perms/owner
    ls -lh
    # Logout of GUI from terminal
    pkill -u $user

    who  # who is logged in; USER TTY TIME
    w    # who is logged in; USER TTY FROM LOGIN@ IDLE JCPU PCPU WHAT
    # from HOST1 @ ssh foo@HOST2 =>
            [foo@HOST2 ~]$ w
             13:37:50 up 56 min,  2 users,  load average: 0.00, 0.01, 0.05
            USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
            foo     pts/0    HOST1.DOMAIN      13:32    6.00s  0.70s  0.02s w

# PROCESS MANAGEMENT [create/monitor/kill]
    export _program=goRun
    (sleep 2 && tail --pid=$( pidof $_program ) -f /dev/null && rm ./$_program &)
    go build -o $_program && ./$_program

    stress  # stress test; artificial load
        -c, --cpu N      # spawn N workers spinning on sqrt()
        -i, --io N       # spawn N workers spinning on sync()
        -m, --vm N       # spawn N workers spinning on malloc()/free()

    strace  # trace system calls and signals; man strace (1)
        # trace `aCommand` and send strace output to file 'aCommand.strace'
        strace -o COMMAND.strace -f COMMAND ARGs
        strace -c COMMAND  # stats

    top # Dynamic real-time view of a running linux system : processes/threads
        # Memory units in MiB at Task (-e) and Summary (-E) areas : Sort by Resident Set Size (RES)
        top -em -Em -oRES
    htop    # Newer/nicer top
    pstree  # Shows parent/child tree structure of processes
    ps      # Snapshot of current processes [syntax:UNIX|BSD|GNU]
        # List all process sorted by RSS (Resident Set Size; actual phy mem used) [KB]
        ps -aux --sort=-rss |head
        ps -aux |wc -l # get the number of running processes
        ps -ax --sort=-rss -o user,pid,rss,pmem,pcpu,command # command (full statement); comm (command only)
            # all (a); incl processes external to shell (x)
                # Fields
                USER
                PID      # Process ID
                %CPU
                %MEM     # https://povilasv.me/go-memory-management/
                VSZ      # Bytes of RAM reserved (Virtual Memory Size)
                RSS      # Resident Set Size : Actual physical memory [KB] used by the process
                TTY      # current-terminal:'pts/0', background-process:'?'
                STAT     # status : sleep:'S', running:'R'
                START
                TIME
                COMMAND  # the command that lauched it

        # monitor process $1; show/stream its `ps` status @ tty11; write to syslog on stop
            while ps -aux | grep $1 | grep -v grep | grep -v bash > /dev/tty11
            do; sleep 1; done
            logger $1 has stopped.  # send to syslog; `/var/log/messages`

        ps -ejH # Process tree
        ps fax # processes AND their child processes
        ps -ag # processes by group name or session
        ps ax | grep 'process-str'
        ps -ef | grep ssh | grep -v grep # all ssh session processes
        ps -eo user,pid,cpu,nice,comm # format [-o]; show only ...

    pstree # all processes per parent-child tree [graph]

    # SHELL JOBs : process launched from shell
        COMMAND & # start as a BACKGROUND PROCESS
        CTRL+C    # TERMINATE job
        CTRL+Z    # PAUSE job
        bg [N]    # MOVE process TO BACKGROUND, per JOB NUMBER (N); default: N=1
        fg [N]    # MOVE process TO FORE, per JOB NUMBER (N); default: N=1

    # PROCESS SIGNALs (NAMES & NUMBERS)
        Name      Number    Effect
        -------   -------- ---------
        SIGHUP      1       Hangup
        SIGINT      2       Interrupt from keyboard
        SIGKILL     9       Kill signal          # Severe
        SIGTERM    15       Termination signal   # Polite
        SIGSTOP  17,19,23   Stop the process     # Severe

    # SENDING SIGNALS [man 7 signal]
        #  terminate/kill : SIGTERM[15]/SIGKILL[9] : politely/NOW
        #  do NOT use SIGKILL [9] on file process; can destroy file[s]
        top             # send signals: 'k'=kill, 'r'=renice [increment!]
        kill 0          # kill ALL JOBS except current shell
        kill %N         # kill per JOB NUMBER; get job number per `jobs`
        kill PID        # kill per PID; does NOT kill STOPPED JOB
        kill $!         # kill last background job, per its PID [$!]
        kill -n 15 1234 # politely kill PID number 1234
        kill -n SIGNUM  PID  # by number
        kill -s SIGNAME NAME # by name
        kill -l # list all the SIGNAMEs
        killall NAME  # kill all 'NAME' jobs; all users if root

        # LIST/KILL per NAME and other attributes
            pgrep [options] pattern  # LIST processes
            pkill [options] pattern  # SIGNAL processes
            pkill pattern            # Terminate per SIGTERM (15); DEFAULT
            # E.g.,
            pkill -KILL NAME    # kill process per name, per SIGKILL (9)
            pgrep -u root sshd  # list the processes called sshd AND owned by root
            pgrep -u uZer,foo   # list the processes owned by uZer OR foo.
            pkill -u USERNAME   # LOGOUT a user per SIGTERM (15)

        # LIST/KILL per JOB NUMBER, `N`, which is NOT the PID.
            jobs # show BACKGROUND shell jobs by JOB NUMBER number; `[N]` NAME ARGs
            kill PID  # kill PID
            kill %N   # kill JOB NUMBER (N); use to kill STOPPED JOBs
            kill $!   # kill last background job, per its PID [$!]
            nohup COMMAND & # no-hangup; don't terminate upon logout

    # MEASURE script RUNTIME [executes script]
        time SCRIPT

        time ps -aux
            real    0m0.005s # Total, including I/O
            user    0m0.002s # @ user-mode time
            sys     0m0.003s # @ kernel-mode time

    # PERFORMANCE LOAD
    #  runqueue     : PIDs [stack] => scheduler => cpu0/1/2/...
    #  load average : number of process in the runqueue @ 1min,5min,15min
    #  CPU(s) user-space:us, system:sy, idle:id, waiting:wa
        uptime # up-time, #-of-users, & load-averages @ 1min 5min 15min

        top # PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND
            top -e m -E m # Memory units in MiB : At both Task (-e) and Summary (-E) areas.
             #  LIVE list of processes & info; default sort per CPU usage;
             #  toggle: '1' toggles CPU% per cores/total
             #  send signal: 'k'=kill per SIGTERM[15]/SIGKILL[9]
             #  send signal: 'r'=niceness [increment!]
             #  change sort collumn: '<' or '>'

        free # memory; total,used,free,...; RAM/buffers/cache/Swap;
            -m  # MB
            -g  # GB
            # system stores/frees @ cache as needed
            # '-/+ buffers/cache:' shows this 'extra' used/free memory
            # Swap; dormant used-memory constantly moved between RAM & swap

        # Swap
            swapon --show # Summary of usage
            swapon -s #... same but depricated; less readable
            swapoff -a # Disable ALL swaps devices/files of /proc/swaps
            # Verify current swap(s)
            cat /proc/swaps
            # Disable all swaps
            sudo swapoff -a
            sudo systemctl --now disable swap.target

         # BENCHMARK [de]compression performance/speed [7-zip app]
            /bin/7za b

    # SPAWN PROCESSes : Fork Bomb
        # infinitely spawn forked processes using colon function, `:` (alias of true)
        :() { : | : & }; :
            # then inspect numbers of running processes and tasks ...
            cat pids.current # total number of processes
            cat tasks

# LOGGING
    # legacy
        aSERVICE |--> rsyslog
                 |--> internal/independently log

            rsyslog[d]  # legacy log handler  (CentOS 6+)
            /var/log/

    # systemd
        servicectl <--> aSERVICE --> journald
        servicectl <--> journald

    # Integrate journald/rsyslogd : rcv other's logs; one or both direction
        journal[d]  # systemd log handler (CentOS 7+)
        logger STR  # Send to syslog : /var/log/messages

    # Read systemd journal
        journalctl # CLI for journald (BINARY log files)
            -u NAME     # Of declared service (unit) NAME
            -e          # Jump to end (most recent)
            -x          # Augment with useful meta info
            --no-pager  # Full message (else truncates each)
            -b                  # boot logs
            --system            # System journal
            --user              # User journal
            --since=yesterday   # Logs since yesterday|today|...
        # Recent journal messages (all services)
        sudo journalctl -xe --no-pager
        # Recent journal of a service
        sudo journalctl --no-pager -xeu $service
        # Boot log
        sudo journalctl -xb

        # Delete/vacuum logs AKA journal entries
        sudo journalctl --rotate         # systemd-journald SIGHUP (close/reopen)
        sudo journalctl --vacuum-time=1s # Delete archives, but not current

        # DELETE ALL journald LOGS
            sudo systemctl stop systemd-journald
            sudo rm -rf /var/log/journal/*/*.journal
            sudo systemctl start systemd-journald

# TASK SCHEDULING : cron, or at
    # How to @ https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/
    cron  # crond daemon; for sheduling tasks to repeat on a regular basis
            # crond started on boot by default; other services depend on it
            # its config files are scattered about
            # rpms can automatically 'drop shell scripts in cron'
            # users can create their own cron jobs

    at  # atd daemon; for jobs to execute at a certain time
            # use to 'add jobs'

    # CRON CONFIG FILEs : CREATE CRON JOB

        # create cron job [crontab file]
            #  @ RHEL, see:
                /var/spool/cron/
                    -rw-------. 1 foo  foo  36 Jan 30 13:28 foo
                    -rw-------. 1 root root 27 Jan 30 13:25 root
            # @ other distros: https://www.cyberciti.biz/faq/where-is-the-crontab-file/

        # METHOD 1
                su - USERNAME
                crontab -e  # create using editor of current env

                    # run logger; write msg 'hello' to syslog at 2:30pm ea day
                    30 14 * * * logger hello
                    # run backup /etc to root home dir ea day @ 04:00
                    0 4 * * * tar -czf /root/etc.tgz /etc

            # METHOD 2
            # create cron job @ /etc/cron.d DIRectory
            vim /etc/cron.d/foo
            # E.g., 'sysstat' cron job
            cat /etc/cron.d/sysstat # =>
                # Run system activity accounting tool every 10 minutes
                */10 * * * * root /usr/lib/sa/sa1 1 1
                # 0 * * * * root /usr/lib/sa/sa1 600 6 &
                # Generate a daily summary of process accounting at 23:53
                53 23 * * * root /usr/lib/sa/sa2 -A

        # Prototype cron config file
        /etc/crontab # don't use; not protected

        # list all ...
        ls -1 /ect/cron* # used by rpms to drop shell scripts to be executed hourly/daily/...

            /etc/cron.deny
            /etc/crontab   # don't use; managed by rpm;

            # cron jobs DIR; contains cron jobs [files]
            # USER-CREATED CRON JOBS GO HERE
            /etc/cron.d
                0hourly
                raid-check
                sysstat
                unbound-anchor
            # DIRs containing shell scripts dropped by rpm / pkg install scipts
            # Do NOT put here; can't control; managed by rpm
            /etc/cron.daily
            /etc/cron.hourly
            /etc/cron.monthly
            /etc/cron.weekly

    # at : STATUS of atd daemon ...
    systemctl status atd -l # CentOS 7 [systemd]
    system atd status      # CentOS 6

    # at : LOCATION
        /var/spool/at/

    # at : CREATE
        at 14:30  # time; 24hr
        # => [typed @ at's prompt]
        > logger hello at 2:30 from at
        CTRL+D

    # logs written to ...
        /var/log/messages
        /var/log/secure
         .
         .
         .
    # at : SHOW JOBS
        atq

    # at : DELETE JOB[s]
        atrm 2 # remove job #2

    # Cron Utility @ AsusWRT/Merlin router
        cru  # front-end script for `crontab`, written by Merlin
         # E.g., install/run, then update every 6 hours per `cru`
            /jffs/scripts/ya-malware-block.sh
            cru a UpdateYAMalwareBlock "0 */6 * * * /jffs/scripts/ya-malware-block.sh"
            # https://github.com/RMerl/asuswrt-merlin/wiki/How-to-block-scanners,-bots,-malware,-ransomware

# PRIORITIES & NICENESS [ps + grep]
    #  Nice Levels [niceness], -20 to +19;
    #  lower Nice Level, higher priority
    nice -n 10 COMMAND # set nice-level of a process
    nice -n -20 COMMAND # set low nice-level of a process
    renice 15 -p {PID}    # renice a running process per its PID
    renice 10 -u USERNAME # renice all running processes per USERNAME

# POWER MANAGEMENT  pm-action (8)
    legacy              systemd

    halt                systemctl halt
    poweroff            systemctl poweroff
    reboot              systemctl reboot
    pm-suspend          systemctl suspend
    pm-hibernate        systemctl hibernate
    pm-suspend-hybrid   systemctl hybrid-sleep

    # SYSTEM SHUTDOWN
    shutdown -r now

    # reboot per menu entry #3 [systemd] ...
    grub2-reboot 2 && systemctl reboot

    # suspend ...
    /etc/systemd/
        logind.conf # => edit ...
            IdleAction=suspend
            IdleActionSec=30min
    /usr/lib/systemd/system/
        suspend.target
    /usr/lib/systemd/system/

        systemd-suspend.service # runs all executables PRE|POST @

            /usr/lib/systemd/system-sleep/ [pre/post]

                #!/bin/sh
                # man systemd-suspend.service(8)
                # $1 = pre|post @ $2 = suspend|hibernate|hybrid-sleep
                [[ "$1" == 'pre'  ]] && echo "This runs BEFORE $2"
                [[ "$1" == 'post' ]] && echo "This runs AFTER $2"


# UEFI [firmware] altering files.
    /sys/firmware/efi/efivars
    # a special filesystem that presents the configuration settings for the computer's underlying UEFI firmware to the user. These configuration variables are used to control the way the motherboard firmware starts up the system and boots your operating system. CHANGING THE FILES IN THIS DIRECTORY THEREFORE CHANGES THESE RESPECTIVE VARIABLES IN THE FIRMWARE. http://www.theregister.co.uk/2016/02/02/delete_efivars_linux/

# INIT kernel
    # "kernel" the operating system proper, in memory.
    /vmlinuz # the operating system proper, on disk.
    # Contains all the functions that make everything go.

    systemd [systemctl...] # https://en.wikipedia.org/wiki/Systemd
        # https://coreos.com/os/docs/latest/getting-started-with-systemd.html
        # 1. Unit/Service files; config files that describe the process/service; fnames: NAME.service
        # 2. Target; a grouping mechanism that allows systemd to start up groups of processes at the same time.
        # An init system; bootstraps the user space and manage all processes subsequently;
        # Replaced the UNIX System V or Berkeley Software Distribution (BSD) init systems @ 2014.
        systemctl # CLI for systemd
        systemctl --now $action $unit       # action: status|reload|start|stop|enable|disable
        systemctl list-sockets              # List socket units currently in memory
        systemctl list-units                # List units currently in memory
        systemctl list-unit-files           # List all installed
        systemctl list-dependencies $unit   # Recusively list all units required of this one
        systemctl is-active $unit           # Exit 0 if "active"
        # users shell scripts; <fname>.sh
        /usr/local/bin

        # startup (init) scripts
        /etc/rc.d/init.d
        /etc/init.d.

# VIRTUAL CONSOLE LOGIN
    CTRL+ALT+<F1-F7>

    CTRL+ALT+F1  # console
    CTRL+ALT+F7  # GUI

    # The Linux console is a SYSTEM CONSOLE internal to the Linux kernel. (A system console is the device which receives all kernel messages and warnings and which allows logins in SINGLE USER MODE). The Linux console provides a way for the kernel and other processes to send text output to the user, and to receive text input from the user. The user typically enters text with a computer keyboard and reads the output text on a computer monitor. The Linux kernel SUPPORTS VIRTUAL CONSOLES - consoles that are logically separate, but which access the same physical keyboard and display. The Linux console (and Linux virtual consoles) are implemented by the VT subsystem of the Linux kernel, and do not rely on any user space software. This is in contrast to a terminal emulator, which is a user space process that emulates a terminal, and is typically used in a graphical display environment.  https://en.wikipedia.org/wiki/Linux_console

# GRUB : Protect using unique username and password

    # Generate password
    sudo dnf install grub2-tools # Is *not* in grub2-tools-minimal @ RHEL 8.
    grub2-mkpasswd-pbkdf2
    # Set string
    pw_str='grub.pbkdf2.sha512.10000.FFC...CED.F30...0D1'

	# Verify boot partition is hd0 or whatever
    lsblk
    df -hT
        # And mapping is :
        /dev/sda1 -> (hd0,msdos1)
        /dev/sda2 -> (hd0,msdos2)

        # GRUB Partition Naming
        #     (hd0,1) or (hd0,msdos1) refers to the first partition on the first hard disk (/dev/sda1 in Linux).
        #     (hd0,2) or (hd0,msdos2) refers to the second partition on the first hard disk (/dev/sda2 in Linux).

        # Explanation
        #     (hd0,1): This is a shorthand notation. It refers to the first partition on the first hard disk.
        #     (hd0,msdos1): This is a more explicit notation that also refers to the first partition on the first hard disk, indicating it's an MBR (Master Boot Record) partitioning scheme.

    # Create/Edit grub config
	cat <<-EOH |tee sudo /etc/grub.d/40_custom
	set superusers="grubadmin"
	password_pbkdf2 grubadmin $pw_str

	menuentry 'Red Hat Enterprise Linux' {
		set root=(hd0,msdos2)
		linux /boot/vmlinuz-$(uname -r) root=/dev/sda1
		initrd /boot/initramfs-$(uname -r).img
	}
	EOH

    # Update grub config
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
    # Reboot
    sudo reboot


# MAINENTANCE MODE
    # a.k.a. "Single User Mode" a.k.a. "runlevel 1"

    # @ ONLINE terminal; if system boots
    # http://www.linfo.org/change_to_single_user.html
        su /sbin/init 1  # change to runlevel 1
        # show current runlevel
        /sbin/runlevel

    # @ GRUB (bootloader); if boot fails
        # Boot into Single User Mode
        # https://www.tecmint.com/boot-into-single-user-mode-in-centos-7/
        # 1. Select kernel version
        # 2. press `e` to edit that line
        # 3. down-arrow to line with `linux16`
        #    and change `ro` to `rw init=/sysroot/bin/sh`
        # 4. CTRL+X, or F10
        # 5. Mount root filesystem per
            chroot /sysroot/
        # When finished ...
            reboot -f

    # FIX LOGIN FAILs
        # Login from console
            <ALT>+<CTL>+<F1-7

        # typical suspects ...
            cat .xsession-errors
            .Xauthority   # corrupted owner/perms; can delete
            chmod 1777 /tmp

    # Reset/Restore USER/GROUP PERMS to default
    # run as su (root) ...
    # switch to single-user-mode ...
    su /sbin/init 1

        # @ HOME
            find /home/uZer -type d -print0 | xargs -0 chmod 0755
            find /home/uZer -type f -print0 | xargs -0 chmod 0644

    # Reset/Restore all packages
        # RPM:
             for p in $(rpm -qa); do rpm --setperms $p; rpm --setugids $p; done

        # DEB:
             dpkg --get-selections | grep install | grep -v deinstall | cut -f1 | xargs apt-get --reinstall -y --force-yes install

        # FreeBSD:
             mtree -U -f /etc/mtree/BSD.root.dist
             mtree -U -f /etc/mtree/BSD.var.dist
             mtree -U -f /etc/mtree/BSD.include.dist
             mtree -U -f /etc/mtree/BSD.sendmail.dist
             mtree -U -f /etc/mtree/BSD.usr.dist

# AD
    # LDAP
        ldapsearch # Query AD and check if RFC 2307 attributes are present for a user or group.
        ldapsearch -x -H ldap://$ad_host -D "$sld.$tld" -W -b "dc=$sld,dc=$tld" "(sAMAccountName=$user)" uidNumber gidNumber

    # SSSD
        # sssd.service
        sudo systemctl enable --now sssd.service

        # sssd logs
        cat /var/log/sssd/sssd_$sld.$tld.log

        # sssd config
        cat /etc/sssd/sssd.conf
            # To use RFC 2037
                # ldap_id_mapping = False
                # ldap_user_object_class  = posixAccount
                # ldap_group_object_class = posixGroup
            # To *not* use RFC 2037
                # ldap_id_mapping = True
                ## Range for UID:GID mapped from AD SID must not conflict with local
                # ldap_idmap_range_min = 10000
                # ldap_idmap_range_max = 20000
            # Note "simple" access control provider allows LOGIN
            # per whitelist(s) of users and/or groups,
            # but does not affect file access of authenticated user
                # [domain/example.com]
                # id_provider = ad
                # auth_provider = ad
                # access_provider = simple
                # simple_allow_groups = admins, developers, support
                    # UPN (User Principal Name) format may be used :
                    # admins@<REALM>, e.g., admins@EXAMPLE.COM
            # @ Kerberos in use for authentication in SSSD
                # auth_provider = krb5
                # krb5_server   = <KDC server>
                # krb5_realm    = EXAMPLE.COM

        # ssd cache : Clear
        sudo sss_cache -E

    # KERBEROS : https://chatgpt.com/c/670f0f6c-d81c-8009-b437-30f0009a613c
        # Verify SSSD is using Kerberos for authentication:

        # Check for active tickets
        klist # The presence of a TGT (Ticket Granting Ticket) for krbtgt/REALM@REALM
            # indicates that Kerberos is in use for authenticating users.
            #=>
            # Ticket cache: FILE:/tmp/krb5cc_1000
            # Default principal: user@REALM

            # Valid starting       Expires              Service principal
            # 10/17/2022 08:01:32  10/17/2022 18:01:32  krbtgt/REALM@REALM

        /etc/sssd/sssd.conf
            # [domain/example.com]
            # auth_provider = krb5
            # krb5_server   = <KDC server>
            # krb5_realm    = EXAMPLE.COM

        # See : REF.Network.LDAP.sh

# SECURITY/AUDIT

    auditd # Linux Audit Daemon : CLIs : auditctl, ausearch, aureport
        # Enable/start now
            systemctl enable --now auditd.service
        # Summary report
            aureport # "Number of ..." : All the Things (itemized)
            aureport --help
                     --login
                     --auth
                     --failed
                     --syscall
                     --executable
        # View audit logs
            cat /var/log/audit/audit.log
        # List the active auditd rules
            auditctl -l
        # Search for specified event
            ausearch -k $id
        # Create TEMPORARY audit rules (does not survive reboot)
            # Monitor actions by specific user:
                id=user-1001-watch
                auditctl -a always,exit -F uid=1001 -S all -k $id
            # Monitor a file : `-p rwxa` : read (r), write (w), execute (x), and attr changes
                id=file-etc.shadow-watch
                auditctl -w /etc/shadow -p rwxa -k $id
            # Monitor "execve" system calls
                auditctl -a exit,always -F arch=b64 -S execve -k syscall-execve-watch
            # Monitor logins by specific user
                auditctl -a always,exit -F uid=1000 -S execve -k user-1000-login-watch
        # Create PERSISTENT audit rules (survives reboot)
            vi /etc/audit/rules.d/audit.rules
                -w /etc/shadow -p rwxa -k file-etc.shadow-watch

# SECURITY PROFILE

    oscap # OpenSCAP CLI : OpenSCAP : SCAP Security Guide (SSG)
        # SCAP is "Security Content Automation Protocol"
        # Install
        dnf install scap-security-guide openscap-utils -y
        # Evaluate OS against a profile:
        ssg=/usr/share/xml/scap/ssg/content/ssg-rhel8-xccdf.xml # RHEL 8 uses separate *-xccdf.xml files (checklists) and other files for different types of security content (like *.xml for OVAL definitions).
        ssg=/usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml    # RHEL 9 consolidates these into *-ds.xml (Data Stream) files, which include XCCDF, OVAL, and other necessary components in a single package. This makes it easier to manage and apply security content.
        id=cis
        oscap xccdf eval --profile $id $ssg
        # Remediate : Apply a profile's remediation script
        oscap xccdf eval --profile $id --remediate $ssg

        # Check compliance state by running scan against specific profile by "Id" :
        oscap xccdf eval --profile $id $ssg
        # List all available security profiles
        oscap info $ssg #... @ RHEL 9:
            # Document type: Source Data Stream
            # Imported: 2024-08-15T09:54:02

            # Stream: scap_org.open-scap_datastream_from_xccdf_ssg-rhel9-xccdf.xml
            # Generated: (null)
            # Version: 1.3
            # Checklists:
            #         Ref-Id: scap_org.open-scap_cref_ssg-rhel9-xccdf.xml
            #                 Status: draft
            #                 Generated: 2024-08-15
            #                 Resolved: true
            #                 Profiles:
            #                         Title: ANSSI-BP-028 (enhanced)
            #                                 Id: xccdf_org.ssgproject.content_profile_anssi_bp28_enhanced
            #                         ...
            #                         Title: CIS Red Hat Enterprise Linux 9 Benchmark for Level 1 - Server
            #                                 Id: xccdf_org.ssgproject.content_profile_cis_server_l1
            #                         ...
            #                         Title: DISA STIG for Red Hat Enterprise Linux 9
            #                                 Id: xccdf_org.ssgproject.content_profile_stig
            #                         Title: DISA STIG with GUI for Red Hat Enterprise Linux 9
            #                                 Id: xccdf_org.ssgproject.content_profile_stig_gui
            #                 Referenced check files:
            #                         ssg-rhel9-oval.xml
            #                                 system: http://oval.mitre.org/XMLSchema/oval-definitions-5
            #                         ssg-rhel9-ocil.xml
            #                                 system: http://scap.nist.gov/schema/ocil/2

        # The most commonly used profiles:
        # CIS (Center for Internet Security) Benchmarks:
            # Overview: The CIS benchmarks are among the most widely recognized best practices for securing systems. They offer detailed guidance on securing operating systems, applications, and services.
            # Purpose: Designed to reduce vulnerabilities and harden servers against attacks. They include recommendations for file permissions, network security, user management, patching, and more.
            # Applicable Industries: General use across industries, but especially common in financial services, healthcare, and public sector.
        # DISA STIG (Defense Information Systems Agency | Security Technical Implementation Guide):
            # Overview: STIG is the official guidance from DoD for securing IT systems.
            # Purpose: Provides highly detailed and prescriptive settings for securing systems, with an emphasis on reducing attack surfaces and meeting compliance requirements for government systems.
            # Applicable Industries: Primarily used in government and defense, but also adopted by industries that require strong security postures.
        # PCI-DSS (Payment Card Industry Data Security Standard):
            # Overview: PCI-DSS is a set of security standards designed to ensure that all companies that accept, process, store, or transmit CREDIT CARD INFORMATION maintain a secure environment.
            # Purpose: Focused on securing systems and applications that handle payment card data, including encryption, access control, logging, and vulnerability management.
            # Applicable Industries: Retail, e-commerce, finance, or any organization handling payment data.
        # NIST 800-53 and NIST 800-171 (National Institute of Standards and Technology):
            # Overview: The NIST standards are U.S. federal guidelines for securing information systems and protecting the confidentiality, integrity, and availability of federal data.
            # Purpose: Used to ensure systems meet federal security and privacy requirements. Provides controls for access management, logging, monitoring, and configuration management.
            # Applicable Industries: Federal agencies, but increasingly adopted by regulated industries (e.g., healthcare, energy).
        # ISO 27001:
            # Overview: ISO 27001 is an international standard for managing information security. It includes requirements for establishing, implementing, maintaining, and improving an information security management system (ISMS).
            # Purpose: Focused on managing risk to information assets by implementing security controls. It’s a widely recognized standard for compliance across industries.
            # Applicable Industries: General purpose, adopted across industries like finance, healthcare, IT services, and manufacturing.
