# GitLab omnibus upgrade unhealthy

GitLab omnibus is in unhealthy state three days after upgrade from 17.8 to 18.0, with over 500,000 failed background jobs and gitlab-rake advising "... git bundle ... db:migrate". The command sudo -u git bundle ...  fails by what appears a file owner/access issue, "rake ... not found". This is production service used by devs. What is advised recovery strategy from here?


Critical situation — production GitLab Omnibus 18.0 with a large backlog of background jobs and incomplete migration post-upgrade. 

Here's a focused and staged **recovery strategy**:

---

### 🔍 Step 1: **Assess Current State and Log Everything**

1. **Confirm GitLab health checks**:

   ```bash
   sudo gitlab-rake gitlab:check SANITIZE=true
   sudo gitlab-rake gitlab:env:info
   ```

2. **Identify which background jobs are failing**:

   ```bash
   sudo gitlab-rake sidekiq:queue_stats
   ```

3. **Check logs**:

   ```bash
   tail -n 100 /var/log/gitlab/gitlab-rails/sidekiq.log
   tail -n 100 /var/log/gitlab/gitlab-rails/production.log
   ```

---

### ⚠️ Step 2: **Diagnose the `rake ... not found` Error**

This implies your `PATH` or `BUNDLE_GEMFILE` is not correctly set, usually due to:

* Running the command as the wrong user
* Not using the correct GitLab environment

#### ✅ Use this pattern to ensure correct context:

```bash
sudo gitlab-rake db:migrate
```

or

```bash
sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production
```

If `bundle` is missing or misconfigured:

```bash
cd /opt/gitlab/embedded/service/gitlab-rails
sudo -u git -H /opt/gitlab/embedded/bin/bundle exec rake db:migrate RAILS_ENV=production
```

---

### 🧼 Step 3: **Clear the Obstruction (Run `db:migrate`)**

If `db:migrate` hasn't completed, GitLab cannot enqueue or process jobs properly.

```bash
sudo gitlab-ctl stop sidekiq
sudo gitlab-rake db:migrate
```

If this fails, record the error. You might need to restore from a backup (see below) or rerun the upgrade with `--skip-auto-reconfigure` and step manually.

---

### 🧯 Step 4: **Fail-Safe Options**

If migration or the bundle command cannot run:

1. **Create a snapshot or full VM backup immediately.**
2. **Check if a pre-18.0 backup exists** in `/var/opt/gitlab/backups/` or your storage.
3. Restore to 17.8 **on a staging VM** and retry upgrade carefully.

---

### 🧽 Step 5: **Queue Cleanup (Only After Data Integrity is Assured)**

If background jobs are beyond recovery:

```bash
sudo gitlab-rails console
Sidekiq::Queue.all.each(&:clear)
Sidekiq::RetrySet.new.clear
Sidekiq::ScheduledSet.new.clear
```

**⚠️ Dangerous!** Only do this if you're certain no important jobs are in queue.

---

### 🔁 Step 6: **Restart and Monitor**

```bash
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart
sudo gitlab-rake gitlab:check SANITIZE=true
```

Use:

```bash
watch sudo gitlab-ctl status
```

---

### 🔒 Production-Safe Recommendation

If you're uncertain or logs show database issues:

1. Restore from latest working backup (or snapshot).
2. Rehearse the 17.8→18.0 upgrade in a staging clone.
3. Fix permission, run migrations, verify background jobs *before* retrying production upgrade.



---
