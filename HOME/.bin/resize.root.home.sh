#!/bin/bash
# ===========================================================================
# This wonderful script shrinks /home and grows /root partitions. 
# home is shrunk to 1GB, and root absorbs all the free space on the disk.
# Also, home is saved and restored !
# 
# Presumes both home and root partitions are on the same disk, 
# and under same lv and name, '/dev/mapper/c7'.
#  
# Run as root user in Single User mode, `/sbin/init 1`.

# Ran successfully @ 2018-05-17 to remedy a CentOS 7 update/upgrade 
# that failed due to insufficient space @ /root.
# REF: https://serverfault.com/questions/771921/how-to-shrink-home-and-add-more-space-on-centos7 
# ===========================================================================
exit

umount /dev/mapper/c7-home
lvremove /dev/mapper/c7-home
lvcreate -L 1GB -n home c7
mkfs.xfs /dev/c7/home
mount /dev/mapper/c7-home
lvextend -r -l +100%FREE /dev/mapper/c7-root
tar -xzvf /root/home.tgz -C /home
printf "\n %s\n\n" 'Check for valid UUIDs @ /etc/fstab ... '
cat /etc/fstab

