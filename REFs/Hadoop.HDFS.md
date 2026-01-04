# [Apache Hadoop](https://hadoop.apache.org/ "Hadoop.Apache.org")


## Hadoop ecosystem:

- Hadoop Distributed File System (**HDFS**): This is the primary storage system used by Hadoop applications. It is a distributed file system designed to run on commodity hardware. HDFS provides high throughput access to application data and is designed to be highly fault-tolerant.
- **MapReduce**: This is a programming model and processing technique for distributed computing. It allows for massive scalability across hundreds or thousands of servers in a Hadoop cluster. MapReduce processes large data sets by breaking the work into a set of independent tasks, making it an essential part of data processing in the Hadoop ecosystem.
- **YARN** (Yet Another Resource Negotiator): YARN is a **resource management layer** for the Hadoop ecosystem. It manages computing resources in clusters and uses them for scheduling users' applications. YARN provides a more flexible and efficient framework than the original MapReduce for cluster resource management.
    -  [Spark](https://spark.apache.org/) and/or [Flink](https://flink.apache.org/) may run on YARN, all working together to process the same data set.
- Hadoop Common: These are the common utilities and libraries that support other Hadoop modules. Hadoop Common provides the essential services and support needed by other Hadoop components, including the filesystem and network access to Hadoop clusters.
- Other:
    - Hive: A data warehousing and SQL-like query language that allows for data summarization, query, and analysis.
    - HBase: A scalable, distributed database that supports structured data storage for large tables.
    - Pig: A high-level platform for creating MapReduce programs used with Hadoop.
    - Sqoop: A tool designed for efficiently transferring data between Hadoop and relational databases.
    - Flume: A service for efficiently collecting, aggregating, and moving large amounts of log data to HDFS.
    - Oozie: A workflow scheduler system to manage Hadoop jobs.


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

