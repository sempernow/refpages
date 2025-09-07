exit 
# RHEL Admin Guide - Part I. Basic System Configuration  https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/part-Basic_System_Configuration.html

# BOOT PROCEDURE :: systemd
	# BOOTLOADER https://en.wikipedia.org/wiki/Booting#BOOT-LOADER
	  # POST > MBR finds boot device > grub2 > kernel & initrd > mount root fs > systemd
	  # GRUB2 [Grand Unified Bootloader]
	  # https://www.gnu.org/software/grub/manual/grub.html 

	dmesg  # read kernel (boot) messages; e.g., AFTER boot; buffered  https://en.wikipedia.org/wiki/Dmesg

# GRUB2  https://www.certdepot.net/rhel7-get-started-grub2/
	#    https://wiki.centos.org/HowTos/Grub2
	# The Boot Menu is AUTOMATICALLY CREATED/MODIFIED
	/boot/grub2/grub.cfg  # DO NOT edit /boot/grub2/... files

	# VIEW boot menu entries per NUMBER and NAME
	awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
	# VIEW boot menu entries per NAME only 
	grep "^menuentry" /boot/grub2/grub.cfg | cut -d "'" -f2

	# EDIT boot menu per /etc/... files ...
	/etc/grub.d/40_custom  # ADD custom ENTRIES here (e.g., dual boot)
	/etc/default/grub      # edit BEHAVIOR ON BOOT
		GRUB_TIMEOUT=5
		GRUB_DEFAULT=saved     # DEFAULT BOOT entry; typically 'saved' (see below)
		GRUB_SAVEDEFAULT=true  # supposedly required or helps
		GRUB_DISABLE_SUBMENU=true
		GRUB_TERMINAL_OUTPUT="console"
		GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet"
		GRUB_DISABLE_RECOVERY="true"

		# Kernel options common to all entries are defined @ 
		GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet"  
		# For full detailed boot messages, delete 'rhgb quiet'; for standard, delete 'rhgb'

	# SET DEFAULT boot entry
		# If DEFAULT is 'saved', then edit per 
			grub2-set-default 2  # SETs to THIRD entry (identify per above @ 'View Boot Menu...')
			grub2-set-default 'Windows 7'  # set per name

			grub2-editenv list   # View change if 'GRUB_FEFAULT=saved'

		# If DEFAULT is an entry NAME, then simply edit that
			vim /etc/default/grub
				GRUB_DEFAULT="NAME"

	# DELETE old kernels (also cleans up grub2 menu)
	yum update yum-utils -y
	package-cleanup --oldkernels --count=1

	# REBUILD boot menu, AFTER editing, ...
	grub2-mkconfig -o /boot/grub2/grub.cfg           # @ BIOS (legacy Mainboards)
	grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg  # @ UEFI (2018+ Mainboards)

# DUAL BOOT  :: Windows-7 + CentOS-7
	# See 'REF.Install.CentOS-7@ASRock-AM1H-ITX.sh'

	# FIX @ Linux :: GRUB2 boot menu ...
	# UPDATE; NO FIX NEEDED; handled by os-prober [grub] if 'ntfs-3g' installed
		# NTFS :: mount/read/write 
			yum install epel-release -y
			yum install ntfs-3g -y	
		# https://www.gnu.org/software/grub/manual/grub.html
		# boot into RHEL; does not yet have 'Windows 7' option, so ... 	
		# Chain-loading :: for OS' that do NOT support GRUB/Multiboot
		#  E.g., if Windows system on 1st partition of 1st disk [sda1]
		vim /etc/grub.d/40_custom # edit/add ...
			menuentry 'Windows 7' {
			    insmod chain 
			    insmod ntfs   
			    set root='(hd0,1)'
			    chainloader +1
			} 
		# Regenerate Grub config file; legacy utility was 'update-grub'
			grub2-mkconfig -o /boot/grub2/grub.cfg             # bios 
			grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg    # UEFI
			
		# validate 
			cat /boot/grub2/grub.cfg
		# reboot 	
			systemctl reboot 
		
		# UPDATE :: don't need 40_custom after ntfs-3g pkg installed;
		#  grub os-prober finds windows bootloader and adds entry
		
		# os-prober :: can DISable [creates weird/long names] ...
		# https://www.gnu.org/software/grub/manual/grub.html#Configuration
			vim /etc/default/grub # edit/add ...
				GRUB_DISABLE_OS_PROBER=true

			# bad symlink-efi ?? NO, but destroyed it anyway on experimenting
				ls -l /boot/grub2
				mv grubenv grubenv.badlink # renamed symlink 
				grub2-editenv /boot/grub2/grubenv create # REcreates as regular file
				# also created by other utils, e.g., 'grub2-set-default'
				
		# If Windows itself fails to boot [corrupted BCD store], 
		# then boot into Win7PE and FIX the BCD Store using command...
			bootfix.bat c:\Windows c:    # Uzer cmd_library script
			# OR
			BCDboot.exe c:\Windows /s c: # the Windows native
		
	# FIX @ Windows :: BCD Store menu
		# ALTERNATIVE to 'FIX @ Linux' (above)
		# Add linux bootloader to Windows bootloader 
		# https://www.youtube.com/watch?v=rPUVIc-W13s 
		# @ Linux install, BEFORE 1st reboot ...
			# mount Windows system partition [c:]; e.g., 'dev/sda1'
				mkdir /mnt/share # create mount-point [temp dir]
				mount /dev/sda1 /mnt/share # mount Windows partition, c:\ , 'dev/sda1'
			# copy Linux bootloader to file 'centos7.bin' @ Windows root;
			# Linux bootloader is first 512 bytes @ /boot partition, e.g., '/dev/sda3'  
				dd if='/dev/sda3' of='/mnt/share/centos7.bin' bs=512 count=1
		reboot # into Windows 
		# BCD edit :: create/add boot entry [boot option]
			bcdedit /create /d "CentOS 7" /application BOOTSECTOR
		# copy/paste the generated {UUID}, INCLUDING CURLY BRACES, @ commands ...
			bcdedit /set {UUID} device partition=c:
			bcdedit /set {UUID} path \centos7.bin
			bcdedit /displayorder {UUID} /addlast
			bcdedit /timeout 30
			
			bcdedit # show/validate BCD Store entries
			# save a backup for future /restore operation
			bcdedit /export c:\BCDstore.Windows+Linux.exported

		# If want to start fresh with a new BCD store, 
		#  then BEFORE the above bcdedit commands, first run ... 
			BCDboot.exe c:\Windows /s c:
			# save a backup for future /restore operation
			bcdedit /export c:\BCDstore.Windows-only.exported

# INITIAL SETUP  [root perms required for most of these commands]
	# @ Integrated Windows/NTFS Desktop Environment

	# CIFS / SAMBA 
	yum install cifs-utils  # min required for fstab entry to be mountable
	yum install cifs-utils samba-client samba-common  # all related utils

	# NTFS :: mount/read/write 
		yum install epel-release -y
		yum install ntfs-3g -y

	# TEMP/TEST MOUNT [SOURCE & MtPt (folders) must both exist]
		mount SOURCE MtPt          # MtPt is target to which SOURCE is mapped/mounted
		# or 
		mount -t ntfs SOURCE MtPt  # '-t' NOT necessary for most FS types

	# SAMBA/CIFS share :: replace w/ apropos uid/gid number[s]
	vim /etc/fstab  # tab-delimited
	# edit ... e.g. ...
		//SMB/wde_40gb/40GB\040SAMBA	/media/SMB	cifs	owner,uid=1000,gid=1000,dir_mode=0700,file_mode=0700,credentials=/home/Uzer/etc/config/samba/cifs.creds.SMB 0 0 

	# create MOUNT POINT, e.g., `/media/SMB`
		mkdir /media/SMB
		# now can mount ...
		mount -a  # mount all per /etc/fstab

	# USER config (per custom 'synch' script)
		mkdir ~/etc          # USER config files go here
		synch smb pull       # pull user config from samba share
		
	# BASH config; protected, but configures all users ...
		sudo echo 'source "/home/${USER}/etc/_USER.cfg"' >> "/etc/profile.d/${USER}.sh"

	# SSH :: start sshd on boot 
		systemctl enable sshd.service
		vim /etc/ssh/sshd_config
			# disallow auth per password [FIRST establish public-key auth]
			PasswordAuthentication no            # default: yes
			ChallengeResponseAuthentication no   # default: no
	# WoL
		yum -y install ethtool
		# wake remote machine...
			ether-wake [-i REMOTE_INTERFACE_NAME] REMOTE_INTERFACE_MAC
		# setup local machine for WoL
			echo '/usr/sbin/ethtool -s eth0 wol g' >> /etc/rc.d/rc.local
		# OR 
			vim /etc/sysconfig/network-scripts/ifcfg-LAN # find w/ 'ls /.../ifcfg-*'
			# edit ...
				DEVICE=eth0
				TYPE=EThernet 
				ONBOOT=yes
				ETHTOOL_OPTS="wol g"
			 
		# start network on boot 
		 # CentOS-6
			chkconfig network on 
		# CentOS-7
			vim /etc/sysconfig/network-scripts/ifcfg-LAN # find w/ 'ls /.../ifcfg-*'
				# edit 
				ONBOOT=yes

	# suspend ... man systemd-suspend.service
		/etc/systemd/
			logind.conf # => edit ...
				IdleAction=suspend
				IdleActionSec=30min

		/etc/systemd/system/keepAwake.service # => create

			[Unit]
			Description=Inhibit suspend
			Before=sleep.target

			[Service]
			Type=oneshot
			ExecStart=/usr/bin/sh -c "(( $( who | grep -cv '(:' ) > 0 )) && exit 1"

			[Install]
			RequiredBy=sleep.target
			
# PRACTICAL/GENERAL 

	# Copy File Content to Clipboard using Xclip
		cat input.txt | xclip -i 

	# Internal Variables http://www.tldp.org/LDP/abs/html/internalvariables.html

	# Bash auto-sources on launch ...
		# if login shell ...
		~/.bash_profile
		# always; and, by default command, is sourced by .bash_profile too ...
		~/.bashrc 
		# ... which, by default command, sources ...
			/etc/bashrc # system-wide, which sources all '*.sh' @ ...
				/etc/profile.d/*.sh  
		# so, place bash-config script[s] ...
			# for CURRENT USER should be sourced per command @ ~/.bashrc 
			# for ALL-USERS should be @ /etc/profile.d/bashrc.custom.sh
			# or sourced per command therein; any 'NAME.sh' okay

	# Shell scripts @  ...

		/etc/profile.d # app config scripts [*.sh]

		/usr/local/etc # system-wide executables; in PATH for all users

		~/bin          # user-specific executables; automatically added to PATH
		~/etc          # not a required folder; NOT automatically added to PATH 

		# ~/ === $HOME === /home/$USER

	# make symbolic link
	ln -s '/media/CENTOS-6_8-/DATA/Linux REF/bash' ~/Desktop

	cat /proc/asound/cards

	# install VLC media player
	# http://www.tecmint.com/install-vlc-media-player-in-rhel-centos-fedora/
		# EPEL [Extra Packages for Enterprise Linux] 
		# https://fedoraproject.org/wiki/EPEL
		# EPEL has an 'epel-release' package that includes gpg keys for package signing and repository information. 
		# Installing this package for your Enterprise Linux version should allows yum to install packages and their dependencies.
	sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
	sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el6/i386/nux-dextop-release-0-3.el6.nux.noarch.rpm
	sudo yum install vlc

	# copy all folders/files @ current dir to ... home /Downloads/DATA
	cp -r *  ~/Downloads/DATA

	# system shutdown
	sudo /sbin/shutdown -r now

	# edit sudoers file in vi
	sudo visudo

	# add self to wheel
	usermod -aG wheel Uzer

	# Hardware Settings :: ls{NAME} & modprobe

		lsmod          # show active kernel modules
		modprobe NAME  # install module [expect/ignore warnings]
		rmmod          # remove module 
		
		lspci          # show PCI 
		lsusb          # show USB 
		lspcmcia 
		lshal
		lshw 

	# Runlevel Info 
	cat /etc/inittab 
		
	# Manage Shared Libraries [linked libraries; dll in Windows]

		ldd /bin/ls # list dynamic dependencies for 'ls' util		
				