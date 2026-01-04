exit
# FIREWALL : firewalld, nftables/iptables, NetworkManager (nmcli)
# RHEL : Getting Started with nftables : https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/getting-started-with-nftables_configuring-and-managing-networking#doc-wrapper
# Red Hat recommends:
# - firewalld : Use for simple firewall use cases. 
# - nftables  : Use to set up complex and performance-critical firewalls, such as for a whole network.
#               nftrace, nft
# - iptables  : RHEL's uses the nf_tables kernel API instead of the legacy back end. 
#               The nf_tables API provides backward compatibility; 
#               scripts of iptables commands still work on RHEL. 
# 
    # INSPECT ALL network settings that may affect traffic

        # firewalld : Works with/against NetworkManager
        sudo systemctl enable --now firewalld.service
        dev="$(command ip -4 -brief link |grep -v 'lo ' |cut -d' ' -f1 |head -n1)"
        z=$(sudo firewall-cmd --get-zone-of-interface=$dev)
        sudo firewall-cmd --list-all --zone=$zone # Does *not* include service ports, direct rules, …
        # NetworkManager
        nmcli dev status
        nmcli dev show $dev
        nmcli con show $dev
        # iptables 
        sudo ip6tables -L -v -n
        sudo iptables -L -v -n
        # nftables : Successor to iptables 
        sudo systemctl enable --now nftables.service
        systemctl status nftables
        sudo nft list ruleset
        sudo nft list tables

    firewalld.service # firewalld @ K8s : https://chatgpt.com/c/d3822fbe-5c9d-4ec4-8844-964294985bb5 
        systemctl enable --now firewalld.service  
        systemctl status firewalld.service  
    
    firewall-cmd # CLI for firewalld.service

        # Policy TARGETs:
            #################################################################################################
            # The DEFAULT BEHAVIOR of the Linux firewall is to 
            # DENY all INCOMING traffic and ALLOW all OUTGOING traffic.
            #
            # - To override that default behavior, declare rule(s) using firewall-cmd.
            # - A rule typically affects INCOMING traffic unless its param(s) indicate otherwise.
            # - Underlying processes may (dynamically) override/reset firewalld behavior, per configuration.
            #   See iptables, nftables (successor to iptables), and/or NetworkManager (nmcli).
            #   NetworkManager (nmcli) wins/overrules ALL CONFICTS against firewalld (firewall-cmd).
            #################################################################################################
            default     # Process by rules of THIS ZONE ONLY, then by firewalld's default behavior. (See above.)
            CONTINUE    # Continue processing by rules of OTHER ZONEs (order by zone priority) 
                        # after processing rules of this zone, then by firewalld's default behavior.
            ACCEPT      # Blacklist : Allow all (incoming/outgoing) traffic NOT EXPLICITLY DENIED.
            DROP        # Whitelist : Deny all INCOMING traffic NOT EXPLICITLY ALLOWED; source is not notified.
            REJECT      # Whitelist : Deny all INCOMING traffic NOT EXPLICITLY ALLOWED; source is notified.

            sudo firewall-cmd --list-all 

        # List ALL settings of a zone
            zone=k8s
            # A zone is ACTIVE if it is assigned (bound) to any network INTERFACE
            # A zone may be bound (assigned) to MANY INTERFACES
            # target: <TARGET> : Zone parameter declaring its BEHAVIOR : "target: default|CONTINUE|ACCEPT|DROP|REJECT".
            firewall-cmd --zone=$zone --list-all    # Service ports and such are *not* listed here
            firewall-cmd --direct --get-all-rules   # Direct Rules are *not* scoped to zone or service
            # List all ports and such for EVERY SERVICE of declared zone.
            printf "%s\n" $(sudo firewall-cmd --list-services --zone=$zone) |
                xargs -I{} sudo firewall-cmd --info-service={}

        # GET : get|list|info|query
            firewall-cmd --list-all                 # List ONLY that which is NOT OF any service (of default zone unless declared).
            firewall-cmd --list-ports               # Ports *not* of a service, of default zone

            firewall-cmd --list-services            # ACTIVE services of default zone
            firewall-cmd --list-services --zone=$zone  # ACTIVE services of DECLARED zone
            firewall-cmd --get-services             # All services (defined/available)

            firewall-cmd --list-interfaces          # All interfaces bound to default zone
            firewall-cmd --list-rich-rules
            firewall-cmd --list-protocols           # All of zone : See /etc/protocols for all available 
            firewall-cmd --list-all-policies

            firewall-cmd --direct --get-all-rules   # All Direct Rule(s)
            firewall-cmd --direct --get-rules       # Only those added using --add-rule 
            
            firewall-cmd --query-masquerade --zone=$zone   # Get masquerade (SNAT) setting of a zone

            firewall-cmd --info-service=$svc            
            firewall-cmd --info-policy=$policy 
            firewall-cmd --info-zone=$zone                 
            
            firewall-cmd --get-zones           # Get all zones
            firewall-cmd --get-default-zone    # Get DEFAULT zone
            firewall-cmd --get-active-zone     # Get ACTIVE zone and its bound interface(s)
            firewall-cmd --get-zone-of-interface=$ifc # Get zone bound to an interface
 
        # SET : set|add|remove|change

            # Set default zone : use if all unconfigured interfaces are virtual 
                firewall-cmd --set-default-zone=trusted
            
            # Set all interfaces of a CIDR to a zone 
                firewall-cmd --zone=trusted --add-source=$podCIDR --permanent
                firewall-cmd --zone=trusted --add-source=$svcCIDR --permanent 

            # Add new zone 
                firewall-cmd --new-zone=$zone --permanent
            
            # Log all DROPped (or otherwise denied) packets across ALL ZONES.
                sudo firewall-cmd --set-log-denied=all --permanent # Applies to all zones
                sudo firewall-cmd --reload
                sudo firewall-cmd --set-log-denied=off --permanent # Turn it off
    
            # BIND (change) zone to interface UNLESS CONFLICT w/ NetworkManager
                firewall-cmd --change-interface=$ifc --zone=$zone --permanent
                firewall-cmd --reload
                #… is the equivalent of:
                firewall-cmd --remove-interface=$ifc --zone=$old --permanent
                firewall-cmd --add-interface=$ifc --zone=$new --permanent

                # IF interface is MANAGED BY NetworkManager, 
                # "Warning … controlled by NetworkManager",
                # THEN must synchronize the two configs (firewalld v. NetworkManager):
                # DECONFLICT NetworkManager INTERFERENCE with firewalld:
                    nmcli con modify "$ifc" connection.zone $zone
                    nmcli con down "$ifc" # Toggle the interface to apply the change;
                    nmcli con up "$ifc"   # toggle is preferable to `systemctl restart NetworkManager`
                # ELSE firewall-cmd may report false positive "success",
                # yet NetworkManager later removes that zone and (re)binds prior ($old) zone (SILENTLY).

                # Verify/Get zone to which interface (AKA device AKA connection) is bound:
                firewall-cmd --get-zone-of-interface=$ifc # config @ firewalld
                nmcli con show $ifc |grep connection.zone # config @ NetworkManager
                #… WANT match (firewalld v. NetworkManager). 

                # Bind (assign) zone to MULTIPLE INTERFACES
                firewall-cmd --zone=k8s --add-interface=eth+ 
                firewall-cmd --zone=k8s --add-interface=ens+
                #… else by Direct Rule (See section on that)

            # Add/Remove rules at a *declared* zone, and *persist* the rule.
            #  Else operates on "default" *not* "active" zone, and rule is runtime only. 
            #  (Though warns if affected zone is not active.)
                at="--permanent --zone=$zone"
                firewall-cmd $at $rule_to_add_or_remove

            # Add/Remove rule 
                # Add port (bare)
                firewall-cmd --add-port=10255/tcp 
                # Remove same 
                firewall-cmd --remove-port=10255/tcp 
                # Add service to zone 
                firewall-cmd --zone=$zone --add-service=ssh
                # Enable Masquerading (SNAT)
                firewall-cmd --zone=trusted --add-masquerade
                # Enable forwarding
                sudo firewall-cmd --zone=trusted --add-forward

            # Add a new service 
                svc=istiod
                    # Delete if already exist (optionally):
                    # 1. Must first remove from all zones having it
                    firewall-cmd --remove-service=$svc --zone=$zone --permanent
                    # 2. Delete it
                    firewall-cmd --delete-service=$svc --permanent
                # Create
                firewall-cmd --new-service=$svc --permanent
                # Configure
                firewall-cmd --service=$svc --set-description="Istio control plane"
                firewall-cmd --service=$svc --add-port=15010/tcp 
                firewall-cmd --service=$svc --add-port=15014/tcp 
                # Add to a zone, persistently
                firewall-cmd --permanent --zone=$zone --add-service=$svc

            # Add/Remove service to currently-active zone
                firewall-cmd --add-service=$svc
                firewall-cmd --remove-service=$svc

                # ICMP : List blocks
                firewall-cmd --list-icmp-blocks
                # ICMP : Allow all 
                firewall-cmd --add-protocol=icmp
                # ICMP : Unblock all types
                firewall-cmd --remove-icmp-block-inversion
                # ICMP : Unblock a specific type
                firewall-cmd --query-icmp-block=echo-request ||
                    firewall-cmd --remove-icmp-block=echo-request
                # ICMP : All ping request/reply only : Inversion is REQUIRED IF target is DROP 
                firewall-cmd --add-icmp-block-inversion    # Invert so block allows
                firewall-cmd --add-icmp-block=echo-request # block (allow) request 
                firewall-cmd --add-icmp-block=echo-reply   # block (allow) reply
                    # # Example: This does *not* allow ping request/reply IF target is DROP.
                    # firewall-cmd --remove-icmp-block-inversion
                    # firewall-cmd --remove-icmp-block=echo-request
                    # firewall-cmd --remove-icmp-block=echo-reply

            # APPLY CHANGES to firewalld.service sans restart
            firewall-cmd --reload

            # Sources : default behavior for the zone applies to all traffic lest sources declared
                # Add source : simple
                firewall-cmd --zone=$zone --add-source=$ip_or_cidr
                # Add source : granular
                firewall-cmd --zone=$zone --add-rich-rule='rule family="ipv4" source address="'$cidr'" service name="'$svc'" accept'

            # Add/Remove RICH RULE to a zone (cannot be scoped to service)
                ## See `man firewalld.richlanguage` for rule syntax
                ## Allow traffic from VIP address by IPv4
                at="--permanent --zone=$zone"
                do='add' # add|remove
                firewall-cmd $at --$do-rich-rule='rule family="ipv4" source address="'$vip'" accept'

                # Deny (DROP) outgoing traffic on port 22
                firewall-cmd $at --$do-rich-rule='rule family="ipv4" destination port="22" drop' 

                # Deny ALL IPv4 TRAFFIC from declared source IP (regardless of target ALLOW)
                firewall-cmd $at --$do-rich-rule='rule family=ipv4 source address="'$ip'" drop'

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
                at='--permanent --direct'
                do='add' # add|remove
                firewall-cmd $at --$do-rule ipv4 filter IN_public_allow 0 -m tcp -p tcp --dport 777 -j ACCEPT
                # Allow all IPv4 traffic across all interfaces having pattern ens* 
                firewall-cmd $at --$do-rule ipv4 filter FORWARD 0 -o ens+ -j ACCEPT
                firewall-cmd $at --$do-rule ipv4 filter INPUT 0   -i ens+ -j ACCEPT
                # Restrict IPv4 traffic (src/dst) of all interfaces having pattern eth* to a CIDR (subnet)
                firewall-cmd $at --$do-rule ipv4 filter FORWARD 0 -s $cidr -o eth+ -j ACCEPT
                firewall-cmd $at --$do-rule ipv4 filter FORWARD 0 -d $cidr -i eth+ -j ACCEPT
                    # -s <CIDR>: Specifies the source IP range for outgoing traffic.
                    # -d <CIDR>: Specifies the destination IP range for incoming traffic.
                    # -o eth+: Matches outgoing traffic on interfaces 
                    # -i eth+: Matches incoming traffic on interfaces
                    # -j ACCEPT: Accepts the traffic that matches these rules.

            # Masquerade (NAT for dynamic, private IP)
                # Useful for comms between Pods and services external to cluster 
                # Add 
                firewall-cmd --add-masquerade --zone=$zone --permanent
                # Verify
                firewall-cmd --query-masquerade --zone=$zone
            
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
            #    <description>HTTP is the protocol used to serve Web pages. …</description>
            #    <port protocol="tcp" port="80"/>
            #  </service>

    NetworkManager # Network management deameon @ RHEL 
        # NetworkManager dynamically updates firewall rules, network routes, and other interface parameters.
        # Works with, OR INTERFEREs with, firewalld : See "UNMANAGED DEVICEs" configuration (below).
        man NetworkManager 
        # The NetworkManager daemon attempts to make networking configuration and operation as painless and automatic as possible by managing the primary network connection and other network interfaces, like Ethernet, Wi-Fi, and Mobile Broadband devices. NetworkManager will connect any network device when a connection for that device becomes available, unless that behavior is disabled. Information about networking is exported via a D-Bus interface to any interested application, providing a rich API with which to inspect and control network settings and operation.
        NetworkManager --print-config 
        man NetworkManager.conf 
        
        systemctl status NetworkManager.service

        # UNMANAGED DEVICEs # Configuring NetworkManager to IGNORE some devices : manage them by nftables & firewall-cmd
            # By default, NetworkManager manages all devices except the loopback (lo) device; 
            # However, device(s) may be configured as "unmanaged",
            # ALLOWING FOR more PRECISE CONTROL through nftables scripts, and WITHOUT INTERFERENCE.
            # https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/configuring-networkmanager-to-ignore-certain-devices_configuring-and-managing-networking#permanently-configuring-a-device-as-unmanaged-in-networkmanager_configuring-networkmanager-to-ignore-certain-devices
            # man NetworkManager.conf : Device List Format : Supports basic globbing : cali*
            vi /etc/NetworkManager/conf.d/99-unmanaged-devices.conf
                # To configure a specific INTERFACE (opt w/ globbing) as unmanaged, add:
                    [keyfile]
                    unmanaged-devices=interface-name:cali*
                        #… Note many K8s CNI plugins add these automatically as needed
                        # See : nmcli dev status
                    # @ multiple devices, use semicolon delimiter (";"):
                    [keyfile]
                    unmanaged-devices=interface-name:enp1s0;interface-name:enp7s0 
                # To configure a device with a specific MAC address as unmanaged, add:
                    [keyfile]
                    unmanaged-devices=mac:52:54:00:74:79:56 
                # To configure all devices of a specific TYPE as unmanaged, add:
                    [keyfile]
                    unmanaged-devices=type:ethernet 

                # WARNING : BEFORE declaring it "unmanaged":
                # Settings file(s) : Per device : $dev.nmconnection
                    ls -hl /etc/NetworkManager/system-connections/
                    # Before applying the unmanaged-devices keyfile settings, 
                        # must first PRESERVE DEVICE SETTINGS:
                        ip addr add 192.168.1.100/24 dev $dev
                        ip route add default via 192.168.1.1

                    firewall-cmd --zone=$zone --add-interface=$dev
                    firewall-cmd --reload

            # Reload the NetworkManager service:
            systemctl reload NetworkManager 
            # Verify STATE is "unmanaged"; nominally is "connected". 
            nmcli device status 

    nmcli # NetworkManager CLI 
        # firewalld works with, or conflicts with, NetworkManager
        # See "REF.RHEL.RHCE.sh" 
        # Writes to NetworkManager service
        systemctl status NetworkManager
        # CLI : nmcli, nm-tool
        # GUI : right-click on network icon for menu …

        nmcli dev status    # List devices (interfaces) + info
        nmcli dev show $dev # Network/interface info
        nmcli con show $dev # Network/interface info
        nmcli con show --active # All

        # Change zone-interface binding : Assign (bind) zone to a different interface 
            # (Interface AKA Device AKA Connection)
            firewall-cmd --zone=$zone --change-interface=$ifc --permanent
            firewall-cmd --reload
            # DECONFLICT NetworkManager INTERFERENCE with firewalld:
                # IF "Warning … controlled by NetworkManager",
                # THEN must synchronize the two configs (firewalld v. NetworkManager):
                nmcli con modify "$ifc" connection.zone $z 
                nmcli con down "$ifc" # Toggle the interface to apply the change;
                nmcli con up "$ifc"   # toggle is preferable to `systemctl restart NetworkManager`
                # ELSE firewall-cmd may report false positive "success",
                # yet NetworkManager later removes the zone and (re)binds the prior zone (silently) to that interface.

                # Verify/Get zone bound (assigned) to an interface
                firewall-cmd --get-zone-of-interface=$ifc # config @ firewalld
                nmcli con show $ifc |grep connection.zone # config @ NetworkManager
                #… WANT match (firewalld v. NetworkManager). 

        nmcli -f NAME,DEVICE,TYPE,UUID con show 
            # NAME    DEVICE  TYPE            UUID
            # LAN     enp1s0  802-3-ethernet  b9033960-b5c6-3f…

        nmcli dev wifi            # Show available WiFi networks; channel/strength/…
        nmcli -f ALL dev wifi     # Show available WiFi per SSID/BSSID/freq/…
        nmcli -m multiline -f ALL dev wifi  # @ multi-line view
        nmcli dev wifi rescan     # rescan 

        nmcli con show # show connections; NAME UUID TYPE DEVICE 
        # Toggle device : preferable to restart: `systemctl restart NetworkManager`
            nmcli con down $dev             # disable connection
            nmcli con up   $dev             # enable connection
            nmcli general  
                # STATE      CONNECTIVITY  WIFI-HW  WIFI     WWAN-HW  WWAN
                # connected  full          enabled  enabled  enabled  enabled

        # Change hostname 
            nmcli general hostname a0
            reboot
            # OR
            hostnamectl set-hostname a0
            reboot 
            # Temporarily
            hostnamectl set-hostname a0 --transient

    nftables # IP PACKET (L3) FILTERING 
        # Successor to iptables, ip6tables, arptables, and ebtables
        systemctl enable --now nftables.service
        systemctl status nftables.service
        # nftables CONFIGURATION files:
            # Unit file
            cat /usr/lib/systemd/system/nftables.service
                # [Unit]
                # Description=Netfilter Tables
                # …
                # [Service]
                # …
                # ExecStart=/sbin/nft -f /etc/sysconfig/nftables.conf
                # ExecReload=/sbin/nft 'flush ruleset; include "/etc/sysconfig/nftables.conf";'
                # ExecStop=/sbin/nft flush ruleset
                # …
                cat /etc/sysconfig/nftables.conf
                    # …
                    # #include "/etc/nftables/main.nft"
                    # …
                cat /etc/nftables/main.nft
                    # …
                    # # drop any existing nftables ruleset
                    # flush ruleset
                    # # a common table for both IPv4 and IPv6
                    # table inet nftables_svc {
                    #         # protocols to allow
                    #         set allowed_protocols {
                    #                 type inet_proto
                    #                 elements = { icmp, icmpv6 }
                    #         }
                    #         # interfaces to accept any traffic on
                    #         set allowed_interfaces {
                    #                 …
                    #         }
                    #         # services to allow
                    #         set allowed_tcp_dports {
                    # …
                    # }
                    # …
                    # #include "/etc/nftables/router.nft"
                    # …

        # Load the main table : See /usr/lib/systemd/system/nftables.service
            nft -f /etc/nftables/main.nft 
        
        iptables-nft # To set nftables rules using iptables syntax.
        nft # nftables CLI of : Handles IPv4, IPv6, ARP, and Ethernet bridging.
            nft list ruleset 
            nft list tables
            # Backup (save) the current ruleset to a file:
            nft list ruleset > /etc/nftables/saved.conf
            # Restore a saved ruleset:
            nft -f /etc/nftables/saved.conf

        # FLUSH all rules (ruleset) to "turn off" the Linux firewall; to remove all traffic restrictions.
            # Merely stopping/disabling firewalld.service does *not* stop underlying (nftables) rules from applying.
            # That fact holds true even if NetworkManager is configured to not manage the relevant interface(s).
            # Rather, the entire ruleset of nftables must be flushed.
            # Doing so will remove all active rules, thereby allowing all traffic (until such rules are re-applied).
            
            # FLUSH all Linux-firewall rules:
            systemctl disable --now firewalld.service
            
            nft flush ruleset 
            
            # REAPPLY all Linux-firewall rules:
            systemctl enable --now firewalld.service

        # Create a table of the inet "address family" (used for both IPv4 and IPv6):
        table=atable
        chain=achain
        # ADDRESS FAMILIES : Type of packets processed : A table and its rules/chains processes only one type.
            ip      # IPv4 traffic packets
            ip6     # IPv6 traffic packets
            inet    # Internet (IPv4/IPv6) traffic packets
            arp     # IPv4 ARP packets
            bridge  # Packets traversing a bridge device
            netdev  # Ingress and Egress traffic packets 
        nft add table inet $table 
        # Add a chain to a table
            # Create a new chain in table $table, e.g., to filter traffic:
            nft add chain inet $table $chain { type filter hook input priority 0 \; }
                # - type filter : This chain will FILTER traffic.
                # - hook input  : Specifies that this chain applies to INCOMING traffic.
                # - priority 0  : Determines the ORDER in which this rule will be applied.
        # List chains in a table
            # View all chains in a specific table:
            nft list chain inet $table $chain 
        # Add a rule to accept traffic:
            # Allow incoming traffic on port 22 (SSH) in the $chain:
            nft add rule inet $table $chain tcp dport 22 accept 
        # Add a rule to drop traffic:
            # Drop traffic on port 80 (HTTP):
            nft add rule inet $table $chain tcp dport 80 drop 
        # Add a rule to log traffic:
            # Log incoming traffic on port 443 (HTTPS):
            nft add rule inet $table $chain tcp dport 443 log prefix "HTTPS request: " accept 
        # Working with Sets (Efficient Management of Multiple IPs or Ports):
            # Create a set of IP addresses:
                # Create a set of allowed IP addresses:
                nft add set inet $table allowed_ips { type ipv4_addr \; }
            # Add IPs to a set:
                # Add specific IP addresses to the allowed_ips set:
                nft add element inet $table allowed_ips { 192.168.1.1, 10.0.0.5 }
            # Use the set in a rule:
                # Allow traffic from any IP in the allowed_ips set:
                nft add rule inet $table $chain ip saddr @allowed_ips accept
        # Handling Counters and Rate Limiting:
            # Add a rule with a counter:
                # Track the number of packets and bytes for traffic on port 80:
                nft add rule inet $table $chain tcp dport 80 counter accept
            # Rate limiting:
                # Limit incoming traffic to 10 connections per second for SSH (port 22):
                nft add rule inet $table $chain tcp dport 22 limit rate 10/second accept
        # Deleting : Tables, Chains, and Rules:
            # Delete a rule:
                # Remove a specific rule (e.g., drop rule for port 80):
                nft delete rule inet $table $chain tcp dport 80 drop
            # Delete a chain:
                # Remove the chain (must delete all rules in the chain first):
                nft delete chain inet $table $chain
            # Delete a table:
                # Remove an entire table (which also removes all chains and rules inside it):
                nft delete table inet $table
        # Flushing and Saving Configuration:
            # Flush a chain:
                # Remove all rules from a chain but keep the chain:
                nft flush chain inet $table $chain
            # Flush a table:
                # Remove all rules and chains from a table but keep the table:
                nft flush table inet $table
            # Backup/Restore configuration:
                # To backup (save) the current ruleset to a file:
                nft list ruleset > /etc/nftables/saved.conf
                # To restore a saved ruleset:
                nft -f /etc/nftables/saved.conf
            # Flush EVERYTHING : Debug or entirely new configuration
                nft flush ruleset 

    iptables  # IP Tables; PACKET (L3) FILTERING tool and NAT [IPv4/IPv6] : man iptables(8)
        # Powerful, low-level FIREWALL implemented as Netfilter modules 
        # >>>  DEPRICATED  <<< : Use nftables (nft or iptables-nft) instead.
        # - list contents of the PACKET FILTER RULESET
        # - add/remove/modify rules in PACKET FILTER RULESET
        # - list/reset per-rule counters of PACKET FILTER RULESET
        # http://www.netfilter.org/ 
        # https://wiki.centos.org/HowTos/Network/IPTables
        # https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules 
            -t $table   # DEFAULT table is "filter"
            -n          # Numeric Addr/Port, else lists by name
            -v          # Verbose
        # Tables
            filter      # Default; the primary packet-filtering table;
                        # contains build-in chains: INPUT, FORWARD, OUTPUT
            nat         # NAT and SNAT; consulted when a packet creates a new connection;
                        # contains built-in chains: PREROUTING, INPUT, OUTPUT, POSTROUTING
            mangle      # Specialized packet alteration; PREROUTING, INPUT, OUTPUT, FORWARD, POSTROUTING
            raw         # Exemptions and NOTRACK target rules; PREROUTING, OUTPUT
            security    # MAC rules, e.g., SECMARK and CONNSECMARK targets; INPUT, OUTPUT, FORWARD
        
        # list rule(s) : Unless declared (-t $tbl), defaults to "filter" table
            iptables -S $chain # List rules of Selected chain
            iptables -L        # List rules of all chains
            iptables -L -n -v  # … numeric refernces, and verbose
            iptables -L -n -v -t $table #… of the declared table
            iptables-save      # Dump iptables rules

        # Set a rule on INPUT chain of filter table : Listen on port 22
            iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
            
        # Flush iptables "nat" and "mangle"
            iptables --flush
            iptables --delete-chain
            iptables -t nat --flush
            iptables -t nat --delete-chain
            iptables -t mangle --flush
            iptables -t mangle --delete-chain

        # Delete rules
            iptables -t -F         # ALL chains of a table
            iptables -F $chain  # Only those of $chain

        # Save/Restore scripts :
            /etc/network/if-pre-up.d/
            /etc/network/if-post-down.d/

    # http://www.netfilter.org/projects/nftables/index.html

    ufw  # Uncomplicated Firewall  https://help.ubuntu.com/community/UFW
        ufw enable|disble|status 
        # BLOCK intruder per IP Address; e.g., some local [LAN] intruder here …
            ufw block proto tcp from 192.168.8.345  
        # deny … 
            ufw deny 53/udp  # deny UDP packets on port 53 
            ufw deny ssh     # deny all SSH connections
