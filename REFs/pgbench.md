# [`pgbench` :: PostgreSQL benchmarking](https://www.postgresql.org/docs/current/pgbench.html "postgresql.org")

```bash
su - postgres  # switch to 'postgres' user (@ alpine)
```

```bash 
psql -c 'SHOW config_file'
psql -c 'SELECT version();'     # version of SERVER (postgres daemon)
psql --version                  # version of CLIENT (psql) 
# Initialize @ postgres db
pgbench -i -p 5432 postgres
#...
# Test SQL @ bench.sql, @ postgres db, w/ 10 clients, for 3 seconds
pgbench -c 10 -T 3 -f bench.sql postgres
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

