#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Provision a new K8s user for USER having certificate-based authn/authz
# https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user
# -----------------------------------------------------------------------------
sudo k3s kubectl get node && alias k='sudo k3s kubectl'

user=${USER,,} && [[ $user ]] || exit 1
# CSR denied if groups include "system:masters"
grp_1=devops
grp_2=system:basic-user 
algo=ed25519 # rsa|ed25529
#algo=rsa # rsa|ed25529
# Create private key
openssl genpkey -algorithm $algo -out $user.key
# Create CSR 
openssl req -new -key $user.key -out $user.csr -subj "/CN=$user/O=$grp_1/O=$grp_2"
    # To use `-config CNF` (file) instead of `-subj ...` : 
    # ... -extensions v3_req -config $user.cnf 
    # For CNF declarations, see `man openssl-req`
# Create K8s csr object
cat <<-EOH |k apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $user
spec:
  request: $(cat $user.csr |base64 |tr -d "\n")
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # one day
  usages:
  - client auth
EOH

# Create CA-signed cert
# - by signing CSR using CA key (requires access)
#ca=ca
#openssl x509 -req -in $user.csr -CA $ca.crt -CAkey $ca.key -CAcreateserial -out $user.crt -days 365
# - by approving CSR via API
csr=$user
k certificate approve $csr

# Get/save the cert
k get csr $csr -o jsonpath='{.status.certificate}' \
    |base64 -d \
    |tee $user.crt

# Parse to view Subject field
k get csr $user -o jsonpath='{.status.certificate}' \
    |base64 -d \
    |openssl x509 - -subject -noout

# Extract public key (useful for other tasks) from private key
openssl pkey -in $user.key -pubout -out $user.pub
# Extract public key from certificate
openssl x509 -in $user.crt -pubkey -noout -out $user.pub.crt.key
# Compare the two (want identical)
diff $user.pub $user.pub.crt.key

# Create Role
role=$grp_1
k create role $role \
    --verb=create \
    --verb=get \
    --verb=list \
    --verb=update \
    --verb=delete \
    --resource=pods

# Create RoleBinding
k create rolebinding $role-binding-$user \
    --role=$role \
    --user=$user

# Add user to kubeconfig 
# - Add creds
k config set-credentials $user \
    --client-key=$user.key \
    --client-certificate=$user.crt \
    --embed-certs=true
# - Add context
cluster=default # @ K3s 
k config set-context $user \
    --cluster=$cluster \
    --user=$user

echo '
# Authn/Authz test:
###################
k config use-context $USER  # Change context to this new user
#... and run a naked Pod ...
k run bbox --image=busybox -- sleep 1d
k get pod                   # Okay
k exec -it bbox -- hostname # FAILs authz
k config use-context default
k exec -it bbox -- hostname # Okay
k config use-context $USER 
k delete pod bbox           # Pod terminates, but reports errors during
'

exit $?
#######



☩ k get clusterrolebinding cluster-admin -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  ...
  name: cluster-admin
  resourceVersion: "141"
  uid: 7322ec4e-b8ca-4e6c-8ac6-3410b5b720bf
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:masters

# View certificate text
kubectl config view --raw -o jsonpath='{.users[].user.client-certificate-data}' \
    |base64 -d \
    |openssl x509 -noout -text 
    # Else declared fields only : Much more readable : See `man x509v3_config` for all extensions
    x509v3='subjectAltName,issuerAltName,basicConstraints,keyUsage,extendedKeyUsage,authorityInfoAccess,subjectKeyIdentifier,authorityKeyIdentifier,crlDistributionPoints,issuingDistributionPoints,policyConstraints,nameConstraints'
... |openssl x509 -noout -subject -issuer -startdate -enddate -ext "$x509v3"

# Send GET request to the protected API server using TLS certificate and key
curl -k \
    --cert <(k config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' |base64 -d) \
    --key <(k config view --raw -o jsonpath='{.users[0].user.client-key-data}' |base64 -d) \
    https://$(k -n kube-system get svc traefik -o jsonpath='{.status.loadBalancer.ingress[].ip}'):6443/version