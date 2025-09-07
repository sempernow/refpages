#!/usr/bin/env bash
###############################################################################
# RHEL 8 : System Administration
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/8.9_release_notes/overview
###############################################################################
exit 0
######

# AD : realm + sssd
    # Install pkgs
    all='
        realmd 
        sssd 
        sssd-tools 
        samba-common 
        samba-common-tools 
        krb5-workstation 
        oddjob 
        oddjob-mkhomedir
    '
    dnf install -y $all

# Discover (inspect)
domain=lime.lan
dc=dc1.$domain

realm discover $dc
# Join
realm join --user=Administrator $dc
# List all realms discovered and configured
realm list # --all : include unconfigured realms
# Allow only users of an AD Group (by its name)
ad_group_name='Domain Admins'
realm permit "$ad_group_name"
# Allow all AD users
realm permit --all

# Enable sssd
systemctl enable --now sssd
# Test AD-user auth
id $any_ad_username@$(hostname -d)

# Allow for non-default configuration 
# of AD-users' HOME directory creation (per initial login)
systemctl enable --now oddjobd

sssctl config-check                     # Verify sssd config
journalctl -u sssd --no-pager |tail     # Inspect sssd logs
sudo cat /var/log/sssd/sssd.log |tail   # Inspect sssd logs

sssctl cache-remove u2  # Clear sssd cache
systemctl restart sssd  # Restart sssd (to apply changes)

# NFS : nfs-server

    # Install pkgs
    all='
        realmd 
        sssd 
        sssd-tools 
        samba-common 
        samba-common-tools 
        krb5-workstation 
        oddjob 
        oddjob-mkhomedir
    '
    sudo dnf install -y $all

    # Add services / Open ports 
    systemctl is-active firewalld &&
		cat <<-EOH |xargs -I{} sudo firewall-cmd --permanent --add-service={}
		kerberos
		dns
		ldap
		ldaps
		samba
		EOH

    systemctl is-active firewalld &&
        sudo firewall-cmd --reload

    # Mount (temporary)
    mount -t nfs4 -o vers=4.2 $nfs_server:$nfs_mount/ $local_mnt/

    systemctl restart nfs-server rpc-gssd
    systemctl status nfs-server 
    ps aux |grep nfsd       # Check running nfs processes
    ps aux |grep rpc        # Check running rpc.mountd
    exportfs -v             # Verify exports
    exportfs -rv            # Reload exports
    lsmod |grep nfs         # Verify kernel modules for nfs
    ss -tulpn |grep :2049   # Check nfs-server port

    showmount -e localhost
    cat /etc/exports

# Kerberos

    # Configurations
    - /etc/sssd/sssd.conf
    - /etc/pam.d/sshd
    - /etc/krb5.conf 

    # Regarding /etc/pam.d/
    authselect current     # Show current PAM profile
    # Configure /etc/sssd/sssd.conf for kerberos, then ...
    authselect select sssd #... configure PAM to use sssd.

    # Verify : By same CLI at RHEL (bash) and AD KDC (PowerShell) 
    klist                   # List Kerberos principals and tickets
    klist -f                # Check ticket expiry; error if expired
    keytab=/etc/krb5.keytab
    klist -k $keytab        # List keys of declared keytab file
    # Listed dual entries is normal; one per encryption type
        # Keytab name: FILE:/etc/krb5.keytab
        # KVNO Principal
        # ---- --------------------------------------------------------------------------
        #    2 A2$@LIME.LAN
        #    2 A2$@LIME.LAN
        #    2 host/A2@LIME.LAN
        #    2 host/A2@LIME.LAN
        #    2 host/a2.lime.lan@LIME.LAN
        #    2 host/a2.lime.lan@LIME.LAN
        #    2 RestrictedKrbHost/A2@LIME.LAN
        #    2 RestrictedKrbHost/A2@LIME.LAN
        #    2 RestrictedKrbHost/a2.lime.lan@LIME.LAN
        #    2 RestrictedKrbHost/a2.lime.lan@LIME.LAN

    # Create/Renew TGT (ticket-granting ticket) : Prompts for user's AD password
    kinit # Default (AD DS USER@REALM)
    # Else declare the principal
    realm=$(hostname -d)
    kinit $(id -un)@${realm^^}
    kinit u2@LIME.LAN 
    # Else from a declared keytab file
    kinit -k -t /etc/krb5.keytab nfs/a0.lime.lan
    # Test if AD KDC correctly issues a ticket at client(s) of SPN nfs/a0.lime.lan
    svc=nfs/a0.lime.lan
    kinit -S $svc u2@LIME.LAN

    kinit -R    # Renew ticket manually
    kdestroy    # Destroy all tickets
    kdestroy -A # Destroy all tickets and cache too

# DISABLE SPAM : RHEL 9 spams systemd journal (logs) with RedHat corporation marketing messages
    chmod -x /etc/update-motd.d/* # DISABLE
    chmod +x /etc/update-motd.d/* # ENABLE
    # Disable per user
    touch ~/.hushlogin

# LOGGING : Read systemd journal
    journalctl 
        -u NAME     # Of declared service (unit) NAME
        -e          # Jump to end (most recent)
        -x          # Augment with useful meta info 
        --no-pager  # Full message (else truncates per entry)

    # Recent journal messages (all services)
    journalctl -xe --no-pager

    # Recent journal of service
    journalctl --no-pager -xeu $service

    # Boot log
    journalctl -xb

# LOGGING 
    # See REF.Linux.SysAdmin.sh

# SERVICEs

    # See REF.Linux.SysAdmin.sh

# STORAGE / FILESYSTEM

    # See REF.RHEL.STORAGE.sh

    # SELinux : See REF.RHEL.SELinux.sh

    # HOME PARTITION : SHRINK 
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

# PKG MANAGERs : yum @ RHEL8- : dnf @ RHEL 8+

    dnf  # RHEL 8+
        dnf [options] COMMAND
        provides $pkg   # Versioninng reported here is often misleading; not the app version
        upgrade  $pkg 
        install  $pkg --disablerepo=* --enablerepo=$localrepo
        install  $pkg --nobest --allowerasing 
        download $pkg --archlist x86_64,noarch --alldeps --resolve
        remove   $pkg 
        info     $pkg   # Application details; version and such
        list --showduplicates COMMAND   # List ALL versions
        list available COMMAND          # List NEWER versionS (vs. that already installed)
        repolist
        repodiff --repo-old old1 --repo-new new1
        config-manager --disable $repo 
        makecache  # Create cache of all enabled repo data

    # Modules are part of Application Stream (AppStream) of RHEL8+;
    # collections of software packages grouped together and managed as a unit. They contain a set of RPM packages and metadata that define their default versions and available streams (app versions)
        # List Available Modules
        dnf module list
        # Enable a Module Stream (version) : To use a non-default version
        dnf module enable go-toolset:1.21
        # Install a Module
        dnf module install go-toolset
        # Switch app versions (streams)
        dnf module reset go-toolset
        dnf module enable go-toolset:1.18
        # Disable a Module : Prevent from being installed
        dnf module disable go-toolset

        # Change version without using package manager
        alternatives # Maintain symbolic links determining default commands
        # ... LINK NAME PATH PRIORITY
        alternatives --install /usr/bin/python python /usr/bin/python3.6 1
        alternatives --config python # List configured versions
        alternatives --list          # List all  

    rpm # A low-level utility; does not catch/manage conflicts/dependencies
        # Useful to access repo/pkg meta
        rpm -q COMMAND # RPM package + version
        rpm -qa # List all installed packages
        rpm -q COMMAND # RPM package + version

        # List meta of ALL PACKAGES installed
            for p in $(rpm -qa); do dnf info $p; done 

    # CVEs / PATCHes 
        # Test if a specific Linux kernel (RHEL version) is vulnerable to a declared CVE
            cve=CVE-2017-12190
            kernel=$(rpm -q --last kernel |head -1 |cut -d' ' -f1) 
            #=> kernel-5.14.0-427.37.1.el9_4.x86_64 
            dnf download $kernel # Download the kernel as an *.rpm
            rpm -qp $kernel.rpm --changelog |grep $cve

        # List available patches to the declared CVE
            dnf list --cve $cve | grep kernel.x86_64

        # Scan RPMs for CVEs : cve-bin-tool (python) : https://github.com/intel/cve-bin-tool
            pip install cve-bin-tool
            # Scan a folder or file containing RPMs 
            cve-bin-tool $path # -f csv,json,json2,html -o out
            # Scan an SBOM file
            cve-bin-tool --sbom ${spec:-cyclonedx} --sbom-file $sbom 

    # Add repo
        dnf install dnf-plugins-core
        dnf config-manager --add-repo $url 
        # E.g., EPEL repo of RHEL8
        dnf config-manager --add-repo https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64
        # Import GPG key
        rpm --import http://arepo.example.com/repo/RPM-GPG-KEY-arepo

    # AIR GAP 
        # 1. DOWNLOAD all packages (RPM) *and* all their dependencies (recurse). 
            ARCH="amd64"
            # Not all packages declare arch, esp. for those built *only* for x86_64 AKA amd64, hence "noarch" required.
            opts='--archlist x86_64,noarch --alldeps --resolve' # Both flags required to capture all necessary packages.
            # Not all packages are compatible with those (default) existing.
            try='--nobest --allowerasing'
            log="_dnf.download.opts.all.$(date '+%Y-%m-%d').log"
            # Example set of packages
            all='yum-utils dnf-plugins-core gcc make createrepo createrepo_c mkisofs iproute-tc bash-completion bind-utils unbound tar nc socat rsync lsof wget curl tcpdump traceroute nmap arp-scan iotop htop hdparm fio git httpd httpd-tools jq vim  ansible-core tree'
            # Prep
            dnf -y $try update 
            dnf -y makecache   
            # Download
            dnf -y download $opts $all 
        # 2. INSTALL : Two methods 
            # 2.a. Quick and Dirty™ : Install packages, but not ordered by deps, so some fail, so multiple runs required.  
                dnf -y install --nogpgcheck --nobest --allowerasing --disablerepo=* *.rpm
                # Else use rpm : even messier : doesn't resolve dependencies and it's a lower-level method.
                rpm -ihv *.rpm # Expect silent fails and such.
            # 2.b : PROPERly install : CREATE A LOCAL REPOsitory, so all deps managed as normally.
                # This method requires createrepo package, and so must be handled out-of-band
                dnf install createrepo # Implies RHEL repo access  
                # Create the local repo
                localrepo=localrepo
                mkdir -p /tmp/$localrepo
                mv *.rpm /tmp/$localrepo/
                createrepo /tmp/$localrepo
				cat <<-EOH |sudo tee /etc/yum.repos.d/$localrepo.repo
				[$localrepo]
				name=Local RPM Repository
				baseurl=file:///tmp/$localrepo
				enabled=1
				gpgcheck=0
				EOH
                dnf -y install --disablerepo=* --enablerepo=$localrepo $pkg_list

    # Auto-reboot when required ...
        yum install -y yum-utils 
        needs-restarting -r # returns 0 if reboot is not needed, else 1
        needs-restarting -s # what services need restarting

        #!/bin/bash
        LAST_KERNEL=$(rpm -q --last kernel |perl -pe 's/^kernel-(\S+).*/$1/' |head -1)
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

    # Make ISO of a YUM repo (by repo id)
        # Used by hypervisor 
        # Find "repo id" of desired repo from 
        yum repolist
        # Working dir
        mkdir -p repos;cd repos
        
        ## by reposync method (RHEL 8)
            yum -y update 
            yum -y install yum-utils createrepo createrepo_c xorriso
            # Download the repo including its metadata
            reposync --gpgcheck --repoid=$id --download-path=$(pwd) --downloadcomps --downloadonly --download-metadata
            # Create repo
            createrepo_c $id || sudo createrepo $id
            # Create ISO file
            makeisofs -o $id.iso -R -J -joliet-long $id

        ## By dnf reposync method (RHEL 9)
            dnf -y update 
            dnf -y install dnf-plugins-core createrepo_c genisoimage
            # Download the repo including its metadata
            dnf reposync --gpgcheck --repoid=$id --download-path=$(pwd) --downloadcomps --downloadonly --download-metadata
            # Create repo
            createrepo_c $id
            # Create ISO file
            genisoimage -o $id.iso -R -J -joliet-long $id

# PROCESS MANAGEMENT [create/monitor/kill]
    # See REF.Linux.SysAdmin.sh

# TASK SCHEDULING :: cron, at
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
            find /home/u1 -type d -print0 | xargs -0 chmod 0775
            find /home/u1 -type f -print0 | xargs -0 chmod 0664

        # @ all PACKAGES; perms and user/group id
            su /sbin/init 1
            for p in $(rpm -qa); do rpm --setperms $p; rpm --setugids $p; done

    # RESCUE MODE a.k.a. Single-User Mode a.k.a. Maintenance Mode a.k.a. runlevel 1
        # a.k.a. "Single User Mode" a.k.a. "runlevel 1"  
        # SWITCH TARGETS; switch modes
        # Many targets may be loaded @ any one operational state
        # List Unit files
        systemctl list-unit-files           # All installed +status of each
        systemctl list-units --type=target  # All active

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
