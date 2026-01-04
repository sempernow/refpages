#!/usr/bin/env bash
#######################################
### Healthcheck handled inline @ YAML
#######################################
exit
# Test PostgreSQL server : compatible with /bin/sh -c ".." 
[ $(psql -Aqt -c 'SELECT 1')1 == 11 ] && exit 0 || exit 1

exit
#------------------------------------------------------------------------------
#  Keepalived + Postgres Cluster : @ each server
#  https://www.linkedin.com/pulse/postgresql-replication-automatic-failover-bruno-queir%C3%B3s
# -----------------------------------------------------------------------------
# chmod +x /etc/keepalived/scripts/check_postgres
master_ip="172.17.0.2"
slave_ip="172.17.0.3"
pg_ctl="/usr/local/bin/pg_ctl"
pg_data="/var/lib/postgresql/data"
# Test if primary server's port is open and receiving connections:
(echo >/dev/tcp/${master_ip}/5432) &>/dev/null && { 
    echo "OK"; exit 0; 
} || { 
    ssh postgres@${slave_ip} "${pg_ctl} -D ${pg_data} promote"; exit 1; 
    #... instead of exiting, we could call a Keepalived-switchover function here.
}

exit
# Handle ephemeral IPs ...
ip -o -4 addr 
# This server's IP
hostname -i
# Other server's IP (if only one)
ip -4 neigh |grep 'REACHABLE' |awk '{print $1}'
#=> 10.0.200.25  
# Sans awk: 
#=> 10.0.200.25 dev eth1 lladdr 02:42:0a:00:c8:19 ref 1 used 0/0/0 probes 1 REACHABLE

