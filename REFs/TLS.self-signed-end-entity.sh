#!/usr/bin/env bash
#------------------------------------------------------------------------------
# TLS : openssl : Generate Self-signed Site Certificate
#
# REF : https://docs.docker.com/engine/swarm/configs/
# -----------------------------------------------------------------------------
# Params
len=4096
cn=${TLS_CN:-site.local} 
#ip=${TLS_IP:-192.168.11.109}

## For setting params per -subj "$subj" : NOT configured for WILDCARD cert
o=${TLS_O:-Penguin Inc}
ou=${TLS_OU:-gotham.gov}
c=${TLS_C:-US}

# DH Parameters file : Used by server to speed up the (encrypt/decrypt) calculations.
dhparam='dhparam'   # RSA 
ecparam='ecparam'   # ECDSA

# Issuer of Root CA is self (Self-signed)
ca='root-ca'

# *.key     # Web-server param      : SECRET key
# *.crt     # Web-server param      : PUBLIC certificate
# *.csr     # Cert Signing Request  : Used to generate signed cert (site.crt)
# *.cnf     # Configuration (Text)  : Used to generate CSR (site.csr)

# Generate CA root key : Use -noenc else -nodes (depricated)
openssl req -new -newkey rsa:$len -noenc -out $ca.csr -keyout $ca.key
# Generate CSR (Cert Signing Request) 
openssl req \
    -new -key "$ca.key" \
    -out "$ca.csr" -sha256 \
    -subj "$subj"

# Configure root CA
cat <<EOR > $ca.cnf
[root_ca]
basicConstraints = critical,CA:TRUE,pathlen:1
keyUsage = critical, nonRepudiation, cRLSign, keyCertSign
subjectKeyIdentifier=hash
EOR

# Sign the root-CA certificate
openssl x509 -req -days 3650 -in "$ca.csr" \
    -signkey "$ca.key" -sha256 -out "$ca.crt" \
    -extfile "$ca.cnf" -extensions root_ca 

# Generate site key
openssl req -new -newkey rsa:$len -noenc -out $cn.csr -keyout $cn.key

# Generate site CSR

## Configure site CA  https://www.labeightyfour.com/2019/07/27/generate-keys-in-openssl-using-configuration-file/
cat <<EOH >$cn.cnf
[req]
prompt = no
distinguished_name = req_dn
req_extensions = req_ext
[req_dn]
CN = $cn
O  = ${TLS_O:-Penguin Inc}
OU = ${TLS_OU:-DevOps}
L  = ${TLS_L:-Gotham}
ST = ${TLS_ST:-NY}
C  = ${TLS_C:-US}
[req_ext]
subjectAltName = @alt_names
keyUsage = critical,digitalSignature
extendedKeyUsage = serverAuth
[alt_names]
DNS.1 = $cn
DNS.2 = *.$cn
EOH

## Generate site cert and key
openssl req -newkey rsa:$len -days 3650 -noenc -sha256 \
    -extensions req_ext -config $cn.cnf \
    -keyout "$cn.key" -out "$cn.crt"

## One-liner TLS @ local host : https://letsencrypt.org/docs/certificates-for-localhost/ 
openssl req -x509 -out "$cn.crt" -keyout "$cn.key" -newkey rsa:$len -nodes -sha256 \
    -subj "/C=$c/ST=$st/L=$l/O=$o/CN=$cn" -extensions req_ext \
    -config <(printf "[req_dn]\nCN=$cn\n[req]\ndistinguished_name = req_dn\n[req_ext]\nsubjectAltName=DNS:$cn\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")

###################################################################################
# @ RSA 

# Sign site certificate using root CA
openssl req -x509 -days 3650 -in "$cn.csr" -sha256 \
    -CA "$ca.crt" -CAkey "$ca.key" -CAcreateserial \
    -out "$cn.crt" -extfile "$cn.cnf" -extensions server

# Generate Diffie-Hellman params
openssl dhparam -out $dhparam.pem $len

###################################################################################
# @ ECDSA 
algo='secp384r1'
algo='prime256v1'
# Private key : generate
openssl ecparam -name $algo -genkey -noout -out $cn.key
# -noout : do not outpout params
# -param_enc explicit : embed full parameters of the curve in the key

# Site Certificate : sign/generate
openssl req -new -x509 -key $cn.key -sha256 -nodes -out $cn.crt -days 3650 -extfile $cn.cnf -extensions req_ext
#... sha256 encrypts cert; -nodes for no password

# # Concat key and cert 
# cat ./$site_key ./$site_crt > $site_crt

# Examine both
openssl ecparam -in $cn.key -text -noout
openssl x509 -in $cn.crt -text -noout

# Generate Diffie-Hellman params 
openssl ecparam -name $algo -out $ecparam.pem

######################################
# Concat for full-chain certificate 
cat $cn.crt $ca.crt |tee $fullchain.crt

#####################################
# Test a cert/key pair (sans install)
p=5555
## @ Server terminal
openssl s_server -accept $p -cert $cn.crt -key $cn.key -CAfile $ca.crt
## @ Client terminal
openssl s_client -showcerts -connect $cn:$p -CAfile $ca.crt
### - May omit "-CAfile $ca.crt" if using Trusted CAs of /etc/ssl/certs/
### - For self-signed certs, use site as CA (cert) : "-CAfile $cn.crt"
### - If DNS-resolution error : "...:Name or service not known"
###   Add local DNS resolve   : echo "127.0.0.1 $cn" >>/etc/hosts

# Convert certificate to pem format 
openssl x509 -outform PEM -in $cn.crt -out $cn.pem


# Create docker secrets / configs
docker secret create $cn.key $cn.key
docker secret create $cn.crt $cn.crt
docker config create $dhparam.pem $dhparam.pem
docker config create $fullchain.crt $fullchain.crt

# docker secret create ${SITE_KEY} ${PATH_ACME_OUT}/${DOMAIN}_ecc/${DOMAIN}.key
# docker secret create ${SITE_CRT} ${PATH_ACME_OUT}/${DOMAIN}_ecc/${DOMAIN}.cer
# docker secret create ${FULLCHAIN} ${PATH_ACME_OUT}/${DOMAIN}_ecc/$fullchain.cer
# docker config create ${DHPARAM} ${DHPARAM}
