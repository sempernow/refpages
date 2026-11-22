#!/usr/bin/env bash
# ------------------------------------------------------------------------------
#  Create Swarm cluster
#
#  RUN docker-machine (dm) create COMMANDS @ Git-for-Windows or Powershell.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Start VMs

# @ Hyper-V
docker-machine start {h1,h2,h3}
# @ AWS 
./ec2 start 

# -----------------------------------------------------------------------------
# DNS prep

# IP / DNS 
# Upsert : Auto-update Route53 IP Addresses to those of the running instances.
./route53-auto-update-domain-ip.sh

# Set VM hostname : @ Each node : UNTESTED 
# Set up the server hostname (node name); subdomain of domain we own:
export name='foo.sempernow.com'
sudo echo $name > /etc/hostname
hostname -F /etc/hostname
#... as root (What is root's password @ TinyCore?)

# -----------------------------------------------------------------------------
# Declare nodes (list)

## @ Before swarm init
export list="$(docker-machine ls | grep Running | awk '{printf "%s ", $1}')"
## @ After swarm init; @ configured terminal (dm env $sl) 
export list="$(docker node ls \
    --format "{{.Hostname}}\t{{.Status}}\t{{.ManagerStatus}}" \
    |grep Ready |awk '{printf "%s ", $1}'\
)"
## @ Hardcode
list=$(printf "%s " h{1,2,3})
list=$(printf "%s " a{1a,1b,1c})

# -----------------------------------------------------------------------------
# Declare swarm leader (first node)

sl=$(printf $list | awk '{print $1}')

echo "sl: $sl, list: $list"
# -----------------------------------------------------------------------------
# Regenerate certificates @ new IP address

# WHY? 
# If swarm comms is per public IP, which is required by (remote) docker-machine, 
# and by swarm clusters spanning vendors, then certs may be invalid with each machine restart.
# Exceptions are if IP addresses are by AWS EIP etal.

# REGENERATE CERTs
for vm in $list; do 
    echo "=== ${vm}"
    # rm ~/.docker/machine/machines/${vm}/{ca,cert,key,server,server-key}.pem -f
    docker-machine regenerate-certs ${vm} --force
done

chmod 600 ~/.docker/machine/machines/ad1/*  # -rw---------

# Or simply delete the VMs from docker-machine, and then add them back.

# DELETE MACHINEs (from docker-machine records)
docker-machine rm $list
# OR
for vm in $list; do 
    echo "=== ${vm}"
    rm -rf ~/.docker/machine/machines/${vm} 
done

# -----------------------------------------------------------------------------
# Rotate certs (UNNECESSARY)
docker swarm ca --rotate

# Validate certs/comms:
docker-machine ls

# -----------------------------------------------------------------------------
# SSH into a node 

export vm=$sl #... any node.
export ip=$(docker-machine ip $vm)  

## Per docker-machine 
docker-machine ssh $vm

## Per ssh utility (standalone VM)

### Hardcoded
export user='docker'
#... 'docker' (Hyper-V) | 'ubuntu' (AWS:Terraform) | 'ec2-user' (AWS:default) 
export key=~/.ssh/swarm-aws.pem                     # Private key @ AWS
export key=~/.docker/machine/machines/${vm}/id_rsa  # Private key @ Hyper-V 
echo "ip: $ip, user: $user, key: $key"

### Extract from config.json @ ~/.docker/machine/...
export user=$(docker-machine inspect $vm --format={{.Driver.SSHUser}})
export key=$(docker-machine inspect  $vm --format={{.Driver.SSHKeyPath}})
export port=$(docker-machine inspect $vm --format={{.Driver.SSHPort}})
echo "vm: $vm, ip: $ip, user: $user, key: $key, port: $port"

ssh ${user}@${ip} -i $key

# -----------------------------------------------------------------------------
# Activate a Node : Configure docker (client) to the node's Docker server

env |grep DOCKER # @ docker-desktop
# DOCKER_HOST=tcp://0.0.0.0:2375

# Configure the current shell to the swarm leader's Docker server
dna $sl  # See .bash_functions @ $_PRJ_ROOT/assets/HOME/
# OR
docker-machine env $sl
# If swarm is not cross-vender, then first reset `DOCKER_HOST` 
# (connection param) to the private IP address of the leader node.
export DOCKER_HOST="tcp://${LEADER_PRIVATE_IP}:2376" 
#... `docker-machine env $sl` exports relevant DOCKER_* vars, then instructs:
eval $(docker-machine env $sl)

env |grep DOCKER # @ sl=ad3
# DOCKER_MACHINE_NAME=ad3
# DOCKER_CERT_PATH=/c/HOME/.docker/machine/machines/ad3
# DOCKER_TLS_VERIFY=1
# DOCKER_HOST=tcp://3.81.221.113:2376

# -----------------------------------------------------------------------------
# Declare swarm params

## Leader name
### @ Before swarm init
export sl=$(printf $list | awk '{print $1}') #... first-listed node.
### @ After swarm init; @ shell configured to a node; `docker-machine env $vm`
export sl=$(docker node ls |grep 'Leader' |awk '{print $2}')
[[ $sl == '*' ]] && export sl=$(docker node ls |grep 'Leader' |awk '{print $3}')
#... leader may not be the active node; mutates per (raft-algo) concensus.

## Leader IP
export ip=$(docker-machine ip $sl)   
echo "sl: $sl, ip: $ip, list: $list"

## Leader IP ALTERNATIVES : Public|Private IP(s)

## @ docker-machine ssh ...
docker-machine ssh $sl 'ip -o -4 addr show dev eth0' 
#... all, or @ device eth0 only
#+. 3: eth0    inet 192.168.1.26/24 brd 192.168.1.255 scope global eth0 ...
docker-machine ssh $sl 'ip route show dev ${nic:-eth0}'
#=> 192.168.1.0/24  proto kernel  scope link  src 192.168.1.26

## @ ssh ...
ssh ${user}@${ip} -i $key ".."

export LEADER_IP=$(docker-machine ip $sl)
echo $LEADER_IP 
#... NOT @ CLOUD. Rather,
docker-machine ssh $sl docker swarm init 
#... returns the PRIVATE IP as the LEADER_IP (10.0.101.212)
    # ☩ dm ssh $sl docker swarm init
    # Swarm initialized: current node (v4ocim82cw8j1leijy7e9dxem) is now a manager.

    # To add a worker to this swarm, run the following command:

    #     docker swarm join --token SWMTKN-1-2gywzn7bdrpvgt5llupoakmk448yybrrsyqv2lp7m9vctz39xh-bpxrbw68jmvwrnnwsh6w9e9sn 10.0.101.212:2377

case 2 in
    1) # @ Private|Public IP, per INTERFACE (ADAPTER)
        nic='ens5' # eth0|ens5; NIC (default; eni-0b5e925e39191724f) 
        LEADER_IP=$(docker-machine ssh $sl "ip route show dev ${nic:-eth0}" |awk '{print $7}' |head -n1)
        # Using the private IP REQUIREs (???) RESET of Docker host address:
        docker-machine env $sl
        export DOCKER_HOST="tcp://${LEADER_IP}:2376"
        eval $(docker-machine env $sl)
    ;;
    2) # @ Public IP 
        LEADER_IP=$(docker-machine ip $sl)
    ;; #... MUST for multi-vendor swarm (given current VPC architecture).
esac 


# -----------------------------------------------------------------------------
# SWARM INIT 

# Leave (old) swarm ...
printf "%s\n" $list | xargs -I{} sh -c 'echo === $1; \
    docker-machine ssh $1 docker swarm leave -f' _ {}

# @ Configured terminal  

docker swarm init --advertise-addr "${LEADER_IP}:2377"
docker swarm init --advertise-addr "eth0:2377"
# IF only one NIC (eth0)
docker swarm init

# @ Unconfigured terminal

docker-machine ssh $sl docker swarm init --advertise-addr "${LEADER_IP}:2377"
# IF adapter has only one IP Address, can SET PER adapter NAME.
docker-machine ssh $sl docker swarm init --advertise-addr "eth0:2377"
# IF only one NIC (eth0)
docker-machine ssh $sl docker swarm init

# Rotate certs 
docker swarm ca --rotate

# -----------------------------------------------------------------------------
# SWARM JOIN : REFERENCE ONLY
    docker swarm join \
        --advertise-addr "${_THIS_VM_IP_or_ADAPTER}:2377" \
        --token "SWMTKN-1-${_PER_CLUSTER}-${_AS_MGR_or_AS_WKR}" \
        "${_SWRM_MGR_IP_or_ADAPTER}:2377" #... sans port okay

JOIN_TKN_MGR=$(docker swarm join-token -q manager)
echo $JOIN_TKN_MGR

# SWARM JOIN : Managers
for vm in $list; do
    [[ $vm == $sl ]] && continue
    echo "=== $vm"
    docker-machine ssh ${vm} docker swarm join \
        --token "$JOIN_TKN_MGR" "$LEADER_IP"
done

# -----------------------------------------------------------------------------
# SWARM JOIN : Workers 

JOIN_TKN_WKR=$(docker swarm join-token -q worker) 
echo $JOIN_TKN_WKR

for vm in $list; do
    [[ ${vm} == $sl ]] && continue
    echo "=== ${vm}"
    docker-machine ssh ${vm} docker swarm join \
        --token "$JOIN_TKN_WKR" "$LEADER_IP"
done

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
# Remove a node 

# Demote (to worker) 
docker node demote $_NODE 

# Stop the machine
docker-machine stop $_NODE  # dm stop ...
# OR 
ec2 stop $_NODE 

# Remove
docker node rm $_NODE 

# Verify 
docker node ls  # dn

# -----------------------------------------------------------------------------
# Push to ONE node

export vm=${vm:-h1}

### SCP : docker-machine
docker-machine scp -r $(pwd)/assets/ docker@${vm}:~/assets/
#... @ Hyperv (TinyCore), prompts for user's password :: 'tcuser'
#... FAILs @ Win10/MINGW64 (several pathing issues)

### Rsync : Auth @ PKI
rsync -atuze "ssh -i $key" $(pwd)/assets/ ${user}@${ip}:~/assets/
### Rsync : Auth @ Password
rsync -atuz $(pwd)/assets/ ${user}@${ip}:~/assets/
#... @ Hyperv, prompts for user's password :: 'tcuser'

# -----------------------------------------------------------------------------
# Push to ALL nodes 

# Declare nodes in swarm (namespaced; prefix is $mp)
export list="$(dm ls | grep Running | awk '{printf "%s ", $1}')"
export list="$(docker node ls \
    --format "table {{.Hostname}}\t{{.Status}}\t{{.ManagerStatus}}" \
    |grep Ready |awk '{printf "%s ", $1}' \
)"
echo "list: $list"

# Rsync : Auth @ PKI
for vm in $list; do
    echo "=== $vm"
    ip=$(docker-machine ip $vm)
    pvt_key=~/.docker/machine/machines/${vm}/id_rsa # @ Hyper-V
    pvt_key=~/.ssh/swarm-aws.pem                   # @ AWS
    docker-machine ssh $vm 'mkdir -p ~/assets'
    rsync -atuze "ssh -i $pvt_key" \
        $(pwd)/assets/sql/ ${user}@${ip}:~/assets/sql/
    rsync -atuze "ssh -i $pvt_key" \
        $(pwd)/assets/src/ ${user}@${ip}:~/assets/src/
    rsync -atuze "ssh -i $pvt_key" \
        $(pwd)/assets/keys/ ${user}@${ip}:~/assets/keys/
    rsync -atuze "ssh -i $pvt_key" \
        $(pwd)/assets/.env/postgres-v0.0.1.conf ${user}@${ip}:~/assets/.env/
    rsync -atuze "ssh -i $pvt_key" \
        $(pwd)/assets/.env/nginx-v0.0.1.conf ${user}@${ip}:~/assets/.env/
done 
#... rsync @ CYGWIN | WSL (mind pathing at ~/.docker/.../config.json)

# -----------------------------------------------------------------------------
# Push to ALL nodes : Ad hoc

# Push /assets to hyperv /mnt/assets
rsync -atuze "ssh -i $key" $(pwd)/assets/ ${user}@${ip}:~/assets/
sudo cp -r /home/docker/assets /mnt/assets

# Make dir
printf "%s\n" $list | xargs -I{} sh -c 'echo === $1; \
    docker-machine ssh $1 "mkdir -p ~/assets/.env"' _ {}

# PUSH one dir
printf "%s\n" $list | xargs -I{} sh -c 'export ip=$(docker-machine ip ${1});echo === $1 @ $ip; \
    export key=~/.docker/machine/machines/${1}/id_rsa; \
    docker-machine ssh $1 "mkdir -p ~/assets/.env"; \
    rsync -atuze "ssh -i $key" $(pwd)/assets/ ${user}@${ip}:~/assets/' _ {}

# PUSH one file
printf "%s\n" $list | xargs -I{} sh -c 'export ip=$(docker-machine ip ${1});echo === $1 @ $ip; \
    export key=~/.docker/machine/machines/${1}/id_rsa; \
    docker-machine ssh $1 "mkdir -p ~/assets/.env"; \
    rsync -atuze "ssh -i $key" $(pwd)/assets/.env/postgres-v0.0.1.conf ${user}@${ip}:~/assets/.env/' _ {}

# Validate dir(s)
printf "%s\n" $list | xargs -I{} sh -c 'echo === $1; \
    docker-machine ssh $1 "ls -ahl /home/docker/assets/keys"' _ {}

# DEL dir(s)
printf "%s\n" $list | xargs -I{} sh -c "echo === {}; \
    docker-machine ssh {} 'rm -rf ~/assets/.env'"

# -----------------------------------------------------------------------------
# PULL from Node (VM) : E.g., Pull PostgreSQL server config (postgresql.conf)

docker-machine ssh h3 
docker@h3:~$ cp /var/lib/postgresql/data/postgresql.conf /home/docker/assets/sql/postgresql.conf
docker@h3:~$ sudo chown docker:docker /home/docker/assets/sql/postgresql.conf
docker@h3:~$ exit
rsync -atuz ${user}@${ip}:/home/docker/assets/sql/postgresql.conf $(pwd)/assets/sql/postgresql.conf
# password: tcuser

# -----------------------------------------------------------------------------
# Teardown / Disintegrate 

app='core'
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
# OR
# Delete volumes (`docker system prune ...` does not.)
for vm in $list; do
    echo "=== ${vm}"
    docker-machine ssh ${vm} 'docker volume rm "$(docker volume ls -q)" 2>/dev/null'
done

# Unset terminal : Reset Docker client (`docker` tool) to (local) host's Docker engine.
docker-machine env --unset
