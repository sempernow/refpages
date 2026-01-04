#!/usr/bin/env bash
# -----------------------------------------------------------------------------
#  PostgreSQL @ Docker 
#  - Auto-detect existing ctnr/user/db, and exec into it, else run anew.
# -----------------------------------------------------------------------------
# psql  https://www.postgresql.org/docs/10/app-psql.html
# docker hub  https://hub.docker.com/_/postgres

echo "=== DEPRICATED : Obsolete"
exit
# Select host folder of bind-mount volume, per env var or internal default.
export ctnr='dbp' #'pg-'$(date +%H.%M.%S)
export dir_host=${PATH_ABS_HOST_ASSETS/sql:-/assets/sql}
# Set ctnr mount dir (per postgres image authors).
export dir_ctnr='${PATH_ABS_CTNR_PGHOME}' 
# Set image.
#export image='postgres:11.2'         # 11.8  https://hub.docker.com/_/postgres 
#export image='postgres:11.1-alpine'  # dbp @ app. 
#export image='postgres:9.6-alpine'  # No script 
export image='postgres:12.7-alpine'   # REQUIREs -e $user -e $pass

# If ctnr already running (presumably config'd per app), 
# then set user and db per env vars, else to postgres image defaults.
[[ "$(docker ps | grep ${ctnr})" ]] && export _ranPre=1

# If no running ctnr, then start one.
[[ "$_ranPre" ]] || {
    echo "Mount @ HOST DIR: $dir_host"
    docker run -d --rm --name $ctnr -p 5432:5432 \
    -v ${dir_host}:${dir_ctnr} \
    -e POSTGRES_DB=${DB_NAME:-dbp} \
    -e POSTGRES_PASSWORD=${DB_PASSWORD:-postgres} \
    -e POSTGRES_USER=${DB_USER:-postgres} \
    $image
} #... @ Windows/WSL may REQUIRE `/` prepended to host path; `-v "/$(pwd)":$dir`

# Wait for db connectivity; allow for either, (un)configured, environemnt.
dbConn(){ 
    docker exec -it $ctnr bash \
    -c "psql -U $1 -d $2 -c 'SELECT true' -x" \
    | grep 'bool | t' 
}
con1(){ export pguser='postgres' && export db='postgres' && dbConn $pguser $db; }
con2(){ export pguser=${DB_USER} && export db=${DB_NAME} && dbConn $pguser $db; }

while [[ ! ( "$( con1 )" || "$( con2 )" ) ]]; do sleep 1; done 

[[ "$( con1 )" ]] && { export pguser='postgres'; export db='postgres'; } 
[[ "$( con2 )" ]] && { export pguser=${DB_USER}; export db=${DB_NAME}; }
echo "user: $pguser" 
echo "  db: $db"
#echo "1: '$( con1 )', 2: '$( con2 )'"; exit

# User query/select shell: bash (1) or psql (2)
cat<<-EOX

    PostgreSQL server container (${image}) session
    
    1) Bash shell :: config:

        $ su - pgUserName
        $ cd ${PATH_ABS_CTNR_PGHOME} 
        $ apt-get update 
        $ apt-get install vim  
        $ export EDITOR=vim  # psql: \e

    2) Interactive psql

        \h <COMMAND>        # Info on <COMMAND>   
        \a                  # (Un)align output per column (toggle)
        \set <NAME> <VAL>   # Set a global variable; USAGE: `... = :<NAME>`
        \l                  # Databases  
        \c <DB> [<USER>]    # Connect to <DB> @ <USER> (default to current)
        \d                  # Relations
        \dn                 # Schemas
        \dt                 # Tables 
        \d+ <TABLE>         # Table schema
        \dv                 # Views
        \du                 # Users
        \g                  # Previous Command 
        \s                  # History of commands
        \s <FILE>           # Save History to <FILE>
        \i <FILE>           # Execute SQL in <FILE>
        \e                  # Editor; execute on save/exit (per $EDITOR).
        \ef <FUNCNAME>      # Edit function <FUNCNAME>
        \timing             # Execution Time (toggle)
        \q                  # Quit (end session)
EOX
read q1
case $q1 in
    "1") 
        # -------------------------------
        # Bash shell @ PostgreSQL server.
        docker exec -it $ctnr bash 
    ;;
    "2")
        # ---------------------------------
        # PostgreSQL client (psql) session.
        docker exec -it $ctnr bash -c "cd $dir_ctnr/sql && psql -U ${pguser} -d ${db}" 
    ;;
esac

# Shut down ctnr IFF started herein, else leave it alone and quit.
[[ "$_ranPre" ]] || {
    printf  "\n  %s ... " "Stop and remove container"
    docker stop $ctnr
    printf "\n%s" 'DONE'
}
exit

# ls 
alias ls='ls -l';alias ll='ls -lL --color=auto --group-directories-first'