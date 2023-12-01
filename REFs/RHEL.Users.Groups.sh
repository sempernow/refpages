# Users and Groups
# +Notes from 'RHCSA-LiveLessons' Video Tutorial 2015
# +Managing Group Access (yolinux.com)
# http://www.yolinux.com/TUTORIALS/LinuxTutorialManagingGroups.html
	# User accounts are created, not just for people, but to isolate processes 
	ps aux | less # view all processes and user accounts under which they run.
	# I.e., http daemon run under 'apache' 'user' account, 
	# so that if intruder breaks thru to shell access, 
	# the intruder gains access only to whatever user account 'apache' permitted.

	# UNLIKE Windows, group access is binary
	# NOTE: careful with RHEL notion that each user gets its own group; 
	uid=500(USERNAME) gid=500(USERNAME)
	# Okay, but RHELs security notions are NOT accepted by services. 
	# E.g., sshd Auth FAILs if 770 instead of 700; or 660 instead of 600.

# SHOW all USER & GROUP INFO of CURRENT user
	id  # =>
		uid=500(USERNAME) gid=500(USERNAME) groups=500(USERNAME),10(wheel) ...

# QUICK 
	# Create new Admin user (add to wheel group)
	sudo su                      # switch to root acct 
	adduser uZerName             # create new user
	passwd uZerName              # set password
	usermod -aG wheel uZerName   # add to wheel group
	exit                         # logout of root
	# now login as uZerName


# USER/GROUP MANAGEMENT FILES
	# can quickly mod these using vi[m] ...
	/etc/passwd  # list: all USERNAME:x:UID:GID:GECOS:$HOME:$SHELL
	/etc/shadow  # list: all user:'pass-hash:...', OR 'user:!!...' IF ACCOUNT is DISABLED|LOCKED
	/etc/group	 # list: all groups, 1 per line; name:x:GID:member(s)

	# PARAMETERs FILES
		/etc/login.defs       # On RedHat/CentOS based systems
		/etc/deluser.conf     # On Debian and its derivatives
				
		/etc/default/useradd  # 'useradd' defaults file 
			GROUP=100
			HOME=/home
			INACTIVE=-1
			EXPIRE=
			SHELL=/bin/bash
			SKEL=/etc/skel    # all files here are copied to new user's home dir per 'useradd'
			CREATE_MAIL_SPOOL=yes

				ls -al /etc/skel  # => 
					.gnome2
					.mozilla
					.bash_logout
					.bash_profile
					.bashrc

# USERS
	/etc/passwd  
		USERNAME:x:UID:GID:GECOS:$HOME:$SHELL  # # User ID [UID]; 64,000 available
		# E.g., 
		uZer:x:500:500:Greg:/home/uZer:/bin/bash
		# 1st field is username
		# 2nd field is password
		# 'x' is placeholder for password; was stored here; now @ '/etc/shadow' 
		# 3rd field is UID
		# 4th field is GID
		# 5th field is GECOS field; e.g., real name; shown @ GUI login, etal
		# 6th field is Home Directory; '/home/USERNAME'
		# 7th field is Default Shell; '/bin/bash'

		grep home /etc/passwd      # list all users having a home dir 
		grep USERNAME /etc/passwd  # show all info for user USERNAME
		
	/etc/shadow 
		USERNAME:$6$U5RNa...:UID::::...
			grep uZer /etc/shadow  # => (password hash, NOT plain-text)
				uZer:$6$U5RNa.../DPinW...dd9iI.5b4Y0:17155:0:99999:7:::
				# if acct DISABLED, then pass-hash is (prepended with) '!!', e.g., 
					mysql:!!:16943::::::

		# E.g., change user's HOME dir; default is /home/$USERNAME
		sudo vim /etc/passwd  # E.g., from `/home/uZer` to `/mnt/s/HOME`
		# ... edit @ username, then reboot
		# Reset Password
		passwd $USERNAME

	# ADD USER; CREATING AND MANAGING USERS
		useradd
		# E.g., Add a new user and assign them to be members of the group "accounting":
			useradd -m -g accounting user2
		# Add a new user; assign as members of initial group "accounting" and supplementary group "floppy":
			useradd -m -g accounting -G floppy user1

		useradd --help
		useradd -e YYYY-MM-DD # expiration date

		useradd -c 'GECOS comment' -e 2017-01-22 -s /bin/tcsh USERNAME
		tail -n 1 /etc/passwd  # => 
			foo:x:502:503:GECOS comment:/home/USERNAME:/bin/tcsh

	# VIEW 
	/etc/shadow
		sudo tail -n 1 /etc/shadow
			USERNAME:!!:17187:0:99999:7::17188:
			# Epoch Unix Time: 17188 <==> 01/01/1970 @ 4:46am (UTC)

	# SET PASSWORD of user
		passwd USERNAME  # =>
			New password: 
			BAD PASSWORD: it is based on a dictionary word
			BAD PASSWORD: is too simple
			Retype new password: 
			passwd: all authentication tokens updated successfully.

			# VIEW 
			sudo tail -n 1 /etc/shadow  # => 
				USERNAME:$6$uHm....tPpd1...Xg5.cX...3M6O.:17187:0:99999:7::17188:
		 
			# TEST 
			su USERNAME

	# MANAGING PASSWORDS
		passwd --help
		passwd userNAME      # set password
			-l userNAME      # lock userNAME's password [lock account]
			-u userNAME      # unlock userNAME's password [unlock account]
			-x 90 userNAME   # expire password after 90 days

		chage  --help
		chage -l userNAME    # show userNAME's password settings
		chage -M 90 userNAME # max days before password reset required 

		pwck                 # Verify integrity of password files

	# DELETE USER
		# 1. User must be logged out and have no running processes
			passwd -l USERNAME                        # lock account
			usermod --expiredate 1970-01-02 USERNAME  # expire account
			
		# 2. kill all running processes of user
			# list PID(s) of all running processes of USERNAME
			pgrep -u USERNAME                 
			# inspect them ... UID PID PPID C STIME TTY STAT TIME CMD of USERNAME
			ps -f --pid $(pgrep -u USERNAME)  
			# kill all those processes
			killall -9 -u USERNAME  # SIG-INT 9
			# or
			killall -KILL -u USERNAME

				# 'killlall' is in 'psmisc' pkg; 
					sudo yum install psmisc
		
		# 3. delete user files 
			userdel --remove USERNAME       # On RedHat/CentOS based systems
			deluser --remove-home USERNAME  # On Debian and its derivatives

			userdel -r -Z USERNAME          # -r = --remove; -Z = SELinux settings [RedHat/CentOS]
						
			# to remove ALL FILES owned by USERNAME on the system, ADD the option ...
			--remove-all-files

# GROUPS 
	/etc/group 
	# RedHat uses Private Group as default Primary Group; 
	# GID of user is Primary Group ID; can create and add user to  other groups [Secondary Groups]
	# Groups [GID]; every user is member of primary group; group name/GID same as name/UID .
	grep USERNAME /etc/group  # =>
		wheel:x:10:USERNAME
		USERNAME:x:500:

	grep groupNAME /etc/group  # => pseudo-output ...
		groupNAME:x:GID:USERNAME1,USERNAME2,... # name:x:GID:member[s]

	groups user-id  # Show user's group membership(s)

	# ADD GROUP; CREATE AND MANAGE GROUPs
		groupadd --help

		groupadd newGroup # make/add new group
		tail -n 1 /etc/group
			# => 
			newGroup:x:504:

	# GROUP COMMANDS 
		gpasswd    # Administer the /etc/group file
		groupadd   # Create a new group
			groupadd [-g gid [-o]] [-f] [-K KEY=VALUE] group
			# E.g., 
			groupadd accounting
		groupmod   # Modify a group
			groupmod [-g gid [-o ]] [-n new_group_name] group
			# E.g., Change name of a group: 
			groupmod -n accounting nerdyguys
		groupdel   # Delete a group
			# E.g., 
			groupdel accounting
		vigr       # Edit the group file /etc/group with vi. No arguments specified.
		newgrp     # Change you DEFAULT GROUP 
			# E.g., 
			newgrp GROUPNAME 
		chgrp      # Change GROUP ownership of a file; can also use 'chown'
			# E.g., 
			chgrp GROUPNAME FILEPATH 
		grpck      # Verify integrity of group files
			# E.g., 
			grpck /etc/group

# MODIFY USER|GROUP accounts
	chage 
		chage -E YYYY-MM-DD uZer       # set account expiration date
		chage -R     CHROOT_DIR uZer   # account root; change
		chage --root CHROOT_DIR uZer   # account root; change

	usermod 
		usermod -e YYYY-MM-DD uZer     # set account expiration date
		usermod -l      NEW_LOGIN      # change login name
		usermod --login NEW_LOGIN      # change login name
		usermod -md HOME_DIR uZer      # move [-d] user's home dir; copying existing content [-m]
		usermod -L -e 1 uZer           # disable user's account (lock password)
		usermod -L -e 1970-01-01 uZer  # disable user's account (lock password)
		# add user to group
		usermod -aG newGROUP uZer      # APPEND 'newGROUP' to user's group [membership] list
		# '-G', by itself, overwrites; removes all other group memberships for uZer
		usermod -c "new comment"       # or use `chfn` utility

			# validate change[s] ...
			su foo 
			id #=>
				uid=502(foo) gid=503(foo) groups=503(foo),504(newGroup) ...

# FILE OWNERSHIP USER/GROUP/OTHER [ugo]
	chown # change file owner and group [user-ownership]

	chown USERNAME FILEPATH      # change OWNER [user-ownership] of a file 
	
	chown -R USERNAME FOLDERNAME # change owner of all in/under foldername 
	
	chown USERNAME:GRPNAME FNAME # change owner AND group
	chown USERNAME.GRPNAME FNAME # same [older, less compliant]
	chown :GRPNAME FNAME         # change GROUP ownership [omit owner]
				
	chgrp GROUPNAME FILEPATH     # change GROUP ownership of a file [can use chown, above]

# FILE|DIR|DEVICE PERMISSIONS
	chmod PERMs TARGET 

          oct 
	r      4  # Read 
	w      2  # Write (modify) 
	x      1  # Execute script (if file); read (if directory); requires 'r'
	rx     5  # Read and Execute
	rw     6  # Read and Write
	rwx    7  # Read, Write and Execute

	u  # User access
	g  # Group access
	o  # Other system user's access
	a  # Equivilent to "ugo" 

	# E.g., Grant modify or delete permissions to a file which you own for everyone in the group:
		chmod ugo+rw  DIR/FILE
		chmod ugo+rwx DIR  # must be able to mod dir

	# E.g., Allow everyone in your group to be able to modify the file:
		chmod 660 file-name

