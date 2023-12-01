#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Initialize host (node) for use by store-user service (containers)
# - Add store-user user:group (UID:GID)
# - Add default user (1000) to store-user group
# - Reset owner and permissions at STORE and ASSETS directories.
# -----------------------------------------------------------------------------

# Store user
#storeUser='postgres';uid='70';gid='70'
storeUser=$1;uid=$2;gid=$3
#echo "store user: $storeUser, UID: $uid, GID: $gid" |sudo tee /mnt/init.log

#######################################################################
# Users/Groups 

# Create store-user user:group 
sudo groupadd --gid $uid $storeUser
sudo adduser --uid $uid --gid $gid --gecos "" --disabled-password --no-create-home $storeUser

# Get name of the (standard) default user (uid=1000)
user1000=$(cat /etc/passwd |grep ':x:1000:' |awk -F ':' '{print $1}')
# Add default user to store-user group (useful @ node administration)
sudo usermod -aG $storeUser $user1000
# Add store user to default-user group (useful @ store administration)
sudo usermod -aG 1000 $storeUser

#####################################################################
# FS : Reset owner and permissions (FS mode) for Docker bind mounts

# @ store
store=${PATH_ABS_VM_STORE:-/mnt/store}
# Make directories (if not exist)
sudo mkdir -pm 0770 $store/pgha/{pgdata,archive,etc}
# Set owner (UID:GID), recursively
sudo chown -R $uid:$gid $store
# Set FS mode (permissions), recursively
sudo chmod -R 0770 $store

# @ assets
uid=${CTNR_USER:-1000};gid=${CTNR_GROUP:-1000}
assets=${PATH_ABS_VM_ASSETS:-/mnt/assets}
# Make directories (if not exist)
sudo mkdir -pm 0770 $assets
# Set owner (UID:GID), recursively
sudo chown -R $uid:$gid $assets
# Set FS mode (permissions), recursively
sudo chmod -R 0770 $assets

# Show result
ls -ahl $assets
ls -ahl $store 


