#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  Kubernetes tools : kubeadm
# -----------------------------------------------------------------------------

# @ kubeadm init
cfg=kubeadm.init.config.yaml

# Pull all core K8s images prior to kubeadm init
sudo kubeadm config images pull

# Generate a STABLE certificateKey (sha256 hex) for later (init/join) use
## kubeadm certs certificate-key
key=$(sudo kubeadm certs certificate-key) # Set in kubeadm configuration file: kind: InitConfiguration
# Upload certificates beforehand; instead of "kubeadm init --upload-certs" 
sudo kubeadm init phase upload-certs --upload-certs --certificate-key $key
# Use key declared at kubeadm configuration file: kind: InitConfiguration
sudo kubeadm init phase upload-certs --upload-certs --config $cfg 
#... Certificates @ /etc/kubernetes/pki/*

# Generate a STABLE bootstrap token ([a-z0-9]{6}.[a-z0-9]{16}) for later (init/join) use 
token=$(kubeadm token generate) # Set in kubeadm configuration file: kind: InitConfiguration
# Use token declared at kubeadm configuration file: kind: InitConfiguration
kubeadm init phase bootstrap-token --config $cfg

kubeadm config print init-defaults |tee $cfg
vim $cfg #... modify the configuration
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

# Join command @ CONTROL node(s)
sudo kubeadm join $vipp \
    --ignore-preflight-errors=Mem \
    --token rm7p6u.ujlcmduwnktx5g97 \
    --discovery-token-ca-cert-hash sha256:13d77f4b489877b86640c71a7aaff0e66e2975481d823f1f64a6f94425d07956 \
    --control-plane --certificate-key 44cf77610eba54fe1c3837ad3a38a4d758e503073091b81628a43d08c70904d7 \
    |& tee kubeadm.join.$(hostname).log

# Join command @ WORKER node(s)
## Note : Is exactly that for Control node sans "--control-plane" and "--certificate-key KEY" flags/values
sudo kubeadm join $vipp \
    --ignore-preflight-errors=Mem \
    --token rm7p6u.ujlcmduwnktx5g97 \
    --ignore-preflight-errors=Mem \
    --discovery-token-ca-cert-hash sha256:13d77f4b489877b86640c71a7aaff0e66e2975481d823f1f64a6f94425d07956 \
    |& tee kubeadm.join.$(hostname).log

# Generate a NEW join COMMAND for control node  (@ certs expire and so reload)
## 1. Re upload certificates in the already working master node:
kubeadm init phase upload-certs --upload-certs # Generate a new certificate key.
## 2. Print join command in the already working master node:
kubeadm token create --print-join-command
## 3. Join a new control plane node:
$JOIN_COMMAND_FROM_STEP2 --control-plane --certificate-key $KEY_FROM_STEP1.

# Generate a new control-plane certificate key. 
# Use at kubeadm init|join --certificate-key $key or 
key=$(sudo kubeadm certs certificate-key)

# Generating kubeconfig files, ~/.kube/config, for ADDITIONAL USERS
# https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/#kubeconfig-additional-users
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-kubeconfig/
kubeadm kubeconfig user --client-name=foo --config=example.yaml
# Get settings of target cluster
kubectl get cm kubeadm-config -n kube-system -o=jsonpath="{.data.ClusterConfiguration}"

