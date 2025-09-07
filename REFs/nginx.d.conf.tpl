## @ /etc/nginx/conf.d/default.conf
##
########################################################
##  THIS is a TEMPLATE FOR PROCESSING by nginx.src.sh
##  This gets called from nginx-global-v0.0.1.conf
########################################################
##
## Signals : nginx -s SIGNAL
## reload (config) | quit (graceful) | stop (fast) | reopen (log files)
##
## Options : -h help; -v|V version; -g set directive(s); -t(q)|T test(quiet)|test and print current config
## Ex: nginx -g "pid /var/run/nginx.pid; worker_processes `nproc`;"
##
## Docs : Index
## https://nginx.org/en/docs/ 
##
## Directives 
## https://nginx.org/en/docs/dirindex.html  
##
## Nginx Core Module 
## =================
## Directives
## https://nginx.org/en/docs/http/ngx_http_core_module.html#directives 
## Variables 
## https://nginx.org/en/docs/http/ngx_http_core_module.html#variables
##
## Nginx Reverse Proxy 
## ===================
## https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/ 
##
## location 
## - longest "prefix" (hardcoded) path takes precedent.
## - RegEx paths take precedent over "prefix" paths.
## https://nginx.org/en/docs/http/ngx_http_core_module.html#location 
## https://www.keycdn.com/support/nginx-location-directive
##
## Upstream Module
## ===============
## https://nginx.org/en/docs/http/ngx_http_upstream_module.html
## Upstream Groups
## https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#upstream-groups
## Load balancing 
## https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#ip_hash
##
## Configuring HTTPS servers
## =========================
## https://nginx.org/en/docs/http/configuring_https_servers.html
## Module ngx_http_ssl_module
## https://nginx.org/en/docs/http/ngx_http_ssl_module.html
##
## Security/Server Side TLS (Mozilla.org)
## https://wiki.mozilla.org/Security/Server_Side_TLS
##
## Configure to use TLSv1.2/TLSv1.3 only
## =====================================
## https://www.cyberciti.biz/faq/configure-nginx-to-use-only-tls-1-2-and-1-3/
## TEST support of a TLS version:
## curl -I -v --tlsv1.2 --tls-max 1.2 https://$domain/
## curl -I -v --tlsv1.3 --tls-max 1.3 https://$domain/
## Validate fail @ lower-version attempt
## curl -I -v --tlsv1.1 --tls-max 1.1 https://$domain/
##
## Route 53 Let’s Encrypt wildcard certificate with acme.sh
## ========================================================
## https://www.cyberciti.biz/faq/route-53-lets-encrypt-wildcard-certificate-with-acme-sh/
##
## - This file is NESTED in the http DIRECTIVE @ caller : /etc/nginx/nginx.conf
## - Child blocks inherit directives of parent.
##
## DNS : Docker's embedded DNS server is always @ 127.0.0.11
## https://serverfault.com/questions/827381/upstream-resolve-breaks-configuration
## - Questionable affect; may degrade performance.
## - DNS server set stack-wide @ YAML.
# resolver 127.0.0.11 valid=10s ipv6=off;

## TLS Certs
## - swarm.foo     : per openssl
## - 01.uqrate.org : per acme.sh
## TLS Test @ ssltest.com
## - site.crt           : bytes: 1123; "B+"; missing intermediaries
## - site.fullchain.crt : bytes: 3809; "A+"; full chain

# ssl_certificate         /run/secrets/site.crt;
ssl_certificate         /run/secrets/site.fullchain.crt;
ssl_certificate_key     /run/secrets/site.key;
## https://nginx.org/en/docs/http/configuring_https_servers.html#chains

ssl_session_timeout 1d;
ssl_session_cache shared:MySSL:10m;
ssl_session_tickets off;
## Diffie-hellman params file (docker config) : UNUSED @ ECC certs
ssl_dhparam /dhparam.pem;

# ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
ssl_protocols TLSv1.2 TLSv1.3;
# ssl_protocols TLSv1.3;

# ssl_ciphers         HIGH:!aNULL:!MD5;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

## https://serverfault.com/questions/997614/setting-ssl-prefer-server-ciphers-directive-in-nginx-config
ssl_prefer_server_ciphers off;

## Add HSTS (TLS only) response header 
add_header Strict-Transport-Security "max-age=63072000" always;

## OCSP Stapling
# ssl_stapling on;

# ssl_stapling_verify on;
##... Nginx logs : ERRs: 
## "ssl_stapling" ignored, issuer certificate not found...
## "ssl_stapling" ignored, host not found in OCSP responder "r3.o.lencr.org"
##... other err msgs, depending on ... just about everything.

## Full chain : Root CA and Intermediate certs (REQUIREd if OCSP Stapling)
ssl_trusted_certificate /run/secrets/site.fullchain.crt;
## https://nginx.org/en/docs/http/configuring_https_servers.html#chains
##... full chain is site certificate with any "intermidiary" cert(s) appended. Order matters.

## OCSP Resolver IP address 
# resolver 8.8.8.8;

## https://nginx.org/en/docs/http/ngx_http_core_module.html#send_timeout
send_timeout               11s;

## Proxy server params
## https://nginx.org/en/docs/http/ngx_http_proxy_module.html

proxy_connect_timeout       3s;
## send_timeout correlates with client's WAIT TIME : 504 err page arriving thereupon.
proxy_send_timeout          3s;
proxy_read_timeout         10s;

client_header_timeout       3s;
client_max_body_size        1m;

## Custom error-page scheme FAILing ... returns Nginx default 404 page.
# error_page 502      /502.html;
# error_page 504      /504.html;
# location /504.html {
#     root                /usr/share/nginx/html; 
#     error_page 504      /504.html;
# }

## @ HTTP 4xx|5xx : Static err page : /error.html in the declared nginx root
## Declared (YAML) bind mount @ ${PATH_ABS_VM_ASSETS}/html/50x:/usr/share/nginx/html
error_page 400 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 421 422 423 424 425 426 428 429 431 451 500 501 502 503 504 505 506 507 508 510 511 599 /error.html;

## @ HTTP 4xx|5xx : Set intercept to 'off' to prevent Nginx from intercepting 
## the response from upstream on any of their error codes (4xx|5xx); 
## HOWEVER, when a service is down, Nginx will respond with the declared error_page.
proxy_intercept_errors off;

## - Upstream server (container) ports are those expected by the upstream services
##   REGARDLESS of port(s) declared at Docker
## - MUST set 'max_fails' to the NUMBER of INSTANCES (containers) of its service.
##   The service will be ignored thereafter until restart; 
##   So, proxy service heals if we use `docker service {stop,start} ...` commands; alias {dsstop, dsstart}.
## http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive
## https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#no-keepalives
## "We recommend setting the parameter to TWICE THE NUMBER OF SERVERS listed in the upstream{}" 
upstream gui {
    server gui:8080 fail_timeout=5s;
}
upstream aoa {
    server aoa:PORT_AOA max_fails=REPLICAS_AOA fail_timeout=5s;
    keepalive KEEPALIVE_AOA;
}
upstream api {
    server api:PORT_API max_fails=REPLICAS_API fail_timeout=5s;
    keepalive KEEPALIVE_API;
}
upstream pwa {
    server pwa:PORT_PWA max_fails=REPLICAS_PWA fail_timeout=5s;
    keepalive KEEPALIVE_PWA;
}

## Drop requests having no Hosts header (444 is Nginx's non-standard code)
# server {
#     listen      PORT_RPX;
#     server_name "";
#     return      444;
# }

## @ Redirect : http:// -> https://
server {
    listen      PORT_RPX;
    listen [::]:PORT_RPX;

    server_name     _;

    #############################
    ## Redirect all HTTP to HTTPS 
    # return 301 https://$server_name$request_uri; 
    # return 301 https://$host$request_uri;
    return 301 https://DOMAIN$request_uri;
}

## @ Redirect : www.DOMAIN -> DOMAIN
server {
    listen      PORT_RPX;
    listen [::]:PORT_RPX;

    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name     www.DOMAIN;

    return 301 https://DOMAIN$request_uri;
}

## @ https://DOMAIN
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name     DOMAIN;

    location = /error.html {
        ssi on;
        internal;
        auth_basic off;
        root /usr/share/nginx/html;
    }
    location = /error.json {
        ssi on;
        internal;
        auth_basic off;
        root /usr/share/nginx/html;
    }
    location = /50x.html {
        root /usr/share/nginx/html;
    }
    location = /favicon.svg {
        root /usr/share/nginx/html;
    }

    # location = /basic_status {..} ##... rather 404 @ PWA service
    location = /rpx_status {
        ## Gateway router
        allow 192.168.1.0/24;
        ## Subnet: ingress (overlay)
        allow 10.0.0.0/24;
        ## HQ
        allow 2601:140:8f00:29a:1534:1d1a:36e4:8526;

        deny  all;
        stub_status;
    }

    ###############################################################
    ## location : proxy_pass : Proxy the UPSTREAM servers (hosts) 
    # proxy_pass http://SVC/...

    location /adm/ {
        proxy_pass http://gui/; 

        proxy_http_version  1.1;
        proxy_set_header    Connection "";
 
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Host $server_name;
        proxy_set_header    X-Forwarded-Proto $scheme;

        ## Set 'off' so Nginx intercepts only when service is down.
        # proxy_intercept_errors off; ## ... declared globally.

        ## Response body of JSON instead of HTML
        error_page 400 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 421 422 423 424 425 426 428 429 431 451 500 501 502 503 504 505 506 507 508 510 511 /error.json;
    }

    location /aoa/v1/ {
        proxy_pass http://aoa/aoa/v1/; 

        proxy_http_version  1.1;
        proxy_set_header    Connection "";
 
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Host $server_name;
        proxy_set_header    X-Forwarded-Proto $scheme;

        ## Set 'off' so Nginx intercepts only when service is down.
        # proxy_intercept_errors off; ## ... declared globally.

        ## Response body of JSON instead of HTML
        error_page 400 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 421 422 423 424 425 426 428 429 431 451 500 501 502 503 504 505 506 507 508 510 511 /error.json;
    }

    location /api/v1/ {
        proxy_pass http://api/api/v1/;

        proxy_http_version  1.1;
        proxy_set_header    Connection "";
 
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Host $server_name;
        proxy_set_header    X-Forwarded-Proto $scheme;

        ## Set 'off' so Nginx intercepts only when service is down.
        # proxy_intercept_errors off; ## ... declared globally.

        ## Response body of JSON instead of HTML
        error_page 400 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 421 422 423 424 425 426 428 429 431 451 500 501 502 503 504 505 506 507 508 510 511 /error.json;
    }

    location / {
        proxy_pass http://pwa/; 

        ## 1. Host header required to prevent HTTP 403 per Hotlinks middleware
        ## 2. CORSorigin must be accounted for, especially @ POST. 
 
        ## Default resets host header; we resurrect it here, per request.
        # proxy_set_header    Host                $host;
        # proxy_set_header    X-Real-IP           $remote_addr;
        # # proxy_set_header    X-Forwarded-By      $server_addr:$server_port;
        # proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
        # proxy_set_header    X-Forwarded-Host    $server_name;
        # # proxy_set_header    X-Forwarded-Proto   $scheme;

        proxy_http_version  1.1;
        proxy_set_header    Connection "";
 
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Host $server_name;
        proxy_set_header    X-Forwarded-Proto $scheme;
        
    }

}
