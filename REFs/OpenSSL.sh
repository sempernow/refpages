#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  https://xenovation.com/blog/security/pki/creating-elliptic-curve-ecdh-key-with-openssl
# 
# https://wiki.openssl.org/index.php/Command_Line_Elliptic_Curve_Operations
# -----------------------------------------------------------------------------

################################
# Key Pair of Elliptical Curve
################################

## List available curves
openssl ecparam -list_curves
### TLS @ RFC7748 : 4. Recommended Curves
### Curve25519, Curve448 ??? nothing of the sort is listed.
curve=prime256v1 #... purportedly, this is the the one for TLS.

## Create private key in PEM format (encrypted)
openssl ecparam -name $curve -genkey -noout -out $curve.pem

## Show details
openssl pkey -in $curve.pem -text
### OR
openssl ec -in $curve.pem -text -noout

## Create ecparam file
openssl ecparam -name ${curve} -out ${curve}-ecparams.pem

## Create public key file from private keyfile
openssl ec -in ${curve}.pem -pubout -out ${curve}_pub.pem

cat ${curve}.pem
cat ${curve}-ecparams.pem

## Formats : PEM, PEM Encrypted, PKCS8, PKCS8 Encrypted, DER (binary)
## PEM are AKA "traditional format".
### Convert PKCS8 (Un)Encrypted to PEM Encrypted:
openssl ec -aes-128-cbc -in p8file.pem -out tradfile.pem
### Convert PEM (Un)Encrypted to PKCS8 Encrypted:
openssl pkcs8 -topk8 -in tradfile.pem -out p8file.pem

## File Encrypt/Decrypt w/ password prompt
openssl enc -ciphers # List
### Encrypt
openssl enc -aes-256-cbc -e -iter 1000 -salt \
    -in primes.dat -out primes.enc
### Decrypt
openssl enc -aes-256-cbc -d -iter 1000 \
    -in primes.enc -out primes.dec

## Hash
openssl list -digest-algorithms
openssl dgst -sha1 $file
openssl list -digest-commands
openssl sha1 $file

## Base64 utility (76 char limit)
# Base64 Encode
openssl base64 -e <<< 'Welcome to openssl wiki'
# Base64 Decode
openssl base64 -d <<< 'V2VsY29tZSB0byBvcGVuc3NsIHdpa2kK'
