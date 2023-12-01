# [SQLite `v3`](https://www.sqlite.org/index.html "sqlite.org") | [@Wikipedia](https://en.wikipedia.org/wiki/SQLite) 

## [JSON - Store as searchable doc](https://www.sqlite.org/gencol.html "Generated Columns @ sqlite.org") | [Article 2020/06](https://dgl.cx/2020/06/sqlite-json-support "SQLite as a Document Database")

```bash
$ sqlite3
SQLite version 3.31.1 2020-01-27 19:55:54
Connected to a transient in-memory database.

sqlite> CREATE TABLE t (
   body TEXT,
   d INT GENERATED ALWAYS AS (json_extract(body, '$.d')) VIRTUAL);

sqlite> insert into t values(json('{"d":"42"}'));

sqlite> select * from t WHERE d = 42;
{"d":"42"}|42
```

## [JSON (`k:v`) blob](https://news.ycombinator.com/item?id=19277809 "2019 news.ycombinator.com") @ [`JSON1` Extension](https://www.sqlite.org/json1.html "sqlite.org")

## [Memory-Mapped I/O](https://www.sqlite.org/mmap.html)

## [Optimizations (+Android API)](https://www.whoishostingthis.com/compare/sqlite/optimize/ "whoishostingthis.com")

- Use Transactions
- __Prepare__ and __Bind__
- Sync to Disk Sparingly
- Store Rollback Journal in-Memory
- Index Sparingly (After Bulk Insert)  
&vellip;

## View

A special, read-only table; a named SQL statement (and its results ???) stored as a table, especially for repeated (quicker ???) use.

```
CREATE VIEW aView AS SELECT Name FROM aTable WHERE aField < 1000;

SELECT * FROM aView;
```

- Stupid example; ___use views to combine (join) a bunch of fields from various tables___.

## [Trigger](https://www.tutorialspoint.com/sqlite/sqlite_triggers.htm "tutorialspoint.com") 

SQLite Trigger is a database _callback function_; ___automatically invoked per database event___.

```
CREATE TRIGGER mytrigger UPDATE OF Name ON Friends
BEGIN
INSERT INTO Log(OldName, NewName, Date) VALUES (old.Name, new.Name, datetime('now'));
END;
```

### [`INSTEAD OF` Trigger](https://www.sqlitetutorial.net/sqlite-instead-of-triggers/ "sqlitetutorial.net") 

A Trigger on a View, not a Table. Use to (effectively) INSERT into a View, which can't actually be done, since a View is read-only.

## Transaction 

An atomic operation; success or fail, and nothing else.

```
BEGIN TRANSACTION;
CREATE TABLE Test(Id INTEGER NOT NULL);
INSERT INTO Test VALUES(1);
INSERT INTO Test VALUES(2);
INSERT INTO Test VALUES(3);
INSERT INTO Test VALUES(NULL);
COMMIT;
```
 
 - A transaction can end with a `COMMIT` or a `ROLLBACK` statement. The `ROLLBACK` reverts all changes. 

## References

- [SQLite Views, Triggers, Transactions](http://zetcode.com/db/sqlite/viewstriggerstransactions/)
-  [A Minimalist Guide to SQLite](https://tech.marksblogg.com/sqlite3-tutorial-and-guide.html "tech.marksblogg.com 2017") (Python-centric; first, not very goo, reference.).

### @ Linux (Install) 

```bash
# Install @ Ubuntu/Debian
sudo apt install sqlite3
# Open/Create database
sqlite3 $dbname.db
```

### [@ `~/.sqliterc`](file:///c:/HOME/.sqliterc) (Config)

```
.headers on
.mode column
.nullvalue ¤
.prompt "> "
.timer on
```  

### @ `sqlite3` CLI
```sql
-- Import data of CSV file into "airports" table 
.mode csv  -- other mode: insert (SQL)
.separator ","
.import airports.csv airports 
-- Schema (show) 
.schema airports
-- Read (Import) a previously dumped database (SQL file)
.read foo.sql
-- query per SQL
SELECT ICAO, 空港 FROM airports;
```

### @ `bash` string (SQL statement) ___piped___ to `sqlite3` CLI 

```bash
# Query table per pipe (Unicode/UTF-8 supported)
echo "SELECT ICAO, 空港 FROM airports;" | sqlite3 airports.db
# Dump (Export) bar table from foo.db 
# to out.{CSV|SQL} file, per current .mode {csv|insert}
echo ".dump bar" | sqlite3 foo.db > out.sql
# Read (Import) from foo.sql file into (new) bar.db 
echo ".read foo.sql" | sqlite3 bar.db
```

## [Use as In-Memory Database](https://www.sqlite.org/inmemorydb.html "In-Memory Databases @ sqlite.org") | [PRAGMA](https://www.sqlite.org/pragma.html "PRAGMA Statements @ sqlite.org")

An SQLite database is normally stored in a single ordinary disk file; however, some embedded server scenarios benefit when the database is stored in memory.

The most common way to force an SQLite database to exist purely in memory is to open the database using the special filename "`:memory:`" instead of passing the name of a real disk file. For example: 

```
rc = sqlite3_open(":memory:", &db)
```

### In-Memory &amp; [Shared-Cache](https://www.sqlite.org/sharedcache.html "sqlite.org/sharedcache") @ [Golang (`go-sqlite3`)](https://godoc.org/github.com/mattn/go-sqlite3#SQLiteDriver.Open "godoc.org/mattn/go-sqlite3") 

>... intended for use in embedded servers. If shared-cache mode is enabled and a thread establishes __multiple connections to the same database__, the __connections share a single data and schema cache__; significantly reduces the required memory and IO. Cache can be __shared across an entire process__; `v3.5.0`+ (2007).

```golang
func (d *SQLiteDriver) Open(dsn string) (driver.Conn, error)  
```

- @ `dsn` per URI  
`file:test.db?cache=shared&mode=memory`  
    - In-Memory and Shared-Cache Mode!  

E.g., 

```golang 
db, err := sql.Open("sqlite3", "file::memory:?mode=memory&cache=shared")
```

## [SQLite Archive Files](https://www.sqlite.org/sqlar.html "sqlite.org/sqlar")

## [Appropriate Uses For SQLite](https://www.sqlite.org/whentouse.html "sqlite.org")  


&nbsp;  

<!-- 
([MD](___.html "@ browser"))   

-->