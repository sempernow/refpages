#!/usr/bin/env bash
#------------------------------------------------------------------------------
# TLS : openssl : Generate Self-signed Site Certificate
#
# REF : https://docs.docker.com/engine/swarm/configs
# -----------------------------------------------------------------------------
# Params
c=${TLS_C:-US};st=${TLS_ST:-VA};l=${TLS_L:-Arlington};o=${TLS_O:-Sempernow LLC}

cn=${TLS_CN:-swarm.foo}
#ip=${TLS_IP:-192.168.1.26}

root_key='root-ca.key'         # SECRET
root_crt='root-ca.crt'
root_csr='root-ca.csr'
root_cnf='root-ca.cnf'

site_key='site.key'            # Web-server param : SECRET
site_crt='site.crt'            # Web-server param
site_csr='site.csr'
site_cnf='site.cnf'

fullchain='site.fullchain.crt' # Web server param
#... is $site_crt lest "intermediaries" appended
dhparam='dhparam.rsa.pem'

# site_csr and site_cnf files are not needed by Nginx service;
# needed to generate a new site certificate.

# Generate root key
openssl genrsa -out "$root_key" 4096

# Generate CSR (Cert Signing Request) 
openssl req \
	-new -key "$root_key" \
	-out "$root_csr" -sha256 \
	-subj "/C=$c/ST=$st/L=$l/O=$o/CN=$cn"

# Configure root CA
cat <<EOR > $root_cnf
[root_ca]
basicConstraints = critical,CA:TRUE,pathlen:1
keyUsage = critical, nonRepudiation, cRLSign, keyCertSign
subjectKeyIdentifier=hash
EOR

# Sign the certificate
openssl x509 -req -days 3650 -in "$root_csr" \
	-signkey "$root_key" -sha256 -out "$root_crt" \
	-extfile "$root_cnf" -extensions \
	root_ca

# Generate site key
openssl genrsa -out "$site_key" 4096

# Generate site CSR
openssl req \
	-new -key "$site_key" \
	-out "$site_csr" -sha256 \
	-subj "/C=$c/ST=$st/L=$l/O=$o/CN=$cn"

# Configure site CA  https://www.labeightyfour.com/2019/07/27/generate-keys-in-openssl-using-configuration-file/
cat <<EOR > $site_cnf
[server]
authorityKeyIdentifier=keyid,issuer
basicConstraints = critical,CA:FALSE
extendedKeyUsage = serverAuth
keyUsage = critical, digitalSignature, keyEncipherment
subjectAltName = DNS:$cn
subjectKeyIdentifier = hash
[req]
distinguished_name = app_devops
EOR

###################################################################################
# @ RSA 

# Sign the site certificate
openssl req -x509 -days 750 -in "$site_csr" -sha256 \
    -CA "$root_crt" -CAkey "$root_key" -CAcreateserial \
    -out "$site_crt" -extfile "$site_cnf" -extensions server

# Generate Diffie-Hellman params (computationally intensive) for Nginx 
openssl dhparam -out $dhparams 4096

#... else: 4096 bytes takes MINUTEs; less than is vulnerable to logjam attack;

###################################################################################
# @ ECC 
algo='secp384r1'
algo='prime256v1'
key='site.key'
# Private key : generate
openssl ecparam -name $algo -genkey -noout -out $site_key
# -noout : do not outpout params
# -param_enc explicit : embed full parameters of the curve in the key

# Site Certificate : sign/generate
openssl req -new -x509 -key ./$site_key -sha256 -nodes -out $site_crt -days 730 -extfile "$site_cnf" -extensions server
#... sha256 encrypts cert; -nodes for no password

# # Concat key and cert 
# cat ./$site_key ./$site_crt > $site_crt

# Examine both
openssl ecparam -in ./$site_key -text -noout
openssl x509 -in ./$site_crt -text -noout

# Generate Diffie-Hellman params (computationally intensive) for Nginx 
openssl ecparam -name $algo -out ecparam.pem

##########################################################################
# Concat full chain (for OCSP Stapling) 
cat $site_crt $root_crt > $fullchain

exit 0

# Create docker secrets / configs
docker secret create $site_key ./$site_key
docker secret create $site_crt ./$site_crt
docker config create $dhparam ./$dhparam
docker config create $fullchain ./$fullchain

# docker secret create ${SITE_KEY} ${PATH_ACME_OUT}/${DOMAIN}_ecc/${DOMAIN}.key
# docker secret create ${SITE_CRT} ${PATH_ACME_OUT}/${DOMAIN}_ecc/${DOMAIN}.cer
# docker secret create ${FULLCHAIN} ${PATH_ACME_OUT}/${DOMAIN}_ecc/fullchain.cer
# docker config create ${DHPARAM} ./${DHPARAM}

# Test
openssl s_client -connect $cn:443 -CAfile ./$root_crt \
	> 'openssl.s_client.connect.cafile.log' 2>&1

# Convert certificate to pem format 
openssl x509 -outform PEM -in $_crt -out $_crt_as_pem

# TLS @ localhost : https://letsencrypt.org/docs/certificates-for-localhost/ 
c=${TLS_C:-US};st=${TLS_ST:-VA};l=${TLS_L:-Arlington};o=${TLS_O:-Sempernow LLC}
cn=${TLS_CN:-swarm.now}
printf "[dn]\nCN=$cn\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$cn\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth" > 'config'
openssl req -x509 -out "$cn.crt" -keyout "$cn.key" -newkey rsa:2048 -nodes -sha256 -subj "/C=$c/ST=$st/L=$l/O=$o/CN=$cn" -extensions EXT -config 'config'
