# [Domain Name System](https://en.wikipedia.org/wiki/Domain_Name_System "Wikipedia.org") (DNS)

## DNS Servers

Popular solutions for (sub)networks having [RFC-1918](https://datatracker.ietf.org/doc/html/rfc1918) adress spaces:

1. BIND (Berkeley Internet Name Domain)
    - Overview: BIND is one of the most widely used DNS servers. It's highly configurable and supports a vast array of DNS features, making it suitable for everything from small networks to large, complex infrastructures.
    - Features: BIND supports advanced DNS features like DNSSEC for added security, dynamic updates, and zone transfers. It's often used in large enterprises due to its flexibility and extensive documentation.
2. Microsoft DNS
    - Overview: Integrated with Windows Server, Microsoft DNS is commonly used in environments heavily reliant on Windows infrastructure. It integrates seamlessly with Active Directory, allowing for dynamic DNS updates as network objects change.
    - Features: Easy integration with Windows environments, support for dynamic updates, and tight integration with Active Directory. It's a go-to choice for organizations already invested in Microsoft infrastructure.
3. Unbound
    - Overview: Unbound is a lightweight, secure, and easy-to-configure DNS server designed for high performance. It's often used as a caching DNS resolver and can serve as an authoritative server for private zones.
    - Features: Focuses on performance and security, with features like DNSSEC validation built-in. It's ideal for environments where a secure, validating resolver is required.
4. PowerDNS
    - Overview: PowerDNS offers a suite of DNS software, including an authoritative server and a recursive resolver. It's known for its flexibility, with support for various back-ends including relational databases, making DNS data management and integration with other systems straightforward.
    - Features: Supports dynamic DNS updates, DNSSEC, and has a strong API for integration with external systems, making it a strong choice for dynamic and automated environments.
5. CoreDNS
    - Overview: CoreDNS is a modern, extensible DNS server that can serve as both an authoritative and a recursive DNS server. It's particularly popular in cloud-native environments and is included as a default DNS server in Kubernetes clusters.
    - Features: Highly modular and extensible through plugins, CoreDNS can be tailored to specific needs and integrates well with modern, containerized environments.

Choosing a DNS Server

When selecting a DNS server for an environment, consider factors like existing infrastructure, performance and scalability needs, security features, and ease of management. For example, environments heavily invested in Windows might prefer Microsoft DNS for its integration with Active Directory, while cloud-native or highly automated environments might lean towards CoreDNS or PowerDNS for their flexibility and API support.

In VMware or other virtualized environments, the choice might also be influenced by the ease of automation and integration with virtual machine management, where solutions like PowerDNS or CoreDNS could offer advantages due to their APIs and flexibility in handling dynamic DNS updates.

## DNS Records

### `A` Record

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
- "`3600`" : The __TTL__ (time to live), listed in **seconds**. So, the setting there is to one hour. The TTL is the __time required for a record update to take effect__.  Common TTL for DNS records is between `300` (5 minutes) and `86400` (24 hours), with defaults varying by DNS providers. The shorter the time, the more responsive to changes, but the higher the load on DNS servers.

>Confusingly, the "A record" is that of the truely canonical name, whereas a CNAME record AKA "canonical-name record" is just an alias. All such aliases, e.g., those of all subdomains and domain aliases alike, should point to the one true canonical name. That is, to the "A record".

### `CNAME` Record

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

