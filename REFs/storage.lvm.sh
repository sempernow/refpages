#!/usr/bin/env bash
#####################################################
# LVM : Inspect|Create|Delete : DEVICE : VGs : LVs
# - Create an LVM-based data store
# - Idempotent
#
# ARGs: inspect|create|destroy 
#####################################################
[[ $(whoami) == 'root' ]] || exit 1

### Example 
#
# $ blkid
# /dev/sdb1
#
# $ lsblk
# sdb            
# └─sdb1         
#   └─data-nfs1  
#
# $ df
# Filesystem            Type ... Mounted on
# /dev/mapper/data-nfs1 xfs  ... /srv/nfs/k8s

blk=sdb         # Typical naming convention
dev=/dev/$blk   # Typical naming convention
pv=${dev}1      # Select apropos number
vg=nfs1
lv=data
mount="/srv/nfs/k8s"

inspect(){
    pvdisplay $pv &&
        vgdisplay $lv &&
            lvm lvdisplay --maps $lv ||
                return

    # Physical Volumes  (PVs)
    pvs

    # Volume Groups     (VGs)
    vgs

    # Logical Volumes   (LVs)
    lvs -a -o +devices

    # LVs per device
    lsblk;echo;lvscan
}

create(){
    # Abort if block device does not exist
    lsblk -ndo NAME,SIZE,TYPE,MODEL |grep -q "\b$blk\b" ||
        exit 11

    # Abort if PV is mounted
    mount |grep -q $pv &&
        exit 22

    # 0. Partition device if not already
    isParted(){ lsblk -no TYPE "$pv" |grep part; }
    isParted || {
        # Create a single partition on a raw block device
        parted -s $dev mklabel gpt
        parted -s $dev mkpart pv 1MiB 100%
        parted -s $dev set 1 lvm on
        partprobe "$dev"
        # Allow udev to catch up
        while ! isParted; do sleep 1 >/dev/null; done 
        udevadm settle
    }

    # 1. Create PV if not already
    pvs "$pv" ||
        pvcreate $pv

    # 2. Create VG if not already
    vgs "$vg" ||
        vgcreate "$vg" "$pv"

    # 3. Create LV if not already
    lvs "$vg/$lv" ||
        lvcreate -n "$lv" -l 100%FREE "$vg"

    # 4. Format with XFS if not already
    blkid "/dev/$vg/$lv" |grep 'TYPE="xfs"' ||
        mkfs.xfs /dev/$vg/$lv

    # 5. Use temp mount for cloning a source to this new volume 
    #    for subsequent persistent mount at that source path.
    #    Example: Migrate an etcd store to a new volume.
    tmpMount(){
        # Temporary mount 
        tmp=/mnt/etcd-tmp
        mkdir -p $tmp
        mount /dev/$vg/$lv $tmp
        # Copy data (with etcd stopped)
        src=/var/lib/etcd
        rsync -aHAX --numeric-ids --inplace --delete --fsync \
            $src/  $tmp/

        sync -f $tmp

        # Fix permissions
        chown -R root:root $tmp
        chmod 700 $tmp/member 2>/dev/null || true
    }
}
destroy(){

    # Abort if block device does not exist
    lsblk -ndo NAME,SIZE,TYPE,MODEL |grep -q "\b$blk\b" ||
        exit 11

    # Abort if PV is mounted
    mount |grep -q $pv &&
        exit 22

    # 1. Unmount the LV
    #umount $mnt 2>/dev/null || true

    # 2. Disable swap, else no-op, then deactivate LV
        # How to check for swaps
        #cat /proc/swaps
        #swapon --summary
    swapoff /dev/$vg/$lv 2>/dev/null || true
    lvchange -an /dev/$vg/$lv

    # 3. Delete the Logical Volume
    lvremove -y /dev/$vg/$lv

    # 4. Remove the Volume Group
    vgremove -y $vg

    # 5. Remove the Physical Volume
    pvremove $pv

    # 6. Wipe filesystem signatures and partition table
    wipefs -a $pv
    wipefs -a $dev 

    # 7. Zap partition table completely (optional and destructive)
    sgdisk --zap-all $dev
    partprobe $dev

    # Validate : Want no trace of that LVM construct
    lsblk $dev
    pvs; vgs; lvs
    blkid
}

"$@" || echo ERR $?
