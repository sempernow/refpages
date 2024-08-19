#!/usr/bin/env bash
########################################
# Configure kernel for K8s CRI and CNI
# - Idempotent
########################################

# Install kernel headers 
[[ $(rpm -q kernel-headers) ]] || sudo dnf -y install kernel-headers-$(uname -r) || exit 10
[[ $(rpm -q kernel-devel) ]]   || sudo dnf -y install kernel-devel-$(uname -r)   || exit 11

unset _flag_config_kernel

ok(){
    # Load kernel modules (now), smartly (okay if already loaded)
    sudo modprobe br_netfilter  
    [[ $(lsmod |grep br_netfilter) ]] || return 21

    sudo modprobe overlay  
    [[ $(lsmod |grep overlay) ]] || return 22

    sudo modprobe ip_vs  
    [[ $(lsmod |grep ip_vs) ]] || return 23

    sudo modprobe ip_vs_rr  
    [[ $(lsmod |grep ip_vs_rr) ]] || return 24

    sudo modprobe ip_vs_wrr  
    [[ $(lsmod |grep ip_vs_wrr) ]] || return 25
    
    sudo modprobe ip_vs_sh  
    [[ $(lsmod |grep ip_vs_sh) ]] || return 26

    # Load kernel modules on boot
    conf='/etc/modules-load.d/kubernetes.conf'
    [[ $(cat $conf 2>/dev/null |grep 'overlay') ]] && return 0
    _flag_config_kernel=1
    ## br_netfilter enables transparent masquerading 
    ## and facilitates Virtual Extensible LAN (VxLAN) traffic 
    ## between Pods across the cluster.
	cat <<-EOH |sudo tee $conf
	br_netfilter
	ip_vs
	ip_vs_rr
	ip_vs_wrr
	ip_vs_sh
	overlay
	EOH

    # Confirm file
    [[ $(cat $conf 2>/dev/null |grep 'overlay') ]] && return 33
}
ok || exit $?

ok(){
    # Set kernel runtime params (sysctl) for K8s networking
    conf='/etc/sysctl.d/kubernetes.conf'
    [[ $(cat $conf 2>/dev/null |grep 'net.bridge.bridge-nf-call-iptables  = 1') ]] && return 0
    _flag_config_kernel=1
	cat <<-EOH |sudo tee $conf
	net.ipv4.ip_forward = 1
	net.bridge.bridge-nf-call-ip6tables = 1
	net.bridge.bridge-nf-call-iptables  = 1
	EOH
    # |Kernel Parameter	                    | Description                      |
    # |-------------------------------------|----------------------------------|
    # |`net.bridge.bridge-nf-call-iptables` |Bridged IPv4 traffic via iptables.|
    # |`net.bridge.bridge-nf-call-ip6tables`|Bridged IPv6 traffic via iptables.|
    # |`net.ipv4.ip_forward`                |IPv4 packet forwarding.           |

    # Confirm file
    [[ $(cat $conf 2>/dev/null |grep 'net.bridge.bridge-nf-call-iptables  = 1') ]] || return 44
}
ok || exit $?
    
# If configuration changed, then apply settings else fail
[[ $_flag_config_kernel ]] && {
    sudo sysctl --system |grep Applying || exit 1

    # Disable swap (idempotent)
    sudo swapoff -a
    swap="$(cat /etc/fstab |grep ' swap' |grep -v '^ *#' |awk '{print $1}')"
    [[ $swap ]] && swap="$(echo $swap |awk '{print $1}')"
    [[ $swap ]] && sudo sed -i "s,$swap,#$swap," /etc/fstab
}

echo ok
