# OID / PEN / CP / CPS


## [Object Identifier (OID)](https://en.wikipedia.org/wiki/Object_identifier)

A __hierarchical__ ID scheme that provides __unique__ identifiers:

```plaintext
1               # ISO
1.3             # Identified-org (ISO/IEC 6523)
1.3.6           # DoD
1.3.6.1         # Internet
1.3.6.1.4       # Private
1.3.6.1.4.1     # IANA enterprise
1.3.6.1.4.1.343 # Intel Corporation
```
- Within __X.500__ and __LDAP__ schemas and protocols, OIDs _uniquely name_ __each attribute type and object class__, and other elements of schema.

## [Private Enterprise Number (PEN)](https://en.wikipedia.org/wiki/Private_Enterprise_Number)

__IANA__ assigns PENs to organizations [by&nbsp;request](https://pen.iana.org/pen/PenApplication.page "pen.iana.org"). 
These PENs are a foundation used by an oranization to build its internal OIDs, 
including those for certificate policies.

__OIDs__ of __PEN__: __`32473`__

```plaintext
1.3.6.1.4.1.32473             # Your organization
1.3.6.1.4.1.32473.1.1         # PKI sub-tree
1.3.6.1.4.1.32473.1.1.1001    # "High Assurance TLS Policy" for servers (manually) verified otherwise
1.3.6.1.4.1.32473.1.1.1002    # "Low Assurance Client Policy" for automated certificates
```
- Find the assigned PENs from the [IANA Registry](https://www.iana.org/assignments/enterprise-numbers/?q=)

If a CSR has extension parameter `certificatePolicies` &hellip;

```plaintext
certificatePolicies = 1.3.6.1.4.1.32473.1.1.1001
```

&hellip; OpenSSL would parse the resulting certificate  &hellip;

```bash
openssl x509 -text -in example.org.crt
```

&hellip; and report &hellip;

```plaintext
...
X509v3 Certificate Policies:
    Policy: 1.3.6.1.4.1.32473.1.1.1001
      CPS: http://pki.example.org/cps.html
...
```

## Certificate Policy (CP) Template

```plaintext
Certificate Policy for Example Corp Internal PKI  
OID: 1.3.6.1.4.1.32473.1.1.1001  
Version: 1.0  
Date: 2025-06-27  

1. Introduction
   1.1 Overview
       This Certificate Policy (CP) defines the requirements and procedures under which digital certificates are issued, managed, and used within the Example Corp internal Public Key Infrastructure (PKI).
   1.2 Document Name and Identifier
       - Policy OID: 1.3.6.1.4.1.32473.1.1.1001
       - Policy Name: Example Corp High Assurance Server Authentication Policy

2. PKI Participants
   2.1 Certification Authorities
       - Root CA (offline)
       - Intermediate CA(s) (online, used for signing end-entity certificates)
   2.2 Registration Authorities (RA)
       - Designated security team members who validate identity prior to issuance
   2.3 Subscribers
       - Servers and services within the Example Corp network
   2.4 Relying Parties
       - Systems within Example Corp that validate certificates

3. Certificate Usage
   3.1 Appropriate Usage
       - Server authentication (e.g., TLS for internal services)
   3.2 Prohibited Usage
       - Code signing, client authentication, or external/public use

4. Policy Administration
   4.1 Organization Administering the Document
       - Example Corp Security & Compliance Department
   4.2 Contact Information
       - pki-admin@example.org

5. Identification and Authentication
   - Identity is confirmed through the corporate asset inventory and CMDB records.
   - Authentication by asset ownership and MAC address validation.

6. Certificate Lifecycle Management
   6.1 Certificate Application
       - Via automated CSR interface or manual submission
   6.2 Certificate Issuance
       - After identity verification
   6.3 Certificate Renewal/Rekey
       - Allowed 30 days prior to expiration
   6.4 Certificate Revocation
       - On compromise, decommission, or policy violation

7. Physical, Procedural, and Personnel Security Controls
   - Root CA stored offline
   - Access controlled to signing infrastructure
   - Key custodians are background-checked personnel

8. Technical Security Controls
   - RSA ≥ 3072-bit or EC P-256
   - SHA-256 or higher
   - Keys generated in secure HSM or TPM devices for the CA

9. Certificate and CRL Profile
   - Standard X.509 v3
   - CRLs and OCSP available via HTTP
   - Policy OID included in `certificatePolicies` extension

10. Compliance Audit
   - Annual internal audit of PKI operations
```

## Certification Practice Statement (CPS) Template

```plaintext
Certification Practice Statement for Example Corp Internal PKI  
Applies to: OID 1.3.6.1.4.1.32473.1.1.1001  
Version: 1.0  
Date: 2025-06-27  

1. Introduction
   - This CPS details the technical and procedural practices followed to implement the Example Corp CP (OID 1.3.6.1.4.1.32473.1.1.1001).

2. Certificate Issuance
   - Requests are submitted via a secure portal or API
   - Manual validation includes asset owner contact, DNS control, and configuration checks
   - Certificates are signed by intermediate CAs using hardware-backed private keys

3. Private Key Protection
   - Root CA keys are stored on air-gapped USB HSM
   - Intermediate CA keys are stored on network-isolated YubiHSM
   - Access requires quorum of 2 authorized operators

4. Certificate Revocation
   - Revocation initiated on reported compromise or incident escalation
   - CRLs are published hourly; OCSP responders refreshed every 15 minutes

5. Logging and Monitoring
   - All CA and RA activity logged to centralized SIEM
   - Logs retained for 7 years

6. System Security Controls
   - CA infrastructure runs on hardened RHEL VMs
   - SSH access restricted via LDAP group and 2FA
   - Software stack includes HashiCorp Vault, OpenSSL, and cert-manager

7. Business Continuity
   - Root CA recovery documented and tested quarterly
   - Intermediate CA backed up and replicated to warm standby

8. Compliance
   - Internal audits are conducted yearly
   - Based on NIST SP 800-57 and CAB Forum guidelines

9. Document Control
   - This CPS is reviewed annually or after significant change
   - Change requests must be approved by PKI governance board

```

---

<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# … ⋮ ︙ • “” ‘’ – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × € ¢ £ ¤ ¥ ₽ ♻ ⚐ ⚑
# ☢ ☣ ☠ ¦ ¶ § † ‡ ß µ ø Ø ƒ Δ ⚒ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖ ☘ 웃 𝐀𝐏𝐏 𝐋𝐀𝐁
# ⚠️ ✅ 🚀 🚧 🛠️ ⚡ ❌ 🔒 🧩 📊 📈 🔍 🧪 📦 🔧 🧳 🥇 💡 ✨️ 🔚

# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>


-->
