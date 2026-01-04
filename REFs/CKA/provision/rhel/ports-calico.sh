
# Open required ports
## firewall-cmd is interface to firewalld
## Calico : https://docs.tigera.io/calico/latest/getting-started/kubernetes/requirements

[[ $(systemctl is-active firewalld.service) == 'active' ]] || sudo systemctl enable --now firewalld.service

## @ Worker nodes
sudo firewall-cmd --permanent --add-port=179/tcp        # BGP (Calico)
sudo firewall-cmd --permanent --add-port=4789/udp       # VXLAN (Calico/Flannel)
sudo firewall-cmd --permanent --add-port=5473/tcp       # Calico Typha agent hosts
sudo firewall-cmd --permanent --add-port=51820/udp      # Wireguard (Calico)
sudo firewall-cmd --permanent --add-port=51821/udp      # Wireguard (Calico)

## @ Control Plane nodes
sudo firewall-cmd --permanent --add-port=179/tcp        # BGP (Calico)
sudo firewall-cmd --permanent --add-port=4789/udp       # VXLAN (Calico/Flannel)
sudo firewall-cmd --permanent --add-port=51820/udp      # Wireguard (Calico)
sudo firewall-cmd --permanent --add-port=51821/udp      # Wireguard (Calico)
