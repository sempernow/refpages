# [Nginx]( https://nginx.org/en/docs/ "nginx.org") | [Core Module](https://nginx.org/en/docs/http/ngx_http_core_module.html "nginx.org") | [Upstream](https://nginx.org/en/docs/http/ngx_http_upstream_module.html) 


## Commands

```bash
# Validate (-t) and print (-T) the currently running config
nginx -T
# Signal : reload, ...
nginx -s SIGNAL
```

E.g., dump valid/total config of first-found container of `rpx` service

```bash
docker exec -it $(docker ps -q --filter name=rpx -n 1) sh -c 'nginx -T' > 'nginx-T.log'
```

## References @ [`nginx.info.conf`](nginx.info.conf)

## [Top 10 Mistakes](https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#keepalive "nginx.com")

## Dockerfile

The entrypoint for a containerized NGINX server should be:

```bash
nginx -g daemon off
```

This is required for nginx to run in the foreground, 
else the container stops immediately after starting! 

```Dockerfile
CMD ["nginx", "-g", "daemon off;"]

```

## File server

Serve files of the current directory:

```bash
# Start the file server detached
docker run -d --rm --name ngx -p 8080:80 -v $(pwd):/usr/share/nginx/html:ro nginx

# GET host file: $(pwd)/this.txt
wget http://localhost:8080/this.txt # -O dump.here
```


## [Reverse Proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/ "nginx.com")


```bash
docker run -d \
    --name nginx-proxy \
    -p 80:80 \
    -p 443:443 \
    -v /path/to/nginx.conf:/etc/nginx/nginx.conf:ro \
    -v /path/to/certs:/etc/nginx/certs:ro \
    -v /path/to/conf.d:/etc/nginx/conf.d:ro \
    nginx:1.29.4-alpine3.23-slim
```

```nginx
events {
    worker_connections 1024;
}

http {
    # Upstream definitions
    upstream backend1 {
        server backend-app1:3000;
        server backend-app2:3000 backup;
    }
    
    upstream backend2 {
        server api-service:8080;
        keepalive 32;
    }
    
    upstream backend3 {
        server legacy-system:9000 max_fails=3 fail_timeout=30s;
    }
    
    # Logging
    access_log  /var/log/nginx/access.log combined buffer=32k flush=5s;
    error_log   /var/log/nginx/error.log warn;
    
    # SSL/TLS settings
    ssl_certificate     /etc/nginx/certs/cert.pem;
    ssl_certificate_key /etc/nginx/certs/key.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Common proxy settings
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    
    include /etc/nginx/conf.d/*.conf;
}
```

Expose a service running at `127.0.0.1:3000` (`localhost`)

```nginx
http {
    server {
        listen 80;
        server_name example.com;

        location /foo/ {
            proxy_pass http://127.0.0.1:3000/bar/;

            # Universally essential headers (sort of)
            proxy_set_header   Host $host;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $server_name;
            proxy_set_header   X-Forwarded-Proto $scheme;
        }
    }
}
```
- Okay to use either IP address or domain name

### Using the `upstream{}` block 

>"&hellip; [unlocks several features that improve performance](https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#upstream-groups)"

```nginx
http {

    upstream auth_svc {
        zone upstreams 64K;
        server 127.0.0.1:3000 max_fails=1 fail_timeout=2s;
        keepalive 2;
    }

    server {
        listen 8080;
        server_name example.com;

        location / {
            proxy_set_header Host $host;
            proxy_pass http://auth_svc/;
            proxy_next_upstream error timeout http_500;
        }
    }
}
```
- Set `max_fails` ___else Nginx dies when an upstream service stops___.
    ```bash
    docker service update --replicas=0
    ```
- At Docker `service`, `stack` and `swarm`, 
the upstream reference, `auth_svc`, is the Docker ___service name___, 
and the upstream `server IP_ADDR:PORT` references the container. 
That port, perhaps set per `docker` YAML, must also match the application configuration of course.
The `server {listen 8080; ...}` would also be the ___container port___; typically set to `8080` or so.

    ```yaml
        ports:
            - 80:8080
            - 443:8443
    ```

>The service-name referencing allows Nginx to keep up with container changes lest the service itself is terminated; `docker service stop`/`start ...` commands are okay. And `swarm` handles the load balancing.

#### Routing 

`location /THIS/` _versus_ `proxy_pass .../THAT/`

```nginx
upstream server_reference {
    # Server declaration (container perspective)
}

server {
    listen 8080
    server cdn.example.com

    location /THIS/ {
        proxy_pass <scheme>://<server_reference>/THAT/
    }
}
```
- The  `/THIS/` ___is replaced___ by the `/THAT/`
    - The request from downstream (web) is of `/THIS/` .
    - The request sent upstream is of `/THAT/` .
        - Upstream is the application server. 
            - Up/Down is from client perspective, as in UPload versus DOWNload.

### Multiple Services

Using the above service declarations as a template, repeat  as necessary &hellip;

```nginx
http {

    server {
        listen 80;
        server_name example.com;

        location / {
            proxy_set_header Host $host;
            proxy_pass http://localhost:3000/;
        }

        location /svcX/v1/ {
            proxy_set_header Host $host;
            proxy_pass http://localhost:4000/foo/;
        }

        location /svcY/ {
            proxy_bind 127.0.0.2; # declare the network adapter
            proxy_pass http://example.com/app2/;
        }
    }
}
```
- @ Docker `stack` (`swarm`)
    - `location` regards request from downstream (web/client)
    - `proxy_pass` regards request sent upstream (@ CTNR)


## Wordpress-Nginx `.conf` examples | [Search GitHub](https://github.com/search?q=wordpress+nginx)

- [`bitnami/wordpress-nginx` (`nginx-T.command.log.conf`)](nginx-T.command.log.conf)
- [`mjstealey/wordpress-nginx-docker`](https://github.com/mjstealey/wordpress-nginx-docker/blob/master/nginx/default.conf "GitHub")

### Nginx Config Generator : [NGINXConfig.io](https://github.com/digitalocean/nginxconfig.io "DigitalOcean")


## Nginx : `ngx_http_upstream_module` : [`keepalive`](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive)

&hellip; and associated params: 

```ini
upstream SERVICE_{
    server SERVICE_NAME:SERVICE_PORT;

    keepalive 2x_REPLICAS;
}

server {
    ...
    location /THIS/ {
        proxy_pass http://SERVICE_THAT/;

        proxy_http_version 1.1;
        proxy_set_header Connection "";
        ...
    }
} 
```
- `/THIS/` is the request sent by the client (downstream)
- `/THAT/` is the request recieved by the server (upstream)
- `SERVICE_PORT` is that of ___container___, not that exposed.
    - I.e., @ Docker Compose file
    ```yaml
        ...
        ports: 
            - 7770:${SERVICE_PORT}
    ```

>We recommend setting the parameter to ___twice the number of servers listed___ in the `upstream{}` block. This is large enough for NGINX to maintain keepalive connections with all the servers, but small enough that upstream servers can process new incoming connections as well. &mdash; https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#no-keepalives)

## ERR : [Broken Pipe](https://gosamples.dev/broken-pipe/)

>The broken pipe is a TCP/IP error occurring when you write to a stream where 
the other end (the peer) has ___closed___ the underlying ___connection___.

```plaintext
core_pwa.1.ybx10pk8sguo@docker-desktop    | PWA : 2022/09/07 15:10:28.609143 logger.go:54: (200) : GET /app/start -> 10.0.3.6:53812 (60.1168ms)
core_pwa.1.ybx10pk8sguo@docker-desktop    | PWA : 2022/09/07 15:10:28.739194 errors.go:33: 0000000… : ERR : write tcp 10.0.3.3:3030->10.0.3.6:53828: write: broken pipe
core_pwa.1.ybx10pk8sguo@docker-desktop    | PWA : 2022/09/07 15:10:28.739337 main.go:269: main: @ PWA Shutdown per signal: terminated
core_pwa.1.ybx10pk8sguo@docker-desktop    | PWA : 2022/09/07 15:10:28.742779 errors.go:33: 0000000… : ERR : write tcp 10.0.3.3:3030->10.0.3.6:53816: write: broken pipe
core_pwa.1.ybx10pk8sguo@docker-desktop    | PWA : 2022/09/07 15:10:28.751308 errors.go:33: 0000000… : ERR : write tcp 10.0.3.3:3030->10.0.3.6:53824: write: broken pipe
core_pwa.1.ybx10pk8sguo@docker-desktop    | PWA : 2022/09/07 15:10:33.739488 main.go:156: main: @ PWA Shutdown : Disconnecting from 'db1' @ host : 'pg1'
core_pwa.1.ybx10pk8sguo@docker-desktop    | PWA : 2022/09/07 15:10:33.741392 main.go:278: main: Completed
core_pwa.1.ybx10pk8sguo@docker-desktop    | PWA : 2022/09/07 15:10:33.741418 main.go:66: main: error: could not stop PWA server gracefully: context deadline exceeded
```

## `/rpx_status` 

Our alias of `/basic_status`, so that standard returns 404 regardless. 
Still, denies all but for HQ and such.

```bash
☩ curl https://swarm.foo/rpx_status
Active connections: 1
server accepts handled requests
 3 3 45
Reading: 0 Writing: 1 Waiting: 0
```

## [Proxy FTP](https://stackoverflow.com/questions/55338127/server-static-files-from-ftp-server-using-nginx "StackOverflow.com 2019")

>Nginx doesn't support proxying to FTP servers. At best, you can proxy the socket... and this is a real hassle with regular old FTP due to it opening new connections on random ports every time a file is requested.

>What you can probably do instead is create a FUSE mount to that FTP server on some local path, and serve that path with Nginx like normal. To that end, CurlFtpFS is one tool for this. Tutorial: https://linuxconfig.org/mount-remote-ftp-directory-host-locally-into-linux-filesystem


## [PROXY Protocol](https://docs.nginx.com/nginx/admin-guide/load-balancer/using-proxy-protocol/ "docs.nginx.com")

>The PROXY protocol &hellip; to receive client connection information passed through proxy servers and load balancers such as HAproxy and Amazon Elastic Load Balancer (ELB).

>With the PROXY protocol, NGINX can learn the originating IP address from HTTP, SSL, HTTP/2, SPDY, WebSocket, and TCP. Knowing the originating IP address of a client may be useful for setting a particular language for a website, keeping a denylist of IP addresses, or simply for logging and statistics purposes.

>The information passed via the PROXY protocol is the client IP address, the proxy server IP address, and both port numbers.


### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

