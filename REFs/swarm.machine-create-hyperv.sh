#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Create servers @ Microsoft Hyper-V (boot2docker ISO)
# https://docs.docker.com/machine/drivers/hyper-v/
# -----------------------------------------------------------------------------

########################################################
# docker-machine create ... @ MINGW or PowerShell ONLY
########################################################

machines='h1,h2,h3' 
switch='External Switch'
switch='External-GbE'
ram=1024
hdd=10000
echo "=== Create machines (idempotent)"
for vm in $(printf $machines | sed 's/,/ /g'); do 
    echo "=== @ $vm"
    [[ $( docker-machine ls -q | grep $vm ) ]] && {
        echo "Machine '$vm' already exists."
    } || \
        docker-machine create -d hyperv \
            --hyperv-virtual-switch "$switch" \
            --hyperv-memory $ram --hyperv-disk-size $hdd \
            $vm  # MUST be sequential; FAILs as background process(es).
done

# Persistent storage (pg1, pg2) : /mnt/store/pgha <=> /mnt/sda1
docker-machine ssh $vm '
    sudo mkdir -p /mnt/store
    sudo mkdir -p /mnt/sda1/pgha
    sudo chown -R 70:70 /mnt/sda1/pgha/
    sudo ln -s /mnt/sda1/pgha /mnt/store/pgha
    sudo ls -ahl /mnt/store/pgha/
'

exit 

# docker-machine create ... installs TinyCore (`boot2docker.iso`); 
# TinyCorre distro has package manager: tce-load 
# Download and install
sudo tce-load -w -i tor.tcz nginx.tcz tzdata.tcz

# Index of available TinyCore packages:
# http://distro.ibiblio.org/tinycorelinux/10.x/x86/tcz/

# Reboot tinycore
sudo shutdown -r now