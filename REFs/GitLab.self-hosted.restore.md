# [GitLab omnibus : Restore from Backup](https://chatgpt.com/share/68118301-6484-8009-b970-264388b4ef83 "ChatGPT")

## Configure : `/etc/gitlab/gitlab.rb`

To stand up a temporary **GitLab self-hosted** instance (Omnibus) **just to test backup recovery**, 
the `gitlab.rb` can be minimized to only what’s needed to:

- Serve the web interface (even just on localhost)
- Restore from backup
- Avoid full TLS/DNS setup
- Avoid Pages, Registry, and other components unless you're testing them too

Here’s a **minimal working `gitlab.rb`** for localhost-based testing:

```ruby
# External URL – can be HTTP if TLS isn't required
external_url 'http://gitlab.test.local'

# Disable Let's Encrypt, since we're not using HTTPS
letsencrypt['enable'] = false

# Reduce unnecessary components
nginx['listen_https'] = false
nginx['redirect_http_to_https'] = false

# Optional: set a port if needed
# nginx['listen_port'] = 8080

# Disable other services you don’t need for a backup test
gitlab_rails['gitlab_pages_enabled'] = false
registry['enable'] = false
prometheus_monitoring['enable'] = false
grafana['enable'] = false
puma['worker_processes'] = 1

# Skip SMTP config if you don’t care about email
gitlab_rails['smtp_enable'] = false

# Use default PostgreSQL, Redis, etc. included in Omnibus
postgresql['enable'] = true
redis['enable'] = true
```

## Optional DNS & TLS Setup for `gitlab.test.local`

- **DNS**: Add to `/etc/hosts`:
  ```
  127.0.0.1 gitlab.test.local
  ```

- **TLS** (optional): Use self-signed certs only if testing HTTPS.
```ruby
external_url 'https://gitlab.test.local'
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.test.local.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.test.local.key"
```
- Generate self-signed:
```bash
sudo mkdir -p /etc/gitlab/ssl
sudo openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/gitlab/ssl/gitlab.test.local.key -out /etc/gitlab/ssl/gitlab.test.local.crt -days 365 -subj "/CN=gitlab.test.local"
sudo chmod 600 /etc/gitlab/ssl/*
```

Then run:
```bash
sudo gitlab-ctl reconfigure
```

After reconfiguring, restore your backup:
```bash
sudo gitlab-backup restore BACKUP=timestamp
```

And if needed, reset permissions:
```bash
sudo gitlab-rake gitlab:check SANITIZE=true
```


If you **disable GitLab's built-in NGINX** via:

```ruby
nginx['enable'] = false
```

Then GitLab **does not start its internal NGINX at all**, and **you are responsible** for TLS termination, routing, and proxying (e.g., using your own reverse proxy or testing via direct port).

But if you don’t explicitly disable it (`nginx['enable'] = false`), 
GitLab **Omnibus still manages NGINX**, and it **will handle TLS** if:

- `external_url` uses `https://`
- Or `nginx['listen_https'] = true` is set

So in your earlier minimal config, even with:

```ruby
nginx['listen_https'] = false
nginx['redirect_http_to_https'] = false
```

As long as `external_url` is `http://...`, **no TLS is used**, and NGINX serves plain HTTP.

If you do set `external_url` to `https://...` but forget to explicitly disable NGINX TLS, GitLab's NGINX will **try to serve HTTPS**, and if no cert is provided, it will error unless you use Let's Encrypt or generate self-signed ones.

### TL;DR

- `nginx['enable'] = false` → You must handle web serving and TLS yourself (e.g., via Apache, Traefik, or nothing).
- `nginx['enable']` unset or true + `external_url = 'http://...'` → GitLab's NGINX serves **HTTP only**.
- `nginx['enable']` unset or true + `external_url = 'https://...'` → GitLab's NGINX expects to serve **HTTPS** and needs certs configured.


## Verify

The **simplest way to verify projects are restored** after `gitlab-backup restore` is to:

---

### 1. **Check via Web UI (easiest)**
- Log in as root:  
  Default user is `root`, password is either:
    - From the original backup (if `/etc/gitlab/gitlab-secrets.json` was preserved), or
    - Reset via `gitlab-rails console` (see below).
- Browse to `http://<your_gitlab>/`  
- Verify:
    - Projects are listed on the dashboard.
    - Project pages load.
    - Files and commits are visible.
    - (Optional) Pipelines, issues, and merge requests show up.

---

### 2. **Reset root password if needed**
If you can’t log in:
```bash
sudo gitlab-rails console
```

```ruby
user = User.find_by_username('root')
user.password = 'newpassword'
user.password_confirmation = 'newpassword'
user.save!
```

---

### 3. **List projects via CLI**

```bash
sudo gitlab-rails runner "Project.all.each { |p| puts \"#{p.id}: #{p.full_path}\" }"
```

Or if you want to include visibility or repo size:

```bash
sudo gitlab-rails runner 'Project.all.each { |p| puts "#{p.full_path}, #{p.visibility_level}, #{p.statistics.repository_size}" }'
```

---

### 4. **Check repo content from shell**
You can inspect bare repositories restored under:

```
/var/opt/gitlab/git-data/repositories/<namespace>/<project>.git/
```

Example:
```bash
ls /var/opt/gitlab/git-data/repositories/mygroup/myproject.git/
```

---

Let me know if you're testing registry, pages, or CI/CD artifacts — they each require extra restore steps and paths.
---

<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->
