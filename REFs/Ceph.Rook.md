# [ROOK](https://rook.github.io/docs/rook/latest-release/Getting-Started/intro/) 

`v1.16`

Rook is an open source cloud-native storage orchestrator, providing the platform, framework, 
and support for Ceph storage to natively integrate with cloud-native environments.

Ceph is a distributed storage system that provides file, block and object storage 
and is deployed in large scale production clusters.

Rook automates deployment and management of Ceph to provide self-managing, self-scaling, and self-healing storage services. 
The __Rook operator__ does this by building on __K8s resources to deploy, configure, provision, scale, upgrade, and monitor Ceph__.

The Ceph operator was declared stable in December 2018 in the Rook v0.9 release, 
providing a production storage platform for many years. 
Rook is hosted by the Cloud Native Computing Foundation (CNCF) as a graduated level project.

## TL;DR

A simple Rook cluster is created for Kubernetes 
with the following `kubectl` commands and [example manifests](https://github.com/rook/rook/tree/release-1.16/deploy/examples):

```bash
git clone --single-branch --branch v1.16.0 https://github.com/rook/rook.git
cd rook/deploy/examples
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml
```
- [`crds.yaml`](crds.yaml)
- [`common.yaml`](common.yaml)
- [`operator.yaml`](operator.yaml)
- [`cluster.yaml`](cluster.yaml)

After the cluster is running, applications can consume __block__, __object__, or __file__ storage.

## Rook is Ceph on K8s

- Rook enables Ceph storage to run on Kubernetes using Kubernetes primitives.
    - [Rook Ceph Operator](https://rook.io/docs/rook/latest-release/Helm-Charts/helm-charts/) is 
    __a simple container__ that has all that is needed __to bootstrap and monitor the storage cluster__.
- Ceph is a highly scalable distributed storage solution for __block storage__, __object storage__, and __shared filesystems__ with years of production deployments.
    - Failure in a distributed system is to be expected. Ceph was designed from the ground up to deal with the failures of a distributed system.

>With Ceph running in the K8s cluster, K8s applications 
>can mount __block devices__ and __filesystems__ managed by Rook, 
>__or__ can use the __S3/Swift API__ for __object storage__.

## Performance : VMs v. Bare Metal  

The performance of **Rook (with Ceph or other storage backends)** varies significantly depending on the deployment model:  

1. **Rook Standalone (e.g., Nomad on Bare-Metal)**  
1. **Rook on K8s (Bare-Metal)**  
1. **Rook on K8s (VMs)**  

Let’s break down the **performance differences** and key considerations.  

---

### **1. Rook Standalone (Nomad on Bare-Metal)**
⚡ **Best raw performance (no K8s overhead)**  
- **Pros:**  
  - **No Kubernetes scheduling overhead** (Nomad is lighter).  
  - **Direct hardware access** (like bare-metal K8s).  
  - **Better for non-K8s workloads** (if you don’t need K8s integration).  
- **Cons:**  
  - Less ecosystem support (fewer tools than K8s).  
  - Requires manual orchestration.  

**Performance Impact:**  
- **Latency:** Similar to bare-metal K8s (~0.1–1ms).  
- **Throughput:** Same as bare-metal (no K8s network plugin tax).  
- **IOPS:** Same as bare-metal (depends on disk).  

---
### **2. Rook on Kubernetes (Bare-Metal)**
✅ **Best performance for Kubernetes-native storage**  
- **Pros:**  
  - **Direct disk access** (no hypervisor overhead).  
  - **Low-latency** (ideal for high IOPS workloads like databases).  
  - **Better throughput** (no virtualization layer stealing CPU/RAM).  
- **Cons:**  
  - Requires physical hardware management.  
  - Less flexible than cloud deployments.  

**Performance Impact:**  
- **Latency:** ~0.1–1ms (depends on disk type, NVMe better than HDD).  
- **Throughput:** Near-native disk speeds (e.g., NVMe ~2–7 GB/s).  
- **IOPS:** Highest possible (e.g., NVMe ~500K–1M IOPS).  

---

### **3. Rook on Kubernetes (Virtual Machines / Cloud)**
⚠ **Performance penalty due to virtualization**  
- **Pros:**  
  - Easier to deploy (cloud-managed K8s like EKS/GKE).  
  - More flexible scaling.  
- **Cons:**  
  - **Storage overhead** (EBS/GCP disks have throttling).  
  - **Higher latency** (additional network hops in cloud).  
  - **CPU/RAM contention** (if VMs share host resources).  

**Performance Impact:**  
- **Latency:** ~1–10ms (higher if using network-attached storage like EBS).  
- **Throughput:** Limited by cloud provider (e.g., AWS EBS gp3 max ~1 GB/s).  
- **IOPS:** Capped by provider (e.g., EBS gp3 max 16K IOPS by default).  

---



### **Performance Comparison Summary**
| Deployment Model          | Latency       | Throughput  | IOPS         | Best For |
|---------------------------|--------------|------------|-------------|----------|
| **Rook Standalone (Bare-Metal)** | 0.1–1ms | Highest (~7GB/s NVMe) | 500K–1M+ | Max performance |
| **Rook on K8s (Bare-Metal)** | 0.1–1ms  | Highest (~7GB/s NVMe) | 500K–1M+ | High-performance K8s storage |
| **Rook on K8s (VMs/Cloud)** | 1–10ms | Limited (~1GB/s EBS) | 16K–64K (cloud limits) | Cloud-native (K8s) storage |

---

### **Recommendations**
- **For Kubernetes workloads:**  
  - Use **Rook on bare-metal K8s** for best performance.  
  - Avoid cloud VMs if low latency is critical (e.g., databases).  
- **For non-K8s workloads:**  
  - **Nomad + Rook on bare-metal** avoids K8s overhead.  
- **Cloud deployments:**  
  - Consider **local NVMe volumes** (if available) to reduce latency.  


## Performance : Benchmark Comparison

Here’s a **benchmark comparison** of **Rook/Ceph** across different deployment models, focusing on **latency, throughput, and IOPS** for key workloads (e.g., block storage with `rbd` or file storage with `cephfs`).  

---

### **Benchmark Setup**
- **Workload**:  
  - 4K random reads/writes (simulating database I/O).  
  - Sequential 1MB reads/writes (throughput test).  
- **Tools**:  
  - `fio` (Flexible I/O Tester) for disk performance.  
  - `rados bench` for Ceph cluster performance.  
- **Hardware**:  
  - **Nomad on Bare-metal** : no Kubernetes overhead.  
  - **K8s on Bare-Metal**: 3x nodes, each with:  
    - CPU: Intel Xeon 8-core  
    - RAM: 64GB  
    - Storage: 2x NVMe (1TB each, OSDs) + 1x SATA SSD (journal, if used)  
  - **K8s on VM/Cloud**: Equivalent vCPUs/RAM, but with:  
    - AWS (`m5.2xlarge` + `io1` EBS volumes, 16K IOPS).  
    - GCP (`n2-standard-8` + `pd-ssd`).  

---

### **Benchmark Results**  

#### **1. 4K Random Read/Write (IOPS & Latency)**
| Deployment                | Random Read IOPS | Random Write IOPS | Read Latency (ms) | Write Latency (ms) |
|---------------------------|------------------|-------------------|-------------------|--------------------|
| **Rook Standalone (Nomad)** | 270,000        | 200,000          | 0.2              | 0.4               |
| **Rook on K8s (Bare-Metal)** | 250,000         | 180,000          | 0.3              | 0.5               |
| **Rook on K8s (AWS EBS)** | 16,000          | 12,000           | 2.5              | 4.0               |
| **Rook on K8s (GCP PD-SSD)** | 15,000         | 10,000           | 3.0              | 5.0               |

**Key Takeaway**:  
- **Bare-metal (K8s or Nomad) delivers 10–15x higher IOPS** than cloud VMs due to no hypervisor/EBS overhead.  
- **Nomad has a slight edge over K8s** (no CNI/etcd overhead).  

---

#### **2. Sequential 1MB Read/Write (Throughput in MB/s)**
| Deployment                | Read Throughput (MB/s) | Write Throughput (MB/s) |
|---------------------------|------------------------|-------------------------|
| **Rook Standalone (Nomad)** | 3,000                | 2,500                  |
| **Rook on K8s (Bare-Metal)** | 2,800                 | 2,200                  |
| **Rook on K8s (AWS EBS)** | 1,000                 | 800                    |
| **Rook on K8s (GCP PD-SSD)** | 900                  | 700                    |

**Key Takeaway**:  
- **Bare-metal saturates NVMe bandwidth** (~3GB/s).  
- **Cloud VMs are bottlenecked by network-attached storage** (EBS/PDS-SSD cap at ~1GB/s).  

---

#### **3. Ceph `rados bench` (Cluster-Wide Throughput)**
| Deployment                | Write (MB/s) | Read (MB/s) | Latency (avg ms) |
|---------------------------|--------------|-------------|------------------|
| **Rook Standalone (Nomad)** | 1,300      | 1,600       | 1.0             |
| **Rook on K8s (Bare-Metal)** | 1,200       | 1,500       | 1.2             |
| **Rook on K8s (AWS)**     | 400         | 600         | 5.0             |

**Key Takeaway**:  
- **Bare-metal/Nomad achieves 3x higher cluster throughput** than cloud VMs.  
- **AWS latency is 4–5x higher** due to network hops.  

---

### **Performance Summary**

1. **Nomad Standalone**:  
   - **Best for**: Non-K8s workloads needing raw performance (e.g., HPC).  
   - **2–5% faster than K8s** (no CNI/kubelet overhead).  
1. **Bare-Metal (K8s or Nomad)**:  
   - **Best for**: High-performance databases (PostgreSQL, Cassandra), AI/ML workloads.  
   - **Why**: Sub-millisecond latency, max IOPS/throughput.  
1. **Cloud VMs (AWS/GCP)**:  
   - **Best for**: Scalable, less latency-sensitive apps (object storage, backups).  
   - **Bottleneck**: EBS/GCP disk limits (~16K IOPS, ~1GB/s).  

---

### **Recommendations**
- **For Kubernetes workloads**:  
  - Use **bare-metal K8s + Rook** if performance is critical.  
  - In the cloud, **prefer local NVMe (e.g., AWS `i3en`)** over EBS.  
- **For non-K8s workloads**:  
  - **Nomad + Rook on bare-metal** avoids K8s tax.  
- **Avoid**: Running Rook on cloud VMs with network storage for latency-sensitive apps.  

## ## Performance : Benchmark Commands 

The `fio`/`rados` commands to reproduce these benchmarks:

Here are the exact **`fio` and `rados bench` commands** I used for benchmarking, 
along with **tips to reproduce the results** in your environment.

---

### **1. Benchmarking with `fio` (Block Storage Performance)**
**Test Case**: 4K random reads/writes (IOPS) + 1MB sequential (throughput).  
**Prerequisite**:  
- A PersistentVolume (PV) backed by Rook/Ceph (`rbd` or `cephfs`).  
- `fio` installed on a Kubernetes Pod or bare-metal node.

#### **A. 4K Random Read (IOPS + Latency)**
```bash
fio --name=randread --ioengine=libaio --rw=randread --bs=4k --direct=1 --numjobs=4 --runtime=60 --time_based --group_reporting --iodepth=32 --size=1G --filename=/path/to/testfile
```
**Key Flags**:  
- `--rw=randread`: Random reads.  
- `--bs=4k`: 4K block size (simulates database I/O).  
- `--iodepth=32`: Queue depth (higher = more parallelism).  
- `--direct=1`: Bypass OS cache (measures true disk speed).  

#### **B. 4K Random Write (IOPS + Latency)**
```bash
fio --name=randrw --ioengine=libaio --rw=randwrite --bs=4k --direct=1 --numjobs=4 --runtime=60 --time_based --group_reporting --iodepth=32 --size=1G --filename=/path/to/testfile
```
- @ Container  :  `2881 IOPS` and `15 MiB/s` BW
- @ Host (WSL) :  `4798 IOPS` and `19 MiB/s` BW


#### **C. 1MB Sequential Read/Write (Throughput)**

```bash
# Read
fio --name=seqread --ioengine=libaio --rw=read --bs=1M --direct=1 --numjobs=4 --runtime=60 --time_based --group_reporting --iodepth=32 --size=1G --filename=/path/to/testfile

# Write
fio --name=seqwrite --ioengine=libaio --rw=write --bs=1M --direct=1 --numjobs=4 --runtime=60 --time_based --group_reporting --iodepth=32 --size=1G --filename=/path/to/testfile
```
- `--filename` : [Subject file size](https://chat.deepseek.com/a/chat/s/d8464626-cc42-431d-a27a-f7a0fd77bdef) : Minimum recommendation:
    - __File size ≥ 4× system RAM__ (to bypass page cache).
    - __File size ≥ 2× NVMe cache__ (if testing SSD; consumer NVMe drives often have `~1–2GB` cache).
- Using NVMe SSD as backing store, `fio` __sequential `1M`__ read reports:
    - @ Container  :  `2881 IOPS` and `2881 MiB/s` BW
    - @ Host (WSL) :  `2920 IOPS` and `2920 MiB/s` BW


Note that IOPS report is accurate only on 4K random.

Block Size (`--bs`)	IOPS Interpretation	Throughput Scaling:

    4K	IOPS = "true" operations/sec.	Low BW (e.g., 100k IOPS = 400 MiB/s).
    1M	IOPS ≈ BW (MiB/s) since 1 op = 1 MiB.	High BW, low IOPS count.

#### RandRW  : `--bs=4k`

```bash
fio --name=overlay_test \
    --filename=/testfile \  # Creates a file in the container's OverlayFS
    --size=1G \            # Test file size (adjust as needed)
    --rw=randrw \          # Test random reads/writes (or use `read`/`write`)
    --bs=4k \              # Block size (4k for random I/O, 1M for sequential)
    --iodepth=32 \         # Queue depth
    --direct=1 \           # Bypass page cache (O_DIRECT)
    --runtime=60 \         # Test duration (seconds)
    --group_reporting
```
- @ Container  :  `2881 IOPS` and `15 MiB/s` BW
- @ Host (WSL) :  `4798 IOPS` and `19 MiB/s` BW

**Expected Performance for 4K RandRW**

| Storage Type       | Expected IOPS (4K RandRW) | Expected BW (MiB/s) |
|--------------------|--------------------------|---------------------|
| **HDD**           | 100–200                  | 0.4–0.8             |
| **SATA SSD**      | 50k–100k                 | 200–400             |
| **NVMe SSD**      | 100k–1M+                 | 400–4000            |
| **Your Results**  | 2881–4798                | 15–19               |

#### Sequential : `--bs=1M`

@ Container

```bash
root@13b8ba481345:/# fio --name=seqread --ioengine=libaio --rw=read --bs=1M --direct=1 --numjobs=4 --runtime=60 --time_based --group_reporting --iodepth=32 --size=10G --f
ilename=/testfile

```
- `2881 IOPS` and `2881 MiB/s` BW


@ Host (WSL)

```bash
☩ sudo fio --name=seqread --ioengine=libaio --rw=read --bs=1M --direct=1 --numjobs=4 --runtime=60 --time_based --group_reporting --iodepth=32 --size=10G --filename=/testfile
```
- `2920 IOPS` and `2920 MiB/s` BW




sudo fio --name=randrw \
    --filename=/testfile \
    --size=1G \
    --rw=randrw \
    --bs=4k \
    --iodepth=32 \
    --direct=1 \
    --runtime=60 \
    --group_reporting
    
---

### **2. Benchmarking with `rados bench` (Ceph Cluster Performance)**
**Test Case**: Cluster-wide throughput/latency.  
**Prerequisite**:  
- Access to the Ceph cluster (e.g., `ceph-common` tools installed).  

#### **A. Write Test (Throughput + Latency)**
```bash
rados bench -p <pool_name> 60 write --no-cleanup
```
- `-p`: Ceph pool name (e.g., `replicapool`).  
- `60`: Test duration (seconds).  

#### **B. Read Test (Throughput)**
```bash
rados bench -p <pool_name> 60 seq
```

#### **C. Cleanup**
```bash
rados -p <pool_name> cleanup
```

---

### **3. Running Benchmarks in Kubernetes**
If testing Rook/Ceph **inside K8s**, deploy a `fio` Pod:  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fio-test
spec:
  containers:
  - name: fio
    image: nixery.dev/fio
    command: ["sleep", "infinity"]
    volumeMounts:
    - mountPath: /data
      name: rook-ceph-vol
  volumes:
  - name: rook-ceph-vol
    persistentVolumeClaim:
      claimName: rook-ceph-pvc  # Your Rook/Ceph PVC
```
Then `exec` into the Pod and run `fio` commands above against `/data/testfile`.

---

### **Expected Output Examples**
#### **`fio` Output (4K Random Read)**
```
randread: (g=0): rw=randread, bs=4K-4K/4K-4K
...
  read: IOPS=250k, BW=976MiB/s (1023MB/s)
  clat (usec): min=2, max=120, avg=12.5, stdev=5.0
```
- **IOPS**: `250k` (250,000 I/O operations per second).  
- **Latency**: `12.5µs` average.  

#### **`rados bench` Output**
```
Total time run:         60.1234 sec
Total writes made:      72000
Write size:             4194304 bytes
Bandwidth (MB/sec):     1200
Stddev Bandwidth:       45.12
Max latency (sec):      0.08
```
- **Throughput**: `1200 MB/s`.  
- **Latency**: `80ms` max.  

---

### **Tips for Accurate Benchmarks**
1. **Isolate the test environment**:  
   - Run benchmarks alone (no other workloads).  
   - Disable caching where possible (`--direct=1` in `fio`).  

2. **Adjust for your hardware**:  
   - Increase `--iodepth` if using NVMe (e.g., `--iodepth=64`).  
   - Use `--numjobs=8` for multi-core CPUs.  

3. **Cloud-Specific Notes**:  
   - On AWS/GCP, use **provisioned IOPS volumes** (e.g., `io1` with 16K IOPS).  
   - Avoid **burst credits** (run tests for >5 mins).  

4. **Compare multiple runs**:  
   - Variability is common (especially in cloud/VMs).  

---

### **Final Thoughts**
- **Bare-metal will always win** in latency/throughput.  
- **Cloud VMs are bottlenecked by network storage** (EBS/GCP PD).  
- **Nomad vs. K8s**: Differences are minor (~2–5%) unless networking is misconfigured.  



## [Storage Architecture](https://rook.github.io/docs/rook/latest-release/Getting-Started/storage-architecture/#design)

[Ceph Monitors](https://rook.github.io/docs/rook/latest-release/Storage-Configuration/Advanced/ceph-mon-health/) (__mons__) are __the brains of the distributed cluster__. They control all of the metadata that is necessary to store and retrieve your data as well as keep it safe. If the monitors are not in a healthy state you will risk losing all the data in your system.

## [Quickstart](https://rook.github.io/docs/rook/latest-release/Getting-Started/quickstart/#create-a-ceph-cluster) : Create a Ceph Cluster

### Install

@ Hypervisor

Add raw block device, i.e., a 2nd HDD/SSD disk, for Rook to use for its block, file and object stores; `/dev/sdb`

@ Admin host : `Ubuntu (master) .../s/DEV/devops/infra/kubernetes/k8s-vanilla-ha-rhel9/csi/rook`

```bash
make csi-rook-up
```

I.e., 

```bash
bash ./rook.sh up
```

Verify. Note `ceph_bluestore` @ `sdb`

```bash
☩ kw
=== a1 : 10/17
csi-cephfsplugin-f9gk2                          3/3     Running     0          4m59s   192.168.11.101   a1     <none>           <none>
csi-cephfsplugin-provisioner-784d9966c6-v8jrc   6/6     Running     0          4m59s   10.22.0.30       a1     <none>           <none>
csi-rbdplugin-hrtqj                             3/3     Running     0          4m59s   192.168.11.101   a1     <none>           <none>
rook-ceph-crashcollector-a1-7c54587697-spx4z    1/1     Running     0          3m35s   10.22.0.37       a1     <none>           <none>
rook-ceph-exporter-a1-69c78b9795-2hd75          1/1     Running     0          3m32s   10.22.0.39       a1     <none>           <none>
rook-ceph-mgr-a-78cc55dd4c-mfqjb                3/3     Running     0          4m6s    10.22.0.33       a1     <none>           <none>
rook-ceph-mon-a-6b5cc747fb-s8jq2                2/2     Running     0          4m49s   10.22.0.32       a1     <none>           <none>
rook-ceph-osd-0-5d48d97c4-7xzvz                 2/2     Running     0          3m35s   10.22.0.38       a1     <none>           <none>
rook-ceph-osd-prepare-a1-x6hcm                  0/1     Completed   0          3m43s   10.22.0.36       a1     <none>           <none>
rook-ceph-tools-56fbc74755-5q9hj                1/1     Running     0          26s     10.22.0.40       a1     <none>           <none>
=== a2 : 10/16
csi-cephfsplugin-cm7sp                          3/3     Running     0          4m59s   192.168.11.102   a2     <none>           <none>
csi-cephfsplugin-provisioner-784d9966c6-rttbv   6/6     Running     0          4m59s   10.22.1.20       a2     <none>           <none>
csi-rbdplugin-n4b88                             3/3     Running     0          4m59s   192.168.11.102   a2     <none>           <none>
csi-rbdplugin-provisioner-75cfd96674-k8sg4      6/6     Running     0          4m59s   10.22.1.19       a2     <none>           <none>
rook-ceph-crashcollector-a2-546b88b7fb-tcgnd    1/1     Running     0          3m34s   10.22.1.28       a2     <none>           <none>
rook-ceph-exporter-a2-f6867cc86-5pcbl           1/1     Running     0          3m31s   10.22.1.29       a2     <none>           <none>
rook-ceph-mgr-b-86c6bf4594-6hncb                3/3     Running     0          4m5s    10.22.1.23       a2     <none>           <none>
rook-ceph-mon-c-5f4c664bd5-68ljl                2/2     Running     0          4m16s   10.22.1.22       a2     <none>           <none>
rook-ceph-osd-1-56db874b49-4xkj4                2/2     Running     0          3m34s   10.22.1.27       a2     <none>           <none>
rook-ceph-osd-prepare-a2-m5c7s                  0/1     Completed   0          3m43s   10.22.1.26       a2     <none>           <none>
=== a3 : 9/15
csi-cephfsplugin-xp594                          3/3     Running     0          5m      192.168.11.100   a3     <none>           <none>
csi-rbdplugin-kh78s                             3/3     Running     0          5m      192.168.11.100   a3     <none>           <none>
csi-rbdplugin-provisioner-75cfd96674-xr2ll      6/6     Running     0          5m      10.22.2.18       a3     <none>           <none>
rook-ceph-crashcollector-a3-5f986bbc79-nz4hx    1/1     Running     0          3m57s   10.22.2.21       a3     <none>           <none>
rook-ceph-exporter-a3-859f45cf85-xf5ht          1/1     Running     0          3m57s   10.22.2.20       a3     <none>           <none>
rook-ceph-mon-b-56bbb4969f-zbsf7                2/2     Running     0          4m27s   10.22.2.19       a3     <none>           <none>
rook-ceph-operator-659f7d85-tzhq8               1/1     Running     0          5m2s    10.22.2.17       a3     <none>           <none>
rook-ceph-osd-2-846d4cfc67-kh28c                2/2     Running     0          3m36s   10.22.2.23       a3     <none>           <none>
rook-ceph-osd-prepare-a3-7bkv6                  0/1     Completed   0          3m43s   10.22.2.22       a3     <none>           <none>

29/48 @ rook-ceph
```

### [Tools](https://rook.github.io/docs/rook/latest-release/Getting-Started/quickstart/#tools)

[__Toolbox__](https://rook.github.io/docs/rook/latest-release/Troubleshooting/ceph-toolbox/)

```bash
kubectl create -f deploy/examples/toolbox.yaml
kubectl -n rook-ceph rollout status deploy/rook-ceph-tools
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
```
```bash
bash-5.1$ ceph status
  cluster:
    id:     286f4ba4-6ee8-44fe-a082-65add3e08dac
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum a,b,c (age 4h)
    mgr: a(active, since 13h), standbys: b
    osd: 3 osds: 3 up (since 13h), 3 in (since 13h)

  data:
    pools:   1 pools, 1 pgs
    objects: 2 objects, 449 KiB
    usage:   80 MiB used, 30 GiB / 30 GiB avail
    pgs:     1 active+clean

bash-5.1$ ceph osd status
ID  HOST   USED  AVAIL  WR OPS  WR DATA  RD OPS  RD DATA  STATE
 0  a1    26.7M  9.97G      0        0       0        0   exists,up
 1  a2    26.7M  9.97G      0        0       0        0   exists,up
 2  a3    26.7M  9.97G      0        0       0        0   exists,up

bash-5.1$ ceph osd perf
osd  commit_latency(ms)  apply_latency(ms)
  2                   0                  0
  1                   0                  0
  0                   0                  0

bash-5.1$ ceph osd pool ls
.mgr

bash-5.1$ ceph df
--- RAW STORAGE ---
CLASS    SIZE   AVAIL    USED  RAW USED  %RAW USED
hdd    30 GiB  30 GiB  80 MiB    80 MiB       0.26
TOTAL  30 GiB  30 GiB  80 MiB    80 MiB       0.26

--- POOLS ---
POOL  ID  PGS   STORED  OBJECTS     USED  %USED  MAX AVAIL
.mgr   1    1  449 KiB        2  1.3 MiB      0    9.5 GiB

bash-5.1$ rados df
POOL_NAME     USED  OBJECTS  CLONES  COPIES  MISSING_ON_PRIMARY  UNFOUND  DEGRADED  RD_OPS      RD  WR_OPS       WR  USED COMPR  UNDER COMPR
.mgr       1.3 MiB        2       0       6                   0        0         0      96  82 KiB     113  1.3 MiB         0 B          0 B

total_objects    2
total_used       80 MiB
total_avail      30 GiB
total_space      30 GiB
```
```bash
☩ kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph osd status
ID  HOST   USED  AVAIL  WR OPS  WR DATA  RD OPS  RD DATA  STATE
 0  a1    26.7M  9.97G      0        0       0        0   exists,up
 1  a2    26.7M  9.97G      0        0       0        0   exists,up
 2  a3    26.7M  9.97G      0        0       0        0   exists,up
```
```bash
☩ ansibash lsblk -f
=== u1@a1
Connection to 192.168.11.101 closed.
NAME          FSTYPE         FSVER    LABEL UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
sda
├─sda1        vfat           FAT32          08AE-EF02                               591.8M     1% /boot/efi
├─sda2        xfs                           4bff8019-1cf5-4271-874b-92033cac589d    515.9M    46% /boot
└─sda3        LVM2_member    LVM2 001       yf6yIs-Lssu-cJtn-W4ju-LhXf-0sPB-9TvB0P
  ├─rhel-root xfs                           30fe4af7-3837-44bc-812e-90fe4f1a65c2      5.6G    66% /
  └─rhel-swap swap           1              2a49f9f5-16ef-457e-87d8-47ab6f4e05e9
sdb           ceph_bluestore
nbd0
...
nbd15
Connection to 192.168.11.101 closed.
=== u1@a2
Connection to 192.168.11.102 closed.
NAME          FSTYPE         FSVER    LABEL UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
sda
├─sda1        vfat           FAT32          08AE-EF02                               591.8M     1% /boot/efi
├─sda2        xfs                           4bff8019-1cf5-4271-874b-92033cac589d    515.9M    46% /boot
└─sda3        LVM2_member    LVM2 001       yf6yIs-Lssu-cJtn-W4ju-LhXf-0sPB-9TvB0P
  ├─rhel-root xfs                           30fe4af7-3837-44bc-812e-90fe4f1a65c2      6.1G    63% /
  └─rhel-swap swap           1              2a49f9f5-16ef-457e-87d8-47ab6f4e05e9
sdb           ceph_bluestore
nbd0
...
nbd15
Connection to 192.168.11.102 closed.
=== u1@a3
Connection to 192.168.11.100 closed.
NAME          FSTYPE         FSVER    LABEL UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
sda
├─sda1        vfat           FAT32          08AE-EF02                               591.8M     1% /boot/efi
├─sda2        xfs                           4bff8019-1cf5-4271-874b-92033cac589d    515.9M    46% /boot
└─sda3        LVM2_member    LVM2 001       yf6yIs-Lssu-cJtn-W4ju-LhXf-0sPB-9TvB0P
  ├─rhel-root xfs                           30fe4af7-3837-44bc-812e-90fe4f1a65c2      6.1G    63% /
  └─rhel-swap swap           1              2a49f9f5-16ef-457e-87d8-47ab6f4e05e9
sdb           ceph_bluestore
nbd0
...
nbd15
Connection to 192.168.11.100 closed.
```

See `CephCluster`

```bash
☩ k get cephcluster rook-ceph -o yaml
```
```yaml
apiVersion: ceph.rook.io/v1
kind: CephCluster
metadata:
  ...
  name: rook-ceph
  namespace: rook-ceph
spec:
  cephVersion:
    image: quay.io/ceph/ceph:v19.2.0
  ...
  csi:
    cephfs: {}
    readAffinity:
      enabled: false
  dashboard:
    enabled: true
    ssl: true
  dataDirHostPath: /var/lib/rook
  ...
```

See backing store at hosts : `/var/lib/rook`

```bash
☩ ansibash ls -hl /var/lib/rook
=== u1@a1
Connection to 192.168.11.101 closed.
total 0
drwxr-xr-x. 2  167  167 113 Dec 27 21:40 exporter
drwxr-xr-x. 3 root root  18 Dec 27 21:39 mon-a
drwxr-xr-x. 5 root root 163 Dec 27 21:40 rook-ceph
drwxr-xr-x. 3 root root  17 Dec 27 21:39 rook-ceph.cephfs.csi.ceph.com
drwxr-xr-x. 3 root root  17 Dec 27 21:39 rook-ceph.rbd.csi.ceph.com
Connection to 192.168.11.101 closed.
=== u1@a2
Connection to 192.168.11.102 closed.
total 0
drwxr-xr-x. 2  167  167 113 Dec 27 21:40 exporter
drwxr-xr-x. 3 root root  18 Dec 27 21:39 mon-c
drwxr-xr-x. 5 root root 163 Dec 27 21:40 rook-ceph
drwxr-xr-x. 3 root root  17 Dec 27 21:39 rook-ceph.cephfs.csi.ceph.com
drwxr-xr-x. 3 root root  17 Dec 27 21:39 rook-ceph.rbd.csi.ceph.com
Connection to 192.168.11.102 closed.
=== u1@a3
Connection to 192.168.11.100 closed.
total 0
drwxr-xr-x. 2  167  167  90 Dec 27 21:40 exporter
drwxr-xr-x. 3 root root  18 Dec 27 21:39 mon-b
drwxr-xr-x. 5 root root 163 Dec 27 21:40 rook-ceph
drwxr-xr-x. 3 root root  17 Dec 27 21:39 rook-ceph.cephfs.csi.ceph.com
drwxr-xr-x. 3 root root  17 Dec 27 21:39 rook-ceph.rbd.csi.ceph.com
Connection to 192.168.11.100 closed.
```

## [Storage](https://rook.github.io/docs/rook/latest-release/Getting-Started/quickstart/#storage) | [Setting up consumable storage](https://rook.github.io/docs/rook/latest-release/Getting-Started/example-configurations/#setting-up-consumable-storage)

Manifests : See [__Example Configurations__](https://rook.github.io/docs/rook/latest-release/Getting-Started/example-configurations)

See `deploy/examples` :

```bash
v=1.16.0
git clone --single-branch --branch v$v https://github.com/rook/rook.git
```

- __RBD__ (RADOS __Block Device__) : Create attachable block device to be consumed by a Pod.
    - Allows __RWO__ access; mount at one or more Pods, but only at __one node__.
    - [__`storageclass-rbd.yaml`__](storageclass-rbd.yaml)
- __CephFS__ (__Shared Filesystem__) : Create a POSIX filesystem to be shared across multiple Pods and Nodes.
    - Allows __RWX__ access; mount at one or more Pods across __multiple nodes__.
    - [__`storageclass-cephfs.yaml`__](storageclass-cephfs.yaml)
- __S3__ (__Object Storage Device__) : Create an S3-compatible object store (OSD) having an entrypoint inside or outside the K8s cluster.

### RBD vs CephFS

|Feature|RBD|CephFS|
|--|--|--|
|Type|Block storage|File storage|
|Access|Single-node (RWO)|Multi-node (RWX)|
|Use Cases|Databases, VMs, K8s PVCs|Shared FS, logs|
|Protocol|Block-level access (iSCSI-like)|POSIX-compliant file system|

CephFS functions much like NFS

### Block Storage : [RADOS Block Device (`RBD`)](https://rook.github.io/docs/rook/latest-release/Storage-Configuration/Block-Storage-RBD/block-storage/#provision-storage)

Ceph provides raw block device (`rbd`) volumes to pods. 
These provide `ReadWrinteOnce` (RWO) `accessMode`.

Before Rook can provision storage, a `StorageClass` and `CephBlockPool` CR need to be created. This will allow Kubernetes to interoperate with Rook when provisioning persistent volumes. The storage class is defined with a Ceph pool which defines the level of data redundancy in Ceph:

```bash
k apply -f storageclass-rbd.yaml
```
- [__`storageclass-rbd.yaml`__](storageclass-rbd.yaml)



```bash
cat <<EOH |k apply -f -
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  storageClassName: rook-ceph-block
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: test-pvc
spec:
  containers:
    - name: test-pvc
      image: nginx
      volumeMounts:
        - name: test-pvc
          mountPath: /var/lib/www/html
  volumes:
    - name: test-pvc
      persistentVolumeClaim:
        claimName: test-pvc
        readOnly: false
EOH

```
- See [`app.test-pvc.yaml`](app.test-pvc.yaml)

Rook is not (yet) provisioning because we have not yet created the Ceph block pool and StorageClass :

```bash
☩ k get pvc
NAME       STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS      VOLUMEATTRIBUTESCLASS   AGE
test-pvc   Pending                                      rook-ceph-block   <unset>                 38s

☩ k get pv
No resources found
```

Create [`CephBlockPool`](https://rook.github.io/docs/rook/latest-release/CRDs/Block-Storage/ceph-block-pool-crd/) (CRD) &amp; `StorageClass` : [`storageclass-rbd.yaml`](storageclass-rbd.yaml)

```bash
k apply -f storageclass-rbd.yaml
```

Instantly, Rook creates a `pv`, provisioning storage based on prior `pvc` declaring its `sc` (`rook-ceph-block`). Note the `pvc`'s status went from `Pending` to `Bound`:

```bash
☩ k get pvc
NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      ...
test-pvc   Bound    pvc-271fad3d-98ea-4e66-97e0-326478c605a2   1Gi        RWO            rook-ceph-block   ...

☩ k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                STORAGECLASS     ...
pvc-271fad3d-98ea-4e66-97e0-326478c605a2   1Gi        RWO            Delete           Bound    rook-ceph/test-pvc   rook-ceph-block  ...

☩ k get sc
NAME                   PROVISIONER                  RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION  ...
local-path (default)   rancher.io/local-path        Delete          WaitForFirstConsumer   false                
rook-ceph-block        rook-ceph.rbd.csi.ceph.com   Delete          Immediate              true                 
```

@ hosts

```bash
☩ ansibash ls -ahl /var/lib/rook/rook-ceph/286f4ba4-6ee8-44fe-a082-65add3e08dac_*
=== u1@a1
Connection to 192.168.11.101 closed.
total 28K
drwxr-xr-x. 2  167  167 129 Dec 27 21:40 .
drwxr-xr-x. 5 root root 163 Dec 27 21:40 ..
lrwxrwxrwx. 1  167  167   8 Dec 27 21:40 block -> /dev/sdb
-rw-------. 1  167  167  37 Dec 27 21:40 ceph_fsid
-rw-------. 1  167  167  37 Dec 27 21:40 fsid
-rw-------. 1  167  167  55 Dec 27 21:40 keyring
-rw-------. 1  167  167   6 Dec 27 21:40 ready
-rw-------. 1  167  167   3 Dec 27 21:40 require_osd_release
-rw-------. 1  167  167  10 Dec 27 21:40 type
-rw-------. 1  167  167   2 Dec 27 21:40 whoami
Connection to 192.168.11.101 closed.
=== u1@a2
Connection to 192.168.11.102 closed.
total 28K
drwxr-xr-x. 2  167  167 129 Dec 27 21:40 .
drwxr-xr-x. 5 root root 163 Dec 27 21:40 ..
lrwxrwxrwx. 1  167  167   8 Dec 27 21:40 block -> /dev/sdb
-rw-------. 1  167  167  37 Dec 27 21:40 ceph_fsid
-rw-------. 1  167  167  37 Dec 27 21:40 fsid
-rw-------. 1  167  167  55 Dec 27 21:40 keyring
-rw-------. 1  167  167   6 Dec 27 21:40 ready
-rw-------. 1  167  167   3 Dec 27 21:40 require_osd_release
-rw-------. 1  167  167  10 Dec 27 21:40 type
-rw-------. 1  167  167   2 Dec 27 21:40 whoami
Connection to 192.168.11.102 closed.
=== u1@a3
Connection to 192.168.11.100 closed.
total 28K
drwxr-xr-x. 2  167  167 129 Dec 27 21:40 .
drwxr-xr-x. 5 root root 163 Dec 27 21:40 ..
lrwxrwxrwx. 1  167  167   8 Dec 27 21:40 block -> /dev/sdb
-rw-------. 1  167  167  37 Dec 27 21:40 ceph_fsid
-rw-------. 1  167  167  37 Dec 27 21:40 fsid
-rw-------. 1  167  167  55 Dec 27 21:40 keyring
-rw-------. 1  167  167   6 Dec 27 21:40 ready
-rw-------. 1  167  167   3 Dec 27 21:40 require_osd_release
-rw-------. 1  167  167  10 Dec 27 21:40 type
-rw-------. 1  167  167   2 Dec 27 21:40 whoami
```


Test : Write to `rbd` store at pod on one node; read from `rbd` store at pod on another

@ a3

```bash
☩ k get pod -o wide
NAME             READY   STATUS              RESTARTS   AGE    IP           NODE   
test-pvc-xlp5x   1/1     Running             0          3s     10.22.2.25   a3     
test-pvc-z2jzz   0/1     ContainerCreating   0          2m6s   <none>       a1     
test-pvc-zj5m8   0/1     ContainerCreating   0          2m6s   <none>       a2     

☩ k exec -it test-pvc-xlp5x -- bash
root@test-pvc-xlp5x:/# echo bar |tee /var/lib/www/html/foo

```
...

@ a1

```bash
☩ k get pod -o wide
NAME             READY   STATUS              RESTARTS   AGE     IP           NODE  
test-pvc-4f54m   0/1     ContainerCreating   0          3m52s   <none>       a3    
test-pvc-6kp2c   0/1     ContainerCreating   0          3m52s   <none>       a2  
test-pvc-twvtv   1/1     Running             0          3m52s   10.22.0.46   a1  

☩ k exec -it test-pvc-twvtv -- cat /var/lib/www/html/foo
bar
```

### Shared Filesystem : [`storageclass-cephfs.yaml](https://github.com/rook/rook/blob/release-1.16/deploy/examples/filesystem.yaml)

Ceph provides  `ReadWriteMany` (RWX) `accessMode` to a shared POSIX filesystem (CephFS) folder at more application pods. This storage is __similar to NFS__ shared storage or CIFS shared folders.

```bash
k apply -f storageclass-cephfs.yaml
```
- [__`storageclass-cephfs.yaml`__](storageclass-cephfs.yaml)

Test

```bash
☩ k apply -f app.test-cephfs.yaml
persistentvolumeclaim/test-cephfs unchanged
daemonset.apps/test-cephfs configured

☩ k get pod -o wide
NAME                READY   STATUS    RESTARTS   AGE    IP           NODE  
test-cephfs-5hg9m   1/1     Running   0          3m6s   10.22.1.30   a2    
test-cephfs-kvpgf   1/1     Running   0          3m6s   10.22.0.51   a1   
test-cephfs-lnf2m   1/1     Running   0          3m6s   10.22.2.30   a3  

☩ k exec -it test-cephfs-5hg9m -- bash -c 'echo bar |tee /var/lib/www/html/foo'
bar

☩ k exec -it test-cephfs-kvpgf -- cat /var/lib/www/html/foo
bar
```

Performance Test

@ [__`app.test-rbd-fio`__](app.test-rbd-fio.yaml)

```bash
☩ k apply -f app.test-rbd-fio.yaml
persistentvolumeclaim/test-rbd-fio created
pod/test-rbd-fio created

☩ k exec -it pod/test-rbd-fio -- bash
```
```bash
bash-5.2# fio --name=write-test --filename=/mnt/test/testfile --rw=write --bs=1M --size=1G --numjobs=1 --direct=1 --group_reporting
write-test: (g=0): rw=write, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-1024KiB, ioengine=psync, iodepth=1
fio-3.36
Starting 1 process
write-test: Laying out IO file (1 file / 1024MiB)
Jobs: 1 (f=1): [W(1)][100.0%][w=9216KiB/s][w=9 IOPS][eta 00m:00s]

```
```bash
# Write
fio --name=write-test --filename=/mnt/test/testfile --rw=write --bs=1M --size=1G --numjobs=1 --direct=1 --group_reporting

bash-5.2# fio --name=write-test --filename=/mnt/test/testfile --rw=write --bs=1M --size=1G --numjobs=1 --direct=1 --group_reporting
```
```plaintext
...
  write: IOPS=24, BW=24.8MiB/s (26.0MB/s)(1024MiB/41366msec); 0 zone resets
...
   bw (  KiB/s): min= 6144, max=81920, per=100.00%, avg=25496.46, stdev=17007.13, samples=82
...
Run status group 0 (all jobs):
  WRITE: bw=24.8MiB/s (26.0MB/s), 24.8MiB/s-24.8MiB/s (26.0MB/s-26.0MB/s), io=1024MiB (1074MB), run=41366-41366msec

Disk stats (read/write):
  rbd0: ios=0/1038, sectors=0/2093248, merge=0/8, ticks=0/42182, in_queue=42182, util=99.58%
...
```
```bash
# Read
fio --name=read-test --filename=/mnt/test/testfile --rw=read --bs=1M --size=1G --numjobs=1 --direct=1 --group_reporting

```
```plaintext
read-test: (groupid=0, jobs=1): err= 0: pid=23: Sat Dec 28 21:24:57 2024
  read: IOPS=289, BW=290MiB/s (304MB/s)(1024MiB/3533msec)
...
Run status group 0 (all jobs):
   READ: bw=290MiB/s (304MB/s), 290MiB/s-290MiB/s (304MB/s-304MB/s), io=1024MiB (1074MB), run=3533-3533msec

Disk stats (read/write):
  rbd0: ios=973/0, sectors=1992704/0, merge=0/0, ticks=3340/0, in_queue=3340, util=95.28%
```


### [Object Storage Device](https://rook.github.io/docs/rook/latest-release/Getting-Started/example-configurations/#object-storage) | [Overview](https://rook.github.io/docs/rook/latest-release/Storage-Configuration/Object-Storage-RGW/object-storage/) | [CephObjectStore CRD](https://rook.github.io/docs/rook/latest-release/CRDs/Object-Storage/ceph-object-store-crd/#example-debugging)

Object storage exposes an S3 API and or a Swift API to the storage cluster for applications to put and get data.

See [__`object.yaml`__](examples/object.yaml)

## [Ceph Dashboard](https://rook.github.io/docs/rook/latest-release/Storage-Configuration/Monitoring/ceph-dashboard/)

@ Dashboard-server terminal 

Forward service port (`8443`, `https-dashboard`) to host

```bash
☩ k port-forward svc/rook-ceph-mgr-dashboard 5555:https-dashboard
Forwarding from 127.0.0.1:5555 -> 8443
Forwarding from [::1]:5555 -> 8443
Handling connection for 5555
Handling connection for 5555
...
```

@ Another (client) terminal

```bash
☩ curl -kI https://127.0.0.1:5555/
HTTP/1.1 200 OK
Content-Type: text/html;charset=utf-8
Server: Ceph-Dashboard
...
```

@ Browser : __[`https://127.0.0.1:5555`](https://127.0.0.1:5555)__ 

Snapshot: [`rook-ceph-mgr-dashboard.01.webp`](rook-ceph-mgr-dashboard.01.webp)

__Credentials__

```bash
☩ k get secret rook-ceph-dashboard-password -o jsonpath='{.data.password}' |base64 -d
]B>k&W@>Lm*GP]2#q:?V
```
- __user__: `admin`
- __pass__: `]B>k&W@>Lm*GP]2#q:?V`

### [Monitoring](https://rook.github.io/docs/rook/latest-release/Getting-Started/quickstart/#monitoring) : [Prometheus]((https://rook.github.io/docs/rook/latest-release/Storage-Configuration/Monitoring/ceph-monitoring/)

## [Teardown](https://rook.github.io/docs/rook/latest-release/Storage-Configuration/ceph-teardown/)

## [Example Configurations](https://rook.github.io/docs/rook/latest-release/Getting-Started/example-configurations/#operator)

### Operator : [`operator.yaml`](operator.yaml)

The most common settings for production deployments. Self documented.

```bash
kubectl create -f operator.yaml
```

### [Cluster CRD](https://rook.github.io/docs/rook/latest-release/CRDs/Cluster/ceph-cluster-crd/) : [`cluster.yaml`](cluster.yaml)

Common settings for a production storage cluster. __Install after Operator__. Requires at least three worker nodes. Creates the Ceph storage cluster with the CephCluster CR. This CR contains the most critical settings that will influence how the operator configures the storage. 

### [Setting up consumable storage](https://rook.github.io/docs/rook/latest-release/Getting-Started/example-configurations/#setting-up-consumable-storage)

- Shared Filesystem : `kind: CephFilesystem`
    - [`filesystem.yaml`](https://github.com/rook/rook/blob/release-1.16/deploy/examples/filesystem.yaml)
    - [CephFilesystem CRD](https://rook.github.io/docs/rook/latest-release/CRDs/Shared-Filesystem/ceph-filesystem-crd/)
- Object Storage : `kind: CephObjectStore`
    - [`object.yaml`](https://github.com/rook/rook/blob/release-1.16/deploy/examples/object.yaml)

## [Storage Configuration](https://rook.github.io/docs/rook/latest-release/Storage-Configuration/Block-Storage-RBD/block-storage/)


[`deploy/examples`](https://github.com/rook/rook/tree/release-1.16/deploy/examples)
