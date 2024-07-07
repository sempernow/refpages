#!/usr/bin/env bash
###############################################################################
# Linux System Administration Basics
# https://www.linode.com/docs/tools-reference/linux-system-administration-basics/   
###############################################################################
exit 0
######

# Set default editor
    sudo update-alternatives --config editor

# NETWORK 

    # Host
    hostname    # hostname of this machine
    hostname -f # FQDN

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
            timedatectl list-timezones | grep America
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
            sudo apt update
            sudo apt install ntp

            # Enable (per timedatectl) 
            sudo timedatectl set-ntp true

        # ntpq : https://linux.die.net/man/8/ntpq : https://doc.ntp.org/archives/3-5.93e/ntpq/
            # Vital @ private-subnet nodes whereof network synch is required yet 
            # their web access is only thru SOCKS5 proxy; timedatectl FAILs thereof.
            sudo apt update
            sudo apt install ntp  

            # Inspect settings : pool of servers
            ntpq -p

            # Enable per timedatectl 
            sudo timedatectl set-ntp true  # disable per `false`

# MACHINE RESOURCES
    
    # Storage 
        df -hT      # Per device    
        du -h       # Disk usage per directory under PWD
        du -hs $dir # Disk usage summary of all folders thereunder (default is PWD)

    # CPU info
        cat /proc/cpuinfo
        lscpu 
        
    # Memory info
        free -mh  # Units of Mi 
        htop 
            # RSS (Resident Set Size) : Actual physical memory used by the process
            # - Total physical memory must be greater than sum of all RSS across all running processes. 
            # VIRT (Virtual Memory Size) : Total virtual memory the process can access;
            # - Incl. memory that was swapped out, memory that is mapped but not used, and shared memory.
        ps aux --sort=-%mem |head -n 10 
            # RSS (Resident Set Size) : Actual physical memory used by the process
            # - Total physical memory must be greater than sum of all RSS across all running processes. 
            # VSZ (Virtual-memory SiZe) in KiB; equivalent to htop's VIRT.
            # - Incl. memory that was swapped out, memory that is mapped but not used, and shared memory.

            # Example:
            process=containerd
            ps aux |grep -e RSS -e $process
                USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
                root      1234  0.5  2.1 2097152 43152 ?       Ssl  10:00   1:23 /usr/bin/containerd
                # - VSZ (Virtual-memory SiZe) is 2097152 KiB (roughly 2GB).
                # - RES (Resident Memory Size) is 43152 KiB (roughly 42MiB).

    # I/O Usage
        vmstat -d 
 
# OS : Get/Set hostname/info
    hostnamectl 
    # OS info
    cat /etc/os-release
    alias os='cat /etc/os-release'

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

        /etc/systemd/system # Location of all unit (service) files

        # Create a service for COMMAND (quickly)
            sudo systemctl enable --now COMMAND
        # Delete a service
            sudo systemctl disable --now COMMAND

        # Create : Example : ssh-user-sessions.service
            sudo vi /etc/systemd/system/ssh-sessions.service # Edit:
            
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
            sudo vi /etc/systemd/system/keepAwake.service # Edit:

                [Unit]
                Description=Inhibit suspend
                Before=sleep.target

                [Service]
                Type=oneshot
                ExecStart=/usr/bin/sh -c "(( $( who | grep -cv '(:' ) > 0 )) && exit 1"

                [Install]
                RequiredBy=sleep.target

    # LECAGCY METHOS (RHEL 6)
        # ... runs all executables (hooks) @ ...
        /etc/pm/sleep.d 

    # SUSPENSION IS PREVENTED if any such script returns [$?] non-zero exit status.
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
    # RHEL
        yum  
        dnf  # RHEL 8+
        # See REF.RHEL.SysAdmin.sh
 
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
        sudo dpkg -l 
        # List all possible residue
        sudo dpkg --get-selections | grep deinstall

        # Remove all packages of KEYWORD
        sudo dpkg -l |grep KEYWORD |awk '{print $2}' |xargs -I {} sudo apt remove -y {}

        # Remove all configuration residue that `apt remove` fails to remove.
        sudo dpkg --purge $(dpkg --get-selections | grep deinstall | cut -f1)

# SYSTEM 

    uname -a  # All system info
        -rsv    # kernel release, name, version 
        -nmpio  # node (hostname), machine , processor, hardware, os

    # Kernel Modules
        lsmod                   # List all loaded kernel modules
        sudo modprobe $module   # Load a kernel module now (ephemeral)
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
    
    # Create symlink : Removing (rm) symlink does not affect the actual (target) file
    ln -s /path/to/target/file [/path/to/sym/link] # Default symlink path is $(pwd)/file
    
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
 
    # Get MIN MAX values of UID:GID for REGULAR and SYSTEM accounts (users, groups)
        cat /etc/login.defs

    # user, pass : ADD user, SET PW
        adduser $user            # create new user
        passwd $user             # (re)set user's password  

        # Get username from uid
            uname_of_uid(){ cat /etc/passwd |grep ":x:${1}:" |awk -F ':' '{print $1}'; }
            uname_of_uid 1000

        # Add a secure SSH-users account (user:group) at target machines.
            # Add user:group foo:foo having no password, and so disabling password-based shell login.
            # This is useful for remote user(s) to login as this user by ssh; 
            # allowing only (ssh) key-based authtentication.
            # Each user would have to add their public key to this user's ~/.ssh/authorized_keys file,
            # and do so by some out-of-band (not ssh-copy-id) process requiring elevated privileges.
            useradd -m -s /bin/bash foo

        # Add user:group (foo:foo) of declared IDs
            # having UID:GID 1001:1001, 
            # having NO HOME DIRECTORY
            groupadd --gid 1001 foo
            adduser --uid 1001 --gid 1001 --gecos "" --disabled-password --no-create-home foo

        # Add a SYSTEM (-r) user:group $u:$u having home directory and no login shell
            groupadd -r $u
            useradd -r -m -g $u -s /bin/false $u

        # Get entitites (GID, name, ...) from Name Service Switch library
            # Useful to test for existence of subject
            getent group foo 
            getent passwd foo

        # Add user to group
            usermod -aG $group $user 
            newgrp docker # Supposedly to take effect now, but side effects linger. Better to logout/login 
            # OR
            gpasswd -a $user group 

        # Remove a user from a grop
            gpasswd -d $user $group

        # List groups to which user has membership
        groups foo

        # LIST : group / members 
        cat /etc/group 
        getent group NAME

        # Change owner (UID:GID) of /mnt1, recursively
        chown -R 1000:777 /path
        # Change owner to current user:group
        chown -R $(id -u):$(id -g) /path

        # sudoers GROUP : ADD USER | sudoers(5) https://linux.die.net/man/5/sudoers   
        usermod -aG wheel $user  # RHEL/CentOS/Fedora (wheel group)
        usermod -aG sudo $user   # Ubuntu/Debian      (sudo group)

        # CHANGE NAME : user
            usermod -l <newname> -d /home/<newname> -m <oldname>
        # CHANGE NAME : group
            groupmod -n <newgroup> <oldgroup>
        # CHANGE PASSWORD
            passwd $user 
            # Batch password change
            chpasswd  # batch process cmd; must be root user 
            # set the root acct pw to the ssh pw 
            echo  "root:$SSH_USERPASS" | chpasswd
        # Delete user's PASSWORD; may/not prevent login with no password
        sudo passwd -d $user
        # Lock user account from password-authenticated login
        sudo passwd -l $user
        # CHANGE : HOME dir : default is /home/$USER
            sudo vim /etc/passwd  # E.g., from `/home/uZer` to `/mnt/s/HOME`
            # sudo(8)  https://linux.die.net/man/8/sudo 
            # ... edit @ username, then reboot
                sudo COMMAND # has very limited PATH; TERM, PATH, HOME, SHELL, LOGNAME, USER, USERNAME 
                # ... to add more paths, modify: | sudoers(5) https://linux.die.net/man/5/sudoers   
                /etc/sudoers.d 
                    env_check
                    env_keep 
                    # a whitelist for environment variables.

    # sudo / su 
        sudo su 
        sudo -E su  # preserve environment 
        sudo -l     # List commands allowed a sudoer

    # sudoers FILE
        /etc/sudoers # The baseline sudoers file
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
                sudo visudo /etc/sudoers/ops
                ## Allow group 'ops' members to run declared (CSV) list of (sub)commands/flags:
                # Cmnd_Alias  GROUP_OPS_CMDS =  /usr/bin/dnf update, \
                #                         /usr/bin/systemctl status *, \
                #                         /usr/bin/systemctl list-unit-files, \
                #                         /usr/bin/systemctl start apache2, \
                #                         /usr/bin/journalctl, \
                #                         /usr/bin/firewalld --list-all *, \
                #                         /usr/bin/firewalld --get-services, \
                #                         /usr/bin/firewalld --permanent --info-service=*
                ##...Allow sans password:
                # %ops ALL=(ALL) NOPASSWD: GROUP_OPS_CMDS
                ## Modify sudo PATH (secure_path) for group 'ops':
                # Defaults:%ops secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
                ## Similar, but password required (per timestamp_timeout setting):
                # %ops ALL=(ALL) GROUP_OPS_CMDS
                ## Similar, but group declared by its GID
                # %#2222 ALL=(ALL) GROUP_OPS_CMDS
            # Set timeout for sudo password entry
                Defaults timestamp_timeout=-1 # Once per terminal session
                Defaults timestamp_timeout=60 # 60 minutes 
                # Scoped to user
                Defaults:tom timestamp_timeout=-1
                # Scoped to group
                Defaults:%opstimestamp_timeout=-1
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

    top     # Dynamic real-time view of a running linux system;  
            # system summary; list of processes/threads managed by kernel.
    htop    # Newer/nicer top
    pstree  # Shows parent/child tree structure of processes
    ps      # Snapshot of current processes [syntax:UNIX|BSD|GNU]
        ps aux  # list all process + owner of this user;...
                        # all [a]; user [u]; incl external to shell [x]
            # fields ... 
            USER   
            PID      # Process ID
            %CPU 
            %MEM     # https://povilasv.me/go-memory-management/ 
            VSZ      # bytes of RAM reserved (Virtual Memory Size)
            RSS      # bytes of RAM allocated (Resident Set Size)
            TTY      # current-terminal:'pts/0', background-process:'?'
            STAT     # status : sleep:'S', running:'R'
            START  
            TIME 
            COMMAND  # the command that lauched it
            
        ps aux |wc -l # get the number of running processes 

        # monitor process $1; show/stream its `ps` status @ tty11; write to syslog on stop
            while ps aux | grep $1 | grep -v grep | grep -v bash > /dev/tty11 
            do; sleep 1; done 
            logger $1 has stopped.  # send to syslog; `/var/log/messages`

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
            #  all STORED @ [CentOS 6] ... 
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
