#!/usr/bin/env bash
# ------------------------------------------------------------------------------
#  Create swarm @ DigitalOcean 
# -----------------------------------------------------------------------------

export vm='d1' # reset to master
export m1=$vm  # Swarm Master/Leader
export ip=$(docker-machine ip $m1) # PUBLIC IP (We want private @ DO)
export user=$(docker-machine inspect $m1 --format={{.Driver.SSHUser}})
export key=$(docker-machine inspect $m1 --format={{.Driver.SSHKeyPath}})
export port=$(docker-machine inspect $m1 --format={{.Driver.SSHPort}})
# vm: i1, m1: i1, ip: 3.88.249.184, user: ubuntu, key: C:\Users\X1\.docker\machine\machines\i1\id_rsa, port: 22
echo "vm: $vm, m1: $m1, ip: $ip, user: $user, key: $key, port: $port"

# Set Control Plane comms to Private IP
nic='eth1' # per `--digitalocean-private-networking=true`
LEADER_IP=$(docker-machine ssh $m1 ip addr show dev $nic | grep inet | grep $nic | awk '{print $2}' | sed 's#/.*##g') 

echo $LEADER_IP # 10.116.0.2 

# create a swarm as all managers
docker-machine ssh $m1 docker swarm init --advertise-addr "$LEADER_IP"

# note that if you use eth1 above (private network in digitalocean) it makes the below
# a bit tricky, because docker-machine lists the public IP's but we need the 
# private IP of manager for join commands, so we can't simply envvar the token
# like lots of scripts do... we'd need to fist get private IP of first node

# TODO: provide flexable numbers at cli for x managers and x workers
JOIN_TOKEN=$(docker-machine ssh $m1 docker swarm join-token -q manager)

for i in 2 3; do
    docker-machine ssh d$i docker swarm join --token "$JOIN_TOKEN" "$LEADER_IP"
done

docker-machine env $m1
export DOCKER_HOST="tcp://${LEADER_IP}:2376" # Reset to accomodate private NIC (eth1) setup 
eval $(docker-machine env $m1)

docker node ls # validate swarm

exit 
