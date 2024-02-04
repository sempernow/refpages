#!/usr/bin/env bash
###############################################################################
# Establish web access thru a public node per SOCKS5 proxy scheme of OpenSSH,
# and configure the environment, apt-get, and Docker server to use the proxy. 
# Configs are idempotent, and persist regardless of proxy-tunnel status.
# 
# - Web Access @ socks5h://127.0.0.1:5128
# - TEST using cURL utility:
#   - Remote : curl -sI --preproxy socks5h://localhost:5128 www.google.com
#   - Local  : curl -sI www.google.com
#
# SCENARIO: Nodes on private subnet have access to nodes on public subnet 
#   only thru their private IP addresses; private nodes have no comms
#   to/from anywhere outside VPC, whereas public nodes have web access. 
#
#   Such a private node can gain secure web access through a public node 
#   serving as its (SOCKS5) proxy; installable from a remote admin node.
#
#   Admin node <-- SSH --> Internet 
#                             |
#                    SSH,HTTP,HTTPS,SMTP,...
#                             |
#                     | Public Subnet   |              | Private Subnet  |
#                     | Jump Box node   | <-- SSH ---> | Origin node     |
#                     | (SSH Server)    | <-- HTTPS -- | (SOCKS5 Server) |
#
# OpenSSH: Allows for configuring an ssh server as a SOCKS5 server;
#   a session-layer firewall, internet gateway (with NAT), and proxy server, 
#   allowing two-way HTTPS traffic, but only that initiated at SOCKS5 node.
# 
#   Instantiate the SOCKS5 proxy server on Private/Origin node and 
#   tunnel into Public node (Jump Box). The SOCKS5 protocol dynamically
#   handles protocol/port requests from client applications,
#   as a persistent background process: (See man page SSH(1); -D)
#       
#     ssh -D $local_port -fCNq ... USER@PRIVATE_IP_of_PUBLIC_NODE
# 
# ARGs: IP [TTL(-1 for infinity, else seconds, else default=300)]
# 
# REQUIREs: 
# - SSH key of proxy server (~/.ssh/swarm-aws.pem)
# - Matching $USER names (this vs. proxy)
###############################################################################
killSOCKS5(){
    sleep $1 && {
        echo "$(echo "$2" |awk '{print $2}')" |xargs -n 1 kill -s TERM
    }
}
export -f killSOCKS5

# Set SOCKS5 params
[[ $1 ]] || { echo "FAIL @ ARGs : REQUIRED : Private IP of (public) proxy (\$1).";exit 1; }
export port='5128' # 3128 is IANA squid-proxy, exploits, etal : https://www.speedguide.net/port.php?port=3128
ip=$1 #... PRIVATE IP of the PUBLIC NODE (jump box)
export ttl=${2:-300}
user=$USER
key=/home/$user/.ssh/swarm-aws.pem
[[ -f $key ]] || { echo "FAIL @ SSH key : NOT EXIST : '$key'";exit 2; }

# Test for existing tunnel; abort if so.
export ok="$(ps aux |grep -- "-D $port -fCNq ${user}@$ip" |grep -v grep)"
[[ $ok ]] && { echo "SOCKS5 proxy is ALREADY UP";exit 0; }

# Configure the ssh server of the node having web access ($ip) as our SOCKS5 proxy 
# by establishing a tunnel to it; forwarding a local port ($port) to one of its dynamic ports.
echo "Establish SOCKS5 proxy server @ $ip"
nohup /bin/bash -c "ssh -o StrictHostKeyChecking=no -D $port -fCNq ${user}@$ip -i $key &" > /dev/null 2>&1

# Validate proxy tunnel is up; report and abort on fail.
sleep 2 && ok="$(ps aux |grep -- "-D $port -fCNq ${user}@$ip" |grep -v grep)"
[[ $ok ]] || { echo "FAIL @ SOCKS5 : process is NOT RUNNING.";exit 3; }

# Declare proxy params : current shell
export forward=127.0.0.1:$port
export http_proxy=socks5h://$forward
export https_proxy=socks5h://$forward
#... socks5h is 'SOCKS5 with remote DNS resolution' (@ man apt-transport-http)

# Declare proxy params : all shells (persist; idempotently append to config)
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
    export flag_docker_reconfig=1
}

[[ $flag_docker_reconfig && $(type -t docker) ]] && {
     # Docker server : reload and restart on reconfig flag if Docker installed.
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    echo "Docker server is re-configured (@ 1st call only)"
    echo ">>>  RUN the SOCKS command AGAIN  <<<"
} || {
    # Set the TTL-report string (is)
    [[ $ttl == '-1' || (( $ttl < 0 )) ]] && {
        is="is OPEN (infinite TTL)."
    } || {
        (( $ttl / 3600 )) && {
            t="$(( $ttl / 3600 )) hr $(( $(( $ttl / 60 )) % 60 )) min"
        } || {
            t="$(( $ttl / 60 )) min $(( $ttl % 60 )) sec"
        }
        is="CLOSEs in ${t}."

        # Launch a silent background process that closes the tunnel after TTL
        /bin/bash -c "killSOCKS5 '$ttl' '$ok'" >/dev/null 2>&1 &
    }
    echo "SUCCESS : This SOCKS5 tunnel $is"
}

exit 0
