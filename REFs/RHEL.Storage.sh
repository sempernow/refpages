#!/bin/bash
exit
# STORAGE @ RHEL (RedHat/CentOS/Fedora)  
# BLOCK DEVICEs (PARTITION, FILESYSTEM, SWAP) (LPIC-1 & CompTIA-Linux+ Certs)
# https://access.redhat.com/documentation/en/red-hat-enterprise-linux/?category=storage&version=7

# Two Mechanisms for Storage Organization

    # 1. PARTITION   STATIC size
        # sda1  /boot
        # sda2  /
        
    # 2. LVM         DYNAMIC size 
        # $ lsblk 
        # SIZE LABEL NAME               MAJ:MIN TYPE FSTYPE      MOUNTPOINT UUID
        # 20G       sda                   8:0   disk
        # 600M       ├─sda1               8:1   part vfat        /boot/efi  B872-847F
        # 1G         ├─sda2               8:2   part xfs         /boot      0ef0e28d-a54d-4cd6-b7f8-f55b5ca9ae03
        # 18.4G      └─sda3               8:3   part LVM2_member            HH9Op3-T1eP-yX34-wrY1-FIqN-S6ZB-ynCpHs
        # 16.4G        ├─almalinux-root 253:0   lvm  xfs         /          4293cdb0-594f-4ebb-9854-027e7cfc18dc
        # 2G           └─almalinux-swap 253:1   lvm  swap                   ffb13feb-ca59-481b-9612-8f2ae6d9f89c

        # LVM (Logical Volume Manager) : Device mapper
        # https://en.wikipedia.org/wiki/Logical_Volume_Manager_(Linux)  

# UTILITIES 

    # FILESYSTEM USE/MONITOR
        df -Th  # disks info; include FS type; human readable sizes
        df -i   # inodes (usage); POSIX filesystems have 1 inode per file, & max 
        df -h   # disk free; per FILESYSTEM; human-readable (-h)
        # /dev/sda1, tmpfs, varrun, varlock, udev, tmpfs, lrm

        du -h         # disk usage : amount of disk space used per folder, reported in human-readable units
        du -h PATH    # Size (used), per folder under PATH
        du -sh PATH   # Summary of PATH after walking the entire tree
        du -sh *      # Summary of each 1st-child folder & root file
        du -sh .      # Summary of all under $PWD

    # FILESYSTEM INFO
        dumpe2fs /dev/sdb1 # detailed HDD/fs info; name, UUID, magic number, ...
        # XFS tools ...
            xfs_admin 
            xfs_info # on xfs filesystems; only works if mounted 
            xfs_metadump # more in-depth

    # file size (filesize)
        wc -c < "$@"
        stat -c %s "$@"

    # file permissions in octal AND symbolic, and file-name
        stat -c ' %a  %A  %n' "$@" # => 770  -rwxrwx---  foo.bar
        
    # OPEN files
        lsof           # list of all open files;
        lsof -P -g -n  # list apps connected to network
        # -g: display PGID numbers; -n: no IP to hostname conversions; -P no port-number conversions

    # SYMLINKS 
        # Symlinks @ /dev/disk map each device to its /dev entry by three schemes
        $ tree -d /dev/disk
        /dev/disk
        ├── by-id
        ├── by-path
        └── by-uuid

        ln  # CREATE HARD/SOFT LINKs ('SOFT' === 'Symbolic')
            # SYMBOLIC LINKs : `man ln` refers to LINK as DIRECTORY, and the existing source path as TARGET.
            # Do NOT USE relative paths, else may err: "Too many levels of symbolic links"
            # Hard link points to TARGET; SAME INODE; NOT link between volumes (device/partition/fs)
            ln TARGET LINK     # create HARD link
            # Soft link points to TARGET (FILE|DIR); creates NEW INODE; Okay to link between volumes.
            ln -s TARGET LINK  # create SOFT link
            ln -fs TARGET LINK # create SOFT link, forcibly (delete pre-existing)
            # E.g., ...
                $ link -s /foo /bar
                $ ls -l /bar
                lrwxrwxrwx. 1    5 2018-04-21 11:47 bar -> /foo
            # E.g., make link to RHEL's weird grub.conf file/location (menu.lst)
                ln -s '/boot/grub/menu.lst' '/etc/grub.conf'
                # SAFE to DELETE (hard/soft) LINK; target NOT affected; change target (name|del) breaks link.
        # LINK TEST; is FILE is a symlink
        [[  $(stat -c %h FILE) -gt 1 ]] && echo "FILE is a Symbolic Link"
        # LINK TEST; file exists AND is a symbolic link; FLAKY BEHAVIOR  
        [[ -L "$@" ]] && echo "SYMLINKed" # -h; same
        # EXACT hardlink TEST; two files are SAME iNODE; 'ls -i' shows inode number
        [[ "$(ls -i FILE1 | awk '{print $1}')" == "$(ls -i FILE2 | awk '{print $1}')" ]] 

    # FILE OWNERSHIP USER/GROUP/OTHER (ugo)

        chown # change file owner and group (user-ownership)

        chown USERNAME FILEPATH      # change OWNER (user-ownership) of a file 
        
        chown -R USERNAME FOLDERNAME # change owner of all in/under foldername 
        
        chown USERNAME:GRPNAME FNAME # change owner AND group
        chown USERNAME.GRPNAME FNAME # same (older, less compliant)
        chown :GRPNAME FNAME         # change GROUP ownership (omit owner)

        chgrp GROUPNAME FILEPATH     # change GROUP ownership of a file (can use chown, above)
        
    # FILE PERMISSIONS : (-rwxrw-r-- ; user/group/other a.k.a. owner/group/other)
        # https://en.wikipedia.org/wiki/File_system_permissions

        # Permissions algorithm is Exit-On-Match. 
        #   I.e., user gets owner perms if user is owner, 
        #   else group perms if user is group member, else other    

        # REPRESENTATIONS:   decimal / octal / symbolic   
        # u=rwx,g=r-x,o=r-x    755   / 0755  / -rwxr-xr-x 

            Symbolic  Binary  Octal
            ---       000     0
            --x       001     1       EXECUTE
            -w-       010     2       WRITE
            -wx       011     3
            r--       100     4       READ
            r-x       101     5
            rw-       110     6
            rwx       111     7

        # MEANINGs :     File  OR  Dir
                        ----      -------
            4 Read        open      list
            2 Write       modify    add/del
            1 Execute     run       cd
        
        # typically represented in octal or symbolic; e.g., 0755 or rwxr-xr-x
        ls -l /home # => 
        #  permissions    own  grp
        #  -----------    ---  ---
            drwx------. 32 f99z f99z  4096 Jan 24 17:57 f99z
            drwx------.  4 foo  foo   4096 Jan 21 17:08 foo
            drwxr-xr-x.  2 root root     0 Jan 24 17:43 guest  

        # Show perms in OCTAL & SYMBOLIC # => 770  -rwxrwx---  foo-bar.baz
            ls -1 | xargs stat --format=" %a  %A  %n" 
            # OR 
            find . -maxdepth 1 -printf "%f\n" | xargs stat --format=" %a  %A  %n"

        chmod # change permissions user (u), group (g), other (o)
                # if user is not owner (of target file), then first use 'sudo chown ...' 

            # if type 'd', (dir), then 'x' means CAN do dir listing, else can NOT.
            # if type 'l' (link), then given full perm; limited by target
            
            chmod 770 *              # drwxrwx---. ; all @ current dir
            chmod -R ...             # Recurse the tree
            chmod 664 FNAME          # -rw-rw-r--. ; using octal notation
            chmod +x FNAME           # relative mode; make executable
            chmod u+w,g-w,o+x FNAME  # relative mode; add w to user/owner, remove w from group, add x to other
            
            find . -type d -execdir chmod 775 "{}" \+ # (775) drwxrwxr-x @ all dirs
            find . -type f -execdir chmod 664 "{}" \+ # (664) -rw-rw-r-- @ all files

        # DEFAULT PERMS : POSIX/UMASK (022)

            755   # folders;  -rwxr-xr-x
            644   # files;    -rw-r--r-- 
            
            type  owner  group  other 
            ----  ----- ----- ----- 
                d   rwx   r-x   r-x           
                d    7     5     5           

                -   rw-   rw-   r--
                -    6     6     4   

            #  NOTE that 644 @ file is NOT due to umask 133, 
            #    but rather of separate POSIX rule stripping user, owner, and group 
            #    of execute permission, 'x', on all new regular files.

        # RESET/RESTORE user/group perms to default
        # run as su (root) ...
        # switch to single-user-mode ...
        su /sbin/init 1
        
            # @ HOME 
                find /home/uZer -type d -print0 | xargs -0 chmod 0775
                find /home/uZer -type f -print0 | xargs -0 chmod 0664

            # @ all installed pkgs
                for p in $(rpm -qa); do rpm --setperms $p; do rpm --setugids $p; done

        # FILE PERMISSIONs MASK a.k.a. 'file mode creation mask'
            umask # display current umask setting

            # Change per SESSION; to persist, edit @ ~/.profile)
            umask 0022  # Default; e.g.,  666 => 644
            umask 0077  # User only;      666 => 600 
            umask 0337  # User Read-only; 666 => 600

            umask -S u=r,g=r,o= # same; (0)337

            #  PERMISSIONS = 777 - <UMASK> 
            #
            #  Set @ '/etc/profile or /etc/bashrc
            #  DO NOT ALTER; unnecessary and complicated
            #  (0)022 ; default perms for all files/folders created by user thereunder;
            #    though POSIX further lowers regular files perms to 644 
            #  So, if umask is 022, then all new file/folder defaults are ...
            #    folder: 755 (drwxr-xr-x) ... cuz umask 022; 777 - 022 = 755
            #    file:   644 (-rw-r--r--) ... cuz POSIX standard/default removes 'x'

            # reset umask : for all dirs+files thereafter DURING THIS SESSION.
                umask 337           # resets perms to 440 ; -r-r----- 
                umask 0337          # same (in octal notation)
                umask -S u=r,g=r,o= # same; (0)337

            # reset umask : PERSIST ON REBOOT @ ~/.profile
                vi ~/.profile 

            # show umask setting(s) ... 
                grep -i -B 1 umask /etc/profile 
                # or 
                grep -i -B 1 umask /etc/bashrc # RHEL
                
        # SPECIAL PERMISSIONS : setuid bit (SUID), setgid bit (SGID), Sticky bit

                        FILEs           DIRECTORY/FOLDERs               USAGE
                        ------------    -----------------------------   --------------------
            SUID        Run as owner    ...                             DO NOT USE

            SGID        Run as owner    inherit ownership (here/below)  USEd on FOLDERs

            Sticky bit  ...             Del if user is owner            USEd in SHARED GROUP Env.

            # SUID (s) : Set User ID (setuid) : if bit set, USER runs FILE with owner's permissions
                # DO NOT USE this : Used on some SYSTEM binaries
                chmod u+s FILE # SUID; owner: 'rwx' => 'rws'
                -rwsr-xr-x 1 root root 12345 Jun 12 12:34 /path/to/file

            # SGID (s) : Set Group ID (setgid) : if bit set, then FILE has group permissions
                # USE on folders 
                chmod g+s FILE # GUID; group: 'rwx' => 'rws'
                drwxr-sr-x 1 user group 12345 Jun 12 12:34 /path/to/directory

            # Sticky bit (t) AKA "Other ID" : if bit set, only OWNER and root can delete or rename files
                # Applies to folders only (formerly allowed on files too)
                # Used in SHARED GROUPs environments; protects users' files from others in group
                # Used on NFS having root squash (root:root maps to nobody:nobody), so setting at other sets mode.
                chmod o+t FOLDER # Sticky bit (@ other) : 'rwx' => 'rwt'
                drwxrwxrwt.  33 root root  4096 Jan 25 10:20 tmp # 't'; protects users' tmp files

            # if NOT 'x', then 's' => 'S' and 't' => 'T'
        
            # APPLY : SUID|SGID|Sticky bit

                        Octal    Relative-Mode
                        
                SUID     4          u+s
                GUID     2          g+s
                Sticky   1          +t
                -        0
            
                chmod 0666 foo # -rw-rw-rw-
                
                chmod 2666 foo # -rw-rwsrw- (set Group ID)
                                        
            # WHY ever set SUID ?
                # ... show all files having their SUID (4) set
                find / -perm /4000
                ...
                /usr/bin/passwd
                ...
                # passwd used by user to change their password, so ...
                ls -l /usr/bin/passwd # =>
                -rwsr-xr-x. 1 root root 25980 Nov 23  2015 /usr/bin/passwd 
                # ... SUID set because it needs to modify (write-to) /etc/shadow, which ...
            
                ls -l /etc/shadow # =>
                ----------. 1 root root 1522 Jan 25 08:46 /etc/shadow 
                # ... has NO PERMISSIONS, so only root can access it.

            # Set SGID (setgid) : Set group ID bit, so all files/folders created thereunder are of $group
                sudo chown -R :$group /path/to/directory
                sudo chmod -R g+s /path/to/directory

                # If ACLs supported, then also ...
                sudo setfacl -R -m u:$user:rwx /path/to/directory
                sudo setfacl -R -m g:$group:rwx /path/to/directory
                sudo setfacl -R -d -m u:$user:rwx /path/to/directory
                sudo setfacl -R -d -m g:$group:rwx /path/to/directory



    # ACLs (Access Control List)s : Newest File-based Permissions scheme
        # - Handle more than one group/user permissions per file or directory.
        # - Set default permissions for newly created files and directories.
        # - The acl mount option must set
        #     - /etc/fstab or systemd
        #     - @ Ext fs : tune2fs; sets per file system, not OS config (survives environment change)
        #     - @ XFS fs : ACLs is a default mount option
        setfacl # ACLs setting utility
        getfacl # ACLs getting utility
        
        # set GROUPname perms for all EXISTing @ PATH ...
        setfacl -m g:$group:rx $target_path # (-m)odify; (g:)roup GROUP; set perms, to 'rx', @ PATH 
        setfacl -R -m ... # recurse; apply to all subdirs too; do NOT use '-R' with 'd:' (see below)
        
        # set GROUPname perms for all FUTURE @ PATH ... (default) 
        setfacl -m d:g:$group:rx $target_path # ... (d:)efault ...
        
            # do NOT use '-R' with default settings

        getfacl $HOME # =>
            getfacl: Removing leading '/' from absolute path names
            # file: home/f99z
            # owner: f99z
            # group: f99z
            user::rwx
            group::---
            other::---
        
        # FIRST set perms per chmod, THEN setup ACLs; 
        # Do NOT use chmod AFTER setting up ACLs
        
        # ls -l : shows ACLs info ...
            drwxrwx---.  # if no ACLs set
            drwxrwx---+  # if ACLs set



    # FILESYSTEM INTEGRITY (ext2/3/4, vfat, xfs, ...)
        # @ ext
        fsck # filesystem check; per filesystem detection & run util, e.g., e2fsck
            fsck -t ext3 /dev/sdb1 # check type (-t) ext3
            fsck.ext3 /dev/sdb1 # same
        # @ XFS
        xfs_check # equiv for xfs type filesystem
        xfs_info $mount_pt # E.g., /dev/mapper/almalinux_a0-root

    # PARTITIONs + LVM 
        /proc/partitions

        # Create a partition (safely) : Single partition on raw block device
        dev=/dev/sdb
        # 0. Partition if raw           (Partition)
        blkid $dev |grep TYPE || {
            sudo parted -s $dev mklabel gpt
            sudo parted -s $dev mkpart pv 1MiB 100%
            sudo parted -s $dev set 1 lvm on
        }
        # Then create LVM Physical Volume:
        pvcreate ${dev}1   

    # BLOCK DEVICES

        # List all block devices
            ls -l /dev /dev/mapper |grep ^b

        lsblk # list block devices
            lsblk -o SIZE,LABEL,NAME,GROUP,MAJ:MIN,TYPE,FSTYPE,MOUNTPOINT,UUID 
            lsblk -I 8  # devices whose 'major number' is '8'; find @ '/dev' 

            # "MAJ:MIN" : device numbers that uniquely identify device to kernel.
                # MAJ (Major Device Number): Type of device or driver.
                # MIN (Minor Device Number): Differentiate between devices of same type.

        blkid # block device attribs; man page advises use 'lsblk' utility instead
            blkid # list all (may be silent lest root access)
            blkid /dev/sdb || echo no partition exists
            blkid /dev/sda1 
            blkid /dev/sda1 -sUUID -ovalue 
            blkid -g  # Do garbage collect on blkid cache; rm device if not exist.
        # blockdev 
            blockdev --getbsz DEVICE  # size of block [4096; typically)

    # info/tests @ filesystem/dir/file
        file -s /dev/xvdf  # => 'data' if no filesystem; if raw volume
        file foo           # => 'foo: PEM RSA private key'

        fdisk -l [DEVICE]         # list info on block device(s) attached : all|DEVICE
        fdisk -s PARTITION        # size of PARTITION
        blockdev --getbsz DEVICE  # size of block (4096; typically)

    # Monitor I/O    
        sar # System activity info
            type -t sar || sudo dnf install -y sysstat &&
                sudo systemctl enable --now sysstat
            sudo sar 
        
        iostat # CPU and I/O stats for DEVICEs and PARTITIONs
            iostat -hm # -m for MB else KB 

        iotop # I/O monitor 
            sudo iotop -k  # KB/s, else B/s
            sudo iotop -ko # I/O (actually) only
 
        dstat # System resource stats : vmstat + iostat + ifstat
            dstat -tdD total,sda,sdb,sdc,md1 60

    # IOPS : IOPS / Bandwidth / Throughput 
        fio # See iops-test.sh : https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance-linux

        hdparm  # HD Parameters : get/set SATA/IDE device parameters
            # https://man7.org/linux/man-pages/man8/hdparm.8.html
            device=/dev/nvme0n1
            sudo hdparm -t --direct $device # Read speed (MB/sec)

    # FILESYSTEM REPAIR 
        debugfs # debug filesystem; make changes (writeable) (-w)
            debugfs -w /dev/sdb1 # returns prompt (help, q, ls, lsdel, undel)
            # lsdel - shows all deleted file(s)
            # undel (undelete); at debugfs prompt ...
            debugfs: undel <inode#> FNAME

    # FILESYSTEM CHANGES 
        tune2fs # make changes; e.g., change efs2 to efs3 FS by adding journal
        tune2fs -O has_journal /dev/sdb1  # add    feature (-O)
        tune2fs -O ^has_journal /dev/sdb1 # remove feature (-O ^...)
        
    # DISK QUOTAs (per FS) quota, quotaoff/on, quotacheck, edquota, repquota
        quota # tool; not installed by default on all distros
        apt-get install quota 
        vi /etc/fstab # edit fstab (man fstab(5)) ...
            # add 'usrquota,grpquota' ...
            # /dev/sdb1  $path  ext3  defaults,usrquota,grpquota  0  2
        # then REMOUNT; unmount/mount device
        umount $path && mount $path
        quotaoff $path # safety; even though no quota files yet.
        quotacheck -cug $path # create quota files for user+group
        # creates (binary) quota files: aquota.grp, aquota.user
        edquota -u USERNAME # edit user quota file; 
            # set soft/hard limits for blocks (kB of data), and inodes (# of files)
            # if quota is '0', then there's no limit (soft/hard); 
            # seven day grace period begins @ soft limit. Hard limit = no matter what.
            # seven day reset IF below soft @ end of grace period, else locked.
        quotaon $path
        repquota # report quotas 
        repquota $path

# MOUNT FILESYSTEM

   # Use mount for TEMPORARY mounts; does NOT survive reboot
        mount # man mount(8) : https://linux.die.net/man/8/mount 
        # To persist, add entry in /etc/fstab (See below)
        
        mount               # Show all existing mounts
        findmnt [SUBJECT]   # Better; info is organized
   
    # MOUNT ALL (REFRESH) per /etc/fstab settings
        mount -a    # man fstab(5)  
    # UNMOUNT per PARTITION or MOUNT_POINT; e.g., ...
        umount /dev/sdb1
        umount /mnt/foo 

    # SYNTAX
        mount -t TYPE DEVICE DIRECTORY      # TYPE (FS); ext3/xfs/ntfs/...
        mount -t TYPE PARTITION MOUNT_POINT # prefer source ID per (immutable) UUID, not per '/dev/...' 

    # DEVICEs : List all BLOCK DEVICEs
        ls -l /dev/sd*  # One per line
        lsblk -l        # One per line; ok, but does not provide full path
        lshw -short     # All devices, including storage
        fdisk -l        # Disk, Units, Sector size, I/O size (min/optimal); redundant listings
        pvs             # Those under LVM only

    # LOCATION
        /mnt # FHS designated for this purpose specifically; TEMPORARY mount points
        # However, is often used for all mounts; does not break SELinux; okay across distros
        
        # ENTRIES in /etc/fstab : By the book (FHS), mounts declared at /etc/fstab should be:
            /srv # "data served by this system" : nfs, web, ftp, git (repos), ...
            /opt # Add-on software trees.
            /var/lib/foo    # Persistent app data.
            # Not in FHS, but widely adopted by enterprise data centers
            /data/{db,logs,backup} # General purpose for large mounted volumes

    # mount BLOCK DEVICE 'sdb1', having FS type Ext3, at mount point /mnt/abc
        mkdir -p /mnt/abc
        mount -t ext3 /dev/sdb1 /mnt/abc
    # Bind mount : Target is effectively a pointer to source
        mkdir -p $target
        mount --bind $source $target        # Quirks WRT du, chroot, ...
        mount --rbind $source $target       # Recursively; bind mount all links of source too
        mount --bind -o ro $source $target  # Mount target as read-only : Newer kernels only
        # Robust read-only : Applies to mount point and *everything* thereunder regardless of kernel
        mount --bind $source $target &&
            mount -o remount,bind,ro $target 
    # mount USB (@ WSL)
        sudo mkdir /mnt/g
        sudo mount -t drvfs g: /g
    # mount CIFS/Samba share, e.g., USB drive mounted @ router
        mkdir /mnt/wdpRed # create (local) mount point, then mount it ...
        mount -t cifs //192.168.1.1/foo /mnt/wdpRed \
            -o username=$cifsUser,password=$cifsPass,iocharset=utf8,file_mode=0777,dir_mode=0777,soft,user,noperm
            # ... can omit password; will prompt
    # mount ISO : Use LOOP DEVICE (option); a virtual device to MOUNT a FILE as a BLOCK DEVICE  
        # https://en.wikipedia.org/wiki/Loop_device  
        # Used to mount, e.g., ...
        # - ISO files
        # - Disk image files used by virtual machines.
        # - Filesystem images, such as those used in embedded systems or by certain backup solutions.
        # Mount ISO using first-available loopback device:
        mkdir /mnt/target                               # Create target path
        mount -o loop /path/to/foo.iso /mnt/target      # Mount the source (ISO)         *
        ls -hal /mnt/target                             # Read ISO's root dir
        losetup -f                                      # Get available loop device(s)
        umount /mnt/target                              # Unmount the ISO
    
    # Use UUID (unique) or LABEL (not unique), which is immutable (across machines) 
        # Whereas DEVICE name, e.g., /dev/sdb1, is set *per boot*.

    # Mount by UUID (LABEL)
        mount LABEL=foo /mnt/bar # Label support is per FS (ext4, xfs, btrfs, ...)
        mount UUID="1361a3b1-2072-4fee-aa0f-91c7480252a1" /mnt/bar 
        mount UUID=$(blkid /dev/sde1 -sUUID -ovalue) /mnt/bar 

        # Note: Udev rule mounts removable media to ...
            /media/<user>/<LABEL>  # if LABEL exits
            /media/<user>/<UUID>   # otherwise

        # LABEL : Set : UNMOUNT the device beforehand 
            e2label /dev/sdb1 PROJECTS      # ext4 (16 chars), ext3, ext2 : e2fsprogs pkg
            tune2fs -L Boot /dev/sda1       # ext4 (16 chars), ext3, ext2
            xfs_admin -L ARCHIVES /dev/sdb2 # XFS  (12 chars)
            fatlabel /dev/sdc1 BACKUP       # FAT  (11 chars UPPERCASE)
            ntfslabel /dev/sdc1 DATA        # NTFS (32 chars)
        # LABEL : Get : Use same command sans label (as a general rule)
            e2label /dev/sda1 
            lsblk   /dev/sda1 
            blkid   /dev/sda1 
            losetup -f

   
    # @ 'fstab' (AUTOMOUNT on boot) ('Legacy', but also 'PREFERRED') 
        /etc/fstab  # man fstab(5) http://man7.org/linux/man-pages/man5/fstab.5.html   
        # @ RHEL   http://www.unix.com/man-page/centos/5/fstab/ 
        # @ Cygwin https://cygwin.com/cygwin-ug-net/using.html#cygdrive 
        # 
        # 'fstab' is "the preferred approach" @ RHEL-7, per 'man systemd.mount(5)' 
        # http://www.unix.com/man-page/centos/5/systemd.mount/ 

        vi /etc/fstab  # man fstab(5) http://man7.org/linux/man-pages/man5/fstab.5.html   
            # 1st field: target; by LABEL=, UUID=, or /dev/...
            # 2nd field: mount point
            # 3rd field: fs type
            # 4th field: options ('man fstab' (5); 'man mount.cifs' (8))
            # 5th field: dump (0,1) save files automatically (1) upon system shutdown (LEGACY util)
            # 6th field: fsck (0,1,2) fs scan order; root fs '1'; others (2); media (removable) (0) 
            1       2     3       4              5          6
            TARGET  mtPT  fsTYPE  OPT1,OPT2,...  0|1(dump)  0|1|2(fsck)

            # FIELDS are TAB or SPACE -separated
            # OCTAL ENCODE path characters; WHITESPACE is '\040'
            # 4th field OPTIONS:
                rw       # read & write
                user     # allow any user to mount
                owner    # allow device owner to mount
                auto     # mount on boot
                noauto   # do NOT mount @ 'mount -a'
                noexec   # files are NOT executable
                defaults # rw,suid,dev,exec,auto,nouser,async
            
        # E.g., 

            # xfs  (UUID better than /dev/...; former is less mutable.)
            UUID=vu8nUp-DqD...  /foo  xfs  defaults  1  2

            # ext3
            /dev/sdb1  /mnt/foo\040bar  ext3  rw,user,auto,noexec  0  2
            
            # CIFS @ CentOS 7
            //router/wdp\040red	/media/usb	cifs	owner,uid=1000,gid=1000,dir_mode=0700,file_mode=0700,credentials=/home/uZer/.config/cifs/creds 0 0 

            # CIFS Ubuntu 18.04 (armbian); To use less secure SMB1 dialect, specify vers=1.0
            //router/wdp\040red	/media/usb	cifs	vers=1.0,uid=1000,gid=1000,dir_mode=0700,file_mode=0700,credentials=/home/uZer/.config/cifs/creds 0 0

        mount -a  # (re)mount all by /etc/fstab
        
        # Troubleshoot 
        tail -f /var/log/kern.log

    # @ 'systemctl' UNIT FILEs  (systemd; RHEL 7+) 
    # >>>  See 'REF.RHEL.RHCSA.sh' for lv example and more detail
    # Note: 'fstab' is still effective AND takes precedent, even though "legacy"

        # SHOW all UNIT FILES; those regarding ".(auto)mount" ...
            ll /etc/systemd/system/*.*mount  

        # mount requires UNIT FILE named:
            /etc/systemd/system/{NAME}.mount
        # automount requires UNIT FILE named:
            /etc/systemd/system/{NAME}.automount

            # EITHER (mount/automount) can be ACTIVE by systemctl.
            # I.e., stop/disable the one, before start/enable the other.

        # NAMING CONVENTION (REQUIRED)
            # IF the desired target MOUNT POINT is 
                /mnt/foo/bar

            # THEN the UNIT FILE name(s) MUST BE 
                /etc/systemd/system/mnt-foo-bar.mount      # to mount
                /etc/systemd/system/mnt-foo-bar.automount  # to automount

            # The mount point is defined @ the 'Where = ...' in these UNIT FILE(s) ...
                Where = /mnt/foo/bar  # defines the mount-point

            # I.e., PATH <=> NAME convention 
                export _PATH=/mnt/foo/bar  # Mount Point (DO NOT CREATE; auto-created)
                export _NAME=mnt-foo-bar

            # Do NOT create mtpt (folder); unlike other methods, the
            # pre-existing mtpt its neither required nor allowed here.

            # USAGE 
                # (auto)mount/unmount by systemctl & unit file 
                    systemctl (start|stop|enable|disable) lv${_NAME}.(auto)mount
                    # now: start/stop; @ boot: enable/disable
                        
                        systemctl start  lv${_NAME}.mount
                    # validate 
                        systemctl status lv${_NAME}.mount
                    # enable mount on boot  
                        systemctl enable lv${_NAME}.mount
                    # disable mount on boot 
                        systemctl disable lv${_NAME}.mount
                    # disconnects mount
                        systemctl stop lv${_NAME}.mount

                    systemctl daemon-reload # may be needed ???

                lv${_NAME}  # find by lsblk command

            # Create automount of a USB drive by unit files
                vi /etc/systemd/${_NAME}.mount
                    Description = WDPred USB per systemd mount

                    (Mount)
                    What = /dev/sdb2
                    Where = ${_PATH}
                    Type = vfat

                    (Install)
                    WantedBy = multi-user.target
                vi /etc/systemd/${_NAME}.automount
                    (Unit)
                    Description = WDPred USB per systemd automount

                    (Mount)
                    Where = ${_PATH}

                    (Install)
                    WantedBy = multi-user.target
                # NOTE absense of 'What' and 'Type' @ automount Unit File. 
                    # Though the mount Unit File will be 'disabled' for automount, 
                    # systemctl still uses/reads/requires that Unit File.

                # make mtpt (dir)
                    mkdir ${_PATH}

                # enable/start AUTOmount; must first stop/disable mount
                    systemctl stop ${_NAME}.mount
                    systemctl disable ${_NAME}.mount
                    systemctl enable ${_NAME}.automount
                    systemctl start ${_NAME}.automount 
                
                # test/validate
                    ll ${_PATH}
                    systemctl status lv${_NAME}.mount

                # Troubleshoot
                    tail -f /var/log/kern.log

            # >>>  See 'REF.RHEL.RHCSA.sh' for lv example and more detail

    # @ 'autofs' (AUTOMOUNT when needed; else unmounted; LEGACY; RHEL-6)
    #   better method than @ /etc/fstab; does mount/unmount on any activity;
    #   handles automounts when (unexpectedly) unavailable/offline
        yum install autofs 

        /etc/rc.d/init.d/autofs start|stop|restart|reload|status
        # or 
        service autofs start|stop|restart|reload|status

        # @ /etc/auto.master
            vi /etc/auto.master # add (TAB-delimited fields) ...
            # mount_pt  autofs-auto-name-path  (options)
            /media/NAME  /etc/auto.NAME  (--timeout=60 --ghost)

                --timeout  # defines wait time (seconds) before file system is unmounted. 
                --ghost    # creates empty folders for each mount-point; 
                                     # prevent timeouts @ unavalable network share

        # @ /etc/auto.NAME (autofs_config_file_path)
            vi /etc/auto.NAME # add  (TAB-delimited fields)...
            mountedNAME  -fstype=cifs,(other_options)  ://REMOTE_SERVER_PATH
            
# PARTITIONs

    # PARTITION TOOLs
        # gdisk : Text-mode menu-driven program for creation and manipulation of partition tables.
        gdisk # https://linux.die.net/man/8/gdisk
        
        # fdisk : Partition table manipulator for Linux
            fdisk -l (DEVICE) # list info on block all|DEVICE
        # man fdisk(8)  https://linux.die.net/man/8/fdisk
        # NOT for GUID Partition Table (GPT); NOT designed for large partitions.
            fdisk /dev/sdb 
            # INTERACTIVE operations on a HDD using fdisk ...
                m # list of commands
                p # disk info
                n # add new partition; p(primary) or e(extended|logical)
                    #  Partition number: (1)
                    #  'First sector...': (default), 'Last sector...+size': +1G (for 1GiB)
                    # OR create logical partitions in an extended (logical) partition
                    #  p(primary) or l(logical)
                w # write table to disk, & EXIT 
                
                # -->>>( REBOOT IF ANY ERROR MSG )<<<--

        # GParted : GNU Parted - a partition manipulation program 
            parted # man parted(8)  https://linux.die.net/man/8/parted

    # PARTITION SCHEMEs
    
        # Logical Partitions under an Extended Partition ...
            # root - 5GB (sda7)   mt-point is '/'
            # swap - 2GB (sda8)
            # home - 5GB (sda9)   mt-point is '/home' 

        # E.g., Dual Boot openSUSE/Windows setup
            #  Created 3 partitions under an Extended Partition 
            #  on boot into openSUSE @ VMWare:
                1st Partition, for root: 
                        Size:       15GB
                        FS:         ext4 
                        Mount pt:   root, "/"

                2nd Partition, for home: 
                        Size:       102GB
                        FS:         ext4 
                        Mount pt:   home, "/home"
                        
                3rd Partition, for swap: 
                        Size:       2GB
                        FS:         Swap
                        Mount pt:   swap  
        # E.g., CentOS-7 Install ...
            # "Device Selection" > "Other Storage Options" > "I will configure ..." 
            # intall menu/task flow is NOT sequential; uses star logic ...
            # Repeat + "Update Settings" (button) for each partition; 
            #   from "Unknown" list, select free partition, and 
            #   create 3 Logical Partitions: 
                /      SYSTEM   10 GB
                swap     swap    2 GB
                /home    DATA    5 GB
                /boot # auto-created @ install; 1GB, outside VG
                # leaves unused for RHCE tutorial purposes

    # LUKS ENCRYPTED PARTITION
        cryptsetup luksFormat|luksOpen|luksClose TARGET_DEVICE
    
        # make partition | LV (extended) container partition + logical partitions
        fdisk /dev/sdb ; p (show partitions; n; p (primary) OR e(extended|logical); 2(default);+100M (MiB) 
        # validate
        partprobe /dev/sdb # inform OS of partition change(s)
        
            # format/make-fs if logical/container, e.g., /dev/sdb2 is extended/logical partition, wherein encrypted partition(s) --also created per above method --will be created on, e.g., /dev/sdb5
            mkfs.ext4 /dev/sdb2

        # encrypt (format) 
        cryptsetup luksFormat /dev/sdb5 # passphrase set here
        # open encrypted device; required prior to mounting it
        cryptsetup luksOpen /dev/sdb5 NAME # passphrase required here
        # validate : name of encrypted device is ...
            '/dev/mapper/NAME'
            ls /dev/mapper # =>
            ... NAME ...
        # create FS on encrypted device
        mkfs.xfs /dev/mapper/NAME
        
        # mount it 
        mount /dev/mapper/NAME /NAME
        # disconnect encrypted device ...
        umount /NAME 
        cryptsetup luksClose /dev/mapper/NAME
        
        # automount setup 
        vi /etc/fstab 
            # => edit/add
            /dev/mapper/NAME  /NAME  xfs  defaults  1  2 
        vi /etc/crypttab # create
            # cuz device, @ fstab, will not yet exist on boot
            # field 3 is password file option (not in RHCSA exam)
            # system prompts for passphrase on boot
            NAME   /dev/sdb5  none
        # must reboot to test; 'mount -a' would merely call fstab here

# FILESYSTEMs

    # @ RHEL distros ... 
        # xfs (RHEL-7 default)
        # ext4; default (legacy) Linux filesystem
        # btrfs (CoW)
        # vfat; Windows compatibility only; useful for USB keys
        # GFS2; Active/Active HA Clusters
        # Gluster; distributed FS; 'Bricks'; XFS back-end FS

    # MAKE a FILESYSTEM (FORMAT a PARTITION)
    # Linux kernel <==> VFS (Virtual Filesystem) <==> all FS types
        mkfs.<FS> # make filesystem; a family of utilities
            # SHOW all AVAILABLE mkfs.<FS> utilities 
            ls -1 $(which mkfs)* 
            
            # E.g., make an XFS filesystem ...
            mkfs.xfs -L LABEL DEVICE
                # E.g., ...
                mkfs.xfs -L foo /dev/sdb1

    # MAKE a SWAP SPACE (partition of a special FS format)
        mkswap /dev/sdb2  # MAKE 
        swapon /dev/sdb2  # ACTIVATE 

        swapon -s # show swap space info

    # CIFS/Samba (Common Internet File System); successor to SMB ("Samba") Protocol
        yum install cifs-utils  # min required for fstab entry to be mountable
        yum install cifs-utils samba-client samba-common  # all related utils

        # Debian/Ubuntu
        apt install cifs-utils
        apt install nfs-common

        # Config (CIFS/Samba)
            vi /etc/samba/samba.conf

        # Create a CIFS/Samba share (replace uid/gid number(s)w/ apropos)
            vi /etc/fstab  # (see 'MOUNT' section for systemd method)
            # 1. edit fstab, e.g., 
                //SMB/foo/\040bar	/media/SMB	cifs	vers=1.0,uid=1000,gid=1000,dir_mode=0700,file_mode=0700,credentials=/home/Uzer/etc/config/samba/cifs.creds.SMB 0 0 
            # 2. create MOUNT POINT, e.g., '/media/SMB'
                mkdir /media/SMB
            # 3. now refresh mounts ...
                mount -a  # mount all per /etc/fstab

        # Troubleshoot / Log
            tail -f /var/log/kern.log

    # NTFS  ntfs-3g (NTFS driver for Linux)
        yum install epel-release -y
        yum install ntfs-3g -y

        # Ubuntu  https://help.ubuntu.com/community/MountingWindowsPartitions 

        # View FS TYPE, UUID, ... 
            lsblk
        # list NTFS filesystems; local 
            fdisk -l | grep NTFS 

        # MOUNT /dev/sda1 (Win OS system)
            $ mkdir /mnt/ntfs                    # create a mount point 
            $ mount -t ntfs /dev/sda1 /mnt/ntfs  # mount, type 'ntfs', to '/mnt/ntfs'
            $ ll /mnt/ntfs                       # show dir 

        # @ /etc/fstab (entry)  
            UUID=519CB82E5888AD0F  /media/Data  ntfs-3g  defaults,windows_names,locale=en_US.utf8  0 0

        # IF want to mount a DIR at NTFS, would first map folder to drive letter 
        # per Windows; @ cmd: 'SUBST.exe %_drv%: "%_path%"'

        # MOUNT REMOTE DIRECTORIES (filesystem/folder) AT a LOCAL DIRECTORY 
            # per ... any one of many tools 
            # SSHFS + FUSE, SAMBA, NFS
            # https://unix.stackexchange.com/questions/62677/best-way-to-mount-remote-folder 

    # FAT32 
        # @ /etc/fstab (entry)
            UUID=<UUID> /media/<mountpoint> vfat defaults,user,exec,uid=1000,gid=100,umask=000 0 0

    # SSHFS
        # Mount Remote Directories per SSH suite 
        # https://www.linode.com/docs/networking/ssh/using-sshfs-on-linux/

    # iSCSI Storage Area Network (SAN) PROTOCOL.
        # SCSI over IP; uses existing network infrastructure, unlike Fibre Channel.
        # iSCSI provides BLOCK-LEVEL ACCESS to storage devices over LANs and WANs.
        # https://en.wikipedia.org/wiki/ISCSI
        # SCSI = 'Small Computer System Interface'
        yum -y install iscsi-initiator-utils
        man iscsiadmin

# CLONE/IMAGE/RESTORE a device|partition  
    dd  # https://wiki.archlinux.org/index.php/Dd#Disk_cloning_and_restore  
        # May DESTROY source if dest. (of=) is not equal or greater size than source (if=)
        dd if=/dev/sda of=/foo/bar.img bs=128K  # create image of sda
        dd if=/foo/bar.img of=/dev/sda bs=128K  # restore image to sda

        dd if=/dev/$_devIn of=/dev/$_devOut bs=128K conv=noerror,sync status=progress  # partitions
            bs=128K       # block size; default is 512 BYTES (slowest); faster (per machine; 64K-1M) 
                          # ERRORs per bs; bigger is faster, but error will ruin more.        
            conv=noerror  # continue operation on read errors.
            sync          # Add input blocks with zeroes ON ERRORS, so data offsets synced (SORT OF).

        # LEGACY TOOL; was useful for tape media (where block size is critical).   
        # Still useful for: 
        #   1.) Read/Write the first N bytes of a stream.
        #   2.) Overwrite/truncate a file at any point/seek.

        # ... to remote store 
        dd if=/dev/$_devIn conv=sync,noerror bs=128K | gzip -c | ssh uZer@host dd of=aLinux_distro.gz
        # Restore from .gz
        gunzip -c /path/to/img.gz | dd of=/dev/sda

        # ISO to USB 
        dd if=aDistro.iso of=/dev/$_USB_partition bs=1M && sync  # sync is buffer (Linux kernel call)

    ddrescue  # https://wiki.archlinux.org/index.php/disk_cloning  
        # Cloning and recovery 
        ddrescue -f -n /dev/sdX /dev/sdY rescue.log

    e2image # @ e2fsprogs pkg; @ ext2, ext3, ext4 ONLY; Efficiently copy; blocks used  
        # https://wiki.archlinux.org/index.php/disk_cloning
        e2image -ra -p /dev/sda1 /dev/sdb1

# SYSTEM FILEs LOCATIONs
# FHS (File Hierarchy Standard)  http://www.pathname.com/fhs/pub/fhs-2.3.html
# https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard 

    /                       # root
    /bin                    # Essential user command binaries (for use by all users)
    /boot                   # boot loader, kernel, GRUB/LILO; separate, first partition.
    /dev                    # devices; some are VIRTUAL
    /etc                    # Host-specific system CONFIGuration; no binaries
    /etc/X11                # all X11 host-specific CONFIGuration
    /home                   # Users' PERSONAL DIRs, i.e., '/home/$USER', '$HOME', or '~'
    /users                  # @ MacOS only; equivalent to '/home/$USER', i.e., '~/'
    /lib                    # Essential SHARED LIBRARIES & KERNEL MODULES; called by those @ /bin.
    /media                  # Mount points for REMOVABLE media, e.g., CD-ROMs (FHS-2.3 in 2004).
    /mnt                    # Mount points for TEMPORARILY (and manual) mounted filesystems.
    /opt                    # Optional apps; 3rd-party not of distro repo (link binaries to '/bin')
    /proc                   # VIRTUAL filesystem (re)created per boot; process and system params 
    /root                   # Home directory for 'root user'; 'super user'; optional.
    /sbin                   # system admin binaries
    /srv                    # Service data; system services; e.g., web data for an HTTP server.
    /tmp                    # TEMPorary files
    /usr                    # User-installed programs/apps; BINARIES and CONFIG files. 
    /usr/bin                # the PRIMARY DIRECTORY of EXECUTABLE COMMANDS on the system.
    /usr/sbin               # Non-essential standard system binaries
    /usr/lib                # object files, libraries, and indirectly-called binaries.
    /usr/tmp                # Yet another root derivative; user version of /tmp.
    /usr/local              # for installing software locally; SAFE FROM UPDATE OVERWRITES 
    /usr/local/bin          # local binaries
    /usr/local/sbin         # local system binaries
    /usr/local/etc          # Host-specific system configuration
    /var                    # variable files created per runtime; cache, logs, mail, etc.; 
                            #... lots of changes; can fill up quick; e.g., logins @ '/var/log/wtmp'

    # NOTE: '/usr/bin', '/usr/sbin', '/usr/lib', '/usr/tmp', ... are mindless atavisms; 
    #       originally symlinked root derivatives to handle storage limitations. 
    # REF:  http://lists.busybox.net/pipermail/busybox/2010-December/074114.html  

    # Shell scripts @  ...
        /etc/profile.d  # app config scripts (*.sh)
        /usr/local/etc  # system-wide executables; in PATH for all users
        ~/bin           # user-specific executables; automatically added to PATH
        ~/etc           # not a required folder; NOT automatically added to PATH 

        ~/             # home
        /home/$USER    # home

# DM (DEVICE MAPPER)
    # https://en.wikipedia.org/wiki/Device_mapper
    #  kernel <==> DEVICE MAPPER (DM) <==> LVM,LUKS,RAID,multipath,...
    # 
    #  DM generates 2 (synonymous) names for the device: 
    #    '/dev/dm-{N}'      ... per boot     (do NOT use; may change)
    #    '/dev/mapper/...'  ... per creation (fixed; like LABEL|UUID)  
    
    # LVM (LOGICAL VOLUME MANAGER/MANAGEMENT) (Linux)
    # https://en.wikipedia.org/wiki/Logical_Volume_Manager_%28Linux%29
    #  Flexible Storage; a DM target 
    #    Logical Volumes (LV) may consist of several Physical Volumes (PV)
    #    Easy to resize (EXTEND|REDUCE), and/or add, logical volumes
    #    More volumes; LV(max@256) vs PV(max@15; MBR@4-primary|3-pri+1-ext)
    #    Easy to replace failed physical disk/volume
    #  Snapshots/Versioning; backup files even when open
    # 
    #  STRUCTURE : Physical => Logical ()
    #    Physical:  disk (PD) => partition (PP) => volume (PV)
    #     Logical:  Volume Group (VG) => Logical Volume (LV) => File System (FS)
    #
    #  INTERFACE @ PV <=> VG
    #    VG is the abstraction layer
    #    PV are added/replaced at VG layer; interface
    #    FS are created at LV layer.
    #
    #  DM generates: 
    #    '/dev/dm-{N}'             ... per boot      (do NOT use; may change)
    #    '/dev/vg{NAME}-lv{NAME}'  ... per creation  (symlink; unchanging)
    #
    #  LVM adds SYMLINK TO DEVICE '/dev/dm-{N}' ... 
    #    '/dev/mapper/vg{NAME}/lv{NAME}' 
    #
    #  CLVM 
    #    LVM also works in shared-storage CLUSTER; PVs shared between 
    #    multiple nodes; 'clvmd' daemon to mediate access via LOCKING.
    
    # LVM UTILITIES
    
        vg # display VG utilities 
        lv # display LV utilities 
        df -h # FS; show all
        lvs   # LV; show all
        vgs   # VG; show all
        vgchange -a y # activate volume(s); just to be sure, e.g., offline boot to resize root
    
        # CREATE : PD => PP === PV => VG > LV > FS
        
            # 1. Create PP from PD
                fdisk TARGET_DEVICE # e.g., '/dev/sdb' 
                # therein create partition, e.g., /dev/sdb2, then change type, per: 
                # 't' (list(l)|change({select}) type); select '8e'  'Linux LVM'
                # 'w'; write it

                # @ FAIL on 'w'; 'WARNING: Re-reading the partition table failed ...'
                    # inform OS of partition changes 
                    partprobe {DEVICE} # e.g., '/dev/sdb'
                    cat /proc/partitions # validate okay
                    # ... if that doesn't work, then reboot
                    
            # 2. Initialize PV from PP(s)
                pvcreate {PP} # e.g., {PP} = '/dev/sdb2' 
                # validate/show
                    pvs # =>
                        PV         VG         Fmt  Attr PSize  PFree
                        /dev/sda2  vg_centos6 lvm2 a--u 59.13g    0

            # 3. Create VG from PV(s)
                # VG naming convention: vg{NAME}
                vgcreate vg{NAME} {PP} # e.g., {PP} = '/dev/sdb2'  
                # validate/show
                    vgs # => 
                        VG         #PV #LV #SN Attr   VSize  VFree
                        vg_centos6   1   3   0 wz--n- 59.13g    0

                # 2.+3. => Create PV + VG ... same ??? no need for pvcreate ???
                    vgcreate vg{NAME} {PP} # e.g., {PP} = '/dev/sdb2'
                    
            # 4. Create LV from VG
                lvcreate --help | less 
                # name (-n), and size ( per 'extents'(-l) or size(-L) )
                lvcreate -L 1G       -n lv{NAME} vg{NAME}
                # OR 
                lvcreate -l 100%FREE -n lv{NAME} vg{NAME}
                # validate/show
                    lvs # => 
                        LV      VG         Attr       LSize  ...
                        lv_home vg_centos6 -wi-ao----  5.41g                                          
                        lv_root vg_centos6 -wi-ao---- 50.00g                                          
                        lv_swap vg_centos6 -wi-ao----  3.72g   
            
            # 5. Create FS on LV 
                mkfs.ext4 /dev/vg{NAME}/lv{NAME}
            
        # TEST 
            mount /dev/vg{NAME}/lv{NAME} /mnt
            
            # validate/show 
            mount | grep '/dev/mapper'
            # => 
                /dev/mapper/vg_centos6-lv_root on / type ext4 (rw)
                /dev/mapper/vg_centos6-lv_home on /home type ext4 (rw)
            # ... these are SYMLINKS to the real name of the device "dm-{N}" ... 
            ls -l '/dev/mapper/vg_centos6-lv_home'
                # => 
                lrwxrwxrwx. ... /dev/mapper/vg_centos6-lv_home -> ../dm-2
            ls -l '/dev/vg_centos6/lv_home'
                # => 
                lrwxrwxrwx. ... /dev/vg_centos6/lv_home -> ../dm-2

            # ... dm-{N} is 'DEVICE MAPPER' device; also used per LUKS

            lsblk # => 
                NAME                          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
                sda                             8:0    0 59.6G  0 disk
                ├─sda1                          8:1    0  500M  0 part /boot
                └─sda2                          8:2    0 59.1G  0 part
                    ├─vg_centos6-lv_root (dm-0) 253:0    0   50G  0 lvm  /
                    ├─vg_centos6-lv_swap (dm-1) 253:1    0  3.7G  0 lvm  (SWAP)
                    └─vg_centos6-lv_home (dm-2) 253:2    0  5.4G  0 lvm  /home

        # RESIZE (EXTEND|REDUCE)
        
            # extend (grow)   : order of operations: PV -> VG -> LV -> FS 
            # reduce (shrink) : order of operations: FS -> LV -> VG -> PV 

            # GROW (EXTEND) 
                df -h # show FS
                lvs   # show LV 
                vgs   # show VG
                
                # Recreate partition
                    fdisk $pd # E.g., /dev/sdb 
                        # d     delete
                        # n     new
                        # t     type change 
                        # w     write to disk and exit

                # resize VG
                    vg # display available utilities 
                    vgextend --help 
                    vgextend vg{NAME} {PP} # e.g., {PP} = '/dev/sdb5'
                    # validate 
                    vgs 
                
                # resize LV '-r' = resize FS (also)
                    lvextend -l +100%FREE -r /dev/vg{NAME}/lv{NAME}
                    # validate 
                    df -h 


            # SHRINK (REDUCE)
                # view 
                    df -h 
                    mount | grep {NAME}
                # unmount target 
                    umount MOUNT_POINT 
                # shrink FS
                    man -k resize # show all available resize utils 
                    resize2fs /dev/vg{NAME}/lv{NAME} {SIZE} # msg: must first ....
                    e2fsk -f /dev/vg{NAME}/lv{NAME} # .. error-check FS
                    # NOTE: {SIZE} is, e.g., '100M'
                # shrink LV 
                    lvreduce -L {SIZEFS} # MUST first resize FS
                    # {SIZEFS} is that read from resize2fs report, e.g., '102400K'
                # validate 
                    mount -a
                    df -h 

            # SHRINK (REDUCE) : ALT/FAST method; handles EVERYTHING
                lvreduce -L {SIZE} -r /dev/vg{NAME}/lv{NAME} # '-r' resizes FS first

        # EXAMPLE : INCREASE PD (sda; disk) @ hypervisor (from 20GB to 28GB), 
                #   and then use LVM to gwow partition size

                $ lsblk
                NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
                sda                  8:0    0   28G  0 disk
                ├─sda1               8:1    0  600M  0 part /boot/efi
                ├─sda2               8:2    0    1G  0 part /boot
                └─sda3               8:3    0 18.4G  0 part
                ├─almalinux-root 253:0    0 16.4G  0 lvm  /
                └─almalinux-swap 253:1    0    2G  0 lvm  (SWAP)

                sudo pvresize /dev/sda3
                sudo xfs_growfs /
                sudo lvextend -l +100%FREE /dev/almalinux/root

                # If volume fails grow, then delete and recreate partition (data is preserved).
                    # Fix by running "`sudo fdisk /dev/sda`", 
                    # and performing "`d`" (delete), "`n`" (new), "`w`" (write); 
                    # and accepting all defaults.
                    sudo fdisk /dev/sdb
                
                $ lsblk                                                                                     
                NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS                                                
                sda                  8:0    0   28G  0 disk                                                            
                ├─sda1               8:1    0  600M  0 part /boot/efi                                                  
                ├─sda2               8:2    0    1G  0 part /boot                                                      
                └─sda3               8:3    0 26.4G  0 part                                                            
                ├─almalinux-root 253:0    0 16.4G  0 lvm  /                                                          
                └─almalinux-swap 253:1    0    2G  0 lvm  (SWAP)       
  