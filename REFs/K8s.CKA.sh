#!/usr/bin/env bash
exit # DO NOT RUN this script

# Cluster install
sudo swapoff -a 
hostname -I # Get IPv4
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$ip
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

# Untaint all control-plane nodes
kubectl taint nodes --all node-role.kubernetes.io/control-plane:NoSchedule-
# Verify
kubectl describe node |grep Taints

# Upgrade kubeadm : Control nodes then worker nodes
# - Okay if etcd leader is not 1st node upgraded.
# - Worker nodes by same method; NOT drain/delete/join (preserve labels; no scheduler churn).
# https://v1-34.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
sudo apt-mark unhold kubdadm # Required only if prior `sudo apt-mark hold kubeadm` 
sudo apt-get update &&
    sudo apt-get instll -y kubeadm='1.n.n' # No "v" prefix

sudo apt-mark unhold kubeadm &&
    sudo apt-get update &&
        sudo apt-get install -y kubeadm='1.n.n-*' &&
            sudo apt-mark hold kubeadm

# Whilst kubelet is running:
kubectl drain $node --ignore-daemonsets
sudo kubeadm upgrade plan 
sudo kubeadm upgrade apply v1.n.n # Requires "v" prefix unlike binary installs

# Other nodes, repeat same except actual upgrade command ...
sudo kubeadm upgrade node # Instead of updgrade apply <version>

# Updgrade kubelet and kubectl
kubectl drain $node --ignore-daemonsets
sudo apt-mark unhold kubelet kubectl &&
    sudo apt-get update &&
        sudo apt-get install -y kubelet='1.n.n-*' kubectl='1.n.n-*' &&
            sudo apt-mark hold kubelet kubectl

sudo systemctl restart kubelet
kucectl uncordon $node

# Helpers 
k(){ kubectl "$@"; }
# Set cluster context
kx(){ kubectl config use-context "$@"; }
# Set namespace of current context
kn(){ kubectl config set-context --current --namespace "$@"; }
# Tab completion
source <(kubectl completion bash)
complete -F __start_kubectl k  # For alias k too
# To YAML
export do='--dry-run=client -o yaml'
# Terminate pod immediately
export now='--force --grace-period=0'

tee -a ~/.vimrc <<EOH
set tabstop=2
set expandtab
set shiftwidth=2
EOH
# Else
echo "set tabstop=2 shiftwidth=2 expandtab" >> ~/.vimrc