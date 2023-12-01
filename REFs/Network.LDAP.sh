exit 
# LDAP [Lightweight Directory Access Protocol]
#   Single Sign-on using LDAP [directory/database] Server
#     https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol
#     https://en.wikipedia.org/wiki/Single_sign-on
#   DNS  :: server.rhatcert.com
#   LDAP :: cn=server,dc=rhatcert,dc = com
#   LDAP 'base context' ~ DNS domain

#  == 'RHCSA-LiveLessons' Video Tutorial 2015 ==

    which login
    # => 
    /bin/login # binary; for authentication of ... whatever
    # ... uses library files ...

    ldd /bin/login # query/show [ldd] Shared Library Dependencies ...
    # =>
	linux-gate.so.1 =>  (0x00700000)
	libpam.so.0 => /lib/libpam.so.0 (0x00c02000) # 'libpam.so' :: library that adds PAM awareness
	libpam_misc.so.0 => /lib/libpam_misc.so.0 (0x00626000)
	libselinux.so.1 => /lib/libselinux.so.1 (0x00605000)
	libaudit.so.1 => /lib/libaudit.so.1 (0x065ff000)
	libc.so.6 => /lib/libc.so.6 (0x002db000)
	libdl.so.2 => /lib/libdl.so.2 (0x00492000)
	libcrypt.so.1 => /lib/libcrypt.so.1 (0x072b5000)
	/lib/ld-linux.so.2 (0x002b5000)
	libfreebl3.so => /lib/libfreebl3.so (0x072af000)

# PAM [Pluggable Authentication Modules]
# NSS and PAM; modules required for LDAP authentication scheme @ client
# libpam.so :: library that adds PAM awareness
# Login config files @ ...

	/etc/pam.d

cat login # 'login' file contains config info/process
# =>
	auth       include      system-auth # system-auth file; main config for any LDAP authentication 
	account    required     pam_nologin.so
	account    include      system-auth

cat system-auth
# => 
	#%PAM-1.0
	# This file is auto-generated.
	# User changes will be destroyed the next time authconfig is run.
	auth        required      pam_env.so
	auth        sufficient    pam_fprintd.so
		.
		.
		.
# LDAP Server info @
	/etc/nslcd.conf

	less /etc/nslcd.conf # inspect it

	uri ldap://127.0.0.1/ # form of ldap server URI

	# e.g., 
	ldap://zflexldap.com

# LDAP Server Authentication; setup this machine as client of LDAP Server
	authconfig # cli & gui interfaces
		yum install authconfig-gtk # ... or 'rpm -q ...'
		yum install nscd nss-pam-ldapd pam_ldap # all needed 

	authconfig-tui # terminal/window [ncurses?] app

	authconfig-gtk # GUI app ...

	# GUI Menu
	
		User Account Database: 		LDAP
		LDAP Search Base DN:		dc=rhatcertification,dc=com
		LDAP Server:			ldap://server.rhatcertification.com
	
		[X] Use TLS to encrypt connections
	
		[button] Download CA Certificate ... 
			ftp://server.rhatcertification.com/pub/slapd.pem # STILL online [2015 RHCSA tutorial]
			[button] Okay 
			... wait [can take a while; though was instantaneous here]
	
		Authentication Method: 		LDAP password
	
		[button] Apply
	
	# Test/Validate LDAP User ...
		su - ldapuser5 # ldapuser[1-5] were created @ server for this tutorial # =>
		su: warning: cannot change directory to /home/guests/ldapuser5: No such file or directory
		# ... tutorial: "this is good; ignore the errors; will fix later..."

		# note; doesn't exist @ '/etc/passwd'; no home dir [can make one]
		grep ldapuser5 /etc/passwd # => null
		# but is user ...
		id
		# => 
		uid=5005(ldapuser5) gid=5005(ldapuser5) groups=5005(ldapuser5) context=unco...t:s0-s0:c0.c1023

	# NOTE: searched for Online/Test/Free LDAP Servers; they do NOT give CA Certificate URL 
	# E.g., ...
		LDAP Server Information (read-only access):

		Server: ldap.forumsys.com  
		Port: 389

		Bind DN: cn=read-only-admin,dc=example,dc=com
		Bind Password: password

		All user passwords are password.

		You may also bind to individual Users (uid) or the two Groups (ou) that include:

		ou=mathematicians,dc=example,dc=com

			 riemann
			 gauss
			 euler
			 euclid

		ou=scientists,dc=example,dc=com

			 einstein
			 newton
			 galieleo
			 tesla

# LDAP Client :: Automount server; auto-setup of home/LDAP_USER directories for all LDAP users

	# Automount is a system that automates access to home dirs; 
	#  to the [NFS or Samba] server hosting the home directories

		# NFS :: works @ local [LAN only]; does NOT work on the internet

			#  User          <==>      automount
			------------             -----------------
			cd /foo/bar       ==>    /etc/auto.master
							   
				                      /foo   /etc/auto.foo
								 
			user@server:bar  <==     bar -rw nfsserver:/foo # NFS Mount

		# Samba/CIFS :: works @ LAN|WAN; works on the internet; more complicated than NFS

			#  User          <==>      autofs
			------------             -----------------
			cd /home/guests   ==>    /etc/auto.master
				                      /home/guests   /etc/auto.guests # contains cifs mounts per guest

						* -fstype=cifs,username-ldapusers,password=password \
							 ://server.rhatcertification.com/data/&

         # Automount [autofs] maps user; '*' and '&' ==> 'ldapuser1';
         cd /home/guests/ldapuser1  #   

			[ldapuser1@rhelserver ~]$  <==    * -fstype=cifs,username-ldapusers,password=password \
							           ://server.rhatcertification.com/data/&

	# Automount [autofs] NFS Server :: Configure client for all LDAP users
		yum install autofs

		vi /etc/auto.master
			# edit/add ['guests'] can be any name ... 
			# LDAP users :: config auto home dir [TAB-separated fields]
			/home/guests    /etc/auto.guests

		# create ...
		vi /etc/auto.guests
			# add [TAB-separated fields] ...
			# for NFS ...
			*       -rw     nfsserver:/home/guests/&
			# for Samba
			*	-fstype=cifs,username=ldapusers,password=password ://server.rhatcertification.com/data/&

# NFS Server :: setup; create LAN share on this machine
	yum search nfs
	rpm -qa nfs-utils
	yum -y install nfs-utils

	vi /etc/exports # create/edit
		# tab-separated fields :: what to export; mount options; access/users;
		/data	-rw	*(rw,no_root_squash)

	# start NFS server
	systemctl start nfs
	systemctl status -l nfs
	service nfs start 	# CentOS 6.8
	
	# validate NFS server ...
	showmount -e localhost # exported mounts on server 'localhost' # =>
		' # -- single-quotes added cuz weird gedit highlighter issue --
		Export list for localhost:
		#/data * # 
		'
		# mount 
		mount localhost:/data /mnt 
		
		# note how it mounts on top of whatever else was there; filesystems can be mounted on top of one another 
		# unmount to return prior level mount 
		
		umount localhost:/data
		
		# Automount it ...
		vi /etc/auto.master
			# add [tab delimited] ...
				# NFS Server ...
				/nfsserver	/etc/auto.nfsserver
		
		# create
		vim /etc/auto.nfsserver
			# add [tab delimited] ...
				localdirNAME	-rw	localhost:/data
		
		service autofs restart # =>
			Starting automount:                                        [  OK  ]
		
		ls -a /nfsserver  # =>
			.  ..
		cd /nfsserver/localdirNAME # =>
			[root@CentOS localdirNAME]# 
			
		ls -a /nfsserver  # =>
			.  ..  localdirNAME

# nslcd process :: directs LDAP scheme
	service nslcd status # CentOS 6.8 =>
		nslcd is stopped
	systemctl status nslcd # CentOS 7 =>
			.
			.
			.
		... systemd[1]: Naming services LDAP client daemon # the glue between linux services and the LDAP server.
		... /etc/nsswitch.conf # handles identity/auth for LDAP users

	# PAM [Pluggable Authentication Modules]; LDAP authentication mechanism
	/etc/pam.d
	
	# populated w/ base-configuration, etc, per authconfig-gtk app [above]
	/etc/nslcd.conf
	
		grep 'rhatcertification' /etc/nslcd.conf # => 
			uri ldap://server.rhatcertification.com
			base dc=rhatcertification,dc=com
	

