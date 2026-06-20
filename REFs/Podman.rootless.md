# Rootless Podman

>Provision a Podman environment for unprivileged, non-local (AD) users on RHEL.


## UPDATE 2026

Podman rootless is compatible with Active Directory (AD) domain users, 
but it **requires manual configuration of user mappings**. 

Because rootless containers rely on Linux user namespaces to map container IDs to host IDs, 
you must explicitly assign a range of subordinate UIDs and GIDs to each AD user. 

Active Directory and LDAP don't natively populate Linux's /etc/subuid and /etc/subgid files upon user login. This requires several specific configuration steps. [5, 6] 
### The Problem with Remote Users

Rootless Podman uses the `newuidmap` and `newgidmap` utilities, which look at `/etc/subuid` and `/etc/subgid` to allocate ID mappings. Because non-local AD users authenticate dynamically (often via SSSD), their records aren't permanently written to local system files like `/etc/passwd` or `/etc/shadow` by default.

### How to Make it Work

   1. Assign Subordinate ID Ranges:
   You must manually create entries in /etc/subuid and /etc/subgid for your domain users. The syntax assigns a range (e.g., $65,536$ IDs) to an AD username:
   ```bash
   ad_username:100000:65536
   ```
   2. Automating the Setup (Recommended for Scale):
   Manually tracking AD users is unmanageable at scale. Administrators usually automate this by writing scripts to dynamically populate /etc/subuid and /etc/subgid using a PAM (Pluggable Authentication Module) script (like pam_exec.so) when a domain user logs in.
   3. Using SSSD Central Management (Enterprise Environments):
   If you are using FreeIPA alongside AD, central subordinate ID management is natively available. You can use SSSD plugins to retrieve UID/GID ranges centrally without modifying local /etc/sub* files on every machine. [1, 5, 6, 10, 11, 12] 

### Key Limitations to Keep in Mind

* Network File Systems (NFS) Homes: Network file systems don't generally support Linux user namespaces. If your AD domain users mount home directories from a remote file server (NFS), rootless Podman will fail unless the graphroot is re-configured to local storage.

* The Single-Mapping Fallback: If an AD user isn't assigned ranges in /etc/subuid, Podman will default to a "single mapping into the namespace". This allows basic commands to work but will throw errors during complex actions (like running images that require container-internal root access or volume ownership changes). 

### Managing subids

`pam_exec.so` is a generic execution tool 
that runs a custom script of your choice during user login.

To handle unique subID provisioning, 
the custom script must contain 
the math and logic to calculate unique ranges 
and write them to `/etc/subuid` and `/etc/subgid`.

#### How to use pam_exec.so for provisioning

To automate this, you must combine pam_exec.so with a custom script.

- 1. Add `pam_exec.so` to your PAM stack:
   Add this line to your PAM configuration file 
   (such as `/etc/pam.d/system-auth` or `/etc/pam.d/password-auth`):
   ```bash
   session optional pam_exec.so /usr/local/bin/provision_subids.sh
   ```
- 2. Write a custom provisioning script:
   Your script must read the incoming `$PAM_USER` variable, ensure they do not already have an entry, calculate a unique starting ID, and append it to the files.

#### Example Provisioning Script

This basic script calculates a unique subID range 
based on the user's existing Active Directory UID 
to guarantee uniqueness across the domain.

```bash
#!/bin/bash

# Exit if the user is root or already has subuids configured
if [ "$PAM_USER" = "root" ] || grep -q "^${PAM_USER}:" /etc/subuid; then
    exit 0
fi

# Get the user's AD/SSSD UID
USER_UID=$(id -u "$PAM_USER" 2>/dev/null)
if [ -z "$USER_UID" ]; then
    exit 0
fi

# Math formula: Use a large offset to prevent overlapping local IDs
# e.g., UID 10005 becomes SubUID 1000500000 (allocating 65,536 IDs)
SUB_ID_START=$(( USER_UID * 100000 ))
RANGE=65536

# Append uniquely to both files
echo "${PAM_USER}:${SUB_ID_START}:${RANGE}" >> /etc/subuid
echo "${PAM_USER}:${SUB_ID_START}:${RANGE}" >> /etc/subgid
```

#### Better Alternative: Modern Linux Solutions

Instead of writing custom scripts with `pam_exec.so`, 
newer systems offer **cleaner ways to handle remote users**:

* `shadow-utils` with SSSD (Modern RHEL/Fedora/Ubuntu): 
    Modern versions of `newuidmap` can query SSSD directly if configured.
* `systemd-homed:` Dynamically manages user namespaces and subIDs for users on demand.

--- 

# Prior Work

## Overview

There are many corners to this envelope:

- Lacking privilege, a per-user (rootless) configuration is required:
    - Podman does not configure remote (AD) users.
    - Podman creates per-user namespaces using subids only if
      user is local, regular (non-system), and created after Podman is installed.
    - An active fully-provisioned login shell is required to initialized a rootless Podman session.
        - `HOME` is set.
        - `XDG_RUNTIME_DIR` is set.
        - DBus Session Bus starts.
            - Provides user-level IPC.
    - Linux system users, "`adduser --system ...`",
      are not provisioned an active login shell, regardless.
    - Containers running under a rootless process do not survive the user session unless
      Linger is enabled for that user: `sudo loginctl enable-linger <username>`.
        - Also required for Podman's systemd integration schemes.
    - The per-user subid ranges (`subuid`, `subgid`) must be unique per host.
- Workarounds for AD users (__`$USER`__) is to provision a
  logically-mapped __local user__ (__`podman-$USER`__)
  to serve as their Podman service account:
    1. __No login shell__ (`adduser --shell /sbin/nologin ...`)
        - To provide a full functional rootless Podman environment,
          these environment settings must be __explicitly declared__:
            ```bash
            cd /tmp
            sudo -u podman-$USER -- env \
                HOME=/home/podman-$USER \
                XDG_RUNTIME_DIR=/run/user/$(id -u podman-$USER) \
                DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u podman-$USER)/bus \
                podman ...
            ```
            - [`podman.sh`](per-user/podman.sh)
            - Tight security by locking down allowed commands using a group-scoped sudoers drop-in file.
                - [`provision-podman-sudoers.sh`](per-user/provision-podman-sudoers.sh)
    2. __Login shell__ (`adduser --shell /bin/bash ...`)
        - Using SSH shell to trigger an active login session,
        which provides a __fully functional__ rootless Podman environment.
            ```bash
            ssh -i $key podman-$USER@localhost [podman ...]
            ```
            - Secure by locked password, so AuthN/AuthZ is *exclusively* by SSH key/tunnel.

- Privileged ports, e.g., 80 (HTTP) and 443 (HTTPS), are not allowed.

## Local-user Service Account (per AD user)

### 1. __No login shell__

To allow for self-provisioning, the AD user must be member of `podman-sudoers` group,
which may be either AD or local.

#### Admin

```bash
sudo install.sh
```

- [`podman-provision-sudoers.sh`](per-user/podman-provision-sudoers.sh)
- [`podman-provision-nologin.sh`](per-user/podman-provision-nologin.sh)
- [`podman-unprovision-user.sh`](per-user/podman-unprovision-user.sh)
- [`podman.sh`](per-user/podman.sh)

#### User(s)

Users must be member of the group declared in the apropos group-scoped sudoers file that allows such access.

1. Self provision a fully-functional rootless Podman environment
    ```bash
    u0@a0 # unprivileged user
    ☩ sudo podman-provision-nologin.sh
    ```
1. Use it to run Podman commands
    ```bash
    u0@a0 # unprivileged user
    ☩ podman run --rm --volume $work:/mnt/home alpine sh -c '
        echo $(whoami)@$(hostname -f)
        umask 002
        rm -f /mnt/home/test-write-access-*
        ls -hl /mnt/home
        touch /mnt/home/test-write-access-$(date -u '+%Y-%m-%dT%H.%M.%SZ')
        ls -hl /mnt/home
    '
    root@65f76044ffcb
    total 0
    total 0
    -rw-rw-r--    1 root     root     0 ... test-write-access-2025-05-11T19.08.32Z

    ☩ ls /work/podman/home/u0
    total 0
    -rw-rw-r--. 1 podman-u0 podman-u0 0 ... test-write-access-2025-05-11T19.08.32Z

    ☩ ls -n /work/podman/home/u0
    total 0
    -rw-rw-r--. 1 50004 50004 0         ... test-write-access-2025-05-11T19.08.32Z
    ```
    - Podman rootless : The `root` user of container is *not* `root` at host,
      but rather maps to host user (`podman-u0`) who ran the command.

### 2. __Login shell__

TODO

## ❌ Common Service Account

>A common service account for multiple developers running rootless Podman is technically possible,
>but **collisions and subtle failures are highly likely**,
>and **increase rapidly with team size** and intensity of usage.

---

### ⚠️ **Key Problems with a Shared Podman Account**

Rootless Podman heavily relies on **per-user namespaces**, **cgroups**, and **runtime directories** that are not designed for concurrent use by multiple interactive users under a shared UID.

Here’s a breakdown of what can and will go wrong:

---

#### 1. **Shared XDG\_RUNTIME\_DIR**

By default, rootless Podman uses:

```
$XDG_RUNTIME_DIR = /run/user/$(id -u)
```

In a shared account, everyone has the **same UID**, so they share `/run/user/1001`, for example.

* Podman creates UNIX domain sockets here (e.g., `/run/user/1001/podman/podman.sock`)
* `systemd` user services are also tied to this directory

**Collision symptoms:**

* One user kills or restarts the Podman socket, interrupting others
* Containers show up across sessions (even when they shouldn’t)
* Podman client fails to connect because the socket is in use or misowned

---

#### 2. **Volume, Image, and Container Name Clashes**

All container objects are stored in a single namespace (under that user’s `$HOME/.local/share/containers` or `/var/tmp/containers/...`).

**Collision symptoms:**

* Containers and volumes have non-unique names
* Conflicting ports (e.g., two users both try to run something on `localhost:8080`)
* One user’s `podman rm` or `podman volume rm` breaks another’s environment

---

#### 3. **File Ownership and Permissions**

Files written by Podman in shared directories (volumes, mounts, container data) are owned by **the service account**, not the real invoking user.

This means:

* Users can accidentally delete or modify each other’s data
* There is **no meaningful ownership enforcement** unless you wrap every command in sandboxing (like `sudo -u`, namespaces, ACLs)

---

#### 4. **Trouble with `loginctl` / lingering**

Even if `loginctl enable-linger podmaners` is active, only **one instance** of the user service is assumed to be running.

If multiple users:

* Try to run `podman system service` in the background (e.g., for CLI clients)
* Use `podman generate systemd` and launch containers on login

You'll encounter unpredictable behavior or crashes.

---

#### 5. **Security and Auditing**

* Logs show actions as `podmaners`, not the real user
* There’s no accountability unless you manually inject tracing (e.g., `sudo -u podmaners --preserve-env=REAL_USER=alice`)
* A compromised Podman container or build process could access another developer’s mounts or data

---

### 🛑 Bottom Line: **Shared Account Not Viable at Scale**

> For **one-off automation or tightly scripted CI/CD tasks**, a shared rootless Podman account might work.

> But for **interactive, multi-user development**, it's **fragile, unsafe, and increasingly error-prone**.

---

### ✅ Recommended Alternative for \~12 Developer Team

Provision **a dedicated Podman service account per developer**, either:

* ~~**Mapped from AD** (e.g., `jdoe@domain` → `podman-jdoe`)~~
    - Not viable; Podman does not recognize AD users,
      so namespaces (subid assignments) would have to be managed.
* Or **locally created accounts** named after users (`podman-alice`, `podman-bob`, etc.)

And provision:

* `/etc/subuid` and `/etc/subgid` entries
* `loginctl enable-linger`
* Proper SELinux `restorecon` on home dir
* Optionally restrict shell access and use `sudo -u` or `ssh` as interface

---

## `su` vs `sudo -u`

### **Shell Requirements: `su` vs `sudo -u`**

| **Command**           | **Requires Login Shell?** | **Works with `nologin`?** | **Best For** |
|-----------------------|---------------------------|---------------------------|--------------|
| `su - $name`          | ✅ **Yes** (`/bin/bash`)  | ❌ No (`nologin` fails)  | Interactive sessions |
| `sudo -u $name`       | ❌ **No**                 | ✅ Yes (ignores shell)   | __Service accounts__ |

Where `$name` is that of the Podman (service) account common to all users.

---

### **Key Differences**

#### **1. `su` (Switch User)**
- **Requires a valid login shell** (e.g., `/bin/bash`, `/bin/sh`)
- **Fails if shell is `/sbin/nologin` or `/bin/false`**:
    ```bash
    su - podmaners  # Error: "This account is currently not available."
    ```
- **Bypass (temporarily, not recommended)**:
    ```bash
    sudo su -s /bin/bash podmaners  # Force shell
    ```

#### **2. `sudo -u` (Run as User)**
- **Ignores the user's shell** – works even with `/sbin/nologin`
- **Ideal for service accounts**:
    ```bash
    sudo -u podmaners podman info  # Works!
    ```
- **Logs commands** in `/var/log/secure` (better auditing).

---

### **Why This Matters for Podman Service Accounts**
- **Security**: Service accounts should **never** have a shell (`/sbin/nologin`).
- **Podman needs `sudo -u`**:
    ```bash
    # Correct way to run Podman as a service account
    sudo -u podmaners podman run --rm alpine echo "Hello"
    ```
- **`su` breaks security**: Giving a shell to `podmaners` defeats the purpose of a service account.

---

### **Best Practices**
1. **Always use `sudo -u` for service accounts**:
    ```bash
    sudo -u podmaners podman [command]
    ```
2. **Never change `nologin` to `bash`**:
    ```bash
    # ❌ Dangerous (don't do this!)
    sudo usermod -s /bin/bash podmaners
    ```
3. **If you need debugging**:
    ```bash
    # Temporary shell (avoid unless necessary)
    sudo -u podmaners bash -c 'whoami && podman info'
    ```

---

### **Example: Secure Podman Setup**
```bash
# Create service account (no shell, no home dir)
sudo useradd -r -s /sbin/nologin -d /var/empty podmaners

# Verify
sudo -u podmaners podman info  # ✅ Works
su - podmaners                 # ❌ Fails (as intended)
```

---

### **Final Answer**
✅ **Use `sudo -u podmaners`** – it bypasses shell checks and is secure.
❌ **Avoid `su` for service accounts** – it requires a shell and weakens security.

Need to debug a `nologin` account? Use:

```bash
sudo -u podmaners bash -c '[commands]'  # Temporary exception
```


### Further Comparison


### 🔹 **Scheme A: `sudo -u podmaners podman`**

Users invoke Podman indirectly:

* The service account has **no shell** (`/sbin/nologin`)
* User is granted `sudo` rights to run commands **as `podmaners`**, with a tightly scoped `sudoers` rule:
    ```bash
    joe ALL=(podmaners) NOPASSWD: /usr/bin/podman *
    ```
* No interactive session is allowed for `podmaners`

---

### 🔹 **Scheme B: `ssh podmaners@localhost`**

Users invoke Podman interactively:

* The `podmaners` account has a shell (e.g., `/bin/bash`)
* The password is **locked**
* Only public key access is allowed (users’ SSH keys placed in `~podmaners/.ssh/authorized_keys`)
* Users `ssh` into the account and run Podman normally

---

### 🔒 **Security Comparison**

| Feature                       | Scheme A: `sudo -u`                                                        | Scheme B: `ssh localhost`                                                            |
| ----------------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| **Access Surface**            | Limited to `podman` command via `sudoers`                                  | Full interactive shell if not further restricted                                     |
| **User Auditing**             | Logs `sudo` invocations (audit trail)                                      | Harder to attribute actions to specific users without per-key `command=` restriction |
| **Privilege Escalation Risk** | Low, if `sudoers` is tight                                                 | Higher — any bug or misconfigured shell environment might be exploitable             |
| **Isolation Between Users**   | Weak — shared user means shared state (UID, XDG\_RUNTIME\_DIR, containers) | Same weakness unless separate users are used                                         |
| **User Convenience**          | Scriptable but less flexible                                               | Fully interactive; user can run shell + Podman tooling                               |
| **SELinux Compatibility**     | Controlled by calling user (via `sudo`)                                    | Depends on SSH session context; easier to misconfigure SELinux domains               |
| **Revocation**                | Simple — remove sudoers line                                               | Must remove user’s SSH key manually                                                  |

---

### 🔐 Verdict: **Scheme A is more secure by default**

> **Why:**

* It **limits users to exactly one binary** (Podman) under a shared account.
* No interactive shell or login session is allowed.
* Actions are **logged in `sudo` logs** with the invoking user’s identity.
* It respects privilege separation better and is **easier to audit and revoke**.

---

### 🛠️ If You Must Use Scheme B (SSH):

* Use per-user SSH keys with `command=` in `authorized_keys`, e.g.:

    ```bash
    command="/usr/bin/podman $SSH_ORIGINAL_COMMAND",no-agent-forwarding,no-pty ssh-rsa AAAAB3... user@domain
    ```
* Lock down the shell with:

    ```bash
    chsh -s /sbin/nologin podmaners
    ```

  and use `ForceCommand` in `sshd_config`:

    ```bash
    Match User podmaners
      ForceCommand /usr/bin/podman
      PermitTTY no
      AllowTcpForwarding no
    ```
* Monitor logs to track usage.

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
