#!/usr/bin/env bash
exit 
#------------------------------------------------------------------------------
# TLS : openssl : Generate Root CA Key and Certificate 
# -----------------------------------------------------------------------------
# *.key     # Web-server param      : SECRET key in PEM format
# *.crt     # Web-server param      : PUBLIC certificate in PEM format
# *.csr     # Cert Signing Request  : Used to generate signed cert (site.crt)
# *.cnf     # Configuration (Text)  : Used to generate CSR (site.csr)

len=4096
days=3650
cn=${TLS_CN:-Penguin Root CA}
o=${TLS_O:-Penguin Inc}
ou=${TLS_OU:-gotham.gov}
c=${TLS_C:-US}
path="${TLS_DIR:-.}/${cn// /-}"

# Configuration File (CNF) of CSR for a Root CA
tee $path.cnf <<-EOR
[ req ]
prompt              = no
default_bits        = $len
default_md          = sha256
distinguished_name  = req_distinguished_name
x509_extensions = v3_ca
[ req_distinguished_name ]
CN  = $cn
O   = $o
OU  = $ou
C   = $c
[ v3_ca ]
basicConstraints        = critical, CA:TRUE # Append pathlen:1 to limit chain to one subordinate CA
keyUsage                = critical, keyCertSign, cRLSign
subjectKeyIdentifier    = hash
EOR

## Generate key and CSR  : -noenc else -aes256 to encrypt w/ AES-256 (password)
openssl req -new -config $path.cnf -noenc -newkey rsa:$len -keyout $path.key -out $path.csr
## Sign the root cert with root key, applying the extensions of CSR
openssl x509 -req -in $path.csr -extensions v3_ca -extfile $path.cnf -signkey $path.key \
    -days $days -sha384 -out $path.crt

## OR

## Generate both key and cert from CNF in one statement; skip the CSR
openssl req -x509 -new -nodes -keyout $path.key -days $days -config $path.cnf -extensions v3_ca \
    -out $path.crt


echo "🔍  Parse the certificate located at '$path.crt'" >&2 # man x509v3_config
openssl x509 -in $path.crt -noout -issuer -subject -startdate -enddate \
    -ext subjectAltName,basicConstraints,keyUsage,subjectKeyIdentifier
