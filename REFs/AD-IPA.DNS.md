# DNS for AD-IPA Integration

See `DNS` ([MD](/1%20Data/IT/Network/DNS/DNS.md)|[HTML](/1%20Data/IT/Network/DNS/DNS.html)) 


## FreeIPA AD Integration 

FreeIPA (Identity, Policy, Audit) is a Linux-based identity management solution 
that can interoperate with AD via __cross-forest trusts__ or direct integration. 
Using `ipa.lime.abiz.com` as a __subordinate domain__ under `lime.abiz.com` is a valid approach, 
as it maintains a clear DNS hierarchy and allows FreeIPA to leverage AD's DNS for resolution.

See `AD-IPA.topology` ([MD](/1%20Data/IT/OS/Windows/Windows%20Server%202019/AD-IPA-integration/AD-IPA.topology.md)|[HTML](/1%20Data/IT/OS/Windows/Windows%20Server%202019/AD-IPA-integration/AD-IPA.topology.html)) 


DNS of hosts under RHEL IdM (a branded version of FreeIPA) is delegated to IdM by AD

### TL;DR

Hosts under FreeIPA (e.g., `host1.ipa.lime.abiz.com`) 
should have their DNS records managed by the FreeIPA server's DNS service for the `ipa.lime.abiz.com` __zone__. 
This aligns with best practices for DNS hierarchy, ensures proper integration with FreeIPA's identity management features, 
and supports FIPS and security compliance in an air-gapped network. 
Proper DNS delegation from AD to FreeIPA and correct configuration of FreeIPA's DNS service are critical for seamless operation. 
For detailed guidance, refer to FreeIPA’s documentation on DNS management and Microsoft’s AD DNS delegation guidelines.


### Subordinate FreeIPA Domain (`ipa.lime.abiz.com`)

- __FreeIPA Integration__: FreeIPA (Identity, Policy, Audit) is a Linux-based identity management solution 
    that can interoperate with AD via __cross-forest trusts__ or direct integration. 
    Using `ipa.lime.abiz.com` as a __subordinate domain__ under `lime.abiz.com` is a valid approach, 
    as it maintains a clear DNS hierarchy and allows FreeIPA to leverage AD's DNS for resolution.
- __Trust Relationship__: In an air-gapped network, a cross-forest trust between AD (`lime.abiz.com`) 
    and FreeIPA (`ipa.lime.abiz.com`) 
    can be established using __Kerberos__ and __LDAP__. 
    Both systems must use FIPS-validated cryptographic modules (e.g., OpenSSL in FIPS mode for FreeIPA, Microsoft's CNG for AD) 
    to meet FIPS requirements. 
    Ensure that Kerberos tickets and LDAP communications use FIPS-compliant algorithms (e.g., AES-256, SHA-256).
- __DNS Resolution__: FreeIPA requires a properly configured DNS environment. 
    The AD domain's DNS servers must host the zone for `lime.abiz.com` 
    and delegate the `ipa.lime.abiz.com` subdomain to FreeIPA's DNS servers 
    (if FreeIPA manages its own DNS). 
    This ensures seamless resolution and avoids conflicts.

### Why FreeIPA Should Manage DNS for Its Hosts

- __DNS Delegation__:
    - In a properly configured environment, the AD domain's DNS servers (for `lime.abiz.com`) delegate the `ipa.lime.abiz.com` subdomain to FreeIPA's DNS servers. This means FreeIPA's DNS server is authoritative for the `ipa.lime.abiz.com` zone, and it should manage all DNS records for hosts within that subdomain (e.g., `host1.ipa.lime.abiz.com`). 
    - This delegation ensures that FreeIPA can ___handle dynamic DNS updates___, service (`SRV`) records, and other DNS entries required for its hosts, such as those for __Kerberos__ (`_kerberos._tcp.ipa.lime.abiz.com`) and __LDAP__ (`_ldap._tcp.ipa.lime.abiz.com`).

- __FreeIPA's Integrated DNS__:
    - FreeIPA includes a __built-in DNS server__ (based on __BIND__) designed to manage DNS for its clients. When a host like `host1.ipa.lime.abiz.com` enrolls in FreeIPA, it automatically registers its DNS records (e.g., `A`, `AAAA`, `PTR`, and `SRV` records) with the FreeIPA DNS server via secure dynamic updates (using `GSS-TSIG` with Kerberos).
    - This integration simplifies management and ensures that FreeIPA-specific records (e.g., for Kerberos realms or LDAP services) are correctly maintained.

- __AD-FreeIPA Trust__:
    - In an AD-FreeIPA trust setup, AD clients resolve `lime.abiz.com` names via AD's DNS servers, while FreeIPA clients resolve `ipa.lime.abiz.com` names via FreeIPA's DNS servers. ___The trust relationship relies on proper DNS resolution___, so FreeIPA hosts must have their DNS managed by FreeIPA to avoid resolution issues.
    - For example, `host1.ipa.lime.abiz.com` needs its `A` record in the FreeIPA DNS zone to ensure FreeIPA clients and services (e.g., Kerberos, LDAP) can locate it.

- __FIPS and Security Compliance__:
    - Managing DNS records on FreeIPA's DNS server ensures compliance with security standards (e.g., FIPS) by using secure dynamic updates and supporting DNSSEC (if enabled). FreeIPA's DNS server can be configured to use FIPS-validated cryptographic modules (e.g., OpenSSL in FIPS mode) for secure operations.

### Configuration Steps

To ensure that client hosts like `host1.ipa.lime.abiz.com` have their DNS managed by the FreeIPA server:

__DNS Delegation__:

__At AD DNS host(s)__ (for `lime.abiz.com`), __create a delegation__ for `ipa.lime.abiz.com` 
pointing to the FreeIPA server's IP address. 
This is done by adding `NS` (Name Server) records for the FreeIPA DNS server in the `lime.abiz.com` zone.


```text
ipa.lime.abiz.com.  IN  NS  ipa-server.ipa.lime.abiz.com.
ipa-server.ipa.lime.abiz.com.  IN  A  192.168.1.10
```
- Where `ipa-server` is the __hostname__ of this RHEL IdM (FreeIPA) host.

__FreeIPA DNS Setup__: 

__At FreeIPA host__, enable DNS service, and configured it to manage the `ipa.lime.abiz.com` zone. 
This can be set up during FreeIPA installation or later using the command: `ipa dnszone-add`.

```bash
zone=ipa.lime.abiz.com
ipa dnszone-add $zone --name-server=$(hostname).$zone
```

__Host Enrollment__:

__At client host(s)__, When enrolling a host (e.g., `host1.ipa.lime.abiz.com`) in FreeIPA, 
use the `ipa-client-install` command with the `--enable-dns-updates` option. 
This ensures the host's DNS records (e.g., `A`, `PTR`) 
are automatically registered in the `ipa.lime.abiz.com` zone.

```bash
zone=ipa.lime.abiz.com
ipa-client-install --domain=$zone --server=$(hostname).$zone --enable-dns-updates
```


__Verify DNS Records__:

__At FreeIPA host__, confirm that the host's DNS records are correctly registered in FreeIPA's DNS zone.

```bash
zone=ipa.lime.abiz.com
ipa dnsrecord-find $zone
```

Output should include:

```text
Record name: host1
A record: 192.168.1.100
```


__Client Configuration__:

Configure clients (e.g., RHEL hosts) to use the FreeIPA DNS server (e.g., `ipa-server.ipa.lime.abiz.com`) for name resolution. 
Update `/etc/resolv.conf` or NetworkManager settings to point to the FreeIPA server's IP address.


__Additional Considerations__

- __Reverse DNS (PTR Records)__: If FreeIPA manages reverse DNS for the RFC 1918 subnet 
    (e.g., `1.168.192.in-addr.arpa` for `192.168.1.0/24`), 
    ensure the reverse zone is delegated from AD's DNS to FreeIPA's DNS. 
    This allows FreeIPA to manage PTR records for its hosts.
- __DNSSEC__: Enable DNSSEC on FreeIPA's DNS server for added security, 
    especially to meet stringent security requirements in an air-gapped network.
- __AD-FreeIPA Trust__: Ensure the trust between `lime.abiz.com` (AD) and `ipa.lime.abiz.com` (FreeIPA) is configured correctly, 
    with both domains resolving each others `SRV` records for Kerberos and LDAP. 
    This ___may require conditional forwarders or stub zones___ in AD for `ipa.lime.abiz.com`.
- __Air-Gapped Environment__: In an air-gapped network, all DNS resolution must occur internally. 
    Ensure no external DNS servers are referenced, and all DNS traffic stays within the RFC 1918 network.

# &nbsp;

<!-- 

… ⋮ ︙ • ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
☢ ☣ ☠ ¦ ¶ § † ‡ ß µ Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 🡸 🡺 ➔
ℹ️ ⚠️ ✅ ⌛ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🥇 ✨️ 🔚

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# README HyperLink

README ([MD](__PATH__/README.md)|[HTML](__PATH__/README.html)) 

# Bookmark

- Target
<a name="foo"></a>

- Reference
[Foo](#foo)

-->
