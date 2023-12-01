# Redis (REmote DIctionary Server)

## [Redis Docs](https://redis.io/documentation "redis.io/documentation")  | [Modules](https://redis.io/modules "redis.io/modules") | [Wiki](https://en.wikipedia.org/wiki/Redis "Wikipedia") | [Example: Twitter Clone](https://redis.io/topics/twitter-clone)

>Redis clients communicate with the Redis server using [RESP](https://redis.io/topics/protocol "redis.io") (_REdis Serialization Protocol_) @ `TCP:6379`. It's a [Request/Response model](https://redis.io/topics/protocol#request-response-model). The protocol is very human readable and easy to implement, yet can be implemented with a performance similar to that of a binary protocol.

- Distributed, __in-memory datastore__, __cache__ &amp; __msg broker__  
100K `SET`/second; 80K `GET`/second
    - key-value (NoSQL) database; many [data types](https://redis.io/topics/data-types "redis.io/topics/data-types") 
    - [Lua scripting](https://redis.io/commands/eval)
    - <abbr title="Least Recently Used">LRU</abbr> [cache](https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_recently_used_(LRU) "Wikipedia :: Cache Replacement Policies"), with settable [eviction policies](https://redis.io/topics/lru-cache)
- [Pipelining](https://redis.io/topics/pipelining "redis.io/topics/pipelining")  multiple commands per request; performant (`5x`) queries
- [Pub/Sub messaging](https://redis.io/topics/pubsub "redis.io/topics/pubsub")  
- [Streams](https://redis.io/topics/streams-intro "redis.io/topics/streams-intro"); log (append-only) data structure model, but allows for complex/blocking ops; consumers wait for new data; (Kafka) Consumer Groups; client groups cooperate in consuming a different portion of the same stream of messages.
- [Transactions](https://redis.io/topics/transactions)
- Atomic high-level ops; intersection/union/difference between `sets`; sorting of `lists` and `sets`.   
- [Persistence](https://redis.io/topics/persistence "redis.io/topics/persistence") 
    - RDB persistence performs point-in-time snapshots; very compact,  single-file representation; perfect for backups.
    - <abbr title="Append Only File">AOF</abbr> persistence logs every write op received by server; 
- [HA; Clustering; Replication (master-replica)](https://redislabs.com/redis-features/high-availability "High Availability / Redis Sentinel / Redis Cluster"); read-scalability 
- Modules 
    - [ReJSON](https://oss.redislabs.com/redisjson/); a JSON data type for Redis; allows storing, updating and fetching JSON values from Redis keys (documents); JSONPath-like syntax.

>Unusual data model; commands do not describe a query, but rather specific operations to perform on data types, hence data must be identifiable by primary index alone (no secondary index). Yet can implement RDB on top of key-value store. [E.g.](https://redis.io/topics/twitter-clone#data-layout "Twitter Clone Demo/Tutorial 2014 @ Redis.io"), store users per `user`, and have `users` track the user-id key:

    INCR next_user_id => 1000
    HMSET user:1000 username foo password 1234
    HSET users foo 1000


## Install @ Ubuntu ([per download](https://redis.io/download "redis.io/download")) 

```bash 
# Redis server + client
$ sudo apt-get install redis-server # installed v.4
```
- [Redis config](https://redis.io/topics/config "redis.io") @ `/etc/redis/redis.conf`

## [Redis @ Docker](https://hub.docker.com/_/redis "hub.docker.com") 

```bash
dokcer run --rm --name 'rds' -d -p 6379:6379 redis
docker exec -it 'rds' redis-cli
```

@ Swarm service (`app_rds`), task `1`, node `h3` (`f0pd8lcif0m433yp6h0iqpgzp`)

```bash  
_CTNR='app_rds.1.f0pd8lcif0m433yp6h0iqpgzp'
docker-machine ssh h3 "docker exec -it $_CTNR redis-cli"
```

##### [`redis.conf`](redis.conf) | [Optimizing](https://blog.opstree.com/2019/04/16/redis-best-practices-and-performance-tuning/)

```plaintext
tcp-backlog 511
#... @ boot2docker :: cat /proc/sys/net/core/somaxconn => 128
#...                  cat /proc/sys/net/ipv4/tcp_max_syn_backlog => 128
```

## Start/Connect 

```bash
# Start Redis server; pass args
$ redis-server --port 6380 --slaveof 127.0.0.1 6379
```

```bash
# Start Redis server as bkgnd proc
$ redis-server &  # ... prints startup msgs 
# Connect per Redis CLI
$ redis-cli
127.0.0.1:6379> QUIT # to exit
```

- [Clients per language](https://redis.io/clients "redis.io/clients"), aside from the native (`redis-cli`).

## [Commands](https://redis.io/commands "redis.io/commands") per [Data Type](https://redis.io/topics/data-types "redis.io/topics/data-types")

#### @ Strings ([commands](https://redis.io/commands/#string))

- _Binary-safe_; any kind of (blob) data; JPEG, serialized objects; up to `512 MB` per string  
- [Bitmaps](https://redis.io/topics/data-types-intro#bitmaps) included; bit-oriented __operations__ _defined on String data type_. 

```bash 
SET foo 100   # (integer) 100
INCR foo      # (integer) 101
DECR foo      # (integer) 100
GET foo       # "100"
GET bogus     # (nil)
EXISTS foo    # (integer) 1
EXISTS bogus  # (integer) 0
DEL foo       # (integer) 1
EXPIRE foo 5  # (integer) 1 ; DEL in 5 seconds
SETEX foo 5 bar # SET+EXPIRE; "bar" DELs in 5 sec
TTL foo       # (integer) 2 ; seconds remaining
PERSIST foo   # Undo prior EXPIRE|SETEX
FLUSHALL      # OK
CLEAR         # clear terminal

SET foo:bar baz  # ... namespaces
SET foo 100
GET foo       # "100"
GET foo:bar   # "baz"

# SET MULTIPLE VALUEs
MSET foo "hello" bar "you"
APPEND foo " world"
GET foo       # "hello world"
GET bar       # "you"
RENAME foo foo2
GET foo2      # "hello world"
GET foo       # (nil)

# BITs
SETBIT key offset val  # allocates, per offset, if not exist
SETBIT foo 3 0  # set 3rd bit of foo to 0  
GET foo         # "\x00", OR its Unicode equiv rune

GETBIT key offset 
GETBIT foo 3    # 0
```
- Use as Atomic counters 
- For Appending / Encoding / [Bloom Filter](https://en.wikipedia.org/wiki/Bloom_filter "wiki/Bloom_filter")

#### @ Lists ([commands](https://redis.io/commands/#list))

- Ordered set of strings (sorted by _insertion order_); up to `4` billion (`2`<sup>`32`</sup>`-1`) __elements__ per list.
- Push/Pop ; Left/Right ; Head/Tail

```bash
LPUSH foo a   # (integer) 1; "a"
LPUSH foo b   # (integer) 2; "b","a"
RPUSH foo c   # (integer) 3; "b","a","c"
LLEN foo      # (integer) 3; list length
LRANGE foo 0 -1  # `-1` = to the end element
1) "b"
2) "a"
3) "c"
LRANGE foo 1 -1
1) "a"
2) "c"
LRANGE foo 0 1
1) "b"
2) "a"

LPOP foo     # "b"; removes left-most element 
RPOP foo     # "c"; removes right-most element
LRANGE foo 1 -1 
1) "a"

LPUSH foo a
LPUSH foo b
LPUSH foo c

LINSERT foo BEFORE "b" "bar"
LRANGE foo 0 -1
1) "c"
2) "bar"
3) "b"
4) "a"

RPOPLPUSH src dst  # right-most @ src moved to left-most @ dst
RPOPLPUSH foo foo  # circle, moving tail el to head
BRPOPLPUSH src dst timeout  # blocking variant

# Add el(s) but maintain size
LPUSH foo new
LTRIM foo 0 9  # limits size to 10 els; #0-9
```
- Model a timeline in a social network
- Use as a message passing primitive
- Blocking lists; wait for a key to get new elements to fetch

#### @ Sets ([commands](https://redis.io/commands/#set))

- Unordered collection of _unique_ Strings; up to `4` billion (`2`<sup>`32`</sup>`-1`) __members__ per list.
- Constant time to add, remove, or test member exist 
- Native commands for _union_, _intersection_, and _difference_

```bash
SADD foo bar       # add member bar to set foo
SMEMBERS foo       # list all members
SCARD foo          # cardinality; the # of members 
SISMEMBER foo baz  # test member baz exist (1|0) in set foo
SMOVE foo bar baz  # move member baz from set foo to set bar
SREM foo baz       # remove member baz from set foo

SINTER k1 [k2 ...] # Rtn INTERsection of sets
SDIFF k1 [k2 ...]  # Rtn DIFFerence between sets.

# @ one or more (count) RANDOM members from set
SPOP k1 [count]        # remove + return member(s)
SRANDMEMBER k1 [count] # return member(s)
```

- Track unique things, e.g., IP addresses per `SADD`
- Represent relations; create a tagging system; add all the IDs of all the objects having a given tag using `SADD`; get all IDs of all objects having multiple tags using `SINTER`.
- Extract elements at random using the `SPOP` or `SRANDMEMBER`.

#### @ Sorted Sets ([commands](https://redis.io/commands#sorted_set))

- Ordered collection of _unique_ Strings; ordered per member-associated __score__, from __low to high__.  
- Log time, O(log(n)), to add, remove, or update; very fast access 


```bash
 ZADD key [NX|XX] [CH] [INCR] score member [score member ...] 

    XX  # Update only. Never add elements.  
    NX  # Always add. Don't update if exist.   
    CH  # Changed; new elements and existing elements if score changed.

ZADD users 1980 "Joe"
(integer) 1
ZADD users 1980 "Sam"
(integer) 1
ZADD users 1983 "Sally"
(integer) 1
ZADD users 1977 "Oldman"
(integer) 1

ZRANK users Oldman  # returns rank; scores sorted low to high
(integer) 0
ZRANK users Sally
(integer) 3

ZRANGE users 0 -1
1) "Oldman"
2) "Joe"
3) "Sam"
4) "Sally"

ZRANGE users 0 -1 WITHSCORES
1) "Oldman"
2) "1977"
3) "Joe"
4) "1980"
5) "Sam"
6) "1980"
7) "Sally"
8) "1983"
```

- __Leader board__ in a massive online game; new scores updated using `ZADD`; top users using `ZRANGE`; given an user name, return __rank__ in listing using `ZRANK`; show users with a score similar to a given user using `ZRANK` and `ZRANGE` together.

- Index data such as users; with age as score and ID as value, so can retrieve all users across a range of ages using `ZRANGEBYSCORE`.

#### @ Hashes ([commands](https://redis.io/commands#hash))
- Maps (assoc. arrays) between _string_ fields and _string_ values; perfect data type for working with live (not-serialized) objects; `{k1: {k11: v11, k12: v12, ...}, k2: {...}, ...}` 

```bash
HMSET user:1000 uname foo pass bAr age 44
HGETALL user:1000
1) "uname"
2) "foo"
3) "pass"
4) "bAr"
5) "age"
6) "44"
HSET user:1000 pass 12345
HGET user:1000 pass
"12345"
```

#### @ [Streams](https://redis.io/topics/streams-intro "redis.io/topics/streams-intro") ([commands](https://redis.io/commands#stream)) 

- _Messaging system_ & _time-series store_; @ Redis 5.0+ .

- Log (time-series; append-only) data structure model, but _allows for complex/blocking ops_; consumers wait for new data; (Kafka) _Consumer Groups_;  client groups cooperate in consuming a different portion of the same stream of messages.

- Each  __entry__ (__item__) is composed of one or multiple time-ordered field-value pairs; so structured, a sort of append-only CSV-formatted file; multiple fields per line. 

- @ auto-generated ID, "`*`", `<msecTime>-<seqNumber>`; local __Unix-time__ @ local Redis node generating the stream ID, as long as current `msecTime` is larger than previous entry, else previous entry used instead; so, if a clock jumps backward, then the monotonically incrementing ID property still holds. The `seqNumber` is used for entries created @ same `msecTime`. 
    - The `msecTime` part of the ID facilitates nearly free __range queries__ by ID (time), per `XRANGE`.  

Add [(`XADD`)](https://redis.io/commands/xadd) and Query [(`XRANGE`)](https://redis.io/commands/xrange)

```bash
# Add entries
XADD key ID field string [field string ...] 
XADD strm * sensor-id 1234 temp 19.8 # `*` to auto-generate ID (time-series)
XADD strm * sensor-id 7777 temp 16.3

XLEN strm  # stream length; number of entries

# Query entries; access items over a range
XRANGE key start end [COUNT n]  # COUNT for 1st n items only
XRANGE strm - +  # `-/+` is min/max ID (time) of stream @ key "strm"
1) 1) "1555877533372-0"
   2) 1) "sensor-id"
      2) "1234"
      3) "temp"
      4) "19.8"
2) 1) "1555879971871-0"
   2) 1) "sensor-id"
      2) "7777"
      3) "temp"
      4) "16.3"

XRANGE strm 1555879971800 +
1) 1) "1555879971871-0"
   2) 1) "sensor-id"
      2) "7777"
      3) "temp"
      4) "16.3"
```

- Each entry returned is an array of two items: ID &amp; list of field-value pairs.  
- `XRANGE` query complexity is `O(log(N))` to seek; `O(M)` to return M elements. 

Listening [(`XREAD`)](https://redis.io/commands/xread) for new items

```bash
# Subscribe to new items arriving to the stream
XREAD [COUNT n] [BLOCK msec] STREAMS key [key ...] ID [ID ...] 
XREAD STREAMS strm 1555879971870 # all GREATER than ID 
1) 1) "strm"
   2) 1) 1) "1555879971871-0"
         2) 1) "sensor-id"
            2) "7777"
            3) "temp"
            4) "16.3"
XREAD STREAMS strm $  # NEW only; since listening started
(nil)
```
- Read data from one or multiple streams, only returning entries with an ID __greater__ than last received ID (arg) reported by caller. This command has an option to block if items are not available, in a similar fashion to `BRPOP` or `BZPOPMIN` and others.


- A stream can have multiple clients (consumers) waiting for data. Every new item, by default, will be delivered to every consumer that is waiting for data in a given stream; this differs from __blocking lists__, where _each consumer will get a different element_; ability to fan out to multiple consumers is _similar to Pub/Sub_.

- While in Pub/Sub messages are fire and forget and are never stored anyway; blocking list messages are popped from the list when received by the client; streams work in a fundamentally different way. 

- All the messages are appended in the stream indefinitely (unless the user explicitly asks to delete entries): consumers  know what is a __new__ message to it by remembering ID of their last received message.

- Streams __Consumer Groups__ provide a level of control that Pub/Sub or blocking lists cannot achieve; different groups for same stream, explicit acknowledge of processed items, ability to inspect the pending items, claiming of unprocessed messages, and coherent history visibility for each single client, that is only able to see its private past history of messages.

[Consumer Groups](https://redis.io/topics/streams-intro#consumer-groups)  

```bash
 XREADGROUP GROUP group consumer [COUNT n] [BLOCK msec] [NOACK] STREAMS key [key ...] ID [ID ...] 

# Create consumer group
XGROUP CREATE strm grp1 $

# Add entries
XADD strm * msg apple
XADD strm * msg orange
XADD strm * msg strawberry
XADD strm * msg apricot
XADD strm * msg banana

# Read from stream using group grp1; consumer Alice. 
# ">"; returns only new msgs never delivered to other consumers so far
XREADGROUP GROUP grp1 Alice COUNT 1 STREAMS strm > 
1) 1) "strm"
   2) 1) 1) "1555885532198-0"
         2) 1) "msg"
            2) "apple"

# Acknowledge msg(s); REMOVEs msg(s)
XACK key group ID [ID ...] 

XACK strm grp1 1555885532198-0
(integer) 1
XREADGROUP GROUP grp1 Alice COUNT 1 STREAMS strm 0
1) 1) "strm"
   2) (empty list or set)

XREADGROUP GROUP grp1 Alice COUNT 1 STREAMS strm1 > 
(nil)
```

#### [Pipelining](https://redis.io/topics/pipelining "redis.io/topics/pipelining") 

- Multiple commands per request; performant (`5x`) queries; demonstrated here with the native Redis client/CLI or `nc` (Netcat):   
    - `(printf "...") | redis-cli --pipe`
    - `(printf "...") | nc localhost 6379`

```bash
# per `redis-cli --pipe`
$ (printf "PING\r\nPING\r\nPING\r\n") | redis-cli --pipe
All data transferred. Waiting for the last reply...
Last reply received from server.
errors: 0, replies: 3 
# ... the client returns only a summary report, and STDERR

# per Netcat
$ (printf "PING\r\nPING\r\nPING\r\n") | nc localhost 6379
+PONG
+PONG
+PONG
^C  # manually exit

# Scripting (Lua) per pipeline; SET/GET
$ (printf "eval \"return redis.call('set','foo','bar')\" 0\r\n") | nc localhost 6379
$ (printf "eval \"return redis.call('get','foo')\" 0\r\n") | nc localhost 6379
$3
bar
^C  # manually exit
```

#### Pipelining a file containing many Redis statements:  

Use to __insert__ a __large amount of data__; starting with a `DATA_SERIES` _file_ of many `key`/`val` pairs, prepend "`SET` " to each line:

```bash
$ awk '{print "SET " $0}' DATA_SERIES > 'data.txt'
```

- So, `data.txt` is an ASCII file containing the "`SET key val`" commands:  

    ```
    SET Key0 Val0
    SET Key1 Val1
    ...
    SET KeyN ValN
    ```
Then, enter the data into Redis:

```bash
# Pipelining a file containing many Redis statements
cat 'data.txt' | redis-cli --pipe
```

- Pipelining is much faster than a series of individual statements.



### &nbsp;
<!--  
# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->

