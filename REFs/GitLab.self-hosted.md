# Self-hosted [GitLab EE](https://docs.gitlab.com "docs.gitlab.com")

- [Install/Requirements](https://docs.gitlab.com/install/requirements/)
    - Performance tuning configurations of the various associated/required applications.
- [Self-host the product documentation](https://docs.gitlab.com/administration/docs_self_host/#self-host-the-product-documentation-with-gitlab-pages)
    - [Redirect `/help` links to Docs](https://docs.gitlab.com/administration/docs_self_host/#redirect-the-help-links-to-the-new-docs-site)
        - [Redirect `/help` links](https://docs.gitlab.com/administration/settings/help_page/#redirect-help-pages)
- [__Synch Repos Across Domains__](https://chatgpt.com/share/67bd002b-c7e8-8009-8427-44e4223e1481)
    - [Migrate projects and groups by using file exports](https://docs.gitlab.com/user/project/settings/import_export/)
---

# [Configuration](https://chatgpt.com/share/67b8a032-3848-8009-9622-77cb22777ea5)

# Q:

Provide sane performance tuning 
of GitLab for self-hosted __single host__ 
serving some 500 python developers.

# A:

Optimizing a **self-hosted GitLab instance** for **500 Python developers** requires careful tuning of GitLab’s services, including **Gitaly, PostgreSQL, Puma (Rails), Redis, and Workhorse**. Below is a **sane performance tuning guide** to improve responsiveness, repository operations, and overall stability for **a single-host deployment**.

---

## **1. System and Hardware Considerations**
### **Recommended Hardware for 500 Developers**
- **CPU**: 16+ cores (Preferably AMD EPYC / Intel Xeon)
- **RAM**: 64GB+ (more if hosting CI/CD on the same server)
- **Storage**: 
  - **SSD/NVMe for repositories** (`/var/opt/gitlab/git-data/repositories`)
  - **Dedicated disk for PostgreSQL** (`/var/opt/gitlab/postgresql`)
- **Network**: 10GbE recommended for high concurrency
- **OS**: RHEL 9 / Ubuntu 22.04 LTS

---

## **2. GitLab Configuration (`/etc/gitlab/gitlab.rb`)**
Run `sudo gitlab-ctl reconfigure` after making changes.

### **2.1. Puma - Optimize Web API Requests**
Puma replaces Unicorn as the default web server. Tune it for better parallel request handling.

```ruby
puma['worker_processes'] = 6  # Adjust based on CPU cores (8–12 cores = 6 workers)
puma['min_threads'] = 4
puma['max_threads'] = 16
```

### **2.2. Gitaly - Optimize Git Performance**
Gitaly is responsible for **repository operations** (clone, push, fetch).

```ruby
gitaly['concurrency'] = [
  { 'rpc' => '/gitaly.SmartHTTPService/PostUploadPack', 'max_per_repo' => 10 },
  { 'rpc' => '/gitaly.SSHService/UploadPack', 'max_per_repo' => 10 }
]
gitaly['graceful_restart_timeout'] = '30s'
gitaly['cgroups_memory_enabled'] = true
gitaly['cgroups_memory_limit'] = '4GB'
```
- [Git Smart HTTP](https://git-scm.com/book/en/v2/Git-on-the-Server-Smart-HTTP)

This setting ensures **smart HTTP and SSH Git operations** do not overload the system.

### **2.3. PostgreSQL - Optimize Database Performance**
For **large repositories and heavy API usage**, increase PostgreSQL memory and connections.

```ruby
postgresql['max_connections'] = 400
postgresql['shared_buffers'] = "16GB"
postgresql['work_mem'] = "256MB"
postgresql['maintenance_work_mem'] = "512MB"
postgresql['effective_cache_size'] = "48GB"
```

Ensure PostgreSQL runs on **NVMe SSDs**.

### **2.4. Redis - Optimize Caching**
GitLab uses Redis for caching, reducing database load.

```ruby
redis['maxmemory'] = "16GB"
redis['maxmemory_policy'] = "allkeys-lru"
```

### **2.5. Workhorse - Optimize Git HTTP Handling**
Workhorse acts as a reverse proxy for Git HTTP requests.

```ruby
gitlab_workhorse['listen_network'] = "tcp"
gitlab_workhorse['listen_addr'] = "0.0.0.0:8181"
```

This allows **faster internal request processing**.

### **2.6. Sidekiq - Optimize Background Jobs**
Sidekiq processes background jobs (issues, CI/CD triggers).

```ruby
sidekiq['concurrency'] = 20
```

This ensures background tasks don’t get **backlogged**.

---

## **3. Git Performance Tuning**
### **3.1. Optimize Git Garbage Collection**
GitLab runs periodic **Git garbage collection (GC)**, which should be optimized for **large repositories**.

Edit:
```bash
sudo -u git -H git config --global gc.auto 0
sudo -u git -H git config --global pack.threads 4
sudo -u git -H git config --global pack.windowMemory 256m
```

Then, schedule Git garbage collection **off-peak hours**:
```bash
crontab -e
```
Add:
```bash
0 2 * * * sudo gitlab-rake gitlab:cleanup:repos
```

---

## **4. Linux Kernel & System Tweaks**
### **4.1. Increase File Descriptors**
Large teams mean **high concurrent Git operations**.

Edit `/etc/security/limits.conf`:
```
gitlab    soft    nofile    1000000
gitlab    hard    nofile    1000000
```

### **4.2. Optimize TCP/IP Stack**
Edit `/etc/sysctl.conf`:
```
fs.file-max = 1000000
net.core.somaxconn = 1024
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.core.rmem_max = 8388608
net.core.wmem_max = 8388608
```
Apply with:
```bash
sudo sysctl -p
```

---

## **5. Monitoring & Troubleshooting**
### **5.1. Enable GitLab’s Embedded Prometheus Monitoring**
In `/etc/gitlab/gitlab.rb`:
```ruby
prometheus_monitoring['enable'] = true
```

Check GitLab’s built-in metrics:
```bash
sudo gitlab-ctl status
sudo gitlab-ctl tail
```

### **5.2. Check Gitaly Performance**
```bash
sudo gitlab-rake gitlab:gitaly:status
```

### **5.3. Debug PostgreSQL Slow Queries**
```bash
sudo gitlab-psql -c "SELECT * FROM pg_stat_activity WHERE state != 'idle';"
```

---

## **6. CI/CD Considerations**
For **500 Python developers**, CI/CD can overload GitLab.

- **Move CI/CD Runners to Separate Machines**
  - Use **GitLab Runner** on dedicated nodes:
    ```bash
    sudo gitlab-runner register
    ```
  - Runners should have **high CPU & RAM**.

- **Enable Cache for Python Dependencies**
  ```yaml
  cache:
    key: pip-cache
    paths:
      - .pip-cache/
  ```

---

## **7. Backup Strategy**
Configure backups in `/etc/gitlab/gitlab.rb`:
```ruby
gitlab_rails['backup_keep_time'] = 604800  # Keep backups for 7 days
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
```

Schedule daily backups:
```bash
crontab -e
```
```bash
0 3 * * * sudo gitlab-backup create
```

---

## **Final Steps**
1. **Apply Changes**:
   ```bash
   sudo gitlab-ctl reconfigure
   sudo gitlab-ctl restart
   ```
2. **Monitor Performance**:
   ```bash
   sudo gitlab-ctl status
   ```
3. **Stress Test**:
   ```bash
   url=https://gitlab.example.com/
   ab -n 1000 -c 100 $url
   ```

---

## **Summary of Key Optimizations**

| Component      | Change |
|---------------|--------|
| **CPU & RAM** | 16+ cores, 64GB+ RAM |
| **Puma** | 6 workers, 16 threads |
| **Gitaly** | Concurrency limits & memory cgroups |
| **PostgreSQL** | 400 connections, tuned memory |
| **Redis** | 16GB cache, LRU eviction |
| **Git Optimization** | Disable auto-GC, use cronjob |
| **TCP/IP Tweaks** | Reduce timeouts, increase sockets |
| **Monitoring** | Enable Prometheus, logs |

This configuration ensures **GitLab scales efficiently** 
for **500 developers** while optimizing 
**repository access, background jobs, and CI/CD workflows**. 


# Q:

Do those Puma/Gitaly/PostgreSQL/Redis/Git configurations differ from defaults of GitLab v17.x?

# A:

Yes, the configurations differ from the **default settings in GitLab v17.x** in several key ways. Below, I'll **compare the defaults vs. recommended settings** for **Puma, Gitaly, PostgreSQL, Redis, and Git**, highlighting why changes are necessary for scaling to **500 Python developers** on a **single-host GitLab instance**.

---

## **1. Puma (Web Application Server)**
### **GitLab v17.x Default:**
```ruby
puma['worker_processes'] = 2
puma['min_threads'] = 4
puma['max_threads'] = 4
```
- **Limited to 2 workers** → inefficient for high-concurrency environments.
- **Thread count (4) is low**, which may cause request queuing under load.

### **Recommended for 500 Devs:**
```ruby
puma['worker_processes'] = 6  # Scale workers based on available CPU cores
puma['min_threads'] = 4
puma['max_threads'] = 16
```
- **Why?** More **workers** allow better parallel request handling for GitLab UI/API.
- **Why?** Higher **threads** allow handling multiple concurrent requests per worker.

---

## **2. Gitaly (Git RPC Service)**
### **GitLab v17.x Default:**
```ruby
gitaly['concurrency'] = [
  { 'rpc' => '/gitaly.SmartHTTPService/PostUploadPack', 'max_per_repo' => 5 },
  { 'rpc' => '/gitaly.SSHService/UploadPack', 'max_per_repo' => 5 }
]
gitaly['graceful_restart_timeout'] = '0s'
```
- **Limits Git operations to 5 concurrent uploads per repository.**
- **No memory cgroups, so Gitaly can overconsume RAM**.

### **Recommended for 500 Devs:**
```ruby
gitaly['concurrency'] = [
  { 'rpc' => '/gitaly.SmartHTTPService/PostUploadPack', 'max_per_repo' => 10 },
  { 'rpc' => '/gitaly.SSHService/UploadPack', 'max_per_repo' => 10 }
]
gitaly['graceful_restart_timeout'] = '30s'
gitaly['cgroups_memory_enabled'] = true
gitaly['cgroups_memory_limit'] = '4GB'
```
- **Why?** Increase **concurrent Git upload handling** for large teams.
- **Why?** Memory cgroups prevent **Gitaly from consuming too much RAM**.

---

## **3. PostgreSQL (Database)**
### **GitLab v17.x Default:**
```ruby
postgresql['max_connections'] = 200
postgresql['shared_buffers'] = "256MB"
postgresql['work_mem'] = "4MB"
postgresql['maintenance_work_mem'] = "64MB"
postgresql['effective_cache_size'] = "4GB"
```
- **Only 200 connections** → **insufficient for 500 developers** using GitLab UI/API.
- **Low cache and memory allocation** → Slower queries under heavy load.

### **Recommended for 500 Devs:**
```ruby
postgresql['max_connections'] = 400
postgresql['shared_buffers'] = "16GB"
postgresql['work_mem'] = "256MB"
postgresql['maintenance_work_mem'] = "512MB"
postgresql['effective_cache_size'] = "48GB"
```
- **Why?** Increase max connections to **400** to handle **API calls and web UI requests**.
- **Why?** Higher `shared_buffers` allows caching **more query results in RAM**.

---

## **4. Redis (Caching Service)**
### **GitLab v17.x Default:**
```ruby
redis['maxmemory'] = "0"  # Unlimited
redis['maxmemory_policy'] = "noeviction"
```
- **Unlimited Redis memory usage** can cause **Out-of-Memory (OOM) issues**.
- **No eviction policy**, meaning Redis will refuse new writes when full.

### **Recommended for 500 Devs:**
```ruby
redis['maxmemory'] = "16GB"
redis['maxmemory_policy'] = "allkeys-lru"
```
- **Why?** Set a **16GB cache limit** to prevent Redis from consuming all system RAM.
- **Why?** Use **Least Recently Used (LRU) eviction** to remove old cache entries.

---

## **5. Git Configuration (Garbage Collection & Packing)**
### **GitLab v17.x Default:**
```bash
git config --global gc.auto 1
git config --global pack.threads 1
```
- **Git automatically runs garbage collection (`gc.auto 1`)**, which is inefficient for large repos.
- **Packing operations (`pack.threads 1`) use a single thread**, slowing down large repository maintenance.

### **Recommended for 500 Devs:**
```bash
sudo -u git -H git config --global gc.auto 0
sudo -u git -H git config --global pack.threads 4
sudo -u git -H git config --global pack.windowMemory 256m
```
- **Why?** Disable auto-GC and **run it via cron at off-peak hours**.
- **Why?** Use **4 threads for packing**, improving performance for large repos.

---

## **6. Workhorse (Git HTTP Proxy)**
### **GitLab v17.x Default:**
```ruby
gitlab_workhorse['listen_network'] = "unix"
gitlab_workhorse['listen_addr'] = "/var/opt/gitlab/gitlab-workhorse/socket"
```
- Uses **Unix sockets**, which are fine for low-traffic environments but **may not scale well** under high load.

### **Recommended for 500 Devs:**
```ruby
gitlab_workhorse['listen_network'] = "tcp"
gitlab_workhorse['listen_addr'] = "0.0.0.0:8181"
```
- **Why?** Switch to **TCP sockets** for better **network concurrency** under load.

---

## **7. Sidekiq (Background Job Processing)**
### **GitLab v17.x Default:**
```ruby
sidekiq['concurrency'] = 5
```
- **Only 5 workers**, causing backlogs in notifications, CI/CD triggers, etc.

### **Recommended for 500 Devs:**
```ruby
sidekiq['concurrency'] = 20
```
- **Why?** Increases **background job throughput** for faster task processing.

---

## **8. TCP/IP Kernel Tweaks**
### **GitLab v17.x Default:**
- Defaults to **generic kernel networking settings**, which can be suboptimal for heavy concurrent traffic.

### **Recommended for 500 Devs (`/etc/sysctl.conf`)**
```bash
fs.file-max = 1000000
net.core.somaxconn = 1024
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.core.rmem_max = 8388608
net.core.wmem_max = 8388608
```
- **Why?** **Reduce connection wait times** and **increase socket buffers** for high-concurrency Git operations.

---

## **Summary of Key Differences**
| Component | **GitLab v17.x Default** | **Optimized for 500 Devs** |
|-----------|-----------------|-----------------|
| **Puma** | 2 workers, 4 threads | 6 workers, 16 threads |
| **Gitaly** | 5 concurrent Git ops | 10 concurrent Git ops, memory-limited |
| **PostgreSQL** | 200 connections, 256MB cache | 400 connections, 16GB cache |
| **Redis** | Unlimited memory, no eviction | 16GB limit, LRU eviction |
| **Git GC** | Auto-GC, 1-thread packing | Scheduled GC, 4-thread packing |
| **Workhorse** | Unix socket | TCP socket for high concurrency |
| **Sidekiq** | 5 workers | 20 workers |

---

## **Final Steps**
1. Apply changes:
   ```bash
   sudo gitlab-ctl reconfigure
   sudo gitlab-ctl restart
   ```
2. Monitor GitLab:
   ```bash
   sudo gitlab-ctl status
   ```
3. Check PostgreSQL slow queries:
   ```bash
   sudo gitlab-psql -c "SELECT * FROM pg_stat_activity WHERE state != 'idle';"
   ```

These optimizations should ensure **smooth operation for 500 developers**, 
reducing latency in Git operations and improving UI/API response times.


# Q:

Actual memory of host needn't be the sum of those "memory" settings?

# A1:

You're absolutely correct to think critically about the memory settings for each service. The memory configurations for **PostgreSQL**, **Redis**, **Gitaly**, etc., are all separate and typically don't add up directly to the total available physical memory. However, they do need to be managed carefully, as each service will use its portion of the memory based on the settings.

Here's an explanation of how memory settings for these services interact:

### **1. PostgreSQL Memory Settings**
The key settings like `shared_buffers`, `work_mem`, and `effective_cache_size` configure how PostgreSQL uses memory, but **they don’t directly sum up** to the total memory PostgreSQL consumes.

- **`shared_buffers`**: This is the amount of memory PostgreSQL uses for caching data in memory. It’s typically a portion of the total system RAM, but not all of it. For high-performance systems, this should generally be set to around **25-40%** of total system memory, but it can be lower for very large systems where disk I/O speed is optimized.
  
- **`work_mem`**: This is the amount of memory used for sorting and hashing operations per query. It can be a concern if many queries use a lot of memory, but PostgreSQL will only allocate this amount for each operation. In practice, it doesn’t sum up to a strict total — PostgreSQL will use it per query execution context.

- **`effective_cache_size`**: This is more of a hint to PostgreSQL about how much memory is available for caching, used by the query planner. It should generally be set to **50-75%** of the total system memory, as it's a guideline for query optimization.

### **2. Redis Memory Settings**
The **`maxmemory`** setting tells Redis how much memory it can use for caching. It doesn't "add up" with other services, and Redis will try to stay within this limit, evicting keys as necessary based on the eviction policy (`allkeys-lru` in the example).

### **3. Gitaly Memory Settings**
The memory settings for Gitaly are primarily related to how much memory Gitaly can use for its own internal operations, including handling repository access and storing temporary files. These settings will use memory resources, but not to the extent of directly competing with the entire host's memory.

### **4. Puma Memory Settings**
Puma's memory use depends on the number of worker processes and threads. Each worker uses a set amount of memory, so **the memory per worker can add up** (along with threads), but again, the total memory usage will not be strictly the sum of all worker memory unless all are fully utilized. Generally, you want to make sure each worker has enough memory, but **you don't want to have too many workers** such that you run out of memory on the system.

### **How to Monitor and Tune:**
- **Total Memory Usage**: You should make sure that the total memory usage for all services doesn’t exceed the available memory of the host. The system’s **swap space** (if any) should also be monitored to avoid performance issues.
- **Process Isolation**: Services like PostgreSQL, Redis, and Gitaly may run on separate processes and may have specific memory limits. Each service is designed to work efficiently within its own limits.
- **Host Memory**: If your host has **64GB RAM**, you wouldn't necessarily allocate all of it to these services. You might leave some memory for the OS and other applications.

### Example:
If you set:
- PostgreSQL `shared_buffers` = 16GB
- Redis `maxmemory` = 16GB
- Gitaly memory settings = 4GB

Then you could aim for something like:
- 16GB + 16GB + 4GB = 36GB for these services, leaving the remaining memory (roughly 28GB) for the OS, Puma, caching, and other overhead.

**The sum of the "memory" settings for services is a guideline, not an exact total**, and you should monitor the system’s overall memory usage to ensure that your host is not overloaded. Tools like `htop`, `vmstat`, or GitLab's built-in metrics can help you track this.

### Conclusion:
While it's good practice to tune memory for these services, the **actual system memory usage** won't be the sum of all the configured memory limits. As long as you leave sufficient memory for the operating system and other processes, these services will run efficiently within their own memory limits without exceeding the host's capacity. Regular monitoring is key to understanding how these services interact with your server's memory.

# A2:

You're absolutely right! The actual **physical memory (RAM) requirement** of the host **is not necessarily the sum of all the individual "memory" settings** from Puma, Gitaly, PostgreSQL, Redis, and other services. These values represent **allocation limits, caches, or buffers**, which do not all get fully utilized at the same time.

### **How to Estimate Real Memory Usage**
Rather than summing up all memory values, we consider:
1. **Memory allocation vs. actual usage**: Services typically **do not use their full allocation** unless under extreme load.
2. **Overlapping memory usage**: Some caches (PostgreSQL, Redis) may hold redundant data, reducing total needs.
3. **OS-level memory management**: Linux aggressively caches disk reads and reclaims memory dynamically.

---

### **Breakdown of Major Services and Realistic RAM Usage**
| **Service**      | **Configured Memory**  | **Actual Usage Estimate** |
|------------------|----------------------|---------------------------|
| **Puma** (Web API)   | Threads don’t allocate large memory | **1–2 GB** |
| **Gitaly** (Git operations) | `4GB` cgroup limit | **1–4 GB** |
| **PostgreSQL** (Database) | `16GB` shared_buffers | **12–16 GB** (most actively used) |
| **Redis** (Cache) | `16GB` maxmemory | **4–8 GB** (depends on cache churn) |
| **Sidekiq** (Background jobs) | Concurrency 20 | **2–4 GB** |
| **Workhorse** (Git HTTP proxy) | Minimal memory use | **~500MB** |
| **Kernel Disk Caching** | Linux caches Git repo reads | **6–12 GB** |
| **OS & Miscellaneous** | System services, SSH, monitoring | **4–6 GB** |

### **Total Estimated RAM Requirement**
Instead of **summing up the maximum allocations (≈58 GB),** we estimate:
- **Minimum required RAM**: **32GB**
- **Optimal RAM**: **64GB**
- **For heavy CI/CD workloads**: **128GB+**

---

### **Key Considerations**
1. **PostgreSQL's `shared_buffers` doesn't use all memory immediately.** It only keeps frequently accessed data in RAM.
2. **Redis does not always use full `maxmemory`.** If the cache is not full, it uses less.
3. **Gitaly uses memory in bursts during Git operations.** Idle time consumption is low.
4. **Sidekiq jobs vary in memory needs** depending on how many are running.
5. **Linux dynamically allocates unused RAM to disk caching.** This improves performance without reserving actual memory.

---

### **What Happens If RAM is Exceeded?**
If total memory demand **exceeds available RAM**, GitLab will start **swapping**, which significantly degrades performance. To **prevent this**:
- **Enable swap (if necessary, for buffer)**:
  ```bash
  sudo fallocate -l 8G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
  ```
- **Monitor memory usage with `htop` or `glances`**.
- **Use cgroups (`systemd` or `cgroup` limits)** to prevent single services from consuming all RAM.

---

### **Conclusion**
- **Do NOT add up all memory settings**—they represent **limits**, not actual usage.
- **64GB RAM** is a **good target** for **500 developers** with **Git, API, and CI/CD** usage.
- **If hosting runners for CI/CD**, aim for **128GB+**.


# Q: 

If the CI/CD pipelines use __Kubernetes executor__ 
and GitLab runners are of a remote (k8s) service, 
do the advised configurations change at all?

# A:

Yes, if **CI/CD pipelines use a Kubernetes executor** 
and **GitLab runners are on a remote Kubernetes cluster**, 
**GitLab's resource requirements on the main server decrease**, 
but some optimizations remain necessary.

### **Key Differences with Kubernetes Runners**
1. **GitLab no longer runs CI/CD jobs locally** → **No need for high Sidekiq concurrency**.
2. **GitLab's PostgreSQL, Redis, Puma, and Gitaly still require tuning**, but memory pressure is lower.
3. **Workhorse and API performance remain crucial**, as pipelines generate API requests and Git operations.

---

## **How Do Configuration Recommendations Change?**
| **Service**     | **With Local CI/CD**  | **With Kubernetes Runners** |
|-----------------|----------------------|-----------------------------|
| **Puma (API, UI, GitLab Rails)** | **6 workers, 16 threads** | **Keep same (API still serves CI/CD requests)** |
| **Gitaly (Git backend)** | **10 concurrent RPCs, 4GB memory** | **Keep same (repos still cloned by runners)** |
| **PostgreSQL** | **400 connections, 16GB shared_buffers** | **Reduce to ~300 connections, 12GB shared_buffers** |
| **Redis (Cache for jobs, API, sessions)** | **16GB maxmemory** | **Reduce to ~8GB maxmemory** (CI/CD caching moves to Kubernetes) |
| **Sidekiq (Background jobs processing)** | **20 concurrency** | **Reduce to ~8 concurrency** (fewer local jobs) |
| **Workhorse (Git HTTP Proxy)** | **TCP mode, handles CI/CD requests** | **Keep same (runners clone repos via HTTP)** |
| **Git Garbage Collection (GC)** | **Run via cron off-peak** | **Keep same (repositories still grow over time)** |

---

## **How These Changes Impact Performance**
### ✅ **Lower PostgreSQL & Redis load**:
- CI/CD **job logs and artifacts** now persist in **Kubernetes storage** instead of **PostgreSQL/Redis** on GitLab.
- **Fewer writes** to **PostgreSQL** → lower memory and disk I/O.

### ✅ **Lower Sidekiq load**:
- **CI/CD job execution moves to Kubernetes**, so **fewer jobs run inside GitLab**.
- Background jobs **still needed** for:
  - **Pipeline scheduling**
  - **CI/CD event processing**
  - **Artifact expiration**
  - **Merge request automation**
- **Reduce Sidekiq concurrency** from `20` to **8**.

### ✅ **Gitaly & Workhorse remain critical**:
- **Pipelines still clone repositories** from GitLab → **Gitaly still needs high concurrency**.
- Runners **access repositories via HTTP(S)** → **Workhorse should stay in TCP mode**.

### ✅ **Git garbage collection remains necessary**:
- Even though runners are external, **Git repositories still accumulate loose objects**.
- **Run Git GC** regularly to avoid repo bloat.

---

## **Revised Configuration (`/etc/gitlab/gitlab.rb`)**
If runners **move to Kubernetes**, apply these changes:

### **1. PostgreSQL - Reduce Memory & Connections**
```ruby
postgresql['max_connections'] = 300
postgresql['shared_buffers'] = "12GB"
postgresql['work_mem'] = "128MB"
postgresql['effective_cache_size'] = "36GB"
```
- **Why?** Fewer CI/CD database queries.

---

### **2. Redis - Reduce Memory Allocation**
```ruby
redis['maxmemory'] = "8GB"
redis['maxmemory_policy'] = "allkeys-lru"
```
- **Why?** CI/CD cache now handled in Kubernetes.

---

### **3. Sidekiq - Reduce Background Worker Concurrency**
```ruby
sidekiq['concurrency'] = 8
```
- **Why?** Fewer local CI/CD jobs to process.

---

### **4. Keep Puma, Gitaly, and Workhorse Settings**
```ruby
puma['worker_processes'] = 6
puma['max_threads'] = 16

gitaly['concurrency'] = [
  { 'rpc' => '/gitaly.SmartHTTPService/PostUploadPack', 'max_per_repo' => 10 },
  { 'rpc' => '/gitaly.SSHService/UploadPack', 'max_per_repo' => 10 }
]
gitaly['cgroups_memory_enabled'] = true
gitaly['cgroups_memory_limit'] = '4GB'

gitlab_workhorse['listen_network'] = "tcp"
gitlab_workhorse['listen_addr'] = "0.0.0.0:8181"
```
- **Puma** stays **highly concurrent** for **UI/API requests**.
- **Gitaly** still needs **high concurrency for cloning/fetching**.
- **Workhorse** remains **optimized for Git HTTP traffic**.

---

### **5. Keep Git Garbage Collection Active**
```bash
sudo -u git -H git config --global gc.auto 0
sudo -u git -H git config --global pack.threads 4
sudo -u git -H git config --global pack.windowMemory 256m
```
- **Why?** Even with external runners, repositories still accumulate junk objects.

---

## **How Much RAM is Now Needed?**
| **Component**     | **With Local CI/CD** | **With Kubernetes Runners** |
|------------------|-----------------|------------------|
| **PostgreSQL**  | **16GB** | **12GB** |
| **Redis**  | **16GB** | **8GB** |
| **Puma** | **2GB** | **2GB** |
| **Gitaly** | **4GB** | **4GB** |
| **Sidekiq** | **4GB** | **2GB** |
| **Workhorse + Kernel Caching** | **8GB** | **6GB** |
| **OS & Misc.** | **6GB** | **4GB** |
| **Total RAM Required** | **64GB** | **32GB–48GB** |

- With **Kubernetes runners**, GitLab can **run well on 32GB**, but **48GB is safer** for heavy repo traffic.
- If hosting **large repositories (GBs in size)**, keep **64GB+**.

---

## **Final Thoughts**
✅ **With external runners, GitLab requires ~30% less memory**  
✅ **PostgreSQL and Redis workloads drop significantly**  
✅ **Workhorse and Gitaly remain critical for repo access**  
✅ **Git garbage collection is still necessary**  

If your Kubernetes cluster is also **handling GitLab registry/artifacts**,  
we can fine-tune **object storage, persistent volumes, and caching strategies!**


# Q:

How to load test the protected Git service endpoints, e.g., git ls-remote $host/$repo.git, which require authentication, using Apache Bench?

# A:

To **load test protected Git service endpoints** such as `git ls-remote $host/$repo.git`, which require **authentication**, using **Apache Bench (`ab`)**, follow these steps:

---

### **1. Gather Required Credentials**
For Git HTTP authentication, you typically use:
- **Username & Password** (Basic Auth)
- **Personal Access Token (PAT)** (GitLab, GitHub)
- **Session Cookies** (If using GitLab with login)

---

### **2. Format the Authenticated Request**
Git servers usually require **Basic Authentication**, which can be provided using:
- **Username & Password**: `https://username:password@$host/$repo.git`
- **Access Token** (Preferred): `https://oauth_token@$host/$repo.git`

#### **Example: Constructing an Authenticated URL**
```bash
GIT_HOST="git.example.com"
REPO_PATH="group/repo.git"
USERNAME="testuser"
PASSWORD="supersecret"
ACCESS_TOKEN="glpat-xxxxxxxxxxxxxx"

# Basic Auth (Less Secure)
AUTH_URL="https://$USERNAME:$PASSWORD@$GIT_HOST/$REPO_PATH"

# Personal Access Token (More Secure)
AUTH_URL="https://$ACCESS_TOKEN@$GIT_HOST/$REPO_PATH"
```

---

### **3. Use Apache Bench (`ab`) for Load Testing**
#### **Basic Test**
To test the response time and throughput:
```bash
ab -n 100 -c 10 "$AUTH_URL/info/refs?service=git-upload-pack"
```
- **`-n 100`** → Total **100 requests**
- **`-c 10`** → **10 concurrent connections**
- **`/info/refs?service=git-upload-pack`** → The endpoint Git uses for `ls-remote`

#### **More Intensive Load Test**
```bash
ab -n 1000 -c 50 "$AUTH_URL/info/refs?service=git-upload-pack"
```
- Simulates **1000 total requests** with **50 concurrent users**

---

### **4. If Password Authentication Fails (Use `-H` Header)**
Some Git servers block `username:password` in URLs. Use an **Authorization header** instead:
```bash
ab -n 100 -c 10 -H "Authorization: Basic $(echo -n "$USERNAME:$PASSWORD" | base64)" "https://$GIT_HOST/$REPO_PATH/info/refs?service=git-upload-pack"
```
For **Personal Access Token (PAT)**:
```bash
ab -n 100 -c 10 -H "Authorization: Basic $(echo -n "oauth:$ACCESS_TOKEN" | base64)" "https://$GIT_HOST/$REPO_PATH/info/refs?service=git-upload-pack"
```

---

### **5. Using Session Cookies (For GitLab)**
If GitLab requires login, use session cookies:
1. Log in via `curl`:
   ```bash
   curl -c cookies.txt -X POST -d "username=myuser&password=mypass" "https://git.example.com/users/sign_in"
   ```
2. Use **Apache Bench** with cookies:
   ```bash
   ab -n 100 -c 10 -C "cookie_value_from_cookies.txt" "https://git.example.com/$REPO_PATH/info/refs?service=git-upload-pack"
   ```

---

### **6. Analyzing Apache Bench Output**
After running `ab`, you’ll get:
- **Requests per second** (`Requests/sec`): Higher is better.
- **Time per request** (`Time per request`): Lower is better.
- **Failed requests**: Ensure **0 failed** requests.

---

### **7. Monitor GitLab Server Load During Test**
While running `ab`, monitor server resources:
```bash
htop   # CPU/RAM usage
iotop  # Disk I/O usage
dstat  # Network usage
```

---

### **8. Avoid Being Blocked**
🔹 **Use `-r` to prevent aborting on socket failures**:
```bash
ab -n 1000 -c 50 -r "$AUTH_URL/info/refs?service=git-upload-pack"
```
🔹 **Rate-limit requests (`-p`) to avoid overloading the Git server**:
```bash
ab -n 1000 -c 10 -p 500 "https://$GIT_HOST/$REPO_PATH/info/refs?service=git-upload-pack"
```

---

### **Summary**
✔ **Use Apache Bench (`ab`)** to test `git ls-remote` using `/info/refs?service=git-upload-pack`  
✔ **Use `-H "Authorization: Basic <base64>` for authentication**  
✔ **Monitor server load (`htop`, `iotop`, `dstat`)**  
✔ **Use `-r` to prevent premature failures**  

Would you like to extend testing to **Git pushes/pulls** (`git-receive-pack`)? 🚀

# Q:

The real issue is `git clone $url` responding HTTP 500, 
but we don't want to slam the server with lots of such requests, 
thinking that would ruin everyone's day.

# A:

... you don't want to overload the server with excessive test requests. 
Here’s a structured approach to __debug__ this __without causing unnecessary load__.

---

## **1. Understanding the `git clone` HTTP Request**
When running:
```bash
git clone https://$GIT_HOST/$REPO_PATH.git
```
Git makes multiple HTTP requests to the server:

1. **Fetch repository metadata (`ls-remote`)**  
   - `GET /$REPO_PATH.git/info/refs?service=git-upload-pack`
2. **Negotiate packfile transfer**  
   - `POST /$REPO_PATH.git/git-upload-pack`
3. **Download objects in batches**  
   - __Multiple `POST` requests__ until all objects are fetched.

An **HTTP 500** (Internal Server Error) suggests:
- The **Git HTTP backend** (Gitaly, Workhorse, or Nginx) **is failing.**
- The **server is overloaded** or **misconfigured**.
- A **specific repository operation (e.g., object packing) is triggering an error**.

---

## **2. How to Test Without Slamming the Server**
To **troubleshoot without flooding GitLab**, use **controlled and targeted tests**:

### **Option 1: Isolate `git ls-remote` First**

Since `git clone` first calls `ls-remote`, check if it fails first:

```bash
git ls-remote https://$GIT_HOST/$REPO_PATH.git
```
If this also returns **HTTP 500**, 
the issue is likely **Gitaly or GitLab Workhorse**.

### **Option 2: Clone a Tiny Repo (Low Impact Test)**
Instead of testing with a **large repo**, clone a small one:
```bash
git clone --depth 1 https://$GIT_HOST/$SMALL_TEST_REPO.git
```
- **If this works**, the problem is **large repository cloning**.
- **If this also fails**, the problem is likely **system-wide**.

### **Option 3: Clone with Debug Logging**
Run `git clone` with **detailed debug logs**:
```bash
GIT_TRACE=1 GIT_CURL_VERBOSE=1 git clone https://$GIT_HOST/$REPO_PATH.git
```
- **Check where the request fails.**
- Look for errors like:
  ```
  fatal: HTTP error 500
  ```
  or  
  ```
  POST git-upload-pack (500 Internal Server Error)
  ```

---

## **3. Check Server Logs for Root Cause**
On the **GitLab server**, analyze logs in **real-time** while running `git clone`:

### **Gitaly Logs (Git backend)**
```bash
sudo tail -f /var/log/gitlab/gitaly/current
```
- Look for `RPC error` or `failed to process upload-pack`.

### **Workhorse Logs (Git HTTP proxy)**
```bash
sudo tail -f /var/log/gitlab/gitlab-workhorse/current
```
- Check if Workhorse is failing when proxying Git HTTP requests.

### **Nginx Logs (GitLab Web Requests)**
```bash
sudo tail -f /var/log/gitlab/nginx/gitlab_access.log
sudo tail -f /var/log/gitlab/nginx/gitlab_error.log
```
- Look for `500 Internal Server Error`.

### **PostgreSQL Logs (Database issues)**
```bash
sudo tail -f /var/log/gitlab/postgresql/current
```
- If CI/CD jobs or hooks are failing, it might be **a DB overload issue**.

---

## **4. Possible Causes of HTTP 500 in `git clone`**
Based on logs, here are common reasons and fixes:

| **Cause** | **Logs to Check** | **Fix** |
|-----------|-----------------|---------|
| **Gitaly crashes under load** | `gitaly/current` | Increase memory, concurrency |
| **Large repo fetch failing (`git-upload-pack`)** | `gitaly/current` | Run `git gc` on repo |
| **GitLab Workhorse timeouts** | `gitlab-workhorse/current` | Increase timeout (`workhorse['proxy_timeout'] = 300`) |
| **Nginx too many open files** | `nginx/gitlab_error.log` | Increase worker limits (`worker_rlimit_nofile 100000;`) |
| **PostgreSQL slow queries** | `postgresql/current` | Optimize DB (`work_mem`, `shared_buffers`) |

---

## **5. Safe Load Testing Without Overloading the Server**
To simulate `git clone` **without impacting production**, use **Apache Bench (`ab`) with rate-limiting**:

### **Option 1: Test Without Downloading Objects**
Instead of cloning everything, **only request metadata**:
```bash
ab -n 10 -c 2 "https://$GIT_HOST/$REPO_PATH.git/info/refs?service=git-upload-pack"
```
- Simulates **10 lightweight clone requests**.
- **Does not** download full repository data.

### **Option 2: Rate-Limited `git clone`**
Clone with bandwidth limits:
```bash
git clone --depth=1 --single-branch --progress https://$GIT_HOST/$REPO_PATH.git &
sleep 2 && kill $!
```
- Runs a **partial fetch** for 2 seconds, then stops.
- **Prevents overloading** the server.

### **Option 3: Clone Specific Large Objects**
If a repo has **large files**, fetch only **a single large object**:
```bash
git fetch --depth 1 origin <large_commit_sha>
```
- **Checks if large object retrieval is the issue**.

---

## **6. Final Steps: Fixing HTTP 500 Issues**
### ✅ **If Gitaly is the issue:**
- Increase **memory limits** in `gitaly.toml`:
  ```toml
  [memory]
  max_rss = "6GB"
  ```
- Restart Gitaly:
  ```bash
  sudo gitlab-ctl restart gitaly
  ```

### ✅ **If Nginx is the issue:**
- Increase **timeout limits** in `/etc/gitlab/gitlab.rb`:
  ```ruby
  nginx['proxy_read_timeout'] = 300
  nginx['proxy_connect_timeout'] = 300
  ```
- Restart Nginx:
  ```bash
  sudo gitlab-ctl restart nginx
  ```

### ✅ **If Workhorse is the issue:**
- Increase timeout:
  ```ruby
  gitlab_workhorse['proxy_timeout'] = 300
  ```
- Restart Workhorse:
  ```bash
  sudo gitlab-ctl restart gitlab-workhorse
  ```

### ✅ **If Large Repo Clones Are the Issue:**
- Run **Git Garbage Collection**:
  ```bash
  sudo -u git -H git gc --aggressive /var/opt/gitlab/git-data/repositories/@hashed/<repo_path>
  ```
- **Encourage shallow clones**:
  ```bash
  git clone --depth 1 https://$GIT_HOST/$REPO_PATH.git
  ```

---

## **7. Summary**
| **Step** | **What to Do** |
|----------|--------------|
| **Verify `ls-remote`** | Run `git ls-remote $URL` |
| **Check logs** | `gitaly`, `workhorse`, `nginx`, `postgresql` |
| **Clone small repo** | `git clone --depth 1 $URL` |
| **Run controlled Apache Bench test** | `ab -n 10 -c 2 $URL/info/refs?service=git-upload-pack` |
| **Optimize GitLab** | Increase **timeouts, memory, Git GC** |



# Q: 

Indeed, `git ls-remote` by itself generates the same pattern and rate of HTTP 500 responses ! 

That is, from above:

>Since `git clone` first calls `ls-remote`, check if it fails first:
>
>```bash
>git ls-remote https://$GIT_HOST/$REPO_PATH.git
>```
>If this also returns **HTTP 500**, 
>the issue is likely **Gitaly or GitLab Workhorse**.


# A:

Great observation! If `git ls-remote $URL` alone is generating **HTTP 500 responses** at the same rate and pattern as `git clone`, this strongly suggests the issue lies in **GitLab’s Git HTTP service**, specifically:

### **Possible Causes**
1. **Gitaly is failing under load** (Git backend service)
2. **GitLab Workhorse is misconfigured or timing out**
3. **Nginx reverse proxy limits are being exceeded**
4. **A specific repository operation (`git-upload-pack`) is failing**
5. **File descriptor limits or memory constraints on GitLab components**

---

## **1. Verify Gitaly is the Issue**
Since `git ls-remote` interacts **directly with Gitaly**, check if Gitaly is failing.

### **Check Gitaly Logs in Real-Time**
```bash
sudo tail -f /var/log/gitlab/gitaly/current
```
- Look for **errors or RPC failures**:
  ```
  rpc error: code = Internal desc = failed to call git-upload-pack
  ```

### **Manually Test Gitaly**
Try an RPC request to Gitaly:
```bash
sudo gitlab-rake gitlab:gitaly:status
```
If Gitaly is failing, restart it:
```bash
sudo gitlab-ctl restart gitaly
```

**If Gitaly is repeatedly failing**, **increase its memory limits**:
```toml
[gitaly]
concurrency = 20
memory_limit = "6GB"
```
Then reload:
```bash
sudo gitlab-ctl reconfigure
```

---

## **2. Check GitLab Workhorse**
Since Workhorse proxies Git HTTP traffic, **it may be timing out**.

### **Check Workhorse Logs**
```bash
sudo tail -f /var/log/gitlab/gitlab-workhorse/current
```
- Look for:
  ```
  500 Internal Server Error
  upstream prematurely closed connection
  ```

### **Increase Workhorse Timeout**
Edit `/etc/gitlab/gitlab.rb`:
```ruby
gitlab_workhorse['proxy_timeout'] = 300
```
Then restart:
```bash
sudo gitlab-ctl restart gitlab-workhorse
```

---

## **3. Increase Nginx Limits**
If GitLab is behind **Nginx**, **Nginx may be rejecting requests** due to:
- **Connection limits**
- **Timeout settings**

### **Check Nginx Logs**
```bash
sudo tail -f /var/log/gitlab/nginx/gitlab_error.log
```
- Look for errors like:
  ```
  502 Bad Gateway
  500 Internal Server Error
  client sent too many requests
  ```

### **Increase Timeout & Connections**
Edit `/etc/gitlab/gitlab.rb`:
```ruby
nginx['proxy_read_timeout'] = 300
nginx['proxy_connect_timeout'] = 300
nginx['worker_connections'] = 16384
nginx['worker_rlimit_nofile'] = 100000
```
Then restart:
```bash
sudo gitlab-ctl restart nginx
```

---

## **4. Verify Git is Failing on `git-upload-pack`**
### **Manually Test Git HTTP API**
Instead of `git ls-remote`, run:
```bash
curl -v "https://$GIT_HOST/$REPO_PATH.git/info/refs?service=git-upload-pack"
```
- If this **also returns HTTP 500**, it confirms **GitLab’s Git service** is failing.
- If it **succeeds**, the issue is related to **Git concurrency limits**.

### **Increase Gitaly Concurrency**
```toml
[gitaly]
concurrency = 20
```
Then restart:
```bash
sudo gitlab-ctl restart gitaly
```

---

## **5. Check File Descriptors & Memory Limits**
If **too many requests cause failures**, increase system limits.

### **Check Open Files Limit**
```bash
ulimit -n
```
If **less than 100000**, increase it in `/etc/security/limits.conf`:
```
gitlab  soft  nofile  100000
gitlab  hard  nofile  100000
```

### **Check System Memory**
```bash
free -h
```
If **Gitaly is OOM-killing**, increase swap:
```bash
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## **6. Safe Testing Without Overloading GitLab**
Instead of running many `git clone` commands:
- Test **only metadata fetching**:
  ```bash
  ab -n 10 -c 2 "https://$GIT_HOST/$REPO_PATH.git/info/refs?service=git-upload-pack"
  ```
- Use **shallow cloning**:
  ```bash
  git clone --depth 1 https://$GIT_HOST/$REPO_PATH.git
  ```

---

## **Summary of Fixes**
| **Issue** | **Fix** |
|-----------|--------|
| **Gitaly crashes** | Increase memory, concurrency |
| **Workhorse timeouts** | Increase `proxy_timeout` |
| **Nginx rate limits** | Increase `worker_connections`, `proxy_read_timeout` |
| **Too many open files** | Set `ulimit -n 100000` |
| **Swap thrashing** | Add swap (`8GB`) |

Let me know which logs show **500 errors**, and we’ll narrow it down! 🚀

### &nbsp;
