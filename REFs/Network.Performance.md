# Network Performance

## Q:

A private network having both Windows Server and RHEL 8 hosts under vSphere hypervisors has notoriously poor performance, with intermittent latencies of several (if not tens of) seconds, yet network admins claim their metrics are not capturing that.  

1. Is that plausible? 
2. How to best demonstrate (capture) these intermittent latencies? 

Kubernetes clusters built of kubeadm suffer etcd leader changes many times per day, if not per hour.

## A:

### Part 1: Is it plausible for network admins' metrics to miss intermittent latencies?

**Absolutely yes, and it's very common.** Here’s why:

1.  **Polling Intervals:** Most SNMP/SNMP-based monitoring systems (like Nagios, SolarWinds, PRTG) poll devices every 1-5 minutes. An intermittent latency spike lasting 10-30 seconds can begin and end completely between polls, leaving no trace in the data.
2.  **Averaging:** Many tools show average latency or utilization over time. A 30-second spike in a 5-minute average gets diluted to a minor blip.
3.  **Wrong Metrics:** They might be monitoring link utilization (which is fine) or basic ICMP ping latency to the router/gateway, but not the *path latency* between specific critical hosts (e.g., between a Windows Server host and a RHEL host) or, more importantly, **TCP latency** which includes processing delay.
4.  **Monitoring the Wrong Layer:** Network teams often monitor the physical and data link layers (switch ports, routers) and maybe network layer (IP). The problem could be at the **transport layer (TCP)** or **application layer**—caused by host-level issues (CPU starvation, memory pressure, storage I/O wait) that manifest as network latency. Their switches see clean, error-free frames.
5.  **Hypervisor Network Stack:** The problem may be **inside the vSphere host**. Issues with:
    *   **Driver/vSwitch:** Poorly performing VMXNET3 driver, misconfigured vSwitch (e.g., incorrect teaming/LB policy), or resource contention on the vSphere host's networking (e.g., CPU ready time affecting the network interrupt handler).
    *   **Storage Network Contention:** If storage (iSCSI/NFS) and VM traffic share the same physical NICs or VLAN, a storage burst can cause TCP retransmits and latency for VM traffic.
    *   **Network I/O Control (NIOC):** If not configured or misconfigured, critical traffic isn't prioritized.

**Conclusion:** It's entirely plausible. The admins are likely telling the truth—their **current** metrics aren't capturing the event. The challenge is to move from "the network is fine" to "let's find where this *end-to-end* latency is actually occurring."

---

### Part 2: How to demonstrate (capture) these intermittent latencies?

You need **continuous, high-frequency, end-to-end active probing** between the actual affected endpoints. Here is a layered strategy:

#### **Phase 1: Strategic, Continuous Pinging (Simple Proof)**
This is your first, low-overhead proof.
*   **Tool:** Use `smokeping` or a simple script with `ping -D` (Linux) to log timestamped pings.
*   **Method:** Set up continuous pings (100ms intervals) **between the problematic VMs themselves** (e.g., RHEL 8 to Windows Server) **and also from each VM to their respective default gateways**.
*   **Why?** This isolates the problem:
    *   If latency spikes **only** between VMs, but not to their gateways, the issue is likely beyond the first hop (deep in the core/network, or on the destination host).
    *   If latency spikes **to the gateway as well**, the problem is in the first hop (vSwitch, physical switch port, host CPU).
*   **Capture the proof:** The log files with microsecond timestamps (`-D` on Linux) are irrefutable evidence of the latency spikes.

#### **Phase 2: Advanced TCP/Application Layer Tracing**
Ping (ICMP) can be de-prioritized. To see what applications experience, use TCP-based tools.
*   **`tcpping` (or `nping --tcp`):** Simulates a TCP handshake. Latency here is more representative of application connections.
*   **`hping3`:** Can flood with TCP SYN packets to see if loss/latency increases under load.
*   **`curl` with Time Details:** Use `curl -w "dnslookup: %{time_namelookup} connect: %{time_connect} starttransfer: %{time_starttransfer} total: %{time_total}\n" -o /dev/null -s <URL>` between hosts. This breaks down where in the connection the delay is (DNS, TCP connect, app response).
*   **Wireshark/Tcpdump on both ends:** This is the ultimate weapon. Perform a simultaneous packet capture on the source and destination VMs during a known problem period (or during a scheduled test). Filter for traffic between them.
    *   **Look for:** **TCP Retransmissions, Duplicate ACKs, or Out-of-Order packets.** These indicate packet loss the network may not alert on.
    *   **Look for Spikes in `TCP Delta`:** The time between a data packet and its ACK. A sudden increase points to network bufferbloat or host stalls.
    *   **Correlate timestamps:** A packet sent at T=0, ACK received at T=12 seconds is undeniable proof of a 12-second RTT.

#### **Phase 3: Hypervisor-Level Investigation**
*   **vSphere Performance Graphs:** Check for **"CPU Ready" (%)** and **"CPU Co-Stop"** on the affected VMs. High CPU Ready (>10%) means the VM is waiting for CPU cycles from the hypervisor—it will freeze, making all responses slow, mimicking network latency.
    - Note the counter-intitive meaning of "__CPU Ready__".
        - The VM is "Ready": The virtual machine's kernel or applications have requested CPU time and are prepared to execute instructions.
        - The __Hypervisor is Busy__: The ESXi hypervisor, which manages all the physical resources, acknowledges the VM's request but has no free physical CPU cores available at that exact moment.
        - The __Wait Time__: The metric measures the _duration of this waiting period_; the time the "ready" VM spent queued up for service.
    - __Co-Stop__ (`%CSTP`) measures "co-scheduling" constraints;  the percentage of time a VM had to wait for all of its assigned vCPUs to be scheduled on physical CPU cores simultaneously. Ironically, the most common cause is assigning more vCPUs to a VM than the workload actually needs or can use efficiently.
*   **esxtop:** From the ESXi shell, run `esxtop`. Check:
    *   `NETWORK` view: Look for `%DRPTX` (dropped transmits) on the vSwitch or physical NICs (vmnic).
    *   `INTERRUPT` view: High interrupt rates can indicate poor driver performance.
*   **Check NIOC Settings:** Ensure shares/limits are set for critical VM traffic if sharing with storage.


---

### Part 3: The Kubernetes etcd Leader Change Problem

Frequent etcd leader changes are a **symptom, not a root cause**. They are the **canary in the coal mine** for the issues above. Etcd is exquisitely sensitive to:
1.  **Network Latency:** The etcd raft protocol has strict heartbeat intervals (default election timeout of 1000ms). A latency spike >100ms can cause missed heartbeats, leading to leader elections.
2.  **I/O Latency:** etcd writes to disk before committing. If the underlying storage (even if it's a virtual disk) experiences high I/O wait, the etcd node can't respond in time.
3.  **CPU Starvation:** If the etcd pod/VM is not getting scheduled CPU (high CPU Ready in vSphere), it will freeze and drop heartbeats.

**How to Investigate the etcd Issue:**
*   **Check etcd Metrics:** Use `etcdctl endpoint status` and `etcdctl endpoint health`. Look for high leader heartbeat round-trip times.
*   **Check etcd Logs:** `journalctl -u etcd` (on the host) or `kubectl logs -n kube-system <etcd-pod-name>`. You will see lines like:
    *   `"lost leader", "took too long", "heartbeat send error"`
*   **Correlate:** The timestamps of etcd warnings **will directly correlate** with the latency spikes you capture using the methods above. This is your knockout punch: "At 14:23:17, the RHEL VM experienced a 14-second TCP latency spike. At 14:23:18, etcd node on that server lost its leader. Here are both logs."

### Recommended Action Plan:
1.  **Immediate Evidence:** Set up `smokeping` between two problematic VMs and from each VM to its gateway. Run it for 24 hours. The graphs will show the spikes.
2.  **Demand Coordination:** Schedule a short maintenance window with the network and virtualization teams.
3.  **Conduct a Test:** During the window, run a `iperf3` or `nuttcp` bandwidth/latency test between VMs while simultaneously:
    *   Running `esxtop` on the ESXi hosts.
    *   Running `tcpdump` on the VMs.
    *   Monitoring the etcd cluster status.
4.  **Root Cause:** The combined data will pinpoint the layer: Host CPU Ready, vSwitch, physical NIC, switch port, storage network contention, etc.

By moving the conversation from "the network is fine" to "here is the evidence of latency between these two VMs at layer 3 and layer 4, and here is the correlated impact on our Kubernetes control plane," you shift the focus to a collaborative troubleshooting effort across teams.


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
