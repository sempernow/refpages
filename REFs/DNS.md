# [Domain Name System](https://en.wikipedia.org/wiki/Domain_Name_System "Wikipedia.org") (DNS) | [RFC 1034](https://datatracker.ietf.org/doc/html/rfc1034), [RFC 1035](https://datatracker.ietf.org/doc/html/rfc1035) | [ChatGPT](https://chatgpt.com/c/6702c7fe-caa4-8009-ad29-acc4c8b6ba5f)

## Overview

DNS is a hierarchical and distributed __name service__ AKA __directory service__ that provides a naming system for computers, services and such on Internet Protocol (IP) networks. It associates various information with domain names (identification strings) assigned to each of the associated entities. Most prominently, it __translates__ readily memorized __domain names__ to numerical __IP addresses__.

>Note that DNS is merely one sort of *directory service*. Other notable directory services include Microsoft [__Active Directory__](https://en.wikipedia.org/wiki/Active_Directory) (AD), which is a database and set of services, including that connect users with network resources. One of its "roles" is Active Directory Domain Services (AD DS), which is the <dnf title="Identity Provider">IdP</dfn> thereunder.

## Domain Name System Security Extensions ([__DNSSEC__](https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions "Wikipedia.org"))

DNSSEC adds a layer of security to DNS by enabling DNS responses to be __digitally signed__. 
This ensures that the DNS responses you get have not been tampered with and are coming from an authentic source. 
It helps prevent attacks like __DNS spoofing__ or __cache poisoning__, where an attacker provides false DNS records.

Resolvers such as BIND, Unbound and CoreDNS can act as a DNSSEC __validator__, 
verifying that DNS records are authentic and signed. 
DNSSEC requires some additional configuration. 
For example, enabling the `dnssec` plugin of CoreDNS, and ensuring DNSSEC is supported by zones or upstream servers.

- DNS-over-TLS (__DoT__):  
    Encrypts DNS queries, making sure that third parties (like ISPs or attackers) cannot see what domains you are querying. This is useful for ensuring privacy and security, as traditional DNS queries are sent in plaintext. Requires configuring certificates and configuring resolver to listen on a TLS port (`853`).
- DNS-over-HTTPS (__DoH__):  
    Works similarly to DoT, but it encrypts DNS queries over HTTPS, 
    using the same protocol as web traffic. 
    This not only hides DNS queries from third parties but also makes it harder for network administrators to block or filter DNS requests, 
    as DoH traffic looks like regular web traffic.

## DNS Servers

Installing a __local DNS resolver__ in a VPN or within each subnet can improve performance, privacy, resilience, and internal DNS control, especially in complex networks with multiple VMs, subnets, or VPNs. Whether to install it in each VM or subnet depends on the specific needs for redundancy, security, and performance. For larger or more segmented networks, having local DNS resolvers in each subnet (or even on each critical VM) can be quite beneficial.

### When to Install in Each VM vs. Only in Subnets:
   - __Per VM__: Installing a local resolver in each VM is beneficial if your VMs are highly isolated, and you want each to resolve DNS queries independently. This can improve resiliency and reduce dependency on network-wide DNS failures.
   - __Per Subnet__: A local resolver in each subnet (but not necessarily in each VM) can centralize DNS resolution within that subnet, reducing the overhead of running separate instances while still improving latency and control within that segment.

### Potential Downsides:
   - __Overhead__: Running a local resolver in every VM or subnet adds additional maintenance and resource overhead. In smaller environments, a single central resolver may be sufficient.
   - __Consistency__: If not properly configured, multiple DNS resolvers within the same network could lead to inconsistent resolution results, especially when caching policies or custom configurations differ between resolvers.

### Benefits of Local Resolver

1. __Improved Performance (Reduced Latency)__
    - __Local caching__: A local resolver caches DNS queries, meaning frequently requested domain lookups (like those for external services or internal network devices) will be resolved more quickly after the initial query.
    - __Reduced dependency on external resolvers__: Instead of querying an external DNS server for every request, local queries can be handled by the local Unbound instance, reducing round-trip times and improving overall response speed.
1. __Network Segmentation and Isolation__
    - __Internal name resolution__: If you have internal services within the VPN or subnet, a local DNS resolver can provide faster and more secure resolution for internal resources without relying on external DNS servers.
    - __Local name overrides__: You can configure local hostnames or domains that only exist within your private network, which can be useful for custom internal services or segmented network environments. This also prevents reliance on external systems for internal names.
1. __Resilience and Redundancy__
    - __DNS fallback__: If your external DNS server becomes unavailable (e.g., your VPN or primary connection to an upstream DNS fails), a local resolver can help by serving cached results for already queried domains, providing continued access to known services.
    - __Multiple VMs, subnets__: Installing Unbound in each VM or subnet can provide __fault tolerance__. If one local resolver fails, others can still handle DNS queries for their respective parts of the network.
1. __Security and Privacy__
        - __DNS over TLS (DoT) or DNS over HTTPS (DoH)__: Unbound supports these secure DNS protocols, ensuring that DNS queries are encrypted, which improves privacy and protects against DNS spoofing and man-in-the-middle attacks.
        - __Local DNS filtering__: You can apply custom DNS filtering policies to block certain domains or provide access only to specific internal services, improving security within your network.
1. __Control over DNS Forwarding and Split-horizon DNS__
    - __Custom DNS forwarding__: With Unbound, you can configure forwarding rules, allowing you to direct specific DNS requests to different upstream resolvers (e.g., internal queries go to an internal DNS server, while external queries go to an upstream public DNS service).
    - __Split-horizon DNS__: You can serve different DNS responses based on the source of the request, which can be valuable if you have different services available to internal and external clients.

### Popular solutions for private ([RFC-1918](https://datatracker.ietf.org/doc/html/rfc1918 "IETF.org")) networks (subnets):


1. [__BIND 9__](https://en.wikipedia.org/wiki/BIND "Wikipedia.org") (Berkeley Internet Name Domain)
    - Overview: BIND 9 is one of the most widely used DNS servers. It's highly configurable and supports a vast array of DNS features, making it suitable for everything from small networks to large, complex infrastructures.
    - Features: BIND supports advanced DNS features like DNSSEC for added security, dynamic updates, and zone transfers. It's often used in large enterprises due to its flexibility and extensive documentation.
        ```bash
        ☩ sudo dnf provides bind
        ...
        bind-32:9.16.23-18.el9_4.6.x86_64 : The Berkeley Internet Name Domain (BIND) DNS (Domain Name System) server
        Repo        : rhel-9-for-x86_64-appstream-rpms
        Matched from:
        Provide    : bind = 32:9.16.23-18.el9_4.6
        ```
2. __Microsoft DNS__
    - Overview: Integrated with Windows Server, Microsoft DNS is commonly used in environments heavily reliant on Windows infrastructure. It integrates seamlessly with Active Directory, allowing for dynamic DNS updates as network objects change.
    - Features: Easy integration with Windows environments, support for dynamic updates, and tight integration with Active Directory. It's a go-to choice for organizations already invested in Microsoft infrastructure.
3. [__Unbound__](https://www.nlnetlabs.nl/projects/unbound/about/ "NLNETlabs.nl")
    - Overview: Unbound is a lightweight, secure, and easy-to-configure DNS server designed for high performance. It's often used as a caching DNS resolver and can serve as an authoritative server for private zones.
    - Features: Focuses on performance and security, with features like DNSSEC validation built-in. It's ideal for environments where a secure, validating resolver is required.
        ```bash
        ☩ sudo dnf provides unbound
        ...
        unbound-1.16.2-3.el9_3.5.x86_64 : Validating, recursive, and caching DNS(SEC) resolver
        Repo        : rhel-9-for-x86_64-appstream-rpms
        Matched from:
        Provide    : unbound = 1.16.2-3.el9_3.5
        ```
4. __PowerDNS__
    - Overview: PowerDNS offers a suite of DNS software, including an authoritative server and a recursive resolver. It's known for its flexibility, with support for various back-ends including relational databases, making DNS data management and integration with other systems straightforward.
    - Features: Supports dynamic DNS updates, DNSSEC, and has a strong API for integration with external systems, making it a strong choice for dynamic and automated environments.
5. [__CoreDNS__](https://coredns.io/ "CoreDNS.io")
    - Overview: CoreDNS is a modern, extensible DNS server that can serve as both an authoritative and a recursive DNS server. It's particularly popular in cloud-native environments and is included as a __default DNS server in K8s clusters__.
    - Features: Highly modular and extensible through plugins, CoreDNS can be tailored to specific needs and integrates well with modern, containerized environments. 
    Plugins for : DNSSEC (`dnssec`), DoH (`doh`) and DoT (`tls`).

Choosing a DNS Server

When selecting a DNS server for an environment, consider factors like existing infrastructure, performance and scalability needs, security features, and ease of management. For example, environments heavily invested in Windows might prefer Microsoft DNS for its integration with Active Directory, while cloud-native or highly automated environments might lean towards CoreDNS or PowerDNS for their flexibility and API support.

In VMware or other virtualized environments, the choice might also be influenced by the ease of automation and integration with virtual machine management, where solutions like PowerDNS or CoreDNS could offer advantages due to their APIs and flexibility in handling dynamic DNS updates.

## DNS Records

### [Zone file](https://en.wikipedia.org/wiki/Zone_file "Wikipedia.org")

The zone file of a DNS zone contains mappings between domain names and IP addresses and other resources, organized in the form of text representations of [__resource records__](https://en.wikipedia.org/wiki/Domain_Name_System#Resource_records) (RR). A zone file may be either a DNS master file, authoritatively describing a zone, or it may be used to list the contents of a DNS cache.

The zone file is the central configuration that holds all the resource records (RRs) for the domain (or subdomain) that the zone covers. The zone file contains various types of resource records, such as SOA, A, AAAA, CNAME, MX, and others.


```ini
$TTL 86400
@   IN  SOA   ns1.example.com. admin.example.com. (
        2023100601 ; Serial
        7200       ; Refresh
        3600       ; Retry
        1209600    ; Expire
        86400      ; Negative TTL
    )
@   IN  NS    ns1.example.com.
@   IN  NS    ns2.example.com.

@   IN  A     192.0.2.1
www IN  A     192.0.2.2
```
- `NS` (Nameserver) : Declares an authoritative nameserver of the domain 
  (`@` is placeholder for root AKA apex domain of zone).
    - Multiple NS records provide redundancy and (DNS-based) load balancing.
- `SOA` (Start of Authority) : Defines the primary nameserver and basic zone configuration.
- `A`/`AAAA` (Address) : Maps a domain or subdomain to an IP (`v4`/`v6`) address.
- `CNAME` (Canonical Name) : Defines an __alias__ for a domain name and points it to `A` record having the Canonical Name (root domain).
- `MX` : Defines mail servers for the domain.

#### Origin Domain 

The __Origin Domain__ of the zone is typically declared using the `@` symbol or through the `$ORIGIN` directive. If the `@` symbol is used in the zone file, it acts as a placeholder for the origin domain, which is either explicitly declared in the file using the `$ORIGIN` directive or inherited from the zone definition provided in the DNS server configuration.

The origin domain is not always explicitly stated inside the zone file because the origin domain is often declared in the configuration of the DNS server itself. 

Example : The `BIND` resolver (DNS server) has zone definition in `named.conf` :

```ini
zone "example.com" {
    type master;
    file "/etc/named/zones/db.example.com";
};
```

#### [`NS` Record](https://www.cloudflare.com/learning/dns/dns-records/dns-ns-record/ "cloudflare.com")

The NS records are what the global DNS system uses to delegate authority to the nameservers for a domain,
thereby defining the __authoritative nameservers__.

They are the "entry points" for queries directed at the domain. 
When these DNS queries need to be resolved (e.g., finding the IP address for `www.example.com`), 
the NS records tell the DNS resolver which nameservers are responsible 
for answering queries about the root domain (`example.com`) and its subdomains.

#### [`SOA` Record](https://en.wikipedia.org/wiki/SOA_record "Wikipedia.org")

Start Of Authority (SOA) record contains administrative information about the zone, especially regarding zone transfers. The SOA record format is specified in [RFC 1035](https://datatracker.ietf.org/doc/html/rfc1035). The SOA record helps manage updates to the zone but __does not directly handle the query resolution__ for external clients.

[Structure](https://en.wikipedia.org/wiki/SOA_record#Structure "Wikipedia.org") (by examples):

```ini
;NAME          TTL    CLASS  TYPE  MNAME             RNAME       
example.com.   86400  IN     SOA   ns1.example.com.  hostmaster.example.com. (
    2023100601  ; SERIAL  : Serial number 
    3600        ; ESH : Refresh interval
    900         ; RETRY   : Retry interval
    1209600     ; EXPIRE  : Expire time
    86400       ; MINIMUM : Minimum TTL (Negative-response caching TTL)
)
```

In BIND syntax:

```ini
$TTL 86400
@   IN  SOA     ns.icann.org. noc.dns.icann.org. (
    2020080302  ; SERIAL  : Serial number 
    7200        ; ESH : Refresh interval
    3600        ; RETRY   : Retry interval
    1209600     ; EXPIRE  : Expire time
    3600        ; MINIMUM : Minimum TTL (Negative-response caching TTL)
)
```
- `$TTL 86400` TTL : `$TTL` (Time To Live) sets __the default for all records__ in the zone. 
    Set here to 24 hours (`86400/3600`). This means that DNS resolvers will cache resource records in this zone for 24 hours _unless otherwise specified_ for specific records.
- `@` is a shorthand for the origin domain (the domain for which this zone file is authoritative). 
    In this example, the SOA record applies to the root domain of the zone, such as `example.com`, but without explicitly mentioning the domain name. The __actual domain__ is __inherited from__ the __zone definition__.
- `MNAME`: `ns.icann.org` is the master AKA primary name server.
- `RNAME`: `noc.dns.icann.org` is the email of the responsible party (DNS administrator) 
    __in DNS zone file syntax__; the `@` symbol of email address is replaced by a dot (`.`). 
    So, "`noc.dns.icann.org.`" translates to `noc@dns.icann.org` 
- `SERIAL`: `2020080302` is the serial number of the zone file. 
    Typical format is `YYYYMMDDnn`, so `2020080302` means the __second revision__ (`02`) of the zone file on __August 3, 2020__ (`20200803`). This number __increments with every update__ to the zone. Secondary DNS servers use this number to determine if the zone has changed and if they need to fetch a new copy of the zone file.
- `ESH`: `7200` is the __time a secondary DNS server will wait__ (seconds) 
    before querying primary server for updated zone file. 
    Set here to 2 hours (`7200/3600`). 
    - Recommended/default is `86400` seconds (24 hours).
- `RETRY`: `3600` is __time before trying again after failing to contact primary server__ (seconds). 
    Set here to 1 hour. 
    - Recommended/default is `7200` (2 hours).
- `EXPIRE`: `1209600` is __time after which a secondary server will stop serving the zone__ (seconds) 
    if it cannot contact the primary server for an update. 
    Set here to 14 days (`1209600/(24*3600)`). After this period of uninterrupted failures, the secondary server __discards__ its copy of the __zone file__. Hence "expire".
    - Recommended/default is `3600000` (41.7 days; 1000 hours).
- `MINIMUM`: `3600`  __time that DNS resolvers will cache negative responses__ (seconds). 
    E.g., when a domain or subdomain doesn't exist. Set here to 1 hour. 
    See [RFC 2308](https://datatracker.ietf.org/doc/html/rfc2308 "IETF.org").
    - Recommended/default is `172800` (2 days). 

#### `A` Record

The "`A`" stands for "address", as in "IP address".

Primary use is __to resolve a domain name to an IPv4 address__. 
Resolving to an IPv6 address requires an "`AAAA`" record. Another use for DNS A records is for operating a Domain Name System-based Blackhole List (DNSBL). DNSBLs can help mail servers identify and block email messages from known spammer domains.

Most websites have only one A record. The IPv4 address to which it resolves is often that of a highly-available (HA) load balancer. Some higher profile websites have several A records, with same domain name pointing to different IPv4 addresses, allowing DNS-based load balancing as well, AKA Round-robin DNS.

Example `A` record:

|`example.com` | record type: | value:      |TTL   |
|--------------|--------------|-------------|------|
| `@`          | `A`          |`192.0.2.1`  |`3600`|

- "`@`" : Represents the domain __root__ AKA __apex__, not just that of the current DNS record. 
  Its value here indicates this record is for the root domain, `example.com`.
- "`3600`" : The __TTL__ (time to live), listed in __seconds__. So, the setting there is to one hour. The TTL is the __time required for a record update to take effect__.  Common TTL for DNS records is between `300` (5 minutes) and `86400` (24 hours), with defaults varying by DNS providers. The shorter the time, the more responsive to changes, but the higher the load on DNS servers.

>Confusingly, the "A record" is that of the truely canonical name, whereas a CNAME record AKA "canonical-name record" is just an alias. All such aliases, e.g., those of all subdomains and domain aliases alike, should point to the one true canonical name. That is, to the "A record".

#### `CNAME` Record

A "canonical name" (CNAME) record is that of an alias domain (`blog.example.com`) that points to a root domain (`example.com`). That truely canonical root record, which resolves to an IPv4 address, is the "A record". 

CNAME records __must point to a domain, never to an IP address__. 

Subdomains and alias domain names are typically configured with CNAME records pointing to a root domain (that has a DNS A record). __Configured this way__, if, as, and whenever the domain's host changes its IPv4 address, __only one DNS record requires an update__. That of the "A record" for the root domain. This single DNS-record update triggers a cascade of DNS server updates per TTL of each and every affected CNAME record.

Example of a CNAME record:

|`blog.example.com` | record type: | value:                     |TTL    |
|-------------------|--------------|----------------------------|-------|
|`@`                |`CNAME`       |is an alias of `example.com`|`32400`|

This CNAME record for `blog.example.com` points to `example.com` with a TTL of 9 hours. 
From our example A record, we know this resolves to IPv4 address `192.0.2.1`.

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

