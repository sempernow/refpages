#!/bin/bash
exit
# BOOT MESSAGEs 
    journalctl -xb # boot log 

# MAINENTANCE MODE 
    # RESCUE MODE a.k.a. Single-User Mode a.k.a. Maintenance Mode a.k.a. runlevel 1
    # a.k.a. "Single User Mode" a.k.a. "runlevel 1"  
    # SWITCH TARGETS; switch modes
    #   many targets may be loaded @ any one operational state
        # show all loaded targets
        systemctl list-units --type=target 

            systemctl isolate rescue.target
            exit # or CTRL+D to switch back
            # change to runlevel 1;
                su /sbin/init 1   
            # show current runlevel 
                /sbin/runlevel

    # @ ONLINE terminal; if system boots
    # http://www.linfo.org/change_to_single_user.html  
        su /sbin/init 1  # change to runlevel 1
        # show current runlevel 
        /sbin/runlevel

        # ===  OR  ===

        # EMERGENCY MODE per systemctl
            systemctl isolate emergency.target
            systemctl reboot    # exit
            systemctl systemctl # exit

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

    # ===  OR  ===

    # @ GRUB menu :: enter RESCUE|EMERGENCY [mode/target/environmnet] 
        # Press 'e' to open grub menu settings
        # @ 'linux16...' line, APPEND ... 
            systemd.unit=rescue.target    # RESCUE    [mode/target/environmnet]
            systemd.unit=emergency.target # EMERGENCY [mode/target/environmnet]
        # CTRL+X to restart
            systemctl default
            systemctl reboot

# YUM :: PKG MANAGER

    # Update kernel
    yum -y update kernel

    # Upgrade ALL pkgs 
    for p in $(rpm -qa); do yum -y upgrade $p; done 
    # or simply 
    yum -y upgrade

    # repo-based info; 'Installed' & 'Available' Packages
    yum info PKG
    # Download and install ...
    yum install PKG

    # auto-reboot when required ...
    yum install -y yum-utils 
    needs-restarting -r # returns 0 if reboot is not needed, else 1
    needs-restarting -s # what services need restarting

        #!/bin/bash
        LAST_KERNEL=$(rpm -q --last kernel | perl -pe 's/^kernel-(\S+).*/$1/' | head -1)
        CURRENT_KERNEL=$(uname -r)
        [[ $LAST_KERNEL == $CURRENT_KERNEL ]] || printf "\n  %s\n\n" 'REBOOT NOW to complete kernel update'

    yum remove pkg # protects; fails if dependencies exist
    # LOCAL PKG [outside any repositories] install ...
    yum localinstall PKG # and will get dependencies from repo 
    yum list           # list all packages in repo   
    yum list installed # list all installed packages 
    yum list installed | grep @epel  # list those from `epel` repo 
    # search packages per word [substr of pkg-name]
    yum search PKG-substr 
    # search packages per binary fname
    yum whatprovides */binaryname
    yum provides     */binaryname  # identical

    # list available repositories 
    yum repolist 
    # list available package groups
    yum group list [[hidden] ids]
    # INSTALL a GROUP
    yum group install graphical-server-environment # install per id; worked
    yum group install server-platform              # NOPE !
    # list available from a specified repo per repo id
    yum --disablerepo="*" --enablerepo="REPO_ID" list available
    /etc/yum.repos.d # all repos


# SELinux
    ## Show status
    sestatus
    ## Disable temporarily 
    sudo setenforce 0
    ## Disable persistently
    sudo vim /etc/selinux/config
        # SELINUX=disabled
    # Reboot to take effect
    sudo shutdown -r now

# PROCESS MANAGEMENT [create/monitor/kill]
    # See REF.Linux.SysAdmin.sh

# TASK SCHEDULING :: cron, at
    # See REF.Linux.SysAdmin.sh

# LOGGING 
    # See REF.Linux.SysAdmin.sh

# PRIORITIES & NICENESS [ps + grep]
    # See REF.Linux.SysAdmin.sh

# POWER MANAGEMENT  pm-action (8)

    CentOS-6            CentOS-7 [systemd]

    halt                systemctl halt  
    poweroff            systemctl poweroff  
    reboot              systemctl reboot 
    pm-suspend          systemctl suspend
    pm-hibernate        systemctl hibernate  
    pm-suspend-hybrid   systemctl hybrid-sleep

    # See REF.Linux.SysAdmin.sh

# SERVICEs

    # See REF.Linux.SysAdmin.sh

# STORAGE / FILESYSTEM

    # See REF.RHEL.STORAGE.sh

    # SELinux :: RESTORE USER's HOME DIR to default rules
        # restore all context, template files, etc.
        cd /
        sudo restorecon -RFv /home/uZer
        sudo restorecon -RFv /home/uZer/*
        sudo restorecon -RFv /home/uZer/*.*
        sudo restorecon -RFv /home/uZer/.*

    # HOME PARTITION :: SHRINK 
        # give space to root partition; save and restore home; 
        # all @ lv '/dev/mapper/c7'
        # run as root in SINGLE USER MODE, '/sbin/init 1'
        umount /dev/mapper/c7-home
        lvremove /dev/mapper/c7-home
        lvcreate -L 1GB -n home c7
        mkfs.xfs /dev/c7/home
        mount /dev/mapper/c7-home
        lvextend -r -l +100%FREE /dev/mapper/c7-root
        tar -xzvf /root/home.tgz -C /home
        # Check for valid UUIDs @ /etc/fstab ...
        cat /etc/fstab

# MAINENTANCE MODE

    # Single User Mode a.k.a. runlevel 1 a.k.a. Maintenance Mode 
    # http://www.linfo.org/change_to_single_user.html
        su /sbin/init 1  # change to runlevel 1

        # show current runlevel 
        /sbin/runlevel

    # Reset/restore USER/GROUP PERMS to default
        # run as su (root) ...
        # switch to single-user-mode ...
        su /sbin/init 1
        
        # @ HOME dirs/files
            find /home/uZer -type d -print0 | xargs -0 chmod 0775
            find /home/uZer -type f -print0 | xargs -0 chmod 0664

        # @ all PACKAGES; perms and user/group id
            su /sbin/init 1
            for p in $(rpm -qa); do rpm --setperms $p; rpm --setugids $p; done
