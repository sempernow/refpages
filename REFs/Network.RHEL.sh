#!/bin/bash
# ---------------------------------------------------------
#  CentOS 7 [CentOS-7-x86_64-DVD-1511.iso]
#  CentOS release 6.8 (Final) # this is 32-bit
#  https://wiki.centos.org/HowTos

#  https://wiki.centos.org/HowTos/Laptops/NetworkManager
# 
#  ***  DO NOT EXECUTE  ***
# ---------------------------------------------------------
exit

# MANAGING HTTP SERVICES :: Apache WEB SERVER
  # install/config OS as Web Server
  sudo yum group install graphical-server-environment 
  # ... but only `httpd` is required ...

    # Apache Web Server :: INSTALL and CONFIGURE
        sudo yum -y install httpd
        sudo systemctl --now enable httpd 
        sudo firewall-cmd --permanent --add-service=http --add-service=https
        sudo firewall-cmd --reload  

        elinks  # text-based browser for DevOps
        yum install elinks -y  
  
    # show Apache CONFIG FILES 
        rpm -qc httpd 

        /etc/httpd                   # Server root; all paths are realitve to it 
        /etc/httpd/conf/httpd.conf   # Main config file 
        /etc/httpd/conf.modules.d    # Modules' config dir; added per module install  
        /etc/httpd/conf.d            # Supplemental config dir; used by plugin files 

    /etc/sysconfig/httpd         # config used to change startup params 

    # DEPLOY a Web Server
    /etc/httpd/conf/httpd.conf
      DocumentRoot "/var/www/html" # default DOC ROOT; if changed,
                                   #  then SELinux changes also required.
            Listen 888                    #  set to `80` to listen to all incomming 

    /var/www/html                   
        vim index.html               # create web page @ DOC ROOT
            <blink>Hello</blink>  

    # test 
        yum install -y elinks          # text-based browser
        elinks http://localhost:888    # go to the created web page

    # Virtual Hosts [multiple names sharing same IP Address] 
        # sans DNS, `hosts` file entries required @ BOTH client and server 
        vim /etc/hosts 
            foo.some.com  192.168.1.105 
            bar.some.com  192.168.1.105 

        mkdir -p /web/foo; mkdir -p /web/bar
        # create `index.html` in each 

        # SELinux context :: set for all @ /web/* 
        # set context [per default config, e.g., view @ ls -Z /web]
            semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"  
            restorecon -R -v /web 

        # create config files
        /etc/http/conf.d/foo.conf 
        /etc/http/conf.d/bar.conf 
            # create/edit/add ..., e.g., for `foo.conf`
                <Directory /web/foo>
                    Require all granted 
                    AllowOverride None 
                </Directory>		

                <VirtualHost *:80>   # overrides any normal host thereof
                #<VirtualHost _default_:80>  # equiv for 'IP virtual hosting'
                    DocumentRoot /web/foo 
                    ServerName  foo.some.com 
                    ServerAlias www.foo.some.com 
                    ServerAdmin root@foo.some.com 
                    ErrorLog  "logs/foo_error_log"
                    CustomLog "logs/foo_access_log" combined
                </VirtualHost> 

        systemctl start httpd
        systemctl enable httpd 

        firewall-cmd --permanent \
            --add-service=http --add-service=https
        firewall-cmd --reload  

    # ACLs :: to grant DocumentRoot access to other users, e.g., to DevOps, etc 
        groupadd webdev  # create group `webdev` 
        # apply to NEW files; `g:....`  
            setfacl -R -m g:webdev:rwX /web  # set file ACL; `X` on dirs only
        # apply to EXISTING files; `d:g:...`
            setfacl -R -m d:g:webdev:rwX /web  # set file ACL; `X` on dirs only
        # show file ACLs
            getfacl /web  

# FTP SERVER [vsftpd]
    yum -y install vsftpd
    systemctl status vsftpd 
    systemctl enable vsftpd 
    systemctl start vsftpd 

    # config 
    /etc/vsftpd
        vsftpd.conf # default config'd for anonymous downloads

    # users: anonymous|authenticaed
        /var/ftp # for anonymous ftp users
        # is home dir of user 'ftp'
        # dir owner/user/group is 'root'; perms for 'others' is r/w; 

    # find/test home dir of ftp user 
        grep ftp /etc/passwd # => 
        ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
        # showing home dir of '/var/ftp'

    # test firewall :: allows ftp service ?
        firewall-cmd --list-all # ftp service not listed, but download allowed anyway !?

    # test SELinux :: downloads blocked ?
        getenforce 
        ls -lZ /var/ftp 
        getsebool -a | grep ftp

    # ftp client: wget, lftp, ... 
        yum install -y lftp # can look @ dir 
        lftp localhost # failed @ ssh session: 
        # msg ... `ls' at 0 [Delaying before reconnect: 29]

# FIREWALL [firewalld] 
  Netfilter # framework for Linux firewall
    iptables  # legacy  [CentOS-6] https://www.unixmen.com/iptables-vs-firewalld/
        # chains and rules; static; must stop/reload on changes
        sudo iptables -L # list 
        sudo iptables -S # status 
        sudo iptables -F # flush

    nft # nftables : Replaces : iptables, ip6tables, arptables, and ebtables
        sudo nft list ruleset # firewalld is wrapper for nftables / iptables

    firewalld # systemd service : User-friendly interface (wrapper) for iptables/nftables 
        # based on zones and servies; dynamic; changes don't break sessions
        # interface => zone [public|private|DMZ] => service
        systemctl status firewalld
        
        # modify using ...
        firewall-cmd    # CLI
        firewall-config # GUI; very convenient; 
        # Configuration [option: Runtime|Permanent <==> NOT|Persistent 
      
        firewall-cmd --get-zones
        firewall-cmd --get-default-zone
        # add a service [NOT persist]
        firewall-cmd --zone=home --add-service=foo
        # ... where 'foo.xml' is a service description [file] defined in /services dir 
        
        /etc/firewalld
            /services/                # create service[s] here
            /icmptypes/
            /zones/
            lockdown-whitelist.xml
            firewalld.conf

        # make PERSISTent [survive reboot]
        firewall-cmd --permanent ...

# Network config :: GUI Tool
redhat-config-network # CentOS
network-admin         # Debian, Suse, ...

# System's DNS domain name 
dnsdomainname	# => localdomain

# hostname :: show 
hostname	# => localhost.localdomain

# hostname :: change [currently-only]
hostname CentOS.LANDOMAIN

    # CentOS/RedHat 6 
    service network status|stop|start|restart
    
    # CentOS/Redhat 7 [systemd]
    systemctl status|start|stop|restart|enable|disable NetworkManager
    
    # IP Networking Control Files http://linux-ip.net/html/basic-control-files.html
    # config files https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/ch-Network_Interfaces.html#sect-setting-the-host-name
        /etc/hosts # resolve host names that cannot be resolved any other way; resolve host names on small networks with no DNS server; regardless, should contain a line specifying the IP address of the loopback device (127.0.0.1) as localhost.localdomain; see the hosts(5) manual page. 
        /etc/resolv.conf # specifies the IP addresses of DNS servers and the search domain; network initialization scripts populate this file; see the resolv.conf(5) manual page. 
        /etc/sysconfig/network # specifies routing and host information for all network interfaces; global effect and not to be interface specific. 
        /etc/sysconfig/network-scripts/ifcfg-interface-name 

        
        # Interface definitions :: per Connection Name,'*'; [RedHat]
        ls '/etc/sysconfig/network-scripts/ifcfg-'*
            
        # ifcfg-LAN2 [CentOS 6]
            TYPE=Ethernet
            BOOTPROTO=dhcp
            DEFROUTE=yes
            IPV4_FAILURE_FATAL=yes
            IPV6INIT=no
            NAME=LAN2
            UUID=8f0e4728-e3b0-42fd-9d75-f467a53767ee # per connection, NOT per MAC
            ONBOOT=no
            DNS1=192.168.1.1
            DOMAIN=LANDOMAIN
            HWADDR=00:23:54:7C:B8:64  # eth0
            PEERDNS=no
            PEERROUTES=yes

        # Interface definitions :: 'Routes...' [RedHat]
        ls '/etc/sysconfig/network-scripts/route-'*
        
        # route-LAN2 [CentOS 6] 
        
            ADDRESS0=192.168.1.1 # Gateway Router
            NETMASK0=255.255.255.0
            GATEWAY0=192.168.1.2 # Client-Bridge
            METRIC0=1

        # Hostname and default gateway definition [RedHat]
        cat '/etc/sysconfig/network' # cycle NIC after any change [per 'nmcli con down/up eth0']
        
            NETWORKING=yes
            NETWORKING_IPV6=no
            HOSTNAME=CentOS.LANDOMAIN
            DOMAINNAME=LANDOMAIN
            
        # Definition of static routes, if exist [RedHat]
        cat '/etc/sysconfig/static-routes' 

        # hosts File 
        cat '/etc/hosts'

        # DOMAIN & DNS Name Server :: resolve.conf [for viewing only; config w/ NetworkManager]
        cat '/etc/resolv.conf' # => 
        
            # Generated by NetworkManager
            search LANDOMAIN
            nameserver 192.168.1.1

# OpenSSH (see also `REF.Network.SSH.sh`)
# SSH [OpenSSH] [pkg] :: symm encryption @ Layer 4: Transport Layer; 
    # data structure/delivery; TCP, UDP; SEGMENT/DATAGRAM
    # config files @ /etc/ssh/... and ~/.ssh/ 
    # https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/s1-ssh-configuration.html

    # sshd :: SERVER
        # OpenSSH install ...
        yum install openssh-server

            # SSH [daemon; sshd]
            service sshd status
            service sshd start
            service sshd stop

            # @ RHEL 7 start/stop daemon
            systemctl start sshd.service
            systemctl stop sshd.service
            # reload after config change 
            systemctl daemon-reload

            # config to start @ boot
            systemctl enable sshd.service

    # ssh :: CLIENT programs
        ssh
        scp
        sftp

    # ssh :: access/logon
        ssh username@hostname.domainname
        ssh username@IPaddress
        ssh -l username target-address

    # ssh :: secure copy [per hostname OR IP]
    scp localfile username@hostname:remotefile # push
    scp username@hostname:remotefile localfile # pull

    # ssh :: secure FTP
    sftp username@hostname

    # ssh :: X11 Forwarding
        yum groupinfo "X Window System"
        yum groupinstall "X Window System"
    
        # X11 Forwarding w/ "X11 SECURITY extensions"
        ssh -X username@hostname  # vulnerable to threats @ remote host
        
        # ForwardX11Trusted [bypass X11-security-extensions] 
        ssh -Y username@hostname  # even less secure
        
        # before ending ssh session, if any GUI/X11 process was launched therein,
        # must first kill its 'dbus-launch' process, per `kill PID` [list per `ps`],
        # or terminate X11 @ local machine per GUI menu: `XDG Menu > Exit` @ Windows taskbar

        # Win7/Cygwin :: X11 Forwarding @ SSH session
        # http://www.arsc.edu/arsc/knowledge-base/ssh-and-x11-forwarding-us/index.xml

            Install: openssh, xorg-server, xinit
            
            # How-to ...
            
                startxwin # but can't run directly; app hangs/waits @ Cygwin terminal.
                # Even successful launch method [below] causes issues if ssh from SAME terminal
                # So, must launch in its own bash terminal PRIOR to ssh terminal.
                
                # GUI method: double-click @ installed XDG Menu app, 'Cygwin-X.lnk', @ Start Menu 
                # See Command @ shortcut Properties >
                    C:\Cygwin\bin\run.exe --quote /usr/bin/bash.exe -l -c "exec /usr/bin/startxwin"
                
                # OR script it into Cygwin.bat [done!].
                    START cmd /c C:\Cygwin\bin\run.exe --quote /usr/bin/bash.exe -l -c "exec /usr/bin/startxwin"
                
                # Okay @ Cygwin ...
                bash -l -c '/usr/bin/startxwin &' 
                # ... works, but if from same terminal as ssh, 
                # then any GUI process launched @ remote terminal, 
                # sends X11 messages to its stdout. 
                
            # if not launched from terminal that started 'starxwin', then need to set var ...
            
                export DISPLAY=:0  # REQUIREd by Cygwin-X11 methods; 
                                   # 'startxwin' sets this automatically
        
            # launch SSH session w/ X11 Forwarding ...
                ssh -Y user@host.domain 
                
                ssh -Y Uzer@linux.LANDOMAIN

                # SUCCESS !!! logged in per above command and ...
            
                # tested GUI apps ...
                    gedit REF.vi.sh &    # editor
                    nautilus . &         # file explorer
                # both executed as backgound processes; 
                # launched GUI window @ local XPC Win7 PC !!!
                
                # before ending ssh, close all GUI apps, 
                # AND local X11 process OR remote 'dbus-launch' process.
    
    # ssh :: Firewall; set to allow
        # See 'REF.Network.sh'

# SMB/CIFS 
# SMB [Server Message Block] / CIFS [Common Internet File System]
# Mounting Windows (or other samba) shares is done through the cifs virtual file system client (cifs vfs) implemented in kernel and a mount helper mount.cifs which is part of the samba suite. 
# https://wiki.centos.org/TipsAndTricks/WindowsShares

    # CLIENT :: MOUNT SAMBA SHAREs
    # cifs-utils pkg & its dependencies; samba-common, samba-client pkgs
    # cifs-utils installs smbclient, but NOT full samba suite [samba server, etal]
    yum install cifs-utils samba-client samba-common  

        # smbclient :: Accessing SMB share [login] from Linux  http://www.tldp.org/HOWTO/SMB-HOWTO-8.html

        smbclient -L netbios-name [-s config.filename] [-U username]
        # or 
        smbclient //server/service [-s config.filename] [-U username]

        # show available shares on a given host [server]; here it's 'SMB'
        smbclient SMB 
        # => Not enough '\' characters in service; 
        # ... requires particular sharename, e.g., ...
        smbclient //HTPC/VM_SHARE -U SAMBA

            # => Enter SAMBA's password: 
            # => returns smbclient prompt ...
            # => Domain=[HTPC] OS=[Windows 7 Ultimate 7601 Service Pack 1] Server=[Windows 7 Ultimate 6.1]
            # => smb: \>

            # => smb: \> help
            # => smb: \> quit

        # use label method ...
        smbclient -L SMB -U routerUSER
        # => Server does not support EXTENDED_SECURITY but 'client use spnego = yes and 'client ntlmv2 auth = yes'
        smbclient -L SMB -U routerUSER --option=clientusespnego=no

        # NOTE: penetration test of HTPC ...
        #   valid user/pass @ LOCAL user logon FAILed per 'NT_STATUS_INVALID_WORKSTATION'
        #   valid user/pass @ LAN user logon FAILed per   'NT_STATUS_LOGON_FAILURE'

        # =>    routerUSER's password: 
        Domain=[LANDOMAIN] OS=[Unix] Server=[Samba 3.6.25]

            Sharename       Type      Comment
            ---------       ----      -------
            TC              Disk      WD_Elements's TC in WD Elements 1023
            tc_volume       Disk      WD_Elements's tc_volume in WD Elements 1023

              .
              .
              .
            IPC$            IPC       IPC Service (SMB)
        Domain=[LANDOMAIN] OS=[Unix] Server=[Samba 3.6.25]

            Server               Comment
            ---------            -------
            HTPC                 
            SMB                  SMB

            Workgroup            Master
            ---------            -------
            LANDOMAIN            SMB

        # MOUNT TEMPORARY  
            mount -t cifs  //SERVER/foldername /media/SERVERsharename -o user=winUSER,pass=winPASS,dom=winDOMAIN
            # NOTE: local dir '/media/SERVERsharename' must exist [use mkdir]

            mount -t cifs //SMB/data /media/SMB -o user=$USERNAME,pass=$PASS
            # => mounted @ mount-point: '/media/SMB'
            mount -t cifs //HTPC/VM_SHARE /media/HTPC -o user=$USERNAME,pass=$PASS
            # => mounted @ mount-point: '/media/HTPC'

            # show all mount[s] ...
            mount 
            # show CIFS mount[s] ...
            mount | fgrep 'cifs'
            # => //SMB/wde_40gb/40GB SAMBA on /media/SMB type cifs (rw)

            # unmount ...
            umount /media/SMB

            umount -a  # umounts ALL listed @ '/etc/mtab'

            cat /etc/mtab

        # MOUNT PERMANENT
            /etc/fstab 
            #   edit/add @ /etc/fstab; '\040' is escaped-octal for ASCII space char 
            //SMB/wde_40gb/40GB\040SAMBA /media/SMB cifs credentials=/etc/samba/cifs.creds

            # ... did NOT allow timestamp per modtime w/out uid,gid,dir_mode,file_mode [See 'man mount.cifs' (8)] ...
            cifs owner,uid=500,gid=500,dir_mode=0700,file_mode=0700,credentials=/home/Uzer/etc/samba/cifs.creds
            # username can have a form of 
            username=<domain>/<hostname>

            # then edit 'cifs.creds' file 
                username=winuser
                password=winpass

            # protect ...
            chmod 0400 /etc/samba/cifs.creds

                # UPDATE :: moved 'cifs.creds' file to ~/etc/samba/

            # refresh after fstab edit 
            mount -a

            # if noauto option @ fstab entry, mount per mount-pt, e.g., ...
            mount /media/SMB 

        # autofs [PERMANENT] [Legacy CentOS-6]
        #   better method than @ /etc/fstab; mount/unmount on any activity
        #   handles automounts when [unexpectedly] unavailable/offline
            yum install autofs 

            /etc/rc.d/init.d/autofs start|stop|restart|reload|status
            # or 
            service autofs start|stop|restart|reload|status

            # @ /etc/auto.master
                vi /etc/auto.master # add [TAB-delimited fields] ...
                # mount_pt          autofs_config_file_path  [options]
                /media/NAME	/etc/auto.NAME	[--timeout=60 --ghost]

                # '--timeout' defines how many seconds to wait before the file system is unmounted. 
                # '--ghost' creates empty folders for each mount-point in the file in order 
                #   to prevent timeouts, if a network share cannot be contacted.

            # @ /etc/auto.NAME [autofs_config_file_path]
                vi /etc/auto.NAME # add  [TAB-delimited fields]...
                mountedNAME	-fstype=cifs,[other_options]	://REMOTE_SERVER/REMOTE_SHARENAME


            # EXAMPLE ..

                # edit ...
                vi /etc/auto.master  # add ...
                /media/SMB  /etc/auto.SMB

                # create ...
                vi /etc/auto.SMB  # add ...
                SMB -fstype=cifs,owner,uid=500,gid=500,dir_mode=0700,file_mode=0700,credentials=/home/Uzer/etc/samba/cifs.creds ://SMB/wde_40gb/40GB\ SAMBA

                # UPDATE: autofs method FAILed ...
            
                # UPDATE: Can't use fstab method for whitespace; '\040'
                #         Use '\ ' instead; escape whitespace[s]

                # UPDATE: only root has access regardless of contents of auto.SERVERNAME 

                # UPDATE: found this ... " Under some Ubuntu versions, the default auto.master file is having a last line +auto.master which means that the file includes itself ! You must comment or remove that last line or you will get some wierd errors while trying to browe your automount directories."

            # restart :: launch autofs app ...
            /sbin/service autofs restart	# ... this process FAILed @ whitespace code '\040' in path [above]

            # status :: view active mount points ...
            /sbin/service autofs status 

            # reload :: If changed '/etc/auto.master' while autofs is running, reload it ...
            /sbin/service autofs reload

    # SERVER :: CREATE/SHARE SAMBA
    rpm -qa samba      # query installed
    yum info samba     # query installed & available & pkg blurb
    yum install samba  # install samba pkg

    # How to configure Samba [server] on RHEL 6
    # http://www.computernetworkingnotes.com/network-administration/how-to-configure-samba-on-rhel-6.html

        # Requires 3 rpm pkgs :: query/install [rpm -qa <pkg>]
            samba
            samba-common
            samba-winbind

        # Samba Daemons; three services; one optional and two required
                Service	Daemons	  Description
        Required	smb	smbd	  (SMB/CIFS Server) main samba service; authent. and auth.; file/printer sharing
        Required	nmb	nmbd	  (NetBIOS name server) Resources browsing
        Optional	winbind	winbindd  For host and user name resolution

            # query these services ...
            service winbind status  # => winbindd is stopped
            # start these services ...
            service smb start
            service nmb start
            service winbind start

            # set config so services are started on boot
            chkconfig smb on 
            chkconfig nmb on
            chkconfig winbind on

            # show config status [per runlevel]
            chkconfig --list | grep smb 
            # => smb            	0:off	1:off	2:on	3:on	4:on	5:on	6:off


        # How to allow samba through firewall; configure iptables and SELinux.

            # SAMBA uses ports 137,138,139 and 445
            Port 137	UDP NetBIOS name service (WINS)
            Port 138	UDP NetBIOS datagram
            Port 139	TCP NetBIOS Session (TCP), Windows File and Printer Sharing

            Port 445	Microsoft-DS Active Directory, Windows shares (TCP)
            Port 445	Microsoft-DS SMB file sharing (UDP)

            # iptables; add the following rules [sudo] ...
            iptables -A INPUT -m state --state NEW -m udp -p udp --dport 137 -j ACCEPT
            iptables -A INPUT -m state --state NEW -m udp -p udp --dport 138 -j ACCEPT
            iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 139 -j ACCEPT
            iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 445 -j ACCEPT

            # ... and restart [sudo]
            service iptables restart 
            # =>
                iptables: Setting chains to policy ACCEPT: filter          [  OK  ]
                iptables: Flushing firewall rules:                         [  OK  ]
                iptables: Unloading modules:                               [  OK  ]
                iptables: Applying firewall rules:                         [  OK  ]

            # SELinux options on/off [sets current state of a particular SELinux boolean]
            samba_enable_home_dirs		Enables the sharing of home directories
            samba_export_all_ro		Enable read-only access to ALL directories
            samba_export_all_rw		Sets up read/write access to ALL directories
            samba_share_t 			Default file which Samba can share # use this one, per shared dir

            # create share dir @ CREATED-SHARE-PATH, then run ...			
                chcon -R -t samba_share_t <CREATED-SHARE-PATH>

            # With '-P' option, changes boot-time default settins; without, just current/temporary-til-reboot
            setsebool [-P] <BOOLEAN> <on|off> 

            # to share default home dir ...
            setsebool -P samba_enable_home_dirs on

            # view settings ...
            getsebool -a | grep samba
            getsebool -a | grep smb

            # also info @ 
            /etc/samba/smb.conf
        
            # new Samba user added only from valid accounts, so create [one]
            useradd smbuser1
            passwd smbuser1

            # add smbuser1 to password database under /etc/samba/
            smbpasswd -a smbuser1

            # Create a smbgroup
            groupadd smbgroup

            # add smbuser1 to smbgroup
            usermod -G smbgroup smbuser1

            # view /home/ ....
            ls -l /home  # => 

                drwx------. 33 Uzer     Uzer      4096 Jan  9 19:47 Uzer
                drwx------.  2 root     root     16384 Dec 20 13:51 lost+found
                drwx------.  4 smbuser1 smbuser1  4096 Jan  9 20:22 smbuser1

    # Samba @ CentOS Wiki [CentOS 5.3] ... obsolete and not recommended methods
    # https://wiki.centos.org/HowTos/SetUpSamba?highlight=%28samba%29

        # SAMBA uses ports 137–139,445 # NetBIOS @ 137-139; Active Directory @ 445
        #  REF: NetBIOS relies on WINS [Windows Internet Naming Service]; 
        #    the DNS of yesteryear; Windows still uses, e.g., per "net view", "net use";
        #    NetBIOS/WINS replaced by Active Directory (AD), which uses DNS server, not NetBIOS. 
        #    AD was Microsoft's answer to Novell's Networking service (NDS), which was Novell's answer to UNIX's NFS server. 
        #    Going from NetBIOS/WINS to AD required a port change; MS chose  PORT 445 (UDP and TCP) for the AD service. 
        #    However, unless you have a Windows server w/ AD, NetBIOS is still the currently used service; 
        #    Windows still defaults to NetBIOS.

        # (Old system) NetBIOS/WINS

            # Port 137 – UDP NetBIOS name service (WINS)
            # Port 138 – UDP NetBIOS datagram
            # Port 139 – TCP NetBIOS Session (TCP), Windows File and Printer Sharing (this is the most insecure port) 

        # (Active Directory)/DNS

            # Port 445 - Microsoft-DS Active Directory, Windows shares (TCP)
            # Port 445 - Microsoft-DS SMB file sharing (UDP) 

        # iptables per NetBIOS or AD ... [see webpage] ... /iptables @ CentOS 6 says editing is NOT RECOMMENDED
        vi /etc/sysconfig/iptables

            # for Active Dir config
            -A RH-Firewall-1-INPUT -s 192.168.10.0/24 -m state --state NEW -m tcp -p tcp --dport 445 -j ACCEPT
            -A RH-Firewall-1-INPUT -s 192.168.10.0/24 -m state --state NEW -m udp -p udp --dport 445 -j ACCEPT

            # for NetBIOS config
            -A RH-Firewall-1-INPUT -s 192.168.10.0/24 -m state --state NEW -m udp -p udp --dport 137 -j ACCEPT
            -A RH-Firewall-1-INPUT -s 192.168.10.0/24 -m state --state NEW -m udp -p udp --dport 138 -j ACCEPT
            -A RH-Firewall-1-INPUT -s 192.168.10.0/24 -m state --state NEW -m tcp -p tcp --dport 139 -j ACCEPT

        # restart firewall :: 2 methods ...
        service iptables restart
        # or
        /etc/init.d/iptables restart 

        # SELinux 

        # show settings ...
        getsebool -a | grep samba
        getsebool -a | grep smb

        # info also @ 
        /etc/samba/smb.conf

        # SELinux options on/off [sets current state of a particular SELinux boolean]
        # With '-P' option, changes boot-time default settins; without, just current/temporary-til-reboot
        setsebool [-P] <BOOLEAN> <on|off> 

        # set samba as the domain controller [sudo]:
        setsebool -P samba_domain_controller on

        # share the default home directory, type this command [sudo]:
        setsebool -P samba_enable_home_dirs on

            # w/out sudo, reports 'Cannot set persistent booleans without managed policy.'

        ls -ldZ # shows dir 'context' 

        # Set label; do only @ directories you created! [else SELinux network configs issues]
        chcon -t samba_share_t /path

        # creating the share 
        mkdir /mnt/data
        mount /dev/hd3 /mnt/data

        # Now run the semanage command on that directory.

        semanage fcontext -a -t samba_share_t '/mnt/data(/.*)?'
        restorecon -R /mnt/data

        # smb.conf @ /etc/samba/
        # ... Entries @ each mount-point 
            [mount-pt-name]
            key1 = value1
      ...
            # modified workgroup @ ...
            vi /etc/samba/smb.conf

                < 	workgroup = LANDOMAIN
                ---
                > 	workgroup = MYGROUP
            # ... NOT needed; does nothing. Reset to original.

# ADDING A NETWORK DEVICE

# HOW TO SETUP NETWORK @ CentOS 7; NITWITS set install to DISABLE ethernet interfaces.
# http://www.krizna.com/centos/setup-network-centos-7/

    # show ethernet cards installed [NetManager] 
    nmcli d
    # GUI method [NetManager]
    nmtui
        "Edit a connection" > eth0 > "Edit"
        IPv4 CONFIGURATION > "Automatic"
        "[x] Automatically connect"

    # CLI method ...
    # Find/edit interace config @ ...
    /etc/sysconfig/network-scripts/
        # Find ...
        BOOTPROTO=none
        ONBOOT=no
        # replace w/ ...
            # For DYNAMIC IP
            BOOTPROTO=dhcp
            ONBOOT=yes
            # For STATIC IP
            BOOTPROTO=static
            ONBOOT=yes
                # ... append @ end of file ...
                IPADDR=192.168.1.103
                NETMASK=255.255.255.0
                GATEWAY=192.168.1.1	

    # Optionally, edit confg @ ...
    /etc/sysconfig/network	
        HOSTNAME=linux.LANDOMAIN
        DNS1=192.168.1.1
        SEARCH=LANDOMAIN
    # Restart network service
    systemctl restart network
    # Adding a qeth Device
    # https://www.centos.org/docs/5/html/Installation_Guide-en-US/s1-s390info-addnetdevice.html#s2-s390info-reference

    # query :: qeth device driver modules loaded
    lsmod | grep qeth # lsmod prints the /proc/modules file
    
    #If not loaded, you must run the modprobe command to load them:
    modprobe qeth
    
    # create a qeth group device. 
    echo read_device_bus_id,write_device_bus_id,data_device_bus_id > /sys/bus/ccwgroup/drivers/qeth/group
    echo 0.0.0600,0.0.0601,0.0.0602 > /sys/bus/ccwgroup/drivers/qeth/group
    # verify that the qeth group device was created properly: 
    ls /sys/bus/ccwgroup/drivers/qeth
    # => 0.0.0600  0.0.09a0  group  notifier_register
    
    # ... more ...

# NetworkManager
    NetworkManager  # a service to set up your network connection; especially useful to configure a wireless connection; is disabled by default.

    # Enable [auto-start] NetworkManager on boot
    chkconfig NetworkManager on		# legacy
    systemctl enable NetworkManager  # systemd

    # start [now]
    service NetworkManager start
    systemctl start NetworkManager   # systemd

    # @ GUI [Gnome], Notification Area [top-right] will show a new icon. Left-click shows list of available Wireless networks.

    # Disable network and wpa_supplicant services on boot
    chkconfig network off
    chkconfig wpa_supplicant off

    systemctl disable NetworkManager  # systemd
    systemctl disable wpa_supplicant  # systemd

# WiFi :: Edimax AC-1200
    # https://edimax.freshdesk.com/support/solutions/articles/14000041287-how-to-install-ew-78xx-11ac-adapter-in-linux-with-kernel-higher-than-v4-1
    su
    # install DKMS pkg.
    yum install dkms

    # Setup two environment variables.
    DRV_NAME=rtl8812AU; DRV_VERSION=4.3.14

    # Create a folder or directory for the open source driver.
    mkdir /usr/src/${DRV_NAME}-${DRV_VERSION}

    # Clone the github driver to the newly created folder.
    git archive driver-${DRV_VERSION} | tar -x -C /usr/src/${DRV_NAME}-${DRV_VERSION}
    # FAILed ...
    # => fatal: Not a git repository (or any of the parent directories): .git
    #    tar: This does not look like a tar archive
    #    tar: Exiting with failure status due to previous errors
    git clone https://github.com/diederikdehaas/rtl8812AU.git /usr/src/${DRV_NAME}-${DRV_VERSION} 
  # https://github.com/diederikdehaas/rtl8812AU.git

    # THEN ... [ran without comment of any sort]
    git archive driver-${DRV_VERSION} | tar -x -C /usr/src/${DRV_NAME}-${DRV_VERSION}
    # ... but SAME ERROR @ 'dkms build ..."

    # try [installed] ...
    yum install kernel-headers kernel-devel gcc

    dkms add -m ${DRV_NAME} -v ${DRV_VERSION}
    # FAILed => 'Your kernel headers for kernel 2.6.32-642.el6.i686 cannot be found '...

        # UPDATE :: success after CentOS kernel update; 'yum -y update kernel' !
        # Deleted local git-clone-dir [see above]; ran 'git clone ...' again; rran 'dkms add -m...' again

        dkms build -m ${DRV_NAME} -v ${DRV_VERSION} 
        # FAILed ...
        #  'make'.......(bad exit status: 2)
        #  Error! Bad return status for module build on kernel: 2.6.32-642.11.1.el6.i686 (i686)
        #  Consult /var/lib/dkms/rtl8812AU/4.3.14/build/make.log for more information.
            # make[2]: *** [/var/lib/dkms/rtl8812AU/4.3.14/build/core/rtw_p2p.o] Error 1
            # make[1]: *** [_module_/var/lib/dkms/rtl8812AU/4.3.14/build] Error 2
        dkms install -m ${DRV_NAME} -v ${DRV_VERSION}
        # remove drvr and delete git repo @ FAIL
        dkms remove ${DRV_NAME}/${DRV_VERSION} --all
        rm -rf /usr/src/${DRV_NAME}-${DRV_VERSION}

# WiFi :: WIRELESS ...
    # Making Wireless work ...
    # https://wiki.centos.org/HowTos/Laptops/Wireless
    
    # LinuxWireless.org
    # http://linuxwireless.org/en/users/Drivers/
    
    # WiFi Adapters
        # Atheros ath5k driver ships with CentOS
        modprobe ath5k
        # Atheros AR9485 (ath9k) ships with CentOS 6
        modprobe ath9k
        # enable NetworkManager to use either
        service NetworkManager start
        systemctl start NetworkManager  # systemd
        
        # Atheros (madwifi) [DKMS based; complete driver]
        # Requires network connection to make this easy. 
        # Configure RPMforge in yum; use yum to install the madwifi package:
        yum install madwifi
        # This will pull in DKMS and a bunch of other dependencies required to build the madwifi kernel module. (So this is not just the firmware, but a complete driver). 
        # load the modules:
        modprobe ath_pci		

        # Intel Pro Wireless 2100 (ipw2100) is 'tested'

        # If you have a working network connection and RPMforge configured in yum, then  install ipw2100-firmware:
        yum install ipw2100-firmware

        # If you don't have a network connection, use another system to download: 
        # Download [firmware] RPM packages named 'ipw2100-firmware' from RPMforge @ http://packages.sw.be/ipw2200-firmware/ on another system and transfer the file using a USB stick. 
        # Then install the package manually using: 
        rpm -Uhv <filename>

        # Then reload ipw2100 module:
        modprobe -r ipw2100
        modprobe ipw2100

# FIREWALL  
  firewalld      # Linux firewall daemon (See REF.RHCE.sh)
  firewall-cmd   # tool to modify firewall rules; DIRECT rules & RICH rules

    iptables  # IP Tables; tool for PACKET FILTERING and NAT [IPv4/IPv6] 
    #  an extremely powerful FIREWALL 
  # - listing contents of the PACKET FILTER RULESET
  # - adding/removing/modifying rules in PACKET FILTER RULESET
  # - listing/zeroing per-rule counters of PACKET FILTER RULESET
  # http://www.netfilter.org/ 
    # https://wiki.centos.org/HowTos/Network/IPTables

  # list rule(s); output looks just like the commands that were used to create them 
    iptables -S        # List Rules by Specification
    iptables -S TCP    # List Rules of a Specific Chain [TCP]
    iptables -L        # List Rules as Tables
    iptables -L INPUT  # List Input Chain Rule Table 

    # 4 commands to view ALL iptables rules
    # https://jvns.ca/blog/2017/06/07/iptables-basics/ [Julia Evans]
      iptables -L            # lists the filter table; implicit `-t` here
      iptables -L -t nat
      iptables -L -t mangle
      iptables -L -t raw 

    nft  # nftables [nft] is newer 'version' of iptables  
    # http://www.netfilter.org/projects/nftables/index.html

# VNC [Virtual Network Connection] :: Remote GUI [RFB Protocol; pixel-based]
#   https://en.wikipedia.org/wiki/Virtual_Network_Computing
#   Creates GUI session of remote machine on local Xserver, 
#   just as local machine GUI runs on Xserver. 
#   VNC is insecure, so concurrent ssh session; 'vncviewer -via user@host.domain:1'
#     LOCAL [VNC client]              REMOTE [VNC server]
#     --------------------            --------------------
#     Machine => vncviewer => sshd => vncserver/Xserver
#     Machine <= Xserver           <= vncserver@.service 
  yum -y install tigervnc tigervnc-server # client + server pkgs
  useradd vncuser
  passwd vncuser
  cd /usr/lib/systemd/system
  cp vncserver@.service vncserver@\:1.service # escaped colon; 1 is 1st session 
  vim vncserver@\:1.service # => replace '<USER>' w/ 'vncuser'
    ExecStart=/usr/sbin/runuser -l <USER> -c
    PIDFile=/home/<USER>/.vnc/%H%i.pid
  systemctl daemon-reload # inform systemd of changes [update]
  # RESET vncuser password FROM vncuser account, NOT from root [contrary to docs]
  su - vncuser
  vncpasswd
  systemctl start vncserver@localhost\:1 # FAILed
  firewall-cmd --permanent --add-service vnc-server
  # connect [test self @ localhost]
  vncviewer -via vncuser@host.domain localhost:1 # self-test host.domain = localhost
