#!/usr/bin/env bash
#------------------------------------------------------------------------------
# mTLS (Istio) : Generate key and cert for CA, Server, and Client.
# https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-sidecar-tls-termination/#generate-ca-cert-server-certkey-and-client-certkey
# -----------------------------------------------------------------------------

# Environment

ca=example.com
server=httpbin.test.svc.cluster.local 
client=client.test.svc.cluster.local

ca_org='example Inc.'
server_org='httpbin organization'
client_org='client organization'

days=365

# CA : key and cert

openssl req -x509 -sha256 \
    -nodes -days $days \
    -newkey rsa:2048 \
    -subj "/CN=$ca/O=$ca_org" \
    -keyout ${ca}.key \
    -out ${ca}.crt

# Server 

## Key & Cert Signing Request (CSR)
openssl req -out ${server}.csr \
    -newkey rsa:2048 -nodes \
    -keyout ${server}.key \
    -subj "/CN=${server}/O=$server_org"
## Cert
openssl x509 -req -days $days \
    -CA $ca.crt \
    -CAkey $ca.key \
    -set_serial 1 \
    -in $server.csr \
    -out $server.crt

# Client 

## Key and Cert Signing Request (CSR)
openssl req -out $client.csr \
    -newkey rsa:2048 -nodes \
    -keyout $client.key \
    -subj "/CN=$client/O=$client_org"
## Cert
openssl x509 -req -days $days \
    -CA $ca.crt \
    -CAkey $ca.key \
    -set_serial 1 \
    -in $client.csr \
    -out $client.crt
