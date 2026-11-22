# GitLab on-prem Backups

```bash
/opt/gitlab/bin/gitlab-backup create
```

## @ `/etc/gitlab/gitlab.rb`

```ruby
gitlab_rails['manage_backup_path'] = true
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
gitlab_rails['backup_archive_permissions'] = 0640 # Permissions on backup tar file
gitlab_rails['backup_keep_time'] = 604800 # Purge older than 7 days
gitlab_rails['backup_exclude'] = ['artifacts', 'lfs', 'uploads'] # Optional excludes
```

Backup parameters in `/etc/gitlab/gitlab.rb` strictly configure **how** backups are created when the `gitlab-backup` command is run (e.g., paths, retention policy, exclusions), but **they do not configure any schedule**. There is **no internal scheduler** within GitLab Omnibus for backups.

Backups must be scheduled **externally**.
There are only a few possible mechanisms to initiate backups from the host.

#### ✅ 1. **Cron Job**

Check for system cron jobs:

```bash
sudo crontab -l
sudo crontab -u git -l
sudo crontab -u gitlab -l
grep -r gitlab-backup /etc/cron*
```

Look also in:

```bash
/etc/cron.daily/
/etc/cron.d/
/var/spool/cron/
```

#### ✅ 2. **Systemd Timer**

Check for a systemd timer:

```bash
systemctl list-timers --all | grep gitlab
grep -r gitlab-backup /etc/systemd/system/
```

GitLab does **not** ship with a built-in timer,
but a local admin might have added one.

#### ✅ 3. **Manual Script (Ansible/Puppet)**

Look for automation artifacts:

```bash
grep -r gitlab-backup /root /home /opt/gitlab /etc
```

Sometimes backups are triggered by infrastructure tools like Ansible or Puppet via `gitlab-backup create`.

#### ✅ 4. **User activity or `at` command**

Check command logs and history:

```bash
last -f /var/log/wtmp
cat ~/.bash_history | grep gitlab-backup
atq
```

---


# Schedule App Backups

A complete, ready-to-use **systemd timer + service** pair to automate **GitLab Omnibus backups** on an air-gapped or standard Linux host.

---

## ✅ 1. Create the Service Unit

**File:** `/etc/systemd/system/gitlab-backup.service`

```ini
[Unit]
Description=Create GitLab Backup
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/gitlab/bin/gitlab-backup create
User=root
Group=root
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=6
```

---

## ✅ 2. Create the Timer Unit

**File:** `/etc/systemd/system/gitlab-backup.timer`

```ini
[Unit]
Description=Daily GitLab Backup at 2:30 AM

[Timer]
OnCalendar=*-*-* 02:30:00
Persistent=true
AccuracySec=5min

[Install]
WantedBy=timers.target
```

* `Persistent=true` ensures it runs if the system was off at the scheduled time.
* `AccuracySec=5min` is optional but adds some flexibility for scheduling.

---

## ✅ 3. Reload and Enable

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now gitlab-backup.timer
```

---

## ✅ 4. Check Timer Status

```bash
systemctl list-timers --all | grep gitlab-backup
```

You should see output like:

```
gitlab-backup.timer  loaded active waiting   Sun 2025-05-08 02:30:00 EDT ...
```

---

## ✅ 5. View Logs

Use journalctl for logs:

```bash
journalctl -u gitlab-backup.service
```

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
