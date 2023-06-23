#!/usr/bin/env bash
# ------------------------------------------------------------------------------
#  Create swarm @ AWS
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Destroy/(Re)Create swarm

# Destroy swarm
printf "%s\n" {ad1,ad2,ap1,ap2} |xargs -IX docker-machine ssh X docker swarm leave -f
# Restart Docker daemon
printf "%s\n" {ad1,ad2,ap1,ap2} |xargs -IX docker-machine ssh X sudo systemctl restart docker
# Init swarm
export sl=ad1
docker-machine ssh $sl docker swarm init
# Add others as managers
JOIN_TKN_MGR=$(docker-machine ssh $sl docker swarm join-token manager -q)
LEADER_IP=$(docker node inspect $sl |jq -Mr .[].ManagerStatus.Addr)
# OR
LEADER_IP=$(docker node inspect --format='{{.ManagerStatus.Addr}}' $sl)
printf "%s\n" {ad2,ap1,ap2} \
  |xargs -IX docker-machine ssh X docker swarm join --token "$JOIN_TKN_MGR" "$LEADER_IP"

# ------------------------------------------------------------------------------
# PRIOR WORK 

name='ad1'
ip=$(ec2s |grep $name |grep 'running' |awk '{print $4}')
echo $ip

# -----------------------------------------------------------------------------
# SSH :: docker-machine or standalone VM

export vm=${vm:-ad1}
export ip=$(docker-machine ip $vm)
export user='ubuntu'  # docker (Hyper-V) ubuntu (AWS Terraform) ec2-user (AWS default) root
export key=~/.docker/machine/machines/${vm}/id_rsa  # @ Hyper-V 
export key=~/.ssh/swarm-aws.pem                     # @ AWS
echo "ip: $ip, user: $user, key: $key"

ssh ${user}@${ip} -i $key

# -----------------------------------------------------------------------------
# Regenerate certificates @ new IP address

# WHY? 
# If swarm comms is per public IP, which is required by (remote) docker-machine, 
# and by swarm clusters spanning vendors, then certs may be invalid with each machine restart.
# Exceptions are if IP addresses are by AWS EIP etal.

# REGENERATE CERTs
for vm in $list; do 
    echo "=== ${vm}"
    rm ~/.docker/machine/machines/${vm}/{ca,cert,key,server,server-key}.pem -f
    docker-machine regenerate-certs ${vm} --force
done
# OR
# REGENERATE CERTs
mp='a1'      # a1a a1b a1c
list='a b c'
for x in $list; do 
    echo "=== ${mp}$x"
    rm ~/.docker/machine/machines/${mp}$x/{ca,cert,key,server,server-key}.pem -f
    docker-machine regenerate-certs ${mp}$x --force
done

# Or simply delete the VMs from docker-machine, and then add them back.

# DELETE MACHINEs (from docker-machine records)
docker-machine rm $list
# OR ..
# DELETE MACHINEs (from docker-machine records)

for x in $list; do 
    echo "=== ${mp}$x"
    rm -rf ~/.docker/machine/machines/${mp}$x 
done

# -----------------------------------------------------------------------------
# Rotate certs (UNNECESSARY)
docker swarm ca --rotate

# Validate certs/comms:
docker-machine ls

# -----------------------------------------------------------------------------
# Params for swarm 

# Declare nodes in swarm (namespaced; prefix is $mp)
export n=$(docker node ls -q | wc -l)
export mp="$(docker node ls | awk '{printf "%.1s\n", $2}' | tail -n1)"

#list='a b c'
#printf "%s " 'VMs:' ${mp}{a,b,c} 
export list="$(dm ls | grep Running | awk '{printf "%s ", $1}')"
export list="$(docker node ls --format "table {{.Hostname}}\t{{.Status}}\t{{.ManagerStatus}}" | grep Ready | awk '{printf "%s ", $1}')"

export sl=$vm    # Swarm Leader; UNCONFIGURED, so hardcode required.
export sl=$(docker node ls | grep 'Leader' | awk '{print $3}') 
#... IF CONFIGURED ALREADY per `docker-machine env $_VM`
echo "n: $n, mp: $mp, sl: $sl, vm: $vm"

#export sl=$(docker node ls | grep 'Leader' | awk '{print $3}') 
#... IF CONFIGURED ALREADY per `docker-machine env $_VM`
ip=$(docker-machine ip $sl)   
echo "mp: $mp, sl: $sl, ip: $ip, list: $list"

# Params :: hardcoded
export user='ubuntu'  # docker ubuntu ec2-user root
export key=~/.ssh/swarm-aws.pem 
echo "mp: $mp, sl: $sl, ip: $ip, user: $user, key: $key, port: $port"

# Params :: extracted from VMs config.json @ ~/.docker/machine/...
export ip=$(docker-machine ip $sl) # PUBLIC IP (We want private @ DO)  3.92.60.21
export user=$(docker-machine inspect $sl --format={{.Driver.SSHUser}})
export key=$(docker-machine inspect $sl --format={{.Driver.SSHKeyPath}})
export port=$(docker-machine inspect $sl --format={{.Driver.SSHPort}})
echo "mp: $mp, sl: $sl, ip: $ip, user: $user, key: $key, port: $port"

# Set Control Plane comms 

# Private IP (listening addr) of swarm leader
LEADER_IP=$(docker node inspect $sl |jq -Mr .[].ManagerStatus.Addr)

case 2 in
    1) # @ Private IP
        nic='ens5'  # 'eth0' # NIC (default) 
        # Per docker-machine
        #LEADER_IP=$(docker-machine ssh $sl ip addr show dev $nic | grep inet | grep $nic | awk '{print $2}' | sed 's#/.*##g') 
        LEADER_IP=$(docker-machine ssh $sl "ip route show dev ${nic:-eth0}" |awk '{print $7}' |head -n1)
        #... CAN (MUST ???) RESET Docker Host to this Private IP...
        docker-machine env $sl  #... is NOT currently ...
        export DOCKER_HOST="tcp://${LEADER_IP}:2376"
        eval $(docker-machine env $sl)
        #... validate ...
        docker-machine ls  
        #... now shows asterisk (*) by this configured, but not yet "Leader", machine ($sl).
        docker node ls  
        ;;
    2) # @ Public IP
        LEADER_IP=$(docker-machine ip $sl)
        ;; 
esac 

echo $LEADER_IP

# -----------------------------------------------------------------------------
# Init swarm 

# Leave (old) swarm ...
printf "%s\n" $list | xargs -I{} sh -c 'echo === $1; \
    docker-machine ssh $1 docker swarm leave -f' _ {}

docker-machine ssh $sl docker swarm init --advertise-addr "$LEADER_IP"
# IF configured to Swarm Leader host 
docker swarm init --advertise-addr "$LEADER_IP"
# IF only one NIC (eth0)
docker swarm init

# Rotate certs 
docker swarm ca --rotate

# Join swarm as MANAGERs
JOIN_TKN_MGR=$(docker-machine ssh $sl docker swarm join-token -q manager)
echo $JOIN_TKN_MGR
for vm in $list; do
    [[ $vm == $sl ]] && continue
    echo "Joining @ node: '$vm'"
    docker-machine ssh ${vm} docker swarm join --token "$JOIN_TKN_MGR" "$LEADER_IP"
done

### HENCEFORTH, can use WSL terminal 
dmfix posix

# -----------------------------------------------------------------------------
# Configure terminal to swarm leader's Docker server

docker-machine env $sl
# If NOT @ cross-vendor, then can reset for Control Plane per Private IP
export DOCKER_HOST="tcp://${LEADER_IP}:2376" 
eval $(docker-machine env $sl)

# -----------------------------------------------------------------------------
# Validate swarm

# docker-machine ssh $sl docker node ls
docker node ls  #... list nodes of swarm ("*" @ shell-config'd leader node)

# Demote node from manager to worker 
docker node ls             # List all swarm nodes per NAME, ID, ...
docker node demote $_NODE  # per name or ID

# Remove node from swarm cluster
docker swarm leave $_NODE
docker node rm $_NODE 

# -----------------------------------------------------------------------------
# PUSH file(s) or dir(s) to VM(s) per SCP or Rsync 

#   See 'REF.swarm-make.sh'
#   See script: ec2

# -----------------
# Push to ONE node

# SCP :: docker-machine
docker-machine scp -r $(pwd)/assets/ docker@${vm}:~/assets/
#... @ Hyperv (TinyCore), prompts for user's password :: 'tcuser'
#... FAILs @ Win10/MINGW64 (several pathing issues)

# Rsync :: Auth @ PKI
rsync -atuze "ssh -i $ssh_private_key" $(pwd)/assets/ ${ssh_user}@${ip}:~/assets/
# Rsync :: Auth @ Password
rsync -atuz $(pwd)/assets/ ${ssh_user}@${ip}:~/assets/
#... @ Hyperv, prompts for user's password :: 'tcuser'

# -----------------------------------------------------------------------------
# Teardown / Disintegrate

docker stack rm $app 

# Declare list of VM names
export list="$(dm ls | grep Running | awk '{printf "%s ", $1}')"
export list="$(docker node ls --format "table {{.Hostname}}\t{{.Status}}\t{{.ManagerStatus}}" | grep Ready | awk '{printf "%s ", $1}')"

# Leave swarm ...
printf "%s\n" $list | xargs -I{} sh -c 'echo === $1; \
    docker-machine ssh $1 docker swarm leave -f' _ {}

# Per node; IF NEEDED 
docker node demote $_ID_OF_BAD_NODE
docker node rm $_ID_OF_BAD_NODE 

# Prune 
printf "%s\n" $list | xargs -I{} sh -c 'echo === $1; \
    docker-machine ssh $1 docker system prune -f' _ {}

# Delete volumes (`docker system prune ...` does not.)
printf "%s\n" $list | xargs -I{} sh -c "echo === {}; \
    docker-machine ssh {} 'docker volume rm $(docker volume ls -q) 2>/dev/null'"

# Unset terminal :: Reset Docker client (`docker` tool) to (local) host's Docker engine.
docker-machine env --unset

