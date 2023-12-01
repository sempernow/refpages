#!/bin/bash

# Apps 
apt-get install libssl-dev -y      # openssl crypto lib
apt-get install openssh-client -y  # ssh client
apt-get install openssh-server -y  # ssh server
apt-get install man-db -y      # man pages
apt-get install vim -y         # vim editor 
apt-get install rsync -y       # rsync

exit

# $HOME dir CHANGE ...
sudo vim /etc/passwd  # E.g., from `/home/uZer` to `/mnt/s/HOME`

# Kernel and dev tools
apt-get update                      # pkgs version-info update      
apt-get install build-essential -y  # gcc, make, ...
apt-get install dh-autoreconf -y    # autoreconf 
apt-get install strace -y           # debugger
# @ Kali
#apt-get dist-upgrade            
#apt-get install metasploit-framework  # turn off anti-virus

# Python / AWS-CLI FAILs 
# Python 2  https://linuxize.com/post/how-to-install-pip-on-debian-9/
apt-get install python-pip -y  # pip (python 2.7)  
pip install aws-cli            # AWS CLI app install
pip install --upgrade awscli   # AWS CLI app upgrade