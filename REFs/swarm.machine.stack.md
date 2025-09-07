
# [`docker-machine` (CLI)](https://docs.docker.com/machine/reference/) :: [`create`](https://docs.docker.com/machine/reference/create/) &hellip;
# [`docker` (CLI)](https://docs.docker.com/engine/reference/commandline/docker/) :: [`swarm`](https://docs.docker.com/engine/reference/commandline/swarm/) | [`stack`](https://docs.docker.com/engine/reference/commandline/stack/) | [`service`](https://docs.docker.com/engine/reference/commandline/service/) | [Compose (YAML)](https://docs.docker.com/compose/compose-file/) 

## Single-node

### `docker swarm init`

```bash
# Init swarm mode 
docker swarm init 
# Validate swarm mode
docker node ls 
```

### `docker service create`

```bash
# Create services' overlay network 
docker network create -d overlay 'appnet'
# Create service(s)
docker service create --name 'rds' --network 'appnet' -p 6379:6379 -d \
    redis:6.0.8-buster redis-server --requirepass ${_REDIS_PASSWORD:-foob1234} 
docker service create --name 'api' --network 'appnet' -p 80:5555 -d gd9h/cache-redis:latest
# Update :: Add healthcheck https://docs.docker.com/engine/reference/commandline/service_update/
docker service update --health-cmd "curl -I -f -s --connect-timeout 2 localhost:5555 || exit 1" api
docker service rm 'api' 
# Create api service (again), but w/ healthcheck
docker service create --name 'api' --network 'appnet' -p 80:5555 -d \
    --health-cmd "curl -I -f -s --connect-timeout 2 localhost:5555 || exit 1" \
    --health-interval 10s \
    --health-retries 3 \
    --health-start-period 30s \
    --health-timeout 2s \
    gd9h/cache-redis:latest
# Add Visualizer service (SUCCESS @ WSL; FAIL @ MINGW64 due to volume-mount pathing)
docker service create --name 'viz' --network 'appnet' -p 8080:8080 -d \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    --label app.label=visualizer \
    dockersamples/visualizer:stable
```
### `docker service` [`update` | `scale`] 

```bash
# Update api service; mod to 3 replicas
docker service update --replicas 3 api 

# Test healthcheck 

# Shutdown rds (cache) service 
docker service scale rds=0
# View services state (replicas running)
docker service ls # api replicas should go to zero 
# Restart rds (cache) service
docker service scale rds=1
# View services state (replicas running)
docker service ls # api replicas should return to original number

# Teardown
docker service rm $(docker service ls -q)

# Disintegrate Swarm 
docker swarm leave -f 

# Cleanup (remove custom networks and such)
docker system prune -f
```

##### [`docker-compose up` VERSUS `docker stack deploy ...`](https://github.com/moby/moby/issues/29133#issuecomment-579774944 "github.com/moby/.../issues ")

>&hellip; _docker stack deploy supports "Variable Substitution" but you need to set the environment variables from the .env file in some way. Several options have been explained above. One of the neatest workarounds is using docker-compose config as pre-processor. So you can create your stack with_ &hellip; 

:

- [Variable Substitution](https://docs.docker.com/compose/compose-file/#variable-substitution)
- [`env_file`](https://docs.docker.com/compose/compose-file/#env_file)
- SOLUTIONs: 
    1. Use `docker-compose` tool as a preprocessor for `docker stack deploy`:
        ```bash
        docker-compose config | docker stack deploy -c - $_STACK_NAME
        # OR 
        docker stack deploy -c <(docker-compose config) $_STACK_NAME 
        ```
    1. Use `Makefile` (PRRED)
        ```bash
        # OR 
        make ...
        ```

## Multi-node | [`docker-machine`](https://docs.docker.com/machine/reference/) | [Infra/Architecture](https://app.cloudcraft.co/blueprint/db07c7d9-c5fc-43eb-b94d-93750787d25a "app.cloudcraft.co")  

### [`docker-machine create`](https://docs.docker.com/machine/reference/create/) | [`swarm.machine-create.sh`](swarm.machine-create.sh)

- [`--driver amazonec2`](https://docs.docker.com/machine/drivers/aws/) 
- [`--driver digitalocean`](https://docs.docker.com/machine/drivers/digital-ocean/)
- [`--driver hyperv`](https://docs.docker.com/machine/drivers/hyper-v/)


Create VMs 

```bash
machines='h1,h2,h3' 
switch='External Switch'
ram=1024
hdd=10000
echo "=== Create machines (idempotent)"
for vm in $(printf $machines | sed 's/,/ /g'); do 
    echo "=== @ '$vm'"
    [[ $( docker-machine ls -q | grep $vm ) ]] && {
        echo "Machine '$vm' already exists."
    } || \
        docker-machine create -d hyperv \
            --hyperv-virtual-switch $switch \
            --hyperv-memory $ram --hyperv-disk-size $hdd \
            $vm  # MUST be sequential; FAILs as background process(es).
done
```

#### [Add an existing machine](https://docs.docker.com/machine/drivers/generic/ "drivers/generic")

```bash
docker-machine create \
    --driver generic \
    --generic-ip-address=${_IP_or_DNS_NAME_of_EXISTING_MACHINE} \
    --generic-ssh-key ${_PRIVATE_KEY_of_EXISTING_MACHINE} \
    ${_NEW_NAME_for_EXISTING_MACHINE}
```
- By this scheme, we can use Terraform to generate the infra, and then use `docker-machine` to init/join into swarm, thereby removing the per-driver (per vendor) limitations of `docker-machine create`&hellip;.

## Make Swarm Cluster | [`swarm-make.sh`](swarm-make.sh)

### `docker-machine ssh $vm "docker swarm init"`

Remotely create a swarm cluster of managers (and/or workers). If a VM has more than one NIC (network interface), then must declare one, per its IP (`--advertise-addr $LEADER_IP`).

```bash
export vm='h1' # reset to master
export m1=$vm  # Swarm Master/Leader

# Set Control Plane comms (if more than one interface)
LEADER_IP=$(docker-machine ip $m1)
# Swarm Init
docker-machine ssh $m1 docker swarm init --advertise-addr "$LEADER_IP"
# Add managers
JOIN_TOKEN_MGR=$(docker-machine ssh $m1 docker swarm join-token -q manager)
echo $JOIN_TOKEN_MGR
for i in 2 3; do
    echo "Joining @ node: 'vm$i'"
    docker-machine ssh vm$i docker swarm join --token "$JOIN_TOKEN_MGR" "$LEADER_IP"
done

# Validate cluster
dm ssh $m1 docker node ls
```

### `docker-machine env $vm`

Configure local Docker client to remote engine (@ swarm leader VM); allows remote access per node; same tools/scripts as for single-host mode, but only for containers on the confgured node.

```bash
export vm='h1' # reset to master
export m1=$vm  # Swarm Master/Leader

# Configure docker client to swarm leader engine 
docker-machine env $m1
eval $(docker-machine env $m1) 
# Verify 
docker node ls 
```

## Stack Deploy | [`swarm.stack-deploy.sh`](swarm.stack-deploy.sh)

### `docker stack deploy` 

```bash
# Deploy stack ...
app='app' 
svc='api' 

docker stack deploy -c 'stack-cache-redis.yml' $app 
# Stack
docker stack ls

# Services
docker service ls || docker stack services $app ## EQUIV

# All Tasks of ALL Services
docker stack ps $app --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.CurrentState}}"
# All Tasks of ONE Service
docker service ps "${app}_${svc}" \
    --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.DesiredState}}\t{{.CurrentState}}"
# else
docker container ls --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.Ports}}\t{{.Names}}"
# All Tasks of ALL Services across ALL Nodes
docker node ps $(docker node ls -q) \
    --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.DesiredState}}\t{{.CurrentState}}" \
    | uniq | grep -v Shutdown

# Use the following pair to match container ID to host (VM) name (to response @ cURL): 

# All per Node ID + Container ID 
for f in $(docker service ps -q "${app}_${svc}" -f desired-state=running); do 
    docker inspect --format "{{.NodeID}}  {{.Status.ContainerStatus.ContainerID}}" $f
done
# All Node ID + Host Name 
docker node ls 

# ---------------------------------------------
# Validate SWARM LOAD BALANCING and redis count 
# Should serve round-robin or random container (id), and redis count, per request:
ip=0.0.0.0 # @ Single/local-host engine swarm
ip=$(docker-machine ip $m1)
dns='kvpairs.com'

for i in {1..9};do curl $ip --connect-timeout 1 && echo '';sleep 1;done

#ip=$(docker-machine ip a2) 

for i in {1..5}; do
    #curl $ip --connect-timeout 1 && echo ''
    curl $dns --connect-timeout 1 && echo ''
done

# -----------------------------------------------------------------------------
#  Teardown

docker stack rm $app 

export m='h'

# Disintegrate Swarm ...
# for i in 3 2 1; do
#     echo "Leaving swarm :: node '${m}$i'"
#     docker-machine ssh ${m}$i docker swarm leave -f
# done
seq {4,-1,1} | xargs -n 1 -I {} sh -c 'docker-machine ssh ${m}$1 docker swarm leave -f' _ {}

# Prune ...
# for i in 4 3 2 1; do 
#     echo "Prune system :: node '${m}$i'"
#     docker-machine ssh ${m}$i docker system prune -a -f
# done
seq {1,1,4} | xargs -n 1 -I {} sh -c 'docker-machine ssh h$1 docker system prune -a -f' _ {}

# Unconfigure (reset docker tool to docker engine at host)
docker-machine env --unset
eval $(docker-machine env --unset)

# Shutdown servers 
docker-machine stop {dn3,dn2,dn1,aa3,aa2,aa1}

```

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

