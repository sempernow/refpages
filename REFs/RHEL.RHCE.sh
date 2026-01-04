exit 
# Lesson 1  RHEL Identity Management [IdM]
# ========================================
    # Based on FreeIPA (Identity Policy Audit) Project
    #  https://www.freeipa.org
    #  https://en.wikipedia.org/wiki/FreeIPA
    #  - 389 Directory Server for LDAP implementation
    #  - MIT Kerberos 5 for authentication and single sign-on
    #  - Apache HTTP Server & Python for management framework & Web UI
    # 
    #  Single Sign-on using LDAP [directory/database] Server
    #    https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol
    #    https://en.wikipedia.org/wiki/Single_sign-on
    #  Services [choices; not all used @ any 1 machine]
    #    389 Directory Server [LDAPv3 Data Store]
    #      https://en.wikipedia.org/wiki/389_Directory_Server
    #    MIT Kerberos KDC; Single Sign-on; Kerberos Protocol
    #      https://en.wikipedia.org/wiki/Kerberos_(protocol)
    #    Integrated Certificate System; DogTag Project 
    #    Integrated NTP Server [Disable chrony to use!]
    #    Integrated Optional DNS Server [ISC Bind Service]
  # 
    #  IdM Server Components and Requirements
    #    Host Name Resolution [DNS or /etc/hosts]
    #    ipa tool; ipa-server & ipa-client packages
        yum -y install ipa-server bind nds-ldap
        ipa-server-install # handles all the params
        systemctl restart sshd # to obtain Kerberos Credentials
        ipa user-find admin # verify IPA access

    # External Authentication :: Authentication Configuration
      # authconfig utility has lots of methods and optional configs
        authconfig-tui # tui; graphical [ncurses] box 
        authconfig-gtk # gui
        
        yum whatprovides */authconfig.gtk
        
        yum -y authconfig-gtk

    # Authenticate against an LDAP server using Kerberos
    
# Lesson 2  Configuring iSCSI Target and Initiator 
# ================================================
    # iSCSI Storage Area Network [SAN] PROTOCOL.
    # SCSI over IP; uses existing network infrastructure, unlike Fibre Channel.
    # iSCSI provides BLOCK-LEVEL ACCESS to storage devices over LANs and WANs.
    # https://en.wikipedia.org/wiki/ISCSI
    # SCSI = 'Small Computer System Interface'
    #
    # The protocol allows clients (INITIATORs) to send SCSI Command Descriptor Block (CDB) commands to storage devices (TARGETs) on remote servers. Thus emulating SCSI using a storage backend; presenting it on the network using iSCSI targets; allowing consolidation of storage into storage arrays while providing clients (e.g., database and web servers) with the illusion of locally attached SCSI disks.
    # 
    # TERMS:
        # IQN: iSCSI Qualified Name; identifies targets and initiators
        # Initiator: iSCSI client
        # Target: iSCSI server service; the storage backend.
        # ACL: Access Control List; per node; per IQN
        # Portal/Node: IP Address and port used to establish iSCSI connections
        # Discovery: process of initiator finding targets configured on a portal
        # LUN: Logical Unit; block devices shared thru target.
        # TPG: Target Portal Group; IP addr & ports bound to specific iSCSI target

        # Create Target [LUNs] SAN; iSCSI Target Server
        
        # Connect Initiator to SAN; iSCSI Initiator Server
        
            yum -y install iscsi-initiator-utils
        
            man iscsiadmin
    
# Lesson 3  System Monitoring
# ===========================
    # Metrics
    #  - Low Latency, e.g. database load
    #  - High Throughput, e.g., file server load
    # Parameters
    #  - Memory, Disk, CPU
    # Tools 
    top; iostat; iotop; vmstat; sar
    
    top  # live/interactive system resources overview; very efficient
    htop # uses 5x more resources than top
    
    top 
        F # 'fields management'
        Q # quit fields management
        W # write setting; current setting as default
        cat .toprc # settings, e.g., those saved per 'W'
        # Appropriate load average is '1' per CPU 
        # us: user-space, sy: system-space [run w/ root privilege]
        # id: idle, wa: waiting for I/O
        
        # Memory buffers & caches Mem ~ 33% Mem, each
    
    iostat # I/O overview
    iotop  # very good; may need to install 
    yum install iotop

        # Simulate workload ... copy entire main HDD to null ...
        dd if=/dev/sda of=/dev/zero & 
        
        iotop      # view I/O performance per process
        
        killall dd # when done
        
    vmstat # used to detect bottlenecks
        # r: running, b: blocking, swap, buff, cache    
        # si:swap in, so: swap out, bi/bo: blocks in/out [reading/writing]
        cat /proc/meminfo # all info on memory utilization
        # Virtual memory [VmallocTotal] is 35 TB; all allocated
        # Resident memory; actual and used
        
        vmstat SECONDS_INTERVAL POLLING_LOOPS # define snapshot
        vmstat 2 5 # example
        vmstat -s  # memory utilization details
    
    sar # System Activity Reporter Components
        yum install -y sysstat 
        # sysstat must run for sar data collection
        # Collects data every 10 minutes
        # trending info; can use like iostat, vmstat
        # can construct user-specified collections 
        LANG=C # set prior to launching sar
        echo alias sar='LANG=C sar' >> /etc/bashrc
        # sar data is collected per cron jobs @ 
        /etc/cron.d/sysstat # define cron jobs; sa1, sa2
        /etc/sysconfig/sysstat # history var [tunable]
        /var/log/sa # data written here; read w/ sar
        man sar
        
        sar -b     # I/O 
        sar -P 0   # trending long-term CPU info
        sar -n DEV # network activity
    
# Lesson 4  System Optimization Basics
# ====================================
        /proc filesystem # analyse/optimize/modify w/ sysctl
    # /proc fs is the interface to kernel; set kernel params 
        /proc/sys # interface to OPTIMIZATION
        /proc/sys/vm/swapiness # memory handling
        
        # TEMPORARY optimizing; reverts on reboot
        echo NEW_VALUE > /proc/.../FILE # try this BEFORE sysctl
        
        # PERMANENT changes
        sysctl 
        
            /etc/sysctl.conf # => sysctl => /proc/sys
            /etc/sysctl.d 
        
        sysctl -a # list all tunables
        
        sysctl -a | grep NAME # list all tunable for NAME
        # params namespace ...
        word1.word2....
        # has corresponding FILE @ proc fs ...
        /proc/sys/word1/word2/...
    
            # E.g., Modify Network Behavior
            
            # Enable/disable ICMP control messages; used by ping
            
                # what ...
                sysctl -a | grep icmp
            
# Lesson 5  Logging
# =================
        rsyslog  # THE logging authority; classical/legacy  http://www.rsyslog.com/
            # log settings per rsyslog.conf
            /etc/rsyslog.conf    # rsyslog; rocket-fast system for log processing  
            man rsyslog.conf(8)  # rsyslogd(8) logs system messages; specifies rules for logging. 

        journald # new; RHEL7 @ systemd; systemctl/journalctl
        # - Connecting journald to rsyslog
        # - Setup Remote Logging
        # - rsyslog modules
        #
        # RHEL logging schemes
            #
            # SERVICEs |=> /somewhere/some_service.log
            #          |=> systemctl => journald [journalctl]
            #          |=> rsyslogd  => /var/log/...
    
    # CONFIG to connect journald to rsyslog 
        journalctl <==> rsyslog # through MODULES
        # see current rsyslog config @ 
        cat /etc/rsyslog.conf 
        
        # SENDING journal to rsyslog.conf is NOT ENABLED by default
            $Modload omjournal # load module; ENABLE
            *.* :omjournal:    # any facility; any priority
        # RECEIVING from journal in rsyslog.conf IS ENABLED by default
            $ModLoad imuxsock  # input module; UNIX; socket
            $OmitLocalLogging off # ENABLE
            # 'In/etc/rsyslog.d/listend.conf' # LINGO used
            vim /etc/rsyslog.d/listend.conf
            $SystemLogSocketName /run/systemd/journal/syslog # socket name
        
        # MODULES [rsyslog]
            im*: # input module
            om*: # output module 
            # many others; parser, message modification, ...
            # E.g., ...
            # Import Text Files [Apache Error logs]
                $ModLoad imfile # input file
                $InputFileName /var/log/httpd/error_log # input file name
                $InputFileTag apache-error:  # Apache error logs
                $InputFileStateFile state-apache-error # make sure its running okay
                $InputRunFileMonitor # monitor Apache files
            # Export to a Database
            $ModLoad ommysql  # send to MySQL database
            $ActionOmmysqlServerPort 1234 # port 
            *.*:ommysql:database-servername,database-name,database-userid,database-password # MySQL connection info
            
        # REMOTE LOGGING
            vim /etc/rsyslog.conf 
            # see '# Provides UDP syslog reception', and the 'TCP' equiv message
            # use TCP if all module logs desired support TCP
            # UDP is unreliable, but more compatible
            # must also set remote server; see '# remote host is ...'
            @@servername.com:514 # if by TCP
            @servername.com:514  # if by UDP
            
        # Exercise 5 
            # - Configure server 1 as a log server
            # - From server 2, send all log messages to server 1
            # - Configure integration between journald and rsyslog so that
            #   all journald messages will occur in rsyslog also 
        
# Lesson 6  Advanced Networking
# =============================
    # Apache Web Server & firewalld
    # NIC Teaming
    # Network Bridges

    # NETWORK BASICS REVIEWed
    
        # Verifying Current State [Review]
            ip addr [show]         # addr info for all interfaces
            ip -s link show eno1   # packet statistics
            ip route               # routing info
            tracepath www.foo.com  # analyze a path
            traceroute www.foo.com # analyze a path
            
            netstat -tulpen        # analyze ports and services
            ss -tulpen             # analyze ports and services
        
        # Network Manager; monitor/manage network settings GUI [systemd]
        nmcli           # CLI util 
        nmtui           # TUI [Text User Interface] util
        
        nmcli # https://linux.die.net/man/1/nmcli
        nmcli [ OPTIONS ] OBJECT { COMMAND | help } 

            OBJECT := { nm | con | dev }
            
                COMMAND per OBJECT
            
                nm  COMMAND := { status | sleep | wakeup | wifi | wwan } 
                con COMMAND := { list | status | up | down } 
                dev COMMAND := { status | list | disconnect | wifi } 
                
        nmcli # TERMINOLOGY ...
            device      # network interface
            connection  # collection of config settings; e.g., @ WiFi
                                    # multiple connections PER DEVICE; ONLY ONE IS ACTIVE 
            ip4, ipv4   # note varying argument requirements per command
            
        nmcli # USAGE ...
            nmcli con show            # connections per device
            nmcli con show NAME       # details for NAMEd device
            nmcli dev status          # status of all devices/connections
            nmcli dev status DEVICE   # status of DEVICE 
            nmcli dev connect DEVICE  # connect DEVICE
            nmcli connect down DEVICE     
            nmcli connect up DEVICE 
            nmcli con up "CONNECTION" # switch to CONNECTION [make active]
            
            # Show available WiFi networks 
            nmcli dev wifi                      # channel/strength/...
            nmcli -f ALL dev wifi               # per SSID/BSSID/freq/...
            nmcli -m multiline -f ALL dev wifi  # @ multi-line view
            nmcli dev wifi rescan               # rescan 

        # MODIFY network; 2 methods 
        # 1. Edit config file[s] directly
        # 2. Network Manager util [GUI/nmcli/nmtui]
        
        # 1. MODIFY per config files
            /etc/sysconfig/network-scripts/ifcfg-NAME

            nmcli con reload # ACTIVATE these new settings 
            # or 
            nmcli con down "NAME"; nmcli con up "NAME" # better
            
        # 2. MODIFY per Network Manager [nmcli] 
        
            # Create new connection named 'dhcp' 
            #   that autoconnects on interface 'eno1'
            nmcli con add con-name "dhcp" type ethernet ifname eno1
            nmcli con up "static" # ACTIVATE these new settings
        
            # Create new connection named 'static' that does NOT autoconnect;
            nmcli con add con-name "static" ifname eno1 autoconnect no type ethernet ip4 192.168.122.102 gw4 192.168.122.1
            # 'gw4' is gatway's ip4 address; 'ip4' is interface's ip4 address
            
            # Modify an existing connection; set DNS server 
            nmcli con mod "static" ipv4.dns 192.168.122.1 
            # note 'ipv4', NOT 'ip4'
            
            # Modify; add another DNS server 
            nmcli con mod "static" +ipv4.dns 8.8.8.8 # note '+ipv4'
            
            # Modify static IP address and gateway
            nmcli con mod "static" ipv4.addresses "192.168.100.10/24 192.168.100.1"

            # Modify; add secondary IP address 
            nmcli con mod "static" +ipv4.addresses 10.0.0.10/24
            
            nmcli con up "static" # ACTIVATE these new settings

        # aHOST 
            vim /etc/hostname
            # or 
            hostnamectl set-hostname new.name.com # change 
            hostnamectl status                    # show
            
        # DNS 
            # pushed from 
            /etc/sysconfig/network-scripts/ifcfg-NAME # so change it here
            # to 
            /etc/reolv.conf
            # or 
            nmcli con mod "static" ipv4.dns 8.8.8.8  # if undefined
            nmcli con mod "static" +ipv4.dns 8.8.8.8 # to add
        
    # ROUTING
    
        # STATIC ROUTES
        #   for connecting nodes [machines] on different LANs thru router(s) 
        #   other than the default gateway router.
            # configure a static route for a CONNECTION using ...
            nmtui > Edit > add destination and gateway IP addresses 
            nmtui > Deactivate/Activate
            ip route show # should see here
            # also @ 
            /etc/systemconfig/network-scripts/route-CONNECTION_NAME
            
        # NETWORK BRIDGES @ KVM Environment 
        
                           eno1   ... Physical Interface
                            |
                         Virbr0      ... Virtual Bridge [Switch]
                        ________|_________
                  |                 |
                Vnet0             Vnet1  ... Virtual Interfaces
                  |                 |
                eth0              eth0   ... Virtual Boards
                 VM0               VM1

            # show ...
            brctl show 
            ip link show 
            
            virsh start vm2 # launch a virtual machine 
            
        # VIRTUAL BRIDGE SETUP
        yum install bridge-utils -y
        
        # Disconnect current interace and reconnect to bridge
        nmcli dev show
        nmcli dev disconnect INTERFACE 
        # do for every interface on the bridge ...
        nmcli con add type bridge-slave con-name br0-port1 ifname INTERFACE master br0
        # ... success, but complains that br0 doesn't exist [yet]; okay
        
        # create br0
        nmcli con add type bridge con-name br0 ifname br0 
        brctl show # now shows br0 exists 
        
        # view/edit 
        /etc/sysconfig/network-scripts/
            ifcfg-br0
        
        man nmcli 
        man nmcli-examples # NICE !!! USE THIS !!!
        
    # BONDS and TEAMS
        # Link Aggregation; multiple physical interfaces to form one interface.
        # Use TEAMing; Bonding is depricated
        # Utilitzes kernel driver and user-space daemon
        teamd
        # Teamd modes a.k.a. 'runners': 
        #  broadcast, roundrobin, activebackup, loadbalance, lacp
        teamctl team0 state # show current state of team named team0
        # Configure with nmcli; 4 steps
        nmcli
    
    # IPv6
        # {NETWORK(network-address)}::{NODE(MAC-address)}/MASK
        #  Can config with 
        nmcli con add con-name ...
        man nmcli-examples # Example 9. is good resource
        # or 
        nmtui # don't need to bother with syntax
        
    # Exercise 6
        ip link # view 
        nmcli dev dis eth0; nmcli dev dis eth1 # disable interfaces
        # add team 
        nmcli con add type team con-name team0 ifname team0 config '{"runner:{"name":"activebackup"}}'
        # add devices to team
        nmcli con add type team-slave con-name team0-port1 ifname eth0 master team0; # repeat for eth1
        teamctl team0 state # should be up and running
        # put team in a bridge; must disable NetworkManager and disable teh team0 driver, so bridge can take config instead of team driver.
        nmcli dev dis team0
        systemctl stop NetworkManager; 
        systemctl disable NetworkManager
        
        yum install bridge-utils # REQUIREd to create bridge !!!
        
        # config directly 
        vim /etc/sysconfig/network-scripts/ifcfg-team0
            BRIDGE=brteam0 # add
            # remove IP config from ifcfg-team0-ports files
            # create ifcfg-brteam0 file 
                DEVICE=brteam0
                ONBOOT=yes
                TYPE=Bridge
                IPADDR0=192.168.122.100
                PREFIX0=24
                
        systemctl restart network

# Lesson 7  Linux Firewalld
# =========================
firewalld        # daemon
firewall-cmd     # CLI 
firewall-config  # GUI 

firewall-cmd  
    --state          # CURRENT STATE 
    --permanent      # changes survive reboot
    --reload         # changes are immediate 

    --list-all       # all config 
    --list-all --zone=dmz # filter 

    # default zone, etc @ config ...
        /etc/firewalld/firewalld.conf

    # view only here
    /usr/lib/firewalld/services/  # XML files 
    ldap.xml, ftp.xml, ... 
    # make/change here 
    /etc/firewalld/services/ 

    # CONFIG Firewalld SERVICES & ZONES 

    systemctl stop iptables  #  
    systemctl stop mask      # prevents from auto-restarting 
    # make sure firewalld is running 
    systemctl unmask firewalld 
    systemctl start firewalld

    firewall-cmd 
        --list-all # all config 
        --list-services  # all currently active zones 
        --get-services   
        --get-zones      # all defined zones
        --list-all --zone=dmz # filter 
        --get-active-zones 

        # add service to current zone 
        --add-service=vnc-server 
        # add service to specified zone 
        --add-service=vnc-server --zone=dmz
        --add-source=10.0.0.0/24  # allow IP
        --add-port 8000/tcp       # add/specify port/protocol

        # ... appending ...
        --reload    # to test now 
        --permanent # to make permanent
        --list-all   # validate config change(s) 

    # CREATE SERVICE FILES; XML files
    # .i.e., create/configure services
    firewall-cmd --get-services  
    # view   @ /usr/lib/firewalld/services/
    # modify @ /etc/firewalld/services/ 	 
    # so, start w/ copy from /usr/lib to /etc/  
    # then modify it, then 
    firewall-cmd --add-service=fooservice --permanent 
    
    # RULES; 2 types 
        # DIRECT: hand-coded rules; processed first; not recommended
        # RICH: expressive language to express custom rules; 
        # order applied: port-forwarding & masquerading, logging, allow, deny
        man firewalld.richlanguage(5)

        # reject an entire CIDR block source  
        firewall-cmd --permanent --zone=public \
           --add-rich-rule='rule family=ipv4 source address=10.0.0.100/32 reject'

        # rate limit http; 3 packets per minute [not a practical example]
        firewall-cmd --permanent \
            --add-rich-rule='rule service name=http limit value=3/m accept'

        # accept IGMP protocol; protocols defined @ /etc/protocols/ 
        firewall-cmd --permanent \
            --add-rich-rule='rule protocol value=igmp accept'

        firewall-cmd --permanent \
            --add-rich-rule='rule family=ipv4 source address=10.0.0.0/24 port port=7900-7905 protocol tcp accept'

        # log ssh packet info @ 2 per minute
        firewall-cmd --permanent \
            --add-rich-rule='rule service name="ssh" log prefix="ssh" level="notice" limit value=2/m accept'

        firewall-cmd --reload    # apply new rich rule(s) 
        firewall-cmd --list-all  # lists all the present rules

    # MASQUERADING; configuring NAT 
        firewalld-cmd --permanent --zone=public \
            --add-masquerade 

    # PORT FORWARDING; all incomming TCP @ 888 forwarded to 10.0.0.10:80
        fireqall-cmd --permanent --zone=public \
            --add-forward-port=port=888:proto=tcp:toport=80:toaddr=10.0.0.10

# Lesson 8 Configuring Apache
# ===========================
    httpd  # Apache Web Server :: INSTALL and CONFIGURE
        yum install httpd -y  
        systemctl enable httpd 
        systemctl start httpd 
        firewall-cmd --permanent \
            --add-service=http --add-service=https
        firewall-cmd --reload  

        elinks  # text-based browser for DevOps
        yum install elinks -y  
  
        # show Apache CONFIG FILES 
        rpm -qc httpd 

            /etc/httpd                   # Server root; all paths are realitve to it 
            /etc/httpd/conf/httpd.conf   # Main config file 
            /etc/httpd/conf.modules.d    # Modules' config dir; added per module install  
            /etc/httpd/conf.d            # Supplemental config dir; used by plugin files 
        
    # Apache Web Server :: MAIN CONFIG file [httpd.conf]
        /etc/httpd/conf/httpd.conf      
            ServerRoot "/etc/httpd"       # so `foo/bar` maps to `/etc/httpd/foo/bar`
            Listen 888                    #  set to `80` to listen to all incomming 
            Include conf.modules.d/*.conf
            User apache                   # apache process runs as this user/group
            Group apache
            ServerAdmin root@localhost
            ...
            DocumentRoot "/var/www/html"  # public root dir; index.html, etc goes here 
            # further directives per dir 
            <Directory "/var/www">        # NOT public; may have scripts, etc
                    AllowOverride None
                    Require all granted       # ???
            </Directory>
            <Directory "/var/www/html">   # allows publilc access 
                Options Indexes FollowSymLinks
                AllowOverride None
                Require all granted
            </Directory>
            ...
            IncludeOptional conf.d/*.conf
            ...
            ErrorLog "logs/error_log"     # default for Apache logs
            ...

    # test
        elinks http://localhost:888  # `q` to exit   

    # `DocumentRoot ...` :: CHANGE 
        DocumentRoot "/web"  # @ `/etc/httpd/conf/httpd.conf`
        # but this reveals an SELinux issue; Apache's info page 
        # loaded instead of the expected `/web/index.html` 
            ls -Zd /web  # SELinux settings 
            # => drwxr-xr-x. ... unconfined_u:object_r:default_t:s0 /web
        # whereas 
            ls -Zd /var/www/html
            # => drwxr-xr-x. ... system_u:object_r:httpd_sys_content_t:s0 /var/www/html
        # temp disable SELinux 
            setenforce 0  # ... and /web/index.html loads per same elinks command 
        # fix SELinux issue 
            semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"  
            restorecon -R -v /web
        # again, the same elinks loads the proper page, @ /web/index.html 
        # and SELinux settings show @ ...
            ls -Zd /web  
            # => drwxr-xr-x. ... unconfined_u:object_r:httpd_sys_content_t:s0 /web

        # ACLs :: Grant DocumentRoot access to other users, e.g., to DevOps, etc 
            groupadd webdev  # create group `webdev` 
            # apply to NEW files; `g:....`  
                setfacl -R -m g:webdev:rwX /web  # set file ACL; `X` on dirs only
            # apply to EXISTING files; `d:g:...`
                setfacl -R -m d:g:webdev:rwX /web  # set file ACL; `X` on dirs only
            # show file ACLs
                getfacl /web  

    # Virtual Hosts :: CONFIG
        # `NameVirtualHost` :: Name-based Virtual Hosting; 
        # mapping multiple names to 1 IP Address
            sales.foo.com      80.1.2.3
            accounts.foo.com   80.1.2.3 
        # per new config file, `sales.conf`, @ `/conf.d` dir
            vim /etc/httpd/conf.d/sales.conf 
            # create/edit/add ...
                <Directory /srv/web/sales>
                    Require all granted 
                    AllowOverride None 
                </Directory>

                <VirtualHost *:80>   # overrides any normal host thereof
                #<VirtualHost _default_:80>  # equiv for 'IP virtual hosting'
                    DocumentRoot /srv/web/sales 
                    ServerName  sales.foo.com 
                    ServerAlias www.sales.foo.com 
                    ServerAdmin root@sales.foo.com 
                    ErrorLog  "logs/sales_error_log"
                    CustomLog "logs/sales_access_log" combined
                </VirtualHost> 

            # can do this @ `httpd.conf` instead; esp if a minor config/mod
            <VirtualHost ...>
            </VirtualHost>

            # VIrtual Host FAILOVER 
                # if virtual host does not exist, 
                # then Apache serves whatever other is configured,
                # so best to create a DEFAULT VIRTUAL SERVER, e.g., 
                /etc/httpd/conf.d/000.conf  # first @ alpha-order; 
                # to serve a default web pagge (index.html) 
                # as the failover on ANY virtual host failure.

        # create dirs `/srv` and `/srv/web`
        # SELinux :: set context [per default config, e.g., view @ ls -Z /web]
            semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"  
            restorecon -R -v /web 

        # Name Resolution :: CONFIG 
            /etc/hosts  # sans DNS Server, add it to hosts file
            192.168.4.101 apache.server.com  sales.foo.com

            # on FAIL  
                cat /var/log/sales_error_log  
                # => ... no matching DirectoryIndex (index.html) found 
                # or 
                journalctl UNIT=httpd.service 

    # Virtual Hosts :: Typical Errors 
        #	- No DocumentRoot specified 
        #	- Non-default DocumentRoot with faulty SELinux label 
        #	- No name resolution; error in naming; `example.com` instead of `www.example.com`

# Lesson 9 Managing Advanced Apache Features
# ==========================================
    #	- Authenticated Web Servers 
    #	- LDAP Authentication 
    #	- Enabling CGI Scripts 
    #	- SSL/TLS setup

    #	- Authenticated Web Servers 
        # Protected Directories; accessible only per authentication 
            # per httpd MANUAL
            # "Apache HTTP Server Version 2.4 Documentation"
            # https://httpd.apache.org/docs/2.4/ 
            # or INSTALL httpd manual LOCALLY ...
                yum search httpd | grep manual
                yum install httpd-manual -y

                /etc/httpd/conf.d/manual.conf
                <Directory "/usr/share/httpd/manual">  # added  
                # so, view ...
                firefox http://localhost/manual  

        # AUTHENTICATION
            # Require user logon per password authentication	
            # create a password file; add Apache user to a config file 
                htpasswd -c /etc/httpd/htpasswd apacheUser  # prompts for password
                # apache manual puts the file here ...
                    htpasswd -c /usr/local/apache/passwd/passwords apacheUser
            # create index page @ `/etc/httpd/htpasswd/index.html`

            # add Directory 
            /etc/httpd/conf/httpd.conf   # Main config file 
                <Directory "/www/docs/private">
                        AuthName "Private"
                        AuthType Basic
                        AuthUserFile "/etc/httpd/htpasswd"  # match @ `htpasswd ...`
                        Require valid-user
                </Directory>

            # Authenticated Directroy SIGN-IN PAGE; 
            # PROMPTS for Username/Password ...
            firefox http://localhost/private

    #	- LDAP Authentication 
        # if many users, the basic method above becomes burdensome 
        # but setup is "quite complex"; See http manual

    #	- Enabling CGI Scripts  
        # to serve dynamic content; 
        # CGI is oldest standard [method] 
        # PHP is more common; install `mod_php`
        # Python is common too; install `mod_wsgi`
        # Databases; natively handles if local; for remote database, 
        #  SELinux booleans required; db dependent, 
        #  e.g., `httpd_can_network_connect_db`, `httpd_can_network_connect`

    #	- SSL/TLS setup [was SSL; now TLS]
        # Protects Websites 
        # - Data encryption 
        # - Identity Verification 
        # Central role for certificates 
        # - Signature guaranteed by a CA
        # Signed (implies by CA), or self-signed (unreliable)
        # - Self-signed is good for testing 
        # - Signed is essential for production  
        
        # SETUP 
            yum install crypto-utils -y 
            yum install mod_ssl -y  # apache plugin 
            genkey  server1.example.com  # CLI / queries
                # => │ You are now generating a new keypair... |
                # Private Key [.key]
                    /etc/pki/tls/private/server1.example.com.key 
                # Certificate [Public] [.crt]
                    /etc/pki/tls/certs/server1.example.com.crt 

                    # COMMON NAME [@query/edit] must match your FQDN (server domain name)

            # SELinux :: check context
            ls -Z /etc/pki/tls/private  
            ls -Z /etc/pki/tls/certs

            # genkey also created  `ssl.conf` @ 
            vim /etc/httpd/conf.d/ssl.conf  
            # which contains all the necessary info
            <VirtualHost *:443>
                ServerName server1.example.com 
                DocumentRoot /web/server1 
                SSLEngine on 
                SSLCertificateFile /etc/pki/tls/certs/serverFQDN.crt
                SSLCertificateKeyFile /etc/pki/tls/private/serverFQDN.key
                ...
            </VirtualHost>

            systemctl restart httpd 

            # access @ localhost  
            firefox https://localhost 
            # => "This connection is untrusted"
            # ... because it is a self-signed certificate 

# Lesson 12 Managing SMB File Sharing
# ===================================
    # SMB/CIFS [Server Message Block / Common Internet File System]
    # Mounting SMB from Windows, Linux or any other server shares;
    smbclient # utility isn't very convenient and not used much 

        # show what shares are offered by SMB server
        smbclient -L //aHOST  # `-L` for show exports; NO PASSWORD NEEDED
            # => 
            #    Enter roots password:        # ... just press ENTER
            #    Server does not support EXTENDED_SECURITY  but...
            #    Anonymous login successful
            #    Domain=[aDOMAIN] OS=[Unix] Server=[Samba 3.6.25]

            #        Sharename       Type      Comment
            #        ---------       ----      -------
            #        TC              Disk      sda1's TC in WD Elements 1023
            #        tc_volume       Disk      sda1's tc_volume in WD Elements 1023
            #        DLNA66          Disk      40GB's DLNA66 in WD Elements 1023
            #        ...
            #    Server does not support EXTENDED_SECURITY  but...
            #    Anonymous login successful
            #    Domain=[aDOMAIN] OS=[Unix] Server=[Samba 3.6.25]
            #
            #        Server               Comment
            #        ---------            -------
            #        aHOST2
            #        aHOST              foo bar

            #        Workgroup            Master
            #        ---------            -------
            #        DOMAIN              aHOST

    # MOUNT; access @ current filesystem; @ `/mnt` folder
    mount -o username=userSMB //aHOST/shareThis /mnt

        # if err, show available helper files
        mount 
        # if no cifs related file, e.g., `mount.cifs`, ...
        yum whatprovides */mount.cifs  
        # => ... `cifs-utils` ...
        yum install cifs-utils -y

    # Create/Config SMB [server] Share
        # Create FS share + grant perms @ Linux
            mkdir /shareThis
            chmod 777 /shareThis/
            useradd sambaUSER
        # Create Share in smb.conf
            yum install -y samba samba-client
            cd /etc/samba
            vim smb.conf
                # => edit ...
                [global] # Samba server config
                workgroup = sambagroupNAME
                # Shared Definitions
                # [public]
                # ...
                [shareThis]
                    comment = my share 
                    path = /shareThis
                    public = yes 
                    # read only = yes
                    writable = yes
                    valid users = @users
                    write list = @users  # OR `+users`

        # Start Samba server
            systemctl start smb nmb  # `nmb` required only for Windows
            systemctl enable smb 
            # verify 
            systemctl status          # view messages
            smbclient -L //localhost  # list available shares
            # Create Samba User
                smbpasswd -a sambaUSER  # only works if corresponding Linux user exists
            # try ...
                mount -o username=sambaUSER //localhost/shareThis /mnt
                cd /mnt 
                ls  # =>  'Permission Denied' !!! So, ...

        # Access Control / Restrictions
            ls -Zd /shareThis/  # info/test SELinux 
            setenforce 0        # ... verify SELinux is the issue 
            cd /mnt 
            ls                  # allowed !!! 
            # So, fix @ smb.conf
                hosts allow = 
            # OR, @ firewalld [but take care the two don't conflict]

# Lesson 14 Managing SSH 
# ====================== 
    # ssh (client;you)         sshd (@ssh server)

    # Authentication 
        ssh-keygen  # creates key pair @ home dir  
            ~/.ssh/id_rsa         # identity; private key; can protect with passphrase
            ~/.sh/id_rsa.pub      # public key  

        ssh-copy-id [user@]hostname  # copy public key 
            # to authorized_keys file @ ssh server  
            ~/.ssh/authorized_keys  
        # Authentication Token is generated upon ssh session login/connect , 
        #  encrypted using your private key, and sent to server; 
        #  if server can decrypt using your public key, then you are authentic[ated].  

        # Automate pass phrase entry ...  
        ssh-agent /bin/bash  # launch ssh-agent into subshell  
        ssh-add              # prompts for pass phrase; caches it until (sub)shell exited  

    # ssh CLIENT options 
    # See REF.Network.utils.sh

    # ssh SERVER options  
    # config sshd @ server  
        /etc/ssh/sshd_config  
        Port 22                    # change this if exposed to internet, e.g., 5177
        ListenAddress 0.0.0.0      # listens to everything; change to specific 
        SyslogFacility AUTHPRIV    # okay
        PasswordAuthentication no  # very secure, but shuts out new ssh clients  
        PermitRootLogin yes        # bad; set to no  
        AllowUsers uzer1 uzer2     # specify; overrules `PermitRootLogin yes`  
        MaxSessions 10             # okay for typical servers  
        GSSAPIAuthentication no    # used only by Kerberos; turn off to speed up auth otherwise 
        X11Forwarding yes          # less secure  
        TCPKeepAlive yes           # prevent termination on inactive session  
        ClientAliveInterval 10     # checks every 10 minutes 

        systemctl restart sshd  # restart after changes 
        status sshd             # validate changes; SELinux may not allow, e.g., port change  
        # if issues ...
        setenforce 0            # turn off SELinux temporarily  
        grep AVC /var/log/audit/audit.log  # show the SELinux messages 
        semanage port -l grep 22    # find the port context  
        man semanage            # shows `semanage port` 
        man semanage port       # shows example "Allow sshd to ..."
        semanage port -a -t ssh_port_t -p tcp 5177  # allow/add ssh @ port 5177

  # SSH TUNNELs :: PORT FORWARDING 
    # local port forwarding; connect unaccessible remote port to accessible local port 
    ssh -fNL 4444:webserver.com:80 user@host2.domain  # from host1, thru host2, to webserver.com
    elinks http://localhost:4444 # webpage from webserver.com, thru host2
    ssh -fNL 4444:localhost:80 user@host2.domain  # from host1, thru/to host2
    elinks http://localhost:4444 # webpage from host2 
    # remote port forwarding; less common; 
    # connect unaccessible local port to an accessible remote port 
    ssh -p 2022 -R 80:localhost:8088 user@host2.domain

  # MONITOR ssh connections (tunnels)
    lsof -i -n | grep ssh       # open files; internet-related (-i) 
    netstat -tulpen | grep ssh  # connections per host:port and process 

