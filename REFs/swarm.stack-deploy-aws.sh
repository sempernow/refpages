#!/usr/bin/env bash
# ------------------------------------------------------------------------------
#  Deploy Stack @ AWS
# -----------------------------------------------------------------------------

export vm='a1' # reset to master
export m1=$vm  # Swarm Master/Leader
# export ip=$(docker-machine ip $m1) # PUBLIC IP (We want private @ DO)  3.92.60.21
# export user=$(docker-machine inspect $m1 --format={{.Driver.SSHUser}})
# export key=$(docker-machine inspect $m1 --format={{.Driver.SSHKeyPath}})
# export port=$(docker-machine inspect $m1 --format={{.Driver.SSHPort}})
# # vm: i1, m1: i1, ip: 3.88.249.184, user: ubuntu, key: C:\Users\X1\.docker\machine\machines\i1\id_rsa, port: 22
# echo "vm: $vm, m1: $m1, ip: $ip, user: $user, key: $key, port: $port"

# Deploy stack ...
app='app'
svc='web'
docker stack deploy -c 'stack-app.yml' $app

# Verify 
docker stack ls
docker stack ps $app --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.CurrentState}}"
docker service ls
docker service ps "${app}_${svc}" --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.DesiredState}}\t{{.CurrentState}}"
docker container ls --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.Ports}}\t{{.Names}}"

# All per Node ID
docker node ps $(docker node ls -q) --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.DesiredState}}\t{{.CurrentState}}" | uniq 
# All per Node ID + Container ID
for f in $(docker service ps -q "${app}_${svc}" -f desired-state=running); do 
    docker inspect --format "{{.NodeID}}  {{.Status.ContainerStatus.ContainerID}}" $f
done

# Validate SWARM LOAD BALANCING and redis count ...different (random) container (id), and redis count, per request:
ip=$(docker-machine ip $m1) #... PUBLIC IP 
dns='kvpairs.com'

for i in {1..5}; do
    curl $ip --connect-timeout 1 && echo ''
    curl $dns --connect-timeout 1 && echo ''
done

curl $ip
<h3>App FooBar Mod @ pt4</h3><b>Hostname:</b> f365bb1d92df<br/><b>Visits:</b> 1
curl $ip
<h3>App FooBar Mod @ pt4</h3><b>Hostname:</b> e672783702d9<br/><b>Visits:</b> 2
curl $ip
<h3>App FooBar Mod @ pt4</h3><b>Hostname:</b> 543d77458a68<br/><b>Visits:</b> 3

# -----------------------------------------------------------------------------
#  Teardown

docker stack rm $app 

# Disintegrate Swarm
docker-machine ssh d3 docker swarm leave
docker-machine ssh d2 docker swarm leave
docker-machine ssh d1 docker swarm leave --force

# Unconfigure (reset docker tool to docker engine at host)
docker-machine env --unset

# Shutdown servers 
docker-machine stop {d1,d2,d3}

