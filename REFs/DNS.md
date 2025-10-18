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

---
---

## TLD of Private (RFC1918) Network

This is a critical design decision for any air-gapped or private network, 
with long-lasting implications for security, manageability, and compatibility.

Here are the implications of each TLD &hellip;

### The Golden Rule: Never Use a Public TLD You Don't Own

First, a critical principle: **You should never use a TLD for your internal network that you could legally register in the public DNS.** This includes `.corp`, `.lan`, `.local` (in a specific context, see below), `.office`, `.network`, or any other gTLD (generic TLD) or ccTLD (country code TLD).

**Why?** Because it creates a **name collision** risk. If you use `internal.corp` and someone registers that domain publicly, or if a software vendor hardcodes a reference to it, your internal DNS resolution can break or, worse, be hijacked if a device ever gets exposed to the internet (even temporarily via a VPN misconfiguration or a laptop leaving the site). This is a serious security and stability anti-pattern.

### TL;DR

If an enterprise owns the publicly registered domain __`www.abiz.com`__, 
then the domain or parent of subdomains of any of its private (RFC1918) networks should use:

1. Best choice: __`a.abiz.com`__ 

2. Second-best choice: __`a.internal`__

Where "`a.`" is any subdomain other than any used publicly by `abiz.com`.

#### Example 

An enterpise __`abiz.com`__ has a project __`prj`__ that has two enterprise-grade air-gapped networks:

- __`one.prj.abiz.com`__
- __`two.prj.abiz.com`__

### Analysis of TLDs

#### 1. `.local`
* **Reserved by IETF ([RFC 6762](https://www.rfc-editor.org/rfc/rfc6762))** for *mDNS / Bonjour / Zeroconf*, so it will **never** be delegated in the public DNS root. However, many OSes (especially macOS, iOS, and Linux with [Avahi](https://en.wikipedia.org/wiki/Avahi_%28software%29)/Avahi-compat libs) *hard-code* `.local` for __link-local multicast DNS__.
*   **Pros:**
    *   **No Collision Risk:** It's safe from public registration.
    *   **Widely Recognized:** Many consumer-grade devices (printers, IoT, Apple Bonjour services) use it by default.
*   **Cons:**
    *   **AD Incompatibility:** This is the **primary and absolute deal-breaker for an enterprise with a Windows Domain Controller**. Active Directory Domain Services (AD DS) is built upon DNS. An AD domain *must* be a DNS domain. Using a `.local` domain for AD requires "single-label" DNS names or other workarounds that break standard DNS compliance and can cause significant issues with Microsoft and third-party applications, SQL Server, and PKI/certificate services.
        * __Microsoft's Guidance__: Microsoft strongly discourages using .`local` or other non-standard TLDs for AD domains. Instead, they recommend using a subdomain of a registered, globally resolvable domain (e.g., corp.example.com) or a private TLD like `.corp` or `.lan` (though these are not officially reserved). This ensures DNS compliance and avoids conflicts.
    *   **mDNS Interference:** Since `.local` is used for mDNS, you can get unexpected resolution behavior on networks where both a unicast DNS server (like your internal BIND/Windows DNS) and mDNS are active.
        * May cause name resolution conflicts and odd behavior: Windows may try AD DNS resolution, while macOS/Linux may intercept with mDNS.
    * [Non-compliant with __CA/Browser Forum__ Baseline Requirements](https://cabforum.org/working-groups/server/baseline-requirements/certificate-contents/), so public CAs won't issue certs for them. 
      Though internal CAs can, tooling may reject.
*   **Verdict:** **Avoid `.local`** for enterprise AD or air-gap root domains 
    unless you want headaches with mDNS conflicts.

#### 2. `.lan`
*   **Technical Status:** This is **not** a reserved Special Use Domain. It is a common convention, but it has no official status. It is **not safe** from future delegation.
*   **Pros:**
    *   **Human Readable:** Clearly stands for "Local Area Network."
    *   **Common Convention:** Widely used in SOHO (Small Office/Home Office) routers and home labs. You are unlikely to run into immediate problems.
*   **Cons:**
    *   **Name Collision Risk:** While not currently a public TLD, there is no guarantee it won't become one. This violates the golden rule and is not future-proof for an enterprise.
    *   **Not Standardized:** No RFC governs its use, so its behavior is purely by convention.
*   **Verdict:** **Okay for air-gap enterprise lab** environments; 
    otherwise avoid in enterprise-grade networks.

#### 3. `.corp`
*   **Technical Status:** This is a **particularly dangerous choice**. For many years, `.corp` was the *de facto* example of an internal TLD used in Microsoft documentation and training. However, it was **delegated as a real gTLD** and is ___now owned by a registry in the public DNS___.
*   **Pros:**
    *   *None that outweigh the severe risks.*
*   **Cons:**
    *   **Extreme Name Collision Risk:** This is the textbook example of what **not** to do. Any leak of DNS queries for your `.corp` domain to the public internet will attempt to resolve against the real public `.corp` TLD, leading to resolution failures or security risks.
    *   **Explicitly Advised Against:** ICANN and other security bodies have issued warnings specifically about `.corp`, `.home`, and `.mail` due to their history of use on private networks.
*   **Verdict:** **Absolutely do not use.** If you have an existing domain using `.corp`, planning a migration away from it should be a high priority.

#### 4. `.home.arpa` 
*  This is a Special-Use Domain Name designated for use in **residential home networks**. The `.arpa` TLD is reserved for **Internet infrastructure** purposes, and `.home.arpa` is a special subdomain to prevent DNS conflicts.

### The Advised Best Practice for Enterprise Air-Gapped Networks

The correct, enterprise-grade approach is to use a **subdomain of a publicly registered domain name that you own.**

#### Recommended Syntax:
`internal.abiz.com` or `private.abiz.com` or `corp.abiz.com`

**Examples:**
*   If your public website is `example.com`, use `ad.example.com` or `internal.example.com` for your Active Directory domain.
*   If you want a clear separation, you could register a domain specifically for this purpose (e.g., `example-internal.com`), but using a subdomain is more common.

#### Why This is the Best Practice:

1.  **No Name Collisions:** You own the domain. You have absolute control over its namespace. There is no risk of conflict with public DNS.
2.  **Maximum Compatibility:**
    * **Active Directory:** Works flawlessly. You can create a domain like `ad.airgapco.com` without any issues.
    * **TLS/CA Services (PKI):** This is critical. 
    Public Certificate Authorities (and your own internal CA) will only issue certificates for domains you can prove you own. 
    If your AD domain is `ad.airgapco.com`, you can easily get a publicly trusted certificate for `server1.ad.airgapco.com` if needed, or more importantly, your internal CA will be managing a namespace you legally control. Using a fake TLD like `.corp` makes certificate management a nightmare.
    * **DNS and DHCP:** All standard-compliant tools work perfectly with this model.
3.  **Clarity and Consistency:** It's logically organized. 
    `server1.internal.airgapco.com` is clearly an internal resource, while `www.airgapco.com` is public.
4.  **Security:** It enforces a clear boundary. 
    Even if a machine accidentally receives a public DNS server (e.g., 8.8.8.8), 
    it will not be able to resolve your internal domain names, which is a good safety measure.

### Special Case: The __`.internal`__ pseudo-TLD

There is a growing consensus and a draft RFC to formally reserve `.internal` 
as a Special Use Domain (like `.local`) specifically for this purpose: 
dedicated private networks where using a owned domain is not feasible. 
While not yet an official standard, it is a much safer choice than `.corp` or `.lan` because:

*   It is highly likely to be officially reserved.
*   It has no existing use (unlike `.local`'s mDNS conflict).
*   Major OS and tooling vendors are aware of the draft and are unlikely to conflict with it.

**Verdict on `.internal`:** If you **absolutely cannot** use a subdomain of a domain you own (e.g., for legal or policy reasons), 
`.internal` is the best of the "fake TLD" options. 
It is far superior to `.lan` or `.local` for an enterprise AD environment. 
However, **using a subdomain you own is still the gold standard.**

### Summary & Final Recommendation

| TLD | Recommended? | Key Reason |
| :--- | :--- | :--- |
| **`.corp`** | **❌ Never** | High collision risk; now a real public TLD. |
| **`.local`** | **❌ For Enterprise AD** | Conflicts with mDNS and breaks AD DS requirements. |
| **`.lan`** | **⚠️ For Lab Only** | Convention, not a standard; future collision risk. |
| **`.internal`** | **✅ Good Fallback** | Best "fake TLD"; likely to be standardized; no mDNS conflict. |
| **`sub1.abiz.org`** | **✅✅ BEST PRACTICE** | No collisions, full PKI/TLS support, maximum compatibility. |

---

## FreeIPA AD Integration 

See `AD-IPA.DNS` ([MD](/1%20Data/IT/OS/Windows/Windows%20Server%202019/AD-IPA-integration/AD-IPA.DNS.md)|[HTML](/1%20Data/IT/OS/Windows/Windows%20Server%202019/AD-IPA-integration/AD-IPA.DNS.html)) 

# &nbsp;

<!-- 

… ⋮ ︙ • ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
☢ ☣ ☠ ¦ ¶ § † ‡ ß µ Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 🡸 🡺 ➔
ℹ️ ⚠️ ✅ ⌛ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🥇 ✨️ 🔚

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# README HyperLink

README ([MD](__PATH__/README.md)|[HTML](__PATH__/README.html)) 

__PATH__ : 
# Bookmark

- Target
<a name="foo"></a>

- Reference
[Foo](#foo)

-->
