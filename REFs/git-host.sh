#!/usr/bin/env bash
#######################################
# Configure this host as a Git server
# - RHEL/SELinux is expected
# - Idempotent
#######################################
[[ "$(id -u)" -ne 0 ]] && {
    echo "❌  ERR : Run as root" >&2

    exit 11
}
type -t git ||
    dnf install -y git

mkdir -p /srv
home=/srv/git

# Create git user and group if not already
id git ||
    adduser --system --shell /usr/bin/git-shell --create-home --home-dir $home git
    # --system: system account (UID < 1000)
    # --shell git-shell: disables login shell, and restricts SSH to server-side Git commands only.
    # --home-dir /home/git : Sets user's HOME dir

# Configure a non-standard HOME ($home) for git (user) that SELinux treats as it would those of /home
seVerifyHome(){
    ## Verify SELinux fcontext EQUIVALENCE
    semanage fcontext --list |grep "$1" |grep "$1 = /home"
}
export -f seVerifyHome
seVerifyHome $home || {
    ## Force SELinux to accept SELinux declarations REGARDLESS of current state of SELinux objects at target(s)
    semanage fcontext --delete "$home(/.*)?" 2>/dev/null # Delete all rules; is okay if no rules exist.
    restorecon -Rv $home # Apply the above purge (now).
    ## Declare SELinux fcontext EQUIVALENCE : "$home = /home"
    semanage fcontext --add --equal /home $home
    restorecon -Rv $home # Apply the above rule (now).
}

# Configure the repos store and SSH dir
mkdir -p $home/{repos,.ssh}
chmod 700 $home/.ssh
touch $home/.ssh/authorized_keys
chmod 600 $home/.ssh/authorized_keys
chown -R git:git $home

ls -hlZ $home
tree -L 2 $home

echo '
  ℹ  USAGE:

  🚧 Add client key(s)
      
      sudo -u git cat $public_key_of_client >> ~/.ssh/authorized_keys

  🚧 Add repo(s)

      sudo -u git git init --bare    /srv/git/repos/$repo.git         # New, empty repo
      sudo -u git git clone --bare   https://example.com/$repo.git    # Existing repo : Start fresh
      sudo -u git git clone --mirror https://example.com/$repo.git    # Existing repo : Backup/Migrate/Sync

  🚀 Access Remotely

      ssh -T git@$host "git --version"                  # Smoke test access 
      git ls-remote git@$host:/srv/git/repos/$repo.git  # List content
      git clone git@$host:repos/$repo.git      # Clone repo from the host (origin)
      
'

exit 
####

## How to configure /srv/git/repos as root dir, so clients' project paths are git://$host/a1.git

# @ Git : git://$host/prj.git
# This transport ignores GIT_PROJECT_ROOT, so must configure --base-path :
# Create and configure a git daemon (systemd) service
# (To configure host as read-only, remove option: --enable=receive-pack)
repos=/srv/git/repos # Git projects' root directory
sudo mkdir -p $repos
sudo dnf install -y git-daemon
systemd=/etc/systemd/system
sudo mkdir -p $systemd
sudo tee $systemd/git-daemon.service <<EOH
[Unit]
Description=Start Git Daemon
After=network.target

[Service]
ExecStart=/usr/bin/git daemon \
    --reuseaddr \
    --base-path=$repos \
    --export-all \
    --verbose \
    --enable=receive-pack
Restart=always
User=git
Group=git
WorkingDirectory=$repos

[Install]
WantedBy=multi-user.target
EOH

sudo systemctl daemon-reload
sudo systemctl enable --now git-daemon

# @ SSH : git@host:/prj.git
# Method 1. Set GIT_PROJECT_ROOT
# This is FAILing : the environment is ignored by git-shell regardless
dir=/etc/ssh/sshd_config.d
sudo mkdir -p $dir
repos=/srv/git/repos # Git projects' root directory
sudo tee $dir/git.conf <<EOH
PermitUserEnvironment yes
Match User git
    PermitTTY no
    SetEnv GIT_PROJECT_ROOT=$repos
EOH
sudo systemctl daemon-reload
sudo systemctl reload sshd
#ForceCommand export GIT_PROJECT_ROOT=$repos; $(which git-shell) -c "\$SSH_ORIGINAL_COMMAND"
#ForceCommand bash -c 'export GIT_PROJECT_ROOT=/srv/git/repos; if [ -n "$SSH_ORIGINAL_COMMAND" ]; then git-shell -c "$SSH_ORIGINAL_COMMAND"; else git-shell; fi'
# Method 2. Create symlink to git's HOME for each repo : Rerun per repo creation
sudo find /srv/git/repos -mindepth 1 -maxdepth 1 -type d -exec /bin/bash -c '
    sudo -u git ln -sf $1 /srv/git/${1##*/}
' _ {} \;

# @ HTTPS
sudo dnf install -y httpd mod_ssl git-core
# Apache config
sudo tee /etc/httpd/conf.d/git.conf <<'EOF'
# Git over HTTPS
SetEnv GIT_PROJECT_ROOT /srv/git/repos
SetEnv GIT_HTTP_EXPORT_ALL

ScriptAlias / /usr/libexec/git-core/git-http-backend/

<Directory "/usr/libexec/git-core">
    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
    Require all granted
</Directory>

# Protect access by requiring authentication
<LocationMatch "^/.*/git-receive-pack$">
    AuthType Basic
    AuthName "Git Access"
    AuthUserFile /etc/httpd/conf/git.passwd
    Require valid-user
</LocationMatch>
EOF

# Alt
sudo dnf update
sudo dnf install -y httpd mod_ssl git-core
sudo dnf install -y policycoreutils-python-utils # For SELinux management

sudo tee /etc/httpd/conf.d/git.conf <<'EOH'
# Git HTTPS Virtual Host Configuration
<VirtualHost *:443>
    ServerName repos.lime.lan
    ServerAdmin admin@lime.lan
    DocumentRoot /srv/git/repos

    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/yourdomain.crt
    SSLCertificateKeyFile /etc/pki/tls/private/yourdomain.key
    SSLCertificateChainFile /etc/pki/tls/certs/yourdomain-chain.crt

    # Git-specific settings
    SetEnv GIT_PROJECT_ROOT /srv/git/repos
    SetEnv GIT_HTTP_EXPORT_ALL
    ScriptAlias / /usr/libexec/git-core/git-http-backend/

    # Authentication (optional)
    <Location />
        AuthType Basic
        AuthName "Git Repository"
        AuthUserFile /etc/httpd/conf/git.htpasswd
        Require valid-user
    </Location>

    # Allow larger file uploads for Git
    LimitRequestBody 104857600

    # Logging
    ErrorLog /var/log/httpd/git-https-error.log
    CustomLog /var/log/httpd/git-https-access.log combined
</VirtualHost>

# Redirect HTTP to HTTPS
<VirtualHost *:80>
    ServerName repos.lime.lan
    Redirect permanent / https://repos.lime.lan/
</VirtualHost>
EOH


sudo systemctl enable --now httpd

# firewalld : Allow HTTPS service
sudo firewall-cmd --permanent --add-service=https --zone=public
sudo firewall-cmd --reload
# SELinux : Allow httpd to read/write repos
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/srv/git/repos(/.*)?"
sudo restorecon -Rv /srv/git/repos
# AuthN
sudo htpasswd -c /etc/httpd/conf/git.passwd $user1
# (will prompt for password)
sudo htpasswd    /etc/httpd/conf/git.passwd $user1
# TLS
sudo openssl req -new -x509 -days 365 \
  -keyout /etc/pki/tls/private/git.key \
  -out /etc/pki/tls/certs/git.crt
sudo chmod 600 /etc/pki/tls/private/git.key
