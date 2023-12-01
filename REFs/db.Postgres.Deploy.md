# Postgres Deployment

```bash
docker run -d --rm --name $ctnr -p 5432:5432 \
    -v $(pwd):/home \
    -e POSTGRES_DB=${DB_NAME:-dbp} \
    -e POSTGRES_PASSWORD=${DB_PASSWORD:-postgres} \
    -e POSTGRES_USER=${DB_USER:-postgres} \
    'postgres:12.6-alpine'
```
- persist: `-v $(pwd)/local_pg_data_dir:/var/lib/postgresql/data`

## [Warm Standby](https://wiki.postgresql.org/wiki/Warm_Standby)

```bash
# Limit addresses per 'postgresql.conf'
psql -U 'uzr1' -d 'db1' -c 'show listen_addresses'
```
- Cannot be `localhost` if @ Docker swarm cluster

## [Server Config](https://www.postgresql.org/docs/current/runtime-config.html)

- `/etc/postgresql/postgresql.conf`
- `/var/lib/postgresql/data/postgresql.conf`
    - @ Alpine variants

## Data directory (default is config dir)

- `/var/lib/postgresql/data`

#### Show Location:

```bash
psql -h $host -U $user -c 'SHOW config_file;'
```
```sql 
SHOW config_file;
```
- Sample config included @ [PostgreSQL images](https://hub.docker.com/_/postgres "hub.docker.com"):
    - `/usr/share/postgresql/postgresql.conf.sample` 
    - `/usr/local/share/postgresql/postgresql.conf.sample`
        -  @ Alpine variants

## Reload @ running server:

- @ `bash` :: `pg_ctl`
    ```bash
    pg_ctl reload
    ```
- @ SQ: :: `psql`
    ```sql
    SELECT pg_reload_conf()
    ```

## [Authentication](https://wiki.postgresql.org/wiki/Client_Authentication "https://wiki.postgresql.org/wiki/Client_Authentication") | [`pg_hba.conf`](https://www.postgresql.org/docs/12/auth-pg-hba-conf.html)

### Password reset; align with `bcrypt` method @ services (Golang) 

```sql
UPDATE users SET pass_hash = crypt('$DB_OPS_PASS', gen_salt('bf', 10))
WHERE (handle = 'app') OR (handle = 'AdminTest') OR (handle = 'UserTest');
```

## [@ Docker](https://hub.docker.com/_/postgres "hub.docker.com :: postgres")

```plaintext
13.1, 13, latest
13.1-alpine, 13-alpine, alpine
12.5, 12
12.5-alpine, 12-alpine
11.10, 11
11.10-alpine, 11-alpine
10.15, 10
10.15-alpine, 10-alpine
9.6.20, 9.6, 9
9.6.20-alpine, 9.6-alpine, 9-alpine
9.5.24, 9.5
9.5.24-alpine, 9.5-alpine
```

## [@ AWS RDS](https://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html) :: [Managed RDBMS Engine per AMI Instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts)

```bash
# Versions list
aws rds describe-db-engine-versions \
    --engine 'postgres' \
    | jq -r '.DBEngineVersions[].EngineVersion'
```
- `9.5.2, ..., 9.6.8-20, 10.9-15, ..., 11.4-10, ..., 12.2-5` (2021-02-10)

## Storage :: Persistence 

- [How to persistent storage in Docker](https://stackoverflow.com/questions/18496940/how-to-deal-with-persistent-storage-e-g-databases-in-docker)
    ```bash
    docker volume create --name vol1
    docker run -d -v vol1:/ctnr_path ctnr_image _some_cmd
    ```
- [How to persist dockerized postgres database](https://stackoverflow.com/questions/41637505/how-to-persist-data-in-a-dockerized-postgres-database-using-volumes)
    ```yaml
    volumes:
      - ./pg_local_data:/var/lib/postgresql/data
    ```
- [How to copy docker volume from one machine to another?](https://stackoverflow.com/questions/42973347/how-to-copy-docker-volume-from-one-machine-to-another)

### @ AWS :: EC2/EBS

1. Attach EBS volume (disk) to EC2 instance
    - `/dev/xvdh`
1. Make partition (optional)
    - `/dev/xvdh1`
1. Make filesystem on the partition/disk
1. Mount filesystem inside EC2 instance 
    - `/opt/ebs_data`
1. Start Docker container with volume
    - `/opt/ebs_data:/var/lib/postgresql/data`


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

