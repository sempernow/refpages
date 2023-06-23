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
#   SERVER: remote machine; host; but has per-client config too. 

# CLIENT services :   (client;you)    <==>    sshd (server)

    # SSH : TL;DR

        # Launch a login shell through an SSH tunnel
        ssh -i $_PRIVATE_KEY_PATH ${user}@${hostname_OR_ip}
            ## Note @ Git servers (GitHub/GitLab), $user is 'git', NOT that account's username. E.g., 
            ssh -T -i $keypath git@gitlab.com # -T for SSH tunnel only; sans shell/terminal (TTY/PTY).

        # Generate elliptical key pair : default type (sans -t) is 'rsa'.
        ssh-keygen -t ed25519 -C $email_addr -f ~/.ssh/keyname 
        #... If RSA type, use at least `-b 2048` (bit length) option; OpenSSL default.

            # Re(Set) key's passphrase (local security)
            ssh-keygen -p -P $old -P $new -f $keypath
            
            # Re(Set) key's comment 
            ssh-keygen -c -C $email_addr -f $keypath

            # Show fingerprint of any key (public/private have same fingerprint)
            ssh-keygen [-E md5] -l[v] -f $keypath # -v : show visual in addition to the hash.

        # Show fingerprint of (remote) host(s) : VALIDATE against remote's claim ON FIRST CONNECT
        ssh-keygen [-E md5] -l[v] -f ~/.ssh/known_hosts   # -v : show visual in addition to the hash.

        # Push user's PUBLIC key to remote by referencing PRIVATE key a.k.a. "identity file" (-i)
        ssh-copy-id -i $_PRIVATE_KEY_PATH -p $_PORT_NUMBER ${user}@${hostname_OR_ip}
        #... requires the remote already has an existing key or allows password auth.

        # Remotely run LOCAL script and args (environment) through a secure shell
        ssh ... "/bin/bash -s" < /a/local/path/script.sh $arg1 $arg2
        #... with partial preprocessing (escapes required in script)
        ssh ... "/bin/bash -c '$(</a/local/path/script.sh)' _ $arg1 $arg2"
        #... advantage over HEREDOC scheme is preservation of semantic highlighting @ code editor.

        # UPLOAD a FILE sans scp, rsync, ... or any other utility.
        # Read local (SSH client) file into string and write it to a remote (SSH host) file
        ssh ... "printf '$(</from/this/local/FILE)' > /to/this/remote/FILE"

    # SCP : Secure Copy  https://en.wikipedia.org/wiki/Secure_copy
        scp # Secure Copy per ssh(1)
            -C      # Compress during transfer
            -i      # ssh identity file
            -o      # ssh(1) options
            -p      # Preserve mtime 
            -q      # Quiet; sans progress
            -r      # Recursive copy; else ignores all files under any directory
            -T      # Disable strict filename checking; mitigate per-distro quirks in file-handling conventions

        scp -i $keypath ...

        # E.g., {PUSH,PULL} the {local(1),remote(2)} SOURCE directory content to TARGET: 
        scp -Cpr -i ~/.ssh/key2 SOURCE  user2@host2:TARGET  # PUSH : local source, remote target
        scp -Cpr -i ~/.ssh/key1 user1@host1:SOURCE  TARGET  # PULL : remote source, local target
        # Where ~/.ssh/key{2,1} is the private key of user{2,1} at host{2,1} during {PUSH,PULL} 
        
        scp -p $source user@host:$target   # push FILE 
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

        # OWNER/PERMISSIONS REQUIRED by SSH (ssh, sshd), so set thus @ ALL MACHINEs:
        chmod 700 /home/uZer  # YES, $HOME too; DO NOT use RHELs notion of 770 
        chmod 700 ~/.ssh
        find ~/.ssh -type f -exec chmod 600 {} \;

        # @ Windows OS, ACLs set to 'Full' access; SIDs "%USERNAME%" + 'SYSTEM'.
        # I.e., @ $HOME dir, remove 'Inherited' perms, and all other SIDs,
        # and apply changes to '... all child objects ...'.
        # (Okay to include 'Administrators' SID too.)

    # KNOWN HOSTS [list known-hosts fingerprints]; 
    # queries/adds-to on 1st connect 
    ~/.ssh/known_hosts

    # AUTHORIZED KEYS (@ remote/host) file; contains PUBLIC keys of clients;    
        ~/.ssh/authorized_keys 
        # OR
        ~/etc/.ssh/authorized_keys 
         # @ router; AC66U [Merlin]
        /tmp/home/root/.ssh/authorized_keys 

            # Push PUBLIC key to remote by referencing PRIVATE key "identity file" (-i)
            ssh-copy-id -i PRIVATE_KEY_ID_FILE -p PORT_NUMBER USER@HOST.DOMAIN 
            #... only if remote already has client's key, or password login is available, 
            # else must use some out-of-band process to insert key into remote's authorized_keys file.

    # FINGERPRINT (fpr)
        # E.g., Validate ALL Host fingerprints; list/verify fpr per 'known_hosts';
        # Use on FIRST CONNECT, comparing it to that shown from host @ first connect 
            ssh-keygen [-E md5] -lvf ~/.ssh/known_hosts    # shows ALL and a visual; -lf sans visual
            # Default hash AKA "Encryption" (-E) shown is SHA256 (Website GUI often show MD5 instead)
        # E.g., Show fingerprint of a key, in the old MD5 format (GitHub uses that)
            ssh-keygen [-E md5] -lf ~/.ssh/github_rsa.pub    
        # NOTE: public and private keys (of a pair) have the SAME fpr.

        # @ Host : SSHFP Record (Secure Shell fingerprint record )
        # https://en.wikipedia.org/wiki/SSHFP_record ; use on FIRST CONNECT
            ssh-keygen -r HOST # prints in ' ZONE FILE FORMAT' ... 
            <Name> [<TTL>] [<Class>] SSHFP <Algorithm> <Type> <Fingerprint>

    # CONNECT/login [local client to remote server]

        # BYOC (Bring your own creds)
        ssh -i ${_PRIVATE_KEY} ${user}@${hostname_OR_ip} #... e.g., ...
        ssh -i ~/.docker/machine/machines/${_VM}/id_rsa ubuntu@kvpairs.com
        #... If `-i ...` is ommitted, then ALL KEYS @ ~/.ssh/ are tried,
        #    unless $user@$host matches a configuration @ ~/.ssh/config .

        # @ public key @ ~/.ssh/config
        ssh ${user}@${hostname_OR_ip}
        # OR
        ssh -l $user ${hostname_OR_ip}
        # OR, if `Host ...` @ `~/.ssh/config` 
        ssh xMachine
        # Host xMachine
        #   HostName centos
        #   User rbox
        #   CheckHostIP yes
        #   IdentityFile ~/.ssh/centosvm_ed25519

        # most commmon connection ISSUES are due to FILE OWNER/PERMISSIONS
        # on private key or folder (see CLIENT section), or  USERNAME@HOST spelling
            'Permission denied (publickey).' # See PERMISSIONS section

        # options; overrides those of default config 
            -i PRIVATE_KEY_FILE # identity file; defaults: ~/.ssh/id_rsa @ ssh-v.2
            -v[v[v[v]]]         # Verbosity (level)
            -F CONFIG_FILE      # use specified config file instead of defaults.
            
            -G  # print configuration (per host) and exit; no connection made

            -X  # Enables X11 forwarding; override ssh config `ForwardX11 no`
            -Y  # Enables trusted X11 forwarding; bypass X11 SECURITY ext controls
            
            # pseudo-tty allocation (shell access) 
            -t  # force pseudo-terminal (TTY/PTY) allocation; 
                #... may solve: 'TERM ... variable not set' warning[s]
            -T  # Disable TTY/PTY allocation (Git servers disable shell access) 
                
            # Port forwarding [see man pages for more]    
            -L local_socket:host:hostport    # local (client) port forwarded to remote.
            -R remote_socket:host:hostport   # remote (server) port forwarded to local. 
            -p PORT_NUMBER user@host.domain  # remote port for this connection    
            # https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding    

            # Port forwarding MULTIPLE PORTS 

                    # ... then can ...
                        ssh localhost -p 8822  # connects to REMOTE_IP_FOO
                        ssh localhost -p 9922  # connects to REMOTE_IP_BAR 

        # Automate passphrase entry (private key may be protected by passphrase; see ssh-keygen.)
        ssh-agent /bin/bash  # launch ssh-agent into subshell    
        ssh-add              # prompts for pass phrase; caches for lifetime of (sub)shell.

        # ADD host's key to ~/.ssh/known_hosts file 
            # Get the host key
            ssh-keyscan -t rsa $_HOST_IP
                #=> 
                # THE_HOST_IP:22 SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3
                # THE_HOST_IP ssh-rsa AAA...ppf
                #... Copy that entire string: "THE_HOST_IP:22 SSH-..." 
                #    to our known_hosts file (here at the machine we're calling from): 
                ~/.ssh/known_hosts #... append it.

        # REMOVE an "offending" key
        ssh-keygen -f ~/.ssh/known_hosts -R $_OFFENDING_IP_ADDR
        #... this occurs, e.g., when re-attaching EIP to a new instance (AWS EC2); 
        # public key of old instance is retained in the client's known_hosts file.

        # Establish socket for CONNECTION SHARING, so can terminate (non-terminal GitHub) session.
            ssh -f -N -M -S ~/.ssh/sockets/%r@%h-%p -L local_socket:host:hostport ID_hostName
            # Close it:
            ssh -S ~/.ssh/sockets/%r@%h-%p -O exit ID_hostName
            
            -f  # go to background just before command execution; implies (includes) -n ().
            -N  # Do not execute a remote command; useful for forwarding ports.
            -L  # local_socket:host:hostport
            -n  # Redirects STDIN to /dev/null; MUST BE USED if ssh is run as background process
            -M  # “master” mode for connection sharing.
            -S  # ControlPath; SOCKET for connection sharing; 'none' to disable sharing

            # set config 
            ssh -o ControlPath=~/.ssh/sockets/%r@%h-%p
            # OR @ ~/.ssh/config 
            ControlMaster auto
            ControlPath    ~/.ssh/sockets/%r@%h-%p
            ControlPersist 600
            # https://www.tecmint.com/speed-up-ssh-connections-in-linux/
            # https://www.cyberciti.biz/faq/linux-unix-reuse-openssh-connection/

            # Then, once configured per ~/.ssh/config, ...
            ssh github          # logon
            ssh -O exit github  # terminate

        # TCP Forwarding  https://blog.fatedier.com/2015/07/22/ssh-port-forwarding/
        ssh -oPort=22 -CNfg -R 40000:localhost:22 root@11.11.11.11

        # RUN SCRIPT per redirect 
        ssh user@host /bin/bash -s < "script" arg1 arg2 
        # RUN SCRIPT in background process
        ssh -n -f user@host "/bin/bash -c 'cd /whereever; nohup ./whatever > /dev/null 2>&1 &'"

    # CONFIG CLIENT MACHINE

    # KNOWN HOSTS; ssh process validates server on first connect to ensure it's not a fake 
    # on 1st connect, ssh [client-process] asks user to approve "...unknown...". 
        # If answer 'yes', then ssh client saves
        #+ host [server] pub key FINGERPRINT to ...
        ~/etc/.ssh/known_hosts # fingerprints [approve per ssh logon] 

        ssh-keyscan  # is a utility for GATHERING the PUBLIC ssh HOST KEYS of a number of hosts; to aid in building and verifying ssh_known_hosts files; VERY FAST; client does NOT need login access to the machines that are being scanned, nor does the scanning process involve any encryption.
        -H       # Hash all hostnames and addresses; protects host?
        -t TYPE  # dsa, ecdsa, ed25519, rsa
        -f FILE  # Read hosts or “addrlist namelist” pairs from file, one per line.

        # Create key pair
            ssh-keygen -t ed25519 -C "user1@host1.domain"
            #... prompts for target location 
            #    with default being: ~/.ssh/id_ed25519  (and ~/.ssh/id_ed25519.pub)
            #... prompts for passphrase (host keys cannot have a passphrase)
            #    ssh-agent auto-handles passphrases
            # The associated entry for such @ ~/.ssh/config would be ...
                Host host1 
                HostName host1.domain
                User user1
                RequestTTY no
                IdentityFile ~/.ssh/id_ed25519
                #... so do not use default name; name per 'host_ed25519' or some such.
                # Bypass prompt

        # E.g., to ADD host to `known_hosts` file: 
            ssh-keyscan -H github.com >> ~/.ssh/known_hosts


        # CONFIG system-wide [@ client machine]
        /etc/ssh/ssh_config 

        # CONFIG per user [@ client machine]
            # overrides system-wide; `config` overrides `ssh_config`
            #  allows for different keys per host [server]
            ~/.ssh/config # more general than identity file 

                # overrides per host ...
                # server1
                Host server1 serverONE # multiple names [CASE-SENSITIVE] okay
                    HostName 192.168.1.333
                    User vee
                    Port 4567
                    IdentityFile ~/.ssh/id_dsa.private1 # private key
                # server2 
                Host server2 two 
                    HostName RHELmachine.foobar.com
                    User zerbar
                    IdentityFile ~/backups/.ssh/id_dsa.some-admin-key
                    # Prevent adding this host to Known Hosts file
                    UserKnownHostsFile /dev/null

                # defaults; for ALL Hosts; PLACE LAST
                Host *
                    GSSAPIAuthentication no  # used @ Kerberos; leave it 'no'
                ForwardAgent no
                ForwardX11 no
                ForwardX11Trusted yes
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
                # (re)set PERMs [REQUIRED by ssh]
                chmod 700 ~/.ssh
                chmod 600 ~/.ssh/* 
            # client RETRIEVE/SAVE PUBLIC KEY from the private key 
                ssh-keygen -y -f ~/.ssh/${private_keyname} > ~/.ssh/${private_keyname}.pub
            # client CREATEs key-pair; in "OpenSSH RSA format"
                ssh-keygen  # stores @ ~/.ssh/
                # E.g., 
                    ssh-keygen -t rsa -C "GitHub"        # used `-t rsa` for GitHub keygen
                    ssh-keygen -t ed25519 -a 100         # very secure but not widely adopted
                    ssh-keygen -t rsa -b 4096 -o -a 100  # rsa is very widely used 
                    # Best Practices [2015]  https://stribika.github.io/2015/01/04/secure-secure-shell.html 

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

            # SELinux Contexts 
            restorecon -Rv ~/.ssh 

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
                ps | grep 'ssh-agent' | awk '{print $1;}' | xargs kill 2> /dev/null

        # DEBUG ... increasing verbosity [1-3x 'v']
            ssh -v[vv] user@host.domain 2> ssh.log # info @ connet AND disconnect    
            ssh -v[vv] user@host.domain -E ssh.log # info @ connet AND disconnect    
            
            # NOTE: this references the line BELOW it ...
                debug1: key_load_public: No such file or directory
            
        # view authentication log msgs ...
            /var/log/auth.log

        # MONITOR ssh connections (tunnels)
            lsof -i -n | grep ssh       # open files; internet-related (-i) 
            netstat -tulpen | grep ssh  # connections per host:port and process 

        # PREVENT QUERY on first connect (useful @ scripts)
            ssh -o StrictHostKeyChecking=no ...
        # CONNECT TIMEOUT
            ssh -o ConnectTimeout=5 -o ...

        # SSH TUNNELING a.k.a. PORT FORWARDING 
            # Establish a local port (localhost:PORT) as a PROXY for a remote (IP:PORT) box
            # USE CASE: 
            #     local access to/from an otherwise inaccessible remote 
            #     through an intermediary (jump box) that has access to the remote.
            # https://en.wikibooks.org/wiki/OpenSSH%2FCookbook%2FProxies_and_Jump_Hosts

            key_local=~/.ssh/swarm-aws.pem            # Key to jump box kept locally
            ip_jump=18.206.203.255
            ip_pvt=10.0.1.71

            # @ -L : Local-port forwarding : all KEYS are LOCAL (pvt key NOT UPLOADED to jump box)
                # Establish a tunnel from localhost (2222) to pvt pox thru jump box
                    -L    # Local address to forward to remote; multiple (hops) okay (comma delimited)
                    -f    # fork process to background
                    -N    # no commands sent once the tunnel is up
                    -vvvE # Log all connection details to file; `... -vvvE /tmp/ssh_session_log`

                ssh -f -N ${user}@$ip_jump -L 2222:$ip_pvt:3333
                # Rewritten ...
                ssh -fNL 2222:$ip_pvt:3333 ${user}@$ip_jump 
                #... access pvt box from local shell @ http://localhost:2222
                ssh -fNL 4444:want.com:80 user@jump.domain 
                #... access want.com from local shell @ http://localhost:4444

                # remote (less common) : connect INACCESSIBLE LOCAL port to an ACCESSIBLE REMOTE port 
                ssh -p 2022 -R 80:localhost:8088 user@host2.domain

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

        # SOCKS[5] proxy server [@ local/client] per SSH tunnel [port-forwarding]   
            # SSH acts as a SOCKS5 server.
            # USE CASE: Local node has no web access, or restricted web access, 
            # but has access to a remote node that has (better) web access.
            # Configure (OS/App) PER APPLICATION https://wiki.archlinux.org/index.php/OpenSSH#Encrypted_SOCKS_tunnel
                ssh -D 5555 -fNqTCv $user@$host #... tunnel from localhost:5555 to remote host
                    -D  # Dynamic port forwarding (to remote); specify the local port (1025-65536).
                    -f  # fork process to background
                    -N  # disable interactive prompt; no commands sent once tunnel is up.
                    -q  # quiet mode
                    -T  # disable pseudo-tty allocation
                    -C  # compress data before sending
                    -v  # verbose (optionally)
                #... (local) client apps use the local entry point; localhost:5555

            # More detailed description ...
            # https://en.wikibooks.org/wiki/OpenSSH%2FCookbook%2FProxies_and_Jump_Hosts#SOCKS_Proxy
                # Verify up
                ps aux | grep ssh 

                -D [bind_address:]port  # Dynamic APPLICATION-LEVEL port forwarding (1025-65536); 
                # allocates a socket to listen to local port; 
                # subsequent connections to this port are forwarded over the secure channel; 
                # the APPLICATION PROTOCOL determines where to connect to at the remote machine;
                # `bind_address` of `localhost` indicates that the listening port be bound for local use only, 
                # while an empty address or `*` indicates that the port should be available from all interfaces.

                # APPLICATIONS MUST BE CONFIGURED to use SOCKS proxy server, e.g., 
                    # Firefox > Options > Advanced > Network > Settings 
                    # > "Manual proxy config" > "SOCKS Host:" > `localhost`, port
                    # https://www.digitalocean.com/community/tutorials/how-to-route-web-traffic-securely-without-a-vpn-using-a-socks-tunnel

                    # http_proxy : set to configure HTTP(S) (Linux env var)
                    export http_proxy=http://$_SERVER:$_PORT/
                    export http_proxy=http://$_USERNAME:$_PASSWORD@$_SERVER:$_PORT/

                    # TEST : SUCCESS 
                        # From pvt box having NO WEB ACCESS (subnet allows no comms to/from anywhere outside VPC), 
                        # establish jump box (that has web access) as SOCKS server, to proxy for the pvt box:
                        user='ubuntu'
                        #ip_jump='34.203.218.222'
                        ip_jump_pvt='10.0.101.194' #... since we can't get to jump's public IP.
                        key_jump=/home/ubuntu/.ssh/swarm-aws.pem 

                        # Establish jump box as web proxy (server), accessible from 127.0.0.1:5128
                        ssh -D 5128 -f -C -q -N ${user}@$ip_jump_pvt -i $key_jump # 3128 is IANA proxy; 5128 no IANA
                        
                        # Validate the tunnel is up
                        ps aux | grep ssh

                            # Declare proxy params : current shell (cofigures OS and some utilities @ this shell)
                            export port='5128'
                            export forward=127.0.0.1:$port
                            export http_proxy=socks5h://$forward
                            export https_proxy=socks5h://$forward
                            #... socks5h is 'SOCKS5 with remote DNS resolution' (@ man apt-transport-http)

                            # Declare proxy params : all shells (persistent) (idempotently append to config)
                            conf='/etc/profile'
                            [[ -f $conf ]] || sudo touch $conf
                            [[ "$(cat /etc/profile |grep 'http_proxy')" ]] || {
                                echo "export http_proxy=socks5h://$forward" \
                                    |sudo tee -a $conf
                            }
                            [[ "$(cat /etc/profile |grep 'https_proxy')" ]] || {
                                echo "export https_proxy=socks5h://$forward" \
                                    |sudo tee -a $conf
                            }

                            # Declare proxy params : apt-get application (idempotently append to config)
                            conf='/etc/apt/apt.conf.d/proxy.conf'
                            [[ -f $conf ]] || sudo touch $conf
                            [[ "$(cat $conf |grep "socks5h://$forward/")" ]] || {
                                echo "Acquire::https::Proxy \"socks5h://$forward/\";" \
                                    |sudo tee -a $conf
                                echo "Acquire::http::Proxy \"socks5h://$forward/\";" \
                                    |sudo tee -a $conf
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

                        kill -9 $_PID 
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
                
