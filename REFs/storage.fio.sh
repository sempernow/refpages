#!/usr/bin/env bash
# -----------------------------------------------------------------------------
#  IOPS test using fio 
# 
#  ARGs: TEST_DIR [SIZE_PER]
# 
#        Example SIZE_PER value: "10G" 
# -----------------------------------------------------------------------------
# https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance-linux

! type -t fio && type -t apt && sudo apt update && sudo apt install -y fio
! type -t fio && type -t dnf && sudo dnf update && sudo dnf install -y fio
type -t fio || exit 1

[[ $1 ]] && TEST_DIR="$1" || TEST_DIR="$(pwd)/iops-test"
[[ $2 ]] && SIZE_PER=$2   || SIZE_PER=1G
LOG="iops-test-${TEST_DIR////.}"
sudo mkdir -p $TEST_DIR

echo "=== $SIZE_PER @ '$TEST_DIR'"

# Test write throughput by performing sequential writes with multiple parallel streams (16+), 
# using an I/O block size of 1 MB and an I/O depth of at least 64:
echo '=== Writes : Sequential 1MB'
sudo fio --name=write_throughput --directory="$TEST_DIR" --numjobs=16 \
    --size=$SIZE_PER --time_based --runtime=60s --ramp_time=2s --ioengine=libaio \
    --direct=1 --verify=0 --bs=1M --iodepth=64 --rw=write \
    --group_reporting=1 --iodepth_batch_submit=64 \
    --iodepth_batch_complete_max=64 \
    |tee "$LOG.log"


# Test read throughput by performing sequential reads with multiple parallel streams (16+), 
# using an I/O block size of 1 MB and an I/O depth of at least 64:
echo '=== Reads : Sequential 1MB'
sudo fio --name=read_throughput --directory="$TEST_DIR" --numjobs=16 \
    --size=$SIZE_PER --time_based --runtime=60s --ramp_time=2s --ioengine=libaio \
    --direct=1 --verify=0 --bs=1M --iodepth=64 --rw=read \
    --group_reporting=1 \
    --iodepth_batch_submit=64 --iodepth_batch_complete_max=64 \
    |tee -a "$LOG.log"


cat "$LOG.log" |grep -e === -e fio- -e IOPS |tee "$LOG.summary.log"

# Clean up:
sudo rm -rf "$TEST_DIR"

exit $?
####################################

# Segregating Random R/W reveals only the pure (theoretical) limits, 
# not most real-world scenarios.

# Test read IOPS by performing random reads, 
# using an I/O block size of 4 KB and an I/O depth of at least 256:
echo '=== Reads : Random 4KB'
sudo fio --name=read_iops --directory="$TEST_DIR" --size=$SIZE_PER \
    --time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 \
    --verify=0 --bs=4K --iodepth=256 --rw=randread --group_reporting=1 \
    --iodepth_batch_submit=256  --iodepth_batch_complete_max=256 \
    |tee -a "$LOG.log"

# Test write IOPS by performing random writes, 
# using an I/O block size of 4 KB and an I/O depth of at least 256:
echo '=== Writes : Random 4KB'
 sudo fio --name=write_iops --directory="$TEST_DIR" --size=$SIZE_PER \
    --time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 \
    --verify=0 --bs=4K --iodepth=256 --rw=randwrite --group_reporting=1  \
    --iodepth_batch_submit=256  --iodepth_batch_complete_max=256 \
    |tee -a "$LOG.log"
