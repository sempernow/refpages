exit
# FIREWALL : firewalld, nftables/iptables
    # RHEL : Getting Started with nftables : https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/getting-started-with-nftables_configuring-and-managing-networking#doc-wrapper
    # - firewalld : Use for simple firewall use cases. 
    # - nftables  : Use to set up complex and performance-critical firewalls, such as for a whole network.
    # - iptables  : RHEL's uses the nf_tables kernel API instead of the legacy back end. 
    #               The nf_tables API provides backward compatibility; scripts of iptables commands still work on RHEL. 
    #               For new firewall scripts, Red Hat recommends using nftables
    # 
    # firewalld @ K8s : https://chatgpt.com/c/d3822fbe-5c9d-4ec4-8844-964294985bb5
all-policies
    # firewall-cmd is the CLI for firewalld.service,
    # which is a systemd service and interface wrapping iptables/nftables 
        systemctl status firewalld.service 
 
    # Show/Verify ALL settings of a zone
        z=k8s
        firewall-cmd --zone=$z --list-all       # This does *not* list allowed port(s) of any *service*
        firewall-cmd --direct --get-all-rules   # Direct Rules cannot be scoped to zone or service
        # Ports and such of all services of declared zone, listed by service.
        printf "%s\n" $(sudo firewall-cmd --list-services --zone=$z) \
            |xargs -I{} sudo firewall-cmd --info-service={}

    # GET
        # A zone is ACTIVE IF BOUND TO an INTERFACE (network device)
        # Zone's default behavior is revealed by: "target: ACCEPT|DROP|REJECT"
        firewall-cmd --get-zones
        firewall-cmd --get-default-zone    # Get DEFAULT zone
        firewall-cmd --get-active-zone     # Get ACTIVE zone and its affected interface(s)
        firewall-cmd --get-zone-of-interface=$dev # Get zone bound to $dev (e.g., device=ens192)

        firewall-cmd --list-all                 # List ports and services of ACTIVE zone
        firewall-cmd --list-ports               # Lists ONLY those NOT of a service
        firewall-cmd --list-services            # ACTIVE services of ACTIVE zone
        firewall-cmd --list-services --zone=$z  # ACTIVE services of DECLARED zone
        firewall-cmd --get-services             # All services (defined/available)
        firewall-cmd --list-interfaces          # All interfaces bound to the ACTIVE zone
        firewall-cmd --list-rich-rules
        firewall-cmd --list-all-policies
        firewall-cmd --direct --get-all-rules
        firewall-cmd --direct --get-rules  # Only those added using --add-rule 
        firewall-cmd --info-zone=$z        # Get zone INFO
        firewall-cmd --info-service=$svc   # Get service INFO; incl. allowed port(s)/proto(s)
        firewall-cmd --info-policy=$policy # Get policy INFO

    # SET
        # Set default zone (don't)
            firewall-cmd --set-default-zone    

        # Add new zone 
            firewall-cmd --permanent --new-zone=$z

        # BIND interface to a zone (regardless of current binding)
            firewall-cmd --permanent --change-interface=$dev --zone=$z
            #... if device was bound to another zone, that would be the equivalent of:
            firewall-cmd --permanent --remove-interface=$dev --zone=$old
            firewall-cmd --permanent --add-interface=$dev --zone=$new
            #... if "interface is under the control of NetworkManager", then MUST:
            nmcli connection modify "$dev" connection.zone $z
            nmcli connection down "$dev" # Then toggle the device for mod to take effect;
            nmcli connection up "$dev"   # preferable to : systemctl restart NetworkManager
            #... else firewall-cmd may report false positive "success",
            #... yet device silently removed and returned to $old zone by NetworkManager:
            firewall-cmd --get-zone-of-interface=$dev
            nmcli connection show $dev |grep connection.zone

            # Bind multiple interfaces to a zone
            # E.g., K8s CNI providers create virtual interfaces *dynamically*, one per Pod.
            # See https://chatgpt.com/share/7c5d78ff-8305-4051-9209-5bc39d4900cd
            firewall-cmd --permanent --zone=k8s --add-interface=cni+ 
            firewall-cmd --permanent --zone=k8s --add-interface=veth+
            #... else by Direct Rule (See section on that)

        # Add/Remove rule
            # Add port (bare)
            firewall-cmd --permanent --add-port=10255/tcp 
            # Remove same 
            firewall-cmd --permanent --remove-port=10255/tcp 
            # Add service to zone 
            firewall-cmd --permanent --zone=public --add-service=http
            firewall-cmd --permanent --zone=public --add-service=https

        # Create (define) service (having ports) 
            svc=istiod
            firewall-cmd --permanent --new-service=$svc
            firewall-cmd --permanent --service=$svc --set-description="Istio control plane"
            # Add port(s) to service 
            firewall-cmd --permanent --service=$svc --add-port=15010/tcp 
            firewall-cmd --permanent --service=$svc --add-port=15014/tcp 
            #...
        # Add/Remove service to currently-active zone
            firewall-cmd --permanent --add-service=$svc
            firewall-cmd --permanent --remove-service=$svc
            #... same, but declare its zone 
            firewall-cmd --permanent --zone=$z ...

        # Sources : default behavior for the zone applies to all traffic lest sources declared
            # Add source : simple
            firewall-cmd --zone=$z --add-source=$ip_or_cidr
            # Add source : granular
            firewall-cmd --zone=$z --add-rich-rule='rule family="ipv4" source address="'$cidr'" service name="'$svc'" accept'

        # Add/Remove RICH RULE to a zone (cannot be scoped to service)
            ## See `man firewalld.richlanguage` for rule syntax
            ## Allow traffic from VIP address by IPv4
            at="--permanent --zone=$z"
            do='add' # add|remove
            firewall-cmd $at --$do-rich-rule='rule family="ipv4" source address="'$vip'" accept'

            ## Allow service (ssh) traffic only if source is of the declared CIDR
            firewall-cmd $at --$do-rich-rule='rule family="ipv4" service name="ssh" reject'
            firewall-cmd $at --$do-rich-rule='rule family="ipv4" source address="'$cidr'" service name="ssh" accept'

            # DROP|REJECT traffic from CIDR address by IPv4, and LOG whenever traffic is affected
            firewall-cmd $at --add-rich-rule='rule family="ipv4" source address="'$cidr'" log prefix="DROP: " level="info" drop'
            firewall-cmd $at --add-rich-rule='rule family="ipv4" source address="'$cidr'" log prefix="REJECT: " level="info" reject'
                # - Use DROP to minimize network/rule visibility or to handle higher volume of unwanted traffic.
                # - Use REJECT to inform sender immediately that their traffic is not allowed, 
                #   improving the user experience for legitimate users or systems.
                # Same, using iptables
                ## DROP + LOG
                sudo iptables -A INPUT -s $cidr -j LOG --log-prefix "IPTABLES DROP: " --log-level 4 #  info (4) and warning (5)
                sudo iptables -A INPUT -s $cidr -j DROP
                ## REJECT + LOG
                sudo iptables -A INPUT -s $cidr -j LOG --log-prefix "IPTABLES REJECT: " --log-level 4
                sudo iptables -A INPUT -s $cidr -j REJECT

                # View/Tail logs
                    sudo journalctl -f
                    # else
                    sudo tail -f /var/log/messages

        # Add/Remove DIRECT RULE interface (cannot be scoped to service or zone)
            at="--permanent --direct"
            do='add' # add|remove
            firewall-cmd $at --$do-rule ipv4 filter IN_public_allow 0 -m tcp -p tcp --dport 777 -j ACCEPT
            # K8s CNI providers create virtual interfaces *dynamically*, one per Pod.
            # Either bind interfaces to zone (see above), or directly allow traffic across interfaces, as here.
            # Allow all IPv4 traffic across all interfaces having pattern cni* or veth* .
            # See https://chatgpt.com/share/7c5d78ff-8305-4051-9209-5bc39d4900cd
                firewall-cmd $at --$do-rule ipv4 filter FORWARD 0 -o cni+ -j ACCEPT
                firewall-cmd $at --$do-rule ipv4 filter INPUT 0 -i cni+ -j ACCEPT
                firewall-cmd $at --$do-rule ipv4 filter FORWARD 0 -o veth+ -j ACCEPT
                firewall-cmd $at --$do-rule ipv4 filter INPUT 0 -i veth+ -j ACCEPT
            # Restrict to podCIDR src/dst
                # Allow Pod CIDR traffic on CNI interfaces
                firewall-cmd $at --$do-rule ipv4 filter FORWARD 0 -s $podCIDR -o cni+ -j ACCEPT
                firewall-cmd $at --$do-rule ipv4 filter FORWARD 0 -d $podCIDR -i cni+ -j ACCEPT
                # Allow cross-node Pod CIDR traffic on main network interfaces
                firewall-cmd $at --$do-rule ipv4 filter FORWARD 0 -s $podCIDR -o eth+ -j ACCEPT
                firewall-cmd $at --$do-rule ipv4 filter FORWARD 0 -d $podCIDR -i eth+ -j ACCEPT
                # -s <Pod_CIDR>: Specifies the source IP range (Pod CIDR) for outgoing traffic.
                # -d <Pod_CIDR>: Specifies the destination IP range (Pod CIDR) for incoming traffic.
                # -o cni+: Matches outgoing traffic on interfaces created by the CNI (such as cni0, cni1, etc.).
                # -i cni+: Matches incoming traffic on interfaces created by the CNI.
                # -j ACCEPT: Accepts the traffic that matches these rules.

        # Masquerade : a type of NAT : Useful for comms between Pods and services external to cluster 
            # REF: https://chatgpt.com/share/d0117056-05f9-40d3-a359-13233dd5697f
            # Add 
            firewall-cmd --permanent --zone=$z --add-masquerade
            # Verify
            firewall-cmd --zone=$z --query-masquerade
        
    # UPDATE active rules (without restarting firewalld.service)
        firewall-cmd --reload              

    # Service descriptions:
        ## Custom services
        /etc/firewalld/services/        # *.xml
        ## Predefined services
        /usr/lib/firewalld/services/    # *.xml 
        #$ cat /usr/lib/firewalld/services/http.xml
        #  <?xml version="1.0" encoding="utf-8"?>
        #  <service>
        #    <short>WWW (HTTP)</short>
        #    <description>HTTP is the protocol used to serve Web pages. ...</description>
        #    <port protocol="tcp" port="80"/>
        #  </service>

    # Policy targets:
        ACCEPT      # Stops processing and allows the traffic.
        DROP        # Stops processing and silently drops the traffic.
        REJECT      # Stops processing and rejects the traffic, often sending an error response back.
        CONTINUE    # Does not stop processing; continues to the next rule or policy.

            sudo firewall-cmd --list-all 
            ...
            target: default # This policy (default) is implicit (not listed); 
            # its target is CONTINUE *unless* modified by related processes, 
            # e.g., NetworkManager, nftables, iptables (depricated).

    # NetworkManager CLI 
        nmcli # firewalld works with or conflicts with NetworkManager
        # Writes to NetworkManager service
        systemctl status NetworkManager
        # CLI : nmcli, nm-tool
        # GUI : right-click on network icon for menu ...
        # See "REF.RHEL.RHCE.sh" 

        nmcli dev status         # List devices (interfaces) + info
        nmcli dev show $dev      # Network + Interface info
        nmcli con show $dev  # Network + Interface info

        # Get zone to which interface AKA device AKA connection is bound:
        firewall-cmd --get-zone-of-interface=$dev
        nmcli con show $dev |grep connection.zone

        # Change firewalld zone to which interface (device) is bound
            firewall-cmd --zone=$z --change-interface=$dev --permanent
            firewall-cmd --reload
            #... if "Warning ... controlled by NetworkManager", then ...
            nmcli con modify "$dev" connection.zone $z

        nmcli -f NAME,DEVICE,TYPE,UUID con show # =>
            NAME    DEVICE  TYPE            UUID
            LAN     enp1s0  802-3-ethernet  b9033960-b5c6-3f...

        nmcli dev wifi            # Show available WiFi networks; channel/strength/...
        nmcli -f ALL dev wifi     # Show available WiFi per SSID/BSSID/freq/...
        nmcli -m multiline -f ALL dev wifi  # @ multi-line view
        nmcli dev wifi rescan     # rescan 

        nmcli con show                  # show connections; NAME UUID TYPE DEVICE 
        # Toggle device : preferable to systemctl restart NetworkManager
        nmcli con down $dev             # disable connection
        nmcli con up   $dev             # enable connection
        nmcli general # =>
            STATE      CONNECTIVITY  WIFI-HW  WIFI     WWAN-HW  WWAN
            connected  full          enabled  enabled  enabled  enabled

        # E.g., set permanent IP
        nmcli con mod "Ifupdown"
            ipv4.addresses "HOST_IP_ADDRESS"
            ipv4.gateway "IP_GATEWAY"
            ipv4.dns "DNS_SERVER(S)"
            ipv4.dns-search "DOMAIN_NAME"
            ipv4.method "manual"

        # RedHat 6 
        service network status|stop|start|restart

        # ... changes stored @ ...

    nftables # nft is the CLI for nftables : successor to iptables, ip6tables, arptables, and ebtables
        nft list ruleset # firewalld is wrapper for nftables / iptables

    iptables  # IP Tables; tool for PACKET FILTERING and NAT [IPv4/IPv6] 
        #  Powerful, low-level FIREWALL implemented as Netfilter modules 
        # - listing contents of the PACKET FILTER RULESET
        # - adding/removing/modifying rules in PACKET FILTER RULESET
        # - listing/zeroing per-rule counters of PACKET FILTER RULESET
        # http://www.netfilter.org/ 
        # https://wiki.centos.org/HowTos/Network/IPTables
        # https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules 

        # list rule(s); output looks just like the commands that were used to create them 
            iptables -S        # List Rules by Specification
            iptables -S TCP    # List Rules of a Specific Chain [TCP]
            iptables -L        # List Rules as Tables
            iptables -L INPUT  # List Input Chain Rule Table 
            # Listen on port 22
            iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

        # Commands to view ALL iptables rules
        # https://jvns.ca/blog/2017/06/07/iptables-basics/ [Julia Evans]
            iptables -L            # lists the filter table; implicit `-t` here
            iptables -L -t nat
            iptables -L -t mangle
            iptables -L -t raw 

        # Save/Restore scripts :
            /etc/network/if-pre-up.d/
            /etc/network/if-post-down.d/

    # http://www.netfilter.org/projects/nftables/index.html

    ufw  # Uncomplicated Firewall  https://help.ubuntu.com/community/UFW
        ufw enable|disble|status 
        # BLOCK intruder per IP Address; e.g., some local [LAN] intruder here ...
            ufw block proto tcp from 192.168.8.345  
        # deny ... 
            ufw deny 53/udp  # deny UDP packets on port 53 
            ufw deny ssh     # deny all SSH connections
