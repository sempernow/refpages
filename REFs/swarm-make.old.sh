#!/usr/bin/env bash
# ------------------------------------------------------------------------------
#  Create cross-vendor (AWS+DO) swarm 
# -----------------------------------------------------------------------------

# Reset Route53 IPs of the associated domain 
./auto-update-route53-ips.sh

# Regenerate certificates (for the new IP address; EIP)
machines='aa3,aa2,aa1' 
# If swarm comms is per public IP, then certs may be invalid with each machine restart
for vm in $(printf $machines | sed 's/,/ /g'); do 
    echo "Regenerate Certificates @ node '$vm'"
    rm ~/.docker/machine/machines/$vm/{ca,cert,key,server,server-key}.pem -f
    docker-machine regenerate-certs $vm --force
done
# Verify 
docker-machine ls 

# Rotate certs (UNNECESSARY)
docker swarm ca --rotate

# export vm='a1' # reset to master
# export m1=$vm  # Swarm Master/Leader
# export ip=$(docker-machine ip $m1) # PUBLIC IP (We want private @ DO)  3.92.60.21
# export user=$(docker-machine inspect $m1 --format={{.Driver.SSHUser}})
# export key=$(docker-machine inspect $m1 --format={{.Driver.SSHKeyPath}})
# export port=$(docker-machine inspect $m1 --format={{.Driver.SSHPort}})
# # vm: i1, m1: i1, ip: 3.88.249.184, user: ubuntu, key: C:\Users\X1\.docker\machine\machines\i1\id_rsa, port: 22
# echo "vm: $vm, m1: $m1, ip: $ip, user: $user, key: $key, port: $port"

export vm='dn1' # reset to master
export m1=$vm  # Swarm Master/Leader

# Get/Set the swarm leader's IP (Control Plane IP)
case 2 in
    1) # @ Private IP
        nic='eth0' # NIC (default; eni-0b5e925e39191724f) 
        LEADER_IP=$(docker-machine ssh $m1 ip addr show dev $nic | grep inet | grep $nic | awk '{print $2}' | sed 's#/.*##g') 
        # Note that using `eth1` (private IP) requires RESET of ENV VAR to configure local `docker` tool to swarm-leader server:
        #   $ docker-machine env $m1
        #   $ export DOCKER_HOST="tcp://${LEADER_IP}:2376"
        #   $ eval $(docker-machine env $m1)
        ;;
    2) # @ Public IP 
        LEADER_IP=$(docker-machine ip $m1)
        ;; #... MUST for multi-vendor swarm (given current VPC architecture).
esac 

echo $LEADER_IP 

# Init swarm 
docker-machine ssh $m1 docker swarm init --advertise-addr "$LEADER_IP"

# TODO: provide flexible numbers at cli for x managers and x workers
JOIN_TKN_MGR=$(docker-machine ssh $m1 docker swarm join-token -q manager) 
echo $JOIN_TKN_MGR

# Add Managers
for i in 3 2 1; do
    echo "Joining swarm as MANAGER:: node 'aa$i'"
    docker-machine ssh aa$i docker swarm join --token "$JOIN_TKN_MGR" --advertise-addr="$(docker-machine ip aa${i})" "$LEADER_IP"
    #docker-machine ssh d$i docker swarm join --token "$JOIN_TKN_MGR" --advertise-addr="$(docker-machine ip d${i})" "$LEADER_IP"
done

for i in 3 2 1; do
    echo "Joining swarm as MANAGER :: node 'dn$i'"
    #docker-machine ssh a$i docker swarm join --token "$JOIN_TKN_MGR" --advertise-addr="$(docker-machine ip a${i})" "$LEADER_IP"
    docker-machine ssh dn$i docker swarm join --token "$JOIN_TKN_MGR" --advertise-addr="$(docker-machine ip dn${i})" "$LEADER_IP"
done

JOIN_TKN_WKR=$(docker-machine ssh $m1 docker swarm join-token -q worker) 
echo $JOIN_TKN_WKR

# Add Workers 
for i in 1 2; do
    echo "Joining swarm as WORKER :: node 'd$i'"
    docker-machine ssh d$i docker swarm join --token "$JOIN_TKN_WKR" "$LEADER_IP"
done

# Validate swarm
dm ssh $m1 docker node ls

# Configure client to swarm leader @ Private IP 
docker-machine env $m1
# NOT @ cross-vendor ... Reset for Control Plane per Private IP
#export DOCKER_HOST="tcp://${LEADER_IP}:2376" 
eval $(docker-machine env $m1)

# Validate local docker client is configured to swarm leader's docker daemon
docker node ls #... list swarm nodes

exit 

# Disintegrate Swarm ...
vm=aa
for i in 3 2 1; do
    echo "Leaving swarm :: node '$i'"
    docker-machine ssh ${vm}$i docker swarm leave --force 
done

# Unconfigure (reset docker tool to docker engine at host)
docker-machine env --unset

vm=aa
for i in 3 2 1; do
    docker-machine stop ${vm}$i 
done

# IF NEEDED 
docker node demote $_ID_OF_BAD_NODE
docker node rm $_ID_OF_BAD_NODE 
