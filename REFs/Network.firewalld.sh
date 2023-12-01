exit
# FIREWALL : firewalld, nftables/iptables
    # RHEL : Getting Started with nftables : https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/getting-started-with-nftables_configuring-and-managing-networking#doc-wrapper
    # - firewalld : Use for simple firewall use cases. 
    # - nftables  : Use to set up complex and performance-critical firewalls, such as for a whole network.
    # - iptables  : RHEL's uses the nf_tables kernel API instead of the legacy back end. 
    #               The nf_tables API provides backward compatibility; scripts of iptables commands still work on RHEL. 
    #               For new firewall scripts, Red Hat recommends using nftables

    # firewall-cmd is the CLI for firewalld.service : systemd service and interface wrapping iptables/nftables 
    systemctl status firewalld.service 
    
    sudo firewall-cmd ... # CLI for firewalld
    sudo firewall-cmd --list-all 
    sudo firewall-cmd --list-ports          # Lists ONLY those NOT of a service
    sudo firewall-cmd --list-services       # ACTIVE services of CURRENT zone
    sudo firewall-cmd --list-services --zone=$name # ACTIVE services of zone $name
    sudo firewall-cmd --get-services        # All services (defined/available)
    sudo firewall-cmd --list-interfaces
    sudo firewall-cmd --list-rich-rules
    sudo firewall-cmd --get-zones
    sudo firewall-cmd --get-default-zone    # Get DEFAULT zone
    sudo firewall-cmd --set-default-zone    # Set DEFAULT zone
    sudo firewall-cmd --get-active-zone     # Get ACTIVE zone and its affected interface(s)
    sudo firewall-cmd --get-zone-of-interface=$device    # Get zone bound to $device (e.g., device=ens192)

    sudo firewall-cmd --info-zone=$name     # Get zone INFO
    sudo firewall-cmd --info-service=$name  # Get service INFO; incl. allowed port(s)/proto(s)
    sudo firewall-cmd --info-policy=$name   # Get policy INFO

    sudo firewall-cmd --reload              # Update the active rules (sans systemctl)

    # Show/Verify settings 
        zone=public
        svc=halb
        sudo firewall-cmd --zone=$zone --list-all
        sudo firewall-cmd --direct --get-all-rules
        sudo firewall-cmd --info-service=$svc

    # Add/Remove rule
        # Add port (bare)
        sudo firewall-cmd --permanent --add-port=10255/tcp 
        # Remove same 
        sudo firewall-cmd --permanent --remove-port=10255/tcp 
        # Add service to zone 
        sudo firewall-cmd --permanent --zone=public --add-service=http
        sudo firewall-cmd --permanent --zone=public --add-service=https
    # Create (define) service (having ports) 
        svc=istiod
        sudo firewall-cmd --permanent --new-service=$svc
        sudo firewall-cmd --permanent --service=$svc --set-description="Istio control plane"
        # Add port(s) to service 
        sudo firewall-cmd --permanent --service=$svc --add-port=15010/tcp 
        sudo firewall-cmd --permanent --service=$svc --add-port=15014/tcp 
        #...
    # Add/Remove service to currently-active zone
        sudo firewall-cmd --permanent --add-service=$svc
        sudo firewall-cmd --permanent --remove-service=$svc
        #... same, but declare its zone 
        sudo firewall-cmd --permanent --zone=$zone_name ...

    # Sources : default behavior for the zone applies to all traffic lest sources declared
        # Add source : simple
        firewall-cmd --zone=$zone --add-source=$ip_or_cidr
        # Add source : granular
        firewall-cmd --zone=$zone --add-rich-rule='rule family="ipv4" source address="'$cidr'" service name="'$svc'" accept'

    # Add/Remove RICH RULE to a zone (cannot be scoped to service)
        ## See `man firewalld.richlanguage` for rule syntax
        ## Allow traffic to/from VIP address by IPv4
        at="--permanent --zone=$zone"
        do='add' # add || remove
        sudo firewall-cmd $at --$do-rich-rule='rule family="ipv4" source address="'$vip'" accept'

    # Add/Remove DIRECT RULE (cannot be scoped to service)

    # Masquerade : a type of NAT : Useful for comms between Pods and services external to cluster 
        # REF: https://chatgpt.com/share/d0117056-05f9-40d3-a359-13233dd5697f
        # Add 
        firewall-cmd --permanent --zone=$zone --add-masquerade
        # Verify
        firewall-cmd --zone=$zone --query-masquerade

    # Default zone behavior is revealed by target: ACCEPT DROP REJECT
    # Service descriptions:
        ## Custom services
        /etc/firewalld/services/        # *.xml
        ## Predefined services
        /usr/lib/firewalld/services/    # *.xml 
        #$ sudo cat /usr/lib/firewalld/services/http.xml
        #  <?xml version="1.0" encoding="utf-8"?>
        #  <service>
        #    <short>WWW (HTTP)</short>
        #    <description>HTTP is the protocol used to serve Web pages. ...</description>
        #    <port protocol="tcp" port="80"/>
        #  </service>

    nftables # nft is the CLI for nftables : successor to iptables, ip6tables, arptables, and ebtables
        sudo nft list ruleset # firewalld is wrapper for nftables / iptables

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
            sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

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
