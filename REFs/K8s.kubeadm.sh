#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  Kubernetes tools : kubeadm
# -----------------------------------------------------------------------------

# @ kubeadm init : Initial/Temp configuration file
cfg=kubeadm-config.yaml # Default is ConfigMap kubeadm-config.data.ClusterConfiguration 

# ClusterConfiguration : /etc/kubernetes/kubeadm-config.yaml (Local file created only by an administrator)
kubectl -n kube-system get cm kubeadm-config -o jsonpath={.data.ClusterConfiguration}
# KubeletConfiguration : /var/lib/kubelet/config.yaml (created on kubeadm init/join)
kubectl -n kube-system get cm kubelet-config -o jsonpath={.data.kubelet}
# Mod and sync changes across all nodes
kubectl -n kube-system edit cm kubelet-config
sudo kubeadm upgrade node phase kubelet-config # Pull cm .data.kubelet to /var/lib/kubelet/config.yaml
# Generate all kubeconfig
sudo kubeadm init phase kubeconfig all

# Pull all core K8s images prior to kubeadm init
sudo kubeadm config images pull --config $cfg

# Generating NEW cluster PKI @ /etc/kubernetes/pki/ : Run per control node
sudo kubeadm init phase certs all --config $cfg # Default config is ConfigMap kubeadm-config.data.ClusterConfiguration
# Generate a STABLE certificateKey (sha256 hex) for later (init/join) use
key=$(sudo kubeadm certs certificate-key) # @ InitConfiguration.certificateKey
# Upload certificates beforehand; instead of "kubeadm init --upload-certs" 
sudo kubeadm init phase upload-certs --upload-certs --certificate-key $key
# Use key declared at InitConfiguration.certificateKey
sudo kubeadm init phase upload-certs --upload-certs --config $cfg 
# Generate a STABLE bootstrap token ([a-z0-9]{6}.[a-z0-9]{16}) for later (init/join) use 
token=$(kubeadm token generate) # @ InitConfiguration.bootstrapTokens.token
# Use token declared at kubeadm configuration file: kind: InitConfiguration
kubeadm init phase bootstrap-token --config $cfg

kubeadm config print init-defaults |tee $cfg
vim $cfg #... modify the configuration to add these params
sudo kubeadm init --config $cfg

vipp='192.168.0.100:8443' # HA-LB Endpoint
pnet='10.10.0.0/16' # Default: 10.244.0.0/16
snet='10.55.0.0/16' # Default: 10.96.0.0/12
## @ --cri-socket $cri
#cri='unix:///var/run/containerd/containerd.sock'
#cri='unix:///run/cri-dockerd.sock'

sudo kubeadm init -v5 \
    --upload-certs \
    --ignore-preflight-errors=Mem \
    --control-plane-endpoint "$vipp" \
    --pod-network-cidr "$pnet" \
    --service-cidr "$snet" \
    |& tee kubeadm.init.$(hostname).log

# Create --ca-cert-hashes value : JoinConfiguration.bootstrapTokens.caCertHash,
# which is the SHA-256 hash of public key
hash=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
        |openssl rsa -pubin -outform der 2>/dev/null \
        |openssl dgst -sha256 -hex \
        |sed 's/^.* //' \
)
# Join command @ CONTROL node(s)
sudo kubeadm join $vipp \
    --ignore-preflight-errors=Mem \
    --token $token \
    --discovery-token-ca-cert-hash $hash \
    --control-plane --certificate-key $key \
    |& tee kubeadm.join.$(hostname).log

# Join command @ WORKER node(s)
## Note : Is exactly that for Control node sans "--control-plane" and "--certificate-key KEY" flags/values
sudo kubeadm join $vipp \
    --ignore-preflight-errors=Mem \
    --token $token \
    --ignore-preflight-errors=Mem \
    --discovery-token-ca-cert-hash $hash \
    |& tee kubeadm.join.$(hostname).log

# Generate a NEW join COMMAND for control node  (@ certs expire and so reload)
## 1. Re upload certificates in the already working master node:
kubeadm init phase upload-certs --upload-certs # Generate a new certificate key.
## 2. Print join command in the already working master node:
kubeadm token create --print-join-command
## 3. Join a new control plane node:
$JOIN_COMMAND_FROM_STEP2 --control-plane --certificate-key $KEY_FROM_STEP1.

# TLS PKI
# Generate a new control-plane certificate key. 
# Use at kubeadm init|join --certificate-key $key or 
key=$(sudo kubeadm certs certificate-key)
# Check expiration
kubeadm certs check-expiration
# Fix client-cert rotation failure
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/#kubelet-client-cert

# Generating kubeconfig files, ~/.kube/config, for ADDITIONAL USERS
# https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/#kubeconfig-additional-users
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-kubeconfig/
# Generate a kubeconfig file with credentials for user $user of group $group that is valid for 1 day:
kubeadm kubeconfig user --config $kubeconfig_file --org $group --client-name $user --validity-period 24h
# Get settings of existing cluster
kubectl get cm kubeadm-config -n kube-system -o=jsonpath="{.data.ClusterConfiguration}"


# Upgrade : Sync changes of ConfigMap (kubelet-config, kubeadm-config)
# Download the kubelet configuration from the kubelet-config ConfigMap stored in the cluster
kubeadm upgrade node phase kubelet-config 
# Upgrade the control plane instance deployed on this node, if any
kubeadm upgrade node phase control-plane 