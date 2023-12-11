#!/usr/bin/env bash
#------------------------------------------------------------------------------
# openssl COMMANDS https://www.openssl.org/docs/man1.1.1/man1/ 
# openssl x509  https://man.archlinux.org/man/x509.1ssl.en
# openssl.org   https://www.openssl.org/docs/manmaster/
# openssl(1ssl) https://man.archlinux.org/man/openssl.1ssl
# config(5ssl)  https://man.archlinux.org/man/config.5ssl
# 
# For info on any openssl COMMAND : See man openssl-COMMAND 
# -----------------------------------------------------------------------------
exit 

len=2048
cn=${TLS_CN:-site.local} 
#... Common Name (CN) is the domain name to which a TLS certificate is bound.

###################################################################### 
# Self-signed WILDCARD certificates for TLS @ localhost (FQDN aliases) 
# Requires local DNS resolver for Fully Qualified Domain Names (FQDNs) 
# or manually add, e.g., to /etc/hosts file: "0.0.0.0 foo.local"
# REF: https://letsencrypt.org/docs/certificates-for-localhost/ 
#
## Create the configuration file (CNF) : See man config
## See: man openssl-req : CONFIGURATION FILE FORMAT section
## https://www.openssl.org/docs/man1.0.2/man1/openssl-req.html
cat <<EOH >$cn.cnf
[req]
prompt = no
distinguished_name = dn
req_extensions = EXT
[dn]
CN = $cn
C  = ${TLS_C:-US}
ST = ${TLS_ST:-NY}
L  = ${TLS_L:-Gotham}
O  = ${TLS_O:-Foobar Inc}
OU = ${TLS_OU:-DevOps}
[EXT]
subjectAltName = @alt_names
keyUsage = digitalSignature
extendedKeyUsage = serverAuth
[alt_names]
DNS.1 = $cn
DNS.2 = *.$cn
EOH

## Else set params per -subj "$subj" : NOT configured for WILDCARD cert
c=${TLS_C:-US};st=${TLS_ST:-NY};l=${TLS_L:-Gotham};o=${TLS_O:-Foobar Inc};ou=${TLS_OU:-DevOps}
subj="/C=$c/ST=$st/L=$l/O=$o/OU=$ou/CN=$cn"

## Generate RSA site cert and key
openssl req -x509 -newkey rsa:$len -days 10000 -noenc -sha256 \
    -extensions EXT -config $cn.cnf \
    -keyout "$cn.key" -out "$cn.crt"

    # -conf ... OR -batch -subj "$subj" (but NOT a WILDCARD cert)


################################
# Trusted-CA-signed Certificates
# 1. Create private key for the domain(s)
# 2. Create Certificate Signing Request (CSR) for submittal to CA;
#    CA signs the site cert and delivers the full-chain certificate.
# https://www.ssl.com/how-to/manually-generate-a-certificate-signing-request-csr-using-openssl/
#
## @ RSA (Rivest-Shamir-Adleman):
#
### 1. Generate RSA private key 
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$len -out $cn.key
### 2. Generate CSR
openssl req -new -sha256 -key $cn.key -extensions EXT -config $cn.cnf -out $cn.csr
### OR
### 1. Generate RSA private key and CSR in one step
#### Without passphrase/prompt (key is NOT encrypted)
openssl req -new -newkey rsa:$len -extensions EXT -config $cn.cnf -noenc -keyout $site.key -out $site.csr
#### With passphrase/prompt 
openssl req -new -newkey rsa:$len -extensions EXT -config $cn.cnf -keyout $site.key -out $site.csr
#
## @ ECDSA (Elliptic Curve Digital Signature Algorithm):
#
### 1. Generate parameter file : See man openssl-genpkey
openssl genpkey -genparam -algorithm ec -pkeyopt ec_paramgen_curve:P-256 -out ECPARAM.pem
### 2. Generate ECDSA private key
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out $cn.key
### 3. Generate CSR
openssl req -new -sha256 -key $cn.key -extensions EXT -config $cn.cnf -out $cn.csr
### OR
### 2. Generate private key and CSR
openssl req -newkey ec:ECPARAM.pem -keyout $cn.key -out $cn.csr
### OR 
### 1. All as a one-liner statement
openssl req -newkey ec:<(openssl genpkey -genparam -algorithm ec -pkeyopt ec_paramgen_curve:P-256)  -extensions EXT -config $cn.cnf -keyout $cn.key -out $cn.csr


####################################
# Parse / Validate OpenSSL documents

## Parse/Validate CSR
openssl req -in $cn.csr -text -noout

## Parse/Validate Certificate
openssl x509 -in $cn.crt -text -noout
#    -in: Specifies the input certificate file to validate or parse.
#    -text: Prints out the certificate details in a human-readable format.
#    -noout: Prevents OpenSSL from outputting the encoded version of the certificate, showing only the human-readable information.

#####################################
# Client : Use to validate TLS server
# See: man openssl-s_client
# https://www.openssl.org/docs/man1.1.1/man1/s_client.html

openssl s_client -connect $cn:443 
openssl s_client -connect $cn:443 -CAfile $ca.crt # CAfile is a Trusted-CAs Certificate
openssl s_client -connect $cn:443 -CAfile $ca.crt -status # For OCSP request/stapling
#... 2>&1 |tee openssl.s_client.connect.${cn}.cafile.log

## Parse the Cert
openssl x509 -in $cert -text -noout
## View CA Subject
openssl x509 -subject -noout < $ca.crt
## View site Subject
openssl x509 -subject -noout < $cn.crt


####################################
# Server : Use to mock TLS server 
# See: man s_server
openssl s_server -accept 443 -www


######
# Meta

openssl list -public-key-algorithms # RSA EC X25519 ED25519
#
#     RSA (Rivest-Shamir-Adleman):
#         RSA has been a widely used algorithm for many years 
#         and is generally considered secure when using key sizes of 2048 bits or higher. 
#         However, larger key sizes are often recommended for enhanced security.
#
#     ECDSA (Elliptic Curve Digital Signature Algorithm):
#         ECDSA is often preferred for its efficiency and smaller key sizes compared to RSA, 
#         providing similar levels of security with shorter keys. 
#         Common elliptic curves include P-256 and P-384.
#
#     X25519 (Curve25519 for key exchange):
#         X25519 is an elliptic curve Diffie-Hellman (ECDH) key exchange algorithm. 
#         It is specifically designed for key exchange and is part of the modern cryptographic suites.
#
#     Ed25519 (Edwards-curve Digital Signature Algorithm):
#         Ed25519 is an elliptic curve digital signature algorithm based on twisted Edwards curves. 
#         It is known for its simplicity, speed, and strong security properties.
#
# In recent years, there has been a trend toward favoring elliptic curve algorithms (such as ECDSA, X25519, and Ed25519) due to their efficiency and smaller key sizes compared to traditional RSA. Smaller key sizes are desirable for faster key exchange and reduced computational overhead.