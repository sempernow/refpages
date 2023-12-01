#!/bin/bash
# ----------------------------------------------------------------------------
#  CentOS 6.8 + 7 :: Linux/Shell commands 
#  https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/part-Basic_System_Configuration.html
#  CentOS is FOSS version of RHEL [Red Hat Enterprise Linux]
#  CentOS is most popular AMI [Amazon Machine Image] 
#    @ AWS [Amazon Web Services]; EC2, EBS [Elastic Beanstalk]
#    https://aws.amazon.com/marketplace
# 
#  CentOS/RHEL7 is Linux kernel 3.10; systemd 208; GNOME 3.8 (3.22 @ RHEL7.4)
#    https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux
# 
#  See txt files @ 'IT\...\LPIC-1 and CompTIA-Linux+ Certification'
#  for more RedHat reference info 
# 
#  ***  DO NOT EXECUTE  ***
# ----------------------------------------------------------------------------
exit

# CentOS = RedHat = RHEL = Fedora
# RedHat versions 6 [legacy] vs. 7 [systemd]
#   http://simplylinuxfaq.blogspot.com/p/major-difference-between-rhel-7-and-6.html
# INSTALL "Server with GUI" + "Development Tools"
# or, LIVE version; torrent download > Rufus > USB ...
#   'CentOS Linux release 7.3.1611 (Core)'
#   @ CentOS-7-x86_64-LiveGNOME-1611.iso 
# "Device Selection" > "Other Storage Options" > "I will configure ..." 
# intall menu/task flow is NOT sequential; uses star logic ...
  # Repeat + "Update Settings" [button] for each partition; 
  #   from "Unknown" list, select free partition, and 
  #   create 3 Logical Partitions:
    /         SYSTEM   10 GB
    swap      swap      2 GB
    /home     DATA      5 GB
    
    /boot     ???      .5 GB # separate? outside LVM?
  
# OS version info ...
cat /etc/system-release # symlinks; 'ls -l /etc/*-release'
    # e.g., ... 
    CentOS release 6.8 (Final) # ... or ...
    CentOS Linux release 7.3.1611 (Core)

# SERVICEs MANAGEMENT :: system daemon [systemd]
  # https://coreos.com/os/docs/latest/getting-started-with-systemd.html  
  # RHEL 7 [systemd] :: start|stop|disable|enable|status|is-active|is-enabled
    systemctl ACTION SERVICEname

    systemctl {enable|disable} SERVICEname # start|stop on boot

    systemctl list-unit-files --type service # show config status
  
    # FULL SPEC; the '.service' is assumed if absent
    systemctl ACTION SERVICEname.service 
    
    systemctl rescue    # change to rescue mode 
    systemctl emergency  # change to emergency mode; minimal env.
    # https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/sect-Managing_Services_with_systemd-Targets.html

    # SYSTEM STATUS :: TROUBLESHOOTING  
      systemctl         # lists all `loaded active` units 
      systemctl status  # summary; shows any failed 
      # if `State: degraded`, it means some process(es) failed 
      # to show failed processes ... 
      systemctl --failed 

      # check logs [journalctl/rsyslog] ...
      journalctl unIT=foo.service

      # search for appropriate log fil
      /var/log   
      cat /var/log/sales_error_log  # e.g.
        # => ... no matching DirectoryIndex (index.html) found 

  # RHEL 6 [legacy] :: start/stop/status/restart
    service NAME start
    service NAME stop
    service NAME status
    service NAME restart 
    
    chkconfig NAME [off|on] # start/stop on boot
    
    chkconfig --list | grep NAME  # show config status [per runlevel]
        
# SYSTEM DAEMON [systemd] [PID=1]; handles services, mounts, automounts, ...
  # https://coreos.com/os/docs/latest/getting-started-with-systemd.html  
  # systemd uses unit files [scripts]; per process/module scripts
  # legacy Linux used init files [scripts]
  
  # Unit files [scripts] :: *.service, *.target, *.target.wants
    # @ DEFAULTs per rpm; do NOT modify these 
    /usr/lib/systemd  

      /system        # SERVICEname.service files
      
    # @ MODIFIEDs; OVERRIDEs defaults
    /etc/systemd      
  
      /system
      /user

    # *.target files :: a collection of unit files defining a system state
    #   Specifies requirements, execution order, params, and conflicts of 
    #   all services and other targets;
    #   Requires=..., Conflicts=..., After=..., PARAMname=VALUE;  e.g., ...
    #   legacy Linux used 'runlevels'

        [Unit]
        Description=Multi-User System    # shows up in the systemd log and a few other places. 
        Documentation=man:systemd.special(7)
        Requires=basic.target  # this unit will only start after basic.target is active
        Conflicts=rescue.service rescue.target
        After=basic.target rescue.service rescue.target
        AllowIsolate=yes

      /usr/lib/systemd/system
    
        poweroff.target      # shutdown state
        rescue.target        # troubleshooting state 
        emergency.target     # minimalist mode troubleshooting state
        reboot.target        # reboot state
        multi-user.target    # fully operational w/out GUI 
        graphical.target     # fully operational w/ GUI 

    # *.wants files :: The services comprising [wanted by] a target
    #   Auto-generated SYMLINKs per systemctl command
    
    # SWITCH TARGETS; switch modes
    #   many targets may be loaded @ any one operational state

      # show all loaded targets
      systemctl list-units --type=target 
    
      # RESCUE MODE a.k.a. Single-User Mode a.k.a. Maintenance Mode a.k.a. runlevel 1
        systemctl isolate rescue.target
        exit # or CTRL+D to switch back

        # change to runlevel 1;
          su /sbin/init 1   

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
        
      # EMERGENCY MODE 
        systemctl isolate emergency.target
        systemctl reboot    # exit
        systemctl systemctl # exit

        # on BOOT fail 
          # read boot msgs, and then login as root ...
          # [CentOS/RedHat 7]
          journalctl -xb # boot log 
          
      # @ GRUB menu :: enter RESCUE|EMERGENCY [mode/target/environmnet] 
        # Press 'e' to open grub menu settings
        # @ 'linux16...' line, APPEND ... 
          systemd.unit=rescue.target    # RESCUE    [mode/target/environmnet]
          systemd.unit=emergency.target # EMERGENCY [mode/target/environmnet]
        # ^X; CTRL+X to restart
        # ^D; CTRL+D to exit ???  
          systemctl default
          systemctl reboot
            
  # MOUNT/AUTOMOUNT per `systemctl` [systemd.mount(5)] UNIT FILEs
  # https://manpages.debian.org/stretch/systemd/systemd.mount.5.en.html
    # `fstab` is STILL PREFERRED method; takes precedent; supposedly "legacy", but only way to set options like `User=` and `Group=`; used by systemd.mount; fstab config CONVERTs INTO NATIVE UNITS dynamically at boot and when the configuration of the system manager is reloaded.
    
    # MOUNT requires unit FILE
      /etc/systemd/system/lv{NAME}.mount
    # AUTOMOUNT requires unit FILE 
      /etc/systemd/system/lv{NAME}.automount

    # NAMING CONVENTION [REQUIRED] 
      # if the desired target MOUNT POINT is 
        /mnt/foo/bar

        # then the UNIT FILE name[s] MUST BE 
        /etc/systemd/system/mnt-foo-bar.mount      # to mount
        /etc/systemd/system/mnt-foo-bar.automount  # to automount

      # AND the `Where = ...`, in these UNIT FILE[s] ...
        Where = /mnt/foo/bar  # MUST also match that mount-point
        
      # Unlike other methods, where mount point [folder] must be created 
      # beforehand, i.e., `mkdir mtpt`, that is NOT needed/allowed here.
       
    # 1. test first; validate partition (What = PARTITION, below) is valid and mountable
      mount PARTITION MtPt; ll MtPt
      
      # *.mount unit files @ 
      /usr/lib/systemd/system
        *.mount 
        # ... not sure what the hell these are; perhaps generated upon mount?

    # 2. Create Unit file @ 
    /etc/systemd/system 
      lv{NAME}.mount    # create; note naming convention; add/edit ...
                  # Need NOT be LVM; can be a physical partition [PP]
      
        [Unit]
        Description = TEST Systemd mount
        
        [Mount]
        What  = /dev/vg{NAME}/lv{NAME}  # LV|PP [created previously]
        Where = /lv{NAME}               # Mount Point
        Type  = xfs
        Options=                        # WTF ??? @ `systemd.mount(5)`
        DirectoryMode=
        TimeoutSec=
        
        # WTF ??? @ systemd.mount(5); can't set OPTIONS here, apparently.
          # "Note that the User= and Group= options are not particularly useful for mount units specifying a "Type=" option or using configuration not specified in /etc/fstab; mount(8) will refuse options that are not listed in /etc/fstab if it is not run as UID 0."
          
          # "FSTAB ... Mounts listed in /etc/fstab will be converted into native units dynamically at boot and when the configuration of the system manager is reloaded. In general, configuring mount points through /etc/fstab is the preferred approach."
          
        # So, ... set OPTIONS @ "legacy" /etc/fstab ??? Yep, apparently.
 
        [Install]
        WantedBy = multi-user.target    # do only @ this target [environment]
        
    # 3. [Auto]Mount/Unmount per systemctl & the unit-file[s]
      
      # [auto]mount/unmount per systemctl & unit-file 
        systemctl [start|stop|enable|disable] lv{NAME}.[auto]mount
        # now: start/stop; @ boot: enable/disable
          
          systemctl start  lv{NAME}.mount
        # validate 
          systemctl status lv{NAME}.mount
        # enable mount on boot  
          systemctl enable lv{NAME}.mount
        # disable mount on boot 
          systemctl disable lv{NAME}.mount
        # disconnects mount
          systemctl stop lv{NAME}.mount

    # AUTOMOUNTs per systemd
    #   device mounted only when used; unmounted when dormant
    # http://blog.tomecek.net/post/automount-with-systemd/
    # Create Unit file @ 
    /etc/systemd/system 
      lv{NAME}.automount  # create; MUST match name of its .mount file 
      
        [Unit]
        Description = TEST Automount
        
        [Automount]                     
        Where = /lv{NAME}               # Mount Point; 
        # NOTE the `What = /dev/...`, the device, was defined @ 'lv{NAME}.mount' file
        
        [Install]
        WantedBy = multi-user.target    # do only @ this target [env]

      # before start/enable AUTOmount service [*.automount], 
      #  first stop & disable the corresponding mount service [*.mount]
        systemctl disable lv{NAME}.mount
        systemctl stop    lv{NAME}.mount
        
      # enable automount service on boot  
        systemctl enable  lv{NAME}.automount 
      # start automount service 
        systemctl start   lv{NAME}.automount

        systemctl status  lv{NAME}.automount
        
      # `ls /lv{NAME}` will show NOTHING, 
      # but `mount` will show mounted

    # EITHER, but NOT BOTH (.mount/.automount) services may be ACTIVE 
    # I.e., stop/disable the one, before start/enable the other.

# BOOT PROCEDURE :: systemd
  # POST > MBR finds boot device > grub2 > kernel & initrd > mount root fs > systemd
  # GRUB2 [Grand Unified Bootloader]
  # https://www.gnu.org/software/grub/manual/grub.html
  
    # grub2 CONFIGuration file
    /boot/grub2/grub.cfg # NEVER MODIFY DIRECTLY
    
    # MODIFY grub2 CONFIGuration file, INDIRECTLY @ ...
    /etc/default/grub  # MODIFY here [PERSISTs]
      # e.g., delete 'rhgb quiet' here to show processes on boot
        GRUB_CMDLINE_LINUX="rd.lvm.lv=c7/root rd.lvm.lv=c7/swap rhgb quiet"
        GRUB_DISABLE_OS_PROBER=true # added by user
        # https://www.gnu.org/software/grub/manual/grub.html#Configuration

      # Additional/Custom scripts
      /etc/grub.d  # e.g., 40_custom [Chain-loading]
      
      # GRUB MODifications :: try to do w/ one of the grub2 utilities 
      /usr/sbin # => grub*
        grub2-bios-setup           grub2-mkconfig    grub2-rpm-sort       grubby
        grub2-get-kernel-settings  grub2-ofpathname  grub2-set-default
        grub2-install              grub2-probe       grub2-setpassword
        grub2-macbless             grub2-reboot      grub2-sparc64-setup

    # [re]COMPILE :: MUST; writes [changes] to boot loader ...
      grub2-mkconfig -o /boot/grub2/grub.cfg # NEVER edit this directly
    
  # TROUBLESHOOTING [RHEL/CentOS/Fedora 7]
  
    # ON BOOT @ GRUB2 menu :: enter RESCUE|EMERGENCY [mode/target/environmnet] 
      # 'c'; for command prompt
      # 'e'; to EDIT selected menu-entry @
      # 'linux16 /vmlinuz-...' line; the 'kernel line'; BEFORE 'initrd16 ...' line
        # e.g., to show processes on boot: delete 'rhgb quite'
        # e.g., change from default.target :: APPEND to 'linux16 ...' line ... 
          systemd.unit=rescue.target    # RESCUE    [mode/target/environmnet]
          systemd.unit=emergency.target # EMERGENCY [mode/target/environmnet]
          # legacy used runlevels
        # e.g., BYPASS/RESET ROOT PASSWORD; append to 'linux16...'
          rd.break # breaks from boot before any disk FS access; 
          # drops into shell; uses initfamfs @ /sysroot [as root dir]

        # ^X; CTRL+X to exit grub editor and start booting 
        # ^C; CTRL+C for command prompt
        # ESC to discard edits and return to menu
      
      # NOTE: rescue/emergency targets [and rd.break] mount FS in READ-ONLY mode; 
      
        # to remount in read/write mode ...
          mount -o remount,rw /
          
        # to RESET ROOT PASSWORD @ '... rd.break' boot ...
          mount -o remount,rw /sysroot
          chroot /sysroot 
          echo NEWPASSWORD | passwd --stdin root
          # or 
          passwd # and then manuall enter it
          touch /.autorelabel # MUST !!! handles SELinux issue
          CTRL+D # exit
          CTRL+D # reboots

      # boot log @ 
        journalctl -xb 

      # reboot 
        systemctl reboot
        # OR 
        systemctl default

    # GRUB menu entries: NUMBER TITLE [Grub counts: 0,1,2,...]
      # awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
    # GRUB menu entries: TITLEs
      grep ^menuentry /boot/grub2/grub.cfg | cut -d "'" -f2
  
      # set menu entry default :: '2' is 3rd menu-entry !!! [0,1,2,...]
        grub2-set-default 0
      # validate @ /boot/grub2/grubenv [SYMLINK]
        grub2-editenv list 
          # =>
          saved_entry=2  
      
      # set menu entry selection @ NEXT BOOT
        grub2-reboot 2

  # [re]SET DEFAULT RUNTIME LEVEL [aka 'runlevel'] [legacy lingo] 
    # boot into text interface [CLI], not GUI
    systemctl set-default multi-user.target

# SELinux [Security Enhanced Linux] :: File AND Process Security Policy
  # Enforces MAC [Mandatory Access Control] vs. Linux's DAC [Discretionary Access Control]
  # SECURITY CONTEXT: 3-string [label] context assigned to EVERY user AND process
  #  USER:ROLE:TYPE[domain]
  #   Type Enforcement; on processes and file system objects; object types; policy rules
  #   MCS [Multi Category Security] Enforcement; Roles?
  #   MLS [Multi Level Security] Enforcement; control processes based on the level of the data they; not used much
  # SELinux users and roles do not have to be related to the actual system users and roles.
  # https://en.wikipedia.org/wiki/Security-Enhanced_Linux
  # https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/SELinux_Users_and_Administrators_Guide/sect-Security-Enhanced_Linux-Introduction-SELinux_Architecture.html
  # UPG :: User Private Groups; each user gets own group 
  # Typical UNIX umask of 022 [set @ /etc/bashrc] unnecessary, since group is private
  id # =>
  uid=500(f99z) gid=500(f99z) groups=500(f99z),10(wheel) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

  # RHEL / SELinux utilities
    useradd(8)    — to create new users.
    userdel(8)    — to delete users.
    usermod(8)      — to modify users.
    groupadd(8)   — to create new groups.
    groupdel(8)   — to delete groups.
    groupmod(8)   — to modify group membership.
    gpasswd(1)      — to manage the /etc/group file.
    grpck(8)      — to verify the integrity of the /etc/group file.
    pwck(8)      — to verify the integrity of the /etc/passwd and /etc/shadow files.
    pwconv(8)  — pwconv, pwunconv, grpconv, and grpunconv; to convert shadowed information for passwords and groups.
    id(1)        — to display user and group IDs.
    umask(2)      — to work with the file mode creation mask. 
  # RHEL / SELinux files
    group(5)      — /etc/group; to define system groups.
    passwd(5)      — /etc/passwd; to define user information.
    shadow(5)      — /etc/shadow; to set passwords and account expiration information for the system. 

  # SELinux MODE [enforcing|permissive]; set per boot
    /etc/sysconfig/selinux 
      SELINUX=enforcing
      
        enforcing  # log & stop  syscall if avc:denied
        permissive # log & allow syscall if avc:denied
        disabled   # No SELinux functionality
        
  # Functional Diagram
    syscall [every process] => SELinux => policy [avc:denied] => auditd 
                
    # auditd [AUDIT DAEMON]            
      /etc/audit/auditd.conf
      /var/log/audit/audit.log # all SELinux events

  getenforce 
  setenforce {enforcing|permissive} # can toggle to troubleshoot
  
  # CONTEXT :: 3 Parts [USER:ROLE:TYPE] [RHCSA focuses only on TYPE]

    # @ Files; show SECURITY CONTEXT; LABEL per USER:ROLE:TYPE 
      ls -Z /foo # =>
        drwxrwxr-x. f99z f99z unconfined_u:object_r:user_home_t:s0 scripts
        -rwxrwxr-x. f99z f99z unconfined_u:object_r:user_home_t:s0 _f99zX.cfg
        
        # on copy, context inherited from destination parent [typically]
        # on move, context moves with the dir/file [typically]
        
    # @ Processes; show SECURITY CONTEXT; USER:ROLE:TYPE
      ps Zaux # =>
        system_u:system_r:sshd_t:s0-s0:c0.c1023 878 ?  Ss     0:00 /usr/sbin/sshd
        system_u:system_r:sshd_t:s0-s0:c0.c1023 4079 ? Ss     0:00 sshd: f99z [priv]

      netstat -Ztulpen # =>
        tcp  ... 0.0.0.0:22 ...  878/sshd  system_u:system_r:sshd_t:s0-s0:c0.c1023

  # BOOLEANS :: off|on <==> PREVENT(off) OR ALLOW(on)
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
    
  # WHY SELinux :: Hacked [Story]: 
  #  Developer under admin was hacked thru PHP backdoor; invader opened a shell and stored large number of PHP scripts on victim [admin] machine; scripts used to attack others. Web sites require access and executables @ '/tmp' and '/var/tmp'; Permissions needed too; Firewalling shouldn't block access either. So, Linux hasn't many options to secure. 
  
    # Thus, SELinux; sets file AND process access per process/application, per POLICY 
  
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

  # CONFIGURE SELinux :: semanage [man pages have good examples; 'man semanage-fcontext']
    # semanage writes to SELinux POLICY, not to FS
      # E.g., fix context for web-site's DocumentRoot access 
      #  [DocumentRoot (re)set @ /etc/httpd/conf/httpd.conf]  
      semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?" # ... RegEx
      restorecon -R -v /web # (re)writes to FS and validates, per POLICY; 
                     # restores any FS CONTEXT errors, per POLICY
      
      # E.g., fix port binding ... 
      #  [DocumentRoot (re)set @ /etc/httpd/conf/httpd.conf]  
      semanage port -a -t http_port_t -p tcp 888
      restorecon -R -v /web
      # ... NOPE; failed.
      
    # chcon :: NEVER USE IT; BAD PROGRAM
    #  Writes directly to FS, NOT to POLICY
    #  so [subsequent] relabel activity will reset per policy
      # E.g., say need to set context label 'httpd_sys_content_t' on /foo dir
      chron -R --type=httpd_sys_content_t /blah       # BAD 
      semanage -a -t httpd_sys_content_t "/foo(/.*)?" # GOOD
      # semanage writes to POLICY which then writes to FS
      
    # FIND LABELs [per CONTEXT USER:ROLE:TYPE]
      semanage fcontext -l # list all CONTEXTs; very long list
      # man page for each context/service
      # CentOS-6 [legacy]; very helpful
        man -k _selinux  
      # CentOS-7 # not installed by default
        yum -y install policycoreutils-devel
        sepolicy manpage -a # FAILed; 'No such file or directory...' 
        mandb
        man -k _selinux
    
    # TROUBLESHOOTing SELinux 
      yum list installed | grep setrouble # should be installed by default
  
      # SELinux decisions, such as allowing or disallowing access, are cached.
      # AVC [Access Vector Cache]; 
      # Denial messages; AVC denials"; logged to location per daemon
      # Daemon                                      Log Location
      auditd on                                    /var/log/audit/audit.log
      auditd off; rsyslogd on                       /var/log/messages
      setroubleshootd, rsyslogd, and auditd on     /var/log/audit/audit.log
      Easier-to-read denial messages also sent to  /var/log/messages
      
      # AUDIT LOG :: header 'AVC'
      /var/log/audit/audit.log
      
      systemctl status auditd
      grep AVC /var/log/audit/audit.log
      
      less /var/log/messages
      
# KERNEL MANAGEMENT 
  # Modular Design; only necessary modules are loaded
  # Automatic; kernel and udev work together to handle HW/processes/modules
  #   new hardware => udev => kernel
  #   hardware <=> kernel => load kernel module
  lsmod # list modules
  udevadm monitor # show recieved events [uevent]; comms btwn udev & kernel
  # e.g., USB key inserted ...
    KERNEL[6720.121503] add      /devices/pci0000:00/0000:00:12.2/usb1/1-4 (usb)
    KERNEL[6720.122253] add      /devices/pci0000:00/0000:00:12.2/usb1/1-4/1-4:1.0 (usb) 
    .
    .
    .
    UDEV  [6721.703852] add      /devices/pci0000:00/0000:00:12.2/usb1/1-4/1-4:1.0/host3/target3:0:0/3:0:0:0/block/sdc (block)
    UDEV  [6721.782119] add      /devices/pci0000:00/0000:00:12.2/usb1/1-4/1-4:1.0/host3/target3:0:0/3:0:0:0/block/sdc/sdc1 (block)
    
  # MANUALLY LOAD/UNLOAD KERNEL [HW] MODULES
    modprobe MODULEname    # load module; handles dependencies
    modprobe -r MODULEname # unload module; handles dependencies 
    
  # MODIFY KERNEL MODULE BEHAVIOR
    modinfo MODULEname     # show module info INCL settable param[s]
    # e.g., 
    modinfo iwlwifi # => ...
      parm:    led_mode:0=system default, 1=On(RF On)/Off(RF Off),...
    # MODIFY [see below for better ??? method] ...
    modprobe iwlwifi led_mode:1
    
    # @ CentOS-6 
      /etc/modprobe.conf # simple single entry point 
    
    # @ CentOS-7 [systemd]
      /lib/modprobe.d # do NOT modify these files 
      /etc/modprobe.d # MODIFY params HERE; man 5 modprobe.d
      # create conf to set param[s] of a module 
      vim /etc/modprobe.d/iwlwifi.conf 
      # => 
        options iwlwifi led_mode=1
      # validate ? typically need to reboot, but some modules ...
        ls /sys/module/MODULEname
        # e.g., @ iwlwifi ...
        cat /sys/module/iwlwifi/parameters/led_mode
        # => 
          1
        # or, (re)load & examine 'kernel ring buffer'
        modinfo MODULEname
        dmesg | grep MODULEname 
  
  # TUNE KERNEL BEHAVIOR :: /proc/sys [live/TEMPORARY]
  /proc          # pseudo-file system; interface to kernel data structures
    cpuinfo 
    partitions
    /sys        # /proc/sys :: subdirs for each interface, e.g., ...
      /fs  
      /net 
      /vm      # swappiness [0-100]; memory optimization; swap out unneeded files
      .
      .
      .
      /kernel 
        cat osrelease # => 
          3.10.0-514.el7.x86_64
        cat hostname # =>
          HTPC
          
    # MODIFY PARAM immediately [does NOT persist on boot]
      echo VALUE > PROC_FILE # BE CAREFUL with these advanced params
  
  # TUNE KERNEL BEHAVIOR :: sysctl [PERSISTENT]
    sysctl -a # show all tunable settings
    # => ...
      net.ipv6.conf.default.mc_forwarding = 0
      net.ipv6.conf.enp1s0.forwarding = 0
      # ... names correspond to respective file path @ '/proc/sys';
      #     just replace '.' with '/'

    # @ CentOS-6 
      /etc/sysctl.conf # simple single entry point; depricated [but works]
        # @ CentOS-7, still works, per symbolic link ...
        /etc/sysctl.d/99-sysctl.conf -> ../sysctl.conf
        # MODIFY @ 'either' file [same file]
        
    # @ CentOS-7 [systemd]  
      /usr/lib/sysctl.d/*.conf # default system settings 
      # fnames starting w/ integers [NN] obey order of read/execution
      # so, last one [setting] wins
      
      # MODIFY @ ...
        /etc/sysctl.d/99-sysctl.conf # symbolic link to '/etc/sysctl.conf'
        # OR [the file it links to]
        /etc/sysctl.conf
        # OR create individual file therein, e.g., ...
        vim /etc/sysctl.d/50-MODULEname.conf
        # ... enabled at next reboot
      
        # sysctl command allows direct modification, but NOT recommended
        # test [temporarily] using [above] 'echo VALUE > /proc/sys/...'
  
  # KERNEL UPDATE 
  # additive; old + new available @ boot menu
    yum update kernel
    # OR 
    rpm -uvh kernel 

  # UNATTENDED/AUTOMATED INSTALLATION :: Kickstart [RedHat]
  # kickstart file, boot.iso, and RHEL repository
    # view @ root user 
    ls ~ # => 
      anaconda-ks.cfg  initial-setup-ks.cfg # kickstart files
    # Kickstart Configurator [GUI]; not installed by default
    # Allows Pre- and Post- Installation script insertion
      yum install system-config-kickstart -y
      
    # 'publish' kickstart file @ remote host [ftp server]
      # secure copy to remote host
        scp anaconda-ks.cfg USER@HOSTaddress:~ # to user's home dir
      # go there 
        ssh USER@HOSTaddress
      # switch to root user 
        su -
      # copy to /ftp/pub
      cp /home/USER/anaconda-ks.cfg /var/ftp/pub 
      chmod 644 /var/ftp/pub/anaconda-ks.cfg # make readable by all
      
      # then at install menu of installation disk, if ftp server is running,
      # press TAB for options and APPEND to 'vmlinuz initrd=...'
        ks=ftp://HOST/pub/anaconda-ks.cfg
      # can also setup 'installation server' instead of using installation disk
      # Install[ation] Server has DHCP & TFTP servers; 
      #  sends boot image, kickstart file, and repository access
      #  to target machine running pxe boot process.

# TIME on Linux 
  # hardware clock ==> system time [one-way]
  hwclock                 # show current HW clock setting
  hwclock --systohc       # write system time to hardware clock
  timedatectl list-timezones
  timedatectl set-timezone Europe/Amsterday
  timedatectl set-time    # set
  # SETUP TIME SERVER
  timedatectl set-ntp yes # starts chronyd.service [TIME SERVER]
    /etc/chrony.conf     # set public time server [time-source]
  timedatectl status  
  
  systemctl status chronyd
	
# Service Configuration [GUI] tool 
yum install system-config-services
      
# Download/upgrade [remove earlier version after install]
  rpm -U PKG
    
  # Dangerous but allows it ...
  rpm -i --nodeps PKG

  # Remove ... fails due to dependencies 
  rpm -e PKG 

  # Signature [check for man-in-middle-attack]
  rpm -K PKG
    
  # Install [verbose]
  rpm -iv *.rpm # stops and complains if dependencies [rinse & repeat]
  
  # Verify [verbose]
  rpm -Vv PKG

  # query packages while they're in repository, but NO '--scripts' option
  repoquery -ql PKG 
    
# YUM :: PACKAGE META HANDLER
#  Repositories > Indexes
#  RHN repository - official, for paid customers

  # YUM / yumdownloader :: config @ /etc/yum.repos.d
    
    # list available repositories 
    yum repolist 
    
    # list available package groups
    yum group list [[hidden] ids]
    
    # INSTALL a GROUP
    yum groupinstall "GROUP NAME"  # NOPE !
    yum group install "GROUP NAME" # NOPE !
    
    # INSTALL a GROUP
    yum group install graphical-server-environment # install per id; worked
    yum group install server-platform              # NOPE !
    
    # list available from a specified repo per repo id
    yum --disablerepo="*" --enablerepo="REPO_ID" list available
    
    /etc/yum.repos.d # all repos
    
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
    
    # yum :: repo-based info; 'Installed' & 'Available' Packages, e.g., ...
    yum info PKG
    
    # Download and install ...
    yum install PKG

    # Upgrade ; list all available updates and query user to download/install
    yum upgrade
      
    # Update kernel [CentOS] 
    yum -y update kernel 

    yum remove pkg # protects; fails if dependencies exist

  # to Download only ; NOT install, 2 options ...

    # 1. "--downloadonly" option  ...

      # (RHEL5)
      yum install yum-downloadonly

      # (RHEL6)
      yum install yum-plugin-downloadonly

      #Run yum command with "--downloadonly" option as follows:

      yum install --downloadonly --downloaddir=TARGET_PATH PKG

    # 2. yumdownloader utility ...

      yum install yum-utils

      # Run the command followed by the desired package:
      yumdownloader PKG
      
    # Download RPM of target (from repo)
    yumdownloader PKG

    # Download RPM of target + dependencies 
    yumdownloader --resolve PKG

    # CREATE YUM REPO[s] 
    #  https://www.digitalocean.com/community/tutorials/how-to-set-up-and-use-yum-repositories-on-a-centos-6-vps
    
    # ... from an ISO, e.g., 'CentOS-6.4-i386-LiveDVD.iso' ...

      # download, e.g., ISO :: wget URL [create /iso-download]
      wget http://mirror.lihnidos.org/CentOS/6.4/isos/i386/CentOS-6.4-i386-LiveDVD.iso
      
        # Mount the ISO [per loop-device]
        mount -o loop /iso-download/CentOS-6.4-i386-LiveDVD.iso /mnt
        
      # Create YUM Repository Configuration file 
      /etc/yum.repos.d/centosdvdiso.repo

      [centosdvdiso]
      name=CentOS DVD ISO
      baseurl=file:///mnt
      enabled=1
      gpgcheck=1
      gpgkey=file:///mnt/RPM-GPG-KEY-CentOS-6
    
    # ... from PACKAGES [Create a Custom YUM Repository], e.g., ...
    
      # requires createrepo pkg 
      yum install createrepo
        
      # create & cd to repo dir 
      mkdir /repo1; cd /repo1
    
      # get package[s] [*.rpm], e.g., ...
      wget http://mirror.lihnidos.org/CentOS/6/os/i386/Packages/NetworkManager-0.8.1-43.el6.i686.rpm
    
      # create repo 
      createrepo /repo1 
      
      # create repo config file @
      /etc/yum.repos.d/custom.repo

        [customrepo]
        name=Custom Repository
        baseurl=file:///repo1/
        enabled=1
        gpgcheck=0
  