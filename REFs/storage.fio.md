# FIO : `fio` : [Flexible I/O Tester](https://fio.readthedocs.io/en/latest/fio_doc.html#examples) (Benchmarking)

##  Install

@ RHEL 
```bash
sudo dnf update -y
sudo dnf install -y fio

# Else
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf install -y fio

# Verify
fio --version # fio-3.13
```
@ Win

```bat
choco install -y fio

:: Verify
fio.exe --version
```

## TL;DR

Phy I/O performance is 30% improvement over VM, and 10x over WSL.

Performance at Random RW (4k)

|Type|IOPS [k]|BW [MB/s]      |
|----|----|--------|
|Phy |67 |273 |
|VM  |51 |209 |
|WSL2|4.7|19  |
|NFS |2.4|0.99|

### Two target/test options : Device or FS

#### FS

- `--filename=/path/to/file`
- `--filename=/path/to/dir` : Creates file therein

1. Testing filesystem performance (ext4, XFS, etc.).
1. Simulates __real-world file access__ patterns (e.g., databases, logs).
1. Avoids direct hardware access (safer for shared systems).

### Device

- `--filename=/dev/sdX` : Requires flags: 
    - `--direct=1` :	Bypasses OS page cache (measures real disk speed)
    - `--ioengine=libaio` (or `io_uring`) :	Enables async I/O for accurate results
    - `--numjobs=4`	: Increases parallel I/O for SSDs

1. Measuring __raw disk performance__ (bypassing filesystem).
1. Benchmarking SSDs/NVMe drives for __maximum throughput/latency__.
1. Avoiding filesystem caching effects.

@ Container : `nixery.dev/shell/fio:latest`

```bash
☩ k exec -it test-fio-pod -- fio --name=randrw \
    --rw=randrw \
    --size=1G \
    --bs=4k \
    --iodepth=32 \
    --direct=1 \
    --runtime=60 \
    --time_based \
    --ioengine=libaio \
    --group_reporting \
    --filename=192.168.11.100:/srv/nfs/k8s/fiotest \
    |grep -e read: -e write:

  read: IOPS=37.6k, BW=147MiB/s (154MB/s)(8806MiB/60001msec)
  write: IOPS=37.5k, BW=147MiB/s (154MB/s)(8799MiB/60001msec); 0 zone resets
```

## @ NVMe : Random R/W (`bs=4k`)

AirDisk (Benchmarked at 1/3 performance of name brands)

`--randread` and `--randwrite` measure __peak performance__ for a single operation.

`--randrw` measures __realistic__ mixed workload __performance__, where reads and writes compete.

Expect 2x BW and 2x IOPS at `--randread` or `--randwrite` relative to `--randrw` performance. 
The latter better represents real world (mixed) performance.
Sum of the former (pure read or write) is theoretical performance.


@ Windows physical machine where `C:` is NVMe SSD having about 1/3 performance of most name brands:


```ini
S:\>fio.exe --rw=randrw --name=test  --size=1G --bs=4k --iodepth=32 --runtime=60 --group_reporting --filename=C:\testfile
...
  read: IOPS=66.8k, BW=261MiB/s (273MB/s)(512MiB/1963msec)
  ...
  write: IOPS=66.8k, BW=261MiB/s (274MB/s)(512MiB/1963msec)
  ...
```
- Some 30% more performant than VM (Hyper-V)
- Partitions (`C`, `S`, `W`) of various sizes (same disk) perform equivalently.
- SanDisk NVMe USB performs equivalently.

@ Hyper-V VM (`u1@a0`) : RHEL9 : __Dynamic__ disk : `/dev/sdb`

```bash
☩ sudo fio --name=randrw \
    --rw=randrw \
    --size=1G \
    --bs=4k \
    --iodepth=32 \
    --direct=1 \
    --runtime=60 \
    --ioengine=libaio \
    --group_reporting \
    --filename=/dev/sdb

  ...
  read:  IOPS=51.0k, BW=199MiB/s (209MB/s)(512MiB/2570msec)
  ...
  write: IOPS=51.0k, BW=199MiB/s (209MB/s)(512MiB/2570msec); 0 zone resets
  ...
```
- __10x relative to WSL2__

@ Hyper-V VM (`u1@a0`) : RHEL9 : __Static__ disk : `/dev/sdc`

```bash
☩ sudo fio --name=randrw \
    --rw=randrw \
    --size=1G \
    --rw=randrw \
    --bs=4k \
    --iodepth=32 \
    --direct=1 \
    --runtime=60 \
    --ioengine=libaio \
    --group_reporting \
    --filename=/dev/sdc

...
  read:  IOPS=45.6k, BW=178MiB/s (187MB/s)(512MiB/2875msec)
  ...
  write: IOPS=45.6k, BW=178MiB/s (187MB/s)(512MiB/2875msec); 0 zone resets
  ...
```
- Slightly _less performant_ than Dynamic disk.

Get pure (AKA theoretical) IOPS: Sum that of read and write:

@ Hyper-V VM (`u1@a0`) : RHEL9 : __Static__ disk : `/dev/sdc`

```bash
☩ sudo fio --name=randrw  \
    --rw=randrw \
    --size=1G \
    --rw=randrw \
    --bs=4k \
    --iodepth=32 \
    --direct=1 \
    --runtime=60 \
    --ioengine=libaio \
    --group_reporting \
    --filename=/dev/sdc \
    --output-format=json \
     |tee fio.randrw.dev.sdc.json

☩ cat fio.randrw.dev.sdc.json |jq '.jobs[0].read.iops + .jobs[0].write.iops'
69774.820336
```
- IOPS : `69,774` (pure AKA theoretical only)


@ WSL2 : `/s`

```bash
☩ sudo fio --name=randrw \
    --rw=randrw \
    --size=1G \
    --bs=4k \
    --iodepth=32 \
    --direct=1 \
    --runtime=60 \
    --ioengine=libaio \
    --filename=/s/fiotest \
    --group_reporting

...
  read:  IOPS=4698, BW=18.4MiB/s (19.2MB/s)(512MiB/27888msec)
  ...
  write: IOPS=4701, BW=18.4MiB/s (19.3MB/s)(512MiB/27888msec); 0 zone resets
  ...
```
- Worst performer. 10x worse.


### NFS


@ NFS server 

```bash
☩ k exec -it test-fio-pod -- fio --name=randrw \
    --rw=randrw \
    --size=1G \
    --bs=4k \
    --iodepth=32 \
    --direct=1 \
    --runtime=60 \
    --time_based \
    --ioengine=libaio \
    --group_reporting \
    --filename=192.168.11.100:/srv/nfs/k8s/default-test-fio-claim-pvc-6ec4b98e-2bac-4aec-a1f2-44dcbef828be \
    |grep -e read: -e write:
  read: IOPS=32.9k, BW=129MiB/s (135MB/s)(7713MiB/60001msec)
  write: IOPS=32.9k, BW=128MiB/s (135MB/s)(7705MiB/60001msec); 0 zone resets
```
- Declare either a folder or file as the target
    - `--filename=192.168.11.100:/srv/nfs/k8s/default-test-fio-claim-pvc-6ec4b98e-2bac-4aec-a1f2-44dcbef828be`
    - `--filename=192.168.11.100:/srv/nfs/k8s/fiotest`

Using NFS performance tuning : `async,no_wdelay,fsid=0`

@ Pod application : 10x performance degredation relative to server side.

```bash
☩ k exec -it test-fio-pod -- fio --name=randrw \
    --rw=randrw \
    --size=1G \
    --bs=4k \
    --iodepth=32 \
    --direct=1 \
    --runtime=60 \
    --time_based \
    --ioengine=libaio \
    --group_reporting \
    --filename=/mnt/fiotest \
    |grep -e read: -e write:

  read: IOPS=5617, BW=21.9MiB/s (23.0MB/s)(1317MiB/60003msec)
  write: IOPS=5610, BW=21.9MiB/s (23.0MB/s)(1315MiB/60003msec); 0 zone resets

```



## @ NVMe : Sequential Read

@ Windows

```bat
C:\TEMP>fio.exe --name=seqread --filename=C:\testfile --size=1G --rw=read --bs=1M --iodepth=32 --runtime=60 --group_reporting
...
  read: IOPS=3038, BW=3039MiB/s (3186MB/s)(1024MiB/337msec)
...

del C:\testfile 
```

## @ NVMe : Sequential Write

@ Linux

```bash
sudo fio --name=seqread --filename=/testfile --size=1G --rw=read --bs=1M --iodepth=32 --runtime=60 --group_reporting
rm /testfile
```


<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->
