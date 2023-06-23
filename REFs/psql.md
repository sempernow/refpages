# [`psql` :: client CLI utility](https://www.postgresql.org/docs/10/app-psql.html)

## tl;dr 

#### Run a [postgres](https://hub.docker.com/_/postgres/ "@ Docker Hub") server in a container

```bash
docker volume create pg_vol

# per run 
docker run -d --rm --name 'dbp' -p 5432:5432 \
    -v pg_vol:/var/lib/postgresql/data \
    -v "$(pwd)/assets/sql":/home \
    -e POSTGRES_DB='db1' \
    -e POSTGRES_PASSWORD='pw1234' \
    -e POSTGRES_USER='uzr1' \
    'postgres:12.6-alpine'

# per service @ swarm mode 
docker swarm init 

docker service create --name 'dbp' -p 5432:5432 \
    --mount source=pg_vol,target=/var/lib/postgresql/data \
    --mount type=bind,source="$(pwd)/assets/sql",target=/home \
    -e POSTGRES_DB='db1' \
    -e POSTGRES_PASSWORD='pw1234' \
    -e POSTGRES_USER='uzr1' \
    'postgres:12.6-alpine'

```
- Persist db data per Docker volume (`VOL_NAME:CTNR_PATH`)
    - `pg_vol` <=> `/var/lib/postgresql/data`
- Access local dir per Docker bind-mount (`LOCAL_PATH:CTNR_PATH`)
    - `./assets/sql` <=> `/home` 

#### Execute an Interactive bash shell @ running `dbp` container 

```bash
# If Postgres server running per `docker run ...` 
docker exec -it dbp sh -c 'ls -ahl /home'

# If Posgres server running per `docker service create ...`
docker exec -it $(docker ps -q -f name=dbp -f status=running | head -n 1) sh -c 'ls -ahl /home'
```

... either way, same action ...

```plaintext
total 165K
...
drwxrwxrwx    1 root     root        4.0K Sep 23 13:44 dump
-rwxr-xr-x    1 root     root         248 Feb 16 16:55 init.sql
drwxrwxrwx    1 root     root           0 Sep 24 21:49 migrate
-rwxr-xr-x    1 root     root         541 Aug  8  2020 models.sh
...
```

#### Launch `psql` (Postgres-client session) from `bash`|`sh` (host shell)

```bash
# Launch session (as root user; at Alpine)
psql -U uzr1 db1  
```
```bash
# Run any SQL or psql command
psql -U uzr1 db1 -c '\l'
psql -U uzr1 db1 -c 'SELECT * FROM foo;'
```

If server is started sans custom user/pass, then defaults to `postgres`/`postgres`, so &hellip;

```bash
su postgres       #... @ Alpine
sudo postgres -i  #... @ Ubuntu
# Change to dir containing our 'init.sql'
cd /home
# Load SQL per file; 
psql -U postgres -d postgres -f init.sql

```
- Postgres images are _built to start shell as root user_ (from `docker exec -it ...`).

#### `psql` : to/from remote host (`-h`)

Password @ `~/.pgpass` of current shell, else prompts. Unnecessary to use option `-w` to suppress prompt, and connection fails if `psql` is unable to acquire credentials.

```bash
# Declare connection params
h='pg2';u='svcs';db='db1'

# Connect
psql -U $u -d $db -h $h
```

Per [`conninfo`](https://www.postgresql.org/docs/12/libpq-connect.html#LIBPQ-PARAMKEYWORDS) string.

```bash
# Declare connection params
h='pg2';u='svcs';db='db1'

# Connect
psql "postgresql://${h}/${db}?user=${u}"
# Or
psql "postgresql:///${db}?host=${h}&user=${u}"
```
- SSL may be required for certain users and/or databases
    ```bash
    psql -U replicator -d replication -h pg1 -w
    ```
    ```plaintext
    psql: error: FATAL:  no pg_hba.conf entry for host "10.0.200.4", user "replicator", database "replication", SSL off
    ```

##### `init.sql`

Create custom user (`uzr1`) and db (`db1`) per SQL file:

```sql
-- create a db
CREATE DATABASE db1;
-- create user
CREATE USER uzr1 WITH PASSWORD 'pw1234';
-- auth as superuser
ALTER USER uzr1 WITH SUPERUSER;
-- grant privileges
GRANT ALL PRIVILEGES ON DATABASE db1 to uzr1;
-- connect to db as user 
\c db1 uzr1
```

#### @ psql shell (client session)

```psql
db1=# \c
You are now connected to database "db1" as user "uzr1".
db1=# \i migrate.sql
...
db1=# SELECT * FROM users;
...
\q
```
... exits back to bash shell.

#### Backup `db1` from bash shell

```bash
# Backup entire db1
pg_dump -U uzr1 -d db1 > db1.dump.sql
```

#### Restore per `db1.dump.sql` 

```bash
# Recreate usr1, db1 (if new ctnr/shell)
psql -U postgres -d postgres -f config.sql
# Restore db1
psql -U uzr1 db1 < db1.dump.sql
```



### [Start _interactive session_](https://www.postgresqltutorial.com/psql-commands/) 

##### PostgreSQL server @ Docker ([`postgres.docker.sh`](postgres.docker.sh))

```bash
# Launch DBMS server
docker run -d --rm --name db -p 5432:5432 -v "$(pwd)":/home $image
# Launch session @ DBMS server 
docker exec -it db bash -c "cd /home && psql -U postgres" 
```
@ Host machine, after creating a database and user per above &hellip;

```bash
psql -h localhost -p 5432 -U userfoo -d dbfoo
```

#### @ PostgreSQL server host

```bash
psql -h 'localhost' -p 5432 -U 'uzr1' -d 'db1'
# Prompt for password; server @ localhost
psql -U 'uzr1' -W  
```
- Note the password requirement is _disabled_ @ `localhost`
    - @ Docker Hub's `postgres` image(s)
    - Default creds:
        - Port: 5432 
        - User: postgres
        - Password: postgres
        - Database: postgres

#### @ Docker container ([`postgres.docker.sh`](postgres.docker.sh))

```bash
psql -U postgres -d DBNAME
```
or 
```bash
su - postgres 
```
```bash
psql -d DBNAME
```

### `psql` Meta Commands 

Tricky syntax; mutliple, case dependent, type dependent syntaxes !

>PostgreSQL documentation incorrectly claims that unquoted always resolves to the value, but not so if string type _unless_ its a PostgreSQL object name.

```sql
\set tbl 'foo'
SELECT * FROM :tbl;     -- Requires UNQUOTED or DOUBLE QUOTES : Returns table content
SELECT * FROM :"tbl";   -- Requires UNQUOTED or DOUBLE QUOTES : Returns table content

 idx |             ctime
-----+-------------------------------
   1 | 2022-01-02 14:53:23.921686+00
(1 row)

db1=> SELECT :'tbl';    -- Requires QUOTED IF value is string : Returns value

 ?column?
----------
 foo
(1 row)

\set x 22
db1=> SELECT :x;    -- May be QUOTED or UNQUOTED IF value is integer : Returns value

 ?column?
----------
       22
(1 row)
```

#### @ Interactive `psql` Session

Prompt &hellip; 

```
<DBNAME>=#
```
Commands (_sans semicolon!_) &hellip;
```plaintext
\?                  # Help
\h <COMMAND>        # Info on <COMMAND>   
\set <NAME> <VAL>   # Set a global variable; USAGE: `... = :<NAME>`
\l                  # Databases  
\c <DB> [<USER>]    # Connect to <DB> @ <USER> (default to current)
\d                  # Relations
\dn                 # Schemas
\dt                 # Tables 
\d+ <TABLE>         # Table schema
\dn+                # Access Privileges
\dv                 # Views
\du                 # Users
\g                  # Previous Command 
\s                  # History of commands
\s <FILE>           # Save History to <FILE>
\i <FILE>           # Execute SQL in <FILE>
\e                  # Editor; execute on save/exit (per $EDITOR).
\ef <FUNCNAME>      # Edit function <FUNCNAME>
\timing             # Execution Time (toggle)
\a                  # Align output per column (toggle)
\H                  # HTML output
\x                  # Expanded display (toggle)
\q                  # Quit (end session)
```
Also accepts any `SQL` (`pSQL`) statement, of course &hellip;
```
SELECT version();
```

@ E.g., &hellip;

```client
foo=# SELECT owner_id AS id, slug AS path FROM channels;
   id  |  path
-------+--------
 45b5f | slug-1
 5cf37 | slug-2
 45b5f | slug-3
```

### `psql` @ host 


```bash
su - postgres  # switch to 'postgres' user (@ alpine)
```

```bash
# @ Docker container shell (bash) ...
pushd home 

# Config file Location 
psql -c 'SHOW config_file'
# Version of SERVER (postgres daemon)
psql -c 'SELECT version();'     
# Version of CLIENT (psql) 
psql --version                  

# Create a database 
psql -c 'CREATE DATABASE foo;'
psql -c 'CREATE TABLE bar (id INT);' foo
#... sans db name, creates table @ default db (postgres)

psql -f ./sql/migrate.sql
psql -c 'SELECT * from topics'
psql -c 'SELECT owner_id as id, slug as path FROM channels'
```

### [Config Settings : Files / Params](https://www.postgresql.org/docs/current/config-setting.html)

Located @ data directory; nominally `/var/lib/postgresql/data/`

- `postgresql.conf`
    ```conf
    # This is a comment
    log_connections = yes
    log_destination = 'syslog'
    search_path = '"$user", public'
    shared_buffers = 128MB
    # References to other, additional configs ...
    include_dir 'conf.d'
    #... relative to current dir.
    include '00shared.conf'
    include '01memory-8GB.conf'
    include '02server-foo.conf'
    #... such naming assures load order.
    #    Last setting overrides prior(s).
    ```
- `postgresql.auto.conf`
    - Auto-generated/modified 
    ```sql
    -- scope : global (cluster wide)
    ALTER SYSTEM ...
    ```
    ```sql
    -- scope : per database
    ALTER DATABASE
    ALTER ROLE
    ```
    ```sql
    -- scope : session 
    SHOW ...
    current_setting(setting_name text)
    SET ...
    set_config(setting_name, new_value, is_local)
    ```
    - SQL command and its equivalent function.
- On startup (`-c` option)
    ```bash
    postgres -c log_connections=yes -c log_destination='syslog'
    ```
- Relaod config 
    ```sql
    -- @ SQL (psql session)
    pg_reload_conf();
    ```
    ```bash
    # @ bash
    pg_ctl reload
    ```

## [SSH tunnel](https://www.postgresql.org/docs/8.2/ssh-tunnels.html "postgresql.org/docs")

Secure TCP/IP Connections with SSH Tunnels

```bash
ssh -L 3333:foo.com:5432 joe@foo.com

psql -h localhost -p 3333 postgres
```

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (MD | HTML)

([MD](___.html "@ browser"))   


# Bookmark

- Reference
[Foo](#foo)
- Target
<a name="foo"></a>

-->

