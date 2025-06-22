# Data Backup Strategies 

In the area of data backup, the terms used to describe different backup strategies are as follows:

1. **Full Backup (Clone of Current State)**:
   A full backup is a complete copy of the data as it exists at a particular point in time. It is a "clone" of the current state, capturing everything, regardless of previous backups. This type of backup does not rely on previous backup data and is independent, meaning you can restore the entire data set from just this backup alone.

2. **Incremental Backup (Accumulation on Top of Prior States)**:
   An incremental backup only captures the changes (new or modified data) since the last backup—whether it was a full backup or another incremental backup. This means each incremental backup builds on the previous one, resulting in a chain of backup sets that, when restored together, recreate the entire dataset.

3. **Differential Backup (Accumulation of Changes Since the Last Full Backup)**:
   A differential backup captures all changes made since the last full backup. Unlike incremental backups, which only include changes since the last backup (of any type), differential backups accumulate all changes since the last full backup. As a result, a differential backup tends to grow in size over time, especially as more changes are made, but it is quicker to restore compared to a series of incremental backups.

4. **Snapshot Backup**:
   A snapshot backup creates a point-in-time copy of the entire system or dataset, usually in a way that allows for rapid restoration. Unlike full backups, snapshots typically rely on underlying data and may use techniques like copy-on-write to track changes. Snapshots often function as "clones" in virtualized environments or storage systems but may not capture the data itself as comprehensively as full backups.

5. **Continuous Data Protection (CDP)**:
   CDP involves continuously backing up data in real-time or near-real-time. It doesn't create periodic snapshots or incremental backups; instead, it keeps a real-time copy of the data state, continuously backing up changes as they occur. This can be seen as a more granular form of data protection compared to traditional backup methods.

Each of these approaches has its pros and cons in terms of storage requirements, backup speed, and recovery times. Typically, a combination of full, incremental, and differential backups is used to balance backup efficiency and restore times.



---

<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# … ⋮ ︙ • “” ‘’ – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × € ¢ £ ¤ ¥ ₽ ♻ ⚐ ⚑
# ☢ ☣ ☠ ¦ ¶ § † ‡ ß µ ø Ø ƒ Δ ⚒ ☡ ☈ ☧ ☩ ✚ ☨ ☦ ☓ ♰ ♱ ✖ ☘ 웃 𝐀𝐏𝐏 𝐋𝐀𝐁
# ⚠️ ✅ 🚀 🚧 🛠️ ⚡ ❌ 🔒 🧩 📊 📈 🔍 🧪 📦 🔧 🧳 🥇 💡 ✨️ 🔚

# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>


-->
