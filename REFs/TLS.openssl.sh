#!/usr/bin/env bash
#------------------------------------------------------------------------------
# OpenSSL.org   https://www.openssl.org/docs/manmaster/
# openssl(1ssl) https://man.archlinux.org/man/openssl.1ssl
# config(5ssl)  https://man.archlinux.org/man/config.5ssl
# 
# See "man openssl-COMMAND" for details of any OpenSSL command.
# -----------------------------------------------------------------------------
exit 

# Common Name (CN) is a Fully Qualified Domain Name (FQDN) to which a TLS certificate is bound.
cn=${TLS_CN:-site.local} 
# Key/Cert bit lengths
len=2048


####################
# DH Parameters file
## RSA
dhparam=dhparam_$len
openssl dhparam -out $dhparam.pem $len 
## EC : Note that ED25519 (X25519) type key/cert does not require any params file
curve='secp384r1' # p-256|p-384|secp384r1  
ecparam=ecparam_$curve
openssl genpkey -genparam -algorithm EC -pkeyopt ec_paramgen_curve:$curve -out $ecparam.pem


###################################################################### 
# Self-signed WILDCARD certificates for TLS @ localhost (FQDN aliases) 
# Requires local DNS resolver for Fully Qualified Domain Names (FQDNs) 
# or manually add, e.g., to /etc/hosts file: "0.0.0.0 foo.local"
# REF: https://letsencrypt.org/docs/certificates-for-localhost/ 
#
## Create the configuration file (CNF) : See man config
## See: man openssl-req : CONFIGURATION FILE FORMAT section
## https://www.openssl.org/docs/man1.0.2/man1/openssl-req.html
tee $cn.cnf <<EOH
[ req ]
prompt              = no
default_bits        = 2048
default_md          = sha256
distinguished_name  = req_distinguished_name 
req_extensions      = v3_req
[ req_distinguished_name ]
CN              = $cn
C               = ${TLS_C:-US}
ST              = ${TLS_ST:-NY}
L               = ${TLS_L:-Gotham}
O               = ${TLS_O:-Foobar Inc}
OU              = ${TLS_OU:-GitOps}
emailAddress    = admin@$cn
[ v3_req ]
subjectAltName      = @alt_names
keyUsage            = digitalSignature
extendedKeyUsage    = serverAuth
[ alt_names ]
DNS.1 = $cn
DNS.2 = *.$cn
EOH

# @ Self-signed cert, replace v3_req with
[ req_ext ]
subjectAltName = @alt_names
[ v3_ca ]
basicConstraints    = CA:FALSE
keyUsage            = digitalSignature, keyEncipherment
extendedKeyUsage    = serverAuth, clientAuth
subjectAltName      = @alt_names

# @ CA Certificate
[ v3_ca ]
basicConstraints        = CA:TRUE
keyUsage                = cRLSign, keyCertSign
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always,issuer

# @ mTLS : CSR sections (instead of, or in addition to, v3_req containing other k-v pairs):
[ server_cert ]
keyUsage            = critical, digitalSignature, keyEncipherment
extendedKeyUsage    = serverAuth
[ client_cert ]
keyUsage            = critical, digitalSignature
extendedKeyUsage    = clientAuth

## Sign server cert
openssl ca -config $cn.cnf -extensions server_cert -in server.csr -out server.crt
## Sign client cert
openssl ca -config $cn.cnf -extensions client_cert -in client.csr -out client.crt

## Else set params using -subj "$subj" : NOT configured here for WILDCARD cert
c=${TLS_C:-US};st=${TLS_ST:-NY};l=${TLS_L:-Gotham};o=${TLS_O:-Foobar Inc};ou=${TLS_OU:-DevOps}
subj="/C=$c/ST=$st/L=$l/O=$o/OU=$ou/CN=$cn"

## Generate RSA site cert and key : Use -noenc else -nodes (depricated)
openssl req -x509 -newkey rsa:$len -sha256 -days 3650 -noenc \
    -extensions v3_req -config $cn.cnf \
    -keyout "$cn.key" -out "$cn.crt"
    #... To SUPRESS PROMPT, use "-config $cn.cnf" (file) AND/OR -batch -subj "$subj".


################################
# Trusted-CA-signed Certificates
# 1. Create private key for the domain(s)
# 2. Create Certificate Signing Request (CSR) for submittal to CA;
#    CA signs the site cert and delivers the full-chain certificate.
# https://www.ssl.com/how-to/manually-generate-a-certificate-signing-request-csr-using-openssl/
# See : FIPS 186-4 / 186-5
#
## @ RSA (Rivest-Shamir-Adleman) : Most common and compatible :
## Required at AD CS (WS2019) :
#
### 1. Generate RSA private key 
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$len -out $cn.key

### 2. Generate CSR
openssl req -new -sha256 -key $cn.key -extensions v3_req -config $cn.cnf -out $cn.csr
### OR
### 1. Generate RSA private key and CSR in one step
#### Without passphrase/prompt (key is NOT encrypted)
openssl req -new -newkey rsa:$len -extensions v3_req -config $cn.cnf -noenc -keyout $site.key -outform pem -out $site.csr.pem
##### Same but in DER format
openssl req -new -newkey rsa:$len -extensions v3_req -config $cn.cnf -noenc -keyout $site.key -outform der -out $site.csr.der
#### With passphrase/prompt 
openssl req -new -newkey rsa:$len -extensions v3_req -config $cn.cnf -keyout $site.key -out $site.csr
#
## @ ECDSA (Elliptic Curve Digital Signature Algorithm; is not EdDSA)
## FIPS compliant :
#
### 1.a Generate ECDSA private key using parameters file
### 1.a.1 Generate parameters file : See man openssl-genpkey
openssl genpkey -genparam -algorithm ec -pkeyopt ec_paramgen_curve:P-256 -out $ecparam.pem
### 1.a.2 Generate ECDSA private key using parameters file
openssl genpkey -paramfile $ecparam.pem -out $cn.pem
### 1.b Generate ECDSA private key sans parameters file
openssl genpkey -algorithm ec -pkeyopt ec_paramgen_curve:P-256 -out $cn.key
### 2. Generate CSR
openssl req -new -sha256 -key $cn.key -extensions v3_req -config $cn.cnf -out $cn.csr
### OR
### 2. Generate private key and CSR using parameters file
openssl req -newkey ec:$ecparam.pem -keyout $cn.key -out $cn.csr
### OR 
### 1. All as a one-liner statement
openssl req -newkey ec:<(openssl genpkey -genparam -algorithm ec -pkeyopt ec_paramgen_curve:P-256)  -extensions v3_req -config $cn.cnf -keyout $cn.key -out $cn.csr
#
## @ ED25519 : Edwards-curve (EdDSA) using SHA-512 (SHA-2) and (elliptic curve) Curve25519 : 
## Simplest, fastest, most secure, and server needs no params file :
#
### Private key
openssl genpkey -algorithm ed25519 -out $cn.key
### Public key 
openssl pkey -in $cn.key -pubout -out $cn.pub.key
### CSR
openssl req -new -key $cn.key -config $cn.cnf -out $cn.csr
### Self-signed Certificate
openssl req -new -key $cn.key -x509 -days 3650 -out $cn.ss.crt


### 3. PKCS format : Convert CSR for copy/paste to web-form input at Microsoft AD Certificate Services (server)
###    Only the DER-format of the created CSR can be converted to PKCS ("PEM") format
###    Though "-outform pem" here, the PKCS file is *not* that of the created CSR "-outform pem"
openssl req -inform der -in $cn.csr.der -outform pem -out $cn.csr.p7b


####################################
# Parse / Validate OpenSSL documents

## Parse/Validate CSR
openssl req -in $any.csr -noout -text

## Parse/Validate Certificate : See "man openssl-x509"
openssl x509 -in $any.crt -noout -text
#   -in     : Specifies the input certificate file to validate or parse.
#   -text   : Prints out the certificate details in a human-readable format.
#   -noout  : Show only the human-readable information.

## Verify the server's ca-signed certificate ($any.crt) against the CA ($ca.crt) that signed it
## (The CA file may be a trust-store bundle; a concatenated list of CA certs in PEM format.)
openssl verify -CAfile $ca.crt $any.crt

## Print cert EXPIRATION DATE section
openssl x509 -in $any.crt -noout -enddate 

## Print cert subject section
openssl x509 -in $any.crt -noout -subject 


###########################################################################
# Get (full-chain) certificate of a server ($h) at its port ($p):
## E.g., 
h=google.com
p=443 
openssl s_client -connect $h:$p -showcerts < /dev/null > ${h}_${p}.full-chain.log

#####################################
# Test a cert/key pair (sans install)
## Note TLS handshake occurs prior to HTTP.
## Optional server/client param : -accept/-connect HOST:PORT ($h:$p)
h=$cn  # Default: *
p=5555 # Default: 4433. Any available port okay, but > 1024 else sudo required.
## @ Server terminal 
openssl s_server -accept $h:$p -cert $cn.crt -key $cn.key -CAfile $ca.crt
## @ Client terminal : params must match server's
openssl s_client -showcerts -connect $h:$p -CAfile $ca.crt
### - Signals: Q (quit), ... : See "man openssl-s_client"
### - Omit "-CAfile $ca.crt" to use "Trusted CA Store" /etc/ssl/certs/
### - If self-signed cer, use site (cn) cert as CA : "-CAfile $cn.crt"
### - On DNS-resolution error : "...:Name or service not known".
###   To add local DNS resolution : echo "127.0.0.1 $h" >>/etc/hosts

################################################################################
# Convert File Formats : Do NOT rely upon the file's extension to indicate format.
## PEM (Privacy-Enhanced Mail) is human-readable text : .crt, .cer, .pem, .key
## DER (Distinguished Encoding Rules) is binary data  : .crt, .cer, .der, .key
## Convert:
### DER to PEM (From binary to text) 
openssl x509 -inform der -in certificate.der -outform pem -out certificate.pem
### PEM to DER (From text to binary) 
openssl x509 -in certificate.pem -outform der -out certificate.der
### PEM to PKCS#7
#### Single PEM certificate (no CRL file) to PKCS#7
openssl crl2pkcs7 -nocrl -certfile input.pem -out output.p7b
#### Chain of PEMs to PKCS#7 (order matters)
openssl crl2pkcs7 -nocrl -certfile end-entity.pem -certfile intermediary.pem -certfile root.pem -out output.p7b
### PKCS#7 to PEM : PKCS#7 may be a full-chain or single certificate:
openssl pkcs7 -print_certs -in input.p7b -out output.pem
### PEMs to PKCS#12 : Password prompt
#### Chain of certificates and server key, all of PEM, into a single PKCS#12
openssl pkcs12 -export -out $cn.p12 -inkey $cn.key.pem -in end-entity.pem -certfile intermediary.pem -certfile root.pem
#### full-chain cert (ordered concat) and server key, both of PEM, into single PKCS#12
openssl pkcs12 -export -out $cn.p12 -inkey $cn.key.pem -in $cn.full-chain.pem

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
# The current trend (2022) is toward elliptic curve algorithms (such as ECDSA, X25519, and Ed25519) due to their efficiency and smaller key sizes compared to traditional RSA. Smaller key sizes are desirable for faster key exchange and reduced computational overhead.