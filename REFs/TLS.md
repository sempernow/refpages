# TLS (Formerly SSL) | [Wikipedia](https://en.wikipedia.org/wiki/Transport_Layer_Security "Wikipedia") | [RFC-6066](https://www.rfc-editor.org/rfc/rfc6066 "IETF.org") | [TLS 1.3](https://www.rfc-editor.org/rfc/rfc8446 "RFC-8446") | [TLS 1.2](https://www.rfc-editor.org/rfc/rfc5246 "RFC-5246")


## Overview

TLS/SSL, "Transport Layer Security" FKA "Secure Socket Layer", is a trust-based PKI (Public Key Infrastructure) scheme of HTTPS protocol, extending HTTP to secure the internet. The server sends a single cryptographically-generated certificate if signed by a root CA, else a chain of them. The client application validates each server certificate against the Certificate Authority (CA) that supposedly signed it.

Nominally, the client application has access to a **trust store** containing a list of trustworthy-CA certificates, which it uses to verify the (supposedly) CA-signed server certificate or chain of certificates. CAs are hierarchical, with intermediate-CA certificates forming a chain of trust from end-entity (server) certificate to the [root (CA) certificate](https://en.wikipedia.org/wiki/Root_certificate). 

>A certificate's `Issuer` is the CA that signed that `Subject` certificate, so the root (CA) is always self-signed. However, the term "_self-signed_" more often references an end-entity certificate created sans CA. These are somewhat useful, but only for test/dev purposes. Care must be taken even within that scope because browsers and other clients respond entirely differently when the end-entity (server) certificate sent during the TLS handshake does not validate against any client-trusted CA.

**POSIX**-type operating systems have a directory of such certificate files. **Linux** stores them in the **`/etc/ssl/certs`** directory. The **`ca-certificates.crt`** file contains a concatenated list of such certificates. Other CA root-certificate files (`*.crt`) may exist in that directory as standalones, e.g., `root-ca-site.local.crt` .

**Windows** has an entirely different scheme of course; `Certificates.msc`

### TLS Handshake 

[HTTPS is an extention of HTTP](https://en.wikipedia.org/wiki/HTTPS). An HTTPS connection starts with a TLS client/server handshake whereof the certificate is sent/validated and the TLS parameters (cipher suite and such) are set (negotiated if allowed). Otherwise, the TLS-handshake fails and the connection is terminated. 

#### __What it verifies__

1. __Certificate Chain Validation__  
    Is the server's certificate trusted and valid?  
    Client checks: 
    - CA signature
    - Expiration
    - Revocation
    - Domain match
2. __Proof of Private Key Possession__  
    Does the server control the private key?  
    The client/server key exchange fails if not.  
    (_This is the part most people miss._)  

#### __How it works__

      Client                 Server
        |----ClientHello ----->|
        |<--- ServerHello -----|
        |<--- Certificate -----|  (public cert, anyone can send)
        |<--- ServerKeyExchange|  (signed with *private key*)
        |ClientKeyExchange---->|  (encrypted with *public key*)
        |<--- Finished --------|  (proves session key works)
        |---- Finished ------->|


>**On TLS-handshake failure**, the server is likely to send a "handshake failure" alert. Such may occur if the certificate's CA cannot be validated by the client, or ***if client and server have no mutually supported TLS-ciphers suite***. The TLS handshake failure is not an HTTP-level response; it's part of the TLS protocol. The HTTP layer comes into play only after a secure TLS connection has been established. If the TLS handshake fails, the HTTP layer doesn't have an opportunity to send an HTTP response code because the connection hasn't been established.

## OpenSSL 

The industry-standard library and its CLI utility for all things TLS. 

The OpenSSL utility, [`openssl`](https://www.openssl.org/), is a multi-purpose tool used to create, parse, validate, convert formats, and test TLS keys, certificates, and such. 

### References:

- Manual (`man`) pages are available for each `openssl <command>` at `man openssl-<command>`. 
- For the list of available `openssl` commands (by category), simply run: `openssl`.
- [`TLS.openssl.sh`](TLS.openssl.sh)  
- [RFC 6125](https://datatracker.ietf.org/doc/html/rfc6125) Identity (DNS names) regarding X.509 certificates.

## Glossary

### Transport Layer Security (TLS)

Transport Layer Security is the newer security protocol that ***replaced Secure Sockets Layer (SSL)***. Though the SSL protocol is obsolete and has been so for about a quarter century, the term "SSL" stubbornly remains with us, e.g., "OpenSSL". Engineers often refer to TLS as SSL, while actual SSL (protocols, ciphers, certificates and keys) are extremely insecure and entirely inadequate. Never use actual SSL.


### [X.509](https://en.wikipedia.org/wiki/X.509 "Wikipedia")

A standard that defines the format of public key certificates. These certificates are used in various security and networking protocols, including TLS/SSL, which is the basis for secure connections on the internet. The X.509 standard is part of the X.500 series of standards defined by the ITU-T (International Telecommunication Union Telecommunication Standardization Sector) for the Directory Services.

The X.509 certificate standard uses [__ASN.1__](https://en.wikipedia.org/wiki/ASN.1) (Abstract Syntax Notation One) to define the data structure and Distinguished Encoding Rules (DER) to specify how that data is serialized into a binary format. This means ASN.1 provides the "what" (the data types and their relationships) and DER provides the "how" (the specific rules for converting those types into a consistent, unambiguous byte stream for storage and transmission). 

Features of X.509 certificates include:

- Public Key: The certificate includes the public key of the certificate holder.
    Identity Information: It contains identity information about the holder, such as the common name (`CN`), organization (`O`), and country (`C`). This information is used to verify the identity of the entity presenting the certificate.
- Issuer: The certificate specifies the issuing CA that has signed and issued the certificate, thus vouching for its authenticity.
- Serial Number: Each certificate issued by a CA is given a unique serial number to distinguish it from other certificates.
- Validity Period: Certificates are valid for a specific period, indicated by the "`Not Before`" and "`Not After`" dates. The certificate should not be considered valid before or after this period.
- Digital Signature: The issuing CA digitally signs the certificate to prove its authenticity. The signature can be verified using the CA's public key.

X.509 certificates play a crucial role in establishing trust in digital communications. By verifying the ***chain of trust*** from a given certificate up to a trusted root CA, entities can establish secure communication channels. This trust model underpins the security of HTTPS websites, email encryption (S/MIME), and many other protocols that secure data exchange over networks.


### Encodings v. Formats

- **Encoding**: The method by which data is transformed into a specific format. Encoding does not necessarily imply any particular data structure. Example: Base64 encoding, which converts binary data into ASCII characters.
- **Format**: A structured arrangement of data, usually specified by standards that define the exact way data should be organized. In cryptography, formats often dictate how keys, certificates, and encrypted messages should be structured. Example: The PKCS#12 format, which defines a way to store a private key and a certificate, optionally with additional metadata and/or encryption.

Reference: 

- `man openssl-format-options`

<a name=der></a>

#### DER (Distinguished Encoding Rules) 

A **binary encoding** scheme; a subset of BER ([X.690](https://en.wikipedia.org/wiki/X.690 "Wikipedia.org")) that eliminates some of the superset's flexibility to guarantee there is one and only one way to encode a message. That is, to encode, decode, re-encode, re-decode, and re-re-encode a DER message, all those encodings remain identical. 

DER is commonly used in security-related applications such as X.509 digital certificates (and keys). Common extensions are: `.crt`, `.cer`, and `.der` if a public certificate; `.key` if a private key, so ***do not rely on the file's extension*** to indicate format. Not many applications require DER formatted certificates or keys, but this binary form is useful for conversions between otherwise incompmatible ASCII-based encodings.

```bash
# Convert format: DER to PEM (From binary to human-readable text) 
openssl x509 -inform der -in certificate.der -outform pem -out certificate.pem

# Convert format: PEM to DER (From human-readable text to binary) 
openssl x509 -in certificate.pem -outform der -out certificate.der

```

#### [PEM](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail "Wikipedia.org") (Privacy Enhanced Mail)

**Base64 encoded** ([ASCII](https://en.wikipedia.org/wiki/ASCII "Wikipedia.org")) file format. PEM is the most common "format" (encoding) for TLS certificate and key files; widely used in web servers and other network applications where textual (ASCII) configuration files are standard. Common extensions for PEM files are: `.crt`, `.cer`, and `.pem` if the document is a public certificate; `.key` if it's a (private) key. However, **do not rely on the filename extension to indicate its actual format**. A `*.pem` *may (also) contain a key*.

>Many cryptography standards use [ASN.1](https://en.wikipedia.org/wiki/ASN.1) Interface Description Language (IDL) to define their data structures, and [DER](#der) to serialize those structures. Because DER produces binary output, it can be challenging to transmit the resulting files through systems, like electronic mail, that only support ASCII. PEM solves that.

PEM *certificates* include a header and footer:

```text
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
```

A *certificate* file may contain many such concatenated certificates. The most common certificate files are those of either a list of root CA certificates AKA trust-store AKA ca-bundle file, or a certificate chain AKA full-chain certificate. The latter is commonly referred to as the "server certificate". 

The full-chain (of trust) certificates must be properly ordered, whereof the first cerificate is that of the end-entity (server). Each cerificate thereafter is that of the prior's Issuer; the CA that signed (and therefore validates) the preceding certificate. This chain goes all the way back to, but not (typically) including, the root-CA certificate. 

That root-CA certificate is expected to be in the clients' trust store. The root-CA certificate is distinguished by having *identical* Subject and Issuer, AKA it is a Self-signed Certificate of a trustworthy Certificate Authority.

Many command-line tools, including OpenSSL's (`openssl`), read PEM files. It is especially common in Unix/Linux environments. 
 
#### JKS (Java KeyStore)

A proprietary file format developed by Oracle for storing cryptographic keys and certificates securely. 
It is primarily used in Java applications to manage and secure keys and certificates for TLS and other uses 
(Document Signing, Software Integrity Checking, Internal Communications, &hellip;).

- Structure: JKS files contain one or more keys or certificates, and the file itself is protected by a password. 
  Each entry in a JKS file is also individually password-protected.
- Format: The JKS file format is a **binary** format specifically designed for use within Java applications. 
  It is not readable as plain text and is not based on any standard encoding rules; **JKS is not DER** encoded.

Also, take care to not mistake JKS with similar acronyms regarding the unrelated JSON-formatted PKI, such as JWKS, JWK, &hellip;.

#### [PKCS](https://en.wikipedia.org/wiki/PKCS "Wikipedia.org") (Public-Key Cryptography Standards)

PKCS encompasses **a group of standards**, including specifications for various formats and protocols designed for secure cryptographic communication; encrypted data, private keys, and public key certificates, among other things. 

##### PKCS#1

Defines the format for RSA encryption and signing. 
It specifies how to encode data for signing or encryption with RSA.

##### [PKCS#7](https://en.wikipedia.org/wiki/PKCS_7)/P7B/CMS

A standard ([RFC-5652](https://datatracker.ietf.org/doc/html/rfc5652 "IETF.org")) for encryption and signing, suitable for messages like signed or encrypted emails. It defines **a general syntax** for data that may have cryptography applied to it, such as digital signatures and encryption. It is widely used in various security and cryptographic applications. This standard is versatile, supporting not only encryption and digital signatures but also other enhancements like data compression and certificate dissemination.

This format __does not contain any key__. 
One or more Base64 ASCII __certificates__ are stored in a __`.p7b`__ or `.p7c` file. 
The format is commonly used in __Windows__ and __Java__ applications. 

Windows Server's Certificate Services (__AD CS__) returns the __fullchain certificate__ (per approved CSR) as `*.p7b` having that (PKCS#7) format. 

```bash
## Convert from P7B to PEM
openssl pkcs7 -print_certs -in input.p7b -out output.pem
```

##### [PKCS#8](https://en.wikipedia.org/wiki/PKCS_8)

Specifies the **private key** information syntax, which is a format for storing private keys;
both encrypted and unencrypted forms.

##### PKCS#10/[CSR](https://en.wikipedia.org/wiki/Certificate_signing_request)

A format regarding [Certificate Signing Request](https://en.wikipedia.org/wiki/Certificate_signing_request "Wikipedia.org") (__CSR__) data structure, for requesting certificates from a CA. It specifies what information the CSR contains and how that information is organized. This ([ASN.1](https://en.wikipedia.org/wiki/ASN.1 "Wikipedia.org")) format is recognized universally and is the standard format for CSRs regardless of the software or platform being used. The file may be in either DER or PEM format. Common filename extensions for a CSR are __`.csr`__, `.pem` and `.der`.

##### [PKCS#12](https://en.wikipedia.org/wiki/PKCS_12 "Wikipedia.org")/PFX/P12

A **binary archive-file format** for storing many cryptographic objects (__certificates and key__) in a single password-protected file, each in a *SafeBag* (container); successor to Microsoft's PFX. Common filename extensions are `.pfx` and `.p12`. Often used in Java applications and across Windows machines. Code-signing certificates stored in PFX are also often used for signing with __Microsoft Authenticode__.

Characteristics and uses of PKCS#12 include:

- Secure Storage and Transport: PKCS#12 files provide a means for secure storage and transport of a user’s certificates and private keys across different systems or applications.
    Interoperability: Due to its standardization, PKCS#12 files are supported by a wide range of software and devices, including web servers, email clients, and VPN clients, facilitating interoperability between different systems and platforms.
- Encryption: The contents of a PKCS#12 file, including private keys, certificates, and other sensitive information, can be encrypted with a password. This encryption uses strong cryptographic algorithms to protect the contents from unauthorized access.
- Bundling: A single PKCS#12 file can contain multiple certificates and keys, making it easier to manage and deploy a complete cryptographic identity or chain of trust. This is particularly useful for SSL/TLS certificates, where a server certificate must be installed along with its corresponding private key and any intermediate certificates.

##### [CMC](https://en.wikipedia.org/wiki/Certificate_Management_over_CMS "Wikipedia.org") (Certificate Management over CMS)

A standard ([RFC-5272](https://datatracker.ietf.org/doc/html/rfc5272 "IETF.org")/[RFC-5273](https://datatracker.ietf.org/doc/html/rfc5273 "IETF.org")) for certificate management that allows for various operations, including requesting certificate issuance, renewal, and revocation. 

A CMC-formatted CSR is essentially a more complex and versatile request format compared to the traditional PKCS#10 CSR. It is designed to support a wider range of certificate management functions and to facilitate more sophisticated interactions between entities requesting certificates (clients) and the entities issuing them (CAs).

CMC-formatted CSRs are particularly useful in environments requiring **advanced certificate management capabilities**, especially where multiple certificate-related operations need to be performed in a streamlined and secure manner. Due to its complexity and advanced features, CMC is **often used in enterprise environments**, in systems with large-scale certificate management needs, or in scenarios requiring **automated certificate lifecycle management**.

[CMC @ RHEL](https://access.redhat.com/documentation/en-us/red_hat_certificate_system/9/html/administration_guide/issuing_certificates_using_cmc "redhat.com")

### Key

AKA Private Key; the private artifact of an asymmetric (public-private) key pair creation. The server's key is private; a secret that must be well protected, never shared, and sufficiently rotated. The public artifact is the server's certificate.

### [Certificate](https://en.wikipedia.org/wiki/Public_key_certificate "Wikipedia.org")

AKA Public Key Certificate, which is composed of the public artifact (AKA Public Key) of an asymmetric (public-private) key pair creation, plus metadata extracted from the CSR. The certificate is public; presented by a web server whenever a new TLS connection is requested. The certificate contains its Subject host name (FQDN), which must match the FQDN of server sending it, and the Issuer. 

The certificate's Issuer is the CA that signed it. Every CA has a certificate, which is used to verify the server's CA-signed certificate.  If the Issuer is not a Root CA, then it must be an Intermediate CA, and so the chain of trust may continue until the Root-CA certificate is obtained and used to verify the signature of the preceding Intermediate-CA certificate in the chain of certificates sent to the client. All such cert bundled into one file and typically referred to simply as the "server certificate".

#### SAN (Subject Alternative Name)

Extension for **CN** (Common Name) AKA Domain Name; a field of a certificate that indicates for which domain(s) the certificate is valid. A single certificate may contain many SANs. That is, may be valid for many different domain names. 

#### Wildcard Certificate

The asterisk character (`*`) is the wildcard, and can be substituted with any valid hostname. Instead of being issued for a specific Fully Qualified Domain Name (FQDN), such as `app.example.com`, wildcard certs are valid for a whole range of subdomain names. So a cert issued to `*.example.com` would cover `app.example.com` and `cdn.example.com`, yet *not* `other.cdn.example.com`. 

### [Certificate Authority](https://en.wikipedia.org/wiki/Certificate_authority "Wikipedia.org") (CA)

A certificate authority verifies details about a domain owner’s request for certificates. Only after validating the certificate-signing request (CSR) do CAs sign and issue the server certificate; typically returning the full-chain (of trust) certificate. Browsers and operating systems maintain a list of trusted certificate authorities. If a server certificate is signed by one of these trusted CAs, it will also be trusted. There are several organizations and forums that maintain lists of trustworthy CAs; it is fragmented.

#### [Full-Chain Certificate](https://en.wikipedia.org/wiki/X.509#Certificate_chains_and_cross-certification)

AKA "server certificate" AKA "certificate chain" file. 

A "full chain" certificate refers to a certificate file containing the entire ***chain of trust***; the end-entity (server) certificate and all the intermediate certificate(s) up to, but not icluding, the root CA certificate. This chain of certificates helps establish trust from the end-entity certificate back to a trusted root certificate authority (CA). Most CAs default to this "bundle" or "full chain" option when delivering certificates. 

Order matters. The first certificate listed is that of the end-entity (server). The second certificate (intermidiary) is that of the CA that signed (and therefore can verify) the 1st, the 3rd verifies the 2nd, and so on. So, the last (Nth) intermidate certificate would be validated by the root CA, which must reside in clients' (TLS) trust store.

>__Certificate Chain Trust__: The server is responsible for sending its own certificate and any intermediate certificates necessary to form a complete path to a root certificate trusted by clients. The inclusion of intermediate certificates is ***crucial because clients might not have them***, *unlike root certificates, which are expected to be pre-installed in clients' trust store*.

```bash
# Get the (full-chain) certificate of a server ($h) at its port ($p)
h='google.com' # Host
p='443'        # Port
openssl s_client -connect $h:$p -showcerts < /dev/null > ${h}_${p}.full-chain.crt

# Verify the server's ca-signed certificate ($any.crt) against the CA ($ca.crt) that signed it
# (The CA file may be a trust-store bundle; a concatenated list of CA certs in PEM format.)
openssl verify -CAfile $ca.crt $any.crt
```

### Certificate hierarchy:

- **End-entity certificate**: This is the certificate that corresponds to the specific domain for which the certificate is issued. It contains the public key for the server and is signed by an intermediate CA.

- **Intermediate certificate(s)**: Intermediate certificates sit between the end-entity certificate and the root certificate in the certificate chain. They are used to enhance security by creating a hierarchy of trust. The intermediate certificate is signed by a root CA and, in turn, signs the end-entity certificate.

Intermediate Certificate (example)

`CN: GTS CA 1C3`

```text
...                                         
 1 s:C = US, O = Google Trust Services LLC, CN = GTS CA 1C3          
   i:C = US, O = Google Trust Services LLC, CN = GTS Root R1         
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256             
   v:NotBefore: Aug 13 00:00:42 2020 GMT; NotAfter: Sep 30 00:00:42 2
-----BEGIN CERTIFICATE-----                                          
MIIFljCCA36gAwIBAgINAgO8U1lrNMcY9QFQZjANBgkqhkiG9w0BAQsFADBHMQsw     
...     
1IXNDw9bg1kWRxYtnCQ6yICmJhSFm/Y3m6xv+cXDBlHz4n/FsRC6UfTd             
-----END CERTIFICATE-----                                            
```
- Note that Subject (`s:`) and Issuer (`i:`) differ.
    - `s:..., CN = GTS CA 1C3`
    - `i:..., CN = GTS Root R1`
        - Root cerficate is "`GTS Root R1`", 
          and it is not included in this full-chain certificate.

- **Root certificate**: The root certificate is the top-level certificate in the hierarchy and is self-signed. (Subject, "`s:`" and Issuer "`i:`" are the same entity.)  It is the ultimate authority that establishes trust in the entire chain. Web browsers and other client applications come pre-installed with a set of trusted root certificates.

When a client, such as a web browser, connects to a server secured with SSL/TLS, it checks the certificate chain to ensure that the end-entity (server) certificate is valid and signed by a trusted intermediate certificate, which, in turn, is signed by a trusted root certificate. That is, the client must have its own set of trusted-CA certificates, or use that of the system (OS) in which it is running, against which to validate the server's certificate.

Including the full chain when configuring SSL/TLS on a server is important to ensure that clients can validate the server's certificate properly. Without the full chain, clients may not be able to establish the chain of trust, and the connection could be deemed untrusted. 

### [CRL](https://en.wikipedia.org/wiki/Certificate_revocation_list "Wikipedia.org") (Certificate Revocation List)

Certificates may include information on how to access a certificate revocation list. 
Clients will download and check this list to make sure the certificate has not been revoked. 
The CRL is a list or database of TLS certificates (serial numbers) that have been revoked by the issuing CA before their scheduled expiration date and should no longer be trusted. 


The CRL method is __plagued by several key limitations__ 
that make it less effective for modern, large-scale internet use:

- __Latency and performance issues__: The CRL file could be very large, especially for major CAs that issued millions of certificates. The need to download and parse this potentially massive file every time a client needed to check a certificate caused significant delays during the TLS handshake.
- __Stale information__: CAs only published new CRLs at regular, predefined intervals (e.g., every 24 hours). This created a "window of vulnerability" where a certificate could be revoked but remain usable until the next CRL was published and downloaded by clients.
- __Scalability problems__: The original CRL architecture did not scale well with the explosive growth of the internet. The network traffic and server load involved with millions of clients downloading large CRL files became a major strain on the CA infrastructure.
- __"Soft-fail" behavior__: Many browsers were configured to "soft-fail" the CRL check if they couldn't reach the CDP to download the list. Rather than halting the connection, they would proceed anyway, leaving users vulnerable if a malicious actor blocked the CRL download. 

__CRLs are slowly being depricated__ as alternate certificate revocation technologies (such as OCSP responders) are increasingly used instead. __Nevertheless, CRLs are still widely used__ by CAs.

### [OCSP](https://en.wikipedia.org/wiki/Online_Certificate_Status_Protocol "Wikipedia.org") (Online Certificate Status Protocol)

OCSP is an internet protocol ([RFC-6960](https://datatracker.ietf.org/doc/html/rfc6960 "IETF.org")) allowing applications to check the revocation status of a certificate in real-time without needing to download and parse a CRL. 

The OCSP protocol is a TLS extension; **a replacement for CRLs**, with the benefits of being more real-time and requiring less bandwidth. However, OCSP also introduces its own complexities, such as the need for additional infrastructure to handle real-time requests. 

Clients query the OCSP responder to check if a certificate has been revoked. Like end-entity (server) certificates, the OSCP response is also cryptographically signed and has its own chain of trust, so clients may verify it regardless of how it arrives. This allows for __OSCP Stapling__.

#### [OSCP Stapling](https://en.wikipedia.org/wiki/OCSP_stapling "Wikipedia.org")

Formally known as the *TLS Certificate Status Request* extension ([RFC&#x2011;6066](https://datatracker.ietf.org/doc/html/rfc6066#section-8 "IETF.org")), OSCP Stapling is __a standard for checking the revocation status of X.509 digital certificates__. 

This is how it works: 

The server routinely queries the OCSP responder, and then "staples" the response to its TLS-handshake response per client connection. So, the server bears the resource cost involved in providing revocation status. This method reduces the performance impact, alleviates privacy concerns, and ensures that clients receive up-to-date revocation information without requiring separate OCSP queries.

### Domain Validation (DV)

A domain validated certificate will be issued to somebody who has proven they control the domain name requested for the certificate. This proof often takes the form of serving a unique token from your web server or DNS records, which the CA will check for before issuing the certificate.

### Organization Validation (OV)

An organization validated certificate means that the certificate authority also verified the company name and address in public databases. This information is put into the certificate, and is typically displayed only when the user clicks the green padlock icon to investigate further.

### Extended Validation (EV)

Extended validation is ***more thorough than domain or organization validation***. EV certificates are issued after checking not only domain ownership, but also verifying the existence and location of the legal entity requesting the certificate, and that said entity controls the domain being verified.

Unlike DV and OV certificates, EV cannot be issued as a wildcard certificate.

EV certificate also ***gets special treatment in web browsers***. Whereas browsers typically denote a DV certificate with a ***green-padlock icon***, EV certificates also show a larger green bar containing the name of the organization it was issued to. This is intended to reduce phishing attacks, though some studies show that users tend not to notice when this green bar is missing.


## Intermediate CA

When creating an Intermediate Certificate Authority (CA) to scope its authority to a specific subset of CIDRs, IPs, 
hostnames, or other identifiers, you need to carefully configure the certificate's extensions and constraints. 
Here are the key parameters and considerations:

How to configure an Intermediate CA using OpenSSL:

1. **OpenSSL Configuration File** (`openssl.cnf`):

```ini
[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:TRUE, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
nameConstraints = critical, permitted;DNS:example.com, permitted;IP:192.168.1.0/24
```
- Set **Basic Constraints** to define CA capabilities and path length.
    - Indicate that the certificate is for a CA (`CA: TRUE`).
    - Specify the maximum depth of subordinate CAs allowed (`pathlen`):
        - `pathlen:0` means the Intermediate CA can only issue end-entity certificates (no further subordinate CAs).
        - `pathlen:1` allows one level of subordinate CAs.
- Configure **Key Usage** appropriately.
   - Ensure the `keyCertSign` and `cRLSign` bits are set for CA certificates.
    - **Extended Key Usage** (optional):
        - Limit the purposes for which the Intermediate CA can issue certificates (e.g., server authentication, client authentication).
- Use the **Name Constraints** extension to limit DNS names, IP ranges, etc.
   - This is __the primary mechanism__ to limit the scope of an Intermediate CA's authority.
   - It can restrict the CA to issuing certificates for specific:
     - **DNS names** (e.g., `example.com`, `*.example.com`)
     - **IP addresses** (e.g., `192.168.1.0/24`, `10.0.0.0/8`)
     - **Email addresses** (e.g., `@example.com`)
     - **Directory names** (e.g., distinguished names in LDAP)
   - **Syntax**:
     - `permittedSubtrees`: Specifies allowed names or IP ranges.
     - `excludedSubtrees`: Specifies explicitly excluded names or IP ranges.
   - Example:
     - To allow only `*.example.com` and `192.168.1.0/24`:
       ```plaintext
       permittedSubtrees:
         - DNS: example.com
         - IP: 192.168.1.0/24
       ```
     - To exclude `*.internal.example.com`:
       ```plaintext
       excludedSubtrees:
         - DNS: internal.example.com
       ```
- Optionally, define **Certificate Policies** and ensure proper revocation mechanisms.

2. **Generate the Intermediate CA Certificate**:

```bash
openssl req -new -key intermediate.key -out intermediate.csr
openssl x509 -req -in intermediate.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out intermediate.crt -days 365 -extfile openssl.cnf -extensions v3_intermediate_ca
```

## Projects

### @ [Docker/Nginx](https://docs.docker.com/engine/swarm/configs/ "docs.docker.com/swarm/configs") 

- Create: [`TLS.openssl.sh`](TLS.openssl.sh)
- Deploy: [`stack-nginx.yml`](stack-nginx.yml)

### [`mkcert`](https://github.com/FiloSottile/mkcert) (HTTPS @ `localhost`)

A simple tool for making locally-trusted development certificates. 
It requires no configuration. 
Worthless @ Windows 10. 

#### @ Windows/WSL (Golang/cURL)

 [Add a self-signed CA (`root-ca.crt`) to Windows 10](https://zeropointdevelopment.com/how-to-get-https-working-in-windows-10-localhost-dev-environment/). 

##### FAIL: 

- `x509 Certificate Signed by Unknown Authority` (Golang)
- `(60) SSL certificate : unable to get local issuer certificate` (cURL)

##### FIX:

1. Generate both a CA root certificate and the server's certificate using `openssl`
    - Use `Makefile` recipes @ `uqrate/v1/assets/keys/tls/openssl/`
2. Per OS:
    - @ Linux
        - Either append the content of the CA's root certificate file (`root-ca.crt`) to `ca-certificates.crt` file of the `/etc/ssl/certs/` directory, or copy the file itself to that directory. 
            ```bash
            sudo vim /etc/ssl/certs/ca-certificates.crt
            ```
            - @ XPC, `root-ca-swarm.foo.crt` is a standalone file under `/etc/ssl/certs`.
            - @ HTPC, the content of that certificate is appended to `ca-certificates.crt` file.
    - @ Windows
        - `Certificates.msc` : Local Machine or Current User
            - Note that `WSL` apps don't use Windows certs store ~~@ HTPC configuration, Adding CA (openssl) @ Current User failed to fix either Golang or cURL failure. Then, added to Local Machine, but that failed to fix issue @ cURL (Golang untested). Then appended to WSL's  certs file (above method), and that fixed at both cURL and Golang. BTW, "Golang" means `go run ...`; was reporting `x509 Certificate Signed by Unknown Authority`.~~
            - Open per `Win+R` > MMC > File > Add/Remove Snap-in > Certificates > Trusted Root Certification Authorities > All Tasks > Import
                - Import: `root-ca.crt`
            - @ PowerShell; ___alt method___; effectiveness is unknown.
                ```powershell
                Import-Certificate -FilePath "root-ca.crt" -CertStoreLocation Cert:\LocalMachine\Root
                ```
        - @ Firefox, mod required to enable the newly added root certificate
            - [Add CA @ Firefox](https://support.mozilla.org/en-US/kb/setting-certificate-authorities-firefox)
                - `about:config` 
                    - `security.enterprise_roots.enabled` : `true`

### [`acme.sh`](https://github.com/acmesh-official/acme.sh) 

#### TL;DR

- Get cert via automated DNS-01 challenge
- List of CAs that `acme.sh` handles : [URL and "Short Name"](https://github.com/acmesh-official/acme.sh/wiki/Server) 

#### HowTo

```bash
domain='target.tld'
len='4096'    # @ RSA
len='ec-384'  # @ Elliptic Curve
AWS_ACCESS_KEY_ID="AKI..."
AWS_SECRET_ACCESS_KEY="58X...mdS"

acme.sh --issue --server letsencrypt --dns dns_aws --ocsp-must-staple --keylength $len -d "$domain" -d "*.$domain"
```
- See `~/.acme.sh/account.conf`
    - Stores AWS creds that it reads from environment.
- [OCSP Stapling](https://en.wikipedia.org/wiki/OCSP_stapling) is [broken](https://blog.hboeck.de/archives/886-The-Problem-with-OCSP-Stapling-and-Must-Staple-and-why-Certificate-Revocation-is-still-broken.html) (@ Nginx and Apache)
- `HTTP-01` challenge type : [Stateless Mode : `--stateless`](https://github.com/acmesh-official/acme.sh/wiki/Stateless-Mode); requires a running, challenge-configured server.
    ```bash
    # 1. Get account thumbprint 
    # Servers (per CA): https://github.com/acmesh-official/acme.sh/wiki/Server
    acme.sh --register-account --config-home  /acme.sh/ca \
        --server https://acme-staging-v02.api.letsencrypt.org/directory

    [Tue Jul 27 21:24:11 UTC 2021] Create account key ok.
    ...
    [Tue Jul 27 21:24:12 UTC 2021] ACCOUNT_THUMBPRINT='Wcb...xfY'

    # 2. Configure (Nginx) web server endpoint: <DOMAIN>/.well-known/acme-challenge/<TOKEN> 
    #    that responds with string: <TOKEN>.<ACCT_THUMBPRINT> 
    server {
        ...
        location ~ ^/\.well-known/acme-challenge/([-_a-zA-Z0-9]+)$ {
            default_type text/plain;
            return 200 "$1.Wcb...xfY";
        }
        ...
    }

    # 3. Get cert by stateless (HTTP-01) challenge:
    acme.sh --issue -d ... --stateless
    ```
    - AWS-credentialed bot-user (@ `acme.sh`) must have AWS role/policy 
      required to perform the DNS-01 challenge
- [@ Docker](https://github.com/acmesh-official/acme.sh/wiki/Run-acme.sh-in-docker) 
- [@ Nginx : Alpine Linux](https://www.cyberciti.biz/faq/how-to-install-letsencrypt-free-ssltls-for-nginx-certificate-on-alpine-linux/ "cyberciti.biz 2020") | [Using `acme.sh`](https://www.cyberciti.biz/faq/route-53-lets-encrypt-wildcard-certificate-with-acme-sh/) |
    - [Setup Nginx as reverse proxy with TLS, per `acme.sh` (@ `letsencrypt`)](https://wiki.alpinelinux.org/wiki/Nginx_as_reverse_proxy_with_acme_(letsencrypt) "wiki.alpinelinux.org @ 2017")


### [Certbot](https://certbot.eff.org/docs "certbot.eff.org") | [certbot @ Docker](https://certbot.eff.org/docs/install.html#running-with-docker) | [`certbot-dns-route53`](https://certbot-dns-route53.readthedocs.io/en/stable/) | [+DNS Provider plugin](https://hub.docker.com/u/certbot "@ Docker Hub")

Certbot is the client advised by `letsencrypt.org`; we used `acme.sh` instead only because its Docker image was better advertised. Certbot @ docker should perform as well. Both automate the cert request and the DNS-01 challenge per suitable DNS providers (both handle AWS/Route53) 

>The dns_route53 plugin automates the process of completing a `dns-01` challenge (`DNS01`) by creating, and subsequently removing, `TXT` records using the Amazon Web Services Route 53 API.

- Gets certs from `letsencrypt.org`
    - `privkey.pem` : SECRET; Private key for the certificate.
    - `fullchain.pem` : All certificates, including server certificate (aka leaf certificate or end-entity certificate). The server certificate is the _first one_ in this file, followed by any intermediates.
    - `cert.pem` : server certificate
        - `chain.pem` (if intermediate certs)
- [Location of certificates](https://certbot.eff.org/docs/using.html#where-certs)
    - `/etc/letsencrypt/live/$domain` : symlinks to current versions
    - `/etc/letsencrypt/archive` : previous versions
    - `/etc/letsencrypt/keys` : previous versions 
- `dns_route53` plugin | Docker image : [`certbot/dns-route53`](https://hub.docker.com/r/certbot/dns-route53)
    - Automates the process of completing a `dns-01` challenge by creating, and subsequently removing, `TXT` records using the Amazon Web Services Route 53 API.
- [Hooks](https://certbot.eff.org/docs/using.html#pre-and-post-validation-hooks) (Pre and Post) @ manual mode (`--manual`)
    ```bash
    certbot certonly --manual \
        --manual-auth-hook /path/to/http/authenticator.sh \
        --manual-cleanup-hook /path/to/http/cleanup.sh -d secure.example.com
    ```

### [`go-acme/lego`](https://github.com/go-acme/lego "GitHub 4.7K stars") | [Docs](https://go-acme.github.io/lego)

>Let's Encrypt client and ACME library written in Go. 

Integrations w/ DNS providers; [AWS Route53](https://go-acme.github.io/lego/dns/route53/)

### [CertMagic (Caddy)](https://github.com/caddyserver/certmagic "GitHub 3.7K stars")

>mature, robust, and capable ACME client integration for Go


```golang
// @ HTTP
http.ListenAndServe(":80", mux)

//... replace that with this ...

// @ CertMagic : HTTPS with HTTP->HTTPS redirects 
certmagic.HTTPS([]string{"example.com"}, mux)
```

## [Compare SSL Certificates](https://www.digitalocean.com/community/tutorials/a-comparison-of-let-s-encrypt-commercial-and-private-certificate-authorities-and-self-signed-ssl-certificates "digitalocean.com 2017")

- [Let's Encrypt](https://letsencrypt.org/getting-started/ "letsencrypt.org")
    - Free, DV only, 90 days, ACME protocol
- Commercial/Private CAs
    - DV, OV, and EV, 1-3 years, $10-$1000
        - @ EV, browser shows ***green padlock icon***
- Self-Signed
    - DV, OV, untrusted by browsers

### EV Certificates

- [digicert.com](https://www.digicert.com/tls-ssl/compare-certificates) (powers GeoTrust, Thawte)
    - $344/yr
    - "Supports 2048-bit public key encryption (3072-bit and 4096-bit available)"
    - "ECC public-key cryptography (supports hash functions: 256 and 384)"
- [`ssl.comodo.com`](https://ssl.comodo.com/ssl-ev-certificates-extended-validation) 
    - @ $250/yr
    - "Strongest SHA2 & ECC Encryption"
- [www.godaddy.com](https://www.godaddy.com/web-security/ssl-certificate)
    - $125/yr - 1 domain
    - $320/yr - Multiple Websites (UCC/SAN)
    - "Strong SHA-2 and 2048-bit encryption."
- [www.ssl.com](https://www.ssl.com/certificates/ev/) 
    - @ $250/yr
    - "2048/4096 SHA2 RSA (ECDSA supported)"

### [Let's Encrypt](https://letsencrypt.org/getting-started/ "letsencrypt.org") : ACME protocol : [Client implementations (Golang)](https://letsencrypt.org/docs/client-options/#clients-go)

The "Let’s Encrypt" organization is a CA. In order to get a certificate for your website’s domain from them, you have to demonstrate control over the domain. This is accomplished using the [ACME protocol](https://en.wikipedia.org/wiki/Automatic_Certificate_Management_Environment).

### [ZeroSSL Pricing](https://zerossl.com/pricing/)

**No EV** (Extended Validation) **certificates**. 

Domain Validation (DV) certificates ONLY.

@ Free &hellip;

```plaintext
    90-Day Certificates - 3
    90-Day ACME Certs   - unlimited
```

@ $100/yr &hellip;

```plaintext
    90-Day Certificates - unlimited
    1-Year Certificates - 3
    Multi-Domain Certs
    REST API Access
    90-Day ACME Certs   - unlimited
```

### &nbsp;