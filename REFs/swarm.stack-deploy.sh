#!/usr/bin/env bash
# ------------------------------------------------------------------------------
#   Deploy Stack (Swarm mode)
# -----------------------------------------------------------------------------

# Declare list of VM names
export list="$(dm ls | grep Running | awk '{printf "%s ", $1}')"
export list="$(docker node ls --format "table {{.Hostname}}\t{{.Status}}\t{{.ManagerStatus}}" | grep Ready | awk '{printf "%s ", $1}')"

# Swarm Leader
export sl=$vm    # hardcode @ UNCONFIGURED.
export sl=$(docker node ls | grep 'Leader' | awk '{print $3}') 
#... IF CONFIGURED ALREADY per `docker-machine env $_VM`
echo "list: $list, sl: $sl"

export ip=$(docker-machine ip $sl) # PUBLIC IP (We want private @ DO)  3.92.60.21
export user=$(docker-machine inspect $sl --format={{.Driver.SSHUser}})
export key=$(docker-machine inspect $sl --format={{.Driver.SSHKeyPath}})
export port=$(docker-machine inspect $sl --format={{.Driver.SSHPort}})
echo "list: $list, sl: $sl, ip: $ip, user: $user, key: $key, port: $port"

# SECRET : Create : Encrypt env var; UNENCRYPTED @ Service ... 
printf "$secret" | docker secret create --label ver='0.0.1' 'foo_secret' -
#... per node, ELSE run 'minio.env.sh' script; see below ...
# SECRET : Add to nodes, per script:
./assets/.env/minio.env.sh ${sl}

# CONFIG : Create : stored @ ALL MANAGER nodes : Available to any service so declared
printf "$config" | docker config create config-foo -  #... from string 
docker config create --label 'pxy-v1.1.1' 'pxy.conf' "$(pwd)/assets/.env/nginx.conf"  #... from file
#... Use @ Service : `docker service create --name foo --config config-foo foo:latest`

# LABEL : Add to node(s)

# @ ALL nodes
printf "%s\n" $list | xargs -I{} sh -c 'echo === $1; \
    docker node update --label-add stack=core $1' _ {}

# LABEL : Validate
printf "%s\n" $list | xargs -I{} sh -c "echo === {}; \
    docker node inspect {} | grep 'core'" 

# -----------------------------------------------------------------------------
# SERVICE NAME format: <STACK>_<SVC>
#    CTNR NAME format: <STACK>_<SVC>.<TASK_#>.<TASK_ID>

app='core' 
svc='api' 
list="$(docker node ls --format "table {{.Hostname}}\t{{.Status}}\t{{.ManagerStatus}}" | grep Ready | awk '{printf "%s ", $1}')"

docker stack deploy -c "./infra/docker/swarm/stack-${app}.yml" $app 

# nodes of swarm : dn @ .bashrcX
docker node ls # --format 'table {{.ID}}\t{{.Hostname}}\t{{.Status}}\t{{.Availability}}\t{{.ManagerStatus}}'
# stack
docker stack ls

# ALL services : ds @ .bashrcX
docker service ls \
    --format 'table {{.ID}}  {{.Image}}\t{{.Name}}  {{.Replicas}}\t{{.Ports}}'
# OR 
docker stack services $app \
    --format 'table {{.ID}}  {{.Image}}\t{{.Name}}  {{.Replicas}}\t{{.Ports}}'

# All tasks of ONE service at THIS node
docker service ps "${app}_${svc}" \
    --format 'table {{.ID}}  {{.Image}}\t{{.Name}}  {{.Node}}\t{{.CurrentState}}'

# All containers at THIS node
docker container ps --format 'table {{.ID}}  {{.Names}}\t{{.Image}}\t{{.Status}}'
# OR
docker container ls --format 'table {{.ID}}  {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'

# container STATs
docker container stats --no-stream \
    --format 'table {{.CPUPerc}}  {{.MemPerc}}\t{{.NetIO}}\t{{.Name}}'

# All tasks of ALL services of ALL nodes : dt @ .bashrcX
printf "%s\n" $list | xargs -I{} docker node ps {} \
    --filter desired-state=running \
    --format 'table {{.ID}}  {{.Image}}\t{{.Name}}  {{.Node}}  {{.CurrentState}}' 
# OR
docker node ps $(docker node ls -q) \
    --filter desired-state=running \
    --format 'table {{.ID}}\t{{.Image}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}' \
    | uniq 

# ALL containers at ALL nodes  : dsc @ .bash_functions_2
printf "%s\n" $list | xargs -I{} docker-machine ssh {} "echo === {}; \
    docker container ls --format 'table {{.ID}}  {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'"

# STATs of ALL containers across ALL nodes
printf "%s\n" $list | xargs -I{} docker-machine ssh {} "echo === {}; \
    docker container stats --no-stream \
    --format 'table {{.CPUPerc}}  {{.MemPerc}}\t{{.NetIO}}\t{{.Name}}'"

# STATs : tail @ current machine
docker container stats --format 'table {{.CPUPerc}}  {{.MemPerc}}\t{{.NetIO}}\t{{.Name}}'

# ALL images at ALL nodes : dsi @ .bash_functions_2
printf "%s\n" $list | xargs -I{} docker-machine ssh {} "echo === {};docker image ls"

# FAILED CONTAINERs (@ this VM)
docker ps -a --format "table {{.ID}}  {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
#... list containers incl. failed ("Exited ...")

# SERVICE UPDATEs
docker service update --image $img_name_tag "${app}_${svc}"    # change image (most common update)
docker service update --replicas 3 "${app}_${svc}"             # scale up

# INSPECT 
docker volume  inspect {dbp1,rds1}_data | jq .
docker network inspect {pvt1,web1} | jq .

# Nginx RELOAD (from its VM)
docker exec -it $(docker ps -q --filter name=pxy) sh -c 'nginx -s reload'

# -----------------------------------------------------------------------------
# Database Admin  (See make.exec.sh)

# @ Node running a PostgreSQL container
# === Interactive shell 
docker exec -it "$(docker ps | grep 'Up' | grep 'postgres' | awk '{print $1}')" sh 
# === psql session 
docker exec -it "$(docker ps | grep 'Up' | grep 'postgres' | awk '{print $1}')" \
    sh -c "cd ${PATH_ABS_CTNR_PGHOME} && psql -U ${DB_USER:-uzr1} -d ${DB_NAME:-db1}" 

# @ Node running an API container 
# === Interactive shell 
docker exec -it $(docker ps | grep 'Up' | grep '.api-' | awk 'NR == 1 {print $1}') sh
# === admin migrate  
docker exec -it $(docker ps | grep 'Up' | grep '.api-' | awk 'NR == 1 {print $1}') \
     sh -c "/app/admin --db-disable-tls=1 migrate"
# === admin seed  
docker exec -it $(docker ps | grep 'Up' | grep '.api-' | awk 'NR == 1 {print $1}') \
     sh -c "/app/admin --db-disable-tls=1 seed"

# -----------------------------------------------------------------------------
# Validate LOAD BALANCING 

# Declare nodes in swarm (namespaced; prefix is $mp)
export n=$(docker node ls -q | wc -l)
export mp="$(docker node ls | awk '{printf "%.1s\n", $2}' | tail -n1)"

# Swarm Leader:
export sl=${mp}1  # hardcode if UNCONFIGURED terminal, else ...
export sl=$(docker node ls | grep 'Leader' | awk '{print $3}') 
#... if already CONFIGURED (per `docker-machine env $sl`)

export ip=192.168.1.{20..30}  #per host DHCP; 127.0.0.1 @ single-node (local) swarm
#export ip=$(docker-machine ip $sl)  # Public IP of Swarm Leader (ANY node IP should work)
export ip=$(docker node inspect $sl | jq -r .[].Status.Addr)
export dns='swarm.now'  # @ OS hosts file 

# Healthcheck endpoint of each (API/PWA) service
curl ${ip}/v1/health;echo;curl ${ip}/health

export c=$(($n+1))  # One round-robin full cycle
seq $c | xargs -Iz curl -I ${ip}/health  --max-time 1
seq $c | xargs -Iz curl -I ${dns}/health --max-time 1 
# JSON : host @ /test  (PWA)
seq $c | xargs -Iz sh -c 'curl -s ${ip}:3030/test --max-time 1 | jq .host'

seq $c | xargs -Iz curl -s swarm.now/health | jq .host
seq $c | xargs -Iz curl -s swarm.now/v1/health | jq .host

#for i in {1..$n};do curl $ip --connect-timeout 1 && echo '';sleep 1;done
# for i in {1..$n}; do
#     curl $ip  --connect-timeout 1 && echo ''
#     curl $dns --connect-timeout 1 && echo ''
# done

# -----------------------------------------------------------------------------
# Connectivity @ App services : cURL : /liveness, /readiness

root='https://swarm.foo'
printf "%s\n" $root/{{liveness,readiness},api/v1/{liveness,readiness},aoa/v1/{liveness,readiness}} \ 
  |xargs -I{} sh -c "curl {};echo ''"

# -----------------------------------------------------------------------------
# Mod 1. Update app_web service by replacing webnet (overlay) with an encrypted data plane version 

docker service update --network-add 'app_enc' --network-rm 'app_webnet' 'app_web' 
#... SUCCESS (visualizer @ kvpairs.com:8080)


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
