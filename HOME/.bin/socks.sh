#!/usr/bin/env bash
# Functions to manage a SOCKS5 proxy server to provide
# HTTP(S) access from a restricted-network machine.
export port='5522'
export ip='10.160.113.234'

showsocks(){
    running="$(ps aux |grep $port |grep $ip)"
    [[ $running ]] && {
        echo "$running"
        echo "" 
        echo "=== SOCKS5 proxy is running : local port $port forwarded to target node ($ip)"
        echo "===   Configure GUI apps : localhost:$port"
        echo "===   Configure CLI apps : export http_proxy=socks5h://127.0.0.1:$port"
    } || {
        echo "=== SOCKS5 proxy is NOT running."
    }
}

export -f showsocks 

makesocks(){
    [[ "$(ps aux |grep $port |grep $ip)" ]] && {
        showsocks
    } || {
        ssh -i $HOME/.ssh/vm_common -fNqT -D $port $ip \
            && showsocks
    }
}

killsocks(){
    pid="$(ps aux |grep $port |grep $ip |awk '{print $2}' |head -n1)"
    [[ $pid ]] && { kill $pid; echo "=== Killed: $pid"; } 
    showsocks
}

export -f makesocks killsocks 

