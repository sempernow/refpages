exit
# NETWORK DEVICEs
    # AKA Connection AKA Link AKA Interface AKA Adapter AKA NIC (Network Interface Card)
    # Naming schemes:
        #  1. Udev naming; eth<X>; CLASSICAL naming
        #  2. Logical naming; .{VLAN} and :{ALIAS}
        #  3. BIOS (AKA Physical) naming; based on HW properties
        #       - Embedded: em3;  em{1-N}
        #       - PCI:      p6p1; p{SLOT#}p{PORT#};
        #
        # Predictable Network Interface Names
        #  systemd/udev automatically assigns predictable, stable NIC names.
        #  https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
        #  https://github.com/systemd/systemd/blob/master/src/udev/udev-builtin-net_id.c#L20
        # e.g., eth0 => enp1s0 : en=Ethernet, p1=PCI-bus1, s0=slot-0

# CIDR blocks
    # -----[ Private IP Address Ranges : RFC-1918 ]---------
    # CIDR block      Class    Start         End
    # --------------  -----    -----------   ---------------
    # 0.0.0.0/8        A       0.0.0.0       0.0.0.255         This Network
    # 127.0.0.0/8      A       127.0.0.0     127.255.255.255   Loopback
    # 10.0.0.0/8       A       10.0.0.0      10.255.255.255    Private Use
    # 172.16.0.0/12    B       172.16.0.0    172.31.255.255    Private Use
    # 192.168.0.0/16   C       192.168.0.0   192.168.255.255   Private Use
    # 169.254.0.0/16   C       169.254.0.0   169.254.255.255   Link Local (APIPA)
    # 224.0.0.0/4      D       224.0.0.0     239.255.255.255   Multicast

    # APIPA (Automatic Private IP Addressing) address CIDR : 169.254.0.0/16
        # A networking feature of MS Windows and others allowing devices
        # to *automatically assign themselves* an IP address in that range
        # whenever unable to obtain one from a DHCP server.
        # This ensures that devices can still communicate within a local network
        # even if the DHCP server is down or misconfigured. Hence "Link Local".

# KERNEL
    # RUNTIME config : Params declared (by drop-in file(s)) here are LOADED AT RUNTIME
        /etc/systctl.conf   # For configuring kernel parameters.
        /etc/sysctl.d       # Dir for drop-in files, which override params declared above.
            # Convention is to name drop-in file (*.conf) by its app/purpose, e.g., kubernetes.conf
            # Contains "<param> = <val>" list : Example entry:
                # net.bridge.bridge-nf-call-iptables = 1

    # ON BOOT config : Module params declared (by drop-in file(s)) here are LOADED ON BOOT
        /etc/modules-load.d # For specifying kernel modules to load.
            # LOADED BY systemd-modules-load.service ON BOOT.
            # Contains "<name_of_module>" list : Example entry:
                # dm_mod

    sysctl  # Configure kernel's RUNTIME parameters : See /proc/sys/
        # GET : Read ephemeral-ports Range @ OS
            sysctl net.ipv4.ip_local_port_range
            # Else
            cat /proc/sys/net/ipv4/ip_local_port_range #=> 32768   60999

        # SET : Ephemerally (now); does NOT survive reboot
            sudo sysctl -w net.bridge.bridge-nf-call-iptables=1

        # SET : Persistently : Create drop-in file under /etc/sysctl.d
            # >>>  PRESERVE TABs of HEREDOC  <<<
			cat <<-EOF |sudo tee /etc/sysctl.d/kubernetes.conf
			net.bridge.bridge-nf-call-iptables  = 1
			net.bridge.bridge-nf-call-ip6tables = 1
			net.ipv4.ip_forward                 = 1
			EOF

        # APPLY changes NOW (REGARDLESS) sans reboot
            sudo sysctl --system

    modinfo  # name, filename, descr, author, license, file
        modinfo $name

    modprobe  # Ephemerally ADD/REMOVE kernel modules (now)
        # E.g., br_netfilter ip_vs, ip_vs_rr, ip_vs_wrr, ip_vs_sh, overlay
        modprobe $name                  # Add module ($name) else okay
        modprobe -r $name               # Remove module ($name) else okay
        modprobe ... --first-time $name # Fail if action (add/remove) would be redundant.
        modprobe -c |grep $name         # Shows iff CHANGED (since last boot) : Do NOT use this.
        lsmod |grep $name               # Shows if LOADED : See lsmod (below) : Use this.

        # ADD : Load kernel modules ON BOOT
        ok(){
            conf='/etc/modules-load.d/kubernetes.conf'
            [[ $(cat $conf 2>/dev/null |grep 'overlay') ]] && return 0
            # >>>  PRESERVE TABs of HEREDOC  <<<
			cat <<-EOH |sudo tee $conf
			br_netfilter
			ip_vs
			ip_vs_rr
			ip_vs_wrr
			ip_vs_sh
			overlay
			EOH
            # Confirm file
            [[ $(cat $conf 2>/dev/null |grep 'overlay') ]] || return 1
        }
        ok || exit $?

    lsmod   # Show status of kernel modules : Prints list : Module, Size, Used by
        lsmod |grep $name  # Shows if module ($name) LOADED
        #... This is *the* reliable method of verifying a module is loaded.

        # ADD (ephemerally) unless already loaded (idempotent)
        sudo modprobe br_netfilter # Okay if already loaded
        [[ $(lsmod |grep br_netfilter) ]] || echo FAILED-to-load

    # APPLY changes sans reboot
        sudo sysctl --system

# AUTHENTICATION/AUTHORIZATION (Identity/Access)
    # NIS (Network Information Service)  https://en.wikipedia.org/wiki/Network_Information_Service
        # YP (Yellow Pages); precursor to NIS
        # An NIS/YP system maintains and distributes a central directory of user and group information,
        # hostnames, e-mail aliases and other text-based tables of information in a computer network.
        # Password File  https://en.wikipedia.org/wiki/Passwd#Password_file
            /etc/passwd  # jsmith:x:1001:1000:Joe Smith,Room 1007,(234)555-8910,(234)555-0044,email:/home/jsmith:/bin/sh
        # Shadow File    https://en.wikipedia.org/wiki/Passwd#Shadow_file
            /etc/shadow  # Shadow File; authentication hashes; the "x" of /etc/passwd

    # Federated Auth schemes, e.g., Active Directory (AD)
        # Integrate into Linux using : Samba, Winbind, SSSD, or RealmD
        # @ https://chat.openai.com/share/73401243-5ea0-4cdc-9090-d6dd709ada10

    # LDAP (Lightweight Directory Access Protocol)
        # https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol
        # Successor to NIS/YP
        # Based on DAP (X.500 protocol)
        # DSA (Directory System Agent) is LDAP Server
        # DNS (Domain Name Service) is in effect the LDAP for WANs

            # See REF.Network.LDAP.*

# CLIENT

    # BENCHMARKING
        # @ Windows
            Wireshark # https://www.wireshark.org/

        # TRAFFIC MONITORING
            iftop       # Bandwidth/speed per connection
            nload       # Graph inbound/outbound traffic
            nethogs     # Like iftop, but sorts by process/application and usage
            bmon        # bandwidth utilization; running-rate estimate
            vnstat      # Lightweight kernel-level monitor
            iperf       # Per protocol monitoring : See below
            netperf     # Benchmarks between two hosts on a network
                        # TCP, SCTP, DLPI, UDP using UNIX sockets; predefined tests
                        # https://github.com/HewlettPackard/netperf
            iptraf      # Ncurses-based monitoring tool
            cbm         # Color Bandwidth Meter (graph)

        # Latency benchmarks of Unix IPC mechanisms
            ipc-bench

            iperf # TCP/UDP benchmarking
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
                # Containerized:
                    # https://hub.docker.com/r/networkstatic/iperf3

                iperf3 -s                   # Server on system 1
                iperf3 -c $server_address   # Client on system 2
                    --reverse   # Server to client; default is client to server
                    -t 30       # Seconds; default is 10
                    -p 8888     # Client/Server ports must match; default is 5201
                    -P 4        # Parallel connections

                    iperf3 -s
                    # -----------------------------------------------------------
                    # Server listening on 5201
                    # -----------------------------------------------------------
                    # Accepted connection from 192.168.11.101, port 52474
                    # [  5] local 192.168.11.103 port 5201 connected to 192.168.11.101 port 52484
                    # ...
                    # [ ID] Interval           Transfer     Bitrate
                    # [  5]   0.00-10.04  sec  20.5 GBytes  17.6 Gbits/sec                  receiver

                    iperf3 -c 192.168.11.103
                    # Connecting to host 192.168.11.103, port 5201
                    # [  5] local 192.168.11.101 port 52484 connected to 192.168.11.103 port 5201
                    # ...
                    # - - - - - - - - - - - - - - - - - - - - - - - - -
                    # [ ID] Interval           Transfer     Bitrate         Retr
                    # [  5]   0.00-10.00  sec  20.5 GBytes  17.6 Gbits/sec    0             sender
                    # [  5]   0.00-10.04  sec  20.5 GBytes  17.6 Gbits/sec                  receiver

        # HTTP

            wrk # HTTP benchmarking tool  https://github.com/wg/wrk
                # Install from source:
                    git clone https://github.com/wg/wrk.git
                    cd wrk
                    make # Requires: gcc package
                    sudo install wrk /usr/local/bin/

                wrk -t12 -c400 -d30s http://127.0.0.1:8080/index.html
                    -c, --connections  # number of HTTP connections to keep open
                                       # N = connections/threads
                    -d, --duration:    # duration of test, e.g. 2s, 2m, 2h
                    -t, --threads:     # number of threads to use
                    -s, --script:      # LuaJIT script, see SCRIPTING
                    -H, --header:      # HTTP header to add to request wrk"
                        --latency:     # print detailed latency statistics
                        --timeout:     # record max timeout @ no response thereunder

            hey # ApacheBench replacement (Golang)  https://github.com/rakyll/hey
                # Load test an API endpoint
                # Reports include LATENCIES; distributions, percentiles, ...
                # To install, download binary, `cp` to /bin/hey, then `chmod +x /bin/hey`.
                hey -m GET -c 10 -n 10000 "http://localhost:3000/v1/u"

            ab  # ApacheBench : HTTP benchmarking : apache2-utils
                # Load test an API endpoint
                ab -c $concurrently -n $iterations "$url"
                # E.g.,
                ab -c 100 -n 10000 http://${host}/

                # If "socket: Too many open files (24)" @, e.g., `... -c 2000`
                # then increase MAX open FDs:
                    ulimit -n 10000  # 1024 is default

            # pprof @ Golang  https://golang.org/pkg/net/http/pprof/
                go pprof ...

            # Vegeta @ GitHub  https://github.com/tsenart/vegeta
                # HTTP load testing tool (CLI) and library.
                # Usage example:  https://medium.com/dm03514-tech-blog/sre-performance-analysis-tuning-methodology-using-a-simple-http-webserver-in-go-d475460f27ca

    # cURL is a tool to transfer data between client (itself) and server
        curl [options] URL         # Okay to omit protocol

            SSL_CERT_FILE=FILE     # Alternative to host OS' CA trust store; FILE is CA certificate.
            -k, --insecure         # Skip TLS certificate verification
            --ca-native            # Use OS-native CA trust store to verify TLS cert of "peer" (in TLS context)
            --cacert FILE          # Path to CA cert or FILE containing bundle of CA certs
            --capath DIR           # Path to DIR of CA cert(s) 
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
            -f, --fail             # Fail (silently) if HTTP resp not 2nn; otherwise exits 0 on any resp.
            -o, --output FILE      # write body to FILE; one per url
            -O URL                 # write body to file of URL BASENAME
            -L, --location         # follow redirects; intelligently handle server response codes
            --create-dirs          # used w/ `-o`; creates local dirs as necessary
            -T, --upload-file FILE # upload FILE; create FILE [@ server-root] if not exist
            --connect-timeout SECS # max time to connect
            -m, --max-time SECS    # max time allowed for transfer [req|resp]; timeout
            -A UA, --user-agent UA # send `User-Agent` header
            -s, --silent           # silences progress meter & err msgs
            -sS, --show-error      # Show error, otherwise silent.
            -u, --user USER:PASS   # credentials; username & password
            -x, --proxy [PROTOCOL://]HOST[:PORT]  # to use specified proxy
            -v, --verbose          # Verbose report
            -v --trace-time        # Prepend each line with current time (usec resolution)
            -v --trace FILE --trace-time # Write trace/time to FILE
            -w, --write-out @FILE  # FORMAT output per txt FILE

        # TLS : 
            # Linux
                # Requires CA cert(s) in PEM format
                --cacert=/path/to/the-signing-root-ca.crt
                --cacert=/path/to/bundle/file/ca.bundle
                --capath=/dir/containing/the-signing-root-ca.crt
                export SSL_CERT_FILE=/path/to/ca.bundle  # Used by many apps
                export CURL_CA_BUNDLE=/path/to/ca.bundle # Takes precedence
                # Install internet's CA bundle
                    # Debian/Ubuntu
                    sudo apt update && sudo apt install -y ca-certificates
                    # RHEL/CentOS/Fedora
                    sudo dnf install -y ca-certificates
                # Add custom CA certificate(s) : file(s) MUST HAVE EXTENSION .crt
                    # Ubuntu  
                    custom=/usr/local/share/ca-certificates/ # Debian/Ubuntu custom certs dir
                    custom=/etc/pki/ca-trust/source/whitelist/  # RHEL
                    sudo mkdir -p $custom
                    sudo cp $ca_cert $custom/any-root-ca.crt
                    # Install it : Creates link to /etc/ssl/certs/
                    sudo update-ca-certificates # Should report something like "... add 1 ..."
                    sudo update-ca-trust # FAILing to update
                    # Updates both (but doesn't)
                    # /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
                    # /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
            # Windows
                --cacert C:\path\to\cacert.pem
                setx CURL_CA_BUNDLE C:\path\to\cacert.pem
                # PowerShell
                [System.Environment]::SetEnvironmentVariable("CURL_CA_BUNDLE", "C:\path\to\cacert.pem", "User")
                # mmc.exe
                # Certificates > Computer Account > Local Computer
                # > Trusted Root Certification Authorities.
                # > Import

        # Print connect-timing info (only) to STDOUT:
            # >>>  PRESERVE TABs of HEREDOC  <<<
            file=curl-time-format.txt
			cat <<-EOH |tee $file
			   time_namelookup:  %{time_namelookup}s\n
			      time_connect:  %{time_connect}s\n
			   time_appconnect:  %{time_appconnect}s\n
			  time_pretransfer:  %{time_pretransfer}s\n
			     time_redirect:  %{time_redirect}s\n
			time_starttransfer:  %{time_starttransfer}s\n
			                     ----------\n
			        time_total:  %{time_total}s\n
			EOH
            curl -s -w "@$file" -o /dev/null $url

        # Response Headers only, lest error, to STDOUT:
            curl -sSLIX GET $url                                # GET  method
            curl -D - -sSLo /dev/null $url                      # Alt, any method
            curl -sSLX POST -d '{..}' -D - -o /dev/null $url    # POST method
            curl -sSLI $url                                     # HEAD method
            ##... Simplest, but too many protected endpoints respond to HEAD requests
            ##    with 405 Method Not Allowed, or worse (misleading: 403 Forbidden).

        # Pull a script to ./a.sh quietly; follow redirects; rpt only if error.
            curl -fsSLO https://foo.com/path/to/a.sh

        # Pull a script to /here/b.sh quietly; follow redirects; rpt only if error.
            curl -fsSL -o /here/b.sh https://foo.com/path/to/a.sh

        # Pull +extract an archive to PWD
            curl -sSL https://${host}/path/foo.tar.gz | tar -zxf -
            curl -sSL https://${host}/path/foo.tar.gz | tar -zx    # Equivalent

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
            curl ${host}/endpoint -d 'foo bar'           # POST
            # ... per explicit Request Method
            curl -X PUT ${host}/endpoint -d 'foo bar'    # PUT

        # Generate LOAD; create demand on server
            seq 10000 |xargs -Iz curl -4 '${host}/index.html'
            # or
            while [ true ]; do curl -4 '${host}/index.html' ; done

        # CORS Test
            curl -I -X GET -H "Origin: http://wants.it" --verbose \
                'http://host.has/resource'

        # Header info only
            curl -Is foo.com

        # Validate URL (test server); send request for URL ...
            curl -I http://google.com/bogus  # HTTP 404 (Not Found)

        # POST (HTTP method)
            curl -X POST http://${host} -d title=foo -d date=1421044443 \
                -d body='beep boop!'
            # JSON (Sans whitespace!)
            export json='{"k1":["a1","a2"],"k2":"v2","k3":[{"foo":"bar","q":123},{"id":"a1","ping":"pong"}]}'
            curl -X POST -H 'Content-Type: application/json' \
                -d "$json" http://${host}/v1/api

        # PUT (HTTP method) : CREATE [UPLOAD] FILE (file.txt), IF NOT EXIST @ server-root
            curl -X PUT -d ' Hello from server @ ${host}' http://${host}/file.txt
            # Validate action
                curl http://${host}/file.txt  # 'Hello from server @ ${host}'

        # DELETE (HTTP method) : delete FILE (file.txt), @ server-root
            curl -X DELETE http://${host}/file.txt
            # Validate action
                curl http://${host}/file.txt  # 'File not found'

        # CRUD @ API; JSON server (JWT-authenticated endpoints); + jq filtering
            # List products
            curl -X GET -s \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer ${token}" \
                http://${host}:${port}/v1/products | jq .

            # CREATE new product (POST); filter API return to retreive its ID
            json='{"name":"Foo bar","cost":100,"quantity":3}'
            id="$(curl -X POST -s \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer ${token}" \
                -d "${json}" http://${host}:${port}/v1/products \
                | jq -r .id)"

            # RETRIEVE product (created just now) per ID
            curl -X GET -s \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer ${token}" \
                http://${host}:${port}/v1/products/${id} | jq .

            # UPDATE existing product (PUT); sans one key
            json='{"name":"FooBar v2","quantity":555}'
            curl -X PUT -s \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer ${token}" \
                -d "${json}" http://${host}:${port}/v1/products/${id}

            # DELETE existing product
            curl -X DELETE -s \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer ${token}" \
                http://${host}:${port}/v1/products/${id} | jq .


    # wget : The non-interactive network downloader.
        wget [options] URL

            -S, --server-response   # print HTTP response headers to STDOUT (before downloading all else)
            --spider                # Validate URL : Exit code non-zero lest resource exist
            --no-check-certificate  # Sans TLS validation
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
            -nv                     # not verbose (no progress % report)

        # Validate endpoint/resource and print only the response-code line (lines on redirect)
            wget -Sq --spider $url 2>&1 |grep HTTP
        # Download and execute a shell script (COMMON, INSECURE, and DANGEROUS)
            wget -O - $_bash_script_url |sh
        # Download binary directly into its install location
            wget -O $destination $url
        # Download server response body to FILE @ $PWD; report meta @ STDERR
            wget [-nv] $url # Silently: -nv
            # IF compressed ...
                file index.html  # get file info : "index.html: gzip compressed data, from Unix"
                mv index.html index.html.gz  # move (rename) to 'index.html.gz'
                gunzip index.html.gz         # uncompress to 'index.html'

        # Download a Web page +ALL REQUISITES (css, js, images), posing as specified User-Agent.
        # NOPE -- FAILS -- NEARLY NEVER WORKS
            wget -mpkE -U $ua $url  # mirror, page-requisites, convert-links, adjust-extension
            # UA @ Android 4
                'Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30'
            # UA @ Win7 Mozilla
                'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:58.0) Gecko/20100101 Firefox/58.0'
            # UA list https://developers.whatismybrowser.com/useragents/explore/operating_system_name/android/
        # print filtered server-response headers (only) to STDOUT
            wget -S --spider $url |& grep 'Last-Modified'

        # Download a website; an ENTIRE WEBSITE
            export _ua='Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:58.0) Gecko/20100101 Firefox/58.0'
            wget -U $ua --recursive --convert-links $url

            # OR
            export domain=foo.com; export _url=foo.com/bar
            wget \
                --recursive \
                --no-clobber \
                --page-requisites \
                --html-extension \
                --convert-links \
                --restrict-file-names=windows \
                --domains $domain \
                --no-parent \
                $url

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

# DNS
    # host : IP <==> domainname
        host -t a HOSTNAME|IP     # IP (per authoritative query)
        host -C HOSTNAME|IP       # Nameserver(s); SOA records
        host -d HOSTNAME|IP       # verbose

    whois HOSTNAME # regsitry ID, registrar, registrar server, update/creation/expiration dates

    nslookup
        nslookup HOSTNAME|FQDN              # returns IP Address
        nslookup -type=CNAME HOSTNAME|FQDN  # returns IP and canonincal name (Apex record to which CNAME point)
        nslookup IP                         # returns FQDN aka "Domain Name"
        
            # @ OCI Container
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

    getent ahostsv4 HOSTNAME  # IPv4
    getent hosts HOSTNAME     # IPv6

    dnsdomainname        # show LAN domain

    # NetworkManager CLI : See REF.Network.firewalld
        nmcli device show $dev # eth0, ens192, ...
        #... use to configure NIC
        nmcli conn show $dev |grep ipv4.dns

# CONNECTIVITY

    # PING
        ping -c1 $ip  # CONNECTIVITY TEST 1 ping
        ping -f $ip   # FLOOD ping; BANDWIDTH TEST : Use at LAN only!

        # Scan subnet for hosts : /24
            seq 254 |xargs -n1 /bin/bash -c '
                netaddr=192.168.11
                ping -c 1 $netaddr.$1 >/dev/null
                [ $? -eq 0 ] && echo "$netaddr.$1 is UP" || :
            ' _

            arp-scan # ARP scanner
                dev=ens192;cidr=192.168.28.0/24
                sudo arp-scan --interface=$dev $cidr
                sudo arp-scan $cidr

# NETWORKs / SUBNETs

    traceroute -n -T -p $port $ip # TCP
    sudo traceroute -I $ip # Use ICMP instead

    mtr # My Traceroute : combine traceroute + ping
        # https://en.wikipedia.org/wiki/MTR_(software)
        mtr -n -T -c 200 $ip --report # Per TCP (vs default; ICMP)
        #... neither are pre-installed @ `Ubuntu 18.04`

    nc # Netcat : Read/Write data across TCP/UDP connections.
        # Attempt TCP connection
        nc $host $port # `nc -u ...` for UDP
        # SCAN for a specific OPEN PORT by NUMBER quickly
        nc -zvw 1 $ip_or_domain $port_number
        # PORT RANGE is NOT RELIABLE (false negatives are typical)
        nc -zvw 1 $ip_or_domain $port_range # Don't use, e.g., nc ... 1-1000
        # SCAN a PORT RANGE quickly and RELIABLY:
        seq ${pSTART:-1} ${pSTOP:-1000} \
            |xargs -IX nc -zvw 1 $ip_or_domain X 2>&1 >/dev/null \
            |grep Connected

        # Get version info of target's OpenSSH server
        echo 'EXIT' |nc $ip 22

        # # @ Windows CMD
        # netstat -aon | findstr :%_port%

        ####################
        # See MORE nc below
        ####################

    arp-scan # ARP scanner
        dev=ens192;cidr=192.168.28.0/24
        sudo arp-scan --interface=$dev $cidr
        sudo arp-scan $cidr

    nmap # Network Mapper : Security Scanner : Port Scanner
        # Advanced tool regarding remote services availability
        # Features: Host discovery, Port scanning, Version detection, OS detection
        # WARNINGs:
        # - nmap used on targets external to your VPC is FORBIDDEN by cloud vendors etal
        # - May FAIL SILENTLY if run sans sudo; reports false negative(s)
        # https://en.wikipedia.org/wiki/Nmap
        sudo nmap HOST                       # Regular scan
        sudo nmap -sn CIDR                   # Ping scan : Discover nodes on subnet, e.g., 192.168.0.0/24
        sudo nmap -T4 -F HOST                # Quick scan
        sudo nmap -sn --traceroute HOST      # Quick traceroute
        sudo nmap -T4 -A -v HOST             # Intense scan
        sudo nmap -p 1-65535 -T4 -A -v HOST  # Intense scan, all TCP ports
        # Slow comprehensive scan
        sudo nmap -sS -sU -T4 -A -v -PE -PP -PS80,443 -PA3389 -PU40125 -PY -g 53 --script "default or (discovery and safe)" HOST

        # Get CIDR binding device
            dev=eth0 # eth0 or ens192
            cidr=$(ip -4 -brief addr show $dev |awk '{print $3}')

    nm-tool  # RedHat; NetworkManager Tool; reports status
             # ... Type, driver, speed, IP, MAC, Gateway IP, DNS, Subnet Netmask

    ipcalc  # Get network address, CIDR, mask,... all the things
        ipcalc -pnmb --minaddr --maxaddr --geoinfo --addrspace 193.92.150.0/27

    mii-tool     # media-independent interface [MII] status [OBSOLETE; use ethtool]
    ethtool NIC  # get info on NIC, e.g., 'ethtool eth0'
            -i NIC   # driver info

    # Get bandwidth of a network interface
    lshw -class network |grep -A 10 eth0 |grep size # size: 10Gbit/s

    ss # Socket Statistics; IP:PORT; like netstat
        -r     # resolve names
        -n     # numeric; don't resolve names
        -p     # incl. processes
        -at4r  # all-sockets, tcp, IPv4, resolve-names

        # Display all TCP sockets with process SELinux security contexts.
            ss -t -a -Z
        # Display all UDP sockets.
            ss -u -a
        # Display all established ssh connections.
            ss -o state established '( dport = :ssh or sport = :ssh )'
        # Check for listener on port 9418 (git daemon)
            ss -ltnp |grep 9148

    netstat # Print network connections, routing tables, interface stats, ...
        netstat -i       # Interface Table; packet info for network cards
        netstat -tulpen  # Active TCP and UDP connections; servers (listening ports)
        netstat -4tlpn   # Active TCP connections of IPv4; servers (listening ports)
        netstat -nr      # IP Routing Table; numeric [IP] instead of HOSTNAME
        netstat -a       # Active UNIX domain sockets; list all network ports
        netstat -at      # Active Internet Connections; list all TCP ports
        netstat -s       # Stats, per protocol, for all ports

    lsof # List Open Files : lsof(8) man page : https://linux.die.net/man/8/lsof
        lsof -U                 # List info of all UNIX socks
        lsof /tmp/demo.sock     # Info on this socket only

        # List all OPEN PORTs : All LISTENING PORTs
        sudo lsof -i -n -P |grep LISTEN
        # Is port 22 open?
        sudo lsof -i:22

    nc # Netcat : Read/Write data across TCP/UDP connections.
        # ncat-nmap pkg
        # READ/WRITE to/from TCP/UDP connections
        # CREATE SERVER, LISTEN to server,
        # PORT SCANNING/listening, FILE TRANSFERS; IPv4/IPv6
        # https://linux.die.net/man/1/nc   https://en.wikipedia.org/wiki/Netcat
        [-46DdhklnrStUuvzC] [-i interval] [-p source_port] [-s source_ip_address] [-T ToS]
        [-w timeout] [-X proxy_protocol] [-x proxy_address[:port]] [hostname] [port[s]]
        -N # Shutdown network socket after EOF on the input.

        # Listen (default is to initiate) : Use to test a client or reverse proxy
            # Inspect client's request, or reverse-proxy's forwarded headers, proxy protocol, and such.
            nc -l -p $port  # -k for repeatedly

        # Port Scanning
            # SCAN for a specific OPEN PORT by NUMBER quickly
            nc -zvw 1 $ip_or_domain $port_number
            # PORT RANGE is NOT RELIABLE (false negatives are typical)
            nc -zvw 1 $ip_or_domain $port_RANGE # Don't use, e.g., nc ... 1-1000
            # SCAN a PORT RANGE quickly and RELIABLY:
            seq ${pSTART:-1} ${pSTOP:-1000} \
                |xargs -IX nc -zvw 1 $ip_or_domain X 2>&1 >/dev/null \
                |grep Connected

        # Attempt TCP connection
            nc $host $port

        # Snoop : Get version info of target's OpenSSH server
            echo 'EXIT' |nc $ip 22

        # Chat : client/server (peers) : Two-way comms channel (STDIN/STDOUT)
            # @ Server (listener) terminal
            nc -l $port # Listen on all interface at port $port
            # @ Client terminal
            nc -N $ip $port # -N to shutdown the network socket after EOF (CTRL-D)
            #... thereafter, anything typed at one terminal is sent to the other

        # Create a UNIX Socket
            # -U : Unix Socket file
            # -l : act as the server-side; listen for incoming connections.
            nc -U /tmp/demo.sock -l

        # File transfer (PUSH)
            # @ target machine; listen; dump output to file
                nc -l 8888 > /path/to/target/file
            # @ source machine; connect to the listen process, feeding it the file
                nc $target_ip 8888 < /path/to/source/file
                # ... connection closes upon transfer completion.

        # FASTer file transfer (PULL) http://petrushin.org/
            # @ source machine; tar option `-` sets .tar output (BIGFILE.gz) to STDOUT (piped)
                tar -cf - /path/to/BIGFILE |pigz |nc -l -p 8888  # pigz is a mutlithreaded gz archiver
            # @ target machine; tar option `-` sets source .tar (BIGFILE.gz) to STDIN (piped)
                nc $target_ip 8888 |pigz -d |tar xf - [-C /target/dir]

            # Parallel Implementation of GZip; used w/ Netcat (nc)  http://www.zlib.net/pigz/
            pigz  # file|STDIN compressed to file.gz|STDOUT;

        # HTTP request
            echo -n "GET / HTTP/1.0\r\n\r\n" |nc $host 80

    socat  # SOcket CAT : netcat for sockets : multipurpose relay
        # Bidirectional data transfers between any two byte streams, each of almost any type.
        # EXAMPLES : http://www.dest-unreach.org/socat/doc/socat.html#EXAMPLES
        # https://linux.die.net/man/1/socat
        # https://www.sobyte.net/post/2022-01/socat-netcat/
        socat [options] $address $address # Address syntax: protocol:ip:port
        socat -h[h[h]]  # List options and address types
        socat -d[d[d]]  # Verbosity

        # TCP listener : Listen for (Proxy-forwarded) request; dump it to stdout
            socat -v TCP-LISTEN:30080,fork -  # Create new process (fork) per request

        # Forward port, changing the protocol
            socal TCP-LISTEN:1234 UDP-LISTEN:4321

        # Forward local port to remote
            socat TCP4-LISTEN:80,fork TCP4:host.example.com:80

        # Docker Socket Proxy : Monitor docker commands of Terminal 2 from Terminal 1
            # @ Terminal 1
            socat -v UNIX-LISTEN:/tmp/docker.sock,fork UNIX-CONNECT:/var/run/docker.sock
            #... same, but more options:
            socat UNIX-LISTEN:/tmp/docker.sock,fork,mode=660,user=$(whoami) UNIX-CONNECT:/var/run/docker.sock
            # @ Terminal 2
            export DOCKERhost=unix///tmp/sock
            docker pull alpine

        # Forward all local traffic of a port to a remote server (at its port)
            socat TCP4-LISTEN:$portLocal,fork TCP4:$server_ip_addr_or_domain_name:$portRemote
        # Forward all local docker pull requests to other Docker registry
            socat TCP4-LISTEN:5000,fork TCP4:$other:5000

        # Forward terminal to the serial port COM1 :
            socat READLINE,history=$HOME/.cmd_history /dev/ttyS0,raw,echo=0,crnl

        # mTLS : Securing Traffic Between two Socat Instances Using TLS
            # http://www.dest-unreach.org/socat/doc/socat-openssltunnel.html
            socat OPENSSL-LISTEN:4443,reuseaddr,pf=ip4,fork,cert=server.pem,cafile=client.crt PIPE

        # Remote bash session (one way)
            # @ Local : local user enters commands here : test command: hostname
            socat STDIN TCP4-LISTEN:1234 # Works with addresses swapped (STDOUT v. STDIN)
            # @ Remote : remote shell
            socat TCP4-CONNECT:$client_ip4_addr_or_hostname:1234 EXEC:/bin/bash

        # Remote bash session within an encrypted (OpenSSL) tunnel (sans ssh)
            # @ Local : Create a self-signed cert and its key : EMPTY FIELDS (all) OK
            openssl req -newkey rsa:2048 -nodes -keyout cert.key -x509 -days 1000 -out cert.crt # -nodes is depricated; prefer -noenc.
            # @ Local : Create PEM from key and cert
            cat cert.key cert.crt > sslkey.pem
            # @ Local : Listener : self signing necessitates `verify=0`
            socat -dd STDIN OPENSSL-LISTEN:1234,cert=sslkey.pem,verify=0 # many need to adjust tty params
            # @ Remote : Connector : execute the shell and forward it, encrypted
            socat -dd OPENSSL-CONNECT:$client_ip_or_hostname:1234,verify=0 EXEC:/bin/bash

        # File tranfer
            # Listener (@ destination)
            socat -dd TCP-LISTEN:1234 OPEN:/path/to/target/file,creat  # Yes, "creat" NOT "create"
            # Connect and send
            socat -dd TCP-CONNECT:$listener_machine_ip:1234 FILE:/path/to/source/file

        # HTTP file server
            #!/bin/bash
            FILE="$1"
            PORT=${PORT:-5555}

            MIME_TYPE=$(file --mime-type -b "$FILE")
            SIZE_BYTES=$(du -b "$FILE" | cut -f1)
            #FILE_NAME=$(basename "$FILE")
            HEADER="HTTP/1.1 200 OK
            Content-Type: $MIME_TYPE
            Content-Length: $SIZE_BYTES
            "

            # Single-request server
            socat -dd - TCP-LISTEN:$PORT,reuseaddr,fork < <(printf "$HEADER"; cat "$FILE")
            # Else
            printf "$(printf "%s\n\n" "$HEADER";cat $FILE)" |socat -dd TCP-LISTEN:$PORT,reuseaddr -

            # Persistent server
            while true;do echo "$(printf "%s\n\n" "$HEADER";cat $FILE)" |socat -dd TCP-LISTEN:$PORT,reuseaddr -;done
            # Else
			cat <<-EOH |tee header
			HTTP/1.1 200 OK
			Content-Type: $MIME_TYPE
			Content-Length: $SIZE_BYTES

			EOH
            while true;do cat header $FILE |socat -dd TCP-LISTEN:$PORT,reuseaddr -;done

        # HTTP Echo server : Response container IP:PORT of both client and server
            socat -v TCP-LISTEN:30080,fork SYSTEM:'(echo -ne "HTTP/1.1 200 OK\nDocumentType: text/plain\n\nserver: \$SOCAT_SOCKADDR:\$SOCAT_SOCKPORT\nclient: \$SOCAT_PEERADDR:\$SOCAT_PEERPORT\n";hostname;date --rfc-3339=s)'
            #... ignores Proxy Protocol (headers), and so will not preserve client IP address.

            # @ JSON format response
            socat -v TCP-LISTEN:30080,fork,bind=192.168.28.200 SYSTEM:'(echo -ne "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\\"server\\": \\"\$SOCAT_SOCKADDR:\$SOCAT_SOCKPORT\\", \\"client\\": \\"\$SOCAT_PEERADDR:\$SOCAT_PEERPORT\\", \\"hostname\\": \\"$(hostname)\\", \\"date\\": \\"$(date --rfc-3339=s)\\"}")'

        # HTTP reverse-proxy server @ http://example.com : upstream @ http://localhost:8080
            socat TCP-LISTEN:8080,fork TCP:example.com:80
            # Daemonize it:
            nohup socat TCP-LISTEN:8080,fork TCP:example.com:80 &
            # Add TLS (via openssl):
            socat TCP-LISTEN:8443,fork,reuseaddr OPENSSL:example.com:443,verify=0
            # Bind to a target interface, e.g., eth0 (vs lo)
                # 1. Get IPv4 address of that interface AKA device:
                ip -4 -brief addr show dev eth0
                # 2. Bind the listener to it
                socat TCP-LISTEN:8443,fork,bind=192.168.28.200 ...

        # Chat client/server : Bidirectional

            # @ machine 1
            socat TCP4-LISTEN:1234 STDOUT
            # or
            nc -l -p 1234

            # @ machine 2
            socat  STDIN TCP4:$machine1_ip:1234
            #... does same ...
            socat TCP4:$machine1_ip:1234 STDOUT
            #... type anything; transmits per newline.

        # Get time from time server : "-" or "STDOUT"
            socat TCP:time.nist.gov:13 STDOUT


    # CAPTURE/INSPECT per PROTOCOL
        wireshark  # gui

        tcpdump    # cli; dump traffic on a network

            -A  # print each packet in ASCII; for capturing web pages.
            -X  # print headers & data of each packet
            tcpdump -i $dev icmp             # Capture ICMP messages (incl. PMTUD modifying MTU)
            tcpdump -v -i $dev port 2377     # Docker Swarm cluster-management traffic
            tcpdump 'tcp port 80' -X         # all tcp packets to/from port 80
            tcpdump host foo                 # all traffic to/from host foo
            tcpdump ip host foo and not bar  # all IP packets between foo and any host except bar

    # DNS lookup utilities
        sudo dnf install -y bind-utils traceroute tcpdump ldns

        traceroute # Hop-by-hop trace from local host to remote host,
            # revealing any intermediary-hop hang: "* * * ..."
            traceroute a2.lime.lan # Typically sends ICMP or UDP
            # If target-host firewall blocks those protocols/ports, then try another, e.g., 53/TCP:
            sudo traceroute -T -p 53 dc1.lime.lan

        tcpdump -i $ifc port 53 # Capture DNS traffic on device AKA interface $ifc

        nslookup # DNS info; query Internet (DNS) name servers; interactively if no args

        nslookup $domain            # get info on $domain name, e.g., www.google.com
        nslookup -query=mx $domain  # query Mail Exchanger Record
        nslookup -type=ns $domain   # query Name Server
        nslookup -type=any $domain  # query DNS Record
        nslookup -type=soa $domain  # query Start of Authority
        nslookup -port 56 $domain   # query port number

        dig $domain                 # DNS query : yum install bind-utils | apt install dnsutils
        dig $nsIP $domain           # DNS query using declared (@$nsIP) nameserver
        dig $nsIP -x $ip$domain     # Reverse DNS query using declared (@$nsIP) nameserver

        # DNS latency due to declared nameserver
        dig @$nsIP $domain |grep time #=> ;; Query time: 249 msec

        drill # Modern version of dig

        ldns # DNSSEC support
            ldns-signzone -k Kexample.com.+005+12345.key example.com.zone
            ldns-verify-zone example.com.zone
            ldns-keygen example.com
            ldns-dane create example.com

    # DHCP release/renew IP Address
        dhclient
        # LAN
        sudo dhclient -r 'eth0' && sudo dhclient 'eth0'
        # IPv6 address
        sudo dhclient -6 -r 'eth0' && sudo dhclient 'eth0'
        # @ WLAN
        sudo dhclient -v -r 'wlan0' && sudo dhclient -v 'wlan0'

    # Restart Network
        # RHEL/CentOS/Fedora
        /etc/init.d/network restart

        # Debian/Ubuntu
        /etc/init.d/networking restart

# CONFIGURE

    # Ubuntu
        netplan # Changes PERSIST
        netplan --debug apply
        /etc/netplan/... # Config files auto-applied on boot

    ip # iproute2 Libary/utilities for configuring Linux : http://www.policyrouting.org/iproute2.doc.html
        # ip, ss, bridge, rtacct, rtmon, tc, ctstat, lnstat,
        # nstat, routef, routel, rtstat, tipc, arpd
        #
        # Configure/show routing, devices, policy routing and tunnels
        # replaces 'ifconfig' & 'route' utilities
        # changes do NOT persist; used as config-test tool; config per apropos files

        # Legacy utility    Obsoleted by                  Note
        # --------------    --------------------------    --------------------------
        # ifconfig          ip addr, ip link, ip -s       Address and link config
        # route             ip route                      Routing tables
        # arp               ip neigh                      Neighbors
        # iptunnel          ip tunnel                     Tunnels
        # nameif            ifrename, ip link set name    Rename network interfaces
        # ipmaddr           ip maddr                      Multicast
        # netstat           ip -s, ss, ip route           Show various network stats

        ip addr # List all addresses; per interface
            -c  # color highlights

        # L4 AKA Layer 4 AKA Transport layer AKA Transport Control Layer
            # AKA Session Layer AKA TCP/UDP Layer AKA Ports Layer
            # AKA End-to-end Comms Layer AKA Connection Layer
            # AKA Flow Control Layer AKA Reliability Layer AKA Segmentation Layer
            man ip-address         # Protocol address management
            ip addr                # show IP and MAC of all devices/interfaces
            ip addr show dev $dev  # show IP and MAC of device (eth0 or whatever)

            sudo ip addr add dev $dev 10.0.0.10/24  # add an IP address to NIC; always include subnet
                                               # ifconfig FAILs to see this newly added IP Address

            sudo ip -6 addr del $ipv6_cidr dev $dev
            sudo ip [-4] addr del $ipv4_cidr dev $dev
            ip maddr show eth0                 # show MAC

        # L3 AKA Layer 3 AKA Network Layer
            # AKA Routing Layer AKA IP Layer AKA Switching Layer
            # AKA Packet Forwarding Layer AKA Logical Addressing Layer
            # AKA Internet Layer
            man ip-route                # Routing table management
            ip route                    # Route to gateway at all interfaces.
            ip -4 route show dev $dev   # Route to Gateway at device; IPv4
                # Shows node's public IP address:
                #... scope link  src 192.168.1.183 ...
            ip -r route  # Resolve your public IP address to name of Gateway
            sudo ip route add $cidr via $gateway_ip
            sudo ip route add 20.0.0.0/8 via 192.168.1.1  # add a route
            sudo ip route add default via 192.168.50.100  # add default gateway

            man ip-tunnel               # Tunnel configuration
            ip tunnel list
                # https://en.wikipedia.org/wiki/IP_tunnel
                # Connect two IPv6 islands, A and B (IPv6 address of each gateway), across an IPv4 network.
                # Create the 6in4 Tunnel:
                dev=tun6in4
                mode=sit # Simple Internet Transition (Used for IPv6-over-IPv4)
                av6='2001:db8:1::1/64'
                bv6='2001:db8:2::1/64'
                ipv4='203.0.113.1'
                sudo ip tunnel add $dev mode $mode remote $ipv4 local $av6 ttl 255
                # Assign the IPv6 Address to the tunnel interface (device):
                sudo ip addr add $av6 dev $dev
                # Bring up the tunnel
                sudo ip link set $dev up
                # Set up routing (lest single purpose, host-to-host and declared/configured by app)
                ip -6 route add $bv6 dev $dev

            # Setup a VPN tunnel through untrusted network (internet), connecting two private subnets:
                sub_a=10.0.1.0/24
                sub_b=10.0.2.0/24
                gw_a=192.0.2.1
                gw_b=198.51.100.1
                mode=gre
                tun=gre1
                tun_a=10.255.255.1/30
                tun_b=10.255.255.2/30
                # 1. Create the GRE Tunnel on Site A:
                    # Add the GRE tunnel interface
                    ip tunnel add $tun mode $mode remote $gw_b local $gw_a ttl 255
                    # Assign an IP address to the GRE tunnel interface
                    ip addr add $tun_a dev $tun
                    # Bring up the tunnel interface
                    ip link set $tun up
                    # Add a route to send traffic destined for Subnet B through the tunnel
                    ip route add $sub_b dev $tun
                # 2. Create the GRE Tunnel on Site B:
                    # Add the GRE tunnel interface
                    ip tunnel add $tun mode $mode remote $gw_a local $gw_b ttl 255
                    # Assign an IP address to the GRE tunnel interface
                    ip addr add $tun_b dev $tun
                    # Bring up the tunnel interface
                    ip link set $tun up
                    # Add a route to send traffic destined for Subnet A through the tunnel
                    ip route add $sub_a dev $tun
                # 3. Secure with OpenVPN (else IPsec)
                    # https://chatgpt.com/share/a5700da7-916a-4570-a501-642340fedb4d
                    # Site A : OpenVPN server configuration file : /etc/openvpn/server.conf
                    # On the server, ensure IP forwarding is enabled and add a route to the client’s subnet.
                        b=10.0.2.0
                        vpn=10.8.0.0
                        # OpenVPN routes traffic by assigning client IPs (10.8.0.1 to 10.8.0.254)
                        # under that declared 24-bit mask (255.255.255.0)
                        # Note VPN network masks have to match source as apropos.
						cat <<-EOH |sudo tee /etc/openvpn/server.conf
						port 1194
						proto udp
						dev tun
						ca ca.crt
						cert server.crt
						key server.key
						dh dh.pem
						server $vpn 255.255.255.0
						ifconfig-pool-persist ipp.txt
						push "route $b 255.255.255.0"
						client-to-client
						keepalive 10 120
						cipher AES-256-CBC
						persist-key
						persist-tun
						status openvpn-status.log
						log-append /var/log/openvpn.log
						verb 3
						EOH
                    # Site B
                    # OpenVPN client configuration file (e.g., /etc/openvpn/client.conf)
                    # On the client, add a route to the server’s subnet.
                        a=10.0.1.0
						cat <<-EOH |sudo tee /etc/openvpn/client.conf
						client
						dev tun
						proto udp
						remote $gw_a 1194
						resolv-retry infinite
						nobind
						persist-key
						persist-tun
						ca ca.crt
						cert client.crt
						key client.key
						remote-cert-tls server
						cipher AES-256-CBC
						verb 3
						route $a 255.255.255.0
						EOH

        # L3/L2 (Network/Link layers)
            # ARP (Address Resolution Protocol) table for IPv4
            # Neighbor Discovery Protocol (NDP) table for IPv6.
            # - These tables map IP addresses (L3) to MAC addresses (L2).
            # - Essential for LAN traffic
            ip neigh
            ip neigh show dev $dev  # Show IP (v4/v6) to MAC address maps for that device
                # 172.27.240.1              lladdr 00:15:5d:91:f1:6c STALE
                # fe80::c9c4:32bb:162f:22cb lladdr 00:15:5d:91:f1:6c STALE
                #... Same MAC (physical address) regardless of IP version
            ip -4 neigh show dev eth0
                # 192.168.1.2 dev eth0 lladdr 00:21:29:ae:77:b6 STALE      # CB router with eth0 connected
                # 192.168.1.1 dev eth0 lladdr e0:3f:49:9a:8b:b8 REACHABLE  # Gateway router
                # 192.168.1.101 dev eth0 lladdr 00:1c:c0:4d:94:bf STALE    # Local host (this machine)

        # L2 AKA Layer 2 AKA Data Link layer AKA Link Layer (TCP/IP model)
            # AKA MAC Layer AKA Frame Layer AKA Switching Layer AKA Bridge Layer
            # AKA Ethernet Layer AKA Physical Addressing Layer
                # Manage physical and logical device settings (MAC address)
                # Device AKA adapter AKA interface AKA connection AKA NIC
            man ip-link                 # Network device configuration
            ip link                     # Show MAC of all devices
            dev=ens192                  # Common: eth0, ens192, wlan0, docker0, cni*
            ip -s link dev show $dev    # Show link statistics
                # Path MTU Discovery (PMTUD) may cause a transitory,
                # per-connection change MTU setting (nominally 1500) of a device,
                # e.g., to account for tunnel protocol (VPN, SSH, ...),
                # which adds data to packets' header
                # See:
                sudo tcpdump -i $dev                    # Reports size per packet, e.g., "length 1414"
            sudo ip link set dev $dev mtu 9000          # Set MTU to allow Jumbo Frames
            #... both TX and RX devices must support, else no affect.
            sudo ip link set $dev up|down               # Set UP/DOWN; toggle on/off; use to apply new config(s)
            sudo ip link set $dev alias "Public link"   # Set alias AKA description

            # LEGACY utilities
                ifdown/ifup
                # @ LAN
                sudo ifdown 'eth0' && sudo ifup 'eth0'
                # @ WLAN
                sudo ifdown 'wlan0' && sudo ifup 'wlan0'

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
        iwconfig wlan0 essid $wifi_ssid key s:$wifi_password


    wl  # WiFi utility for ROUTER FIRMWARE : Package per HW/firmware of your device
        # List of commands : https://wiki.DD-WRT.com/wiki/index.php/Wl_command
        Usage: /usr/sbin/wl [-a|i <adapter>] [-h] [-d|u|x] <command> [arguments]
            -h [cmd]  command description for cmd
            -a, -i    adapter name or number
            -d        output format signed integer
            -u        output format unsigned integer
            -x        output format hexdecimal

        wl -i eth1|eth2 up|down  # on|off; reset adapter and mark as up|down
        wl -i eth1|eth2 restart  # restart (must already be down).
        wl -i eth1|eth2 out      # mark adapter down but do not reset hardware.

        wl -i eth1 radio on|off # 2.4 GHz on|off
        wl -i eth2 radio on|off # 2.4 GHz on|off
        wl -i eth1 status
        # After turning radio off, e.g., `wl -i eth2 radio off`, Web UI shows wrong status
        # @ "Wireless" > "Professional" > "5GHz" > "Enable Radio" > "yes"

        wl -i eth1 bssid         # Adapter MAC (BSSID); must be on.

    iwlist # Get current SSID Listing ...
        iwlist 'wlan0' scan | grep 'ESSID'

    brctl # Bridge (ethernet) configuration : setup, maintain inspect
        # E.g., combine two subnets into one
        # bridge-utils (Bridge Utilities) : Sniff the (Gateway-to-ISP) network
        # https://linux.die.net/man/8/brctl
        brctl show
        brctl addbr br0             # Add (Create) a bridge
        brctl addif br0 eth0 eth1   # Bond interfaces to bridge

         # Bridge addresses and devices; show, manipulate
        bridge fdb show dev $name

        #... @ topology:  ISP  ===(eth1)===  PC  ===(eth0)===  Gateway Router

        # Disable multicast snooping:
        echo 0 > /sys/devices/virtual/net/br0/bridge/multicast_snooping
        # ... THEN RUN Wireshark on eth0 or eth1.

        # TR-069 - Protocol used by ISP (ACS) for managing CPE [CWMP] [Wikipedia]
        # REF: https://0x90.psaux.io/2020/03/01/Taking-Back-What-Is-Already-Yours-Router-Wars-Episode-I/
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

    # IP Networking Control Files http://linux-ip.net/html/basic-control-files.html

        # Interface definitions : per Connection Name,'*'; [RedHat]
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

        # Interface definitions : 'Routes...' [RedHat]
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

        # DOMAIN & DNS Name Server
            # /etc/resolv.conf : Generated by NetworkManager
            # Do not edit.
            cat '/etc/resolv.conf'
                search aDOMAIN
                nameserver 192.168.1.1
                # May be configured such that
                nameserver 127.0.0.1  # loopback addr
                #... this means NeworkManager is using `resolve.dnsmasq`
                # e.g., ddWRT-Merlin router
                cat '/etc/resolv.conf'
                    ...
                    resolv-file=/tmp/resolv.conf
                    servers-file=/tmp/resolv.dnsmasq
                    # then find DNS Server @
                    cat '/tmp/resolve.conf' #=> (OpenDNS servers)
                        nameserver 208.67.222.222
                        nameserver 208.67.220.220

        # SERVICEs/PORTs/PROTOCOL settings @ service name database file:
        /etc/services  # a columnar list: 'SERVICE  PORT/{tcp|udp}  [INFO]'

        # hosts file
            cat /etc/hosts # IP_ADDR HOSTNAME1 HOSTNAME2

                127.0.0.1   localhost.localdomain localhost serviceX.local
                192.168.1.1 router.asus.com
                192.168.1.1 www.asusnetwork.net
                192.168.1.1 www.asusrouter.com
                192.168.1.1 SMB.aDOMAIN SMB

                # Block websites
                0.0.0.0     malicious.site
                0.0.0.0     bad.place.com

# SSH / OpenSSH a.k.a. "OpenBSD Secure Shell" : See 'REF.Network.SSH.sh'

    # BYOC (Bring your own creds)
    ssh -i ${key} ${user}@${host_name_OR_public_ip}

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

    # SCP : Secure Copy  https://en.wikipedia.org/wiki/Secure_copy
        scp $source user@host:$target     # upload source FILE to host @ target
        scp -r $source user@host:$target  # upload source FOLDER to host @ target
        scp user@host:$source $target     # download from host
            -p  # preserve mtime, atime, mode
            -r  # recurse (folder)

        scp -i ~/.ssh/aKey.pem -r ./foo ${user}@${host}:~    # Copy local ./foo to ~/foo @ host
        scp -i ~/.ssh/aKey.pem -r ./foo/* ${user}@${host}:~  # Copy CONTENT of local ./foo to ~/ @ host

    # SFP : Secure FTP (SFTP)  https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol
    # https://www.digitalocean.com/community/tutorials/how-to-use-sftp-to-securely-transfer-files-with-a-remote-server
    # SFTP uses the SSH protocol to authenticate and establish a secure connection. Because of this, the same authentication methods are available that are present in SSH

        sfp ; scp2 ; sftp

        sftp $user@$ip_or_hostname
        sftp -oPort=${port:-22} $user@$ip_or_hostname
        # sftp> help
        # sftp> ?
        # sftp> pwd
        # sftp> lpwd                        # Local equivalent
        # sftp> ls -ahl
        # sftp> lls -ahl                    # Local equivalent
        # sftp> get $path                   # Download $path
        # sftp> get $srcFname $dstFname     # Download remote src to dst
        # sftp> put -r $localDir            # Upload a local directory

# CIFS/SAMBA
    # cifs-utils samba-client samba-common [3 packages]

    # smbclient : ftp-like client to access SMB/CIFS resources on servers
    smbclient -L netbios-name [-s config.filename] [-U username] [--option=clientusespnego=no]
    # or
    smbclient //server/service [-s config.filename] [-U username] [--option=clientusespnego=no]
    # ... prompts for password

    # mount : mount whatever @ temporary/current-environment [on-the-fly]
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

# FIREWALL : firewalld, nftables/iptables
    #>>>  See REF.Network.firewalld.sh  <<<
    # firewall-cmd is the CLI for firewalld.service : systemd service and interface wrapping iptables/nftables
    systemctl status firewalld.service

    sudo firewall-cmd ... # CLI for firewalld

    # Show/Verify settings
        zone=public
        svc=halb
        sudo firewall-cmd --zone=$zone --list-all
        sudo firewall-cmd --direct --get-all-rules
        sudo firewall-cmd --info-service=$svc

    ufw  # Uncomplicated Firewall  https://help.ubuntu.com/community/UFW
        ufw enable|disble|status
        # BLOCK intruder per IP Address; e.g., some local [LAN] intruder here ...
            ufw block proto tcp from 192.168.8.345
        # deny ...
            ufw deny 53/udp  # deny UDP packets on port 53
            ufw deny ssh     # deny all SSH connections

# IRC
    # an ancient text-based chat protocol; remains very popular among programmers.
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
        arpspoof -i $_NIC -t $dst_IP $_AP_IP # now Target sees your NIC (eth0) as AP
        arpspoof -i $_NIC -t $_AP_IP $dst_IP # now AP     sees your NIC (eth0) as Target

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
        # Optionally run using rsync daemon; requires SRC or DEST to start with a module name.

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
            # MIRROR (without overwriting newer @ DEST)
                -auz --delete
            # CLONE
                -az --delete
            # FILTERing : TWO SYNTAXES : ENTIRELY DISTINCT
                # Bash syntax; abs/rel paths, globbing, etc
                --exclude=PATTERN
                --include=PATTERN
                --prune-empty-dirs
                # Non-standard syntax : both declaration and file use rsync syntax.
                # An .rsync-filter file may be in each SOURCE dir and it contains filter rules in rsync syntax.
                -F, --filter='dir-merge /.rsync-filter' # Note "/" is rysnc syntax; is *not* root.
                # E.g.,
                    --exclude=.git
            # other options
                --modify-window=2 # SECONDS (reduced) accuracy @ timestamp comps; useful for FAT, NFS, ...
                --files-from="$_REL_PATHS_LIST" # READ paths FROM FILE
                    # - MUST be of rel-paths; MUST SHARE ONE PARENT,
                    # - Refactors target
                    rsync -itu --files-from="$_REL_PATHS_LIST" "$_PARENT_PATH/" "$dst/"
            # TRAILING BACKSLASH required if target declared, else source copies to SUBDIR of target:
            #   /source  => target/source
            #   /source/ => /target

        # PUSH clone of pwd (content) to ~/target dir of host (a0),
            # excluding source directory $(pwd)/.git,
            # using ssh parameters of ~/.ssh/config .
            rsync -vaz --delete --exclude=.git ./ a0:target

        # MIRROR (without overwriting newer @ target)
            rsync -auz --delete "$src/" "$dst/"

        # CLONE
            rsync -az --delete "$src/" "$dst/"

        # copy root files only; no sub-dirs
            rsync -itu "$src/"* "$dst/"

        # copy ONE dir, recursively
            rsync -itudr "$src/thisone" "$dst/"

        # copy ONE FILE : create/update; preserver-mtime; pre-alloc space
            rsync -itu --preallocate "$src/$_FILE" "$dst/"

        # MIRROR DIRS (src,dst) : Preserve newer in both directions
            # A directory
            rsync -atuz "$src/" $user@$host:"$dst/"   # push
            rsync -atuz $user@$host:"$src/" "$dst/"   # pull
            # A file
            rsync -atvz "$src" $user@$host:"$dst"       # push
            rsync -atvz $user@$host:"$src" "$dst"       # pull

            # If host is unconfigured at ~/.ssh/config
                rsync -atuze "ssh -i $key" ...
                # Useful options to add or override SSH settings of ~/.ssh/config
                "ssh -i $key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
                # Push (Upload)
                rsync -atuz --delete --progress -e "ssh -i $key" "$src/" $user@$host:"$dst/"
                # Pull (Download)
                rsync -atuz --delete --progress -e "ssh -i $key" $user@$host:"$src/" "$dst/"
        # copy one file-type [$type]
            rsync -irtu --include="*/" --include="*.$type" --exclude="*" "$src/" "$dst/"

        # CHANGEd files only; per checksum, not timestamp
            rsync -rcnC --out-format="%f" "$old/" "$new/" # Copy files that were deleted or previously modified
            rsync -rcnC --out-format="%f" "$new/" "$old/" # Copy files that were added or since modified

        # PUSH to AWS VM : from local $PWD to remote $HOME/assets/ .
            # Creates target `~/assets` if not exist.
            key=~/.ssh/swarm-aws.pem
            user=ubuntu
            host='54.234.246.103'
            rsync -atuz -e "ssh -i $key" ./ $user@$host:~/assets/

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
# Apache server
    # @ Alpine
        # Install
        apk add apache2
        # Start the service:
        rc-service apache2 start
        # Validate
        curl http://localhost # Default "It works" page.
        # Enable apache on startup (if needed):
        rc-update add apache2
        # Edit the configuration
        vim /etc/apache2/httpd.conf # Else @ /etc/httpd/conf/httpd.conf
            # DocumentRoot "/var/www/localhost/htdocs"
        # Replace landing page
        echo "
            <style>body {font-family: sans-serif;margin: 2em;background:#443;color:#eee;</style>
            <h1>This response is from Apache Web Server (<code>httpd.service</code>) @ $(hostname)</h1>
            <hr>
            <pre>$(hostnamectl || echo '')</pre>
            <hr>
            <pre>$(ip -4 route)</pre>
        " |sudo tee /var/www/localhost/htdocs/index.html
        # Restart
        rc-service apache2 restart
    # @ RHEL8/AlmaLinux8
        # Install
        sudo dnf -y install httpd
        # Start now +always
        sudo systemctl --now enable httpd
        # Replace landing page
        echo "
            <style>body {font-family: sans-serif;margin: 2em;background:#443;color:#eee;</style>
            <h1>Apache Web Server (<code>httpd.service</code>) @ $(hostname)</h1>
            <hr>
            <pre>$(hostnamectl || echo '')</pre>
            <hr>
            <pre>$(ip -4 route)</pre>
        " |sudo tee /var/www/html/index.html
        # Restart
        sudo systemctl restart http
        # Firewall fix
        sudo firewall-cmd --zone=public --add-service=http --permanent
        sudo firewall-cmd --zone=public --add-service=https --permanent
        sudo firewall-cmd --reload
        # SELinux fix
        sudo semanage -a -t httpd_sys_content_t "/var/www/html(/.*)?" # GOOD
        #sudo chcon -R -t httpd_sys_rw_content_t /var/www/html   # BAD1
