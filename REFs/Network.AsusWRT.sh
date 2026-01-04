# REF.Network.AsusWRT :: GitHub/RMerl/asuswrt-merlin
# @ https://github.com/RMerl/asuswrt-merlin/wiki/User-scripts
[[ "$( type -t openedit )" ]] && openedit "$0" ; exit

# @ Repeater Mode : Administration > Operating Mode > ... set to "Repeater Mode"
    # IP : 192.168.0.193

# WAN : ISP Internet Address @ 73.172.25.116
    ip -4 route
    # 73.172.24.1 dev eth0  proto kernel  scope link
    # 192.168.1.0/24 dev br0  proto kernel  scope link  src 192.168.1.1
    # 73.172.24.0/21 dev eth0  proto kernel  scope link  src 73.172.25.116
    # 127.0.0.0/8 dev lo  scope link
    # default via 73.172.24.1 dev eth0

    ip -r route show dev eth0 #... -r : resolve (DNS)
    # c-73-172-24-1.hsd1.va.comcast.net  proto kernel  scope link
    # 73.172.24.0/21  proto kernel  scope link  src 73.172.25.116
    # default via c-73-172-24-1.hsd1.va.comcast.net

    # Internet IP Address
    ip route show dev eth0 |grep src |awk '{print $7}'

        #... @ client (SSH inline command)
        ssh router "ip -r route show dev eth0" |grep src |awk '{print $7}'

# Entware :: Entware-ng on MIPS devices (RT-N66U, RT-AC66U, RT-N16, e.t.c)
    # tl;dr :: This model, RT-66U, firmware does NOT support Entware PHP pkg, 
    #          so serves only static, and only if explicitly specified, 
    #          URL, e.g., 'http://router.semperlan:81/index.html', not 'http://router.semperlan:81'
    #
    # Entware/Optware  https://github.com/Entware/Entware/wiki 
    # Entware @ AsusWRT-Merlin  https://github.com/RMerl/asuswrt-merlin/wiki/Entware 
    # REQUIREs USB having ext2 FS, e.g., '/dev/sdba1'
    # https://www.tldp.org/HOWTO/Flash-Memory-HOWTO/ext2.html
    # Install @ USB having ext2 FS
    # Create ext2 FS ... (@ 7GB TT USB)
    umount /dev/sda1
    mke2fs /dev/sda1 
    mount /dev/sda1
    # Install Entware by simply runing the script (pre-installed @ AsusWRT-Merlin)
    entware-setup.sh  # installs @ /tmp/mnt/sda1/entware
    # Old way ...
    wget -O - http://pkg.entware.net/binaries/mipsel/installer/installer.sh | sh

    # Usage (Entware/Optware Package Manager)
    opkg update         # Updates Entware/Optware PKG LIST  
    opkg install $PKG
    opkg remove $PKG
    opkg list
    opkg list-installed 
    # findutils - 4.6.0-1
    # ldconfig - 1.0.17-1
    # libc - 1.0.17-1
    # libgcc - 5.4.0-1
    # libssp - 5.4.0-1

    # Lighttpd Web Server  
    # https://github.com/RMerl/asuswrt-merlin/wiki/Lighttpd-web-server-with-PHP-support-through-Entware
    opkg install 'lighttpd' 'lighttpd-mod-fastcgi'  # +'php5-cgi', but pkg install FAILed
    vi '/opt/etc/lighttpd/lighttpd.conf'
        server.port                 = 81
        server.upload-dirs          = ( "/opt/tmp" )

    # web root @ 
    '/opt/share/www'

    # Start server
    /opt/etc/init.d/S80lighttpd start
    # @ browser
    http://router.asus.com:81

    # Remote access to server folder

        # List folder 
        ssh router ls /opt/share/www

        # Upload 
        scp SOURCE router:/opt/share/www/TARGET
        # Upload FOLDER 
        scp -r SOURCE router:/opt/share/www/TARGET

        # SemperNET@SMB:/tmp/mnt/sda1/entware/share/www#

        export _TARGET='/opt/share/www'
        # Upload this folder recursively
        scp -r . router:${_TARGET}/

        ssh router ls -l ${_TARGET}

# Upload per SSH (uses ~/.ssh/config for USER@HOST and key)
scp $_SOURCE_PATH router:/jffs/scripts/$_TARGET_FNAME # to '/jffs/scripts/' folder

# Log :: 'WAN_Connection:'
    cat '/tmp/syslog.log' | grep 'WAN'

# TOOLs
    uname -r  # Linux Kernel (2.6.22.19)
    nvram show # get|set|show ALL nvram settings
    nvram [get name] [set name=value] [unset name] [show] [save file] [restore file] [fb_save file]
    nvram fb_save /tmp/mnt/WinPE/Data/nvram.fb_save.log  # saved 2018-10-27 (restorable)
    nvram commit  # to SURVIVE REBOOT, else changes do not. 

    service NAME  # see example @ VPN start|stop

    3ginfo.sh  # /usr/sbin/3ginfo.sh ; list config etal; from OpenWrt Project (?)

    busybox                 # list all commands 
    busybox COMMAND --help  # help with command

    # Memory (256 MB nvram)
    sysinfo | grep -i mem  # =>
        MemTotal:       239532 kB # incl. new 'hosts' file per Cygwin `hosts` script [~ 1MB]
        MemFree:        152988 kB # 150MB free 
        # 2018-06-10
        MemTotal:       239524 kB
        MemFree:         69136 kB

    # VPN stop|start (off|on) 
    service stop_vpnclient1   # vpn_client1_state=0
    service start_vpnclient1  # vpn_client1_state=2

    # VPN status: vpn_client1_state  off (0) on (1|2)
    nvram show | grep vpn_client1_state | awk -F = '{ print $2}' )
    
    # UPnP :: Verify WAN UPnP is off:
    cat /dev/mtd1 | grep -i upnp | grep -i wan
        #=>
        wan0_upnp_enable=0  # @ primary WAN (so UPnP is OFF)
        wan1_upnp_enable=1  # @ secondary WAN (which is off)
        wan_upnp_enable=0   # temp var used by GUI  

        # turn UPnP off @ 'wan1' anyway
        nvram set wan1_upnp_enable=0 ; nvram commit

    wl  # WiFi utility @ Router firmware
        # List of commands : https://wiki.DD-WRT.com/wiki/index.php/Wl_command
        Usage: /usr/sbin/wl [-a|i <adapter>] [-h] [-d|u|x] <command> [arguments]
            -h [cmd]  command description for cmd
            -a, -i    adapter name or number
            -d        output format signed integer
            -u        output format unsigned integer
            -x        output format hexdecimal

        wl -i eth1|eth2 up|down  # on|off; reset adapter and mark as up|down 
        wl -i eth1|eth2 restart  # restart (must already be down).
        wl -i eth1|eth2 out      # mark adapter down but do not reset hardware. 

        wl -i eth1 radio on|off # 2.4 GHz on|off  
        wl -i eth2 radio on|off # 2.4 GHz on|off 
        wl -i eth1 status
        # After turning radio off, e.g., `wl -i eth2 radio off`, Web UI shows wrong status 
        # @ "Wireless" > "Professional" > "5GHz" > "Enable Radio" > "yes" 
    
        wl -i eth1 bssid         # Adapter MAC (BSSID); must be on.

# JFFS (enabled) :: writable storage that survives reboots ...
    /jffs/scripts
        router.sh*
        ya-malware-block.sh*

    /jffs/configs
        hosts.add

# MAINTENANCE
    # USB-SMB source folder from which file[s] are uploaded to router firmware
    
    #  As seen @ Win7-Cygwin     As seen @ router-SSH shell
         '//SMB/Data/'             '/tmp/mnt/WinPE/Data/'

    router     # maintenance script @ host; 
        ~/.bin/router
    router.sh  # maintenance script @ router; 
        /jffs/scripts/router.sh 

    # Login @ AsusWRT per SSH session
    
        ssh routerUSER@router.LANDOMAIN  
        # or 
        ssh router # per ~/.ssh/config 
    
        # ALL maintenance tasks per menu/select

            /jffs/scripts/router.sh

        # ... OR, sans 'router.sh' script, per commands ...
        
        # 0. UPDATE 'router.sh' 
            cp "/tmp/mnt/WinPE/Data/${0##*/}" "/jffs/scripts/${0##*/}"
        
        # 1. UPDATE 'hosts' [per 'hosts.add' method]
            # `cp` source seen @ Windows Network as '\\SMB\Data\hosts' 
            cp "/tmp/mnt/WinPE/Data/hosts" '/jffs/configs/hosts.add'
            chmod 400 /jffs/configs/*  # make it read-only
            reboot # then login again, after reboot, to validate [see below]

        # 2. VALIDATE 'hosts'
            ssh routerUSER@router.LANDOMAIN # login to router shell per SSH
            cat "/tmp/etc/hosts" | ( head -n 20 ; echo; tail -n 3 )
            
        # 3. MALWARE PROTECTION [script; run, & set per `cru`] [see # 2017-08-29]
            /jffs/scripts/ya-malware-block.sh
            cru a UpdateYAMalwareBlock "0 */6 * * * /jffs/scripts/ya-malware-block.sh"

        # 4. Toggle VPN  (vpn_client1_state)
            service stop_vpnclient1
            service start_vpnclient1

    # How to block scanners, bots, malware, ransomware
        # https://github.com/RMerl/asuswrt-merlin/wiki/How-to-block-scanners,-bots,-malware,-ransomware
        # https://www.snbforums.com/threads/yet-another-malware-block-script-using-ipset-v4-and-v6.38935/
        wget --no-check-certificate -O /jffs/scripts/ya-malware-block.sh https://raw.githubusercontent.com/shounak-de/misc-scripts/master/ya-malware-block.sh
        chmod +x /jffs/scripts/ya-malware-block.sh
        # Run 
        /jffs/scripts/ya-malware-block.sh # works !!!
        # Run per cru [every 6 hrs; does NOT survive reboot]
        cru a UpdateYAMalwareBlock "0 */6 * * * /jffs/scripts/ya-malware-block.sh"
        # `cru` is a Merlin wrapper for `crontab`

    # SNIFF the (Gateway-to-ISP) network; REQUIRES bridge-utils pkg 

        brctl addbr br0             # Add (Create) a bridge 
        brctl addif br0 eth0 eth1   # Bond interfaces to bridge 
     
        #... @ topology:  ISP  ===(eth1)===  PC  ===(eth0)===  Gateway Router

        # Disable multicast snooping:
        echo 0 > /sys/devices/virtual/net/br0/bridge/multicast_snooping
        #... THEN RUN Wireshark @ eth0 or eth1.

        # TR-069 - Protocol used by ISP (ACS) for managing CPE [CWMP] [Wikipedia]
        # REF: https://0x90.psaux.io/2020/03/01/Taking-Back-What-Is-Already-Yours-Router-Wars-Episode-I/ 

# 2017-08-01

    # WiFi BEST/FASTEST Settings [RT-AC66U/Merlin-v380.58] 
    
        7LOL [2.4GHz]: "N Only"; "40 MHz"; Ch "3" 
        
        # Most neighbors @ Ch 6, per Nirsoft > WirelessNetView
                                        
        7LOH [5GHz]  : "N/AC mixed"; "20/40/80"; "Auto" [Ch 149] + "...including band1 ..."
                                     "N/AC mixed"; "80"      ; "Auto" [Ch 149]
         
        # Results @ Edimax-AC1200 [Auto@USB3]

            @ 7LOL [2.4GHz]; "N-Only"; "40"; Ch 3

                "300 Mbps"              @ Windows > WiFi [Adapter] Status
                ~ 100/150 Mbps up/down  @ LAN_SpeedTest.exe

            @ 7LOH [5GHz]; "N/AC mixed"; "80"; "Auto" [Ch 149]

                "876 Mbps"              @ Windows > WiFi [Adapter] Status
                ~ 200/200 Mbps up/down  @ LAN_SpeedTest.exe

            @ GbE [Gb Ethernet] [REFERENCE]

                "1.0 Gbps"              @ Windows > Eth0 [Adapter] Status
                ~ 360/770 Mbps up/down  @ LAN_SpeedTest.exe 

        # Available 5 GHz Channels @ AC66U Merlin 380.58 [2016-03-20

            36/40/44/48/149/153/157/161  
            ALL "control channel" are 20MHz !!! 
            # per https://en.wikipedia.org/wiki/List_of_WLAN_channels#United_States

            # The router offers no 40/80/160 MHz "control channel" @ 5 GHz !!! 
                
# 2017-04-17

    Configured DHCP range: 192.168.1.[200-255]
     
    Manually Assigned IP around the DHCP range
    
        LAN > DHCP Server > ...
        
            MAC                 IP              Hostname
            70:85:C2:3B:C6:54   192.168.1.101   XPC     # Kaby-Lake/H720M-Pro4
            D0:50:99:1C:BC:27   192.168.1.102   HTPC    # Kabini/AM1H-ITX
            
            Note: MAC/IP Binding
                
    # deleted these ...
     ...  192.168.1.103 P5N7A # temp per client-bridge router
     ...  192.168.1.2   CB    # client-bridge router address

    cat /tmp/etc/hosts.dnsmasq # @ ssh session, after web admin 'apply'
        192.168.1.101 XPC
        192.168.1.102 HTPC
             
     
# 2017-01-13 
    updated hosts file, and by overwrite [not append] method.
# 2017-01-05
    custom hosts file by append method. [See below.]

# @ AsusWRT Web Admin UI : Admin > ... enable SSH. Then ...

# SSH to router from Cygwin|GitSDK|MinGW|Linux mintty terminal ...

    # @ Router's Web UI : Administration > System > SSH Daemon
    #                       > SSH Authentication key 
    #                       > cut/paste the PUBLIC KEY file contents in its entirety.

    ssh routerUSER@router.LANDOMAIN  
     OR
    ssh -l routerUSER 192.168.1.1 [or 'router.asus.com'
    
        # names per /tmp/etc/hosts file @ router, and  ~/.ssh/config @ Cygwin
        # case-sensitive per 'Host ...' @  ~/.ssh/config
    
    # key-based [passwordless] authentication
    
        ssh-keygen # used this for router; no passphrase; just press ENTER
        ssh-keygen -t rsa -C "user@host.domain" # used this for GitHub keygen
        
        # '-i' :: identity [private-key] file; default [v.2] is 'id_rsa'
        
            # stores private key [id_rsa] @ Cygwin
                $HOME/.ssh/id_rsa      
            # stores public key [id_rsa.pub] @ Cygwin
                $HOME/.ssh/id_rsa.pub

                # renamed [See config]: 
                    ~/.ssh/AC66U_rsa
                    ~/.ssh/AC66U_rsa.pub
                
        # send public key to router ...
        ssh-copy-id routerUSER@router.LANDOMAIN 
            # authorized_keys @ '/root/.ssh' [SYMLINK]
            /tmp/home/root/.ssh/authorized_keys 
    
        # Connect 
        ssh routerUSER@router.LANDOMAIN
        
        #=> ASUSWRT-Merlin RT-AC66U_3.0.0.4 Sun Mar 20 19:52:51 UTC 2016
        #=> routerUSER@SMB:/tmp/home/root#

        # @ first connect to unknown host, shows fingerprint, NOT of key, but of 'known_hosts' file
        #=> ECDSA key fingerprint is SHA256:EStAlicb9xr86NmhW5xzMlCNAZc4vEtzEgZFW8pFr+I
                
        # Fingerprint of public/private ssh key [public/private are same] 
        ssh-keygen -lf  FILE_PATH         # SHA256; '-B' for readable blather; '-v' for visual
        ssh-keygen -E md5 -lf FILE_PATH   # md5
        ssh-keygen -t ecdsa -lf FILE_PATH # specify key type ecdsa = elip-rsa

        '/c/Cygwin/home/USERNAME/.ssh/id_rsa'
        2048 SHA256:ge2ZxRrTXqIoex0debUVAyev+Uj8621mRBnTni5Z8NQ Uzer@gmail.com (RSA)
        2048 MD5:f4:6a:51:86:5b:62:63:ac:87:20:6e:e8:dd:32:66:4c Uzer@gmail.com (RSA)

# command prompt @ router session ...

    routerUSER@SMB:/tmp/home/root#
    
# list of commands [busybox; dropbear; ... wget, ...]
    /usr/bin 
    usr/sbin
    
# list //SMB mount points ...
    
    # ls -lh /tmp/mnt
    
        drwxrwxrwx    1 UzerNE root  4.0K Jan 13 13:47 40GB
        drwxrwxrwx    1 UzerNE root  4.0K Aug 27  2015 WD_Elements
        drwxrwxrwx    1 UzerNE root  8.0K Aug 26  2015 WinPE
            
    # mappings :: shell-path-@-AsusWRT => Domain-Name
    
        /tmp/mnt/40GB/WDE_40GB      => //SMB/wde_40gb
        /tmp/mnt/WinPE/Data         => //SMB/Data
        /tmp/mnt/WinPE/cmd_library  => //SMB/cmd_library

# HOW TO customize router's config files; e.g., the 'hosts' file ...
# https://github.com/RMerl/asuswrt-merlin/wiki/Custom-config-files

    # AsusWRT auto-generates ... on boot 
    
    cat /tmp/etc/hosts | ( head -n 6 ; echo ; tail -n 6 ) # @ unmodified ...
    
        127.0.0.1 localhost.localdomain localhost 
        192.168.1.1 router.asus.com
        192.168.1.1 www.asusnetwork.net
        192.168.1.1 www.asusrouter.com
        192.168.1.1 SMB.LANDOMAIN SMB
        
    cat /tmp/etc/hosts.dnsmasq
    # per Web Admin ... 'LAN' > 'DHCP Server' > 'Manually Assigned ...'
    #  IPs must be assigned OUTSIDE the range of DHCP hosts [clients]; 
    #  currently set DHCP hosts range is '192.168.1.200' ... 255 

        192.168.1.101 XPC
        192.168.1.102 HTPC
                
    cat /tmp/etc/dnsmasq.conf
    
        pid-file=/var/run/dnsmasq.pid
        user=nobody
        bind-dynamic
        interface=br0
        interface=ppp1*
        no-dhcp-interface=ppp1*
        resolv-file=/tmp/resolv.conf  # DNS servers
        servers-file=/tmp/resolv.dnsmasq
        no-poll
        no-negcache
        cache-size=1500
        min-port=4096
        
    cat /tmp/resolv.conf 
    # @ CloudFlare 
        nameserver 1.1.1.1
        nameserver 1.0.0.1
    # @ OpenDNS 
        nameserver 208.67.222.222
        nameserver 208.67.220.220
        
    # METHODs ...
    
        # Write to 
        /jffs/configs/hosts.add
        # then reboot ...
        
        # APPEND [hosts.add] method...
                
                # copy hosts
                cat /tmp/mnt/WinPE/Data/hosts > /jffs/configs/hosts.add
                # validate
                cat /tmp/etc/hosts | ( head -n 20 ; echo ; tail -n 3 )

        # OVERWRITE [hosts] method ...

                cat /tmp/mnt/WinPE/Data/hosts > /jffs/configs/hosts
                
        # Either way, `chmod` to read-only [for security]
                
                chmod 400 /jffs/configs/*
            
        # VALIDATE ...

            cat "/tmp/etc/hosts" | ( head -n 20 ; echo; tail -n 3 )
            # => 
                127.0.0.1 localhost.localdomain localhost
                192.168.1.1 router.asus.com
                192.168.1.1 www.asusnetwork.net
                192.168.1.1 www.asusrouter.com
                192.168.1.1 SMB.LANDOMAIN SMB
                # ===  START scripted LAN entries  ===
                192.168.1.1 AsusWRT.LANDOMAIN router.LANDOMAIN AC66U.LANDOMAIN
                192.168.1.102 linux.LANDOMAIN CentOS.LANDOMAIN RHEL.LANDOMAIN
                # ===  START curated redirects  ======
                0.0.0.0 lb.usemaxserver.de
                0.0.0.0 tracking.klickthru.com
                0.0.0.0 gsmtop.net
                ...
                0.0.0.0 zintext.com
                0.0.0.0 zmedia.com
                0.0.0.0 zv1.november-lax.com

# Env. Vars @ ssh logon ...

# routerUSER@SMB:/tmp/home/root#

@ set 
    LOGNAME='routerUSER'
    OLDPWD='/tmp/home/root'
    PATH='/bin:/usr/bin:/sbin:/usr/sbin:/home/routerUSER:/mmc/sbin:/mmc/bin:/mmc/usr/sbin:/mmc/usr/bin:/opt/sbin:/opt/bin:/opt/usr/sbin:/opt/usr/bin'
    PPID='2474'
    PS1='\u@\h:\w\$ '
    PS2='> '
    PS4='+ '
    PWD='/etc'
    SHELL='/bin/sh'
    SSH_CLIENT='192.168.1.101 61415 22'
    SSH_CONNECTION='192.168.1.101 61415 192.168.1.1 22'
    SSH_TTY='/dev/pts/0'
    TERM='xterm'
    USER='routerUSER'
    
@ /tmp/etc/smb.conf ... an entry ...
    # [WDE_40GB]
    # comment = 40GB's WDE_40GB in WD Elements 1023
    # path = /tmp/mnt/40GB/WDE_40GB
    # dos filetimes = yes
    # fake directory create times = yes
    # valid users = routerUSER
    # invalid users =
    # read list = routerUSER
    # write list = routerUSER
    
# OpenVPN CLIENT SETTINGS @ AsusWRT-Merlin, for PIA.com
    # OpenVPN installed @ Windows (for REFERENCE)
    # C:\Program Files\OpenVPN\bin
    openvpn.exe --version  # 2.4.4 ...  Sep 26 2017
    openvpn.exe --help     # list options

#Basic Settings

Start with WAN: Yes
Interface Type: TUN
Protocol: UDP
Server Address and Port: # Auto-sets per uploaded .opvn file; 
# Make ADDRESS BLANK; set port to 1198; use custom multiple remote/random addresses
Firewall: Auto
Authorization Mode: TLS # Click "Content modification of Keys & Certificates" to add the CA
Username/Password Authentication: Yes
Username: your user
Password: your pass
Username / Password Auth. Only: No
TLS control channel security (tls-auth / tls-crypt): Disabled
Auth digest: SHA 1
Create NAT on tunnel: Yes

#Advanced Settings

Global Log verbosity: 1
Poll Interval: 0
Accept DNS Configuration: Strict
Cipher Negotiation: Enable with fallback
Negotiable ciphers: AES-128-CBC:AES-256-CBC
Legacy/fallback cipher: AES-128-CBC
Compression: LZO Adaptive
TLS Renegotiation Time: -1
Connection Retry: -1 # 0 is the default at Asuswrt-Merlin
Verify Server Certificate: No
Redirect Internet traffic: No  # Select "Policy Rules" to specify which devices connect via VPN
Block routed clients if tunnel goes down: Yes

#Custom Configuration

remote us-newyorkcity.privateinternetaccess.com 1198
remote us-midwest.privateinternetaccess.com 1198
remote us-east.privateinternetaccess.com 1198
remote us-florida.privateinternetaccess.com 1198
remote us-texas.privateinternetaccess.com 1198
remote us-chicago.privateinternetaccess.com 1198
remote-random
nobind
persist-key
persist-tun
pull-filter ignore "auth token" # accept|ignore|reject t; filter each option received from the server if it starts with the text t; may be specified multiple times, and each filter is applied in the order of appearance.

# REFs
# OpenVPN.net  https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html
# PIA.com     https://www.privateinternetaccess.com/helpdesk/guides/routers/merlin/merlin-firmware-openvpn-setup


# others ...
cipher AES-128-CBC  
auth sha1    
tls-client             # Enable TLS and assume client role during TLS handshake. 
remote-cert-tls server # client|server; require that peer certificate was signed with explicit key usage 
reneg-sec 0            # Renegotiate data channel key after n seconds
disable-occ            # disable warnings on option inconsistencies between peers
persist-key           # Don't re-read key files across SIGUSR1
persist-tun           # Don't close and reopen TUN/TAP device or run up/down scripts across SIGUSR1
nobind                # Do not bind to local address and port; allocate a dynamic port for returning packets; only suitable for peers using the --remote option. 





