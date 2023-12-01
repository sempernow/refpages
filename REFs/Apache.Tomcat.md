# [Apache Tomcat](https://tomcat.apache.org/ "tomcat.apache.org") | [ChatGPT](https://chatgpt.com/share/681a895c-b8ec-8009-8417-cf83c59485e2)

Here's a **systemd unit file** to run a Tomcat 10+ instance 
(installed from tarball, e.g., in `/opt/tomcat`) 
as a service on RHEL-based systems:

---

### 🔧 Assumptions:

* Tomcat is installed at `/opt/tomcat`
* It runs as user `tomcat` (non-root)
* Java is properly installed and in `PATH` (e.g., OpenJDK 17)

---

### 1. **Create the Tomcat system user (no login shell)**

```bash
sudo useradd -r -M -U -s /bin/false tomcat
```

---

### 2. **Extract Tomcat and set ownership**

```bash
sudo tar -xzf apache-tomcat-10.*.tar.gz -C /opt
sudo mv /opt/apache-tomcat-10.* /opt/tomcat
sudo chown -R tomcat:tomcat /opt/tomcat

## Simple
#sudo semanage fcontext -a -t bin_t "/opt/tomcat(/.*)?"
#sudo restorecon -Rv /opt/tomcat
## Compliant
# Add policy lest certain policies already exist : See subsequent section(s) here 
sudo dnf install selinux-policy-targeted

sudo semanage fcontext -a -t tomcat_exec_t "/opt/tomcat/bin(/.*)?"
sudo semanage fcontext -a -t tomcat_var_run_t "/opt/tomcat/temp(/.*)?"
sudo semanage fcontext -a -t tomcat_cache_t "/opt/tomcat/work(/.*)?"
sudo semanage fcontext -a -t tomcat_log_t "/opt/tomcat/logs(/.*)?"
# Apply the labels
sudo restorecon -Rv /opt/tomcat
```

---

### 3. **Create the systemd unit file**

Save as:
`/etc/systemd/system/tomcat.service`

```ini
[Unit]
Description=Apache Tocat 10 Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
```

---

### 4. **Reload systemd and start Tomcat**

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now tomcat
```

---

### 5. **Test it**

```bash
curl http://localhost:8080/
```

---

## SELinux : Further considerations

The statement " `sudo dnf install selinux-policy-targeted`" is **safe and expected** in a STIG/FIPS-compliant RHEL environment—**as long as it's not already using an alternative policy like `selinux-policy-mls` or `selinux-policy-strict`**.

---

### ✅ What `selinux-policy-targeted` is:

* It is the **default SELinux policy** on RHEL systems, including:

  * RHEL 7, 8, and 9
  * CentOS, AlmaLinux, Rocky
* Provides **type enforcement** for the most common services (e.g., `httpd`, `tomcat`, `sshd`, etc.)
* Fully compatible with STIG/FIPS profiles when SELinux is in **enforcing** mode

---

### 🔍 Check your current SELinux policy:

```bash
sestatus | grep Policy
# Should say: SELinux policy from config file: targeted
```

Or check from config:

```bash
grep ^SELINUXTYPE= /etc/selinux/config
# SELINUXTYPE=targeted
```

---

### ⚠️ When to **avoid** installing this:

Only if your system uses a **non-default SELinux policy** like:

* `mls` (Multi-Level Security)
* `strict` (Very fine-grained, rarely used)
* A custom policy set by your security team

In those cases, installing `selinux-policy-targeted` could conflict or overwrite policy files.

---

### 🔐 Bottom line:

In a standard RHEL system aligned with STIG/FIPS and using the **default SELinux mode**, installing or reinstalling `selinux-policy-targeted` is:

* ✅ Safe
* ✅ Expected
* ✅ Auditable

## Provision using __Ansible__ 

A minimal, auditable **Ansible role** to install and configure **Apache Tomcat 10+** from a tarball in a **STIG/FIPS-compliant RHEL environment**, with SELinux context alignment and systemd integration.

---

### 🔧 Role: `roles/tomcat10/`

#### 📁 Directory Structure:

```
roles/
└── tomcat10/
    ├── tasks/
    │   └── main.yml
    ├── templates/
    │   ├── tomcat.service.j2
    └── vars/
        └── main.yml
```

---

### 📄 `vars/main.yml`

```yaml
tomcat_version: "10.1.27"
tomcat_user: "tomcat"
tomcat_group: "tomcat"
tomcat_home: "/opt/tomcat"
java_home: "/usr/lib/jvm/java-17-openjdk"
```

---

### 📄 `templates/tomcat.service.j2`

```ini
[Unit]
Description=Apache Tomcat 10 Web Application Container
After=network.target

[Service]
Type=forking

User={{ tomcat_user }}
Group={{ tomcat_group }}

Environment="JAVA_HOME={{ java_home }}"
Environment="CATALINA_PID={{ tomcat_home }}/temp/tomcat.pid"
Environment="CATALINA_HOME={{ tomcat_home }}"
Environment="CATALINA_BASE={{ tomcat_home }}"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

ExecStart={{ tomcat_home }}/bin/startup.sh
ExecStop={{ tomcat_home }}/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
```

---

### 📄 `tasks/main.yml`

```yaml
- name: Ensure required packages are installed
  package:
    name:
      - curl
      - tar
      - java-17-openjdk
      - policycoreutils-python-utils
      - selinux-policy-targeted
    state: present

- name: Create tomcat group
  group:
    name: "{{ tomcat_group }}"
    system: true

- name: Create tomcat user
  user:
    name: "{{ tomcat_user }}"
    group: "{{ tomcat_group }}"
    shell: /sbin/nologin
    home: "{{ tomcat_home }}"
    system: true
    create_home: false

- name: Download and extract Tomcat
  unarchive:
    src: "https://archive.apache.org/dist/tomcat/tomcat-10/v{{ tomcat_version }}/bin/apache-tomcat-{{ tomcat_version }}.tar.gz"
    dest: /opt
    remote_src: yes
    extra_opts: [--strip-components=1]
    creates: "{{ tomcat_home }}/bin/startup.sh"

- name: Ensure correct ownership
  file:
    path: "{{ tomcat_home }}"
    state: directory
    recurse: yes
    owner: "{{ tomcat_user }}"
    group: "{{ tomcat_group }}"

- name: Apply SELinux contexts
  sefcontext:
    target: "{{ item.path }}"
    setype: "{{ item.type }}"
    state: present
  loop:
    - { path: "{{ tomcat_home }}/bin(/.*)?", type: "tomcat_exec_t" }
    - { path: "{{ tomcat_home }}/temp(/.*)?", type: "tomcat_var_run_t" }
    - { path: "{{ tomcat_home }}/work(/.*)?", type: "tomcat_cache_t" }
    - { path: "{{ tomcat_home }}/logs(/.*)?", type: "tomcat_log_t" }

- name: Restore SELinux context
  command: "restorecon -Rv {{ tomcat_home }}"

- name: Deploy systemd service unit
  template:
    src: tomcat.service.j2
    dest: /etc/systemd/system/tomcat.service
    mode: '0644'

- name: Reload systemd and start Tomcat
  systemd:
    name: tomcat
    daemon_reload: yes
    enabled: yes
    state: started
```

---

### ✅ Usage in Playbook:

```yaml
- hosts: all
  become: true
  roles:
    - tomcat10
```

---

## Bash

Here is a **secure, air-gap–friendly Bash script** to install **Apache Tomcat 10+** in a **STIG/FIPS-compliant RHEL environment**, with:

* Offline install via pre-downloaded tarball
* Correct SELinux labels
* Secure systemd unit
* No internet access required during execution

---

### 🔧 1. **Prepare Your Offline Package Bundle**

#### Required files:

* Tomcat tarball (e.g., `apache-tomcat-10.1.27.tar.gz`)
* OpenJDK 17 RPMs (use `dnf download` with dependencies)
* Save the script below as `install_tomcat10.sh`

---

### 📝 `install_tomcat10.sh`

```bash
#!/bin/bash
set -euo pipefail

# CONFIG
TOMCAT_VER="10.1.27"
TOMCAT_TARBALL="apache-tomcat-${TOMCAT_VER}.tar.gz"
TOMCAT_DIR="/opt/tomcat"
TOMCAT_USER="tomcat"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk"

# Validate inputs
if [[ ! -f "$TOMCAT_TARBALL" ]]; then
  echo "❌ Missing $TOMCAT_TARBALL in current directory."
  exit 1
fi

echo "📦 Installing required packages from local RPMs..."
dnf install -y ./java-17-openjdk-*.rpm ./selinux-policy-targeted*.rpm ./policycoreutils-python-utils*.rpm

echo "👤 Creating tomcat user/group..."
useradd -r -M -U -s /sbin/nologin -d "$TOMCAT_DIR" "$TOMCAT_USER" || true

echo "📁 Installing Tomcat to $TOMCAT_DIR..."
rm -rf "$TOMCAT_DIR"
mkdir -p "$TOMCAT_DIR"
tar -xf "$TOMCAT_TARBALL" --strip-components=1 -C "$TOMCAT_DIR"
chown -R "$TOMCAT_USER:$TOMCAT_USER" "$TOMCAT_DIR"

echo "🔒 Configuring SELinux contexts..."
semanage fcontext -a -t tomcat_exec_t "${TOMCAT_DIR}/bin(/.*)?"
semanage fcontext -a -t tomcat_var_run_t "${TOMCAT_DIR}/temp(/.*)?"
semanage fcontext -a -t tomcat_cache_t "${TOMCAT_DIR}/work(/.*)?"
semanage fcontext -a -t tomcat_log_t "${TOMCAT_DIR}/logs(/.*)?"
restorecon -Rv "$TOMCAT_DIR"

echo "🛠️ Creating systemd unit..."
cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat 10 Web Application Container
After=network.target

[Service]
Type=forking
User=${TOMCAT_USER}
Group=${TOMCAT_USER}
Environment="JAVA_HOME=${JAVA_HOME}"
Environment="CATALINA_PID=${TOMCAT_DIR}/temp/tomcat.pid"
Environment="CATALINA_HOME=${TOMCAT_DIR}"
Environment="CATALINA_BASE=${TOMCAT_DIR}"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"
ExecStart=${TOMCAT_DIR}/bin/startup.sh
ExecStop=${TOMCAT_DIR}/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "🚀 Enabling and starting Tomcat..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now tomcat

echo "✅ Tomcat ${TOMCAT_VER} installed and running on port 8080."
```

---

### 📦 Packaging for Transfer

On a connected machine:

```bash
mkdir tomcat-offline && cd tomcat-offline
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.27/bin/apache-tomcat-10.1.27.tar.gz
dnf download --resolve java-17-openjdk selinux-policy-targeted policycoreutils-python-utils
cp /path/to/install_tomcat10.sh .
tar czf tomcat10-offline-bundle.tar.gz *
```

Transfer the `.tar.gz` to your target and extract it, then:

```bash
sudo bash install_tomcat10.sh
```

---

## Post-install checks 

Verify SELinux context / run OpenSCAP


Here is a **companion script** to verify the **SELinux context**, **systemd unit status**, and optionally run a **SCAP scan** (if tools are installed) to validate that your air-gapped Tomcat installation meets STIG/FIPS expectations.

---

### 🧪 `verify_tomcat10.sh`

```bash
#!/bin/bash
set -euo pipefail

TOMCAT_DIR="/opt/tomcat"
TOMCAT_USER="tomcat"
EXPECTED_TYPES=(
  "tomcat_exec_t:${TOMCAT_DIR}/bin"
  "tomcat_var_run_t:${TOMCAT_DIR}/temp"
  "tomcat_cache_t:${TOMCAT_DIR}/work"
  "tomcat_log_t:${TOMCAT_DIR}/logs"
)

echo "🔎 Verifying SELinux context assignments..."
fail=0
for pair in "${EXPECTED_TYPES[@]}"; do
  type=${pair%%:*}
  path=${pair#*:}
  actual=$(ls -Zd "$path" | awk '{print $1}')
  if [[ "$actual" != "$type" ]]; then
    echo "❌ $path has incorrect SELinux type: $actual (expected $type)"
    fail=1
  else
    echo "✅ $path is labeled correctly: $type"
  fi
done

[[ $fail -eq 0 ]] || { echo "❌ SELinux context check failed."; exit 1; }

echo "📡 Checking Tomcat systemd service..."
if ! systemctl is-enabled --quiet tomcat; then
  echo "❌ Tomcat service is not enabled"
  exit 1
fi

if ! systemctl is-active --quiet tomcat; then
  echo "❌ Tomcat service is not active"
  journalctl -u tomcat --no-pager -n 20
  exit 1
fi
echo "✅ Tomcat service is enabled and active."

echo "🧪 Running optional SCAP compliance scan (if available)..."
if command -v oscap &>/dev/null; then
  profile="xccdf_org.ssgproject.content_profile_stig"
  datastream="/usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml"

  if [[ -f "$datastream" ]]; then
    oscap xccdf eval \
      --profile "$profile" \
      --results "tomcat-scap-results.xml" \
      --report "tomcat-scap-report.html" \
      "$datastream"
    echo "✅ SCAP scan completed. Report: tomcat-scap-report.html"
  else
    echo "⚠️ SCAP content not found at $datastream"
  fi
else
  echo "ℹ️ OpenSCAP (oscap) not installed; skipping scan."
fi
```

---

### 📦 Optional Dependencies:

Install these **on a connected host** and copy RPMs for offline use:

```bash
dnf download --resolve scap-security-guide openscap-scanner
```

On target host:

```bash
sudo dnf install ./scap-security-guide*.rpm ./openscap-scanner*.rpm
```

---

### 📜 Output:

* Shows current SELinux context validation
* Prints systemd status
* Optionally generates:

  * `tomcat-scap-report.html` — human-readable report
  * `tomcat-scap-results.xml` — machine-readable results

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
