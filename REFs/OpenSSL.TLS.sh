#!/usr/bin/env bash
#------------------------------------------------------------------------------
# openssl COMMANDS https://www.openssl.org/docs/man1.1.1/man1/ 
# openssl x509  https://man.archlinux.org/man/x509.1ssl.en
# openssl.org   https://www.openssl.org/docs/manmaster/
# openssl(1ssl) https://man.archlinux.org/man/openssl.1ssl
# config(5ssl)  https://man.archlinux.org/man/config.5ssl
# -----------------------------------------------------------------------------
exit 

cert_ca='ca.cer'
cert_cn='uqrate.org.cer'
rsa_len=2048
cn=${TLS_CN:-swarm.foo}

####################################
# TLS @ localhost (or alias thereto)
# https://letsencrypt.org/docs/certificates-for-localhost/ 

### Set params
c=${TLS_C:-US};st=${TLS_ST:-NY};l=${TLS_L:-Gotham};o=${TLS_O:-Foobar Inc}
### Write config
printf "[dn]\nCN=$cn\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$cn\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth" > 'config'
### Generate site cert and key
openssl req -x509 -out "$cn.crt" -keyout "$cn.key" -newkey rsa:$rsa_len -nodes -sha256 -subj "/C=$c/ST=$st/L=$l/O=$o/CN=$cn" -extensions EXT -config 'config'

##################
# View the Subject
openssl x509 -subject -noout < $cert_ca
#> subject=C = US, O = Let's Encrypt, CN = R3
openssl x509 -subject -noout < $cert_cn
#> subject=CN = uqrate.org

####################
# TLS client : Info  
# https://www.openssl.org/docs/man1.1.1/man1/s_client.html
openssl s_client -connect $cn:443 # -status ;for OCSP request

###############################
# Generate an ECDSA private key
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out PRIVATE_KEY_FILE

#############################################
# Generate an RSA private key : genpkey(1ssl)
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$rsa_len -out PRIVATE_KEY_FILE

#####################################################
# Generate a certificate signing request : req(1ssl):
openssl req -new -sha256 -key PRIVATE_KEY_FILE -out CSR_FILE

####################################
# Generate a self-signed certificate
openssl req -key PRIVATE_KEY_FILE -x509 -new -days 700 -out SITE_CERT_FILE

#############################################################################
# Generate a self-signed certificate with RSA private key in a single command
openssl req -x509 -newkey rsa:$rsa_len -days days \
    -keyout SITE_KEY_FILE -out SITE_CERT_FILE

#################################################
# Generate Diffie–Hellman parameters (not needed)
openssl dhparam -dsaparam -out DHPARAM_FILE $rsa_len

