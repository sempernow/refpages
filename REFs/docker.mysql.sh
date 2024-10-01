#!/usr/bin/env bash
#------------------------------------------------------------------------------
# MySQL @ Docker
# https://hub.docker.com/_/mysql
# Config @ Linux: /etc/my.cnf, /etc/mysql/conf.d/*
# Config @ Windows: my.ini @ installation folder
# -----------------------------------------------------------------------------

img=mysql:latest
u=root
p=admin
h=mydb

# Common network
docker network create $h

# Run MySQL server
docker run -d --rm --name $h --network $h -e MYSQL_ROOT_PASSWORD=$p $img

# Run MySQL client 
docker run --network $h -it $img mysql -h $h -u $u -p $p

# Shell @ MySQL server
docker exec -it $h /bin/bash

exit 0
######

## CONFIGURE 
## By default, MySQL only listens on localhost. 
## To allow requests from other machines, 
## set MySQL to listen on all IP addresses:

vi /etc/mysql/conf.d/10-custom.cnf

    [mysqld]
    bind-address = 0.0.0.0

# @ Server and Client boxes
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload