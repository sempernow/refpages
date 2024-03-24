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
dhparam=dhparam
openssl dhparam -out $dhparam.pem $len 
## ECDSA : The ecparams file is usually not required by TLS-termination servers
ecparam=ecparam
openssl genpkey -genparam -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out $ecparam.pem


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
distinguished_name = req_dn
req_extensions = req_ext
[req_dn]
CN = $cn
C  = ${TLS_C:-US}
ST = ${TLS_ST:-NY}
L  = ${TLS_L:-Gotham}
O  = ${TLS_O:-Foobar Inc}
OU = ${TLS_OU:-DevOps}
[req_ext]
subjectAltName = @alt_names
keyUsage = digitalSignature
extendedKeyUsage = serverAuth
[alt_names]
DNS.1 = $cn
DNS.2 = *.$cn
EOH

## Else set params using -subj "$subj" : NOT configured here for WILDCARD cert
c=${TLS_C:-US};st=${TLS_ST:-NY};l=${TLS_L:-Gotham};o=${TLS_O:-Foobar Inc};ou=${TLS_OU:-DevOps}
subj="/C=$c/ST=$st/L=$l/O=$o/OU=$ou/CN=$cn"

## Generate RSA site cert and key : Use -noenc else -nodes (depricated)
openssl req -x509 -newkey rsa:$len -sha256 -days 3650 -noenc \
    -extensions req_ext -config $cn.cnf \
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
## @ RSA (Rivest-Shamir-Adleman):
#
### 1. Generate RSA private key 
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$len -out $cn.key

### 2. Generate CSR
openssl req -new -sha256 -key $cn.key -extensions req_ext -config $cn.cnf -out $cn.csr
### OR
### 1. Generate RSA private key and CSR in one step
#### Without passphrase/prompt (key is NOT encrypted)
openssl req -new -newkey rsa:$len -extensions req_ext -config $cn.cnf -noenc -keyout $site.key -out $site.csr
#### With passphrase/prompt 
openssl req -new -newkey rsa:$len -extensions req_ext -config $cn.cnf -keyout $site.key -out $site.csr
#
## @ ECDSA (Elliptic Curve Digital Signature Algorithm):
#
### 1.a Generate ECDSA private key using parameters file
### 1.a.1 Generate parameters file : See man openssl-genpkey
openssl genpkey -genparam -algorithm ec -pkeyopt ec_paramgen_curve:P-256 -out $ecparam.pem
### 1.a.2 Generate ECDSA private key using parameters file
openssl genpkey -paramfile $ecparam.pem -out $cn.pem
### 1.b Generate ECDSA private key sans parameters file
openssl genpkey -algorithm ec -pkeyopt ec_paramgen_curve:P-256 -out $cn.key
### 2. Generate CSR
openssl req -new -sha256 -key $cn.key -extensions req_ext -config $cn.cnf -out $cn.csr
### OR
### 2. Generate private key and CSR using parameters file
openssl req -newkey ec:$ecparam.pem -keyout $cn.key -out $cn.csr
### OR 
### 1. All as a one-liner statement
openssl req -newkey ec:<(openssl genpkey -genparam -algorithm ec -pkeyopt ec_paramgen_curve:P-256)  -extensions req_ext -config $cn.cnf -keyout $cn.key -out $cn.csr


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
# Get the (full-chain) certificate of a server ($h) at its port ($p):
## E.g., 
h=google.com
p=443 
openssl s_client -connect $h:$p -showcerts < /dev/null > ${h}_${p}.full-chain.txt

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
### - If self-signed cert, use site (cn) cert as CA : "-CAfile $cn.crt"
### - On DNS-resolution error : "...:Name or service not known".
###   To add local DNS resolution : echo "127.0.0.1 $h" >>/etc/hosts

################################################################################
# File Formats : Do NOT rely upon the file's extension to indicate format.
## PEM (Privacy-Enhanced Mail) is human-readable text : .crt, .cer, .pem, .key
## DER (Distinguished Encoding Rules) is binary data  : .crt, .cer, .der, .key
## Convert:
### DER to PEM (From binary to text) 
openssl x509 -inform der -in certificate.der -outform pem -out certificate.pem
### PEM to DER (From text to binary) 
openssl x509 -in certificate.pem -outform der -out certificate.der

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