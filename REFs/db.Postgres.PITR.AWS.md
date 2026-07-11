# PITR backup/recover of PostgreSQL on EC2/EBS

## Overview 

PostgreSQL Point-in-Time Recovery (PITR) cannot be achieved solely via Amazon EBS snapshots.  
While Amazon EBS snapshots are stored internally on Amazon S3, they are only block-level, point-in-time images. 

To achieve a true PITR (restoring to an exact second or specific transaction), 
you must combine a Base Backup with continuous Write-Ahead Log (WAL) archiving. 
The technical breakdown of how these components interact on EC2 explains why snapshots alone are not enough, along with how to properly implement PITR. 

## Why EBS Snapshots Alone Fail at PITR 

- Snapshot Limitations: An EBS snapshot restores the volume to the exact minute the snapshot was completed. It cannot reconstruct changes that occurred between snapshots (e.g., 20 minutes after your last snapshot). 
- Crash-Consistency: If you take an EBS snapshot while PostgreSQL is running, it creates a "crash-consistent" backup. When restored, PostgreSQL treats it like a server recovery from a sudden power outage and replays whatever data happens to be in its local WAL files. [10, 11, 12]  

## How to Correctly Architect PITR on EC2 

To successfully perform PITR, you need two distinct backup streams: 


        [ Continuous WAL Archiving ] ----------> Shipped to S3 Bucket (Every few minutes)
                                                    +
        [ Base Backup (EBS Snapshot) ] --------> Stored in S3 (Daily/Weekly)
                                                    =
                                        Allows Exact Point-in-Time Restore
                                        
1. The **Base Backup** (Can use EBS Snapshots): You can use an EBS snapshot as your starting base backup instead of running a heavy `pg_basebackup` command. To do this safely, you must signal PostgreSQL by issuing `SELECT pg_log_wal_start()` (or use tools that automate file-system freezing), initialize the  Amazon EBS Snapshot, and then run `SELECT pg_log_wal_stop();`. 
2. The **Continuous WAL Stream** (Requires S3): You must configure PostgreSQL’s `archive_command` in your `postgresql.conf` file to continuously copy completed WAL segments directly to a user-managed Amazon S3 bucket. [15, 16, 17]  

### The PITR Restore Process 

When a failure occurs and you need to restore to a specific timestamp, the process requires mixing both AWS and PostgreSQL tools: 

1. **Provision New Storage**: Create a new EBS volume from your chosen base EBS Snapshot and attach it to your EC2 instance. 
2. **Configure Recovery**: Create a `recovery.signal` file in your PostgreSQL `data` directory. 
3. **Point to WALs**: Configure the `restore_command` in your `postgresql.conf` to pull the archived WAL files down from your Amazon S3 bucket. 
4. **Set Target Time**: Define your exact target time using `recovery_target_time = 'YYYY-MM-DD HH:MM:SS'`. 
5. **Start PostgreSQL**: Start the engine. PostgreSQL will read the base data from the snapshot and sequentially play back the WAL logs from S3 up until your target second, successfully completing PITR. [3, 15, 18, 19, 20]  

### Recommended Automation Tools 

Managing this manually with custom bash scripts can be error-prone. Production environments running PostgreSQL on EC2 typically use dedicated backup utilities to manage both base backups and S3 WAL streaming natively: 

- **`pgBackRest`**: Highly optimized for S3. It handles throttling, multi-threaded backup/restore, and seamless WAL streaming. 
- **PgBarman**: An enterprise backup tool that natively supports cloud storage targets and automates PITR retention policies. [5, 15, 21, 22]  


[1] https://simplyblock.io/blog/point-in-time-recovery-for-postgresql-on-kubernetes/
[2] https://docs.aws.amazon.com/whitepapers/latest/optimizing-postgresql-on-ec2-using-ebs/postgresql-backups.html
[3] https://n2ws.com/blog/aws-sql-server-backup/how-to-backup-your-aws-cloud-based-postgresql-database
[4] https://docs.aws.amazon.com/whitepapers/latest/optimizing-postgresql-on-ec2-using-ebs/ebs-volume-features.html
[5] https://dev.to/mohhddhassan/postgresql-backups-and-point-in-time-recovery-with-pgbackrest-13gp
[6] https://docs.aws.amazon.com/ebs/latest/userguide/ebs-snapshots.html
[7] https://aws.amazon.com/blogs/modernizing-with-aws/automating-sql-server-point-in-time-recovery-using-ebs-snapshots/
[8] https://docs.aws.amazon.com/prescriptive-guidance/latest/backup-recovery/restore.html
[9] https://serverfault.com/questions/914362/amazon-aws-export-ebs-snapshot-to-external-storage
[10] https://aws.amazon.com/blogs/database/improving-oracle-backup-and-recovery-performance-with-amazon-ebs-multi-volume-crash-consistent-snapshots/
[11] https://stackoverflow.com/questions/2997969/postgresql-and-amazon-ebs-snapshots
[12] https://n2ws.com/blog/aws-ebs-snapshot/aws-ebs-snapshots-all-you-need-to-know
[13] https://dev.to/beefedai/incremental-forever-backup-architecture-for-postgresql-569e
[14] https://dba.stackexchange.com/questions/68461/postgresql-continuous-archiving-use-snapshot-for-base-backup-on-aws
[15] https://stackoverflow.com/questions/21621894/backup-postgresql-database-hosted-on-aws-ec2-without-shutting-down-or-restarting
[16] https://severalnines.com/blog/tips-storing-postgresql-backups-amazon-aws/
[17] https://dev.to/cmucheru/postgres-data-backup-with-continuous-archiving-and-point-in-time-recovery-5ech
[18] https://community.spiceworks.com/t/how-to-restore-your-aws-ec2-instance-from-a-snapshot/1012645
[19] https://www.postgresql.org/docs/current/continuous-archiving.html
[20] https://support.purestorage.com/bundle/m_postgresql/page/Solutions/PostgreSQL/Data_Protection_and_Copy_Data_Management/topics/task/t_point_in_time_recovery_with_continuous_archiving.html
[21] https://www.dbi-services.com/blog/using-pgbackrest-to-backup-your-postgresql-instances-to-a-s3-compatible-storage/
[22] https://www.percona.com/blog/postgresql-backup-strategy-enterprise-grade-environment/




---

<!-- 

… ⋮ ︙ - ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
☢ ☣ ☠ ¦ ¶ § † ‡ ß µ Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 🡸 🡺 ➔
ℹ️ ⚠️ ✅ ⌛ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🥇 ✨️ 🔚

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# README HyperLink

README ([MD](__PATH__/README.md)|[HTML](__PATH__/README.html)) 

# Bookmark

- Target
<a name="foo"></a>

- Reference
[Foo](#foo)

-->
