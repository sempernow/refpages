# [Tor Network](https://en.wikipedia.org/wiki/Tor_(network) "Wikipedia") | [`tor(1)`](https://linux.die.net/man/1/tor "man page @ linux.die.net") | [Documentation (Obsolete)](https://2019.www.torproject.org/docs/documentation.html.en "2019 yet no other") | [Tor Project](https://www.torproject.org/ "TorProject.org : has NO Documentation!")

>`tor` is a connection-oriented anonymizing communication service. Users choose a source-routed path through a set of nodes, and negotiate a "virtual circuit" through the network, in which each node knows its predecessor and successor, but no others. Traffic flowing down the circuit is unwrapped by a symmetric key at each node, which reveals the downstream node.

Basically tor provides a distributed network of servers ("onion routers"). Users bounce their TCP streams - web traffic, ftp, ssh, etc - around the routers, and recipients, observers, and even the routers themselves have difficulty tracking the source of the stream. 

(Excerpts from [`tor(1)` man page.](https://linux.die.net/man/1/tor "man page @ linux.die.net"))

## Install

Tor Browser @ Windows

```text
choco install tor-browser
```

`tor` CLI @ Linux

```bash
sudo apt install tor 
```

```bash
sudo systemctl restart tor 

# Start tor process per commandline
tor -f $config_file_path

# Validate config
tor --verify-config

# List options
tor --list-torrc-options
```

## Config : `torrc`

@ `/etc/tor/torrc`

```text
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 127.0.0.1:80
```
- `HiddenServicePort VIRTUALPORT TARGET`
- @ Docker `service`
    - `HiddenServicePort VIRTUALPORT SVC_NAME:PORT`


## Tor SOCKS5 Proxy

Anonymizer for use with HTTP(S) client, such as browser or cURL. 

@ `torrc`

```bash
SOCKSPort 0.0.0.0:9050
```

Test client anonymization

```bash
☩ curl ifconfig.me
71.123.123.123  #... from ISP

☩ curl --socks5-hostname 127.0.0.1:9150  ifconfig.me
198.98.60.90    #... from Tor Network (randomized per session)
```

Test Tor network connectivity 

```bash
# Request : GET tor site
export onion='tenf4wqudyjibh4igv6ir5vjmumo4omi55tu2lncaxpkx7r2a7darjqd.onion'
curl -v --socks5-hostname 127.0.0.1:9050 http://${onion}/
curl -v -x socks5h://127.0.0.1:9050 http://${onion}/
```
```text
*   Trying 127.0.0.1...
* TCP_NODELAY set
* SOCKS5 communication to tenf4wqudyjibh4igv6ir5vjmumo4omi55tu2lncaxpkx7r2a7darjqd.onion:80
* Can't complete SOCKS5 connection to 0.0.0.0:0. (4)
* Closing connection 0
curl: (7) Can't complete SOCKS5 connection to 0.0.0.0:0. (4)
```
- Exit code `4` : Undocumented; this exit code is skipped in man page!
    - _A feature or option that was needed to perform the desired request was not enabled or was explicitly disabled at build-time. To make curl able to do this, you probably need another build of libcurl._ 
    https://everything.curl.dev/usingcurl/returns

## Tor Hidden Service(s)

### Hostname (*.onion; Onion address)

#### @ `/var/lib/tor/hidden_service/` 

The `hostname` is ephemeral (regenerated per restart) lest it and its public-private key pair exist 

```bash
cat /var/lib/tor/hidden_service/hostname
```
```bash
/ $ ls -ahl /var/lib/tor/hidden_service/
total 24K
drwx------    3 tor      nogroup     4.0K Dec  5 21:13 .
drwx------    4 tor      root        4.0K Dec  6 14:20 ..
drwx------    2 tor      nogroup     4.0K Dec  5 21:05 authorized_clients
-rw-------    1 tor      nogroup       63 Dec  5 21:13 hostname
-rw-------    1 tor      nogroup       64 Dec  5 21:13 hs_ed25519_public_key
-rw-------    1 tor      nogroup       96 Dec  5 21:13 hs_ed25519_secret_key
```
- Directory MUST have mode `0700`, else error: "... excessive permissions ...".

Persist hostname and keys for static address 

```bash
export onion_addr="$(cat /var/lib/tor/hidden_service/hostname)"
```

## Nginx config 

```ini
server {
    listen 8888 default_server;
    listen [::]:8888 default_server;
    #server_name tenf4wqudyjibh4igv6ir5vjmumo4omi55tu2lncaxpkx7r2a7darjqd.onion;
    server_name _;
    location / {
        root    /var/www/html;
        index   index.html;
    }
}
```
- "`default_server`" combined with "`server_name _;`" 
   affect a catch-all server block.
