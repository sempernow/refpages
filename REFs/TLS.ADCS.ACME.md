# TLS

## AD CS 

Certificate issuance under Microsoft's manual PKI hellscape

### Add CA cert to Ubuntu trust store

```bash
# Copy the Root CA to ... MUST have extension: *.crt
sudo lime-DC1-CA.cer /usr/local/share/ca-certificates/lime-DC1-CA.crt
# Update the OS trust store
sudo update-ca-certificates
# Verify : flag --ca-native to use host's native trust store
curl --ca-native  https://e2e.kube.lime.lan/foo/hostname
```

By default, 
the AD CS role of Windows Server 2019 provides 
_only RSA type_ TLS certificates.

We successfully obtained a TLS certificate for web server usage 
from AD CS web form of its Certificate Server 
__`lime-DC1-CA`__ at `https://dc1.lime.lan/certsrv/`

The server responds with two (end-entity and full-chain) certificates, 
both __in PKCS#7 format__ (`.p7b`), 
and so must be converted to PEM for use in most servers.
Their odd format is useful only at Microsoft IIS and other legacy 
or non-standard servers such as Apache Tomcat.

- `certnew.p7b`

```bash
# Convert certificate from PKCS#7 (.p7b) to PEM format
cn=kube.lime.lan
openssl pkcs7 -print_certs -in certnew.p7b -out $cn.crt

# Parse the certificate
openssl x509 -noout -subject -issuer -startdate -enddate -ext subjectAltName -in $cn.crt
```

```plaintext
subject=C = US, ST = MD, L = AAC, O = DisselTree, OU = ops, CN = kube.lime.lan, emailAddress = admin@lime.lan
issuer=DC = lan, DC = lime, CN = lime-DC1-CA
notBefore=Jan 25 14:32:36 2025 GMT
notAfter=Jan 25 14:32:36 2027 GMT
X509v3 Subject Alternative Name:
    DNS:kube.lime.lan, DNS:*.kube.lime.lan
```

### CSR

AD CS requires CSR in PKCS#10/#7 (New/Renew) format.
OpenSSL generates the request (`*.csr`) in that format by default.

Regarding Windows Server 2019 and prior, 
AD CS offers __only RSA-based certificates__ 
unless that role is configured otherwise, 
which is a non-trivial task that nearly no organization performs.

```bash
domain=lime.lan
cn=kube.$domain
TLS_CN=$cn
TLS_O="K8s on $domain"
TLS_OU=$domain
## Create the configuration file (CNF) : See man config
## See: man openssl-req : CONFIGURATION FILE FORMAT section
## https://www.openssl.org/docs/man1.0.2/man1/openssl-req.html
cat <<EOH |tee $cn.cnf
[ req ]
prompt              = no        # Disable interactive prompts.
default_bits        = 2048      # Key size for RSA keys. Ignored for Ed25519.
default_md          = sha256    # Hashing algorithm.
distinguished_name  = req_distinguished_name 
req_extensions      = v3_req    # Extensions to include in the request.
[ req_distinguished_name ] 
CN              = ${TLS_CN:-p.gotham.gov}   # Common Name
O               = ${TLS_O:-Penguin Inc}     # Organization name
OU              = ${TLS_OU:-gotham.gov}     # Organizational Unit name
#L               = ${TLS_L:-Gotham}          # Locality name
#ST              = ${TLS_ST:-NY}             # State or Province
C               = ${TLS_C:-US}              # Country
emailAddress    = admin@$root
[ v3_req ]
subjectAltName      = @alt_names
keyUsage            = critical, digitalSignature
extendedKeyUsage    = serverAuth
[ alt_names ]
DNS.1 = $cn
DNS.2 = *.$cn   # Wildcard. CA must allow, else declare each subdomain.
EOH

# RSA (Use only this if the certificate server is AD CS)
openssl req -new -noenc -config $cn.cnf -extensions v3_req -newkey rsa:2048 -keyout $cn.key -out $cn.csr 
# ED25519
openssl req -new -noenc -config $cn.cnf -extensions v3_req -newkey ed25519 -keyout $cn.key -out $cn.csr
# ECDSA (NIST P-256 curve)
openssl req -new -noenc -config $cn.cnf -extensions v3_req -newkey ec:<(openssl ecparam -name prime256v1 -genkey) -keyout $cn.key -out $cn.csr

```

## [Automated TLS Management (Enterprise Grade)](https://chatgpt.com/share/6897a869-d390-8009-b873-da33b20e8e0b "ChatGPT 5")

- [__cert-manager__](https://github.com/cert-manager)
- Private Issuers (Backends):
    - Smallstep [__`step-ca`__](https://smallstep.com/docs/step-ca/ "smallstep.com")  
    An online CA for secure, automated X.509 and SSH certificate management. It's the server counterpart to `step` CLI. Run step-ca (internal ACME) + `step-issuer` or use `cert-manager`’s ACME issuer pointed at `step-ca`. Provides air-gapped ACME + tight Kubernetes integration.
        - Generate TLS certificates for private infrastructure using the ACME protocol.
        - Automate TLS certificate renewal.
        - Add Automated Certificate Management Environment (ACME) support to a legacy subordinate CA.
        - Issue short-lived SSH certificates via OAuth OIDC single sign on.
        - Issue customized X.509 and SSH certificates.
    - __Hashicorp Vault PKI__ | [__OpenBao PKI__](https://openbao.org/docs/secrets/pki/)
    - __Venafi TLS Protect for Kubernetes__ (the commercial successor to __Jetstack__ Secure): central policy/visibility across clusters and CAs (public or private). If you want enterprise governance and inventory at scale, this is the “batteries-included” option.

### Recommendations 

__Per environment__:

- Air-gapped / Regulated:   
  __cert-manager + Vault PKI__ (__or step-ca__ if you want ACME everywhere). Both are proven, policy-driven, and keep keys/CAs entirely under your control. 
- Large enterprise needing fleet-wide governance:   
  V__enafi TLS Protect for Kubernetes__ integrated with __cert-manager__ (__or Venafi issuer__) for policy, workflows, and inventory. 
- AWS-only edge:   
  ACM + AWS Load Balancer Controller for public ingress, optionally cert-manager + Vault/step-ca for internal services and mTLS.

---

## [ACME](https://en.wikipedia.org/wiki/Automatic_Certificate_Management_Environment) 

__Automated Certificate Management Environment__ (ACME) 

An ACME server is a trusted CA endpoint 
that issues certs after validating the 
client requestor has domain control.

* **Origin:** ACME is an IETF standard (RFC 8555) created by the __Let's Encrypt__ project to automate the issuance of publicly trusted TLS certificates.
* **Purpose:** Automates domain-validated (DV) certificate requests and renewals from a Certificate Authority (CA).
* **Focus:**
    * Primarily for *internet-facing* services.
    * Proves control of DNS names via challenges  
    (HTTP-01, DNS-01, TLS-ALPN-01) 
    to prove the requestor has domain control.
    * Result: an X.509 certificate signed by a public CA.
* __Private/Internal ACME Servers__
    * Smallstep Certificates (open-source & enterprise versions)
    * HashiCorp Vault (with ACME support)
    * Boulder (OSS version of __Let's Encrypt's__ CA software).

 