# PostgreSQL HA Cluster | [Server Configuration](https://www.postgresql.org/docs/current/runtime-config.html)

## [Client Apps](https://www.postgresql.org/docs/current/reference-client.html) : [`psql`](https://www.postgresql.org/docs/current/app-psql.html) | [`pg_ctl`](https://www.postgresql.org/docs/current/app-pg-ctl.html) | [`initdb`](https://www.postgresql.org/docs/current/app-initdb.html) | [`pg_basebackup`](https://www.postgresql.org/docs/current/app-pgbasebackup.html "postgresql.org/docs") | &hellip;

## [Configuration](https://www.postgresql.org/docs/current/runtime-config.html) ([fnames/locations](https://www.postgresql.org/docs/current/runtime-config-file-locations.html)) : [`pg_hba.conf`](assets/pgha/config/pg_hba.conf)

- [Log-Shipping Standby Servers](https://www.postgresql.org/docs/current/warm-standby.html)
    - [Streaming-Replication Protocol](https://www.postgresql.org/docs/current/protocol-replication.html)
    - [Streaming Replication](https://www.postgresql.org/docs/current/warm-standby.html#STREAMING-REPLICATION)
        - [Standby Servers](https://www.postgresql.org/docs/13/runtime-config-replication.html#RUNTIME-CONFIG-REPLICATION-standby)
        - [Standby Server Operation](https://www.postgresql.org/docs/current/warm-standby.html#FILE-standby-SIGNAL)
        - [Replication params](https://www.postgresql.org/docs/current/runtime-config-replication.html)
        - [Replication Functions](https://www.postgresql.org/docs/current/functions-admin.html#FUNCTIONS-REPLICATION)
            - `SELECT pg_drop_replication_slot('foo');`
- [Backup/Restore](https://www.postgresql.org/docs/13/backup.html)
    - [Continuous Archiving](https://www.postgresql.org/docs/13/continuous-archiving.html)
        - [Continuouos Archiving @ Standby](https://www.postgresql.org/docs/current/warm-standby.html#CONTINUOUS-ARCHIVING-IN-standby)
        - [Archive Recovery](https://www.postgresql.org/docs/13/runtime-config-wal.html#RUNTIME-CONFIG-WAL-ARCHIVE-RECOVERY)
            - `recovery.signal` file, `archive_command`, `recovery_command`
            - [`recovery.conf` : DEPRICATED (v12)](https://www.postgresql.org/docs/current/recovery-config.html)
- [System Administration Functions](https://www.postgresql.org/docs/current/functions-admin.html)
- [Server Configuration](https://www.postgresql.org/docs/current/runtime-config.html)
    - [Write Ahead Log (WAL)](https://www.postgresql.org/docs/current/runtime-config-wal.html)
- [Authentication Methods](https://www.postgresql.org/docs/current/auth-methods.html)

# TL;DR 

## Streaming Replication : Symmetric Servers

Streaming Replication with Replication Slots implemented on a symmetrical pair of containerized PostgreSQL servers running in a Docker swarm stack. This is a native PostgreSQL (v12/13) implementation, sans external dependencies. The servers are stateless. State is maintained in the peristent data store mounted thereto.

The functional difference between the two servers is that one is in primary (read/write) mode and the other is in hot standby (read-only). The primary is continuously archiving, and the standby is continuously recovering; both per WAL (file) shipping. Separately, point-in-time recovery (PITR) and cluster backup (base backup) are available ad-hoc, imperatively, while the servers are online. All such functionality is per canonical PostgreSQL implementation. 

The symmetrical arrangement is robust and simple to configure. The distinctions between the two servers amount to a zero-byte signal file (`standby.signal`) existing exclusively in the `$PGDATA` directory of whichever is in standby mode; that and the requisite anti-symmetrical settings of replication-connection parameters. Beyond that, they are identical. Each server has a unique host name, and each its own data and archive stores. Extending the scheme to multiple standby servers requires only cloning the one and the processes to configure it.

> Note that _primary_/_standby_ are ___operational___ declarations, whereas each server/service is configured per ___hardware___ declarations and its relevant identity and connection parameters. The point being the former are swappable, while the latter must remain immutable; the (operational) role of a server/service is what toggles, not the server-service-hardware associations. All relevant code must abide the distinction. In a containerized deployment, each PostgreSQL server is a named service, constrained (tethered) to its (configured) hardware regardless of its container(s) popping in and out of existence to provide the services. 

Bootstrapping and ad hoc backup (tarball) processes both utilize the same PostgreSQL utility (`pg_basebackup`); both operating on the `$PGDATA` directory. After servers' initialization and bootstrap, failover(s) are performed by merely adding the `standby.signal` file to the former (demoted) primary, and deleting same from the former (promoted) standy. PITR is performed similarly. Though the servers can swap modes on demand at any time, the scheme is primarily for automated failover. Total transition time is set by application latency; there should never be two primary servers, so the demote/promote duration should be sufficient to assure this. Lest the PostgreSQL servers are spread across the globe, this is typically tens of milliseconds. That's the duration over which clients would lose write access on failover (or any other change of primary).

Routing requests to the appropriate server is an external responsibility. According to PostgreSQL documentation, best performance is achieved when the (hot) standby services all read requests, lightening the load of the primary as it services all write requests. The idea there is the anti-symmetrical nature of such processes; the former being relatively greater in number and lower in computational intensity per, and the latter being the reverse of those two metrics.

## Features / Functions / Modes / Topologies

- Write-Ahead Log Shipping; Streaming Replication (SR) with Replication Slots (RS) assures replica integrity, yet sacrifices limitation on required storage size.
- Shared-Disk Failover; the simplest HA topology; implement with a lone server (sans SR) as a Docker service; under Docker swarm other topologies are available, scaling out from this one server/storage; multiple nodes/storage schemes.
- Continuous Archiving (CA) works with SR/RS~~, but for ephemeral IPs~~ UPDATE: Accepts Docker hostnames.
- Two symmetrical servers (primary/standby)
    - SR/RS + CA
    - Servers each have their own set of data and archive volumes
    - Declarative promote/demote.
    - Bootstrap standby off of primary.
        - ~~The primary does the archiving, so it too must be restarted on new config, yet ephemeral IPs then require standby restart to affect new `primary_conninfo`.~~
        - UPDATE: Using Docker hostnames (See stack YAML) and declarative CIDR subnet, connection config settings are created/loaded only once per cluster; unchanged per (ephemeral) container/IP.
            ```bash
            docker network create --driver=overlay --attachable \
                --subnet=${PGHA_CIDR} \
                --gateway=10.0.200.1 \
                ${PGHA_NET}
            ```
- Streaming Replication is its own orthogonal world. Each server has its own volume. Archive volume is shared. Restore/backup per bootstrap method only, else recovery states (primary/standby) are out of synch and prevent streaming thereafter.
    - `pg_basebackup` is the tool for both bootstrapping the standby and for archiving; merely different option settings. Used for the former, it generates the config/connectivity settings and writes them to `postgresql.auto.conf`, and creates the `standby.signal` file @ `$PGDATA` that triggers streaming.
        - Bootstrapping is cloning the `$PGDATA` dir of primary to that of the standby; requires the source (primary) server running and the target (standby-to-be) server not running. See the `bootstrap` bash functions @ `make.do.sh`.
    - Archive thereunder/thereafter is a clone of `$PGDATA` directory, either as is or two `tar(.gz)` files; utilizing the same tool as for bootstrapping (`pg_basebackup`), but with different options (sans streaming/config).
        - one file is of WAL files, the other is of everything else.
    - Automating failover requires orthogonal process(es); hence `repmgr` etal.
- ~~Contiuous archive --`archive_mode = on`, `archive_command`, `restore_command`, ... --interferes with streaming replication, at least if using replication slots. Untested otherwise.~~ UPDATE: works with SR/RS !! (See above.)

## [Standalone Hot Backups](https://www.postgresql.org/docs/current/continuous-archiving.html#BACKUP-TIPS) | [`pg_basebackup`](https://www.postgresql.org/docs/current/app-pgbasebackup.html)

Simplest, but least live; not HA. See Barman solution.

`pg_basebackup` is used to take a base backup of a running PostgreSQL database cluster. The backup is taken without affecting other clients of the database, and can be used both for point-in-time recovery and as the starting point for a log-shipping or streaming-replication standby server.

___Makes an exact copy of your data directory___ so, all you need to do to restore from that backup is to point postgres at that directory and start it up.


```bash
pg_basebackup -h $hostname -U $username -D $local_dir
```
- User must have REPLICATION permissions or be superuser
- `pg_hba.conf` must permit the replication connection. 
- The server must also be configured with `max_wal_senders` set high enough to provide at least one `walsender` for the backup plus one for WAL streaming (if used).

```bash
# This works @ Docker stack @ default settings  ...
pg_basebackup -h localhost -U uzr1 -D /home/pgbasebackup  
#... 48MB
pg_basebackup -h localhost -U uzr1 -D /home/pgbasebackup_tgz --format=tar --gzip  
#... 4MB
```
- @ service (YAML) : `dbp:` : `volumes:`
    - `dbp1_data:/var/lib/postgresql/data` (named)
    - `${PATH_VM_ASSETS}/sql:/home` (mount)

```conf
archive_command = 'test ! -f /var/lib/pgsql/backup_in_progress || (test ! -f /var/lib/pgsql/archive/%f && cp %p /var/lib/pgsql/archive/%f)'

archive_command = 'local_backup_script.sh "%p" "%f"'

# FAILs to do anything at all ...
restore_command = 'cp /home/pgbasebackup/%f "%p"'
```
```bash
touch /var/lib/pgsql/backup_in_progress
psql -c "select pg_start_backup('hot_backup');"
tar -cf /var/lib/pgsql/backup.tar /var/lib/pgsql/data/
psql -c "select pg_stop_backup();"
rm /var/lib/pgsql/backup_in_progress
tar -rf /var/lib/pgsql/backup.tar /var/lib/pgsql/archive/
```

Compressed

```conf
archive_command = 'gzip < %p > /var/lib/postgresql/data/%f'

restore_command = 'gunzip < /home/pgbasebackup/%f > %p'
```

## Recover/Restore from Hot Backup

- Add to postgres.conf
    ```conf
    restore_command = 'cp /home/pgbasebackup/%f "%p"'
    ```
- Add `recovery.signal` file to data directory, and restart???
    - Manually adding that blank file does in fact trigger some kind of failed attempt to do something, according to the logs, but  this "recovery" does nothing whatsoever, except complain that it can't "stat" archived WAL files; that it can't find the archived files it finds! It finds them, hence it can find them. 
    

### `recovery.conf` is OBSOLETE per v.12

[`FATAL:  using recovery command file "recovery.conf" is not supported`](https://www.2ndquadrant.com/en/blog/replication-configuration-changes-in-postgresql-12/)

- ~~Add this `recovery.conf` to data directory.~~ 
    ```bash
    restore_command = 'cp /home/pgbasebackup/%f "%p"'
    #restore_command = 'gunzip < /home/pgbasebackup_tgz/%f > %p'
    recovery_target_time = '2022-01-01 00:00:00 UTC'
    recovery_target_inclusive = false
    ```
- ~~Restart server~~

### [Streaming Replication](https://www.migops.com/blog/2021/03/31/setting-up-streaming-replication-in-postgresql-13-and-streaming-replication-internals/ "2021 @ Migops.com")

```bash
pg_basebackup \
    -h 192.169.12.1 -p 5432 -U replicator \
    -D /var/lib/pgsql/13/data -Fp -R -Xs -P
```
- `-Fp` : Plain copy of all sub-directories and their contents (datafiles, etc).
- `-R` : Configure replication specific settings automatically in the postgresql.auto.conf file. 
- `-Xs` : Using a separate channel/process, stream ongoing changes (WAL records) from master to standby, while the backup is in progress. 
- `-P` : Show the progress of the backup. 
- `-c` fast : This flag may be used to perform fast checkpoint and to avoid waiting until the lazy checkpoint is completed.


## [Continuous Archiving and Point-in-Time Recovery (PITR)](https://www.postgresql.org/docs/current/continuous-archiving.html)

PostgreSQL maintains a write ahead log (WAL) in the `/pg_wal/` subdirectory of the data directory; the database can be restored to consistency by _replaying_ the log entries made since the last checkpoint. 

A third strategy for backing up databases: combine a file-system-level backup with backup of the WAL files. If recovery is needed, we restore the file system backup and then replay from the backed-up WAL files to bring the system to a current state.

#### [Setting Up WAL Archiving](https://www.postgresql.org/docs/current/continuous-archiving.html#BACKUP-ARCHIVING-WAL)

A running PostgreSQL system produces an indefinitely long sequence of WAL records ... divides this into ___WAL segment files___ (`16MB` apiece);  given numeric names that reflect their position in the abstract WAL sequence. When not using WAL archiving, the system normally creates just a few segment files and then “recycles” them by renaming no-longer-needed segment files to higher segment numbers. 

When archiving WAL data, we need to capture the contents of each segment file ... before the segment file is recycled for reuse. 

... many different ways of “saving the data somewhere”: copy the segment files to an NFS-mounted directory on another machine, write them onto a tape drive, or batch them together and burn them onto CDs, ... 

PostgreSQL lets the administrator ___specify a shell command___ to be executed to copy a completed segment file to wherever it needs to go. The command could be as simple as a `cp`, or it could invoke a complex shell script — it's all up to you.

To enable WAL archiving, set the `wal_level` configuration parameter to replica or higher, `archive_mode` to `on`, and specify the shell command to use in the `archive_command` configuration parameter. In practice these settings will always be placed in the `postgresql.conf` file.  

##### [Write Ahead Log (WAL)](https://www.postgresql.org/docs/current/runtime-config-wal.html#RUNTIME-CONFIG-WAL-SETTINGS) params

- @ `postgresql.conf`
    ```conf
    wal_level = replica
    archive_mode = on

    # @ Unix
    archive_command = 'test ! -f /mnt/server/archivedir/%f && cp %p /mnt/server/archivedir/%f' 
    # @ Windows
    archive_command = 'copy "%p" "C:\\server\\archivedir\\%f"' 
    ```
    - `%p` is path of file to archive.
    - `%f` is file name only.

Example `archive_command` when run ...

```bash
test ! -f /mnt/server/archivedir/00000001000000A900000065 \
    && cp pg_wal/00000001000000A900000065 \
          /mnt/server/archivedir/00000001000000A900000065
```

>The speed of the archiving command is unimportant as long as it can keep up with the average rate at which your server generates WAL data. Normal operation continues even if the archiving process falls a little behind. If archiving falls significantly behind, this will increase the amount of data that would be lost in the event of a disaster. It will also mean that the `/pg_wal/` directory will contain large numbers of not-yet-archived segment files, which could eventually exceed available disk space.

Monitor the archiving process to ensure that it is working as you intend.

## [Replication](https://www.postgresql.org/docs/current/runtime-config-replication.html)

#### [Recovering Using a Continuous Archive Backup](https://www.postgresql.org/docs/current/continuous-archiving.html#BACKUP-PITR-RECOVERY)

```conf
restore_command = 'cp /mnt/server/archivedir/%f %p'
```

## [Log Shipping : Standby Servers](https://www.postgresql.org/docs/current/warm-standby.html)

&hellip; continuous archiving to create a high availability (HA) cluster configuration with one or more standby servers ready to take over operations if the primary server fails; __Warm Standby__ or log shipping. &hellip; asynchronous, i.e., the WAL records are shipped after transaction commit.

Primary and standby server work together, loosely coupled. Primary server operates in ___continuous archiving mode___. Standby servers operates in ___continuous recovery mode___, reading the WAL files from the primary.

Recovery performance is sufficiently good that the Warm Standby will typically be only moments away from full availability once it has been activated. 

[__Hot Standby__](https://www.postgresql.org/docs/current/hot-standby.html#HOT-STANDBY-PARAMETERS) server is a standby server that can also be used for read-only queries.

>_No changes to the database tables are required to enable this capability, so it offers low administration overhead compared to some other replication solutions. This configuration also has relatively low performance impact on the primary server._

### [Standby Server Operation](https://www.postgresql.org/docs/current/warm-standby.html#STANDBY-SERVER-OPERATION)

A PostgreSQL server enters __Standby Mode__ if a `standby.signal` file exists in its data directory when the server is started.

Standby servers continuously apply WAL received either directly from the master (streaming replication), or from a WAL archive (see [`restore_command`](https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-RESTORE-COMMAND)). 

#### `/pg_wal` 

___Shared archive directory___; must be available to all standby servers in the cluster; the standby servers attempt to restore any WAL files found therein. That typically happens after a server restart, when the standby replays WAL that was streamed from the master before the restart; can also manually copy files to `/pg_wal` at any time to have them replayed. 

This is a kind of backup bin for Streaming Replication; if the standby servers can't keep up, so the primary "recycles" WAL data before the standby servers process it from the stream, the data will  automatically be revovered (replayed) from WAL files in this directory.

#### The Loop

At startup, the standby begins by restoring all WAL available in the archive location, calling [`restore_command`](https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-RESTORE-COMMAND). Once it reaches the end of WAL available there and `restore_command` fails, it tries to restore any WAL available in the `pg_wal` directory. If that fails, and streaming replication has been configured, the standby tries to connect to the primary server and start streaming WAL from the last valid record found in archive or pg_wal. If that fails or streaming replication is not configured, or if the connection is later disconnected, the standby goes back to step 1 and tries to restore the file from the archive again. This loop of retries from the archive, `pg_wal`, and via streaming replication goes on until the server is stopped or failover is triggered by a trigger file.

- `pg_promote()` | `pg_ctl promote` | `promote_trigger_file`
    - Standby mode is exited and the server switches to normal operation when `pg_ctl promote` is run, `pg_promote()` is called, or a trigger file is found (`promote_trigger_file`). Before failover, any WAL immediately available in the archive or in `pg_wal` will be restored, but no attempt is made to connect to the master.

### [Prepare Master for Standby Servers](https://www.postgresql.org/docs/current/warm-standby.html#PREPARING-MASTER-FOR-STANDBY)

- Archive directory accessible from the standby; accessible even when the master is down.
- For streaming replication, set up authentication on the primary server 
    - Allow replication connections from the standby server(s); create a role and provide a suitable entry or entries in `pg_hba.conf` with the database field set to `replication`.
    - Set `max_wal_senders` @ primary to a sufficiently large value in the configuration file of the primary server. 
    - Set apropos `max_replication_slots` if slots used.
- Bootstrap with a [Base Backup](https://www.postgresql.org/docs/current/continuous-archiving.html#BACKUP-BASE-BACKUP)

### [Set Up a Standby Server](https://www.postgresql.org/docs/current/warm-standby.html#STANDBY-SERVER-SETUP)

- [Restore the base backup taken from primary server](https://www.postgresql.org/docs/current/continuous-archiving.html#BACKUP-PITR-RECOVERY). 
- Create `standby.signal` file in the standby's data directory. 
- Set `restore_command` to a simple command to copy files from the WAL archive. 
    - If you plan to have multiple standby servers for high availability purposes, make sure that `recovery_target_timeline` is _set to latest_(the default), to make the standby server follow the timeline change that occurs at failover to another standby.

Set up identical to primary (WAL archiving, connections and authentication) because the standby server will work as a primary server after failover.

If you're using a WAL archive, its size can be minimized using the 

#### `archive_cleanup_command` 

WAL archive parameter to remove files that are no longer required by the standby server. The `pg_archivecleanup` utility is designed specifically to be used with `archive_cleanup_command` in typical single-standby configurations, see `pg_archivecleanup`. Note however, that if you're using the archive for backup purposes, you need to retain files needed to recover from at least the latest base backup, even if they're no longer needed by the standby.

Example configuration (@ `postgresql.conf` ???):

```plaintext
primary_conninfo = 'host=192.168.1.50 port=5432 user=foo password=foopass options=''-c wal_sender_timeout=5000'''
restore_command = 'cp /path/to/archive/%f %p'
archive_cleanup_command = 'pg_archivecleanup /path/to/archive %r'
```

For streaming replication set `max_wal_senders` high enough in the primary to allow them to be connected simultaneously.

## [Streaming Replication](https://www.postgresql.org/docs/current/warm-standby.html#STREAMING-REPLICATION "postgresql.org/docs/current")

The step that turns a file-based log-shipping standby into streaming replication standby is setting the `primary_conninfo` setting to point to the primary server. Set `listen_addresses` and authentication options (see [`pg_hba.conf`](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html)) on the primary so that the standby server can connect.

&hellip; allows a standby server to stay more up-to-date than is possible with file-based log shipping;  ___the primary streams WAL records to the standby as they're generated___; asynchronous by default; a small delay between committing a transaction in the primary and the changes becoming visible in the standby; the delay is much smaller than with file-based log shipping, ___typically under one second___ assuming the standby is powerful enough to keep up with the load. With streaming replication, `archive_timeout` is not required to reduce the data loss window.

Use in conjunction with file-based continuous archiving;  set up a WAL archive that's accessible from the standby, else ...

>If you use streaming replication without file-based continuous archiving, the server might recycle old WAL segments before the standby has received them. If this occurs, the standby will need to be reinitialized from a new base backup. You can avoid this by setting `wal_keep_size` to a value large enough to ensure that WAL segments are not recycled too early, or by configuring a replication slot for the standby. If you set up a WAL archive that's accessible from the standby, these solutions are not required, since the standby can always use the archive to catch up provided it retains enough segments.

On systems that support the keepalive socket option, setting `tcp_keepalives_idle`, `tcp_keepalives_interval` and `tcp_keepalives_count` helps the primary promptly notice a broken connection.

Set the maximum number of concurrent connections from the standby servers (see `max_wal_senders` for details).

When the standby is started and `primary_conninfo` is set correctly, the standby will connect to the primary after replaying all WAL files available in the archive. If the connection is established successfully, you will see a `walreceiver` in the standby, and a corresponding `walsender` process in the primary.

## Parameters 

- `archive_timeout` &hellip; limits size of the data loss window in file-based log shipping &hellip; can be set as low as a few seconds. However such a low setting will substantially increase the bandwidth required for file shipping. Streaming replication allows a much smaller window of data loss.

### Hot Standby params

- @ Primary 
    - `wal_level`
    - `vacuum_defer_cleanup_age` 
- @ Standby
    - `hot_standby`
    - `max_standby_archive_delay`
    - `max_standby_streaming_delay`

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
