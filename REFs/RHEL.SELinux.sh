#!/usr/bin/env bash
###############################################################################
# SELinux [Security Enhanced Linux] : File AND Process Security Policy 
# RHEL8 Doc:
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/changing-selinux-states-and-modes_using-selinux
###############################################################################
exit 0
######

# TROUBLESHOOTING : SELinux fcontext: USER:ROLE:TYPE
    # Set to permissive, restart the problemed service; problem fixed?

    getenforce  # Shows: Enforcing, Permissive, or Disabled
    sestatus    # More detailed output

    # Automatically Diagnose via sealert 
    sudo sealert -a /var/log/audit/audit.log
    # List all known SELinux alerts that the setroubleshoot daemon has logged and categorized.
    sudo sealert -l "*"

    # 1. Most recent AVC denials
    sudo ausearch -m avc -ts recent # -ui UID -gi GID -m AVC,USER_AVC,SELINUX_ERR,USER_SELINUX_ERR
    # 2. All recent SELinux audit messages:
    sudo journalctl -t setroubleshoot --since "1 hour ago"
    # 3. Explain Denials with audit2why
    sudo ausearch -m avc -ts recent |audit2why
    # 4. Suggest Allow Rules with audit2allow : USE WITH CAUTION
    sudo ausearch -m avc -ts recent |sudo audit2allow -a
    # 5. Fix Wrong File Contexts
    ls -Z $file                 # Show current SELinux context of a file (path)
    sudo restorecon -v $file    # Restore expected context @ file
    ls -Z $dir                  # Show current SELinux context of dir (path)
    sudo restorecon -vR $dir    # Restore expected context @ dir (recursively)
    # 6. Check File’s Expected Context
    sudo matchpathcon $file
    # 7. Set to permissive (temporarily)
    sudo setenforce 0
    # 8. Rebuild or Reload Policies
    sudo semodule -l        # List installed modules
    sudo semodule -B        # Rebuild and reload policy modules

    # Relabel entire filesystem on boot
    sudo touch /.autorelabel # First set SELinux to Permissive, then reboot, then reset to Enforcing and delete /.autorelabel, then reboot.
    # Clear audit log
    sudo logrotate -f /etc/logrotate.d/audit
    sudo truncate -s 0 /var/log/audit/audit.log

    # NFS SRV:EXPORT v. K8s nfs PV (Pod/Containers) : Fix access denials 
    # Allow rw at container path mounted under NFS export /srv/nfs/k8s : See `man semanage-fcontext` 
    sudo semanage fcontext --add --type public_content_rw_t '/srv/nfs/k8s(/.*)?' 
    sudo restorecon -Rv /srv/nfs/k8s # Export path at (remote) host of NFS server

# INSTALL
    # Install/Verify all the SELinux troubleshooting tools are available
    dnf install -y selinux-policy-targeted libselinux-utils policycoreutils setroubleshoot-server policycoreutils-python-utils

# CONFIGURE

    # View status
        getenforce  # Enforcing|Permissive
        sestatus    # Status and info of SELinux 

    # Set mode temporarily : Toggle to troubleshoot : Does not survive reboot
        setenforce 0|1 # permissive|enforcing

    # Set mode persistently : Survives and takes effect on reboot
    vi /etc/selinux/config 
        # SELINUX=enforcing
        # SELINUXTYPE=targeted

        ## Automate (idempotent)
        ## Set to Permissive
        sudo sed -i -e 's/^SELINUX=disabled/SELINUX=permissive/' /etc/selinux/config
        sudo sed -i -e 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
        ## Set to Enforcing
        sudo sed -i -e 's/^SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config
        sudo sed -i -e 's/^SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config


        ## Manual
        sudo vim /etc/selinux/config
            # SELINUX=permissive
        
        ## Reboot to take effect
        sudo shutdown -r now

    auditd # Linux Audit Daemon : SELinux audit logs
        systemctl enable --now auditd.service

    auditctl # CLI for auditd.service
        # List the active auditd rules
        auditctl -l 
        # List DENIALs : "AVC: ... denied"
        cat /var/log/audit/audit.log |grep avc
        # View denials after set/reboot to Enforcing 
        ausearch -m AVC,USER_AVC,SELINUX_ERR,USER_SELINUX_ERR -ts today
        # Otherwise by process:
        ausearch -m avc -c $process_name  
        # Fix unknown Application : When app behavior isn't covered by default policy
            audit2allow
            semodule
            # If DENIALS in SELinux due to restrictive policies, 
            # review the logs (/var/log/audit/audit.log) and, 
            # if needed, GENERATE a POLICY MODULE that allows the behavior:
            ausearch -m avc -ts recent | audit2allow -M this_app_module
            semodule -i this_app_module.pp

    # If audit daemon not running, then use dmesg:
        dmesg |grep -i -e type=1300 -e type=1400

    # If setroubleshoot-server pkg is installed:
        grep "SELinux is preventing" /var/log/messages
        sealert -l "*"
    
    # Fix : See `man fixfiles`
        fixfiles -F onboot # Force reset of context for customizable files
        fixfiles -R $pkg check  # Check labels on $pkg

    # KNOWN Applications
        # Adjust policies : Allow Apache to use port 443
        semanage port -a -t http_port_t -p tcp 443 

    # Recursively relabel a directory
        restorecon -vR  FOLDER            # Update SELinux policies at affected folder

        systemctl restart SERVICE         # now see if it works sans SELinux 
        systemctl status SERVICE          # shows LOG of ACTIVITY for that service

        ls -ZA                            # show SECURITY CONTEXT; LABEL per USER:ROLE:TYPE 

    # RESTORE security contexts
        restorecon # restore security contexts
        # E.g., fix all files under a folder, e.g., /home/$USER .
        # Optionally reset all regardless (-F), else only those SELinux thinks are in error.
        _restorecon(){
            [[ -d $1 ]] || return 99
            [[ $2 ]] && regardless=F || unset regardless
            restorecon -Rv$regardless $1
            restorecon -Rv$regardless $1/*
            restorecon -Rv$regardless $1/*.*
            restorecon -Rv$regardless $1/.*
        }
        sudo _restorcon 

    # Examine http
        semanage port -l |grep http
        # Change the SELinux type of port 3131 to match port 80: 
        semanage port --add --type http_port_t -p tcp 3131

    # Change SELinux type of /target content to that of /source
        semanage fcontext --add --equal /target /source # See `man semanage-fcontext`

        # Configure a non-standard ($alt) HOME for local user that SELinux treats as it would those of /home
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

    # Identify SELinux booleans relevant for NFS, CIFS, and Apache:
        semanage boolean -l |grep 'nfs\|cifs' |grep httpd
    # Enable the identified booleans: 
        setsebool httpd_use_nfs on
        setsebool httpd_use_cifs on
    # Verify booleans are on
        getsebool -a |grep 'nfs\|cifs' |grep httpd


# Enforces MAC (Mandatory Access Control) vs. Linux's DAC (Discretionary Access Control)
    # SECURITY CONTEXT: 3-string (label) context assigned to EVERY user AND process
    #  USER:ROLE:TYPE[domain]
    #   Type Enforcement; on processes and file system objects; object types; policy rules
    #   MCS [Multi Category Security] Enforcement; Roles?
    #   MLS [Multi Level Security] Enforcement; control processes based on the level of the data they; not used much
    # SELinux users and roles do not have to be related to the actual system users and roles.
    # https://en.wikipedia.org/wiki/Security-Enhanced_Linux
    # https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/SELinux_Users_and_Administrators_Guide/sect-Security-Enhanced_Linux-Introduction-SELinux_Architecture.html
    # UPG : User Private Groups; each user gets own group 
    # Typical UNIX umask of 022 [set @ /etc/bashrc] unnecessary, since group is private
    id # =>
        uid=500(foo) gid=500(foo) groups=500(foo),4(adm),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

    # RHEL / SELinux utilities
        useradd(8)      # create new users.
        userdel(8)      # delete users.
        usermod(8) 	    # modify users.
        groupadd(8)     # create new groups.
        groupdel(8)     # delete groups.
        groupmod(8)     # modify group membership.
        gpasswd(1)      # manage /etc/group file.
        grpck(8)        # verify integrity of /etc/group file.
        pwck(8)         # verify integrity of /etc/passwd AND /etc/shadow files.
        pwconv(8)       # pwconv, pwunconv, grpconv, grpunconv; convert shadowed info (pw,groups)
        id(1)           # display user and group IDs.
        umask(2)        # work with file mode creation mask. 

        # Add user foo to sudo group
        sudo usermod -a -G sudo foo 

        # Create a new group named foo
        sudo groupadd foo 

    # RHEL / SELinux files
        group(5)    # /etc/group; define system groups.
        passwd(5)   # /etc/passwd; define user information.
        shadow(5)   # /etc/shadow; set passwords and account expiration info 

    # SELinux MODE [enforcing|permissive]; set per boot
        /etc/sysconfig/selinux 
            SELINUX=enforcing
            
                enforcing  # log & stop  syscall if avc:denied
                permissive # log & allow syscall if avc:denied
                disabled   # No SELinux functionality
                
    # Functional Diagram
        syscall # [every process] => SELinux => policy [avc:denied] => auditd 
                                
        # auditd [AUDIT DAEMON]						
            /etc/audit/auditd.conf
            /var/log/audit/audit.log # all SELinux events

    # TROUBLESHOOT : turn selinux on/off 
    getenforce 
    setenforce {enforcing|permissive} # can toggle to troubleshoot
    setenforce 0|1                    # ... or that way 

    # CONTEXT : 3 Parts [USER:ROLE:TYPE] [RHCSA focuses only on TYPE]

        # @ Files; show SECURITY CONTEXT; LABEL per USER:ROLE:TYPE 
            ls -Z /foo # =>
                drwxrwxr-x. u1 u1 unconfined_u:object_r:user_home_t:s0 scripts
                -rwxrwxr-x. u1 u1 unconfined_u:object_r:user_home_t:s0 _u1.cfg
                
                # on copy, context inherited from destination parent [typically]
                # on move, context moves with the dir/file [typically]
                
        # @ Processes; show SECURITY CONTEXT; USER:ROLE:TYPE
            ps Zaux # =>
                system_u:system_r:sshd_t:s0-s0:c0.c1023 878 ?  Ss     0:00 /usr/sbin/sshd
                system_u:system_r:sshd_t:s0-s0:c0.c1023 4079 ? Ss     0:00 sshd: u1 [priv]

            netstat -Ztulpen # =>
                tcp  ... 0.0.0.0:22 ...  878/sshd  system_u:system_r:sshd_t:s0-s0:c0.c1023

    # BOOLEANS : off|on <==> PREVENT(off) OR ALLOW(on)
        getsebool -a | grep ssh # =>
            fenced_can_ssh --> off
            selinuxuser_use_ssh_chroot --> off
            ssh_chroot_rw_homedirs --> off
            ssh_keysign --> off
            ssh_sysadm_login --> off
        
        # SET BOOLEAN
        # -P(persistent)
        setsebool [ -PNV ] boolean value | bool1=val1 bool2=val2 

            # E.g., allow ftp users to access their home dir 
            getsebool -a | grep ftp
            setsebool ftp_home_dir on 
            semanage boolean -l | grep ftp # =>
            BOOLEAN (CURRENT_VALUE,DEFAULT_VALUE) ...
        
# WHY SELinux : Hacked [Story] : Developer under admin was hacked thru PHP backdoor; invader opened a shell and stored large number of PHP scripts on victim (admin) machine; scripts used to attack others. Web sites require access and executables @ '/tmp' and '/var/tmp'; Permissions needed too; Firewalling shouldn't block access either. So, Linux hasn't many options to secure. 

    # SELinux sets access to files and other resources BY PROCESSes per policy (rules); 
        # specifies what each process is allowed to do rather than directly setting access to files themselves.

    # CONTEXT of httpd process ...
    ps -Zaux | grep http # =>
        system_u:system_r:httpd_t:s0 ... /usr/sbin/httpd
        
    # CONTEXT of files @ Apache [httpd] access
        # Apache document root dir, '/var/www/html', has CONTEXT [TYPE]: 'httpd_sys_content_t'
        ls -Z /var/www # =>
            drwxr-xr-x. root root system_u:object_r:httpd_sys_script_exec_t:s0 cgi-bin
            drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 html
        # /tmp dir has CONTEXT [TYPE]: 'tmp_t'
        ls -Zdl /tmp # =>
            drwxrwxrwt. 11 system_u:object_r:tmp_t:s0       root root 240 Feb 12 10:45 /tmp

# CONFIGURE SELinux : semanage : See `man semanage-fcontext`
    # semanage writes to SELinux POLICY, not to FS
        # E.g., fix context for web-site's DocumentRoot access 
            # Reset DocumentRoot @ /etc/httpd/conf/httpd.conf  
            semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?" # ... RegEx
            restorecon -R -v /web # (re)writes to FS and validates, per POLICY; 
                                            # restores any FS CONTEXT errors, per POLICY
            
        # E.g., fix port binding ... 
            # Reset DocumentRoot @ /etc/httpd/conf/httpd.conf]  
            semanage port -a -t http_port_t -p tcp 8888
            restorecon -R -v /web
            # ... NOPE; failed.
        
    # chcon : NEVER USE IT; BAD PROGRAM
    #  Writes directly to FS, NOT to POLICY
    #  Subsequent relabeling resets per policy
        # E.g., say need to set context label 'httpd_sys_content_t' on /foo dir
        chron -R --type=httpd_sys_content_t /blah       # BAD 
        semanage -a -t httpd_sys_content_t "/foo(/.*)?" # GOOD
        # semanage writes to POLICY which then writes to FS
        
    # FIND LABELs : per CONTEXT USER:ROLE:TYPE
        semanage fcontext -l # list all CONTEXTs; very long list
        # man page for each context/service
        # CentOS-6 [legacy]; very helpful
            man -k _selinux  
        # CentOS-7 # not installed by default
            yum -y install policycoreutils-devel
            sepolicy manpage -a # FAILed; 'No such file or directory...' 
            mandb
            man -k _selinux
    
    # TROUBLESHOOTing 
        yum list installed | grep setrouble # should be installed by default

        # SELinux decisions, such as allowing or disallowing access, are cached.
        # AVC [Access Vector Cache]; 
        # Denial messages; AVC denials"; logged to location per daemon
        # Daemon	                                    Log Location
        auditd on                                    /var/log/audit/audit.log
        auditd off; rsyslogd on	                     /var/log/messages
        setroubleshootd, rsyslogd, and auditd on	   /var/log/audit/audit.log
        Easier-to-read denial messages also sent to  /var/log/messages
        
        # AUDIT LOG : header 'AVC'
        /var/log/audit/audit.log
        
        systemctl status auditd
        grep AVC /var/log/audit/audit.log
        
        less /var/log/messages
