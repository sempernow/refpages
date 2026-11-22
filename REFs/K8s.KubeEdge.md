# [KubeEdge](https://kubeedge.io/) 

>An open-source system designed to extend native containerized application orchestration and device management to hosts at the "Edge." 

It is a [CNCF Graduate](https://www.cncf.io/announcements/2024/10/15/cloud-native-computing-foundation-announces-kubeedge-graduation/) built on Kubernetes. 

## Core Use Case Scenarios

KubeEdge is primarily used in Edge environments; *where computing needs to be moved closer to data sources* to reduce latency, save bandwidth, and ensure offline autonomy. 

* Intelligent Transportation & Smart Cities:
* Highway Toll Systems: Managing nearly 100,000 edge nodes and 500,000 applications in unmanned toll stations across China.
   * Bridge Monitoring: The [Hong Kong-Zhuhai-Macao Bridge](https://kubeedge.io/case-studies/) uses KubeEdge to collect data from over 14 types of sensors (CO2, noise, temperature) and deploy AI applications at the edge for real-time monitoring.
   * Smart Road Infrastructure: Deploying roadside units (RSUs) to process perception and navigation workloads for autonomous driving.
* Industrial IoT (IIoT) & Manufacturing:
* Smart Factories: Automating safety monitoring through AI at the edge to reduce accidents and improve production efficiency.
   * Coal Mine Safety: Implementing the "Mine Brain" solution to manage cloud-edge-device collaboration for safer coal production.
   * Offshore Oil Fields: Managing sensors and edge nodes centrally even with unstable maritime network conditions.
* Logistics & Retail:
* Smart Logistics: SF Technology leverages KubeEdge for automated sorting and tracking product conditions in cold chain logistics using real-time sensor data.
   * Retail Chains: Deploying inventory management and customer analytics across thousands of stores while ensuring local autonomy during network outages.
* Emerging Frontiers:
* Satellite-Ground Collaboration: Enabling satellites to perform AI inference locally to reduce data return by 90% and improve identification accuracy by 50%.
   * Energy Management: Managing smart grids and energy distribution nodes for real-time monitoring and efficient power allocation.

- [Edge Computing in Kubernetes using KubeEdge | by Arjun B ...](https://medium.com/@arbnair97/how-to-configure-kubeedge-in-a-kubernetes-cluster-6b7c99106f74)
- [KubeEdge: Monitoring Edge Devices at the World's Longest Sea ...](https://www.altoros.com/blog/kubeedge-monitoring-edge-devices-at-the-worlds-longest-sea-bridge/)

### Why KubeEdge for These Use Cases?

The technical advantages that drive these specific use cases include:

* Edge Autonomy: Edge nodes can continue operating and managing local devices even when disconnected from the cloud.
* Low Resource Footprint: The edge component (EdgeCore) requires only about 70MB of memory, making it suitable for resource-constrained IoT gateways.
* Simplified Device Management: Built-in support for protocols like **MQTT**, **Bluetooth**, and **Modbus** through a mapper framework allows for easy **digital twin management**.
* Scalability: Optimized messaging allows it to support far more nodes than standard Kubernetes clusters (tested up to 100,000 nodes). 

## Model / Capability 

In a standard Kubernetes cluster, worker nodes are highly sensitive to network latency and instability. KubeEdge was specifically designed to solve this by fundamentally changing how the cloud and the node communicate.

### Why Standard Kubernetes Fails with Latency

Standard Kubernetes expects a reliable, low-latency connection between the control plane and worker nodes. 

* Heartbeat Mechanism: Every 10 seconds (by default), a kubelet sends a heartbeat to the API server.
* Timeout & Eviction: If the control plane doesn't hear from a node for 40 seconds (the default node-monitor-grace-period), it marks the node as NotReady.
* Pod Rescheduling: After roughly 5 minutes (default-not-ready-toleration-seconds), the control plane begins evicting pods from that "failed" node and tries to restart them elsewhere.
* The Result: In high-latency edge environments (like a ship at sea or a remote factory), temporary network spikes cause "churn," where Kubernetes constantly kills and restarts healthy applications just because the connection was briefly slow. [2, 3, 4, 5] 

### How KubeEdge Fixes This

KubeEdge replaces the standard Kubernetes communication model with an **asynchronous, reliable messaging system**. 

* Edge Autonomy (Local Persistence): Unlike a standard node that loses its state when disconnected, KubeEdge nodes use a local database (**SQLite**) to store metadata. If the connection to the cloud drops, the edge node continues running its current workloads based on this local cache.
* Efficient Messaging: KubeEdge uses protocols like **WebSockets** and **MQTT** instead of the constant "list-watch" HTTP requests used by standard Kubernetes. This drastically reduces the data sent over the wire and is much more tolerant of packet loss and high round-trip times.
* No Forced Evictions: Because the control plane knows these nodes are at the "edge," it doesn't immediately assume a missing heartbeat means the hardware failed. ***It allows the edge node to remain autonomous until the link is restored***, at which point it re-synchronizes metadata.
* Startup Capability: A KubeEdge node can even restart and recover its local services while completely offline by reading from its local database—something a standard Kubernetes node cannot do.   

Performance Comparison

| Feature  | Standard Kubernetes | KubeEdge |
|---|---|---|
| Typical Latency Limit | High sensitivity (40s timeout) | High tolerance (minutes/hours/days) |
| Offline Operation | Pods may stop or be evicted | Full autonomous operation |
| Communication | Synchronous (HTTP List-Watch) | Asynchronous (Websocket/MQTT) |
| Local Cache | Memory-only (lost on reboot) | Persistent Database (SQLite) |

## &nbsp;

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
