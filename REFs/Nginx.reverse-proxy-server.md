# NGINX 

NGINX in Docker to serve files from a bind-mounted directory:

## Basic Command

```bash
docker run -d \
    --name nginx-server \
    -p 8080:80 \
    -v /path/to/host/files:/usr/share/nginx/html:ro \
    nginx
```


## Explanation

- `-p 8080:80` - Maps host port 8080 to container port 80
- `-v /path/to/host/files:/usr/share/nginx/html` - Binds your directory to nginx's default web root
- `:ro` (optional) - Makes the mount read-only for security

## With Custom Configuration

If you need custom nginx configuration:

1. **Create a custom nginx config file** (`nginx-custom.conf`):

```nginx
server {
    listen 80;
    server_name localhost;
    
    location / {
        root /usr/share/nginx/html;
        autoindex on;  # Show directory listing
        index index.html index.htm;
    }
    
    # Optional: Disable nginx version display
    server_tokens off;
}
```

2. **Run with custom config**:
```bash
docker run -d \
    --name nginx-server \
    -p 8080:80 \
    -v /path/to/host/files:/usr/share/nginx/html:ro \
    -v $(pwd)/nginx-custom.conf:/etc/nginx/conf.d/default.conf:ro \
    nginx
```

## With Autoindex (__Directory Listing__)

For serving static files with directory listing enabled:

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    
    # Enable directory listing
    autoindex on;
    
    # Optional: Format the listing nicely
    autoindex_format html;
    
    # Optional: Show file sizes in bytes, KB, MB, or GB
    autoindex_exact_size off;
    
    # Optional: Show file modification times in local timezone
    autoindex_localtime on;
    
    # Optional: Disable directory listing for specific locations
    location /private/ {
        autoindex off;
    }
    
    # Optional: Customize the look of directory listing
    location / {
        # Show icons for different file types
        autoindex on;
        
        # Add custom header
        add_header X-Directory-Listing "Enabled";
        
        # Optional: Disable showing .hidden files
        # autoindex_hide (nginx plus only)
    }
    
    # Optional: Serve specific files by default
    index index.html index.htm;
}
```

## For Development with Auto-Reload

If you're editing files frequently:

```bash
docker run -d \
    --name nginx-dev \
    -p 8080:80 \
    -v /path/to/host/files:/usr/share/nginx/html \
    -v /path/to/nginx/custom.conf:/etc/nginx/conf.d/default.conf \
    --mount type=bind,source=/path/to/your/files,target=/usr/share/nginx/html \
    nginx
```

## Testing

After running, access your files at:
- http://localhost:8080 (or your server IP)
- Individual files: http://localhost:8080/yourfile.html

## Important Notes

1. **Permissions**: Ensure nginx can read your files. If needed:
   ```bash
   chmod -R 755 /path/to/host/files
   ```

2. **Security**: For production, consider:
   - Using read-only mounts (`:ro`)
   - Running as non-root user
   - Adding security headers in nginx config

3. **Cleanup**:
   ```bash
   # Stop the container
   docker stop nginx-server
   
   # Remove the container
   docker rm nginx-server
   
   # Remove the image (if needed)
   docker rmi nginx
   ```

This setup gives you a simple, temporary web server for sharing static files.

---

# RP and TLS Termination

NGINX as a reverse proxy and TLS terminator for multiple upstreams. 

Here's how to set it up:

## Basic Reverse Proxy Setup

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

## Complete Configuration Example

### 1. Create the main nginx config (`nginx.conf`):

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
    access_log /var/log/nginx/access.log combined buffer=32k flush=5s;
    error_log /var/log/nginx/error.log warn;
    
    # SSL/TLS settings
    ssl_certificate /etc/nginx/certs/cert.pem;
    ssl_certificate_key /etc/nginx/certs/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
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

### 2. Create virtual host configurations (`/path/to/conf.d/app1.conf`):

```nginx
# App 1 - with TLS termination
server {
    listen 443 ssl http2;
    server_name app1.example.com;
    
    ssl_certificate /etc/nginx/certs/app1.example.com.crt;
    ssl_certificate_key /etc/nginx/certs/app1.example.com.key;
    
    location / {
        proxy_pass http://backend1;
        proxy_cache my_cache;
        proxy_cache_valid 200 302 10m;
        
        # Health check endpoint
        location /health {
            proxy_pass http://backend1/health;
            access_log off;
        }
    }
    
    # Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name app1.example.com;
        return 301 https://$server_name$request_uri;
    }
}
```

### 3. Multiple upstream config (`/path/to/conf.d/app2.conf`):

```nginx
# App 2 - API service with WebSocket support
server {
    listen 443 ssl;
    server_name api.example.com;
    
    ssl_certificate /etc/nginx/certs/wildcard.example.com.crt;
    ssl_certificate_key /etc/nginx/certs/wildcard.example.com.key;
    
    # API routes
    location /api/v1/ {
        proxy_pass http://backend2/api/v1/;
        proxy_set_header X-API-Version v1;
    }
    
    location /api/v2/ {
        proxy_pass http://backend2/api/v2/;
        proxy_set_header X-API-Version v2;
    }
    
    # WebSocket endpoint
    location /ws/ {
        proxy_pass http://backend2/ws/;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }
    
    # Static files
    location /static/ {
        proxy_pass http://backend2/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 4. Load balancing with health checks (`/path/to/conf.d/app3.conf`):

```nginx
# App 3 - Load balanced with active health checks
upstream backend3 {
    zone backend3 64k;
    server backend-a:9000 weight=3;
    server backend-b:9000 weight=2;
    server backend-c:9000 weight=1;
}

server {
    listen 443 ssl;
    server_name app3.example.com;
    
    # Health check configuration
    match server_ok {
        status 200-399;
        header Content-Type = text/html;
        body ~ "Server is healthy";
    }
    
    health_check match=server_ok interval=10 fails=3 passes=2;
    
    location / {
        proxy_pass http://backend3;
        
        # Retry on failure
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_next_upstream_tries 3;
        
        # Timeout settings
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 30s;
    }
}
```

## Docker Compose Example

```yaml
version: '3.8'
services:
  nginx-proxy:
    image: nginx:1.29.4-alpine3.23-slim
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./certs:/etc/nginx/certs:ro
      - ./logs:/var/log/nginx
    networks:
      - proxy-network
    restart: unless-stopped
    
  backend-app1:
    image: your-app:latest
    networks:
      - proxy-network
    environment:
      - VIRTUAL_HOST=app1.example.com
      - VIRTUAL_PORT=3000
      
  api-service:
    image: your-api:latest
    networks:
      - proxy-network
    environment:
      - VIRTUAL_HOST=api.example.com
      - VIRTUAL_PORT=8080

networks:
  proxy-network:
    driver: bridge
```

## Docker Run Command with Full Configuration

```bash
docker run -d \
    --name nginx-reverse-proxy \
    --network custom-network \
    -p 80:80 \
    -p 443:443 \
    -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
    -v $(pwd)/conf.d:/etc/nginx/conf.d:ro \
    -v $(pwd)/certs:/etc/nginx/certs:ro \
    -v nginx-logs:/var/log/nginx \
    -e TZ=UTC \
    --restart unless-stopped \
    nginx:1.29.4-alpine3.23-slim
```

## Key Features of This Setup:

1. **TLS Termination**: Terminates SSL at nginx level
2. **Multiple Upstreams**: Routes to different backend services
3. **Load Balancing**: Round-robin, weighted, or IP hash
4. **Health Checks**: Active and passive monitoring
5. **Caching**: Response caching capabilities
6. **WebSocket Support**: Proxy WebSocket connections
7. **Security Headers**: Configurable security policies
8. **Access Control**: Rate limiting, IP whitelisting

## Verify Configuration:

```bash
# Test nginx config
docker exec nginx-proxy nginx -t

# Check running config
docker exec nginx-proxy nginx -T

# Monitor logs
docker logs -f nginx-proxy
```

## Why This Image Works:

- **alpine3.23-slim**: Small (~20MB) but includes all necessary nginx modules
- **nginx 1.29.4**: Latest features including HTTP/3, enhanced TLS, better proxy capabilities
- **Includes**: All required proxy modules (http_proxy, stream_proxy, ssl, etc.)
- **Lightweight**: Perfect for containerized environments

For production, consider adding:
- Rate limiting
- WAF (ModSecurity) via separate container
- Log aggregation
- Automatic SSL renewal (Certbot)
- High availability setup

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
