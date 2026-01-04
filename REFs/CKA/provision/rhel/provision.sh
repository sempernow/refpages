#!/usr/bin/env bash
###############################################################################
# Working from an administrative machine, 
# provision a list of targeted machines with all that is necessary 
# for a Vanilla Kubernetes cluster using kubadm.
#
# Client-machine requirements:
# - SSH params for configured for target machine(s) 
#   - See ~/.ssh/config
#
# Target-machine requirements:
# - OS: AlmaLinux 8.
# - CPUs: 2+ if control node, else 1+.
# - Memory: 2048GB+.
# - sudo sans password prompt:
#    `echo "$USER ALL=(ALL) NOPASSWD:ALL" |sudo tee /etc/sudoers.d/$USER`
#
# ARGs: <list of ssh-configured machines>
###############################################################################
[[ $1 ]] && {
    ssh_configured_machines="$@"
} || {
    echo "REQUIREs the list of ssh-configured machines to provision." 
    echo "USAGE : ${0##*/} VM1 VM2 ..." 
    exit
}

_ssh(){ 
    mode=$1;shift
    for vm in $ssh_configured_machines
    do
        echo "=== @ $vm : $1 $2 $3 ..."
        [[ $mode == '-s' ]] && ssh $vm "/bin/bash -s" < "$@"
        [[ $mode == '-c' ]] && ssh $vm "/bin/bash -c" "$@"
        [[ $mode == '-x' ]] && ssh $vm "$@"
    done 
}

# Prep hosts 
_ssh -s 'prep-env.sh'
_ssh -s 'ports-k8s.sh'
_ssh -s 'ports-istio.sh'
_ssh -s 'ports-calico.sh'

# Install tc (for kubeadm), and some rudimentary tools lacking in many RHEL-type distros.
_ssh -x 'sudo dnf -y install iproute-tc bash-completion bind-utils wget git jq vim tree'

# Install yq
VERSION=v4.35.1
BINARY=yq_linux_amd64
url="https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz"

_ssh -x "
    wget $url -O - |tar xz \
        && sudo mv ${BINARY} /usr/bin/yq \
        && sudo chown root:root /usr/bin/yq
"

# Install containerd through Docker CE install.
_ssh -s 'setup-containerd-rhel.sh'

# Configure containerd to use systemd driver instead of its default (cgroupfs driver).
_ssh -x "
    echo '$(<etc.containerd.config-cka.toml)' |sudo tee /etc/containerd/config.toml
    sudo systemctl enable containerd.service
    sudo systemctl restart containerd.service
"

# Configure Docker server to start on boot
_ssh -x "
    sudo systemctl --now enable docker.service
    sudo systemctl status docker.service
"

# Install kubernetes tools
_ssh -s 'setup-kubetools-rhel.sh'

echo '=== DONE'
echo 'After initializing the control node, follow instructions and use kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml to install the calico plugin (control node only). On the worker nodes, use sudo kubeadm join ... to join'
