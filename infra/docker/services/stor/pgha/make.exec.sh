#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  Makefile : recipes : configure PostgreSQL servers, per node/ctnr
#
#  ARGs: RECIPE
#
# Configure sans mount(s)
# - Sans source-file uploads to its host node.
# - Sans host:ctnr bind mounts.
# -----------------------------------------------------------------------------

[[ ($PATH_ABS_CTNR_PGDATA && $PG1 && $PG2 && $NET_PGHA && $NET_PGHA_CIDR) ]] || { 
    echo "=== UNCONFIGURED @ ${0##*/} : DID NOTHING";exit 99; 
}
# docker container ls 
export ctnr_pg1=$(docker container ls --filter=name=$PGHA_SVC1 -q)
export ctnr_pg2=$(docker container ls --filter=name=$PGHA_SVC2 -q)

#echo "1: $(docker inspect --format='{{.LogPath}}' $ctnr_pg2)"
#echo "2: $(docker inspect --format='{{.LogPath}}' $ctnr_pg1)"

[[ $ctnr_pg1 ]] && export ip_pg1=$( \
    docker container inspect -f "{{.NetworkSettings.Networks.${NET_PGHA}.IPAddress}}" \
    $ctnr_pg1 \
)
[[ $ctnr_pg2 ]] && export ip_pg2=$( \
    docker container inspect -f "{{.NetworkSettings.Networks.${NET_PGHA}.IPAddress}}" \
    $ctnr_pg2 \
)
[[ ($1 == 'config') || ($1 == 'verify') ]] && {
    echo "=== @ ${PG1} ctnr: $ctnr_pg1"
    echo "=== @ ${PG1} ip  : $ip_pg1"
    echo "=== @ ${PG2} ctnr: $ctnr_pg2"
    echo "=== @ ${PG2} ip  : $ip_pg2"
}
ip1(){ echo $ip_pg1; }
ip2(){ echo $ip_pg2; }

# -----------------------------------------------------------------------------
# Shell @ service ctnr 

pg1(){
    echo "=== @ Service: ${PG1}:"
    [[ $ctnr_pg1 ]] && {
        docker exec -it $ctnr_pg1 "$@";true
    } || { echo "=== No container";true; }
}
pg2(){
    echo "=== @ Service: ${PG2}:"
    [[ $ctnr_pg2 ]] && {
        docker exec -it $ctnr_pg2 "$@";true
    } || { echo "=== No container";true; }
}
all(){ pg1 "$@";pg2 "$@"; }

status(){ # Server status (all)
    echo "@ Node: $(docker node ls |grep '*' |awk '{print $3}')"
    all bash -c '
        (( $(id -u) )) && { pg_ctl status;true; } || echo "=== No PostgreSQL server : root user"
    '; true; 
}

#################################
# Init host (VM) Filesystem (FS)
#################################
initHost(){ # Init host (VM) FS as source(s) for Docker bind mounts
    script='make.init.host.sh'

    case $HYPERVISOR in
        "hyperv")
            echo "NOT IMPLEMENTED @ '$HYPERVISOR'"
            echo "... Use recipe(s) @ infra/.../nodes"
            # docker-machine ssh $NODE_PG1 /bin/bash -s < $script postgres 70 70
            # docker-machine ssh $NODE_PG2 /bin/bash -s < $script postgres 70 70
        ;;
        "aws") 
            ec2 ssh $NODE_PG1 /bin/bash -s < $script postgres 70 70
            ec2 ssh $NODE_PG2 /bin/bash -s < $script postgres 70 70
        ;;
    esac 
}
initvols() { # Init host (VM) FS for use as Docker volume(s) (DEPRICATED)
    # Set owner & mode at mount(s) : run as root
    echo "DEPRICATED : Use recipe: inithost"
    exit 0

    all bash -c "
        mkdir -p ${PATH_ABS_CTNR_PG_BACKUP}
        find $PATH_ABS_CTNR_PGHOME -type d -exec sh -c '
            chown -R postgres:postgres \$@
            chmod -R 770 \$@
        ' _ {} \+
        echo '=== @ $PATH_ABS_CTNR_PGHOME'
        ls -ahl ${PATH_ABS_CTNR_PGHOME}
        echo '=== @ $PATH_ABS_CTNR_PG_ETC'
        ls -ahl ${PATH_ABS_CTNR_PG_ETC}
    "
}

##############################################
# Configure PostgreSQL Replication Functions 
##############################################
# https://www.postgresql.org/docs/9.4/functions-admin.html#FUNCTIONS-REPLICATION
# psql -c "SELECT pg_drop_replication_slot('foo')"

# Replication Slots : Each server must store replication-slot name(s) of the other(s)
# Namespace protects WALs from deletion until all thereunder are fetched by namesake (server).
slot_create() {
    # ARGs: SERVER SLOT_NAME
    $1 bash -c "psql -c \"SELECT pg_create_physical_replication_slot('${2}')\""
}
slot_delete() {
    # Drop replication-slot if exist
    # ARGs: SERVER SLOT_NAME
    echo "=== @ pg_drop_replication_slot(${2})"
    $1 bash -c "psql -w -c \"
        SELECT pg_drop_replication_slot(slot_name) 
        FROM pg_replication_slots WHERE slot_name = '${2}';
    \""
}

pg_stat_wal_receiver="psql -c '\x' -c 'SELECT * FROM pg_stat_wal_receiver'"
pg_replication_slots="psql -c '
    SELECT slot_name,slot_type,active,active_pid,restart_lsn FROM pg_replication_slots'
"
pg_stat_replication="psql -c '\x' -c 'SELECT * FROM pg_stat_replication'"

slotsCreate() {
    # Though bootstrapping adds replication-slot name to primary,
    # this HA scheme requires symmetry; add the other's name to each.
    slot_create $PG1 $PG2
    $PG1 bash -c "$pg_replication_slots"
    
    slot_create $PG2 $PG1
    $PG2 bash -c "$pg_replication_slots"
}
slotsDelete() {
    slot_delete $PG1 $PG2
    $PG1 bash -c "$pg_replication_slots"
    
    slot_delete $PG2 $PG1
    $PG2 bash -c "$pg_replication_slots"
}

# WAL stats

wal1(){
    $PG1 bash -c "$pg_stat_wal_receiver"
    $PG2 bash -c "$pg_replication_slots"
    $PG2 bash -c "$pg_stat_replication"
}
wal2(){
    $PG2 bash -c "$pg_stat_wal_receiver"
    $PG1 bash -c "$pg_replication_slots"
    $PG1 bash -c "$pg_stat_replication"
}

initCluster() { 
    # Initialize a database cluster
    # Run once; idempotent, but destructive

    # See project-root Makefile : Run : make configs .
    # Preprocessing (initcluster.sql.sh) must occur @ service config, 
    # PRIOR TO UPLOADING its result file to PostgreSQL node; ~/sql/... .
    # That uploaded result file (~/sql/initcluster.sql) is used herein by psql.

    $1 bash -c "
        [[ \$(psql -lqt |cut -d \| -f 1 |grep -w $APP_DB_NAME) ]] && {
            printf '%s\n' '=== Cluster was ALREADY initialized.'
            exit 0
        }
        printf '\n%s\n' '=== Initialize cluster'
        psql -f ~/sql/init/initcluster.sql
    "
    
    # DEPRICATED : MOVED to /assets/sql/initcluster.sql
    # $1 bash -c "
    #     [[ \$(psql -lqt |cut -d \| -f 1 |grep -w $APP_DB_NAME) ]] && {
    #         printf '\n%s\n' '=== Cluster was already initialized.'
    #         exit 0
    #     }
    #     printf '\n%s\n' '=== Initialize cluster'

    #     psql -c 'ALTER SYSTEM RESET ALL'

    #     createuser -e --replication $REPLICATOR_USER
    #     createuser -e --superuser $APP_DB_OWNER
    #     createuser -e --superuser $APP_DB_USER

    #     psql -c '
    #         REVOKE CREATE ON SCHEMA public FROM PUBLIC;
    #     '
    #     psql -c '
    #         CREATE DATABASE $APP_DB_NAME;
    #     '
    #     psql -c '
    #         ALTER DATABASE $APP_DB_NAME OWNER TO $APP_DB_OWNER;
    #         GRANT ALL PRIVILEGES ON DATABASE $APP_DB_NAME to $APP_DB_USER;
    #     '
    #     psql -d $APP_DB_NAME -c '
    #         CREATE SCHEMA IF NOT EXISTS $APP_DB_USER;
    #         ALTER SCHEMA $APP_DB_USER OWNER TO $APP_DB_USER;
    #         REVOKE ALL ON DATABASE $APP_DB_NAME FROM PUBLIC;
    #         SET search_path TO svcs;
    #         CREATE EXTENSION IF NOT EXISTS pgcrypto;
    #         CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";
    #     '
    #     psql -d $APP_DB_NAME -c '
    #         ALTER USER $APP_DB_USER WITH NOSUPERUSER NOCREATEDB NOCREATEROLE;
    #         GRANT CONNECT 
    #         ON DATABASE $APP_DB_NAME to $APP_DB_USER;
    #         GRANT SELECT, INSERT, UPDATE, DELETE 
    #         ON ALL TABLES IN SCHEMA $APP_DB_USER to $APP_DB_USER;
    #     '

    #     psql -d $APP_DB_NAME -U $APP_DB_USER -c '
    #         CREATE TABLE IF NOT EXISTS foo (
    #             idx   BIGINT GENERATED ALWAYS AS IDENTITY, 
    #             ctime TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    #         );
    #         INSERT INTO foo (ctime) VALUES (CURRENT_TIMESTAMP);
    #         CREATE TABLE IF NOT EXISTS bar(x integer);
    #         INSERT INTO bar(x) SELECT y FROM generate_series(1, 100) a(y);
    #     '

    #     psql -c '\du' 
    #     psql -d $APP_DB_NAME -U $APP_DB_USER -c '\dt'
    # "
}

###############################################################
# Server configurations : sans mount; sans source-file upload
###############################################################

# Alt configs 
confLocalAdd(){ # @ server $1
    # listen_addresses : ALL
    $1 bash -c "
        psql -c \"ALTER SYSTEM SET listen_addresses TO '*';\"
    "
    # pg_hba.conf : Allow ALL
    $1 bash -c "
        echo 'host    $APP_DB_NAME             $APP_DB_USER            0.0.0.0/0            scram-sha-256' \
            >> ${PATH_ABS_CTNR_PGDATA}/pg_hba.conf
    "
}
confLocalDel(){ # @ server $1
    # listen_addresses : restrict
    $1 bash -c "
        psql -c \"ALTER SYSTEM SET listen_addresses TO '${PG1},${PG2}';\"
    "
    # pg_hba.conf : remove unrestricted
    $1 bash -c "
        sed -i '/0.0.0.0/d' ${PATH_ABS_CTNR_PGDATA}/pg_hba.conf
    "
}

confArchiveMode() { # ALTER SYSTEM ... @ server $1
    # ARGs: HOST off|always|on(don't use)
    $1 bash -c "
        psql -c \"ALTER SYSTEM SET archive_mode TO $2;\"
    "
}

conf() { # PGDATA/postgresql.conf + ALTER SYSTEM ... @ server $1
    # Create postgresql.conf from source, as a string; remove comments and empty lines;
    # overwrite that at PATH_ABS_CTNR_PGDATA.
    src="$(cat ./config/postgresql.src.conf |sed '/^[#]/d' |sed '/^\s*$/d')"
    tgt="${PATH_ABS_CTNR_PGDATA}/postgresql.conf"

    # Overwrite : postgresql.conf
    $1 bash -c "
        echo \"$src\" > "$tgt"
        echo '=== @ postgresql.conf'
        cat         $tgt
    "
    # Append : postgresql.auto.conf
        #psql -c \"ALTER SYSTEM SET listen_addresses TO '${PGHA_HOST1},${PGHA_HOST2}';\"
        #psql -c \"ALTER SYSTEM SET listen_addresses TO '*';\"
    $1 bash -c "
        psql -c \"ALTER SYSTEM SET listen_addresses TO '${PG1},${PG2}';\"
        psql -c \"ALTER SYSTEM SET archive_command TO 'test ! -f ${PATH_ABS_CTNR_PGARCHIVE}/%f && cp %p ${PATH_ABS_CTNR_PGARCHIVE}/%f';\"
        psql -c \"ALTER SYSTEM SET archive_cleanup_command TO 'pg_archivecleanup ${PATH_ABS_CTNR_PGARCHIVE} %r';\"
        psql -c \"ALTER SYSTEM SET restore_command TO 'cp ${PATH_ABS_CTNR_PGARCHIVE}/%f %p';\"
        echo '=== @ postgresql.auto.conf'
        cat '${PATH_ABS_CTNR_PGDATA}/postgresql.auto.conf'
    "
}

confhba() { # PGDATA/pg_hba.conf @ server $1
    # Generate pg_hba.conf as string; overwrite that at PATH_ABS_CTNR_PGDATA.
    tgt_file='pg_hba.conf';src_str="$(./config/${tgt_file}.sh)"
    [[ "$REPLICATOR_USER" ]] || {
        echo "=== FAIL @ ${tgt_file} : REPLICATOR_USER unset";exit 1
    }
    [[ "$NET_PGHA_CIDR" ]] || {
        echo "=== FAIL @ ${tgt_file} : NET_PGHA_CIDR unset";exit 1
    }
    [[ $src_str ]] || { echo "=== FAIL @ ./config/${tgt_file}.sh";exit 1; }

    $1 bash -c "
        echo '${src_str}' > ${PATH_ABS_CTNR_PGDATA}/${tgt_file} && {
            echo '=== @ ${PATH_ABS_CTNR_PGDATA}/${tgt_file}'
            cat         ${PATH_ABS_CTNR_PGDATA}/${tgt_file} \
            |sed '/^[#]/d' |sed '/^\s*$/d' |grep -v trust
        }
    "
}

confconn(){ # ALTER SYSTEM ... @ server $1
    # @ replication params : primary_conninfo, primary_replication_slot_name .
    # Such would be auto-generated upon 'pg_basebackup -R ...' command
    # during bootstrap of the replica (standby) server.
    # Yet BOTH servers are so configured here (for symmetry). 
    #
    # Run before bootstrapping the replica, 
    # and again at replica AFTER bootstrapped.

    # Set sender_host param
    # [[ $1 == $PG1 ]] && host=$PGHA_HOST2
    # [[ $1 == $PG2 ]] && host=$PGHA_HOST1
    # Okay too @ single-node swarm ...
    # UPDATE: Better; REQUIREd @ multi-host swarm; 
    #... service names resolve; `hostname: ...` (@YAML) does NOT resolve
    [[ $1 == $PG1 ]] && host=$PG2
    [[ $1 == $PG2 ]] && host=$PG1

    [[ $host ]] || {
        echo '=== FAIL : host unset';exit 1
    }

    $1 bash -c "
        pw_replicator=\$(cat /run/secrets/pg_pw_replicator 2>/dev/null)
        [[ \$pw_replicator ]] || {
            echo '=== FAIL : /run/secrets/pg_pw_replicator';exit 1
        }

        export primary_conninfo=\"user=replicator password=\${pw_replicator} host=${host} port=5432 sslmode=prefer sslcompression=0 gssencmode=disable krbsrvname=postgres target_session_attrs=any\"

        psql -c \"ALTER SYSTEM SET primary_conninfo TO '\$primary_conninfo';\"

        psql -c \"ALTER SYSTEM SET primary_slot_name TO '$1';\"
    "
}
verify(){ # @ BOTH servers (TODO: separate)
    echo "=== @ pg1"
    pg1 bash -c "
        [[ -f ${PATH_ABS_CTNR_PGDATA}/pg_hba.conf ]] && {
            cat ${PATH_ABS_CTNR_PGDATA}/pg_hba.conf |grep ${ip_pg2:-NO_IP2}
            cat ${PATH_ABS_CTNR_PGDATA}/pg_hba.conf |grep ${APP_DB_NAME}
        }
        [[ -f ${PATH_ABS_CTNR_PGDATA}/postgresql.auto.conf ]] && {
            cat ${PATH_ABS_CTNR_PGDATA}/postgresql.auto.conf |grep primary_conninfo 
            cat ${PATH_ABS_CTNR_PGDATA}/postgresql.auto.conf |grep primary_slot_name
        }
    "
    pg1 bash -c "psql -c 'show listen_addresses;'";true
    
    echo "=== @ pg2"
    pg2 bash -c "
        [[ -f ${PATH_ABS_CTNR_PGDATA}/pg_hba.conf ]] && {
            cat ${PATH_ABS_CTNR_PGDATA}/pg_hba.conf |grep ${ip_pg1:-NO_IP1}
            cat ${PATH_ABS_CTNR_PGDATA}/pg_hba.conf |grep ${APP_DB_NAME}
        }
        [[ -f ${PATH_ABS_CTNR_PGDATA}/postgresql.auto.conf ]] && {
            cat ${PATH_ABS_CTNR_PGDATA}/postgresql.auto.conf |grep primary_conninfo 
            cat ${PATH_ABS_CTNR_PGDATA}/postgresql.auto.conf |grep primary_slot_name
        }
    "
    pg2 bash -c "psql -c 'show listen_addresses;'";true
}

#######
# OPS
#######

reload(){ all bash -c 'psql -c "SELECT pg_reload_conf()"'; }

restart(){ $1 bash -c "pg_ctl restart -D ${PATH_ABS_CTNR_PGDATA} -m fast -s"; true; }

stop(){ $1 bash -c "pg_ctl stop -D ${PATH_ABS_CTNR_PGDATA} -m fast -s"; true; }

lshome(){
    all bash -c "ls -ahl $PATH_ABS_CTNR_PGHOME"
}
lsdata(){
    all bash -c "ls -ahl $PATH_ABS_CTNR_PGDATA" 
}
lsarchive(){
    all bash -c "ls -ahl $PATH_ABS_CTNR_PGARCHIVE"
}
lswal(){
    all bash -c "ls -ahl ${PATH_ABS_CTNR_PGDATA}/pg_wal"
}
users(){
    pg1 bash -c "psql -c '\du'"
}

# Bootstrap a target server off another, 
# and reconfigure target for standby mode of streaming replication
# with replication slots, all from pg_basebackup (run on target).
# - Source server must be running.
# - Target server must NOT be running.
# *****************************************************************************
#  This DELETES ALL pre-existing FILES in target's $PATH_ABS_CTNR_PGDATA dir.
# *****************************************************************************
boot(){ # https://www.postgresql.org/docs/current/app-pgbasebackup.html
    # [[ $1 == $PG1 ]] && { host=$PGHA_HOST2;h=$PG2; }
    # [[ $1 == $PG2 ]] && { host=$PGHA_HOST1;h=$PG1; }
    #... UPDATE: use svc name; postgres server can't resolve dot names:
    #    See conf() : listen_addresses = "$PG1,$PG2"
    [[ $1 == $PG1 ]] && { host=$PG2;h=$PG2; }
    [[ $1 == $PG2 ]] && { host=$PG1;h=$PG1; }

    # The utility (pg_basebackup) gets password from ~/.pgpass file, else prompts for it.
    pgpass $1 #... requires stack (YAML) having the Docker secrets.
    
    # MUST drop replica's replication-slot name if exist at primary.
    # *************************************************************************
    # This pre-process FAILs lest both primary (source) and replica (target) 
    # are on the same (activated) node, which is never the case lest dev/test.
    #   "psql: error: FATAL:  no pg_hba.conf entry for host ..."
    #
    # WORKAROUNDs @ source server 
    #
    #   1. Delete using Makefile recipe:
    #       ☩ dna ap1
    #       ☩ make slotsdelete
    #
    #   2. Delete using psql:
    #       ☩ dna ap1  #... Activate node running pg1 container
    #       ☩ make pg1 #... Launch shell into container
    #       bash-5.1$ psql -c "SELECT pg_drop_replication_slot('pg2')"
    # *************************************************************************
    # $1 bash -c "psql -w -h $host -U $REPLICATOR_USER -d replication -c \"
    #         SELECT pg_drop_replication_slot(slot_name) 
    #         FROM pg_replication_slots WHERE slot_name = '${1}';
    #     \""

    echo "=== @ pg_basebackup -h '$host' -U '$REPLICATOR_USER' -Fp -R -Xs -C ..."
    # At replica, set data cluster to a clone of primary cluster.
    $1 bash -c "
        rm -rf ${PATH_ABS_CTNR_PGDATA:-PGDATA_var_UNSET}/*
        pg_basebackup -h $host -U $REPLICATOR_USER \
            -D $PATH_ABS_CTNR_PGDATA -Fp -R -Xs -C -S ${1}
    " #... -S ... option adds replication-slot name ($1) at primary cluster.
} 

#pg_basebackup -w -h pg1 -U replicator -D /var/lib/postgresql/data -Fp -R -Xs -C -S pg2

# backup : pg_basebackup : tarball $PGDATA into two files; 'base.tar.gz' and 'pg_wal.tar.gz'
backup(){ # https://www.postgresql.org/docs/current/app-pgbasebackup.html
    # [[ $1 == $PG1 ]] && host=$PGHA_HOST1
    # [[ $1 == $PG2 ]] && host=$PGHA_HOST2
    [[ $1 == $PG1 ]] && host=$PG1
    [[ $1 == $PG2 ]] && host=$PG2
    [[ $host ]] || { echo "=== FAIL @ backup server: $1";exit 1; }
    echo "=== @ pg_basebackup -h $host -U $REPLICATOR_USER -Ft -z ..."
    tgt="${PATH_ABS_CTNR_PG_BACKUP}/${1}/$(date -u +"%Y-%m-%dT%H.%M.%SZ")"
    $1 bash -c "
        pg_basebackup -h $host -U $REPLICATOR_USER -D ${tgt} -Ft -z
        echo '=== @ ${tgt}'
        ls -ahl ${tgt}
    "
}

# Promote $1 to primary mode
promote(){
    $1 bash -c "pg_ctl promote -D ${PATH_ABS_CTNR_PGDATA} -t 2"
}
# Switch $1 to standby mode
demote(){
    $1 bash -c "
        touch ${PATH_ABS_CTNR_PGDATA}/standby.signal
        pg_ctl restart -D ${PATH_ABS_CTNR_PGDATA} -m smart -s
    "
    exit 0
}

# Switch $1 to restore mode
restore(){
    $1 bash -c "
        touch ${PATH_ABS_CTNR_PGDATA}/restore.signal
        pg_ctl restart -D ${PATH_ABS_CTNR_PGDATA} -m smart -s
    "
}

# Print servers' activity
activity() {
    $1 bash -c "
        psql ${SESSION_USER_DB} -c '\x' -c 'SELECT * FROM pg_stat_activity'
    "
}

# Test tables : INSERT|DELETE|SELECT(query)
insert(){
    echo "=== @ psql ${SESSION_USER_DB} -c ..."
    $1 bash -c "
        psql ${SESSION_USER_DB} -c 'INSERT INTO foo (ctime) VALUES (CURRENT_TIMESTAMP)'
        psql ${SESSION_USER_DB} -c 'INSERT INTO bar(x) SELECT y FROM generate_series(1, 100000) a(y)'
    "
}
delete(){    
    echo "=== @ psql ${SESSION_USER_DB} -c ..."
    $1 bash -c "psql ${SESSION_USER_DB} -c 'DELETE FROM foo'"; 
 }
query(){
    echo "=== @ psql ${SESSION_USER_DB} -c ..."
    query="
        psql ${SESSION_USER_DB} -c 'SELECT * FROM foo ORDER BY idx ASC'
        psql ${SESSION_USER_DB} -c 'SELECT count(*) as 'bars' FROM bar'
    "
    pg1 bash -c "$query"
    pg2 bash -c "$query"
}

################################
# PostgreSQL server passwords
################################
pgpass(){ # Injects the ~/.pgpass file; does not survive container.
          # Source is YAML "secrets:", so requires running the apropos docker stack.
          # Is required to automate pg_basebackup process; to run sans pw prompt.

    $1 bash -c "
        echo '@ Container : Write ~/.pgpass file'
        tgt='${PATH_ABS_CTNR_PGHOME:-~}/.pgpass'
        pw_postgres=\$(cat /run/secrets/pg_pw_postgres 2>/dev/null)
        pw_replicator=\$(cat /run/secrets/pg_pw_replicator 2>/dev/null)
        pw_db_owner=\$(cat /run/secrets/pg_pw_app_owner 2>/dev/null)
        pw_db_user=\$(cat /run/secrets/pg_pw_app_user 2>/dev/null)

        [[ \${pw_postgres} && \${pw_replicator} && \${pw_db_owner} && \${pw_db_user} ]] && {
            echo '# hostname:port:database:username:password' > \${tgt}
            echo ${PG1}:5432:${POSTGRES_DB}:${POSTGRES_USER}:\${pw_postgres} >> \${tgt}
            echo ${PG2}:5432:${POSTGRES_DB}:${POSTGRES_USER}:\${pw_postgres} >> \${tgt}
            echo ${PG1}:5432:*:${REPLICATOR_USER}:\${pw_replicator} >> \${tgt}
            echo ${PG2}:5432:*:${REPLICATOR_USER}:\${pw_replicator} >> \${tgt}
            echo ${PG1}:5432:${APP_DB_NAME}:${APP_DB_OWNER}:\${pw_db_owner} >> \${tgt}
            echo ${PG2}:5432:${APP_DB_NAME}:${APP_DB_OWNER}:\${pw_db_owner} >> \${tgt}
            echo ${PG1}:5432:${APP_DB_NAME}:${APP_DB_USER}:\${pw_db_user} >> \${tgt}
            echo ${PG2}:5432:${APP_DB_NAME}:${APP_DB_USER}:\${pw_db_user} >> \${tgt}
            chmod 600 \${tgt}
        } || { echo 'FAIL : /run/secrets/... NOT EXIST';exit 1; }
    "
}
#**************************************************************************************
# Note: TO RESET passwords per EITHER rotate or create/replay, 
# must first take down service, 
# then make docker secrets per `make pwcreate1|pwrotate1`, 
# then restart service, then `make pwcreate|pwrotate`.
#**************************************************************************************

# Rotate : OVERWRITE passwords @ pgha.env FILE, and ALTER ... @ running server.
pwRotate(){
    # Run script locally to generate pgha.env, and recreate docker secrets (if possible). 
    # Note script DOES NOT RESET docker secrets LEST service is DOWN;
    # so reset requires two (2) runs; first when down, then again after restart.
    $PATH_ABS_HOST_ASSETS/.env/pgha.env.sh 
    #... CREATE NEW passwords; OVERWRITE pgha.env FILE.

    # Set passwords @ PostgreSQL server ($1) per ALTER ROLE ...
    $1 bash -c "
        echo '@ Container : Rotate all passwords per Docker secrets'
        pw_postgres=\$(cat /run/secrets/pg_pw_postgres 2>/dev/null)
        pw_replicator=\$(cat /run/secrets/pg_pw_replicator 2>/dev/null)
        pw_db_owner=\$(cat /run/secrets/pg_pw_app_owner 2>/dev/null)
        pw_db_user=\$(cat /run/secrets/pg_pw_app_user 2>/dev/null)

        [[ \$pw_postgres && \$pw_replicator && \$pw_db_owner && \$pw_db_user ]] || {
            echo 'FAIL : /run/secrets/... NOT EXIST';exit 1
        }
        echo '@ PostgreSQL server : Rotate ALL passwords : ALTER ROLEs ...'
        psql -c \"
            ALTER ROLE ${POSTGRES_USER:-postgres} WITH PASSWORD '\$pw_postgres';
            ALTER ROLE $APP_DB_OWNER WITH PASSWORD '\$pw_db_owner';
            ALTER ROLE $APP_DB_USER WITH PASSWORD '\$pw_db_user';
            ALTER ROLE $REPLICATOR_USER WITH PASSWORD '\$pw_replicator';
        \"
    "
}
# Create : Replay passwords EXISTING @ pgha.env FILE
pwCreate(){
    # Run script locally to generate pgha.env, and recreate docker secrets (if possible).
    $PATH_ABS_HOST_ASSETS/.env/pgha.env.sh replay 
    #... REPLAY passwords EXISTING @ pgha.env FILE.

    # Set passwords @ PostgreSQL server ($1) per ALTER ROLE ...
    $1 bash -c "
        pw_postgres=\$(cat /run/secrets/pg_pw_postgres 2>/dev/null)
        pw_replicator=\$(cat /run/secrets/pg_pw_replicator 2>/dev/null)
        pw_db_owner=\$(cat /run/secrets/pg_pw_app_owner 2>/dev/null)
        pw_db_user=\$(cat /run/secrets/pg_pw_app_user 2>/dev/null)

        [[ \$pw_postgres && \$pw_replicator && \$pw_db_owner && \$pw_db_user ]] || {
            echo 'FAIL : /run/secrets/... NOT EXIST';exit 1
        }
        echo '@ PostgreSQL server : Reset all per EXISTING secrets : ALTER ROLEs ...'
        psql -c \"
            ALTER ROLE ${POSTGRES_USER:-postgres} WITH PASSWORD '\$pw_postgres';
            ALTER ROLE $APP_DB_OWNER WITH PASSWORD '\$pw_db_owner';
            ALTER ROLE $APP_DB_USER WITH PASSWORD '\$pw_db_user';
            ALTER ROLE $REPLICATOR_USER WITH PASSWORD '\$pw_replicator';
        \"
    "
}
pwDefault(){
    # Set passwords @ PostgreSQL server ($1) per ALTER ROLE ...
    echo "Default @ DB_PASSWORD : $DB_PASSWORD"
    $1 bash -c "
        echo '@ PostgreSQL server : Set all to DB_PASSWORD : ALTER ROLEs ...'
        psql -c \"
            ALTER ROLE ${POSTGRES_USER:-postgres} WITH PASSWORD '$DB_PASSWORD';
            ALTER ROLE $APP_DB_OWNER WITH PASSWORD '$DB_PASSWORD';
            ALTER ROLE $APP_DB_USER WITH PASSWORD '$DB_PASSWORD';
        \"
    "
    #... Leave REPLICATOR_USER password unchanged; is for PGHA internal use only;
    #    is also set @ primary_conninfo; no reason to reset that role.
}

pwOps(){ # Reset passwords @ selected svcs.users table records
    echo "Passwords reset per assets/keys/db_ops_pass : 'app', 'dev', 'ops', 'AdminTest', 'UserTest'"
    export pw="$(cat ${PATH_ABS_HOST_ASSETS}/keys/db_ops_pass)"
    $1 bash -c "
        psql -U $APP_DB_USER -d $APP_DB_NAME -c \"
            UPDATE users SET 
                pass_hash = pw_hash('$pw'),
                date_update = now()
            WHERE handle IN ('app', 'dev', 'ops', 'AdminTest', 'UserTest');
        \"
    " #... manually @ any : SELECT pw_reset('uzrHandle', 'aNewPW');
}


# RUN ...
$@
