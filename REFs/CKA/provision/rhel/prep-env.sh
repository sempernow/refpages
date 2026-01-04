# Disable swap : required by kubelet
sudo swapoff -a
sudo systemctl stop swap.target --now && sudo systemctl disable swap.target --now
## Comment out or delete this entry:
## /dev/mapper/almalinux-swap none                    swap    defaults        0 0
grep -v swap /etc/fstab |sudo tee /etc/fstab
## Also see systemd.swap

# Disable SELinux : now and forever
sudo setenforce 0
sudo sed -i -e 's/^SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config

## Configure local DNS : limited to self recognition 
cat <<-EOH |sudo tee /etc/hosts
127.0.0.1 localhost $(hostname)
::1       localhost $(hostname)
EOH
