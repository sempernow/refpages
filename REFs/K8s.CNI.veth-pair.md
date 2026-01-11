# K8s : CNI : Virtual Ethernet (veth) Pair

A __veth pair__ is two virtual network interfaces 
connected back-to-back to create a __bidirectional pipe__. 
Whatever enters one end exits the other.

**Why they exist**

Network namespaces are isolated by design;
they can't see each other's interfaces, 
so veth pairs are used to punch a hole between them.

```
┌─────────────────────────────────────────────────────────┐
│ Host network namespace                                  │
│                                                         │
│    ┌─────────┐                                          │
│    │  eth0   │ ← physical NIC                           │
│    └────┬────┘                                          │
│         │                                               │
│    ┌────┴────┐                                          │
│    │ cbr0/   │ ← bridge (or CNI interface)              │
│    │ cni0    │                                          │
│    └────┬────┘                                          │
│         │                                               │
│      vethXYZ  ← host end of pair                        │
│         │                                               │
└─────────┼───────────────────────────────────────────────┘
          │ ← the "pair" connection
┌─────────┼───────────────────────────────────────────────┐
│ Pod network namespace                                   │
│         │                                               │
│       eth0    ← pod end (renamed from veth peer)        │
│         │                                               │
│    Pod sees this as its network interface               │
└─────────────────────────────────────────────────────────┘
```

**In K8s terms**

When a pod starts:
1. CRI tells the runtime to create the pod sandbox with a new network namespace
2. CNI plugin creates a veth pair
3. One end stays in the host namespace (attached to a bridge or used for routing)
4. Other end moves into the pod's namespace and becomes `eth0`

You can see the host ends with   
`ip link | grep cali`   
(or whatever the CNI's prefix),  
e.g., `cali6db1a6d597f@if3`. 

The `@if3` indicates the interface index of the peer in the other namespace.

---

That's expected behavior—Calico doesn't need IPv4 addresses on the veth interfaces themselves.

**How Calico routes differently**

Most CNIs use a bridge model where the host-side veth needs an IPv4 address for L2 connectivity. 
Calico uses pure __L3 routing__:

```
┌─────────────────────────────────────────────────────────┐
│ Host                                                    │
│                                                         │
│  Routing table:                                         │
│  10.244.1.5 dev cali1234 scope link                     │
│  10.244.1.6 dev cali5678 scope link                     │
│                                                         │
│  cali1234 ──────────┬─────────── cali5678               │
│  (no IPv4)          │           (no IPv4)               │
│                     │                                   │
└─────────────────────┼───────────────────────────────────┘
                      │
    ┌─────────────────┴────────────────┐
    │                                  │
┌───┴───┐                          ┌───┴───┐
│ Pod A │                          │ Pod B │
│eth0:  │                          │eth0:  │
│10.244.1.5                        │10.244.1.6
└───────┘                          └───────┘
```

The host routes packets directly to the veth device—no next-hop IP needed. The `scope link` route says "this IP is reachable directly via this interface."

**Why IPv6 appears**

The `fe80::/10` link-local addresses you're seeing are auto-configured on any interface with IPv6 enabled (default kernel behavior). They're not part of Calico's data path; they're just the kernel doing its thing.

**Verification**

```bash
# Host routes for pods - note "scope link", no gateway
ip route | grep cali

# Inside the pod - default route points to a link-local or 169.254.x.x
kubectl exec <pod> -- ip route
```

Calico uses proxy ARP on the host side so the pod's `eth0` can ARP for its gateway and get a response, even though no real IPv4 exists on the host end.

---

| Command | Layer | What it shows |
|---------|-------|---------------|
| `ip link` | L2 | Interfaces, MAC addresses, MTU, state (up/down), veth peers |
| `ip addr` | L2/L3 | L2 info + IP addresses bound to interfaces |
| `ip route` | L3 | Routing table—where to send packets for each destination |
| `ip neigh` | L2/L3 | ARP/NDP cache—IP to MAC mappings |


`ip method` vs. network model 

```
ip link   L2        What interfaces exist and how they're connected.
                    ↓
ip addr   L2/L3     What IPs are assigned to those interfaces. 
                    ↓
ip route  L3        Given a destination IP, which interface/gateway to use.
                    ↓
ip neigh  L2/L3     For that next-hop IP, what's the MAC address.
```

For Calico debugging, the sequence is usually:

```bash
ip link show type veth          # do the veth pairs exist?
ip route | grep cali            # is the pod IP routed to the right veth?
ip neigh show dev caliXXX       # does the host have the pod's MAC?
```

---

## Network layer vs. tool

| Layer | Name | Unit | Identifiers | Tools |
|-------|------|------|-------------|-------|
| L2 | Data Link | Frame | MAC addresses | `ip link`, `ip neigh` |
| L3 | Network | Packet | IP addresses | `ip addr`, `ip route` |
| L4 | Transport | Segment | Ports (TCP/UDP) | `ss`, `netstat` |

**For L4 inspection**

```bash
ss -tlnp          # TCP listeners with PIDs
ss -ulnp          # UDP listeners
ss -tn state established  # active TCP connections
netstat -tulpn    # older equivalent
```

`ip addr` maxes out at L3; it'll show you which IPs exist on which interfaces, 
but has no concept of what's listening or connected on those IPs.

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
