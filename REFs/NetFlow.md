# [NetFlow](https://en.wikipedia.org/wiki/NetFlow) on RHEL

## Q:

Can we leverage NetFlow using open source tools on RHEL 8

## A:

Yes, you can leverage NetFlow on RHEL 8 using several mature open-source tools. 
These tools allow you to collect, store, and visualize network traffic data without licensing fees. 

Popular Open-Source NetFlow Tools for RHEL 8

- `ntopng`: A high-speed web-based traffic analyzer. It can capture data from local interfaces or act as a collector for remote NetFlow/IPFIX exporters.
    - Installation: You can add the official ntop repository to `/etc/yum.repos.d/` and install via dnf install `ntopng`.
- `nfdump` & `NfSen`: A powerful command-line toolset (nfdump) for capturing and processing flows, paired with a web frontend (NfSen) for visualization.
    - Best for: Long-term historical data storage and detailed forensic analysis.
- `SiLK` (System for Internet-Level Knowledge): Developed by Carnegie Mellon’s CERT, it is designed for high-performance collection and analysis of network flow data in large-scale environments.
- `softflowd`: A lightweight software-based NetFlow exporter. If you want a RHEL 8 server to generate NetFlow data about its own traffic to send elsewhere, this is the standard tool.
    - Installation: Available via the EPEL repository using dnf install softflowd.
- `ElastiFlow`: Leverages the Elastic Stack (Elasticsearch and Kibana) 
    to provide advanced, modern dashboards for flow data visualization. 

Quick Setup Steps for RHEL 8

1. Enable EPEL Repository: Many open-source network tools are hosted in the Extra Packages for Enterprise Linux (EPEL) repository.
    ```bash
    sudo dnf install https://dl.fedoraproject.org
    ```
2. Configure Firewall: You must allow the specific UDP port (usually `2055` or `9995`) used by your NetFlow exporters.
    ```bash
    sudo firewall-cmd --add-port=2055/udp --permanent
    sudo firewall-cmd --reload
    ```
3. Install a Collector: For a quick web-based dashboard, installing `ntopng` is often the easiest entry point. 


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
