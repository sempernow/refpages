exit
# OpenSSH a.k.a. "OpenBSD Secure Shell"
# Library of utilities for secure comms; 
# https://en.wikibooks.org/wiki/OpenSSH  
# https://en.wikipedia.org/wiki/OpenSSH 
# https://www.openssh.com/ 
# v4.3+ implements an OSI layer 2/3 TUN-based VPN

# SSH : Secure Shell 
# an OpenSSH utility; Network-level (Layer 3)    
#   CLIENT: local machine; ssh user's machine
#   SERVER: remote machine; host, yet has per-client config too. 

man ssh
man ssh_config

# CLIENT services :   (client;you)    <==>    sshd (server)

    # SSH : TL;DR

        # Launch a login shell through an SSH tunnel
            ssh -i $key_path ${user}@${hostname_OR_ip}
            ## If host is Git server (GitHub/GitLab), then user is 'git' *not* the ssh user.
            ssh -T -i ~/.ssh/gitlab git@gitlab.com # -T to DISABLE tty/pty allocation.
            ## Manage per-host connections DECLARATIVELY at ~/.ssh/config : man ssh_config
                # Host foo
                #   HostName 10.111.0.101 www.foo.org foo.org 
                #   User u1003
                #   CheckHostIP yes
                #   Port 2222
                #   IdentityFile ~/.ssh/foo_u1003
            ## Thereafter simply:
            ssh foo

        # Generate key pair : Default type (-t) is 'rsa' : No passphrase prompt (-N '')
            # Instead of using default key names (id_rsa, id_ecdsa, id_ed25519),
                # Use a naming convention that allows for *rotations per context* (domain, account)
                # E.g., ~/.ssh/local_$(id -un) for a key to all hosts on an RFC1918 (local) network:
                key=~/.ssh/${target_host}_$account # Limits blast radius to this context.

            # Default : Generates an ED25519 pair at ~/.ssh/id_ed25519 
                ssh-keygen # Queries for target location (verify[,overwrite]) and passphrase
            # Elliptical
                # Use ed25519 variant; best, though *not yet* FIPS-compliant
                ssh-keygen -t ed25519 -C "$(id -un)@$(hostname)" -N '' -f $key_path
                # Else use ECDSA; NIST-approved & FIPS compliant (Note ECDSA bits options: 256, 384 or 521)
                ssh-keygen -t ecdsa -b 521 -C "$(id -un)@$(hostname)" -N '' -f $key_path
            # RSA : use bit length option with at least 2048 (OpenSSL default) else 4096
                ssh-keygen -t rsa -b 2048 -C "$(id -un)@$(hostname)" -N '' -f $key_path 

            # Re(Set) key's passphrase (local security)
                ssh-keygen -p -P $old -P $new -f $key_path 
            # Re(Set) key's comment : user's email address or $(id -un)@$(hostname)
                ssh-keygen -c -C "$(id -un)@$(hostname)" -f $key_path

            # Show fingerprint (FPR) of keypair : either key of a pair have same FPR
                ssh-keygen -l[v] -f $key_path # -v : show visual in addition to the hash.
            # Show FPRs of KNOWN (remote) HOST(s) 
                ssh-keygen -lf ~/.ssh/known_hosts

        # Push PUBLIC key to remote (SSH server)
            ssh-copy-id -i $key_path ${user}@$host

        # @ PUSH KEY TO HOST (ssh-copy-id) SECURELY 
            # 1. List FPRs of host : scan a host's key(s) and print the fingerprint(s)
                ssh-keyscan $host 2>/dev/null |ssh-keygen -lf -
            # 2. Push key on query ONLY IF host CLAIM VALIDATES AGAISNT the SCAN above (1).
                ssh-copy-id -i $key_path ${user}@$host
                #... Answer prompt w/ 'yes' if host claim is valid.
                # Host then prompts for password if sshd config allows that,
                # lest host ~/.ssh/authorized_keys file contains another of your keys 
                # (configured at ~/.ssh/config, or of a default name).

        # @ FIRST CONNECT 
            # 1. Scan keys of the new host and print the fingerprint(s) (FPRs)
                ssh-keyscan $host 2>/dev/null |ssh-keygen -lf - # See response below:
                # 256 SHA256:MBJ9WyUc/yQp9AIR4NQhRREdL93JTmEozv+ur/SYV84 192.168.0.79 (ED25519)
                # 256 SHA256:bbD7uhL/UOszb8g3r/nv/qcA2iEsuiIqAbp2PdZMbz4 192.168.0.79 (ECDSA)
                # 3072 SHA256:UVcGRWmd1VbVWjqleuOIgC6M/O86cNlpLowi3otzZ/g 192.168.0.79 (RSA)
            # 2. Connect to host : This mitigates MITM-type attacks
                # VALIDATE host's claim against keys scan on query 
                ssh -i ~/.ssh/vm_common ${user}@$host 
                # Example response: 
                    # /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/c/HOME/.ssh/vm_common.pub"
                    # The authenticity of host '192.168.0.79 (192.168.0.79)' can't be established.
                    # ED25519 key fingerprint is SHA256:MBJ9WyUc/yQp9AIR4NQhRREdL93JTmEozv+ur/SYV84.
                    # This key is not known by any other names
                    # Are you sure you want to continue connecting (yes/no/[fingerprint])? 

        # (Re)Create PKI of SSH server : Use this method for hosts (re)built from same VM volume (template), else host keys are *not* unique.
            # 1. Remove all existing SSH host keys
            sudo rm -f /etc/ssh/ssh_host_*
            # 2. Regenerate new SSH host keys
            sudo ssh-keygen -A
            # 3. Restart the SSH service
            sudo systemctl restart sshd

        # Remove OBSOLETE host keys (else ssh warns of possible attack in progress) from client's known-hosts file:
            ssh-keygen -R $hostReference # Reference is typically hostname or IPv4 address of the obsoleted host 
            # Else by manual edit:
            vi ~/.ssh/known_hosts

        # REMOTEly execute a LOCAL script via secure shell, injecting both local and remote ENVIRONMENTs ...
            ssh ... /bin/bash -s < /path/to/local/script.sh "$local_foo" "\$remote_foo"
            #... This scheme writes nothing to remote filesystem.
            # For other interpreters, ...
            ssh ... /usr/bin/python3 -s < /local/path/to/script.py

    # SCP : Secure Copy  https://en.wikipedia.org/wiki/Secure_copy
        scp # Secure Copy per ssh(1)
            -C      # Compress during transfer
            -i      # ssh identity file
            -o      # ssh(1) options
            -p      # Preserve mtime 
            -q      # Quiet (sans progress)
            -r      # Recursive copy; else ignores all files under any directory
            -T      # Disable strict filename checking; mitigate (per distro) file-handling quirks.

        scp -i $keypath ... 

        # PUSH/PULL a local/remote SOURCE to TARGET: 
            scp -Cpr -i ~/.ssh/key2 SOURCE  user2@host2:TARGET  # PUSH : local source, remote target
            scp -Cpr -i ~/.ssh/key1 user1@host1:SOURCE  TARGET  # PULL : remote source, local target
            
            scp -p  $source user@host:$target  # push FILE 
            scp -pr $source user@host:$target  # push DIR
            
            scp -pr ./foo   ${user}@${host}:~  # Push local DIR,            ./foo, to ~/foo @ host.
            scp -pr ./foo/* ${user}@${host}:~  # Push CONTENT of local DIR, ./foo, to ~/    @ host.

    # SFP : Secure FTP (SFTP)  https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol
        sfp ; scp2 

    # SSH : Scheme
        # Authentication Token is generated and sent to server by client upon session login/connect; 
        #   encrypted using the user's (client) private key (identity file; -i); 
        #   if server can decrypt using user's public key, 
        #   found @ ~/.ssh/authorized_keys/, then user is authentic[ated]. 
        # Server validation is ASSUMED. So, ON FIRST CONNECT, 
        # server's fingerprint (fpr) is displayed with a warning
        # lest by `ssh -o StrictHostKeychecking=no ...`;
        # if client accepts, then server fpr is ADDED to client's ~/.ssh/known_hosts (file). 

    # CONFIGURATION paths
        /etc/ssh_config  # sshd; system-wide config
        ~/.ssh/config    # ssh; per-user config

        # OWNER/PERMISSIONS REQUIRED by SSH (ssh, sshd), so set @ ALL MACHINEs:
        chmod 700 ~/.ssh
        find ~/.ssh -type f -exec chmod 600 {} \;

        # @ Windows OS, ACLs set to 'Full' access; SIDs "%USERNAME%" + 'SYSTEM'.
        # I.e., @ $HOME dir, remove 'Inherited' perms, and all other SIDs,
        # and apply changes to '... all child objects ...'.
        # (Okay to include 'Administrators' SID too.)

        # SELinux Contexts 
        restorecon -Rv ~/.ssh 

    # KNOWN-HOSTS file : stores host fingerprints (FPRs)
        # FPR of the remote host (SSH server) is added per user input at user query on 1st connect,
        # so validate its claim (mitigate MITM attacks) against a ssh-keyscan executed beforehand.
        # Run: `ssh-keyscan $host 2>/dev/null |ssh-keygen -lf -` just prior to first connect.
        ~/.ssh/known_hosts

    # AUTHORIZED KEYS (@ remote/host) file; contains PUBLIC keys of clients;    
        ~/.ssh/authorized_keys 
        # OR
        ~/etc/.ssh/authorized_keys 
         # @ router; AC66U [Merlin]
        /tmp/home/root/.ssh/authorized_keys 

            # Push PUBLIC key to remote by referencing PRIVATE key "identity file" (-i)
            ssh-copy-id -i $key_path -p $number $user@$host 
            #... only if remote already has client's key, or password login is available, 
            # else must use some out-of-band process to insert key into remote's authorized_keys file.

    # FINGERPRINT (fpr)
        # Show fingerprints of a host's keys gathered from a scan
        # Public and private keys (of a pair) have the SAME fpr.
        # RUN THIS prior to 1st connect : validate host's claim against it.
            ssh-keyscan $host |ssh-keygen -lf -             # Includes host-response text
            ssh-keyscan $host 2>/dev/null |ssh-keygen -lf - # Sans 
        # Git host user's FPRs 
            curl -s https://$host/$account.keys |ssh-keygen -lf -
            # Git host user's public keys 
                curl https://$host/$account.keys
                # @ GitHub
                curl https://github.com/$account.keys
                curl https://api.github.com/users/$account/keys    # API : JSON response body
                #> {id: number, key: string, created_at: string, last_used: string}
                # @ GitLab
                curl https://gitlab.com/$account.keys
                curl https://gitlab.com/api/v4/users/$account/keys # API : JSON response body
                # [{id: number, title: string, created_at: string, expires_at : string, last_used_at: string, key: string, usage_type: string}]

        # RUN THIS on any subsequent connection to validate
            # Default hash AKA "Encryption" (-E) shown is SHA256 
            # -v to include a visual (graphic) too.
            ssh-keygen [-E md5] -lvf ~/.ssh/known_hosts    

        # E.g., Show fingerprint of a key, in the old MD5 format (GitHub uses that)
            ssh-keygen [-E md5] -lf ~/.ssh/github_rsa.pub    

        # @ Host : SSHFP Record (Secure Shell fingerprint record )
        # https://en.wikipedia.org/wiki/SSHFP_record
            ssh-keygen -r HOST # prints in ' ZONE FILE FORMAT' ... 
            <Name> [<TTL>] [<Class>] SSHFP <Algorithm> <Type> <HEX Fingerprint>

        # DEBUG ... increasing verbosity [1-3x 'v']
            ssh -v[vv] user@host.domain 2> ssh.log # info @ connet AND disconnect    
            ssh -v[vv] user@host.domain -E ssh.log # info @ connet AND disconnect    
            
        # view authentication log msgs ...
            /var/log/auth.log

        # MONITOR ssh connections (tunnels)
            lsof -i -n |grep ssh       # open files; internet-related (-i) 
            netstat -tulpen |grep ssh  # connections per host:port and process 

        # PREVENT QUERY on first connect (useful @ scripts)
            ssh -o StrictHostKeyChecking=no ...
        # CONNECT TIMEOUT
            ssh -o ConnectTimeout=5 -o ...

    # CONNECT/login [local client to remote server]

        # BYOC (Bring your own creds)
        ssh -i ${key_path} ${user}@${hostname_OR_ip} #... e.g., ...
        ssh -i ~/.docker/machine/machines/${_VM}/id_rsa ubuntu@kvpairs.com
        #... If `-i ...` is ommitted, then ALL KEYS @ ~/.ssh/ are tried,
        #    unless $user@$host matches a configuration @ ~/.ssh/config .

        # @ public key @ ~/.ssh/config
        ssh ${user}@${hostname_OR_ip}
        # OR
        ssh -l $user ${hostname_OR_ip}
        # OR, if `Host ...` @ `~/.ssh/config` 
        ssh xMachine

        # most commmon connection ISSUES are due to FILE OWNER/PERMISSIONS
        # on private key or folder (see CLIENT section), or  USERNAME@HOST spelling
            'Permission denied (publickey).' # See PERMISSIONS section

        # options; overrides those of default config 
            -i KEY_PATH         # identity file; defaults: ~/.ssh/id_rsa @ ssh-v.2
            -v[v[v[v]]]         # Verbosity (level)
            -F CONFIG_FILE      # use specified config file instead of defaults.
            
            -G  # print configuration (per host) and exit; no connection made

            -X  # Enables X11 forwarding; override ssh config `ForwardX11 no`
            -Y  # Enables trusted X11 forwarding; bypass X11 SECURITY ext controls
            
            # pseudo-tty allocation (shell access) 
            -t  # force pseudo-terminal (TTY/PTY) allocation; 
                #... may solve: 'TERM ... variable not set' warning[s]
            -T  # Disable TTY/PTY allocation (Git servers disable shell access) 
                
            # Port forwarding (see man pages for more)    
                -L local_socket:host:hostport    # local (client) port forwarded to remote.
                -R remote_socket:host:hostport   # remote (server) port forwarded to local. 
                -p port_number user@host.domain  # remote port for this connection    
                # https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding    

                # Port forwarding MULTIPLE PORTS 
                    # ... then can ...
                        ssh localhost -p 8822  # connects to REMOTE_IP_FOO
                        ssh localhost -p 9922  # connects to REMOTE_IP_BAR 

                # Reverse/Remote Forwarding (R) : Use cases
                    # Forward a web server from your machine to the remote
                    ssh -CfNR 8080:localhost:80 $user@$remote
                    # remote:8080 → your-machine:80 (a web server)

                    # Forward a database
                    ssh -CfNR 3306:localhost:3306 user@remote
                    # remote:3306 → your-machine:3306 (a database)

                    # Forward to a specific internet host from your side
                    ssh -CfNR 8080:internal-wiki.corp:80 user@remote
                    # remote:8080 → your-machine → internal-wiki.corp:80

                    # On jump box, forward a specific service to the RDBMS
                    ssh -CfNR 123:ntp.example.com:123 $user@rdbms_ip
                    # RDBMS now has localhost:123 → ntp.example.com:123


        # CACHE key PASSPHRASE for one-time entry 
            # Use case is key (for human CLI user) created/secured with a passphrase.
            # Add to bash shell config file:
            if [ -z "$SSH_AUTH_SOCK" ]; then
                eval $(ssh-agent -s) # Launch ssh-agent into background process
                ssh-add $key # Prompt/Add key's passphrase; cache for lifetime of this shell. 
            fi

        # ADD host's key to ~/.ssh/known_hosts file 
            # (Otherwise ADDED AUTOMATICALLY on first connect) 
            # Get the host key(s)
            ssh-keyscan $host
            #... Copy that entire string: "THE_HOST_IP:22 SSH-..." 
            #    to our known_hosts file (here at the machine we're calling from): 
            ~/.ssh/known_hosts #... append it.

        # REMOVE an "offending" key
            ssh-keygen -f ~/.ssh/known_hosts -R $_OFFENDING_IP_ADDR
                #... this occurs whenever any network params change, 
                #     e.g., reprovisioned VM(s), or re-attach EIP to another VM (AWS EC2); 
                #     public key of old instance is retained in client's known_hosts.

        # Establish UNIX SOCKET for connection REUSE / SHAREing (multiple sessions)
            # ControlMaster (man ssh_config) : FAILs @ WSL(2)
            # @ ~/.ssh/config
                # Host github
                #     Hostname www.github.com
                #     ControlMaster auto                    # Automatically use if exist; create socket otherwise
                #     ControlPersist 600                    # TTL (seconds) after idle; forever if 0 or yes 
                #     ControlPath ~/.ssh/master-%r@%h:%p    # master-USER@HOST:PORT
                # Thereafter:
                ssh github          # logon
                ssh -O exit github  # kill that socket

            # @ Imperatively

                # Open : See TOKENS section (%r, %h, %p, ...) of man ssh_config
                ssh  -S ~/.ssh/master-%r@%h:%p $user@$host
                # Show
                ssh -O check $user@$host
                # Close
                ssh -O exit $user@$host 
                    # Options
                    # Socket sharing/reuse
                    -S -o ControlPath ~/.ssh/sockets/%r@%h:%p # Socket path (created) 
                                %r # gets set to remote username
                                %h # gets set to host
                                %p # gets set to port
                        -o ControlMaster=auto  # auto|yes|no : 'auto' FAILs @ WSL : 'yes' FAILs on 1st connect.
                        -o ControlPersist=600  # Max time between connections until connection closed.
                    # Keep alive if no activity
                    -o ServerAliveInterval 60  
                    -o ServerAliveCountMax 3
                    -fNM
                        -f  # go to background just before command execution; implies (includes) -n ().
                        -N  # Do not execute a remote command; useful for forwarding ports.
                        -n  # Redirects STDIN to /dev/null; MUST BE USED if ssh is run as background process
                        -M  # “master” mode for connection sharing.

        # TCP Forwarding  https://blog.fatedier.com/2015/07/22/ssh-port-forwarding/
        ssh -oPort=22 -CNfg -R 40000:localhost:22 root@11.11.11.11

        # RUN LOCAL SCRIPT remotely
        # - Using pipe
        cat /path/to/script |ssh -T user@host /bin/bash -s - $local_arg \$remote_arg 
        # - Using redirect : May err if args "$@", reporting "ambiguous redirect"
        ssh user@host /bin/bash -s < script $local_arg \$remote_arg 
        # - As sudoer (lead space to prevent entry in history)
        HISTCONTROL="ignoreboth"
         echo 'PASSWORD' |ssh user@host sudo /bin/bash -s - < script $local_arg \$remote_arg 

        # - In a background process
        ssh -n -f user@host /bin/bash -c 'nohup /where/what >/dev/null 2>&1 &'

    # CONFIG CLIENT MACHINE

    # KNOWN HOSTS; ssh process validates server on first connect to ensure it's not a fake 
        # On 1st connect, ssh [client-process] asks user to approve "...unknown...". 
        # If answer 'yes', then ssh client saves
        #+ host [server] pub key FINGERPRINT to ...
        ~/etc/.ssh/known_hosts # fingerprints [approve per ssh logon] 

        ssh-keyscan  # is a utility for GATHERING the PUBLIC ssh HOST KEYS of a number of hosts; to aid in building and verifying ssh_known_hosts files; VERY FAST; client does NOT need login access to the machines that are being scanned, nor does the scanning process involve any encryption.
        -H       # Hash all hostnames and addresses; protects host?
        -t TYPE  # dsa, ecdsa, ed25519, rsa
        -f FILE  # Read hosts or “addrlist namelist” pairs from file, one per line.

        # Create key pair
            ssh-keygen -t ed25519 -C "$(id -un)@$(hostname)" -f ~/.ssh/host1
            # Sans -f, prompts for location; default ~/.ssh/id_ed25519 (and its .pub mate)
            # Prompts for passphrase; ssh-agent caches passphrases
            # Create SSH-configuration entry for a host (SSH server) 
            # to which the public key of this pair will be pushed (See ssh-copy-id).
            vi ~/.ssh/config
                Host name1  
                    HostName host1.domain
                    User user1
                    RequestTTY no
                    IdentityFile ~/.ssh/host1

                # Once configured and the key is pushed to host,
                # connect sans password by merely:
                    ssh name1

        # E.g., to ADD host to `known_hosts` file: 
            ssh-keyscan -H github.com >> ~/.ssh/known_hosts

        # CONFIG system-wide [@ client machine]
        /etc/ssh/ssh_config 

        # CONFIG per user [@ client machine]
            # overrides system-wide; `config` overrides `ssh_config`
            #  allows for different keys per host [server]
            ~/.ssh/config # See: man ssh_config

                # overrides per host ...
                # server1
                Host server1 serverONE # multiple names okay (CASE-SENSITIVE)
                    HostName 192.168.1.333
                    User vee
                    Port 4567
                    IdentityFile ~/.ssh/server1 # private-key reference okay
                # server2 
                Host server2 two 
                    HostName rhel.foo
                    User bar
                    IdentityFile ~/backups/.ssh/id_dsa.some-admin-key
                    # Prevent adding this host to Known Hosts file
                    UserKnownHostsFile /dev/null

                # defaults; for ALL Hosts; PLACE LAST
                Host *
                    GSSAPIAuthentication no  # used @ Kerberos; leave it 'no'
                    ## For password prompt @ `ssh ... 'sudo ANY ...'
                    RequestTTY yes # no|yes|force|auto
                    ForwardAgent no # Default 
                    ForwardX11 no
                    ForwardX11Trusted yes # Default per distro
                    Port 22
                    Protocol 2
                    ServerAliveInterval 60
                    ServerAliveCountMax 30
                    # quietly PREVENTS PASSWORD QUERY
                    PreferredAuthentications publickey 

        # IDENTITY FILE (client) holding identity (key-files); 
        # unused/untested; does it override '~/.ssh/config' ???
            ~/.ssh/identity # okay if NOTHING but 'IdentityFile' entries 
                    
    # AUTHENTICATION; KEY-BASED [passwordless] 
        
        # keys @ CLIENT [local machine]; public AND private keys of client (ssh user) 
            ~/.ssh/id_rsa      # private key; "IDENTITY"; can protect with passphrase
            ~/.ssh/id_rsa.pub  # public key    
            # (Re)set ssh-REQUIRED PERMs
            chmod 700 ~/.ssh
            chmod 600 ~/.ssh/* 
        # client RETRIEVE/SAVE PUBLIC KEY from a private key 
            ssh-keygen -y -f ~/.ssh/${private_keyname} > ~/.ssh/${private_keyname}.pub
        # client CREATEs key-pair; in "OpenSSH RSA format"
            ssh-keygen  # default stores @ ~/.ssh/
            # E.g., 
                ssh-keygen -t rsa -C "$(id -un)@GitHub" 
                ssh-keygen -t ed25519 -a 100
                ssh-keygen -t rsa -b 4096 -o -a 100

            # OPTIONs
            -a rounds  # the number of KDF (key deriv. func.) rounds used
            -t ecdsa   # type; rsa (default), dsa, ecdsa, ed25519, rsa1 
            -C         # comment
            -l         # show FINGERPRINT 
            -P         # passphrase; optional
            -o         # save private keys using the new OpenSSH format instead of PEM;
                        # PEM is more compatible but less secure    

            # passphrase reset; on existing key
            ssh-keygen -p -P 'old phrase' -N 'new phrase' -f privateKEYFILE 
            ssh-keygen -p    # per prompts.

            # comment reset; on existing key
            ssh-keygen -c -P 'pass phrase' -C 'new comment' -f privateKEYFILE
            ssh-keygen -c    # per prompts.

            # show fingerprints of KNOWN HOSTS; to validate host on 1st connect
            -lf ~/.ssh/known_hosts     # fingerprint hash
            -lBf ~/.ssh/known_hosts    # readable blather
            -lvf ~/.ssh/known_hosts    # randomart image 
            # (both keys of a pair have IDENTICAL FINGERPRINTS)

        # SEND public key to host [remote ssh server]
            ssh-copy-id -i PUB_KEY_ID_FILE -p PORT_NUMBER USER@HOST.DOMAIN 
                # options, else defaults per ssh config 
                -p PORT_NUMBER
                -i PUB_KEY_ID_FILE 
            # sends/inserts it into host file ...    
            ~/.ssh/authorized_keys
            # ... @ ssh server (host) 
            # wherefrom hosts store/get public keys of clients, for authentication     

                # manually add new pub key ...
                cat id_rsa.pub >> ~/.ssh/authorized_keys
                chmod 600 ~/.ssh/authorized_keys    

        ssh-agent  # PASSPHRASE cache/auto-entry
            # Automate pass phrase entry ...    
            ssh-agent /bin/bash  # launch ssh-agent into subshell    
            ssh-add              # prompts for pass phrase; caches it until (sub)shell exited    
            # ... OR ...
            # as background process @ current shell 
                eval "$(ssh-agent -s)"
                    # load private key into it; login
                    ssh-add "$HOME/.ssh/$_private_key"
                    # then login/connect
                    ssh user@host.domain 
                    # kill all running ssh-agent processes; they don't die w/ mintty
                    ps |grep 'ssh-agent' |awk '{print $1;}' |xargs kill 2> /dev/null

        # SSH Certificates : https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/deployment_guide/sec-using_openssh_certificate_authentication#sec-Introduction_to_SSH_Certificates
            # OpenSSH certificates contain a public key, identity information, and validity constraints. 
            # They are signed with a standard SSH public key using the ssh-keygen utility. 
            # Format: /usr/share/doc/openssh-version/PROTOCOL.certkeys.
            ssh-keygen # supports two types of certificates: user and host. 
                # - User certificates authenticate users to servers
                # - Host certificates authenticate server hosts to users. 
                # For certificates to be used for user or host authentication, 
                # sshd must be configured to trust the CA public key. 

                # Create CA Certificate SIGNING KEY
                    algo=ed25519
                    # Key to sign USER certs
                        ca_user_key=~/.ssh/$(id -un)_${algo}_key
                        ssh-keygen -t $algo -f $ca_user_key                                 # Private key
                        ssh-keygen -s $ca_user_key -I $(id -un) -f $ca_user_key.pub         # Public key
                    # Key to sign HOST certs
                        ca_host_key=~/.ssh/$(hostname)_${algo}_key
                        ssh-keygen -t $algo -f $ca_host_key                                 # Private key
                        ssh-keygen -s $ca_host_key -I $(hostname) -h -f $ca_host_key.pub    # Public key
                            -s ca_key # Sign (certify) a public key using the specified CA key.
                            -I # Certificate identity (host or user name, depanding on type of cert)
                            -h # When signing a key, create host cert instead of user cert.

                        # Host keys (private-public pairs) are generated by default:
                            ls -l /etc/ssh/ssh_host*

                # Create the CA server's own host certificate
                    ca_cert=/etc/ssh/ssh_host_rsa.pub
                    start=1w
                    end=54w5d
                    cipher=aes256-ctr # `ssh -Q cipher` 
                    ssh-keygen -s $ca_host_key -I $(hostname) -V -$start:+$end -Z $cipher -z $(date +%s) -h -f $ca_cert

                # To authenticate users' certificate, hosts must be configured to trust 
                # the CA's public key ($ca_user_key.pub) that was used to sign that certificates.
                    # 1. Hosts must have CA's public key: Push to:
                        /etc/ssh/$ca_user_key.pub # At all target hosts.
                    # 2. Hosts' sshd must be configured:
                        vi /etc/ssh/sshd_config
                            TrustedUserCAKeys /etc/ssh/ca_user_key.pub
                            Ciphers aes256-gcm@openssh.com, aes256-ctr
                        systemctl restart sshd
                # To avoid the warning about an unknown host, users' systems must trust 
                # the CA's public key ($ca_host_key.pub) that was used to sign the HOST certificate.

        # SSH Tunnel : Local Forwarding
            # Establish a local port (localhost:PORT) as a PROXY for a remote (IP:PORT) box
            # USE CASE: 
            #     local access to/from an otherwise inaccessible remote 
            #     through an intermediary (jump box) that has access to the remote.
            # https://en.wikibooks.org/wiki/OpenSSH%2FCookbook%2FProxies_and_Jump_Hosts

            key_local=~/.ssh/swarm-aws.pem # public key sent, yet private key referenced
            ip_jump=18.206.203.255 # SSH server
            ip_pvt=10.0.1.71 # at remote (target) host

            # @ -L : Local-port forwarding 
            # Establish a tunnel from localhost (2222) to pvt pox thru jump box (3333)
                -L    # Local forwarding (answer locally); multiple (hops) okay (comma delimited)
                -f    # fork process to background
                -N    # no commands sent once the tunnel is up
                -T    # disable pseudo-tty allocation
                -vvvE # Log all connection details to file; `... -vvvE /tmp/ssh_session_log`

            # Local clients access pvt box ($ip_jump:22) locally at http://localhost:2222
                ssh -fNTL 2222:$ip_pvt:22 ${user}@$ip_jump 
            # Local clients access pub want.com:443 locally at http://localhost:4444
                ssh -fNTL 4444:want.com:443 user@jump.domain 
                # /etc/hosts or C:\Windows\System32\drivers\etc\hosts
                127.0.0.1 want.com
                # Solutions to Virtual Hosting problem, where request fails 
                # because Host header is localhost, not want.com
                    # Option 1: Set Host header manually
                    curl -H "Host: want.com" http://localhost:4444
                    # Option 2: Use --resolve to fake DNS
                    curl --resolve want.com:4444:127.0.0.1 http://want.com:4444
                    # Option 3: Add to /etc/hosts
                    echo "127.0.0.1 want.com" >> /etc/hosts
                    # Now use: http://want.com:4444
                    # Option 4: Use -L flag to follow redirects
                    curl -L -H "Host: want.com" http://localhost:4444

            # @ ProxyCommand (ssh -W) : all KEYS are LOCAL (pvt key NOT UPLOADED to jump box)
                # per ProxyCommand : all KEYS are LOCAL
                -A      # Enables forwarding of the authentication agent connection.
                ssh -o ProxyCommand="ssh -i $key_local -A -W %h:%p $user@$ip_jump" \
                    $user@$ip_pvt -i $key_local

            # @ ProxyJump (-J) : Jump Host 
                # https://en.wikibooks.org/wiki/OpenSSH%2FCookbook%2FProxies_and_Jump_Hosts
                ssh -J $user@$ip_jump $user@$ip_pvt
                #... does not work with -i ...; must configure per ~/.ssh/config

                # Per config; multiple jump hosts, per CSV list; hosts visited in order listed. 
                Host pvt
                        HostName ip.pvt.com
                        ProxyJump jump@ip.jump.com:22,...
                        User target

            # @ -tt (tty allocation) : nesting ssh commands (OLDEST METHOD)
                key_jump=/home/ubuntu/.ssh/swarm-aws.pem  # Key to pvt UPLOADED to JUMP BOX

                ssh -tt $user@$ip_jump -i $key_local \
                    ssh -tt $user@$ip_pvt -i $key_jump
        
        # SSH Tunnel : Remote Forwarding
            # Provide access to any local host from (remote) SSH host 
            # (and from others per GatewayPorts setting at sshd_config)
            # Forward port (8080) on remote machine to local machine (80), initiating from local machine.
            # https://www.ssh.com/academy/ssh/tunneling-example
            -R # Remote forwarding (answer remotely)
            ssh -R 8080:$local_host:80 $ssh_host 
            ssh -fNTR 8080:$local_host:80 $ssh_host 
            # local_host may be localhost or any local service name or local IP 
            # If local service name, DNS resolver may be local (/etc/hosts).
            # Remote user makes requests to: localhost:8080 regardless
            ssh -f -N -R <REMOTE_FORWARD_PORT>:<DB_HOSTNAME_OR_IP>:<DB_PORT> <SSH_USER>@<SSH_HOST> -g -i <PATH_TO_PRIVATE_KEY> -o ServerAliveInterval=30 -o ServerAliveCountMax=1 -o ExitOnForwardFailure=yes
            # @ sshd_config: Allow access from remotes other than SSH host
                GatewayPorts # no|yes|clientspecified
            
            $ip=152.144.1.12 # GatewayPorts clientspecified
            # Allow connections to port 8080 (at public.foo.com) only from $ip
            ssh -R $ip:8080:localhost:80 public.foo.com 

            # SSH Session : appearing to initiate from SSH host machine
            ssh -R 2222:localhost:22 $user@$ssh_host 
            ssh -p 2222 username@localhost

            # Connect INACCESSIBLE LOCAL port (8088) to an ACCESSIBLE REMOTE port (2222)
            ssh -p 2222 -R 80:localhost:8088 user@host2.domain
            #... access host2.domain:80 locally @ http://localhost:8088

        # SOCKS[5] : local proxy server in SSH tunnel (dynamic port-forwarding) to remote host.
            # SSH acts as a SOCKS5 server at a local port (-D) to *dynamically* route 
            # (local) traffic of *any* TCP/UDP *protocol* to (exiting at) remote host (gateway), 
            # which opens apropos connnection to destinations/ports based on those requests, 
            # all without predefined port-forwarding rules for each service.
            #
            # Each ssh client (CLI) node runs its SOCKS server (as background process; -f), 
            # yet firewall rules etal are centralized; 
            # configured on the target (bastion/gateway) host.
            # 
            # Common use case is a local node having no web access, or restricted web access, 
            # but has SSH access to a remote node (gateway) that has (better) web access.
            #
            # Must configure each app to use the SOCKS proxy. (See "APPLICATIONS ..." below.)
            # Ref: https://wiki.archlinux.org/index.php/OpenSSH#Encrypted_SOCKS_tunnel
            # IANA SOCKS5 port is 1080, but use whatever.
                ssh -CfND 1080 $user@$host #... tunnel from localhost:1080 to remote host
                # Options:
                    -D [$local_bind_addr:]$port # Dynamic APPLICATION-LEVEL port forwarding; 
                        # Create local SOCKS5 server listening on local $port (1025-65536).
                        # The APPLICATION PROTOCOL determines the *destination* IP:PORT .
                        # SECURITY regarding optional local_bind_addr :
                        #   DO NOT bind to 0.0.0.0 (all interfaces), 
                        #   else is available to EVERY machine on the LAN/Wi-Fi/VPN/... .
                        #   Use 127.0.0.1 (default) AKA localhost, 
                        #   else that of another (private/local-only) network interface.
                    -f  # fork process to background (optional).
                    -N  # No commands; not interactive once tunnel is up (optional).
                    -C  # compress all data (optional).

                # So (local) client apps use the local entry point, localhost:1080,
                # but (remote) destination hosts see request Origin as that of $host (gateway).
                # Unlike VPNs, the proxy is not visible to destination hosts.
                # 
                # More detailed description ...
                # https://en.wikibooks.org/wiki/OpenSSH%2FCookbook%2FProxies_and_Jump_Hosts#SOCKS_Proxy
                #
            
            # REVERSE SOCKS (-R) : Reverse port forward to an *existing* SOCKS server  

                # Forwarding a remote TO your *existing* SOCKS proxy server
                    # You have a SOCKS proxy already running locally at 1080
                    # (created earlier with -D, or by some other tool)
                    # Run this locally to expose your SOCKS proxy to the remote machine:
                    ssh -CfNR 1080:localhost:5555 $user@$remote
                    # Result: Remote listens on 5555, which is mapped to your 127.0.0.1:1080
                    #   remote:5555  →  tunnel  →  your-machine:1080 (SOCKS server)
                    #
                    #... AVOID; This relay pattern adds a second trust boundary 
                    #    and doubles crypto cost without any benefit.
                    #    Use only if no SSH outbound at client.

            # USE CASEs

                # Gateway : Local apps use local proxy at localhost:1080 
                          # to access destination servers via remote gateway.
                    ssh -i /path/to/gateway/key.pem \
                        -o ServerAliveInterval=15 \
                        -o ServerAliveCountMax=3 \
                        -o ExitOnForwardFailure=yes \
                        -o StrictHostKeyChecking=yes \
                        -o UserKnownHostsFile=/dev/null \
                        -o LogLevel=VERBOSE \
                        -CfN -D 1080 \
                        $user@$gateway 2> ~/.ssh/socks.log
                        #... local SOCKS proxy server is listening on 127.0.0.1:1080
                    
                        # Local apps make requests via proxy:
                            curl --socks5 localhost:1080 http://example.com
                            # Else
                            export http_proxy='socks5h://127.0.0.1:1080'
                            curl -s http://$web_domain     
                            export https_proxy='socks5h://127.0.0.1:1080'
                            curl -s https://$web_domain  

                        # autossh for resiliency : reconnnect on fail
                        autossh -M 0 -i /path/to/key.pem $opts -CfN -D 1080 user@gateway_ip

                        # Rate limit using iptables
                        iptables -A INPUT -p tcp --dport 1080 -m connlimit --connlimit-above 50 -j REJECT

                        # Or, as a systemd service
                        # /etc/systemd/system/socks5-gateway.service
                        [Unit]
                        Description=SOCKS5 Gateway Proxy
                        After=network.target

                        [Service]
                        Type=simple
                        User=proxyuser
                        ExecStart=/usr/bin/ssh ...# Add the full statement here
                        Restart=always
                        RestartSec=10
                        LimitNOFILE=65535

                        [Install]
                        WantedBy=multi-user.target
    
                # Bridge to Jump Box : LAN/Wi-Fi clients use proxy: $bridge:1080 
                    # to access jump box having access to internet gateway
                    # Create SOCKS on the bridge host
                    bridge=192.168.1.100 # LAN address bound to an interface
                    ssh $opts -CfND "$bridge:1080" $user@$jump
                    # Else
                    ssh $opts -CfND "0.0.0.0:1080" $user@$jump
                    # Now all other machines on the network can use:
                    curl --socks5 $bridge:1080 http://example.com
                    # WiFi Client (192.168.1.50) 
                    #     ↓
                    # Bridge Machine (192.168.1.100) [runs SSH with -D 192.168.1.100:1080]
                    #     ↓
                    # Jump Box (10.0.0.10)
                    #
                    # Additional opts : handle multiple concurrent sessions
                    opts='-o ControlMaster=auto -o ControlPath=~/.ssh/sockets/socks-%r@%h-%p -o ControlPersist=600'
                    
                # Proxy through multiple hops : Your PC → jump1 → jump2 → internet
                    ssh -J user@jump1 -D 1080 user@jump2
                    # SOCKS server: localhost:1080 (YOUR PC)
                    # Traffic: localhost:1080 → jump1 → jump2 → internet
                    # (Neither jump1 nor jump2 have a SOCKS server)

            # Harden
                # Method 1. Restrict to Specific Local User
                    # Create dedicated proxy group and user
                    sudo groupadd -r proxyuser  # -r creates system group (GID < 1000)
                    # Create user and assign to group
                    sudo useradd -m -s /bin/false -g proxyuser proxyuser
                    # Run SSH as proxyuser
                    sudo -u proxyuser ssh -CfN -D 1080 user@gateway_ip
                    # Use filesystem permissions
                    sudo chown proxyuser:proxyuser /path/to/key.pem
                    sudo chmod 600 /path/to/key.pem

                # Method 2. Firewall Local Access
                    # Restrict localhost:1080 to specific users via iptables
                    iptables -A OUTPUT -o lo -p tcp --dport 1080 -m owner --uid-owner proxyuser -j ACCEPT
                    iptables -A OUTPUT -o lo -p tcp --dport 1080 -j DROP

                # Method 3. SELinux/AppArmor Policies
                    # SELinux policy to restrict proxy access
                    # Only proxyuser can connect to port 1080
                    semanage port -a -t ssh_port_t -p tcp 1080
                    # Create policy module for proxyuser

                # Method 4. Use Unix Socket Instead of TCP
                    # Create Unix socket proxy (safer than TCP)
                    socat UNIX-LISTEN:/tmp/proxy.sock,fork SOCKS5:localhost:1080
                    # Now only processes with filesystem access can use it
                    curl --socks5 /tmp/proxy.sock http://example.com

                # Method 5. Isolate with ControlMaster
                    # Create isolated proxy session
                    ssh -i /path/to/gateway/key.pem \
                        -o ServerAliveInterval=15 \
                        -o ServerAliveCountMax=3 \
                        -o ExitOnForwardFailure=yes \
                        -o StrictHostKeyChecking=yes \
                        -o UserKnownHostsFile=/dev/null \
                        -o LogLevel=VERBOSE \
                        -o ControlMaster=auto \
                        -o ControlPath=~/.ssh/sockets/proxy-%r.sock \
                        -CfND 1080 \
                        user@gateway_ip
                        #... Only processes that can access ControlPath file can use it

            # APPLICATIONS MUST BE CONFIGURED to use SOCKS proxy server, e.g., 
                # Firefox > Options > Advanced > Network > Settings 
                # > "Manual proxy config" > "SOCKS Host:" > `localhost`, port
                # https://www.digitalocean.com/community/tutorials/how-to-route-web-traffic-securely-without-a-vpn-using-a-socks-tunnel

                # http_proxy (Linux env var) : normally set to configure HTTP(S)
                    export http_proxy=http://$_SERVER:$_PORT/
                    export http_proxy=http://$_USERNAME:$_PASSWORD@$_SERVER:$_PORT/

                # Example
                    # From pvt box having NO WEB ACCESS (subnet deny comms to/from anywhere outside VPC), 
                    # Create SOCKS tunnel to jump box (that has web access), which acts as proxy for pvt box:
                    user='ubuntu'
                    ip_jump_pvt='10.0.101.194' # Private IP of jump box
                    key_jump=/home/ubuntu/.ssh/cluster-aws.pem 

                    # Web accessible from pvt box at 127.0.0.1:1080
                    ssh -i $jump_key -CfND 1080 ${user}@$jump
                    
                    # Validate the tunnel is up
                    ps aux |grep ssh

                    export http_proxy='socks5h://127.0.0.1:5522'
                    curl -sI http://$web_domain     # HTTP/1.1 200 OK ...
                    export https_proxy='socks5h://127.0.0.1:5522'
                    curl -skI https://$web_domain   # HTTP/1.1 200 OK ...

                    # Configure the host (all apps abiding those params) to use SOCKS

                        # Declare proxy params : current shell (cofigures OS and some utilities @ this shell)
                        export port='1080'
                        export forward=127.0.0.1:$port
                        export http_proxy=socks5h://$forward
                        export https_proxy=socks5h://$forward
                        #... socks5h is 'SOCKS5 with remote DNS resolution' (@ man apt-transport-http)

                        # Declare proxy params : all shells (persistent) (idempotently append to config)
                        conf='/etc/profile'
                        [[ -f $conf ]] || sudo touch $conf
                        [[ "$(cat /etc/profile |grep 'http_proxy')" ]] || {
                            echo "export http_proxy=socks5h://$forward" |
                                sudo tee -a $conf
                        }
                        [[ "$(cat /etc/profile |grep 'https_proxy')" ]] || {
                            echo "export https_proxy=socks5h://$forward" |
                                sudo tee -a $conf
                        }

                        # Declare proxy params : apt-get application (idempotently append to config)
                        conf='/etc/apt/apt.conf.d/proxy.conf'
                        [[ -f $conf ]] || sudo touch $conf
                        [[ "$(cat $conf |grep "socks5h://$forward/")" ]] || {
                            echo "Acquire::https::Proxy \"socks5h://$forward/\";" |
                                sudo tee -a $conf
                            echo "Acquire::http::Proxy \"socks5h://$forward/\";" |
                                sudo tee -a $conf
                        } 
                        #... apt-get reads neither http_proxy nor https_proxy

                        # Declare proxy params : docker.service.d (idempotently append to config)
                        conf='/etc/systemd/system/docker.service.d/http-proxy.conf'
                        [[ -f $conf ]] || { 
                            sudo mkdir -p '/etc/systemd/system/docker.service.d'
                            sudo touch $conf 
                        }
                        [[ "$(cat $conf |grep '[Service]')" ]] || {
                            echo "[Service]" |sudo tee -a $conf
                        }
                        [[ "$(cat $conf |grep "socks5://$forward/")" ]] || {
                            echo "Environment=\"HTTP_PROXY=socks5://$forward/\"" |sudo tee -a $conf
                            export docker_reconfig_flag=1
                        }

                    # Test : SUCCESS
                    curl -I http://google.com
                    curl -I https://google.com

                    # Test : SUCCESS
                    sudo apt-get update 

                    kill -15 $_PID || kill -9 $_PID
                    #... terminate the tunnel; does not survive the session, regarldess


        # SSH-based VPN 
            # TUN device: A virtual network device for point-to-point IP tunneling.
            # Establishing an Ad Hoc VPN (so needn't configure per application)
            # by bridging two gateway nodes per TUN device at each (TUNs have their own IP).
            # https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Proxies_and_Jump_Hosts#Passing_Through_a_Gateway_with_an_Ad_Hoc_VPN
            # SSH-BASED VIRTUAL PRIVATE NETWORKS (@ ssh man page)
                # ssh contains support for Virtual Private Network (VPN) tunnelling
                # using the tun(4) network pseudo-device, allowing two networks to be
                # joined securely.  The sshd_config(5) configuration option
                # PermitTunnel controls whether the server supports this, and at what
                # level (layer 2 or 3 traffic).

                # The following example would connect client network 10.0.50.0/24 with
                # remote network 10.0.99.0/24 using a point-to-point connection from
                # 10.1.1.1 to 10.1.1.2, provided that the SSH server running on the
                # gateway to the remote network, at 192.168.1.15, allows it.

            Server subnet                                    Client subnet

                           +----10.0.99.1       10.0.50.1----+
                           +    10.0.99.2 ===== 10.0.50.2    +
                           |                                 |
            10.0.99.0/24 --+                                 +--- 10.0.50.0/24

            TUN_0=10.1.1.1
            TUN_1=10.1.1.2

            # - Bridge IPs are referenced only by their CIDRs
            # - TUN IPs are orthogonal to targets'

            # @ client (gateway machine):

                ssh -f -w 0:1 192.168.1.15 true # Private IP of subnet's gateway? Hangs
                ifconfig tun0 $TUN_0 $TUN_1 netmask 255.255.255.252
                route add 10.0.99.0/24 $TUN_1

            # @ server (gateway machine):

                ifconfig tun1 $TUN_1 $TUN_0 netmask 255.255.255.252
                route add 10.0.50.0/24 $TUN_0

            # @ ip ??? 
            ip tuntap add dev tun0 mod tun #... but how to set its params as with ifconfig

        badvpn # +TUN device 
            # https://wiki.archlinux.org/index.php/VPN_over_SSH#Set_up_badvpn_and_tunnel_interface
            #... a more involved setup, but any/all apps can use.

        # X11 Forwarding  https://wiki.archlinux.org/index.php/OpenSSH#X11_forwarding
            # a mechanism that allows graphical interfaces of X11 programs running on a remote system 
            # to be displayed on a local client machine. The remote host does not need to have a full X11 
            # system installed, however it needs at least to have xauth installed; 
            # a utility that maintains Xauthority configs for X11 client/server authentication 

    # SSH SERVER (sshd)

        # INSTALL/START/STOP @ RHEL (see also 'REF.Network.RHEL.sh')    
                yum install openssh-server
                systemctl enable sshd.service  # works sans '.service'
                systemctl start  sshd.service 

                # DEBUG; shows LOG of ACTIVITY; sshd 'Authentication'
                systemctl status sshd     

        # SELinux / sshd FIX
        sudo semanage fcontext -a -t NetworkManager_etc_rw_t authorized_keys
        restorecon -v authorized_keys
        ausearch -c sshd --raw | audit2allow -M my-sshd
        semodule -i my-sshd.pp

        # SERVERs PUBLIC-PRIVATE KEY pairs
        /etc/ssh
        # upon contact, server sends its public key, e.g., ... 
        /etc/ssh/ssh_host_rsa_key.pub  # per server config; e.g., may be ecdsa key instead
        # Fingerprint (is shown to client, for server validation, on 1st connect)
        ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub

        # @ router; AC66U [Merlin]; private or public ??
        /tmp/etc/dropbear/                            
            dropbear_rsa_host_key
            dropbear_ecdsa_host_key

        # CONFIG sshd SERVER
         /etc/ssh/sshd_config  # modify this to change sshd config

        # SYSTEM-WIDE 
            /etc/ssh/sshd_config  # SERVER config
            /etc/ssh/ssh_config   # CLIENT config
        # user-wide; overrides system-wide 
            ~/.ssh/config
        # sshd [daemon] config [e.g., modify listening/connect port here]
            /etc/ssh/sshd_config

            # MODIFY sshd (server) CONFIG     
                /etc/ssh/sshd_config
            # https://wiki.centos.org/HowTos/Network/SecuringSSH
                AllowUsers uzer1 uzer2       # specify; overrules `PermitRootLogin yes`    
                Protocol 2                   # forbid legacy protocol
                Port 22                      # change to, e.g., 5177; SELinux must allow (See below)
                ListenAddress 0.0.0.0        # listens to everything; change to specific 
                PubkeyAuthentication yes
                AuthorizedKeysFile .ssh/authorized_keys
                PasswordAuthentication yes   # REQUIRED @ ssh client setup; send key per `ssh-copy-id ...`
                GSSAPIAuthentication no      # used only by Kerberos; turn off to speed up auth otherwise 
                SyslogFacility AUTHPRIV      # okay
                X11Forwarding yes            # less secure
                TCPKeepAlive yes             # prevent termination on inactive session    
                ClientAliveInterval 60       # seconds per
                ClientAliveCountMax 3        # so 3 minutes to AUTO-KILL idle connection
                ## Fast + FIPS 140-2 (2024) ciphers : Set these at /etc/ssh/sshd_config
                Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr
                # Additional recommended settings for security (2024)
                KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
                MACs hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

            # Restart sshd daemon after changes
                systemctl restart sshd   # restart after changes 
                systemctl status sshd    # validate changes; SELinux may not allow, e.g., port change    

            # if PORT CHANGE, SELinux requires notification; allow/add ssh @ specified port
                semanage port -a -t ssh_port_t -p tcp $SSH_PORT_NUMBER

                # ALLOW @ FIREWALL too ...
                firewall-cmd --add-port $SSH_PORT_NUMBER/tcp --permanent
                # change rule(s)
                iptables -A INPUT -p tcp -s $_CLIENT_IP_ADDR --dport 22 -j ACCEPT
                # else, per limiting attacks
                iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name ssh --rsource
                iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent ! --rcheck --seconds 60 --hitcount 4 --name ssh --rsource -j ACCEPT

                # Reference
                man semanage       # shows `semanage port` 
                man semanage port  # shows example "Allow sshd to ..."

            # Debugging (connection issues)
                # check perms + owner + group + SELinux security context
                ls -ZA ~/.ssh  # should be ...
                -rw-------. uZer uZer unconfined_u:object_r:ssh_home_t:s0 authorized_keys

                # check SSH server status report
                systemctl status sshd -l           # show full report
                # check auth logs
                grep AVC /var/log/{secure,audit.log}  
                
                    # log settings per 
                    /etc/rsyslog.conf    # rsyslog: The rocket-fast system for log processing    
                    man rsyslog.conf(8)  # rsyslogd(8) logs system messages; specifies rules for logging. 

                # Test if SELinux issue:
                setenforce 0  # ... turn off SELinux (temporarily)    

                # E.g., SOLVEd (connection) issues (almost always about folder/file permissions) 
                # @ connecting to RHEL 7; auth degenerates down to password access
                    # @ client ...
                        $ ssh linux -vv  # try logon; verbose report
                        ...
                        debug1: Offering RSA public key: ... KEY_PATH ...
                        ...
                        debug3: receive packet: type 51
                        debug1: Authentications that can continue: publickey,password
                        debug2: we did not send a packet, disable method  # <== WHY ???
                        debug1: Next authentication method: password
                        ... password:

                     # @ host (server) ...
                        $ systemctl status sshd -l
                            Apr 23...sshd[7244]: Authentication refused: bad ownership or modes for directory /home/uZer 
                            
                        # Show perms + SELinux SECURITY CONTEXT; LABELs per USER:ROLE:TYPE 
                        $ ls -ZA ~/.ssh  
                        -rw-rw----. uZer uZer unconfined_u:object_r:ssh_home_t:s0 authorized_keys
                        # So, WRONG PERMs (660); SELinux okay
                        chmod 600 ~/.ssh/authorized_keys  # ... SOLVED IT ! 
                
