# Sonatype [Nexus Repository Manager](https://help.sonatype.com/en/sonatype-nexus-repository.html "help.sonatype.com") (__NXRM__)


# Backup Script 

Handle the blob store, `/nexus-data/blobs`,  via filesystem level backup

This script will safely backup just:

- OrientDB database
- Configuration (`etc`, `keystores`, security, users, roles, scheduled tasks, etc.)
- Repository metadata
- Everything else **except** `/nexus-data/blobs`

---

## 📜 Backup Script (Without Blob Store): `/usr/local/bin/nexus-config-backup.sh`

```bash
#!/bin/bash
set -euo pipefail

BACKUP_DIR="/opt/nexus-backups"
NEXUS_DATA="/nexus-data"
EXCLUDE_BLOBS="${NEXUS_DATA}/blobs"
NEXUS_SERVICE="nexus"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_NAME="nexus-config-backup-${TIMESTAMP}.tar.gz"
TEMP_DIR="/tmp/nexus-backup-${TIMESTAMP}"

echo "[INFO] Starting Nexus configuration backup..."

# Step 1: Stop Nexus to ensure DB consistency
echo "[INFO] Stopping Nexus..."
systemctl stop "${NEXUS_SERVICE}"

# Step 2: Create temp working dir
mkdir -p "${TEMP_DIR}"

# Step 3: Rsync everything but blobs
echo "[INFO] Copying configuration and database (excluding blobs)..."
rsync -a --delete \
  --exclude="blobs/" \
  "${NEXUS_DATA}/" "${TEMP_DIR}/nexus-data/"

# Step 4: Start Nexus again
echo "[INFO] Restarting Nexus..."
systemctl start "${NEXUS_SERVICE}"

# Step 5: Create archive
mkdir -p "${BACKUP_DIR}"
echo "[INFO] Creating archive: ${BACKUP_DIR}/${BACKUP_NAME}"
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}" -C "${TEMP_DIR}" nexus-data

# Step 6: Cleanup
rm -rf "${TEMP_DIR}"
echo "[INFO] Configuration backup complete: ${BACKUP_NAME}"
```

---

## 🧼 Make Executable

```bash
chmod +x /usr/local/bin/nexus-config-backup.sh
```

---

## 🧪 Restore Process (Without Blob Store)

To restore:

1. Stop Nexus:
   ```bash
   systemctl stop nexus
   ```

2. Restore the config:
   ```bash
   tar -xzf nexus-config-backup-*.tar.gz -C /
   ```

3. Ensure `/nexus-data/blobs` exists and is restored separately.

4. Start Nexus:
   ```bash
   systemctl start nexus
   ```

---

## ✅ Bonus: Filesystem Snapshot for Blobs

If using LVM:

```bash
lvcreate --size 50G --snapshot --name nexusblob-snap /dev/vg0/nexusblob
```

Then mount it and archive:

```bash
mount /dev/vg0/nexusblob-snap /mnt/nexusblob-snap
rsync -a /mnt/nexusblob-snap/ /some/backup/target/
umount /mnt/nexusblob-snap
lvremove /dev/vg0/nexusblob-snap
```

---

# Tasks

Curated set of **NXRM Tasks** specifically for **application-level maintenance**, pruning, and performance — not backup.

These tasks help keep the Nexus repo healthy, smaller, and faster — **ideal to run on a schedule**, e.g., nightly or weekly. I'll show:

1. **Recommended Tasks** for cleanup/maintenance
2. **How to create them in the GUI**
3. **REST API JSON templates** (so you can script them)

---

## ✅ 1. Recommended Maintenance Tasks

| Task Name                         | Description |
|----------------------------------|-------------|
| **Remove Snapshots from Maven Repositories** | Deletes old `-SNAPSHOT` versions beyond a retention policy |
| **Delete Unused Components**     | Deletes components that are no longer referenced by any metadata |
| **Compact Blob Store**           | Frees space by removing soft-deleted blobs (garbage collection) |
| **Rebuild Repository Index**     | Recreates the search index for a given repo (if corrupted) |
| **Repair - Reconcile component database** | Re-syncs metadata DB with blobs; good after crashes |
| **Evict unused proxy items from cache** | Clears unused items from proxy cache (only for proxy repos) |

---

## 🖱️ 2. Create via GUI

**Path**: `Admin > System > Tasks > Create task`

- **Task type**: choose one of the above
- **Schedule**: daily/weekly, or after-hours
- **Repository**: set `All Repositories` or choose per task
- **Retention**: set days to keep, # to retain, etc.

Example:

- Task Type: `Remove Snapshots from Maven Repositories`
- Repositories: All hosted maven
- Minimum snapshot count: 2
- Snapshot retention (days): 14
- Run as: `admin`
- Schedule: `Daily @ 01:00 AM`

---

## 📡 3. JSON Templates (via REST API)

You can use `curl` to POST these to your Nexus instance at:

```http
POST http://localhost:8081/service/rest/v1/tasks
Authorization: Basic <admin:password base64>
Content-Type: application/json
```

### 🧹 Remove Snapshots (14 days old, keep 2)

```json
{
  "name": "Remove Old Maven Snapshots",
  "type": "removeSnapshots",
  "message": "Remove maven snapshots older than 14 days",
  "schedule": {
    "type": "daily",
    "time": "01:00"
  },
  "enabled": true,
  "properties": {
    "repositoryName": "maven-releases",
    "minimumRetained": "2",
    "snapshotRetentionDays": "14"
  }
}
```

### 🗑️ Delete Unused Components

```json
{
  "name": "Delete Unused Components",
  "type": "cleanup",
  "message": "Delete orphaned components",
  "schedule": {
    "type": "weekly",
    "dayOfWeek": "Saturday",
    "time": "01:30"
  },
  "enabled": true,
  "properties": {
    "lastBlobUpdatedDays": "30"
  }
}
```

### 🧼 Compact Blob Store

```json
{
  "name": "Compact Default Blob Store",
  "type": "blobstore.compact",
  "message": "GC cleanup on default blob store",
  "schedule": {
    "type": "weekly",
    "dayOfWeek": "Sunday",
    "time": "02:00"
  },
  "enabled": true,
  "properties": {
    "blobstoreName": "default"
  }
}
```

You can repeat this template for each blob store.

---

## 🧠 Pro Tips

- If using `content selectors` and cleanup policies, you can attach them to automate deletion of old/unused artifacts per repo.
- For large systems: stagger tasks to avoid I/O spikes.
- Enable task logs under `Support > Logging` if needed.


#  Generate Tasks using API 

**shell script** to automate the creation of maintenance tasks in **Sonatype Nexus Repository Manager** 
using the **REST API**. It authenticates with basic auth, sends task definitions as JSON, and checks for successful responses.

---

## 📜 Script: `nexus-maintenance-tasks.sh`

```bash
#!/bin/bash
set -euo pipefail

# === CONFIGURATION ===
NEXUS_URL="http://localhost:8081"
NEXUS_USER="admin"
NEXUS_PASS="yourpassword"  # Replace with a secure method in production

# === AUTH HEADER ===
AUTH=$(echo -n "${NEXUS_USER}:${NEXUS_PASS}" | base64)

# === POST FUNCTION ===
post_task() {
  local task_name="$1"
  local json_payload="$2"
  echo "[INFO] Creating task: ${task_name}"
  curl -s -o /dev/null -w "%{http_code}" -X POST "${NEXUS_URL}/service/rest/v1/tasks" \
    -H "Authorization: Basic ${AUTH}" \
    -H "Content-Type: application/json" \
    -d "${json_payload}"
}

# === TASK 1: Remove Snapshots ===
SNAPSHOT_TASK=$(cat <<EOF
{
  "name": "Remove Old Maven Snapshots",
  "type": "removeSnapshots",
  "message": "Remove maven snapshots older than 14 days",
  "schedule": {
    "type": "daily",
    "time": "01:00"
  },
  "enabled": true,
  "properties": {
    "repositoryName": "maven-releases",
    "minimumRetained": "2",
    "snapshotRetentionDays": "14"
  }
}
EOF
)
post_task "Remove Old Maven Snapshots" "$SNAPSHOT_TASK"

# === TASK 2: Delete Unused Components ===
DELETE_UNUSED_TASK=$(cat <<EOF
{
  "name": "Delete Unused Components",
  "type": "cleanup",
  "message": "Delete orphaned components",
  "schedule": {
    "type": "weekly",
    "dayOfWeek": "Saturday",
    "time": "01:30"
  },
  "enabled": true,
  "properties": {
    "lastBlobUpdatedDays": "30"
  }
}
EOF
)
post_task "Delete Unused Components" "$DELETE_UNUSED_TASK"

# === TASK 3: Compact Blob Store ===
COMPACT_BLOB_TASK=$(cat <<EOF
{
  "name": "Compact Default Blob Store",
  "type": "blobstore.compact",
  "message": "GC cleanup on default blob store",
  "schedule": {
    "type": "weekly",
    "dayOfWeek": "Sunday",
    "time": "02:00"
  },
  "enabled": true,
  "properties": {
    "blobstoreName": "default"
  }
}
EOF
)
post_task "Compact Default Blob Store" "$COMPACT_BLOB_TASK"

echo "[DONE] All tasks created."
```

---

## 🔧 Usage

1. Save the script:
   ```bash
   nano nexus-maintenance-tasks.sh
   ```

2. Make executable:
   ```bash
   chmod +x nexus-maintenance-tasks.sh
   ```

3. Run it:
   ```bash
   ./nexus-maintenance-tasks.sh
   ```

---

## 🧠 Notes

- You can also store `NEXUS_PASS` securely using `read -s` or pulling from a secret file.
- Change `repositoryName` to `"*"` if you want to apply to all Maven repos (if supported in your version).
- Confirm with `GET /service/rest/v1/tasks` to see created tasks.

---

Want a version that **reads tasks from JSON files** in a directory instead, for version-controlled task definitions?



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
