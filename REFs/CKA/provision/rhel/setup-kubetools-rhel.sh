#!/usr/bin/env bash
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl

# Add Kubernetes yum repo 
# Exclude tools (exclude) from upgrade on `yum update`
cat <<EOF |sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Install tools : kubeadm kubelet kubectl crictl
sudo dnf -y install kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

# # Install cri-tools : crictl 
# # https://github.com/kubernetes-sigs/cri-tools
## UPDATE : Moved : See setup-containerd-rhel.sh
# VERSION="v1.28.0"
# wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
# sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
# rm -f crictl-$VERSION-linux-amd64.tar.gz

# Configure OS
## UPDATE : Moved : See prep-env.sh and setup-containerd-rhel.sh
## Set SELinux in permissive mode (effectively disabling it)
# sudo setenforce 0
# sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

## Turn off swap
# sudo swapoff -a
# sudo sed -i 's/\/swap/#\/swap/' /etc/fstab

## Set iptables bridging (@ setup-containerd-rhel.sh)
# cat <<EOF |sudo tee /etc/sysctl.d/k8s.conf
# net.bridge.bridge-nf-call-ip6tables = 1
# net.bridge.bridge-nf-call-iptables = 1
# EOF
# sudo sysctl --system

## UPDATE : Moved : See prep-env.sh and setup-containerd-rhel.sh
#sudo crictl config --set \
#    runtime-endpoint=unix:///run/containerd/containerd.sock
