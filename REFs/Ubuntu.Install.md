# Ubuntu Intall 

## Install Ubuntu 18.04.1 LTS on VM @ Hyper-V 
- Create VM per "Quick Create ..."   
- Connects per `XRDP` 
- Auto-Shared Drives (per `XRDP` Session only) 
    - @ Connect (`XRDP`) > Local Resources > More > (__select__ _drives to share_)   
    Back @ Main menu > Save Settings (check-box)   
    - Shared Drives are mounted @ `~/shared-drives`

### [SSH](Network.SSH.sh "Network.SSH.sh")  

```bash
# Install OpenSSH
apt-get install openssh-server
# Check status of ssh daemon
systemctl status ssh.service
# Configure (See "Network.SSH.sh")
vim /etc/ssh/sshd_config
```  
### Other Useful ...
```bash 
sudo apt-get update  # Update pkg list from repo
sudo apt install -f  # fix broken dependencies

# Install a downloaded .deb pkg
sudo apt install -y $_DEB_PKG_PATH 
# or 
sudo dpkg -i $_DEB_PKG_PATH
sudo apt install -f  # --fix-broken (dependencies)
# ... to further config/fix ...
sudo dpkg-reconfigure $_DEB_PKG_NAME  # path sans '.deb' 

# Freeze filesystem (make read-only) @ next boot (only) 
apt-get install overlayroot
echo 'overlayroot="tmpfs"' >> '/etc/overlayroot.conf'
reboot
# Persist
overlayroot-chroot
```

### [Kodi](https://kodi.wiki/view/HOW-TO:Install_Kodi_for_Linux "Kodi.wiki")  

```bash 
# Kodi install
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:team-xbmc/ppa
sudo apt-get install -y kodi
```

- Kodi fails @ Armbian  ([MD](Armbian.html "@ browser"))  

### [Vagrant box @ VirtualBox VM on Ubuntu](http://www.codebind.com/linux-tutorials/install-vagrant-ubuntu-18-04-lts-linux/ "CODEBIND.COM")    

- Vagrant install ([MD](Vagrant.Install.html "If @ browser"))

