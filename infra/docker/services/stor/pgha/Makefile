###############################################################################
# PostgreSQL HA : Streaming Replication : Symmetrical Servers
###############################################################################
include ./../../../../../Makefile.settings
include Makefile.settings

###############################################################################
# Meta

menu :
	$(INFO) '==================================================================='
	$(INFO) 'PostgreSQL HA : Streaming Replication (SR) : Symmetrical Servers'
	$(INFO) 'Work from each PG node (*) if multi-node swarm. (Run: dn, dna)'
	$(INFO) '==================================================================='

	$(INFO) 'Configure service (once per swarm)'
	@echo '	inithost (once, at each PG node)'
	@echo '	configsvc : secrets network'

	$(INFO) 'PostgreSQL HA : Init Cluster (at each PG node)'
	@echo '	upadmin init(1,2) pwcreate|pwrotate(1,2) config(1,2) reload restart(1,2)'

	$(INFO) 'Verify init @ activate node (1|2)'
	@echo '	up|upadmin query insert(1|2) delete(1|2) insert(1|2)'

	$(INFO) 'Bootstrap standby server (2|1) off primary (1|2)'
	@echo '	upboot(2|1) boot(2|1) lsdata'
	@echo '	… slotsdelete (beforehand, at source server, may be necessary)'

	$(INFO) 'Post-bootstrap re-configuration'
	@echo '	upadmin config(2|1) slotscreate (at each node)'
	@echo '	… to reckon anti-symmetry of replication params (connections & slot names).'

	$(INFO) 'Validate SR (writes @ primary; WAL @ replica)'
	@echo '	up|upadmin insert(1|2)|delete(1|2) | wal(2|1)'

	$(INFO) 'Failover : swap servers modes (primary/standby)'
	@echo '	failover2 (demote 1 then promote 2) | failover1'

	$(INFO) '(Re)Configure for normal operations (ad hoc)'
	@echo '	upadmin config|pgpass|pwrotate|pwcreate up'

	$(INFO) 'Normal operating mode (db service; sans .pgpass, Docker secrets, and most env vars)'
	@echo '	up status | verify | wal1|wal2 | log1|log2 | tail1|tail2 | lshome | lsdata | lsarchive'
	@echo '	conflocaladd | conflocaldel | confarchivemodeoff | confarchivemodeon  (@ pg1)'
	@echo '	pwops : Rotate passwords of certain accounts per assets/keys/db_ops_pass'

	$(INFO) 'Backup / Restore'
	@echo '	backup1|backup2 / restore1|restore2'
	@echo '	… @ upadmin pgpass (else prompts for password)'

	$(INFO) 'Stack/Servers modes (declarative) '
	@echo '	up (normal ops) | upadmin|upboot1|upboot2 (config) | off|offroot (sans server)'

	$(INFO) 'Docker helpers (See .bash_functions @ PRJ_ROOT/assets/HOME/)'
	@echo '	dm      : docker-machine ls|ip|ssh|env|… NODE'
	@echo '	dni     : docker node inspect'
	@echo '	dnll    : docker node labels (all nodes. Also, see addlabels recipe @ /docker/nodes/)'
	@echo '	dn|dna  : docker node ls | eval $$(docker-machine env NODE)'
	@echo '	ds|dsw  : docker service ls | watch …'
	@echo '	dsc     : List ctnrs (running) at all nodes (all states @ `dsc ANY`)'
	@echo '	dsl     : docker service logs {STACK}_{SVC}'

env :
	$(INFO) ': Environment is declared in Makefile.settings @ project root.'
	@env |grep SWARM_
	@env |grep SWM_
	@env |grep HYPERVISOR
	@env |grep ADMIN_ |grep -v PATH
	@env |grep CTNR_ |grep -v PATH
	@env |grep NET_DMZ
	@env |grep NET_PVT
	@env |grep NET_PGHA
	$(INFO) 'NODEs'
	@env |grep NODE_ |grep -v printf
	$(INFO) 'VOL_*'
	@env |grep VOL_
	$(INFO) 'PATH_ABS_*'
	@env |grep PATH_ABS_HOST
	@env |grep PATH_ABS_VM
	@env |grep PATH_ABS_CTNR
	@env |grep PATH_ABS_PGHA
	$(INFO) 'PATH_REL_*'
	@env |grep PATH_REL
	$(INFO) 'APP_ASSETS_PATH*'
	@env |grep APP_ASSETS_PATH
	$(INFO) 'PG*'
	@env |grep PG |grep -v NODE |grep -v VOL |grep -v PATH |grep -v BASH |grep -v NET_
	$(INFO) 'DB_*'
	@env |grep DB_ |grep -v APP_
	$(INFO) 'PostgreSQL'
	@env |grep POSTGRES
	@env |grep REPLICATOR
	$(INFO) 'APP_*'
	@env |grep APP_DB 

do :
	ls -ahl ${PATH_ABS_HOST_ASSETS}/.env

###############################################################################
# Docker : service/stack : config infra

configsvc   : secrets network 
volumes :
# Swarm : single|multi host(s)
ifeq ($(SWARM_LEADER), docker-desktop)
	docker volume create \
		--label TargetImage=${PGHA_IMAGE} \
		--label TargetService=${PG1} \
		--label TargetDir=${PATH_ABS_CTNR_PGDATA} \
		--label ID=$(shell cat /proc/sys/kernel/random/uuid) \
		${VOL_PG1_DATA}
	docker volume create \
		--label TargetImage=${PGHA_IMAGE} \
		--label TargetService=${PG2} \
		--label TargetDir=${PATH_ABS_CTNR_PGDATA} \
		--label ID=$(shell cat /proc/sys/kernel/random/uuid) \
		${VOL_PG2_DATA}
	docker volume create \
		--label TargetImage=${PGHA_IMAGE} \
		--label TargetService=${PG1} \
		--label TargetDir=${PATH_ABS_CTNR_PGARCHIVE} \
		--label ID=$(shell cat /proc/sys/kernel/random/uuid) \
		${VOL_PG1_ARCH}
	docker volume create \
		--label TargetImage=${PGHA_IMAGE} \
		--label TargetService=${PG2} \
		--label TargetDir=${PATH_ABS_CTNR_PGARCHIVE} \
		--label ID=$(shell cat /proc/sys/kernel/random/uuid) \
		${VOL_PG2_ARCH}
	docker volume create \
		--label TargetImage=${PGHA_IMAGE} \
		--label TargetService=${PGHA_STACK} \
		--label ID=$(shell cat /proc/sys/kernel/random/uuid) \
		${VOL_PGHA_ETC}
else 
	@echo 'Use Makefile recipes @ /docker/nodes/'
#bash ${PATH_ABS_HOST_NODES}/make.node.sh createVols
endif
label labels :
# bash ${PATH_ABS_HOST_NODES}/make.node.sh addLabels
	@echo 'Use Makefile recipes @ /docker/nodes/'
	@echo ' '
	@echo '	… add|rm a single label using: `dnlabel …` '
secret secrets :
	$(INFO) 'docker secret create ...'
	bash ${PATH_ABS_HOST_ASSETS}/.env/pgha.env.sh replay
	docker secret ls
network networks :
	$(INFO) 'docker network create ...'
	docker network prune -f
	docker network create --driver=overlay ${NET_DMZ1}
	docker network create --driver=overlay \
		--attachable \
		--subnet=${NET_PGHA_CIDR} \
		--gateway=${NET_PVT1_GATEWAY} \
		--internal ${NET_PGHA}
	docker network ls

###############################################################################
# Docker : service/stack : manage

failover2 : demote1 promote2
failover1 : demote2 promote1

upadmin :	
	docker stack deploy -c ${PATH_ABS_PGHA_ADMIN_YML} ${PGHA_STACK}
up :
	docker stack deploy -c ${PATH_ABS_PGHA_OPS_YML} ${PGHA_STACK}
off :
	docker stack deploy -c ${PATH_ABS_PGHA_OFF_YML} ${PGHA_STACK}
offroot :
	docker stack deploy -c ${PATH_ABS_PGHA_OFFROOT_YML} ${PGHA_STACK}
upboot1 :
	docker stack deploy -c ${PATH_ABS_PGHA_BOOT1_YML} ${PGHA_STACK}
upboot2 :
	docker stack deploy -c ${PATH_ABS_PGHA_BOOT2_YML} ${PGHA_STACK}
down :
	docker stack rm ${PGHA_STACK}
log1 logs1 :
	docker service logs ${PGHA_STACK}_${PG1}
log2 logs2 :
	docker service logs ${PGHA_STACK}_${PG2}
tail1 :
	docker service logs ${PGHA_STACK}_${PG1} -f
tail2 :
	docker service logs ${PGHA_STACK}_${PG2} -f

###############################################################################
# PostgreSQL server : admin from host

# @ Docker bind mounts
inithost : 
	@pushd ${PATH_ABS_HOST_DOCKER}/nodes;make inithost
	@pushd ${PATH_ABS_HOST_DOCKER}/nodes;make upload

# @ Docker volumes (DEPRICATED)
initvols :
	bash make.exec.sh initvols

# Initialize a primary(#)/standby server pair
# REQUIREs: make upadmin
init initcluster: init1 init2
init1 : 
	bash make.exec.sh initCluster pg1
init2 : 
	bash make.exec.sh initCluster pg2

pwops :
	bash make.exec.sh pwOps pg1

pgpass : pgpass1 pgpass2
pgpass1 :
	bash make.exec.sh pgpass pg1
# Inject ~/.pgpass into ctnr; requires docker secrets (@ YAML)
pgpass2 :
	bash make.exec.sh pgpass pg2

pwrotate : pwrotate1 pwrotate2 
pwcreate : pwcreate1 pwcreate2
pwcreate1 :
	bash make.exec.sh pwCreate pg1
pwrotate1 :
	bash make.exec.sh pwRotate pg1
pwcreate2 :
	bash make.exec.sh pwCreate pg2
pwrotate2 :
	bash make.exec.sh pwRotate pg2

activity1 :
	bash make.exec.sh activity pg1
activity2 :
	bash make.exec.sh activity pg2

ip1 :
	bash make.exec.sh ip1 
ip2 :
	bash make.exec.sh ip2 
status :
	bash make.exec.sh status
lshome : 
	bash make.exec.sh lshome
lsdata : 
	bash make.exec.sh lsdata
lsarchive lsarch :
	bash make.exec.sh lsarchive
lswal :
	bash make.exec.sh lswal

wal1 : 
	bash make.exec.sh wal1
wal2 : 
	bash make.exec.sh wal2
	
users :
	bash make.exec.sh users

# Bootstrap a standby server(#) off the primary.
# REQUIREs: make upboot1|upboot2
boot1 : 
	bash make.exec.sh boot pg1
boot2 : 
	bash make.exec.sh boot pg2
slotscreate: 
	bash make.exec.sh slotsCreate
slotsdelete : 
	bash make.exec.sh slotsDelete
#... prior to bootstrap, may need to run slotsdelete at source server.

config : conf confhba confconn pgpass
config1 : conf1 confhba1 confconn1 pgpass1
config2 : conf2 confhba2 confconn2 pgpass2

conf : conf1 conf2 verify
confconn : confconn1 confconn2
confhba : confhba1 confhba2

conf1 : 
	bash make.exec.sh conf pg1
conf2 : 
	bash make.exec.sh conf pg2
confconn1 : 
	bash make.exec.sh confconn pg1
confconn2 : 
	bash make.exec.sh confconn pg2
confhba1 : 
	bash make.exec.sh confhba pg1
confhba2 : 
	bash make.exec.sh confhba pg2

conflocaladd :
	bash make.exec.sh confLocalAdd pg1
conflocaldel :
	bash make.exec.sh confLocalDel pg1
confarchivemodeoff :
	bash make.exec.sh confArchiveMode pg1 off
confarchivemodeon :
	bash make.exec.sh confArchiveMode pg1 always

verify :
	bash make.exec.sh verify

reload : 
	bash make.exec.sh reload 
restart : restart1 restart2
restart1 :
	bash make.exec.sh restart pg1
restart2 :
	bash make.exec.sh restart pg2
stop : stop1 stop2
stop1 :
	bash make.exec.sh stop pg1
stop2 :
	bash make.exec.sh stop pg2

# Failover management
promote1 :
	bash make.exec.sh promote pg1
promote2 :
	bash make.exec.sh promote pg2
demote1 standby1 :
	bash make.exec.sh demote pg1
demote2 standby2 :
	bash make.exec.sh demote pg2

backup1 :
	bash make.exec.sh backup pg1 
backup2 :
	bash make.exec.sh backup pg2 

restore1 : 
	bash make.exec.sh restore pg1
restore2 : 
	bash make.exec.sh restore pg2

###############################################################################
# PostgreSQL server : replication test / validate 

insert1 :
	bash make.exec.sh insert pg1
	bash make.exec.sh query
insert2 :
	bash make.exec.sh insert pg2
	bash make.exec.sh query
delete1 : 
	bash make.exec.sh delete pg1
	bash make.exec.sh query
delete2 : 
	bash make.exec.sh delete pg2
query : 
	bash make.exec.sh query

###############################################################################
# PostgreSQL server : admin from container

# pg1 (pg1) | pg2 (pg1)

pg1 : 
	docker exec -it $(shell docker container ls --filter=name=${PG1} -q) bash
pg2 : 
	docker exec -it $(shell docker container ls --filter=name=${PG2} -q) bash 

c1 : 
	docker run -it --rm --network ${NET_PGHA} \
		${PGHA_IMAGE} psql -h ${PG1} ${SESSION_USER_DB}
c2 : 
	docker run -it --rm --network ${NET_PGHA} \
		${PGHA_IMAGE} psql -h ${PG2} ${SESSION_USER_DB}

###############################################################################
# Docker : run / service : single server

run : 
	docker run --detach --rm --name ${PG1} \
		--network ${NET_PGHA} \
		-v ${VOL_PG1_DATA}:${PATH_ABS_CTNR_PGDATA} \
		--env POSTGRES_PASSWORD_FILE=/run/secrets/pg_pw_postgres \
		${PGHA_IMAGE}

svc :
	docker service create -d --name svc_${PG1} -p 5432:5432 \
		--network ${NET_PGHA} \
		--mount source=${VOL_PG1_DATA},target=${PATH_ABS_CTNR_PGDATA} \
		--secret pg_pw_postgres \
		--env POSTGRES_PASSWORD_FILE=/run/secrets/pg_pw_postgres \
		${PGHA_IMAGE}

###############################################################################
# Docker : cleanup 

# delvol :
# ifeq ($(SWARM_LEADER), docker-desktop)
#   # @ Local host  (Swarm-single-host OR not Swarm modes) 
# 	docker volume prune -f
# else
#   # @ Remote host (Swarm-multi-host mode)
# 	bash ${PATH_ABS_HOST_NODES}/make.node.sh delNodeDockerVolumes
# endif

prunesecrets :
	@docker secret rm $(shell docker secret ls -q) > /dev/null 2>&1;true
	docker secret ls
# prunenodes :
# 	bash ${PATH_ABS_HOST_NODES}/make.node.sh pruneNodes
# # delassets :
# # 	bash ${PATH_ABS_HOST_NODES}/make.node.sh delNodeAssets
# prunelabels :
# 	bash ${PATH_ABS_HOST_NODES}/make.node.sh pruneLabels
# 	@echo '	… repeat `make prunelabels` to remove MULTIPLE LABELS.'

clean prune : prunesecrets
ifeq ($(SWARM_LEADER), docker-desktop)
    # @ Local host  (Swarm-single-host OR not Swarm modes) 
	docker system prune -f
else
    # @ Remote host (Swarm-multi-host mode)
	@echo 'Use Makefile recipes @ /docker/nodes/'
# bash ${PATH_ABS_HOST_NODES}/make.node.sh pruneNodes
endif





