exit
# CentOS 7 LIVE; torrent download > Rufus > USB ...
	CentOS-7-x86_64-LiveGNOME-1611.iso
	# else, if 'Everything' ISO, 
	# then select 'Server...' with 'Development Tools' option
# @ HTPC ASRock AM1H-ITX	

# DUAL BOOT CentOS 7 + Windows 7
	# http://www.dedoimedo.com/computers/dual-boot-windows-7-centos-7.html
	# @ Windows, create EXTENDED partition [leave unused space for other experiments], 
	# in which the 3 Logical Partitions for Linux will be created
	# FAIL :: CentOS install [per below process] deleted the extended partition, and repartitioned using primary partitions. No option available at install. So, all 4 partitions are used; remaining, unpartitioned space is worthless. In future, do all partitioning @ live boot, pre-install
	
	# @ CentOS Install ...
	# "Device Selection" > "Other Storage Options" > "I will configure ..." 
	# intall menu/task flow is NOT sequential; uses star logic ...
		# Repeat + "Update Settings" [button] for each partition; 
		#   from "Unknown" list, select free partition, and 
		#   create 3 Logical Partitions: 
			/      SYSTEM   10 GB
			swap     swap    2 GB
			/home    DATA    5 GB
			/boot # auto-created @ install; 1GB, outside VG
		
		# leaves unused for RHCE tutorial purposes
		
	# REF: Windows 7        43 GB
	\Windows                24 GB
	\Program Files           5 GB
	\Program Files (x86)     3 GB
	\Users                   2 GB
	pagefile.sys             8 GB 

	# See 'REF.config.CentOS7.sh'


