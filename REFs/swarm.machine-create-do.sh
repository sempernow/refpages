#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Create servers @ DigitalOcean 
# https://docs.docker.com/machine/drivers/digital-ocean/
# -----------------------------------------------------------------------------

########################################################
# docker-machine create ... @ MINGW or PowerShell ONLY
########################################################

# Source DO_TOKEN
. ./../../assets/keys/create-servers-do.sh
# Set other params 
machines='dn1,dn2,dn3' # vendor/zone/instance
region='nyc1'
image='ubuntu-18-04-x64'
size='s-1vcpu-1gb' # https://developers.digitalocean.com/documentation/v2/#list-all-sizes
ssh_user='root' # Default for Ubuntu @ DigitalOcean 
ssh_key_path=~/.ssh/swarm-do-rsa
ssh_fpt="$(ssh-keygen -E md5 -lf ${ssh_key_path}.pub | awk '{print $2}' | cut -d ':' -f 1 --complement)"

echo "=== Create machines (idempotent)"
for vm in $(printf $machines | sed 's/,/ /g'); do 
    echo "=== @ '$vm'"
    [[ $( docker-machine ls -q | grep $vm ) ]] && {
        echo "Machine '$vm' already exists."
    } || \
        docker-machine create \
            --driver='digitalocean' \
            --digitalocean-access-token="${DO_TOKEN}" \
            --digitalocean-image=$image \
            --digitalocean-size=$size \
            --digitalocean-ssh-user=$ssh_user \
            --digitalocean-ssh-key-fingerprint=$ssh_fpt \
            --digitalocean-region=$region \
            --digitalocean-tags='swarm' \
            --digitalocean-ssh-key-path=$ssh_key_path \
            --digitalocean-userdata='./userdata.install-docker.sh' \
            $vm  # MUST be sequential; FAILs as background process(es).
            
            # NOT @ multi-vendor swarm
            #--digitalocean-private-networking=true \
done
#... unlike AWS driver, these VMs are ready to go upon creation; user configured
# Is this due merely to user being 'root' vs 'ubuntu'?

exit 
