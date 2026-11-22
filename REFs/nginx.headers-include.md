# NGINX : Common Response Headers

>How to implement a common set of response headers
>that are inherited by selected location blocks.

An NGINX quirk is that if a `location` defines *any* 
[`add_header`](https://nginx.org/en/docs/http/ngx_http_headers_module.html#example "nginx.org/docs"), 
then all parent headers are completely overridden (rather than extended). 
So, this __include&nbsp;method__ is the *only* __guaranteed&nbsp;solution__ for common headers.

(Note `proxy_set_header` declarations have same override behavior.)

This example adds a common set of security-related headers 
to all `location` blocks of a `server` block:

@ `/etc/nginx/conf.d/security-headers.conf`

```ini
# /etc/nginx/conf.d/security-headers.conf
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
# HSTS (HTTP Strict Transport Security, i.e., TLS only) response header 
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
```


@ `/etc/nginx/conf.d/example.com.conf`

```ini
# /etc/nginx/conf.d/example.com.conf
#...
server {
    listen 443 ssl;
    server_name example.com;

    #...
    
    location /api {
        include /etc/nginx/conf.d/security-headers.conf; #<<-- Reference
        add_header          Cache-Control "no-store, no-cache, max-age=0";
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://backend;
    }
    
    location /static {
        include /etc/nginx/conf.d/security-headers.conf; #<<-- Reference
        add_header          Cache-Control: "public, max-age=86400"
        root /var/www/static;
    }
    
    location / {
        include /etc/nginx/conf.d/security-headers.conf; #<<-- Reference
        root /var/www/html;
    }
}
```

---

## NGINX Inheritance Rules 

The key interaction to be aware of is NGINX's header __inheritance rule__ 
*for directives that can be used in* __multiple contexts__ 
(like `add_header` and `proxy_set_header`).

### Override Rule

If an `add_header` or `proxy_set_header` directive is defined within a `server` block, 
it *overrides and discards* any `add_header` or `proxy_set_header` directives 
from a parent `server` or `http` block.

### Example of NGINX inheritance: 

__If you have this configuration__: 

```ini
http {
    # This header is for the client response (http block)
    add_header X-Http-Header "http-value"; 

    server {
        # This header is for the client response (server block)
        add_header X-Server-Header "server-value";

        # This sets a header for the upstream request (server block)
        proxy_set_header X-Proxy-Server-Header "proxy-server-value"; 

        location /proxy/ {
            # This header is for the client response (location block)
            add_header X-Location-Header "location-value"; 

            # This sets a header for the upstream request (location block)
            proxy_set_header X-Proxy-Location-Header "proxy-location-value"; 
            proxy_pass http://backend_server;
        }
    }
}
```
- `add_header` adds headers to the response that NGINX sends back to the client.
- `proxy_set_header` sets or redefines headers in the request that NGINX sends to the upstream (backend) server. 

__Then, when a request matches__ : 

- __Client Response__ Headers: Only `X-Location-Header` will be present. 
    `X-Http-Header` and `X-Server-Header` are *ignored* because an `add_header` exists in the `server` block. 
- __Upstream Request__ Headers: Only `X-Proxy-Location-Header` will be sent to the backend. 
    `X-Proxy-Server-Header` is *ignored* because a `proxy_set_header` exists in the `location` block. 

---

<!-- 

… ⋮ ︙ • ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
☢ ☣ ☠ ¦ ¶ § † ‡ ß µ Ø ƒ Δ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖  ☘  웃 𝐀𝐏𝐏 🡸 🡺 ➔
ℹ️ ⚠️ ✅ ⌛ 🚀 🚧 🛠️ 🔧 🔍 🧪 👈 ⚡ ❌ 💡 🔒 📊 📈 🧩 📦 🥇 ✨️ 🔚

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# README HyperLink

README ([MD](__PATH__/README.md)|[HTML](__PATH__/README.html)) 

# Bookmark

- Target
<a name="foo"></a>

- Reference
[Foo](#foo)

-->
