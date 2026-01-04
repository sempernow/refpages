# [NETDATA for Proxmox VE](https://www.netdata.cloud/integrations/data-collection/containers-and-vms/proxmox-ve/)


Here's a comprehensive guide on how to install netdata on a Proxmox host. 
I'll cover multiple methods so you can choose the one that best fits your needs.

## Method 1: Install via Proxmox Shell (Recommended)

### Step 1: Access Proxmox Shell
SSH into your Proxmox host or use the built-in shell via the web interface.

### Step 2: Install netdata using the automated script
```bash
# Download and run the automatic installation script
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh
sh /tmp/netdata-kickstart.sh
```

This script will:
- Detect your OS (Proxmox is Debian-based)
- Install all dependencies
- Set up netdata as a service
- Configure automatic updates

### Step 3: Verify installation
```bash
# Check if netdata is running
systemctl status netdata

# Check listening port (default: 19999)
netstat -tlnp | grep 19999
```

### Step 4: Access the dashboard
Open your browser and navigate to:
```
http://your-proxmox-ip:19999
```

---

## Method 2: Manual Installation via APT

### Step 1: Add netdata repository
```bash
# Add the repository key
curl https://packages.netdata.cloud/repos/repoconfig-archive-archive-keyring-2023.gpg > /usr/share/keyrings/netdata-archive-keyring.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/netdata-archive-keyring.gpg] https://packages.netdata.cloud/repos/archive/debian stable bullseye" > /etc/apt/sources.list.d/netdata.list

# Update package list
apt update
```

### Step 2: Install netdata
```bash
# Install netdata
apt install netdata

# Enable and start the service
systemctl enable netdata
systemctl start netdata
```

---

## Method 3: Using Docker (Alternative approach)

If you prefer containerized deployment:

```bash
# Create a directory for netdata configuration
mkdir -p /opt/netdata/{config,lib,log,cache}

# Run netdata in a container
docker run -d --name=netdata \
  --pid=host \
  --network=host \
  --restart=unless-stopped \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /opt/netdata/config:/etc/netdata:rw \
  -v /opt/netdata/lib:/var/lib/netdata:rw \
  -v /opt/netdata/log:/var/log/netdata:rw \
  -v /opt/netdata/cache:/var/cache/netdata:rw \
  -e PUID=0 \
  -e PGID=0 \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  netdata/netdata:latest
```

---

## Configuration for Proxmox-specific Monitoring

### Enable Proxmox-specific collectors
Netdata should auto-detect many Proxmox components, but you can enhance monitoring:

#### 1. Monitor LXC containers and VMs
Netdata automatically detects containers, but for better VM monitoring, ensure the netdata agent is installed inside VMs as well.

#### 2. Configure ZFS monitoring (important for Proxmox)
```bash
# Check if ZFS monitoring is enabled
cat /etc/netdata/netdata.conf | grep zfs

# If you need to enable it manually, edit the config:
nano /etc/netdata/netdata.conf
```
Add or ensure these lines exist:
```
[plugin:zfs]
enabled = yes
update every = 5
```

#### 3. Monitor hardware sensors
```bash
# Install sensors for hardware monitoring
apt install lm-sensors

# Detect sensors
sensors-detect
```

### Firewall Configuration

If you have a firewall enabled, open port 19999:

```bash
# Using iptables (if enabled)
iptables -A INPUT -p tcp --dport 19999 -j ACCEPT

# Using ufw (if enabled)
ufw allow 19999/tcp
```

---

## Advanced Configuration

### Change default port (optional)
If you want to use a different port:

```bash
# Edit netdata configuration
nano /etc/netdata/netdata.conf

# Change the port
[web]
    bind to = 0.0.0.0:29999
```

Then restart netdata:
```bash
systemctl restart netdata
```

### Enable authentication (recommended for production)
```bash
# Enable basic authentication
nano /etc/netdata/netdata.conf

[web]
    allow connections from = *
    allow dashboard from = *
    allow badges from = *
    allow streaming from = *
    allow management from = localhost
    web files owner = root
    web files group = netdata
```

### Set up reverse proxy with Proxmox web interface (optional)
You can integrate netdata into the Proxmox web interface:

```bash
# Create a snippet for nginx
nano /etc/nginx/snippets/proxy-netdata.conf
```

Add:
```
location /netdata/ {
    proxy_pass http://127.0.0.1:19999/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_http_version 1.1;
    proxy_pass_request_headers on;
    proxy_set_header Connection "keep-alive";
    proxy_store off;
}
```

Then include it in your Proxmox nginx configuration.

---

## Verification and Testing

After installation:

1. **Access the dashboard**: `http://your-proxmox-ip:19999`
2. **Check system metrics**: Look for CPU, memory, disk I/O, and network stats
3. **Verify Proxmox-specific metrics**:
   - ZFS pool statistics
   - LXC container resource usage
   - VM performance metrics
   - Hardware sensor data (if available)

### Useful commands for management:
```bash
# Start/stop/restart netdata
systemctl start netdata
systemctl stop netdata
systemctl restart netdata

# Check logs
journalctl -u netdata -f

# Enable auto-start on boot
systemctl enable netdata
```

---

## Security Considerations

1. **Change default port** if exposing to the internet
2. **Set up authentication** for remote access
3. **Use firewall rules** to restrict access
4. **Consider VPN** for remote monitoring
5. **Regular updates**: Netdata auto-updates by default, but verify with `netdata-updater`

The automated script (Method 1) is generally the easiest and most reliable approach for Proxmox hosts. Netdata will automatically detect Proxmox's ZFS storage, LXC containers, and provide comprehensive system monitoring out-of-the-box.

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
