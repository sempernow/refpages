#!/usr/bin/env bash

[[ "$(whoami)" == 'root' ]] || exit 11

# Stop kubelet and all Kubernetes related processes
systemctl stop kubelet || exit 22
[[ $(type -t docker) ]] && systemctl stop docker
systemctl stop containerd || exit 33

# Reset kubeadm installed state
kubeadm reset -f

# If using etcd in a dedicated directory (for external etcd)
rm -rf /var/lib/etcd

# Remove virtual network interfaces
dev='lxc cni flann cali cili'
rem(){
    ip -brief link |grep $1 |cut -d' ' -f1 |cut -d'@' -f1 \
        |xargs -n1 /bin/bash -c '
            [[ $1 ]] || exit
            ip link set dev $1 down
            ip link delete $1
        ' _
}
unalias ip 2>/dev/null
export -f rem
printf "%s\n" $dev |xargs -n1 /bin/bash -c 'rem $1 2>/dev/null' _

# Flush iptables
iptables --flush
iptables --delete-chain
iptables -t nat --flush
iptables -t nat --delete-chain
iptables -t mangle --flush
iptables -t mangle --delete-chain
#nft flush table ip nat
#nft flush table ip mangle

# Clear IPVS tables
[[ $(type -t ipvsadm) ]] && ipvsadm --clear

# Clear CNI configuration
rm -rf /etc/cni/net.d
rm -rf /var/lib/cni

# Clear remaining kubelet files
rm -rf /var/lib/kubelet

# Optionally, remove all docker/containerd storage
# Warning: This will remove all containers, including their data volumes
rm -rf /var/lib/docker
rm -rf /var/lib/containerd

[[ $(type -t docker) ]] && systemctl start docker
systemctl start containerd
systemctl start kubelet

