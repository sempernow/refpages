# [PostgreSQL](https://www.postgresql.org/docs/10/index.html "postgresql.org/docs") | [Features](https://www.youtube.com/watch?v=KK0YPraAYTo "'PostgreSQL Top Ten Features' @ YouTube 2016") | [@ Docker](https://hub.docker.com/_/postgres "hub.docker.com :: postgres") | [Wiki](https://wiki.postgresql.org/wiki/Main_Page "PostgreSQL Wiki") |  [Wikipedia](https://en.wikipedia.org/wiki/PostgreSQL)

- Distributed, ACID-compliant, transactional RDBMS,   
using Multiversion concurrency control (MVCC)
- Highly Extensible
- Materialized Views (Updatable)
- Triggers
- Foreign keys
- Functions & Stored Procedures; embed other languages  

## [PostgreSQL Server Parameters](https://postgresqlco.nf/doc/en/param/ "@ postgresqlco.nf") | [Tuning Guide](https://postgresqlco.nf/tuning-guide)

Searchable listing and descriptions of all PostgreSQL server parameters, and tuning guide too!

## `psql` session

```bash
$ psql
```
```sql
psql (12.7)
postgres=# \q
```
```bash
$ createuser -P -e user1
$ psql -c "CREATE DATABASE foo"
$ psql -U user1 -d foo
```
```sql
psql (12.7)
foo=> \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 user1     |                                                            | {}
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
foo=> \q
```

## [PostgreSQL 12+ @ Docker](https://hub.docker.com/_/postgres "hub.docker.com :: postgres")

- Alpine (`postgres:12.7-alpine`; `160MB`)
    - `~` (home)
        - @ `/var/lib/postgresql`
    - `$PGDATA` (cluster data directory)
        - @ `/var/lib/postgresql/data`
- DNS vs (ephemeral) IP address
    - `listen_addresses=foo` fails
    - `listen_addresses=foo.bar` resolves
        - declare `hostname: foo.bar` (@ YAML)
- Initialization (first run) : `initdb`  
    - Either `POSTGRES_PASSWORD` or `POSTGRES_PASSWORD_FILE` must be set, else aborts.
    - Can set `POSTGRES_USER` to any name, but the ___user must exist___ @ container's `/etc/passwd`, else `initdb` fails. The official `postgres` image has and can run as `postgres:postgres` (`70:70`).
    - No mounts to `$PGDATA` (on first run, else `initdb` does nothing); directory must be empty (and sans mounts).
        ```yaml
            user: "postgres"
            command: ["postgres", "-c", "config_file=/mnt/host/postgresql.conf", "-c", "..."] 
        ```
        @ map syntax
        ```yaml
            user: "postgres"
            command:
                - "postgres"
                - "-c"
                - "config_file=/mnt/host/postgresql.conf"
                - "-c"
                - "shared_buffers=3GB"
                - "-c"
                - "listen_addresses=*"
        ```
- To run as current (OS) user (accepted by `initdb` as legitimate)
    ```bash
    docker run -it --rm --user "$(id -u):$(id -g)" \
        -v /etc/passwd:/etc/passwd:ro \
        -e POSTGRES_PASSWORD=$users_pw \
        $PG_IMAGE
    ```
    - So can fake a `passwd` file and therefore user?


## [@ AWS RDS](https://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html) :: [Managed RDBMS Engine per AMI Instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts)

```bash
# Versions list
aws rds describe-db-engine-versions \
    --engine 'postgres' \
    | jq -r '.DBEngineVersions[].EngineVersion'
```
- `9.5.2, ..., 9.6.8-20, 10.9-15, ..., 11.4-10, ..., 12.2-5` (2021-02-10)

## Architecture 

PostgreSQL uses a client/server model; a session consists of __cooperating processes__:

- Server process (`postgres`); manages the database files, accepts connections from client applications, and performs database actions on behalf of the clients. (Unix domain socket `/tmp/.s.PGSQL.5432`)

- Client (frontend) process; application requesting database operations; can be a CLI, GUI, web server, or a specialized database maintenance tool. [PostgreSQL _native client apps_](https://www.postgresql.org/docs/current/reference-client.html) include `psql`, `createdb`, `dropdb`, `pg_dump`, `pg_restore`; many tools are developed by the community.  

    - Some native client tools fail if their __version does not match__ that of the server.

- Client and the server may be on different hosts, communicating over a TCP/IP network connection. If so, files accessible by client machine might not be accessible on the database server machine, or may be accessible, but only by a different file name.

- PostgreSQL server handles multiple concurrent connections from clients by starting (forking) a new process for each connection, so the master server process is always running, waiting for client connections; whereas client and associated server processes come and go. 

## [Data Definition Language](https://www.postgresql.org/docs/12/ddl.html) (DDL)

## Data Types [@ PostgreSQL](https://www.postgresql.org/docs/current/datatype.html "postgresql.org") | [@ SQL (Reference)](https://www.w3schools.com/sql/sql_datatypes.asp "Canonical SQL @ w3schools.com") | [Extensible types](https://www.postgresql.org/docs/current/typeconv-overview.html)

### [System Info Functions](https://www.postgresql.org/docs/current/functions-info.html)

- `pg_typeof((SELECT foo FROM bar where colx = 'unique'))` &mdash; data type
- `current_database()`
- `current_schema()`
- `current_user()`
- `version()`
- `pg_get_keywords()` &mdash; list of all keywords and their restrictions 

#### Pairing types across app boundaries

|PostgreSQL|Golang|Javascript|
|----|---|---|
|`BIGINT`|`int`|`integer`|
|`UUID`|`string`|`string`|
|`NUMERIC(5,2)`|???|???|
|`TIMESTAMPTZ`|`time.Time`|`string`|

- @ Golang, currency may be `float32` or [`currency.Unit{USD}`](https://godoc.org/golang.org/x/text/currency#Unit "godoc.org")

```bash
☩ curl -s -X GET localhost:3000/books/create | jq .
{
  "id": "41c27323-09f7-4056-8579-a90cf260febf",
  "title": "Foo bar",
  "price": 44.22,
  "timeDb": "2020-06-25T16:01:38.19155Z",
  "timeGo": "2020-06-25T16:01:38.188344Z"
}
```
- Note difference in accuracy; PostgreSQL is only to 10's of `ms`, whereas Golang, `time.Now()`, is accurate to the `ms`.

## Comments

Mind the syntax; always only one `--` per line, and always follow by at least one whitespace before adding text.

```sql
-- okay
SELECT foo, bar FROM a -- okay
-- okay
--bad
---bad
-- bad -- bad
WHERE bar = 22;    -- okay
```
- The bad don't always cause problems, but do under certain conditions.
- Some wrappers are even more finicky.
    - E.g., no trailing comments (per file) at Adminer when loading by file (`Import`).

## Types 

- Date/Time [Types](https://www.postgresql.org/docs/current/datatype-datetime.html "postgresql.org") | [Functions and Operators](https://www.postgresql.org/docs/current/functions-datetime.html)
    - [Use __`timestamptz`__](https://wiki.postgresql.org/wiki/Don%27t_Do_This#Date.2FTime_storage), not `timestamp`. 
        ```sql
        CREATE TABLE foo tz TIMESTAMP WITH TIME ZONE;
        -- or, using its PostgreSQL alias, ...
        CREATE TABLE foo tz TIMESTAMPTZ;
        ```  
    - Behavior: [SQL spec vs PostgreSQL](https://wiki.postgresql.org/wiki/PostgreSQL_vs_SQL_Standard#TIMESTAMP_WITH_TIME_ZONE "wiki.postgresql.org")
    - `timestamptz` stores an integer; microseconds since January 1st, 2000 in UTC, and _auto-handles time zone conversions_, mapping to server-session timezone on query; access using `at time zone`. (`timestamp` does none of that; stores data and time, and will cause problems.)

        ```sql
        CREATE TABLE t1 (
            tstamp  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            date    BIGINT DEFAULT now_unix()
        )
        -- timestamptz to bigint Unix milliseconds 
        -- to match Golang time.Time @ millisecond: (time.Now().UnixNano() / 1e6)
        SELECT date,(extract(epoch FROM tstamp)*1000)::BIGINT as tstamp FROM t1;
        ```
        ```plaintext
                 date      |    tstamp
            ---------------+---------------
             1593996756642 | 1593996756642
        ```
        ```sql 
        -- RFC3339 : 2022-01-06T14:49:45Z
        SELECT to_char(date_trunc('seconds', now()), 'YYYY-MM-DD"T"HH24:MI:SS"Z"');

        -- ADD year, month, day, hour, minute, second
        SELECT NOW();
        -- 2020-08-04 16:45:02.457971+00
        SELECT NOW() + INTERVAL '5 minute';
        -- 2020-08-04 16:50:06.368969+00
        SELECT NOW() + INTERVAL '1 hour';
        -- 2020-08-04 17:45:16.205172+00

        -- Get SERVER timezone
        SELECT current_setting('TIMEZONE');
        -- Set SERVER timezone
        SET timezone = 'EST';

        -- Use type casting (has a RUNTIME COST)
        SELECT NOW()::timestamptz AT TIME ZONE 'Europe/Rome' as "Rome's timestamp";

        --       Rome's timestamp
        -- ----------------------------
        --  2020-06-16 15:11:45.649728

        -- From Timestamp to Epoch (digits) ...
        -- FIX flakey-varying per scan issue 
        -- Use date_trunc() to SET ACCURACY, ELSE number of decimals VACILLATE. 
        SELECT extract(epoch FROM date_trunc('milliseconds', NOW())); -- seconds
        -- 1594417154.250
        SELECT (extract(epoch FROM date_trunc('milliseconds', now()))*1000);
        -- 1594417154250  (13 digits vs <10>.<3>)

        SELECT (extract(epoch FROM NOW())*1000)::bigint; -- ms
        -- 1594417197766
        SELECT extract(epoch FROM timestamptz '2015-07-20 01:00+02');
        -- 1437346800
        SELECT extract(epoch FROM t1.date_create)::NUMERIC(15,0) FROM t1;
        -- 1593867279

        -- From Epoch (digits) to TimestampTZ 
        SELECT to_timestamp(1437346800)::timestamptz;
        -- 2015-07-19 23:00:00+00
        SELECT to_timestamp(1437346800)::timestamptz AT TIME ZONE 'Europe/Rome';
        -- 2015-07-20 01:00:00

        -- From Epoch (digits) to Timestamp 
        SELECT to_timestamp( 1437346800);
        --  2015-07-19 23:00:00+00 
        ```  
        - Set accuracy per [`date_trunc('milliseconds', Now())`](https://www.postgresql.org/docs/9.6/functions-datetime.html)

        To ensure the literal is treated as `timezonetz`, use &hellip;
        ```sql 
        TIMESTAMP WITH TIME ZONE '2015-07-20 01:00+02'
        ```
        - [Usage/Helpers](https://www.postgresqltutorial.com/postgresql-timestamp/) 
            ```sql
            -- Change server timezone
            SET timezone = 'America/New_York';
            -- Get timezone 
            SHOW TIMEZONE;
            -- Get timestamp; specify timezone
            SELECT timezone('America/New_York','2016-06-01 00:00');
            -- Same but "better"
            SELECT timezone('America/New_York','2015-07-19 23:00'::timestamptz);
            -- 2015-07-19 19:00:00
            SELECT timezone('America/New_York',(SELECT to_timestamp(1437346800))::timestamptz);
            -- 2015-07-19 19:00:00
            -- Set FORMAT (Precision, etc)
            SELECT to_char((SELECT to_timestamp(1437346800)::timestamptz), 'YYYY-MM-DD HH:MI:SS.US TZ');
            -- 2015-07-19 11:00:00.000000 UTC
            SELECT to_char('2015-07-19 11:00:00.000000'::timestamptz, 'YYYY-MM-DD HH:MI:SS.US TZ');
            -- 2015-07-19 11:00:00.000000 UTC
            ```
    - List of ___Timezone Names___; output to a CSV file.
    ```sql 
    COPY (
        SELECT * from pg_timezone_names
    ) to '/home/timezones.csv' WITH CSV HEADER; 
    ```
    - To truncate, [use __`date_trunc('second', blah)`__](https://wiki.postgresql.org/wiki/Don't_Do_This#Don.27t_use_timestamp.280.29_or_timestamptz.280.29)
        - Not `timestamp(0)`, and not `timestamptz(0)`; they _round off_, not truncate.
- [Numeric](https://www.postgresql.org/docs/current/datatype-numeric.html)
    - `SMALLINT`, `INTEGER`, `BIGINT`, `DECIMAL`, `NUMERIC`, `REAL`, `DOUBLE PRECISION`, `SMALL SERIAL`, `SERIAL`, `BIGSERIAL`.
    - [NUMERIC](https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-NUMERIC-DECIMAL)<a name="serial"></a>; ___arbitrary precision___ numbers.
    ```sql
    -- precision is total number of digits; scale is that following the decimal point.
    NUMERIC(precision [, scale])
    -- Money; up to 9.99 Billion
    NUMERIC(12,2)
    ```
    - [Monetary](https://www.postgresql.org/docs/current/datatype-money.html)   
        - [Use __`NUMERIC`__](https://wiki.postgresql.org/wiki/Don't_Do_This#Don.27t_use_money) (above), not `MONEY`, else suffer round-off and other issues.   
- [TEXT/CHARACTER](https://www.postgresql.org/docs/current/datatype-character.html); handles ___up to `1 GB`___ per; optimizes per length; auto compress/decompress (internally and transparently), and only when apropos.
    - [Use __`text`__ or __`varchar`__](https://wiki.postgresql.org/wiki/Don't_Do_This#Text_storage), __sans limit__ (__`n`__); neither `char(n)` nor  `varchar(n)`. Else suffer padding (to `n`) issues mucking with SQL logic.
        - ___To limit length___, use a [Check Constraint](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-CHECK-CONSTRAINTS "ddl-constraints @ PostgreSQL.org") instead.
            ```sql
            -- Name it to clarify the error message(s).
            foo TEXT CONSTRAINT max_foo CHECK (LENGTH(foo) <= 512)
            ```
- [UUID](https://www.postgresql.org/docs/current/datatype-uuid.html) 
    - Useful for Primary Key
- [Serial](https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-SERIAL)<a name="serial"></a>
    - Useful, but ___depricated___, for Primary Key; not standard SQL; not true types (serial, bigserial), but merely a notational convenience for creating unique identifier columns. (See [Primary Keys](#primary-keys "below").)
- [Enumerated](https://www.postgresql.org/docs/current/datatype-enum.html "postgresql.org") 
- [Network Address](https://www.postgresql.org/docs/current/datatype-net-types.html "postgresql.org") 
- [JSON](https://www.postgresql.org/docs/current/datatype-json.html "postgresql.org") (`json`|`jsonb`) | [GIN Indexes](https://www.postgresql.org/docs/current/gin.html) | [JSON Functions and Operators](https://www.postgresql.org/docs/current/functions-json.html "postgresql.org")  
    - __`jsonb`__ is the efficient, key-searchable, binary format; slower to input, but __significantly faster to process__; [supports (GIN) indexing](https://www.postgresql.org/docs/current/datatype-json.html#JSON-INDEXING "jsonb indexing").  
    - Store as JSON (document/_denormalized_) data type in cases where   
storing otherwise would require lots of `JOIN` ops. And do so in `jsonb` format, unless processing it as an atomic blob, with insert/retrieve only, sans key/val searches.
- [Arrays](https://www.postgresql.org/docs/current/arrays.html "postgresql.org") 
```sql
CREATE TABLE sal_emp (
    uname       text,
    pay_by_qtr  integer[],
    sch         text[][],
    foo         integer[3][3]
);

INSERT INTO sal_emp (uname, pay_by_qtr, sch)
    VALUES (
        'Bill',                                     -- uname
        '{10000, 10000, 10000, 10000}',             -- pay_by_qtr
        '{{"meeting", "lunch"}, {"presentation"}}'   -- sch
    );
```

## [SQL](https://www.w3schools.com/sql/default.asp "tutorial @ www.w3schools.com") | [Commands](https://www.postgresql.org/docs/11/sql-commands.html "sql-commands [list] @ postresql.org") | [Language](https://www.postgresql.org/docs/current/sql.html "sql @ postgresql.org") | [Tutorial](https://www.postgresql.org/docs/current/tutorial-sql.html "tutorial-sql @ postgresql.org")

### [SQL Keywords](https://www.postgresql.org/docs/current/sql-keywords-appendix.html) 

Both "reserved" + "non-reserved" ___words to avoid___ as identifiers. E.g., `id`, `name`, `names`, `new`, `nil`, `none`, `null`, `nulls`, `path`, `per`, `ref`, `row`, &hellip;, `uri`, `user`, `value`, `view`, `views`

### Admin :: `CREATE`/`DROP` Database / User `GRANT ... PRIVILEGES` 

```sql
-- drop (remove, delete) db
DROP DATABASE 'db_foo';
-- create a db
CREATE DATABASE 'db_foo';
-- create user
CREATE USER 'userof_foo' WITH PASSWORD 'pass_of_userof_foo';
-- grant privileges
GRANT ALL PRIVILEGES ON DATABASE 'db_foo' to 'userof_foo';
-- revoke privileges
REVOKE ALL PRIVILEGES ON DATABASE company from james;

-- alter
ALTER USER james WITH SUPERUSER;
ALTER USER james WITH NOSUPERUSER;
-- remove
DROP USER james;

-- server version
SELECT version();

-- connect to db
\c db_foo
-- list dbs
\l 
-- see current user
SELECT current_user;
-- see current database
SELECT current_database();
```
-  @ Client (`psql`) session

### Benchmark :: [`EXPLAIN [ANALYZE, ...]`](https://www.postgresql.org/docs/current/sql-explain.html)

```sql
EXPLAIN ANALYZE 
    SELECT b.*
    FROM books b 
    WHERE price < 8
    ORDER BY b.title ASC;
```

```sql
                                                 QUERY PLAN
------------------------------------------------------------------------------------------------------------
 Sort  (cost=25.14..25.64 rows=200 width=108) (actual time=0.017..0.017 rows=2 loops=1)
   Sort Key: title
   Sort Method: quicksort  Memory: 25kB
   ->  Seq Scan on books b  (cost=0.00..17.50 rows=200 width=108) (actual time=0.008..0.010 rows=2 loops=1)
         Filter: (price < '8'::numeric)
         Rows Removed by Filter: 1
 Planning Time: 0.056 ms
 Execution Time: 0.029 ms
(8 rows)
```

### [Create Schema](https://www.postgresql.org/docs/11/ddl-schemas.html) 

- A database contains one or more named schemas, which in turn contain tables. Schemas also contain other kinds of named objects, including data types, functions, and operators.   
The same object name can be used in different schemas without conflict. Unlike databases, schemas are not rigidly separated.  __Uses__:  
- To allow many users to use one database without interfering with each other.
- To organize database objects into logical groups to make them more manageable.
- Third-party applications can be put into separate schemas so they do not collide with the names of other objects.

    ```sql
    CREATE SCHEMA foo_schema AUTHORIZATION some_user;
    CREATE TABLE foo_schema.some_table (
     ...
    );
    ```

#### [Schema : Best Practices](https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PATTERNS "@ postgresql.org") 

Add/set schema name to user's name. Also run certain `REVOKE` commands so that any current user's default schema is their user name (instead of default being `public`).

```sql
-- Create schema
CREATE SCHEMA IF NOT EXISTS uzr1;
--SET search_path TO uzr1, public;
ALTER SCHEMA uzr1 OWNER TO CURRENT_USER;

-- Revoke CREATE permission on public schema from PUBLIC role 
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
-- Revoke PUBLIC role’s ability to connect to database
REVOKE ALL ON DATABASE db1 FROM PUBLIC;
```
- Thereby, qualified names are `username.tablename`, yet `tablename` resolves to that per default search path.
    - "_Constrain ordinary users to user-private schemas. To implement this, issue `REVOKE CREATE ON SCHEMA public FROM PUBLIC`, and create a schema for each user with the same name as that user. Recall that the default search path starts with `$user`, which resolves to the user name. Therefore, if each user has a separate schema, they access their own schemas by default._"
- Schema; post changeover
    ```sql
    db1=# \dt
                List of relations
    Schema |       Name        | Type  | Owner
    --------+-------------------+-------+-------
    public | darwin_migrations | table | uzr1
    uzr1   | channels          | table | uzr1
    uzr1   | groups            | table | uzr1
    uzr1   | messages          | table | uzr1
    uzr1   | subscriptions     | table | uzr1
    uzr1   | transactions      | table | uzr1
    uzr1   | users             | table | uzr1
    uzr1   | views             | table | uzr1
    ```

## [Data Manipulation](https://www.postgresql.org/docs/current/dml.html "postgresql.org") (CRUD)  

- [Don't use `NOT IN`](https://wiki.postgresql.org/wiki/Don't_Do_This#SQL_constructs). [Don't use `BETWEEN`](https://wiki.postgresql.org/wiki/Don't_Do_This#Don.27t_use_BETWEEN_.28especially_with_timestamps.29).  
- [Don't use `SQL_ASCII` encoding](https://wiki.postgresql.org/wiki/Don't_Do_This#Don.27t_use_SQL_ASCII).  
- [Don't use _upper-case_ table names](https://wiki.postgresql.org/wiki/Don't_Do_This#Don.27t_use_upper_case_table_or_column_names).  


### [Create Table](https://www.postgresql.org/docs/11/sql-createtable.html)

- @ __Table &amp; Column Names__; [always use lowercase](https://wiki.postgresql.org/wiki/Don't_Do_This#Don.27t_use_upper_case_table_or_column_names "ALWAYS use lower-case @ PostgreSQL"), because such names are ___folded to lower-case___, regardless, by PostgreSQL; though that is not compliant with the standard SQL spec. 
    - Table `foos` or `foos_bars`, for example. 
- Auto-incrementing, e.g., a primary-key (`id`)  
    - Canonical SQL  
        ```sql 
        CREATE TABLE foos (
            id integer NOT NULL AUTO_INCREMENT
        );
        ```
- __Primary Key__ (PK) <a name="primary-keys"></a> &mdash; "`PRIMARY KEY`" and"`NOT NULL UNIQUE`" are ___equivalent___; want to guarantee unique; if use integer _sequence_, `bigint` (per `IDENTITY`; see below), then debugging is easier, but scaling &mdash;sharding a distributed database/table &mdash;has issues; if use `uuid` (_random_), then scales well (shards), but debugging can be hell lest some (indexed) table column exists that reckons the (logical, time, or whatever) _sequence_ of its data. Also, for both security and decoupling, don't expose any PK to any client. __Affect on performance__: The index update on INSERT or UPDATE (any write) takes time, so inserting into a UNIQUE indexed table is _slower_ than inserting into one without any unique index or primary key.

    >A solution to the security issue is to use two indexed keys; the sequential key, as PK, and a second "external" (client-side) __globally-unique__ ID, e.g., `uuid`. Also see [Sequential UUID generator](https://github.com/tvondra/sequential-uuids "PostgreSQL extension by Tomas Vondra 2019 @ GitHub"), which is similar to <def title="Comcombined-time GUID">COMB</def>.

    - Summary:
    ```sql
        CREATE EXTENSION IF NOT EXISTS "pgcrypto";                  -- for UUID v4 generator 
        CREATE TABLE IF NOT EXISTS messages (
            id  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,    -- surrogate key (internal)
            msg_id UUID DEFAULT gen_random_uuid(),                  -- natural key  (external)
            ...
        );
        CREATE INDEX IF NOT EXISTS msg_id_idx ON messages (msg_id); -- fast query on msg_id key.

        SELECT left(msg_id::text, 8) FROM messages; -- to truncated string
    ```
    - If primary key: `id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),` 

    - Details:
   
    - PK per [Identity](http://www.postgresqltutorial.com/postgresql-identity-column/); an auto-incrementing numerical type; not globally unique (locally unique), but the PK is fast and ___sortable___.  
    `... GENERATED [ALWAYS|BY DEFAULT] AS IDENTITY [PRIMARY KEY]`   
        - Create
        ```sql
        CREATE TABLE users (
            idx BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
            email TEXT NOT NULL
        );
        ```
        - Insert and query  
            ```sql
            INSERT INTO users (name) 
            VALUES ('abc'), ('xyz');
            SELECT * FROM users;
            ```
                idx     |    name 
                -------------------
                1      |     abc
                2      |     xyz
    - PK per [Serial](#serial "@ Data Types, above"); non-standard SQL; depricated; use Identity method (above) instead.
        ```sql
        CREATE TABLE tblname (
            colname SERIAL
        );
        -- equivalent (standard SQL) ...
        CREATE SEQUENCE tblname_colname_seq AS integer;
        CREATE TABLE tblname (
            colname INTEGER NOT NULL DEFAULT nextval('tblname_colname_seq')
        );
        ALTER SEQUENCE tblname_colname_seq OWNED BY tblname.colname;
        ```
        Then
        ```sql
        ALTER TABLE tblename ADD PRIMARY KEY (colname);
        ```
    - PK per [UUID](https://www.postgresql.org/docs/current/uuid-ossp.html); [use `v4`](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_%28random%29 "Wikipedia"); universally unique; random; fast query (is it's own data type in PostgreSQL), but is ___not sortable___; can generate internally per extention.  
        - per [`pgcrypto`](https://www.postgresql.org/docs/current/pgcrypto.html) extension; [`gen_random_uuid()`](https://www.postgresql.org/docs/current/pgcrypto.html#id-1.11.7.34.9) &mdash; Generates v4 UUID; the extension/method [_suggested at PostgreSQL docs_](https://www.postgresql.org/docs/current/uuid-ossp.html#id-1.11.7.53.6) if only generating v4 (random) UUIDs, else use `uuid-ossp` extension (below).
            ```sql
            -- Load extension
            CREATE EXTENSION IF NOT EXISTS "pgcrypto";
            -- Create PK
            CREATE TABLE users (
               id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            );
            ```
        - per [`uuid-ossp`](https://www.postgresql.org/docs/current/uuid-ossp.html) extension; [`uuid_generate_v4()`](https://www.postgresql.org/docs/current/uuid-ossp.html#id-1.11.7.53.4) &mdash; Generates v4 UUID.
            ```sql
            -- Load extension
            CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
            -- Create PK
            CREATE TABLE users (
               id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
            );
            ```
    - PK per [Sequential UUID](https://github.com/tvondra/sequential-uuids "PostgreSQL extension by Tomas Vondra 2019 @ GitHub")
        - Similar to <def title="Comcombined-time GUID">COMB</def>, it combines a locally-unique sequence (either timestamp or serial index) with a globally-unique UUID. _Available as_ ___PostgreSQL___ ( `v10+`) ___extension___ .
    - PK per [ULID](https://github.com/oklog/ulid "'Universally Unique Lexicographically-Sortable Identifier' @ Golang @ GitHub"); 26 chars (base32); lexicographically sortable (unlike `mattersmost/NewID`); _"compatible with UUID/GUIDs"_, but ___not___ with PostgreSQL type `UUID`. Also, unlike `UUID`, must generate externally, @ (Golang) application.
    - PK per [KSUID](https://github.com/segmentio/ksuid "K-Sortable Unique IDentifier @ Golang 2017 @ GitHub"); "roughly" sortable by time of creation. Generate externally, @ (Golang) application.
- [__Constraints__](https://www.postgresql.org/docs/current/ddl-constraints.html "ddl-constraints @ postgresql.org") (___Referential Integrity___) &mdash; Used to limit the type of data that can go into a table; action abored on fail; ensures the accuracy and reliability of the data in the table. [Common constraints](https://www.w3schools.com/sql/sql_constraints.asp "w3schools.com/sql"):  

        NOT NULL    - Ensure column cannot have a NULL value.  
        UNIQUE      - Ensure all values in a column are different.  
        PRIMARY KEY - Uniquely identifies each row/record in a table;  
                      Combination of NOT NULL and UNIQUE.  
        FOREIGN KEY - Uniquely identifies a row/record in another table.  
        CHECK       - Ensure all values in a column satisfy a specific condition.   
        DEFAULT     - Sets a default value for a column when no value is specified.  
        INDEX       - Used to create and retrieve data from the database very quickly.  

    ```sql 
    -- add constraint 
    ALTER TABLE subscriptions ALTER COLUMN usr_id SET NOT NULL;
    -- remove constraint 
    ALTER TABLE subscriptions ALTER COLUMN usr_id DROP NOT NULL;
    ```
    - Some constraints require a _declared constraint name_ to enable any subsequent removal; 
        - E.g., `ADD CONSTRAINT order_id_fk FOREIGN KEY (order_id) ...`

    - [`CHECK` (The inserted data must satisfy a boolean.)](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-CHECK-CONSTRAINTS)
        ```sql
        CREATE TABLE products (
            product_no integer,
            name text,
            price numeric CHECK (price > 0)
        );
        ```
        - Optionally name, and may apply to multiple columns.  
            ```sql 
            price numeric CHECK (price > 0),
            discounted_price numeric CHECK (discounted_price > 0),
            CHECK (price > discounted_price)
            ```
    - [Foreign Keys](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-FK "ddl-constraints @ postgresql.org") (current; ver `11.2`.)  
        - __Referencial Integrity__, e.g., forbid entries in one table if no matching entries exist in another table.  
            ```sql
            -- refererenced table
            CREATE TABLE products (
                product_no integer PRIMARY KEY,
                ...
            );
            -- referencing table
            CREATE TABLE orders (
                ...
                product_no integer RENCES products,  
                ...
            );
            ```
            - Prohibits creation of an `orders` entry, unless its `product_no` exists in the `products` table. (The `product_no` is a __foreign key__  in `orders` table.)
        - Constrain __a group of columns__:
            ```sql
            CREATE TABLE t1 (
                ...
                b integer,
                c integer,
                FOREIGN KEY (b, c) RENCES other_table (c1, c2)
            );
            ```
#### Summary 

```sql
-- M:M @ products:orders

CREATE TABLE products (
    product_id BIGINT PRIMARY KEY,
    product_name TEXT,
    price NUMERIC 
);

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    shipping_address TEXT
);

-- resolve (w/ constraints) with junction table
CREATE TABLE products_orders (
    product_id BIGINT RENCES products ON DELETE RESTRICT,   -- =>
    order_id BIGINT RENCES orders ON DELETE CASCADE,        -- <=
    PRIMARY KEY (product_id, order_id)
);
```

#### Better, two-step method; 

1. Create table(s)
1. Add constraints (Referential Integrity)

```sql
-- 1.) Create table
CREATE TABLE products_orders (
    product_id BIGINT,
    order_id BIGINT
);

-- 2.) Add Constraints (Referential Integrity)
--     Naming each CONSTRAINT allows for subsequent DROP CONSTRAINT <name>;

ALTER TABLE products_orders
    ADD CONSTRAINT product_id_fk 
        FOREIGN KEY (product_id) RENCES products(product_id) ON DELETE RESTRICT;

ALTER TABLE products_orders
    ADD CONSTRAINT order_id_fk  
        FOREIGN KEY (order_id) RENCES orders(order_id) ON DELETE CASCADE;

ALTER TABLE products_orders
    ADD CONSTRAINT products_orders_pk PRIMARY KEY (product_id, order_id);
```
- Always use ___lower case___ for all ___names___, everywhere.

- [Inheritance](https://www.postgresql.org/docs/current/tutorial-inheritance.html)  
   - [Don't use table inheritance.](https://wiki.postgresql.org/wiki/Don't_Do_This#Don.27t_use_table_inheritance) Use foreign keys instead.   
- [Modifying Tables](https://www.postgresql.org/docs/current/ddl-alter.html#id-1.5.4.7.9 "ddl-alter @ postgresql.org") (`ALTER TABLE`)  &mdash; To `ADD`, `DROP` (delete), or `MODIFY` __columns__ in an existing table; `ADD` or `DROP` various __constraints__ on an existing table; `REANAME` a table.  
    ```sql 
    ALTER TABLE products ALTER COLUMN price TYPE numeric(10,2);
    ```

### `SELECT ... CASE ... LIMIT`

```sql
...
SELECT *
FROM "vw_messages"
...
ORDER BY 
    CASE WHEN n  > 0 THEN date_create END DESC, -- @ older
    CASE WHEN n <= 0 THEN date_create END ASC   -- @ newer
LIMIT CASE WHEN n > 0 THEN n ELSE -n END;
```
- Sorts ___once___ by whichever `CASE` is `true` .

###  [Insertions](https://www.postgresql.org/docs/current/tutorial-populate.html) [(`INSERT`)](https://www.postgresql.org/docs/current/sql-insert.html) &ndash; Populate a table with values, per table row.

#### `INSERT ... VALUES (..)`

```sql
-- Insert a row whereof all columns are set to default values
INSERT INTO products DEFAULT VALUES;
-- Insert a row per data set of declared values; columns IMPLIED
INSERT INTO products VALUES (1, 'Cheese', 9.99);
-- Insert a row per data set of declared values; columns EXPLICITLY declared
INSERT INTO products (name, price, product_no) VALUES ('Cheese', 9.99, 1);
-- Insert SEVERAL ROWS, per explicitly declared columns
INSERT INTO products (product_no, name, price) VALUES
    (1, 'Cheese', 9.99),
    (2, 'Bread', 1.99),
    (3, 'Milk', 2.99);
```

#### `INSERT ... SELECT ...`

Populate one table (`table2`) with ___values from another table___ (`table1`), column per column.

```sql
INSERT INTO table2 (column1, column2, column3, ...)
    SELECT column1, column2, column3, ...
    FROM table1
    WHERE condition; 
```

Static test

```sql
INSERT INTO messages (
    to_id, to_handle, chn_id, body, author_id)
SELECT 'toMsgID', 'toAuthorHandle', 'chnID', 'the body', 'authorID'
WHERE CASE
    WHEN 
        'toMsgID' = ''
    THEN 
        'chnID' IN ( SELECT c.chn_id FROM vw_channels c WHERE c.owner_id = 'authorID' )
    ELSE 
        true
    END
LIMIT 1
```
- Replace string literals with parameters suiting the driver; @ Golang: `$1`, `$2`, &hellip;

More examples &hellip;

```sql
-- Insert into tbl_1 values from tbl_2 plus literal(s)
INSERT INTO tbl_1 (
    xid, scope, key_name, key_hash
) -- user_id is field of tbl_2; all else are literals. 
SELECT user_id, xis_user_enum(), 'rand26.rand60', pw_hash('rand26.rand60')
FROM tbl_2
WHERE roles @> ARRAY['HOST']
AND (email LIKE '%@emx.unk')
-- Insert conditionally, including such at other tables (Golang sqlx syntax)
INSERT INTO messages (
    msg_id, to_id, to_display, to_handle, chn_id, 
    author_id, author_display, author_handle, author_avatar, author_badges, 
    title, summary, body, form, privacy, date_create, date_update, sponsub)
SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18
WHERE CASE -- <<< Insert(s) occur only where CASE evalutes to true, per EXISTS(..).
    WHEN -- new (not reply) message.
        ( $2 )::UUID IS NULL
    THEN -- forbid new message lest author is channel owner, or is auto-generated sponsub message.
        EXISTS (
            SELECT 1
            FROM vw_channels c 
            WHERE c.chn_id = $5
            AND CASE 
                    WHEN $18 <> 0
                    THEN true
                    ELSE c.owner_id = $6
                END
        )
    ELSE -- forbid reply message lest recipient message (rx) exists in channel.
        EXISTS (
            SELECT 1 
            FROM vw_messages rx 
            WHERE rx.msg_id = $2
            AND rx.author_handle = $4
            AND rx.chn_id = $5
        )
    END
LIMIT 1
```

#### Upsert 

```sql
-- ON CONFLICT ... DO UPDATE ...
INSERT INTO geo_cities(
    id, country_id, city_name
)
VALUES (1, 1, 'ExampleName')
ON CONFLICT (id) DO UPDATE SET 
    country_id = excluded.country_id, 
    city_name = excluded.city_name
RETURNING *; -- @ function, must match pre-body statement: RETURNS ... AS
```
```sql
-- SELECT ... WHERE NOT EXISTS : (Golang example)
INSERT INTO channels (
    chn_id, view_id, owner_id, 
    host, slug, title, about, 
    privacy, msg_size, date_create, etag
    )
SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
WHERE NOT EXISTS (SELECT slug FROM channels WHERE slug = $5)
```
```sql 
-- RETURNING : @ Upsert
INSERT INTO applicants (
    email, handle, code, mode, date_create
)
VALUES ('foo@bar.com', 'hsle', '1234567', 1, now())
ON CONFLICT (email) DO UPDATE SET 
    "handle" = 'hsle',
    "code" = '1234567',
    "mode" = 1,
    "date_create" = now()
WHERE applicants.email = 'foo@bar.com'
RETURNING *;          -- Typed return !!!

 idx |    email    | handle |  code   | mode |          date_create
-----+-------------+--------+---------+------+-------------------------------
  10 | foo@bar.com | hsle   | 1234567 |    1 | 2022-02-03 14:53:53.614682+00
(1 row)
-- OR
...
RETURNING applicants; -- Untyped return !!!

                           applicants
-----------------------------------------------------------------
 (10,foo@bar.com,hsle,1234567,1,"2022-02-03 14:55:43.501578+00")
(1 row)
```
- Double quotes around field names, e.g., `"handle"`, is not needed here, but PostgreSQL converts all such names to lowercase without them.

#### `IN` is faster than `OR`

```sql
-- Replace this ...
WHERE (handle = 'app') OR (handle = 'AdminTest') OR (handle = 'UserTest')
--- ... with this ...
WHERE handle IN ('app', 'AdminTest', 'UserTest')
```
```sql
-- inverse
WHERE slug NOT IN ('pub', 'sub')
```

#### ` t1.c3 = ANY (..)` | t1.c3 IN (..) 

```sql
WHERE chn_id = ANY (SELECT chn_id FROM vw_messages WHERE author_id = appid())
-- OR (EQUIVALENT)
WHERE chn_id IN (SELECT chn_id FROM vw_messages WHERE author_id = appid())
```

#### `ANY` @ Array 

```sql
--- Replace this ...
WHERE c.key = ANY (ARRAY[123, 539, ...])
-- ... OR ...
WHERE c.key IN (123, 539, ... )
--- ... with this (performant) ...
WHERE c.key = ANY (VALUES (123), (539), ... )
-- ... OR ...
WHERE c.key IN (VALUES (123), (539), ... )
```

#### ARRAY contains : `@>` | [`ARRAY` Functions](https://www.postgresql.org/docs/12/functions-array.html)

Add an element to an `ARRAY`, e.g., to a field of type `TEXT[]`

```sql
-- Idempotent append
UPDATE users SET 
    roles = array_append(roles, 'MODERATOR')
WHERE handle = 'FooBAR' AND NOT roles @> ARRAY['MODERATOR'];
```

### `INSERT... RETURNING <table or column(s) name(s)>`, or `UPDATE ... RETURNING ...`; returns _only_ the rows successfuly inserted; use ___to validate___ the mutation &hellip;

- Yet such is _not compatible_ with Golang's `sqlx` pkg `Exec()`, which returns nothing.

```sql 
INSERT INTO messages_binary (timestamp, group_id, content) VALUES
    ('1', 'group5', '...'),
    ('2', 'group6', '...'),
    ('3', 'group7', '...')
    ON CONFLICT DO NOTHING 
    RETURNING timestamp;
```

`RETURNING <table-name>`; return ALL table columns, i.e., ___pointfree___ style &hellip;

```sql
INSERT INTO books (isbn, title, author, price) VALUES
    ('978-1505255607', 'The Time Machine', 'H. G. Wells', 5.99),
    ('978-1503261969', 'Emma', 'Jayne Austen', 9.44)
    RETURNING books;
```

>Pointfree makes for cleaner, more legible code, and much less of it. Just be careful to match the two boundaries (db &amp; app); the table columns (db) must align with the destination struct fields (app).

#### [`COPY ... FROM`/`TO ...`](https://www.postgresql.org/docs/current/sql-copy.html)  

Insert ___data___ from/to a ___file___ source/target; requires ___absolute path___ of the file; process an entire data file in one command; several file formats (`TEXT`, `CSV`, or `BINARY`); less flexible than `INSERT`, but incurs ___significantly less overhead for large data loads___; `BINARY` format is the fastest.

>Requires a user having `SUPERUSER` or `pg_write_server_files` `ROLE`, else per script `psql ... -f exfiltrate.sql`


- `FROM` a ___tab-delimited___ plain text file (default format).
    ```sql
    -- insert file data into table
    COPY products (product_no, name, price) 
        FROM '/home/user/products.txt';
    ```
- `FROM` a __`CSV`__ file (_Preserves whitespace!_)
    ```sql
    COPY some_table (col3,col7,col2)
    FROM '/foo/postgres-data.csv'
    DELIMITER ',' CSV HEADER; -- include header ( field names) row
    ```
- `TO` one record (row) to __`BINARY`__ file or `STDOUT`
    ```sql
    COPY (
        SELECT *
        FROM foo WHERE idx=50
    ) TO STDOUT WITH BINARY;
    ```
- `TO` a `CSV` file
    ```sql
    COPY (
        SELECT msg_id, body
        FROM messages
    ) TO '/home/foo.csv' WITH CSV; -- sans HEADER (field names) row
    ```

##### [`generate_series()`](https://www.postgresql.org/docs/current/functions-srf.html "postgresql.org") for [data generation](https://regilero.github.io/postgresql/english/2017/06/26/postgresql_advanced_generate_series/ "regilero.github.io/postgresql 2017") | [Set-based vs `FOR LOOP`](https://stackoverflow.com/questions/19145761/postgres-for-loop "@ StackOverflow.com")

```sql
DROP TABLE IF EXISTS foo;
CREATE TABLE IF NOT EXISTS foo (
    idx     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    c1      INT
);

INSERT INTO foo (c1)  
    SELECT * FROM generate_series(105,109) -- 105, ..., 109
    LIMIT  15000;  -- safety

SELECT * FROM foo;

--  idx | c1
-- -----+-----
--    1 | 105
--    2 | 106
--    3 | 107
--    4 | 108
--    5 | 109
```

### [Queries](https://www.postgresql.org/docs/current/queries.html) [(`SELECT`)](https://www.postgresql.org/docs/current/sql-select.html)

```sql
-- expression 
SELECT city, (temp_hi+temp_lo)/2  
    AS temp_avg, date FROM weather;

-- qualify
SELECT * FROM weather
    WHERE city = 'San Francisco' 
    AND prcp > 0.0;

-- unique & sort
SELECT DISTINCT city
    FROM weather
    ORDER BY city;

-- return the first row that matches
SELECT * FROM foo WHERE idx > 3 LIMIT 1;
```

### `UNION` [`ALL`]

Concatenate tables (having same columns) __per row__. 

```sql
SELECT * FROM messages where author_name = 'foo'
UNION
SELECT * FROM messages where to_id IS NOT NULL
```

`UNION ALL` ___is faster___; sans redundancy check.

```sql
SELECT city FROM customers
UNION ALL -- rows may be duplicates
SELECT city FROM suppliers
ORDER BY city;
```

`UNION` is also useful per column, e.g., ___prepend a column___ to a query result

    ```sql 
    SELECT 'Customer' AS kind, contact_name, city, country
    FROM customers
    UNION
    SELECT 'Supplier', contact_name, city, country
    FROM suppliers;

    kind        contact_name        city            country
    Customer    Yvonne Moncada      Buenos Aires    Argentina 
    Customer    Zbyszek             Walla           Poland 
    Supplier    Anne Heikkonen      Lappeenranta    Finland 
    Supplier    Antonio del Sadra   Oviedo          Spain 
    Supplier    Beate Vileid        Sandvika        Norway 
    ```

### `JOIN` 
Combine tables per common column | [postgresql.org](https://www.postgresql.org/docs/current/tutorial-join.html "tutorial @ postgresql.org") | [w3schools.com](https://www.w3schools.com/sql/sql_join.asp "w3schools.com") | [@w3resource.com](https://www.w3resource.com/sql/joins/sql-joins.php "tutorial @w3resource.com") 

![Join Types](./../SQL.JOIN-types.png)

- `[INNER] JOIN` 

    ```sql

    -- Explicit syntax
    SELECT *
    FROM a
    INNER JOIN b
    ON a.c5 = b.c3
    WHERE b.c2 = 'x'

    -- Equivalent syntax
    SELECT * 
    FROM a
    JOIN b
    ON a.c5 = b.c3
    WHERE b.c2 = 'x'

    -- Alternative Syntax
    SELECT *
    FROM a, b
    WHERE a.c5 = b.c3
    AND b.c2 = 'x'
    ```
    - Output __all columns__ from __both tables__ as long as the columns match. 
    - To select some subset of columns &hellip;
        ```sql
        SELECT a.c3, b.c1, a.c7, a.c2
        FROM a
        JOIN b 
        ON a.c5 = b.c3
        WHERE b.c2 = 'x'
        ```

- `LEFT [OUTER] JOIN` 
    ```sql
    SELECT *
        FROM weather 
        LEFT OUTER JOIN cities 
        ON (weather.city = cities.name);
    ```
    - Regards tables left and right of the __join operator__; __all rows__ of the __left table__ are output _at least once_, whereas __only matching rows__ of the __right table__ are output. 

- Self Join; one table, e.g., all the weather records that are in the temperature range of other weather records.

- Aggregate Functions 
    ```sql
    SELECT max(temp_lo) FROM weather;  
    -- max: 46
    ```
    ```sql
    SELECT city FROM weather
        WHERE temp_lo = (SELECT max(temp_lo) FROM weather); 
    -- city: San Francisco
    ```

- [Window Functions](https://www.postgresql.org/docs/current/tutorial-window.html) &mdash; Perform a calculation across (`OVER`) a set of table rows that are somehow related to the current row.  
    ```sql
    SELECT uname, 
        ROW_NUMBER () OVER (PARTITION BY idx ORDER BY idx),
        pass_hash
        WHERE pass_hash = 'bogus'
    FROM users;
    ```
    - Resets the idx ([row count](https://www.postgresqltutorial.com/postgresql-row_number/)) to that of filtered result(s).
    ```sql
    SELECT depname, empno, salary, avg(salary) 
        OVER (PARTITION BY depname) FROM empsalary;

    -- order, then add a rank per value
    SELECT depname, empno, salary,
        rank() OVER (PARTITION BY depname ORDER BY salary DESC)
    FROM empsalary;
    ```

- [Table to JSON](https://attacomsian.com/blog/export-postgresql-table-data-json/)
    ```sql
    SELECT array_to_json(array_agg(row_to_json (r))) 
    FROM (
        SELECT first_name, last_name, email, first_name || ' ' || last_name as name 
        FROM users;
    ) r;
    ```

### Updates [(`UPDATE`)](https://www.postgresql.org/docs/current/sql-update.html) 

```sql
UPDATE weather
    SET temp_hi = temp_hi - 2,  temp_lo = temp_lo - 2
    WHERE date > '1994-11-28';
```

`WHERE col_name IN ('val1', 'val2', ...)`

```sql
UPDATE users SET 
    pass_hash = pw_hash('abc123'),
    date_update = now()
    WHERE handle IN ('foo', 'bar', 'boofar');
```

-  [Transactions](https://www.postgresql.org/docs/11/tutorial-transactions.html)  &mdash; Bundle __multiple steps__ into a single, __all-or-nothing__ operation  

    ```sql
    -- per transaction
    BEGIN;
    UPDATE accounts SET balance = balance - 100.00
        WHERE name = 'Alice';
    SAVEPOINT my_savepoint;
    UPDATE accounts SET balance = balance + 100.00
        WHERE name = 'Bob';
    -- oops ... forget that and use Wally's account
    ROLLBACK TO my_savepoint;
    UPDATE accounts SET balance = balance + 100.00
        WHERE name = 'Wally';
    COMMIT;
    ```

- `RETURNING`; use to validate; to return only those rows affected.

    ```sql
    UPDATE messages 
    SET body = 'Newer content' 
    WHERE msg_id = 3 
    RETURNING msg_id;
    ```
### Deletions [(`DELETE`)](https://www.postgresql.org/docs/current/sql-delete.html)

```sql
DELETE FROM weather WHERE city = 'Hayward';
```

- `ON DELETE RESTRICT`  
If `product_no` entry exists at `order_items` (junction) table, then prohibit its removal at `products` table.

- `ON DELETE CASCADE`   
If `order_id` entry is removed at `orders` table, then remove its entry at  `order_items` (junction) table too.    

- Other actions:   
    - `ON UPDATE`; where `CASCADE` means copy to the referencing row(s).

    - `NO ACTION`; if any referencing rows still exist when the constraint is checked, an error is raised; this is the default behavior.  
    - `SET NULL`, `SET DEFAULT`; the referencing column(s) in the referencing row(s) set to null or default values, respectively, when the referenced row is deleted.

> Greatly simplies CRUD logic of external code.

#### Conditional `DELETE`

Delete record(s) of a table ___per result of a query upon another table___. The following example deletes all old short-form messages of no interest to any other member `AND` authored by any member having no buyin. That last "`AND`" is conditional upon read result, `EXISTS(SELECT...)`, from logic upon another table (`users`).

```sql
DELETE FROM messages 
WHERE CURRENT_TIMESTAMP - date_update > 10 * interval '1 hour'
AND count_replies = 0
AND repubs = 0
AND sponsub = 0
AND tokens_q <= 0
AND tokens_p = 0
AND size < 1024
AND EXISTS (
    SELECT idx FROM users 
    WHERE users.user_id = messages.author_id
    AND users.acc_buyin = 0
);
```

### Junction Table to Resolve Many-to-Many Relationships 

    M:M  ==>  M:1>--<1:M

```sql
-- M:M @ products:orders
CREATE TABLE products (
    product_no integer PRIMARY KEY,
    name text,
    price numeric
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    shipping_address text,
    ...
);

-- resolve (w/ constraints) @ junction table
CREATE TABLE order_items (
    product_no integer RENCES products ON DELETE RESTRICT,
    order_id integer RENCES orders ON DELETE CASCADE,
    quantity integer,
    PRIMARY KEY (product_no, order_id)
);
```

## [Variables](https://www.postgresql.org/docs/9.6/app-psql.html#APP-PSQL-VARIABLES) | [`psq`l meta-commands](https://www.postgresql.org/docs/9.6/app-psql.html)

### `\set key1 val1` 

Use @ `:key1`, `:'key1'`, or `(:key1)`

```sql
-- :key1
\set idx 5
DELETE FROM users where user_id = :idx;

-- :'key1'
\set cid 'f4a21a19-5fb8-4e5d-ac89-b54f4bd5c81f'
SELECT get_msglist_chan_json(:'cid', now(), 99);

-- (:key1)
\set cid 'select distinct chan_id from messages where body = \'__FAUX__\''
select get_msglist_chan_json((:cid), now(), 99)
```
- Note to enter `psql` meta-command ___sans semicolon___, unlike SQL commands.

## [CTE (Common Table Expressions) AKA `WITH` Queries](https://www.postgresql.org/docs/current/queries-with.html) 

`WITH fooVar AS (query)` provides a way to write auxiliary statements for use in a larger query, ___for improved performance___; define _temporary tables_ that exist just _for one query_, and _set its result to a variable_. CTEs may be utilized to perform some subset of what otherwise requires a PostgreSQL [`trigger` function](#trigger).

```sql
-- Two CTEs; the second utilizing the first. 
WITH regional_sales AS ( -- CTE; sets its query result to `regional_sales` var
        SELECT region, SUM(amount) AS total_sales
        FROM orders
        GROUP BY region
     ), 
     top_regions AS ( -- CTE; sets its query result to `top_sales` var 
        SELECT region
        FROM regional_sales
        WHERE total_sales > (SELECT SUM(total_sales)/10 FROM regional_sales)
     )
-- Main query; access var `regional_sales` 
SELECT region,
       product,
       SUM(quantity) AS product_units,
       SUM(amount) AS product_sales
FROM orders
WHERE region IN (SELECT region FROM top_regions) 
GROUP BY region, product;
```

#### `WITH RECURSE `

_The general form of a recursive `WITH` query is always a non-recursive term, then `UNION` (or `UNION ALL`), then a recursive term, where only the recursive term can contain a reference to the query's own output._

```sql 
SELECT DISTINCT mm.* FROM ( 
    SELECT m1.* FROM vw_messages m1 
    WHERE tokens_q > 0

    UNION ALL

    SELECT m2.* FROM vw_messages m2 
    WHERE tokens_p > 0
) mm
ORDER BY mm.tokens_p, mm.tokens_q DESC
LIMIT 20;
```
```sql
SELECT DISTINCT mm.* FROM ( 
    WITH RECURSIVE xx AS(

        SELECT tx.* 
        FROM vw_messages tx 
        JOIN vw_messages rx
        ON tx.to_id = rx.msg_id        
        AND rx.author_id = uid   

        UNION ALL

        SELECT mx.*
        FROM vw_messages mx
        JOIN xx ON mx.to_id = xx.msg_id 

    ) SELECT * FROM xx
    ...
) mm
```

## [Views](https://www.postgresql.org/docs/11/rules-views.html "postgresql.org") 
- A stored query; like a function but takes no param. Create a view over a query; to __maintain constistant interfaces__ even as an application's ___tables evolve___;  encapsulates structural details. ([Tutorial](https://www.postgresql.org/docs/current/tutorial-views.html "postgresql.org")); __views are not rules__ per se, but _use the query rewrite rules_; a key aspect of good SQL database design; 

    ```sql
    -- create  
    CREATE VIEW myview AS
    SELECT city, temp_lo, temp_hi, prcp, date, location
        FROM weather, cities
        WHERE city = name;
    -- use 
    SELECT * FROM myview;
    ``` 

## [__Materialized Views__](https://www.postgresql.org/docs/11/rules-materializedviews.html "postgresql.org")
- Persist view (a query) results in a table-like form; ___cache___. Faster than a table query, but may be stale. 

```sql
-- derived from views table
DROP MATERIALIZED VIEW IF EXISTS mv_views_cfg CASCADE;
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_views_cfg AS (
    SELECT DISTINCT
        view_id,
        vname
    FROM views  
    WHERE etag = 'mv-cfg'
);

-- Update source table
INSERT INTO views (vname, etag, view_id) 
SELECT 'ghost-view', 'mv-cfg', uuid_nil() -- required @ mv_channels_cfg MV
WHERE NOT EXISTS (SELECT 1 FROM views WHERE vname = 'ghost-view');

-- Refresh the MV, else remains unchanged (stale).
ESH MATERIALIZED VIEW mv_views_cfg;
```

## `CREATE` [`UNLOGGED TABLE ...`](https://www.postgresql.org/docs/12/sql-createtable.html)

>"Data written to unlogged tables is not written to the write-ahead log, which makes them ___considerably faster___ than ordinary tables. However, ... not crash-safe ... not replicated to standby servers ..."


## [Server Programming](https://www.postgresql.org/docs/11/server-programming.html "postgresql.org")

- [PostgreSQL Type System](https://www.postgresql.org/docs/11/extend-type-system.html "postgresql.org")


- Rules; [don't use them](https://wiki.postgresql.org/wiki/Don't_Do_This#Don.27t_use_rules). Use __triggers__ instead. (See `CREATE FUNCTION` below.)

    - The Query Rewrite [Rule System](https://www.postgresql.org/docs/11/rules.html "postgresql.org")  

        > &hellip;  __modifies queries__ to take rules into consideration, and then passes the modified query to the query planner for planning and execution. &hellip; very powerful &hellip; used for many things such as query language __procedures__, __views__, and __versions__.

### [Stored Procedures](https://www.postgresqltutorial.com/postgresql-stored-procedures/)

Confusing lingo; three types of such &hellip;

- `FUNCTION` &mdash; takes args; has returns or not
    - `TRIGGER` &mdash; does not take args
- `PROCEDURE` &mdash; has no return 

### [Functions and Operators](https://www.postgresql.org/docs/current/functions.html "postgresql.org")  | [SQL Functions](https://www.postgresql.org/docs/11/xfunc-sql.html "postgresql.org") | [Control Structures](https://www.postgresql.org/docs/13/plpgsql-control-structures.html "RETURN ..., RETURNING ..., IF-THEN-ELSEIF, CASE-WHEN-ELSE-END")


Allow us to group __a block of `SQL` statements__ _inside the database server_; radically reduce client/server comms overhead.

Using [Procedural Languages](https://www.postgresql.org/docs/11/xplang.html "postgresql.org");  `PL/pgSQL`, `PL/Tcl`, `PL/Python`, ...; loadable.  

- These are more flexible than SQL functions; the power of a procedural language and the ease of SQL. [Structure of `PL/pgSQL`](https://www.postgresql.org/docs/11/plpgsql-structure.html "postgresql.org"):

#### `SQL` vs. `PL/pgSQL`

```sql
-- @ SQL (standard)
CREATE OR REPLACE FUNCTION set_chan(oid INT, vid INT, frag TEXT)
    RETURNS TABLE (chan_id INT) AS
$BODY$
    INSERT INTO channels (owner_id, view_id, slug) 
        VALUES (oid, vid, frag) 
        RETURNING channels.chan_id;
$BODY$ LANGUAGE SQL;


-- @ PL/pgSQL
CREATE OR REPLACE FUNCTION set_chan(oid INT, vid INT, frag TEXT)
    RETURNS TABLE (chan_id INT) AS
$BODY$
BEGIN
    RETURN QUERY -- Else err: "query has no destination for result data"
    INSERT INTO channels (owner_id, view_id, slug) 
        VALUES (oid, vid, frag) 
        RETURNING channels.chan_id;
END
$BODY$ LANGUAGE 'plpgsql';
```

### [Control Structures](https://www.postgresql.org/docs/13/plpgsql-control-structures.html "RETURN ..., RETURNING ..., IF-THEN-ELSEIF, CASE-WHEN-ELSE-END")

`RETURN` ..., `RETURNING` ..., `IF-THEN-ELSEIF`, `CASE-WHEN-ELSE-END`

#### Return Base Types

```sql
CREATE FUNCTION somefunc(integer, text) 
RETURNS integer AS 
$BODY$
BEGIN
-- ... the function body 
END
$BODY$
LANGUAGE plpgsql;
```

[Dollar Quoting](https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-DOLLAR-QUOTING "postgresql.org")  

##### Load a function per SQL file :: `\i funcDef.sql`

#### [Return Composite types](https://www.postgresql.org/docs/11/xfunc-sql.html#XFUNC-SQL-COMPOSITE-FUNCTIONS) @ __1 row__

```sql
INSERT INTO emp VALUES ('Bill', 4200, 45, '(2,1)');

CREATE FUNCTION double_salary(emp) 
RETURNS numeric AS 
$$
    SELECT $1.salary * 2 AS salary;
$$ LANGUAGE SQL;

SELECT name, double_salary(emp.*) AS dream
    FROM emp
    WHERE emp.cubicle ~= point '(2,1)';
```

#### [Return `TABLE`](https://www.postgresql.org/docs/11/xfunc-sql.html#XFUNC-SQL-FUNCTIONS-RETURNING-TABLE) @ __one or more rows__

- ___Returns 1 row regardless___; `NULL`s _if 0 rows match!_

```sql
CREATE FUNCTION get_table(id int) 
RETURNS tblname AS 
$$
    SELECT * FROM tblname WHERE idx = id;
$$ LANGUAGE SQL;

CREATE FUNCTION sum_n_product_with_tab (x int)
RETURNS TABLE(sum int, product int) AS 
$$
    SELECT $1 + t1.y, $1 * t1.y FROM t1;
$$ LANGUAGE SQL;
```
- Note: Must omit or include `TABLE`, per pointsfree versus not pointsfree styles:
    - `RETURNS tblname`
    - `RETURNS TABLE(...) AS`

Per `RETURN QUERY` @ `plpgSQL`

```sql
CREATE OR REPLACE FUNCTION get_film (p_pattern VARCHAR) 
	RETURNS TABLE (
		film_title VARCHAR,
		film_release_year INT
) 
AS $$
BEGIN
	RETURN QUERY SELECT
		title,
		cast( release_year as integer)
	FROM
		film
	WHERE
		title ILIKE p_pattern ;
END; $$ 
LANGUAGE 'plpgsql';
```

Use a function as a `TABLE` source; per referenced-table name (`foo`)

```sql
CREATE FUNCTION getfoo(int) RETURNS foo AS $$
    SELECT * FROM foo WHERE fooid = $1;
$$ LANGUAGE SQL;

SELECT *, upper(fooname) FROM getfoo(1) AS t1;
```

#### [Return `SETOF` (UNTYPED)](https://www.postgresql.org/docs/11/xfunc-sql.html#XFUNC-SQL-FUNCTIONS-RETURNING-SET) @ __one or more rows__ of a `TABLE`

- ___Returns 0 rows if no match___, unlike `RETURNS foo`, which ___returns 1 row regardless___.
- Returns ___untyped___ columns, so is _not_ SQL compatible. 

```sql
CREATE FUNCTION getfoo(int) 
    RETURNS SETOF foo AS 
$$
    SELECT * FROM foo WHERE fooid = $1;
$$ LANGUAGE SQL;

SELECT * FROM getfoo(1) AS t1;
```

##### How to retrieve the table rows per ___pointfree___ style

`SETOF table_name`

```sql 
DROP FUNCTION IF EXISTS get_owner(UUID);
CREATE OR REPLACE FUNCTION get_owner(cid UUID)
    --RETURNS TABLE (user_id UUID, uname TEXT, email TEXT) AS
    RETURNS SETOF users AS
    --RETURNS SETOF users AS -- ERROR type mismatch ???
$BODY$
    SELECT u.* FROM users u
    INNER JOIN channels c
    ON u.user_id = c.owner_id
    WHERE c.chan_id = cid 
$BODY$
LANGUAGE SQL;

-- SUCCESS (return is typed)
SELECT * FROM get_owner('84944737-e5e4-4ebf-855a-cc3306781603');
-- SUCCESS (return is untyped)
SELECT get_owner('84944737-e5e4-4ebf-855a-cc3306781603');
```

However, we can [declare a type, and reference it](https://stackoverflow.com/questions/22423958/sql-function-return-type-table-vs-setof-records "2016 @ StackOverflow.com") thereafter.

```sql
CREATE TYPE footype AS (score int, term text);

CREATE FUNCTION foo() RETURNS SETOF footype AS $$
   SELECT * FROM ( VALUES (1,'hello!'), (2,'Bye') ) t;
$$ language SQL immutable;

CREATE FUNCTION foo_tab() RETURNS TABLE (score int, term text) AS $$
   SELECT * FROM ( VALUES (1,'hello!'), (2,'Bye') ) t;
$$ language SQL immutable;

SELECT * FROM foo();      -- works fine!
SELECT * FROM foo_tab(); 
```

#### [Return `SETOF` RECORD (UNTYPED)](https://www.postgresql.org/docs/11/xfunc-sql.html#XFUNC-SQL-FUNCTIONS-RETURNING-SET) @ __one or more rows__ of a `TABLE`

```sql
CREATE OR REPLACE FUNCTION storeopeninghours_tostring(numeric)
 RETURNS SETOF RECORD AS $$
DECLARE
 open_id ALIAS FOR $1;
 result RECORD;
BEGIN
 RETURN QUERY SELECT '1', '2', '3';
 RETURN QUERY SELECT '3', '4', '5';
 RETURN QUERY SELECT '3', '4', '5';
END
$$;
```
- Since untyped, &hellip
    ```sql
    -- FAIL
    SELECT * FROM storeopeninghours_tostring(2);
    -- SUCCESS
    SELECT storeopeninghours_tostring(2);
    ```
```sql
CREATE OR REPLACE FUNCTION public.exec(text)
RETURNS SETOF RECORD
AS $BODY$
BEGIN 
    RETURN QUERY EXECUTE $1; 
END 
$BODY$ 
LANGUAGE 'plpgsql';

-- Usage:
SELECT * FROM exec('SELECT now()') AS t(dt timestamptz);
```

#### Return per `OUT` params; `OUT var TYPE`

Useful when return is a basic type (vs a  composite, `TABLE`, etal)

```sql
CREATE FUNCTION add_em (IN x int, IN y int, OUT sum int)
AS 'SELECT x + y'
LANGUAGE SQL;

SELECT add_em(3,7);
```
- Note no need for `FROM` clause.

#### Return `void`

```sql
CREATE FUNCTION clean_emp() RETURNS void AS '
    DELETE FROM emp
        WHERE salary < 0;
' LANGUAGE SQL;

SELECT clean_emp();
```

### `LATERAL` : [`SELECT f.col_3, x.* FROM foo f, LATERAL aFunc(f.bar) x ...`](https://www.postgresql.org/docs/current/sql-select.html) 

>Call a function on column(s) of _each record_ in a query, 
returning its results (all or selected columns)
instead of, or in addition to, column(s) of the queried table.

```sql
-- Insert a user-scoped api key (VIP key) for each user having ...
SELECT x.handle, x.xid, x.api_key
FROM vw_users u,
    LATERAL insert_user_scoped_api_key(u.handle) x
WHERE u.roles @> ARRAY['HOST']
AND (u.email LIKE '%@emx.unk');
```
```text
  handle                       xid                                  api_key
SlowMoFTW      b03048a8-24c3-4658-b645-c7c6eecefa8b    AWTTFKRTQX4XCZLR3D6JGWLPBL.bnP...oNv
TheRetorter    bd8479d6-111c-42e3-a49d-25423535cb39    HZ4CI21144KBMRD6EEEGMJZ5TJ.JVC...Hsw
...
```

### [`CURSOR` @ PL/pgSQL](https://www.postgresqltutorial.com/plpgsql-cursor/) usage in a function | @ [`/docs`](https://www.postgresql.org/docs/11/plpgsql-cursors.html)

Rather than executing a whole query at once, it is possible to set up a cursor that encapsulates the query, and then read the query result a few rows at a time. 

### [Trigger Functions](https://www.postgresql.org/docs/11/plpgsql-trigger.html "postgresql.org") <a name=trigger></a>
A function that binds to a table/event, and ___automatically triggers___ on [data changes](https://www.postgresql.org/docs/11/plpgsql-trigger.html#PLPGSQL-DML-TRIGGER "postgresql.org") or [database events](https://www.postgresql.org/docs/11/plpgsql-trigger.html#PLPGSQL-EVENT-TRIGGER "postgresql.org"). Unlike other functions, it ___does not accept any parameters___.

```sql
-- per CTE Postgres 9.1:
WITH rows AS (
    INSERT INTO Table1 (name) VALUES ('a_title') 
    RETURNING id
)
INSERT INTO Table2 (val)
SELECT id
FROM rows

-- per Trigger:
CREATE FUNCTION t1_ins_into_t2()
    RETURNS trigger AS 
$$
BEGIN
    INSERT INTO table2 (val) 
        VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t1_ins_into_t2
    AFTER insert on table1
FOR EACH ROW
EXECUTE PROCEDURE t1_ins_into_t2();
```

### [`CREATE PROCEDURE`](https://www.postgresql.org/docs/11/xproc.html)

A kind of function sans return; _unlike functions_, procedures ___allow transactions___ 

```sql
CREATE OR REPLACE PROCEDURE set_transaction_q(payer INT, payee INT, msg INT, q INT)
LANGUAGE 'plpgsql'    
AS $$ -- ... returns void on success; ERROR on fail
BEGIN
    -- payer (from)
    UPDATE users SET tokens_q = tokens_q - q
        WHERE user_id = payer;
    -- payee (to)
    UPDATE users SET tokens_q = tokens_q + q
        WHERE user_id = payee;
    -- record 
    INSERT INTO transactions (payer_id, payee_id, msg_id, tokens_q) 
        VALUES (payer, payee, msg, q);
    COMMIT;
END;
$$;

CALL set_transaction_q(:payer, :payee, :msg, :q);
```

#### Transaction @ `PROCEDURE` [`BEGIN ... COMMIT ... ROLLBACK`](https://www.postgresql.org/docs/11/plpgsql-transactions.html)

```sql
CREATE PROCEDURE transaction_test1()
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 0..9 LOOP
        INSERT INTO test1 (a) VALUES (i);
        IF i % 2 = 0 THEN
            COMMIT;
        ELSE
            ROLLBACK;
        END IF;
    END LOOP;
END
$$;

CALL transaction_test1();
```

## `LOCK`

This is a per table, per transaction __write__ lock; all other users are prevented from writing to the table whilst under lock.

```sql
BEGIN;
LOCK TABLE foo IN ACCESS EXCLUSIVE MODE;
-- All other users are now restricted to read-only mode at this table.
-- ... Do stuff to foo table and/or its constraints, then ...
COMMIT; -- Unlock the table.
```

## [PostgreSQL Tutorial](http://www.tutorialspoint.com/postgresql/ "tutorialspoint.com")

## [All Native PostgreSQL Client Apps](https://www.postgresql.org/docs/current/reference-client.html)

## [`pgbench` :: benchmark tests](https://www.postgresql.org/docs/current/pgbench.html)

```bash
su - postgres  # switch to 'postgres' user (@ alpine)
```

```bash 
psql -c 'SHOW config_file'
psql -c 'SELECT version();'     # version of SERVER (postgres daemon)
psql --version                  # version of CLIENT (psql) 
# Initialize
pgbench -i -p 5432 -d postgres
#...
# Test w/ 10 clients 
pgbench -c 10  # -T <SECONDS>
#...
starting vacuum...end.
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 10
number of threads: 1
number of transactions per client: 10
number of transactions actually processed: 100/100
latency average = 23.646 ms
tps = 422.909536 (including connections establishing)
tps = 426.859358 (excluding connections establishing)
#... tps = Transactions Per Second 

# -S (SELECT only; read only), -n (skip vacuum)
pgbench -c 100 -T 300 -S -n
# Try tweaking params: `shared_buffers` and `effective_cache_size` 
# @ postgresql.conf
exit # back to root user
apt-get update
apt-get install vim 
su - postgres
vim /var/lib/postgresql/data/postgresql.conf 
```

@ `bench.sql` ([`bench.init.sql`](bench.init.sql))

```sql
INSERT INTO test_bench VALUES(1,'test');
INSERT INTO test_bench VALUES(1,'test');
SELECT * FROM test_bench WHERE id=1;
SELECT * FROM test_bench WHERE id=2;
```
- A workload of 50% reads and 50% writes (or a 60:40 environment).

```bash
pgbench -c 100 -T 3 -S -n -f bench.sql 

postgres@30420c4a8027:/home/2020-lab-1$ pgbench -c 100 -T 3 -S -n -f bench.sql
transaction type: multiple scripts
scaling factor: 1
query mode: simple
number of clients: 100
number of threads: 1
duration: 3 s
number of transactions actually processed: 5538
latency average = 57.473 ms
tps = 1739.939481 (including connections establishing)
tps = 1741.067620 (excluding connections establishing)
SQL script 1: <builtin: select only>
 - weight: 1 (targets 50.0% of total)
 - 2738 transactions (49.4% of total, tps = 860.230101)
 - latency average = 7.073 ms
 - latency stddev = 9.057 ms
SQL script 2: bench.sql
 - weight: 1 (targets 50.0% of total)
 - 2800 transactions (50.6% of total, tps = 879.709380)
 - latency average = 94.788 ms
 - latency stddev = 41.833 ms
```

## [`psql` :: client CLI utility](https://www.postgresql.org/docs/10/app-psql.html)

- Start a session @ server, and issue commands therein ...

    ```bash
    $ psql -h 'localhost' -p '5432' -U 'postgres' -d 'foo'
    psql (11.2 (Ubuntu 11.2-1.pgdg18.04+1))
    ...
    foo=# select domain,path,html from public.comments;
    ```

- Or, per command, from the host ...

    ```bash
    $ psql -h 'localhost' -p '5432' -U 'postgres' -d 'foo' \
        -c 'select domain,path,html from public.comments;'
    ```

### SQL @ host per `psql`

```bash
# SQL ...
psql -c '\x' -c 'SELECT * FROM foo;'
# or
echo '\x \\ SELECT * FROM foo;' | psql
```

### SQL @ server session per `psql` 
```bash
# Connect, then enter SQL statements directly 
$ psql -h <host> -p <port> -U <user> -W <pass> <database>

SELECT * FROM foo;

SELECT version();    # show PostgreSQL SERVER version  
SELECT current_date;
SELECT 2 + 2;
```

### `psql` :: commands
```bash
su - postgres  # switch to 'postgres' user (@ alpine)
```

```bash
psql -c 'SHOW config_file'
psql -c 'SELECT version();'     # version of SERVER (postgres daemon) 
psql --version                  # version of CLIENT (psql) 
# Connect to database at remote host
$ psql -h <host> -p <port> -U <user> -W <pass> <database>
# Connect locally
$ psql -U <user> 
psql (11.2 (Debian 11.2-1.pgdg90+1))
Type "help" for help.
<user>=>   # cmd prompt @ psql session, if restricted user
<user>=#   # cmd prompt @ psql session, if superuser (@ docker|installer)

# psql commands ...
    \h               # help   
    \l               # List databases  
    \c $DB_NAME      # Connect to database  
    \d               # Display tables list 
    \d+ $TABLE_NAME  # Display table schema (collumn names and data type)  
    \x               # Expanded display (toggle); much more verbose
    \q               # Quit; end session; terminate the forked server process 
```
- Those `psql` commands cause failures when run as scripts in Adminer and such wrappers.

#### @ Docker container ([`postgres.docker.sh`](postgres.docker.sh))
```bash
# @ Container shell (bash) ...

root@f3e668efe2a2:/home# pushd home 
root@f3e668efe2a2:/home# psql -U postgres -f ./sql/wipe.sql
root@f3e668efe2a2:/home# psql -U postgres -f ./sql/migrate.sql
root@f3e668efe2a2:/home# psql -U postgres -f ./sql/seeds.sql

root@f3e668efe2a2:/home# psql -U postgres -c 'SELECT * from topics'
root@50a7156ab294:/home# psql -U postgres -c 'SELECT owner_id as id, slug as path FROM channels'

# @ Launch INTERACTIVE client session (PostgreSQL)

root@f3e668efe2a2:/home# psql -U postgres
```

@ interactive session &hellip;

```client
postgres=# \l
postgres=# \d
postgres=# \d+ channels 

postgres=# SELECT owner_id AS id, slug AS path FROM channels;
                  id                  |  path
--------------------------------------+--------
 45b5fbd3-755f-4379-8f07-a58d4a30fa2f | slug-1
 5cf37266-3473-4006-984f-9325122678b7 | slug-2
 45b5fbd3-755f-4379-8f07-a58d4a30fa2f | slug-3
```

### [Server Config](https://www.postgresql.org/docs/current/runtime-config.html)

- `/etc/postgresql/postgresql.conf`
- `/var/lib/postgresql/data/postgresql.conf`

#### Show Location:

```sql 
SHOW config_file;
```
- Sample config included @ [PostgreSQL images](https://hub.docker.com/_/postgres "hub.docker.com"):
    - `/usr/share/postgresql/postgresql.conf.sample` 
    - `/usr/local/share/postgresql/postgresql.conf.sample` @ Alpine variants

#### Reload @ running server:

- @ `bash` :: `pg_ctl`
    ```bash
    pg_ctl reload
    ```
- @ SQ: :: `psql`
    ```sql
    SELECT pg_reload_conf()
    ```


```bash
# Query the server for its config file ...
$ psql -h $host -U $user -c 'SHOW config_file;'
               config_file
------------------------------------------
 /var/lib/postgresql/data/postgresql.conf
(1 row)  # ... @ a running Docker container
``` 

### Create a database

- @ `psql` utility

    ```bash
    $ psql ...
    # @ PostgreSQL server session ...
    CREATE DATABASE dbname;
    ```
- @ `createdb` utility

    ```bash
    $ createdb [-U USERNAME] ['dbname']  # default dbname is USERNAME
    ```

### Destroy a database

- @ `dropdb` utility

    ```bash
    $ dropdb 'dbname'
    ```  

### [Backup/Restore a Database](https://www.postgresql.org/docs/current/backup.html) | [Automate](https://mattsegal.dev/postgres-backup-automate.html "mattsegal.dev @ 2020")

- [Synchronous Replication](https://www.postgresql.org/docs/12/warm-standby.html#SYNCHRONOUS-REPLICATION)
- [Backup a Database](https://www.postgresql.org/docs/10/backup-dump.html)   
    - [@ `pg_dump`](https://www.postgresql.org/docs/current/app-pgdump.html) utility. Generate a text file with SQL commands that, when fed back to the server, will __recreate the database in the same state__ as it was at the time of the dump.  

        - `-a` ; `--data-only`
        - `-s` ; `--schema-only`
        - `-t` ; `--table <TABLE>`
        - `-w` ; `--no-password` ; [Sans prompt](https://www.postgresql.org/docs/current/libpq-pgpass.html); use a __password file__: `chmod 600 ~/.pgpass`, or __environment variable__, `PGPASSFILE: host:port:db:user:pass`
            - `~/.pgpass` is ___absolutely worthless___ in container-ized environments; owner/perms (`chown`/`chmod`) of FILE must match that of (CONTAINER's) db USER.

        ```bash 
        # Entire database, as SQL
        pg_dump -U $user -Fc 'dbname' > 'dumpfile.sql'
        pg_dump -U $user -Ft 'dbname' > 'dumpfile.tar'
        ```
        - `-Fc`; `--format=custom`; _Output a custom-format archive suitable for input into `pg_restore`_.

        ```bash
        # Table, schema only, as SQL
        $ pg_dump -h $_host -p $_port -U $_user \
            -d $_db -t $_table -s  > $_db.$_table.sql
        ```

- [Restore a Database](https://www.postgresql.org/docs/current/backup-dump.html#BACKUP-DUMP-RESTORE)

    - [@ `pg_restore`](https://www.postgresql.org/docs/current/app-pgrestore.html) utility; use if large/compressed dumpfile.

        ```bash
        # Script that deletes all objects and data in target db
        psql -U $user -d $dbname -c '\i /home/wipe/wipe.sql' 
        # Load new db objects and data, or whatever is contained in the source tar file
        pg_restore -U $user -d $dbname 'dumpfile.tar'
        ```
        - @ S3
            ```bash
            # Restore from the latest backup file
            S3_TARGET=$S3_BUCKET/$LATEST_BACKUP_FILE
            aws s3 cp $S3_TARGET - | pg_restore --dbname $DB_NAME --clean --no-owner
            ```
    - [@ `psql`](https://www.postgresql.org/docs/current/app-psql.html) utility 

        ```bash 
        # Restoring the dump
        $ psql 'dbname' < 'dumpfile'
        ```

        ```bash
        $ psql -h $host -p $port -U $user \
            --set ON_ERROR_STOP=on 'dbname' < 'dumpfile'
        ```

- Clone :: Server-to-Server (Dump/Restore)
    - [@ `pg_dump`](https://www.postgresql.org/docs/current/app-pgdump.html "postgresql.org") piped to `psql`

        ```bash
        $ pg_dump -h $host1 'dbname' | psql -h $host2 'dbname'
        ```

## @ Ubuntu/Debian
- Installed PostgreSQL dir, e.g., @ `/opt/PostgreSQL/10.7`
- Better to use container/cloud-based service

## Connect the backend server 

- Per [UNIX Domain Sockets (`UDS`) or TCP/IP](https://docs.mattermost.com/install/sockets-db.html#with-unix-socket "@ Mattermost") Sockets.
    - [The `UDS`](https://lists.freebsd.org/pipermail/freebsd-performance/2005-February/001143.html "freebds.org 2005") are [faster and more secure](https://stackoverflow.com/questions/14973942/tcp-loopback-connection-vs-unix-domain-socket-performance "StackOverflow 2016"). 
    - [Test @ `ipc-bench`](https://github.com/rigtorp/ipc-bench "2019 @ GitHub") :: `~ 7x` more throughput; `1/3` the latency.
    

            TCP  latency: 6 us
            UDS  latency: 2 us
            PIPE latency: 2 us

            TCP  throughput: 0.253702 M msg/s
            UDS  throughput: 1.733874 M msg/s
            PIPE throughput: 1.682796 M msg/s

### [Install `psql` @ Ubuntu](https://www.postgresql.org/docs/10/app-psql.html)  

```bash
$ sudo apt install postgresql-client-common
$ sudo apt install postgresql-client-10
```
### Connect using `psql`

```bash
# Connect as root using `psql` utility
$ sudo -U postgres psql
postgres=#
# as root, set user/creds 
ALTER USER postgres WITH PASSWORD 'foobar';
# Henceforth, login ...
$ psql -U postgres -h localhost
\q  # to exit 
```
## [@ Docker](https://hub.docker.com/_/postgres "hub.docker.com :: postgres")

### Run a Postgres server container 

```bash
$ docker run -d -p 5432:5432 --name 'db' \
    -e POSTGRES_PASSWORD=$dbpw postgres
```

### Access the server

```bash
$ psql -h localhost -p 5432 -U ${POSTGRES_USER} 
Password for user postgres:
...
postgres=#
```

### Access the server container, per shell

```bash
$ docker exec -it $CNTNR_ID bash -c "psql -U postgres"
psql (11.2 (Debian 11.2-1.pgdg90+1))
Type "help" for help.

postgres=#
```

### ... same, but in stages 

```bash
# Access the running Postgres container per its ID
$ docker exec -it $CNTNR_ID bash 
root@b39a615060bc:/#
``` 

- Therein, connect using [Postgres client CLI utility (`psql`)](https://www.postgresql.org/docs/10/app-psql.html) 

    ```bash
    # @ Username: "postgres"
    $ psql -U postgres
    psql (11.2 (Debian 11.2-1.pgdg90+1))
    ...
    postgres=#
    \q  # to exit
    ```

    ```bash
    \c postgres
    \l
                                     List of databases
       Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
    -----------+----------+----------+------------+------------+-----------------------
     postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
     template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres
     template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres

    # ... this is the baseline state of a virgin PostgreSQL server
    ```

    - If no database exists @ startup, then PostgreSQL creates this default database.

## [PostgreSQL + adminer @ `docker stack` or `docker-compose`](https://hub.docker.com/_/postgres "hub.docker.com :: postgres")  

```bash
docker stack deploy -c 'postgres.stack.yml' 'postgres' 
# or 
docker-compose -f 'postgres.stack.yml' up
docker-compose -f 'postgres.stack.yml' down -v  # delete volume(s) too
```

- [(`postgres.pgadminer.yml`)](postgres.pgadminer.yml)

- GUI amin [@: `http://localhost:8080`](http://localhost:8080)  
    user: postgres  
    pass: example  
    db: postgres  

- CLI @ `psql`, inside the container:

    ```bash
    $ docker exec -it 'database_db_1' bash
    root@e70e81c53d80:/# psql -U postgres
    ```

## [pgAdmin @ Docker](https://hub.docker.com/r/dpage/pgadmin4 "hub.docker.com :: dpage/pgadmin4") 

```bash
docker run -p 8080:80  \
    -e "PGADMIN_DEFAULT_EMAIL=user@domain.com" \
    -e "PGADMIN_DEFAULT_PASSWORD=SuperSecret" \
    --name 'pgadmin' \
    -d dpage/pgadmin4
```

## PostgreSQL + pgAdmin @ `docker stack` or `docker-compose` 

- [(`postgres.pgadmin4.yml`)](postgres.pgadmin4.yml)  
- GUI amin [@: `http://localhost:8080`](http://localhost:8080)  

    ```
    user: user@domain.com  
    pass: SuperSecret  
    ```
    
- CLI @ `psql`, inside the container:  

    ```bash
    $ docker exec -it 'database_db_1' bash
    root@e70e81c53d80:/# psql -U postgres
    ```

### &nbsp;

<!-- 

# Bookmark

- Reference
[Foo](#foo)
- Target
<a name="foo"></a>

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->

