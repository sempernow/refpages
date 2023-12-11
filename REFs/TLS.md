# TLS (Formerly SSL) | [Wikipedia](https://en.wikipedia.org/wiki/Transport_Layer_Security "Wikipedia") | [RFC-6066](https://www.rfc-editor.org/rfc/rfc6066) | [TLS 1.3](https://www.rfc-editor.org/rfc/rfc8446 "RFC-8446") | [TLS 1.2](https://www.rfc-editor.org/rfc/rfc5246 "RFC-5246")

## Overview

TLS/SSL is a trust-based scheme. The server sends a cryptographically-generated certificate, and the client application validates that against the Certificate-Authority (CA) certificate (root certificate) from which the server's certificate claims to be created. Nominally, the client application obtains that root-CA certificate from the default store at its host (OS). Applications may have their own stores, cipher suites and such, may add their own to those of host, or entirely ignore the host's CA store and/or the host's TLS configuration.

**POSIX**-type operating systems have a directory of such certificate files. **Linux** stores them in the **`/etc/ssl/certs`** directory. The **`ca-certificates.crt`** file contains a concatenated list of such certificates. Other CA root-certificate files (`*.crt`) may exist in that directory as standalones, e.g., `root-ca-site.local.crt` .

**Windows** has an entirely different scheme of course; `Certificates.msc`

### TLS Handshake 

[HTTPS is an extention of HTTP](https://en.wikipedia.org/wiki/HTTPS). An HTTPS connection starts with a TLS client/server handshake whereof TLS parameters (cipher suite and such) are set (negotiated if allowed). Otherwise, the TLS-handshake fails and the connection is terminated. 

>**On TLS-handshake failure**, the server is likely to send a "handshake failure" alert. Such may occur if the certificate's CA cannot be validated by the client, or ***if client and server have no mutually supported TLS-ciphers suite***. The TLS handshake failure is not an HTTP-level response; it's part of the TLS protocol. The HTTP layer comes into play only after a secure TLS connection has been established. If the TLS handshake fails, the HTTP layer doesn't have an opportunity to send an HTTP response code because the connection hasn't been established.

## OpenSSL (TLS) Tools

### [`openssl`](https://www.openssl.org/) | [`REF.TLS.openssl.sh`](REF.TLS.openssl.sh) (commands)

The multi-purpose OpenSSL tool used to create, parse, validate, and test TLS keys, certificates, and such. Also useful for TLS at `https://localhost` (and aliases) for development. **Satisfies all browsers**.  

>For useful information on any `openssl <command>`,   
>run `man openssl-<command>`.  
>For list of commands by category, just run `openssl`.

#### @ [Docker/Nginx](https://docs.docker.com/engine/swarm/configs/ "docs.docker.com/swarm/configs") 

- Create: [`REF.TLS.openssl.sh`](REF.TLS.openssl.sh)
- Deploy: [`stack-nginx.yml`](stack-nginx.yml)

### [`mkcert`](https://github.com/FiloSottile/mkcert) (HTTPS @ `localhost`)

A simple tool for making locally-trusted development certificates. 
It requires no configuration. 
Worthless @ Windows 10. 

#### @ Windows/WSL (Golang/cURL)

REF: [Add a self-signed CA (`root-ca.crt`) to Windows 10](https://zeropointdevelopment.com/how-to-get-https-working-in-windows-10-localhost-dev-environment/). 

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

### [Let's Encrypt](https://letsencrypt.org/getting-started/ "letsencrypt.org") : ACME protocol : [Client implementations (Golang)](https://letsencrypt.org/docs/client-options/#clients-go)

The "Let’s Encrypt" organization is a CA. In order to get a certificate for your website’s domain from them, you have to demonstrate control over the domain. This is accomplished using the [ACME protocol](https://en.wikipedia.org/wiki/Automatic_Certificate_Management_Environment).

## Glossary

### Transport Layer Security (TLS)

>Transport Layer Security is the newer security protocol that ***replaced Secure Sockets Layer (SSL)***. Though the SSL protocol is obsolete, and has been so for about a quarter century, the term "SSL" stubbornly remains with us.

### Certificate

Server certificates are presented by a web server whenever a new TLS connection is requested. They contain the name of the host the certificate is issued to (which should match the server you’re attempting to connect to) and are signed by a Certificate Authority (CA) to establish trust.

#### Full-Chain Certificate

A "full chain" certificate refers to a certificate that includes not only the end-entity (server) certificate for a specific domain but also the intermediate and root certificates in the certification chain. This chain of certificates helps establish trust from the end-entity certificate back to a trusted root certificate authority (CA). Many CAs provide this "bundle" or "full chain" option when delivering certificates.

Components of a full-chain certificate:

- **End-entity certificate**: This is the certificate that corresponds to the specific domain for which the certificate is issued. It contains the public key for the server and is signed by an intermediate CA.

- **Intermediate certificate(s)**: Intermediate certificates sit between the end-entity certificate and the root certificate in the certificate chain. They are used to enhance security by creating a hierarchy of trust. The intermediate certificate is signed by a root CA and, in turn, signs the end-entity certificate.

- **Root certificate**: The root certificate is the top-level certificate in the hierarchy and is self-signed. It is the ultimate authority that establishes trust in the entire chain. Web browsers and other client applications come pre-installed with a set of trusted root certificates.

When a client, such as a web browser, connects to a server secured with SSL/TLS, it checks the certificate chain to ensure that the end-entity (server) certificate is valid and signed by a trusted intermediate certificate, which, in turn, is signed by a trusted root certificate. That is, the client must have its own set of trusted-CA certificates, or use that of the system (OS) in which it is running, against which to validate the server's certificate.

Including the full chain when configuring SSL/TLS on a server is important to ensure that clients can validate the server's certificate properly. Without the full chain, clients may not be able to establish the chain of trust, and the connection could be deemed untrusted. 

### Certificate Authority (CA)

Certificate authorities verify details about a domain owner’s request for SSL certificates, then – if everything checks out – issue and sign server certificates. Browsers and operating systems maintain a list of trusted certificate authorities. If a server certificate is signed by one of these trusted CAs, it will also be trusted.

### Domain Validation (DV)

A domain validated certificate will be issued to somebody who has proven they control the domain name requested for the certificate. This proof often takes the form of serving a unique token from your web server or DNS records, which the CA will check for before issuing the certificate.

### Organization Validation (OV)

An organization validated certificate means that the certificate authority also verified the company name and address in public databases. This information is put into the certificate, and is typically displayed only when the user clicks the green padlock icon to investigate further.

### Extended Validation (EV)

Extended validation is ***more thorough than domain or organization validation***. EV certificates are issued after checking not only domain ownership, but also verifying the existence and location of the legal entity requesting the certificate, and that said entity controls the domain being verified.

Unlike DV and OV certificates, EV cannot be issued as a wildcard certificate.

EV certificate also ***gets special treatment in web browsers***. Whereas browsers typically denote a DV certificate with a ***green-padlock icon***, EV certificates also show a larger green bar containing the name of the organization it was issued to. This is intended to reduce phishing attacks, though some studies show that users tend not to notice when this green bar is missing.

### SAN (Subject Alternative Name)

The new **CN** (Common Name) AKA Domain Name; a field of a certificate that indicates for which domain(s) the certificate is valid. A single certificate may contain many SANs and be valid for many different domain names. 

### Wildcard Certificate

The asterisk character (`*`) is the wildcard, and can be substituted with any valid hostname. Instead of being issued for a specific Fully Qualified Domain Name (FQDN), such as `app.example.com`, wildcard certs are valid for a whole range of subdomain names. So a cert issued to `*.example.com` would cover `app.example.com` and `database.example.com`. 

### Certificate Revocation List (CRL)

SSL certificates can include information on how to access a certificate revocation list. Clients will download and check this list to make sure the certificate has not been revoked. CRLs have largely been replaced by OCSP responders.

### Online Certificate Status Protocol (OCSP)

The OCSP protocol is a replacement for CRLs, with the benefits of being more real-time and requiring less bandwidth. The general operation is similar: clients are to query the OCSP responder to check if a certificate has been revoked.

### &nbsp;