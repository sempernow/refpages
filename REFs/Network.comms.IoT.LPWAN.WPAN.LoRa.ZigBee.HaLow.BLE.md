# IoT Connectivity


|Class|Protocols|Typical Range|Primary Topology|
|---|---|---|---|
|LPWAN|Wi-Fi HaLow<br>LoRaWAN|Long<br>(500m – 10+ km)| Star (direct to gateway/AP)
|WPAN/Mesh|Zigbee<br>BLE| Short<br>(10m – 100m)|Point-to-point or Mesh|

>**Wi-Fi HaLow** is sometimes called a high-throughput LPWAN or long-range Wi-Fi because it bridges the gap; offers LPWAN-like range with faster speeds than LoRaWAN.

---

# LPWAN (Low-Power Wide-Area Network)

- Includes: **Wi-Fi HaLow** (802.11ah), **LoRaWAN**, **Sigfox**, **NB-IoT**, and **LTE-M**.
- What defines it: Designed for long-range communication (hundreds of meters to several kilometers) at **low bit rates**, **low power** allowing battery-powered devices to transmit small amounts of data across wide areas or through heavy obstacles.

---

## [LoRa](https://en.wikipedia.org/wiki/LoRa) (Long Range) | L1 

Proprietary wireless modulation technique designed for the **IoT**, 
allowing devices to communicate over long distances 
while consuming very little power. 

Owned by [Semtech](https://en.wikipedia.org/wiki/Semtech)

LoRa is strictly **a physical-layer wireless modulation technique**—similar to how AM/FM radio works—meaning it simply translates data into long-range, low-power radio waves without needing an IP address, cellular network, or internet connection to function.

- **Tiny Bandwidth**: 0.3 kbps to 50 kbps (Texting)
- **Long Range**: 
    - Rural: 10 to 15 km
    - Urban: 2 to 5 km
- Is not a complete network protocol;  
  only the physical layer of systems like LoRaWAN and Meshtastic.
- Uses CSS (Chirp Spread Spectrum);  
    spreads the signal across a wider bandwidth,   
    making it highly resistant to interference   
    and able to be detected even below the noise floor.  
- Unlicensed Spectrum: Free **ISM** ( Industrial, Scientific, and Medical) bands
    - EU/Europe: 868 MHz
    - USA/Canada/Mexico: **915 MHz** 

Though LoRa is completely **decoupled from Internet** at the radio level, 
it is **compatible with Internet** through gateways.

- Decoupled (No Internet Needed):   
    Two LoRa devices can communicate directly with each other peer-to-peer (or in an offline mesh network like Meshtastic) over several miles. In this setup, the data stays entirely local and never touches the internet.
- Compatible (Internet-Connected):   
    To send that sensor data to a cloud dashboard or phone app, a **LoRaWAN** gateway acts as a bridge. The gateway receives the local LoRa radio signal and forwards the data over standard IP networks (Wi-Fi, Ethernet, or cellular) to the internet.

### LoRaWAN ([Wiki](https://en.wikipedia.org/wiki/LoRaWAN)|[Org](https://lora-alliance.org/about-lorawan/)) | L2 

An open,low-power, wide-area network (LPWAN) protocol built on top of LoRa. 
Compatible with but decoupled from the Internet.
Primarily an L2 protocol, it handles media access control (MAC), device classes (A, B, C), adaptive data rates (ADR), device addressing (DevAddr), and network-level AES-128 encryption. 

It defines how devices talk to gateways, how data is routed to servers, and how security (encryption) is handled. It uses a "star-of-stars" topology where end devices talk to gateways, which then forward data to a central network server .

LoraWAN is a Low Power, Wide Area (**LPWA**) networking specification designed to wirelessly connect battery operated *things* to the internet in regional, national or global networks, and targets key Internet of Things (IoT) requirements such as bi-directional communication, end-to-end security, mobility and localization services.

LoRaWAN operates in unlicensed radio frequency bands and is known for its long-range capabilities (up to 15 km in rural areas), low power consumption, and the ability to connect a large number of devices to a single network. The architecture includes end devices, gateways, network servers, and application servers, enabling a scalable and flexible network for diverse IoT applications.


#### LoRaWAN Backend / Gateways | L3

The **LoRaWAN Network Server** (LNS) provides Internet connectivity; 
handles basic packet routing, deduplication (when multiple gateways hear the same transmission), 
and regional frequency management. 
Once a gateway receives a LoRa packet, 
it wraps it in standard IP/UDP or MQTT (Layers 3–7) to send it over the internet to the cloud.

Used in IoT for for remote asset tracking and monitoring.

---

### [Meshtastic](https://meshtastic.org/) | L2-L7

An open-source, decentralized mesh networking **firmware** and app ecosystem for P2P/mesh comms built on LoRa radios.
Provides off-grid encrypted text messaging, GPS location sharing, and sensor telemetry 
without internet, cell towers, Wi-Fi, or subscription fees.

No cell towers. No internet. Just pure peer-to-peer connectivity.

Android app integrates with Meshtastic devices via Bluetooth

#### Meshtastic devices


---

### [MeshCore](https://meshcore.io/) | L2-L7

MeshCore is a simple, secure, off-grid mesh communications system in firmware.
Build your own low-cost, long-range, encrypted messaging network.

You can still send messages even when WiFi, Cellular, and Starlink are down.

---

### [MeshCore vs Meshtastic](https://www.youtube.com/watch?v=IlS8Cj1tNsA "YouTube")

Both run on the same LoRa hardware, but they are ***completely incompatible with each other*** 
and cannot communicate directly. The core difference lies in how messages are relayed: 

- **Meshtastic**
    - Operates as a ***flat***, dynamic mesh where every device participates equally.
    - Lets every node participate in relaying, creating a self-organizing "**crowd network**".
    - Can be setup to act like MeshCore, but default design adapts to follow a *moving* crowd.
- **MeshCore** 
    - Has a ***structured*** hierarchy separating handheld users from dedicated infrastructure.
    - Allows only dedicated repeaters to relay, building a structured "**backbone network**".


---

## Wi-Fi HaLow

A Wi-Fi HaLow gateway bridges long-range, low-power IEEE **802.11ah** (sub-1 GHz, typically ~900 MHz in the US) devices with standard IP networks, Ethernet, or 2.4 GHz Wi-Fi.

**1 Mbps to 25 Mbps**

Most available gateways reach up to roughly 1 km (0.6 miles) line-of-sight with stronger wall and floor penetration than 2.4 GHz or 5 GHz Wi-Fi, typically costing between $69 and $288 depending on features and region.

Used in devices such as long-range security cameras, IoT sensors, USB dongles, wireless bridges/extenders, and industrial hardware.

Can use as repeater if a client is otherwise stranded by low Wi-Fi signal.

# WPAN (**W**ireless **P**ersonal **A**rea **N**etwork) / Low-Power Short-Range Mesh

- Includes: **Zigbee**, **BLE** (**B**luetooth **L**ow **E**nergy), **Thread**, and **Z-Wave**.
- What defines it: Built for **short-range** communication (typically 10 to 100 meters) inside homes or buildings, often relying on **mesh** networking (where devices relay data to each other) to extend coverage rather than long-range radio signals.

Example : MM8108 used as Wi-Fi extender

        [Internet Gateway Router] 
            │ (Ethernet Cable)
            ▼
        [Morse Micro MM-HL1-EXT]  (Set to Access Point / Router Mode)
            │ (900 MHz Wi-Fi HaLow Wireless Link)
            ▼
        [Morse Micro MM-U0-A-US]  (USB 2.0 Dongle)
            │ (USB Port)
            ▼
        [Client Host PC]

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