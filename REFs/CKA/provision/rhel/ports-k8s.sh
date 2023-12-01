# Open required ports
## firewall-cmd is interface to firewalld
## https://kubernetes.io/docs/reference/networking/ports-and-protocols/
## https://docs.oracle.com/en/operating-systems/olcne/1.1/start/ports.html

[[ $(systemctl is-active firewalld.service) == 'active' ]] || sudo systemctl enable --now firewalld.service

## @ Worker nodes
sudo firewall-cmd --permanent --zone=trusted --add-interface=cni0
sudo firewall-cmd --permanent --add-port=443/tcp            # kube-apiserver inbound
sudo firewall-cmd --permanent --add-port=10250/tcp          # kubelet API inbound
sudo firewall-cmd --permanent --add-port=10255/tcp          # kubelet Node/Pod CIDRs (v1.23.6+)
sudo firewall-cmd --permanent --add-port=10256/tcp          # GKE LB Health checks
sudo firewall-cmd --permanent --add-port=30000-32767/tcp    # NodePort Services inbound

## @ Control Plane nodes
sudo firewall-cmd --permanent --zone=trusted --add-interface=cni0
sudo firewall-cmd --permanent --add-port=443/tcp            # kube-apiserver inbound
sudo firewall-cmd --permanent --add-port=2379-2380/tcp      # etcd, kube-apiserver inbound
sudo firewall-cmd --permanent --add-port=6443/tcp           # kube-apiserver inbound
sudo firewall-cmd --permanent --add-port=10250/tcp          # kubelet API inbound
sudo firewall-cmd --permanent --add-port=10255/tcp          # kubelet Node/Pod CIDRs (v1.23.6+)
sudo firewall-cmd --permanent --add-port=10256/tcp          # GKE LB Health checks
sudo firewall-cmd --permanent --add-port=10257/tcp          # kube-controller-manager inbound
sudo firewall-cmd --permanent --add-port=10259/tcp          # kube-scheduler inbound

# @ Kubernetes versions below 1.17
#sudo firewall-cmd --permanent --add-port=10251/tcp      # kube-scheduler (moved to 10259)
#sudo firewall-cmd --permanent --add-port=10252/tcp      # kube-controller-manager (moved to 10257)
