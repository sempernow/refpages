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

---

# `pgbench` Basics

You can use pgbench to isolate and target a single, specific SQL query. By passing a custom .sql file using the -f flag and enabling the latency report flag (-r), pgbench will measure the exact response time and latency breakdown for just your targeted query under load. [1, 2, 3] 

## Step-by-Step Guide to Benchmark a Specific Query## 1. Save Your Query to a File

Create a text file containing the exact SQL query you want to optimize. [3] 

# Save this file as `my_query.sql`

```sql
SELECT user_id, COUNT(*) 
FROM orders 
WHERE status = 'pending' 
GROUP BY user_id;
```

## 2. Run pgbench targeting the File [4] 

Execute pgbench against your production or staging database using the following precise configuration flags: [2] 

```bash
pgbench -f my_query.sql -n -c 5 -j 2 -t 500 -r my_database
```

What these specific flags do for query-level testing:

* `-f my_query.sql`: Bypasses the built-in TPC-B test and forces pgbench to only execute the query inside your file.
* `-n`: Skips the automatic VACUUM process that pgbench tries to run by default on its native benchmark tables.
* `-c 5` and `-j 2`: Simulates 5 concurrent application users across 2 threads hitting this exact query simultaneously.
* `-t 500`: Runs the query 500 times per client (yielding 2,500 total executions for a reliable statistical average).
* `-r` (Crucial): Stands for "report latencies". It instructs pgbench to calculate and output the exact statement-by-statement average execution response time. [1, 2, 5, 6, 7] 

## Understanding the Output

When the run finishes, the `-r` flag appends a statement latency breakdown to the bottom of the standard summary: [5] 

```plaintext
...
number of transactions actually processed: 2500/2500
latency average = 14.210 ms
tps = 351.864910 (without initial connection time)

Statement latencies:
  14.185 ms  SELECT user_id, COUNT(*) FROM orders WHERE status = 'pending'...
```


* latency average: Tells you the global average response time of the entire script file execution.
* Statement latencies: Pinpoints exactly how many milliseconds your specific SQL statement took to respond on average across those 2,500 stress-test runs. [5, 8] 

## Alternative: Dynamic Variables (Simulating Production Realism)

If running the exact same query creates unrealistically fast speeds due to database caching, you can pass random parameters to your target query file using pgbench scripting syntax: [6] 

```sql
-- Modified my_query.sql
\setrandom customer_id 1 100000SELECT * FROM orders WHERE user_id = :customer_id;
```

[1] [https://andyatkinson.com](https://andyatkinson.com/blog/2021/08/10/pgbench-workload-simulation)
[2] [https://neon.com](https://neon.com/blog/autoscaling-in-action-postgres-load-testing-with-pgbench)
[3] [https://www.tangramvision.com](https://www.tangramvision.com/blog/how-to-benchmark-postgresql-queries-well)
[4] [https://www.tangramvision.com](https://www.tangramvision.com/blog/how-to-benchmark-postgresql-queries-well)
[5] [https://dev.to](https://dev.to/aws-heroes/custom-sql-scripts-in-pgbench-502i)
[6] [https://gist.github.com](https://gist.github.com/artemik/3e26ac09208b8d215b421c7221a4ae48)
[7] [https://www.dbi-services.com](https://www.dbi-services.com/blog/ysql_bench/)
[8] [https://www.postgresql.org](https://www.postgresql.org/docs/current/pgbench.html)
[9] [https://vela.simplyblock.io](https://vela.simplyblock.io/articles/best-open-source-postgresql-performance-tuning-tools/)
[10] [https://dba.stackexchange.com](https://dba.stackexchange.com/questions/42012/how-can-i-benchmark-a-postgresql-query)


---

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

