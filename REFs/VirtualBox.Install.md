# [VirtualBox Install](https://www.virtualbox.org/wiki/Downloads "virtualbox.org :: Downloads")

## @ Windows 

- Use [installer](https://www.virtualbox.org/wiki/Downloads "virtualbox.org :: Downloads")

## @ Ubuntu
```bash
sudo apt-get -y install virtualbox
```

## [@ RHEL/CentOS](https://www.virtualbox.org/wiki/Linux_Downloads)  
```bash 
# Download/Import its public key
sudo rpm --import https://www.virtualbox.org/download/oracle_vbox.asc
# Download/Install VirtualBox 5.5.20 (.rpm) 
sudo yum install -y \
    https://download.virtualbox.org/virtualbox/5.2.20/VirtualBox-5.2-5.2.20_125813_el7-1.x86_64.rpm  
```
- Fails if Linux @ VM on Hyper-V  ([MD](REF.Hyper-V.Nested-Virtualization.html "@ browser"))  

    ```bash
    There were problems setting up VirtualBox.  
    To re-start the set-up process, run
      /sbin/vboxconfig  
    # ... did, as root, to same/repeated effect.
    ```