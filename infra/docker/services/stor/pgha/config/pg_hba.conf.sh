#!/usr/bin/env bash
#------------------------------------------------------------------------------
#  Makefile : confhba : pg_hba.conf
# 
#  pipe1 allows config from (this) host sans file upload(s) to target host(s).
# -----------------------------------------------------------------------------
# IP Address(es) of containerized (swarm) services are ephemeral (per container),
# so allow connections from any address within a declared subnet ($NET_PGHA_CIDR).

[[ "$REPLICATOR_USER" ]] || {
    echo "=== FAIL @ ${0##*/} : REPLICATOR_USER unset";exit 1
}
[[ "$NET_PGHA_CIDR" ]] || {
    echo "=== FAIL @ ${0##*/} : NET_PGHA_CIDR unset";exit 1
}
mkfifo pipe1
cat <<-EOH > pipe1 &
##########################################################################
###  AUTO-GENERATED @ ${0##*/} : pg_hba.conf
##########################################################################

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust

# Replication connections from localhost
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust

# Replication connections from anywhere within declared subnet
host    replication     $REPLICATOR_USER      $NET_PGHA_CIDR            scram-sha-256
# Application connections from anywhere within declared subnet
host    $APP_DB_NAME             $APP_DB_OWNER            $NET_PGHA_CIDR            scram-sha-256
host    $APP_DB_NAME             $APP_DB_USER            $NET_PGHA_CIDR            scram-sha-256
EOH
cat < pipe1
rm pipe1