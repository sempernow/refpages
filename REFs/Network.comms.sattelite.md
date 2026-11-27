# Satellite Communication Systems


## [Iridium](https://www.iridium.com/) Communication Systems

A constellation of LEO (**l**ow-**E**arth **O**rbit) satellites.

### [Services](https://www.iridium.com/services)

- **PNT** (**P**osition, **N**avigation and **T**iming)  
- **Safety and Security**  
- **[IoT, Data & Messaging](https://www.iridium.com/services/data-messaging)**  
    - **Iridium [Short Burst Data](https://www.iridium.com/services/iridium-short-burst-data-sbd)**® (**SBD**) is a low-power, two-way   
    satellite messaging and data service 
    designed for IoT, tracking, and remote-asset monitoring. 
- **NTN Direct**  
    A [3GPP](https://www.3gpp.org/about-us) standards-based 
    narrowband Internet of Things (NB-IoT) and Direct-to-Device (D2D) 
    satellite connectivity service providing exetended cellular-style coverage 
    for compatible devices and mobile network operators (MNOs).
    - Designed for NB-IoT and D2D devices, enabling massive scale and low cost.
    - Designed to mesh seamlessly with terrestrial networks, enabling roaming, fallback and global reach.
    - Partners:
        - Mlink: MS150-IR IoT-NTN (chipset)
        - Nordic Semiconductor: nRF9151 System-in-Package (SiP)
        - Altair: ALT1350 (chipset)
- **Voice**

### [Products](https://www.iridium.com/products)

- [Iridium Go](https://www.iridium.com/products/iridium-go)  
    Voice (2s latency) and Text


---

## Garmin inReach 

Subscription global 2-way messaging (SOS) system via Iridium sattelites.

---

## Open Source / DIY

You can build a DIY open-source satellite communicator using an Iridium Short Burst Data (SBD) modem, open-source microcontroller libraries, and a custom server backend—though you still have to pay for commercial satellite airtime and will not get Garmin's 24/7 emergency SOS dispatch.

Because satellites in orbit are privately owned infrastructure (unlike the free, unlicensed radio frequencies used by LoRa), there is no 100% free, fully open-source equivalent from end to end. However, the hardware integration, firmware, and messaging software can be completely open source.

### How the Open-Source DIY Stack Works

To replicate the two-way global messaging and GPS tracking of a Garmin inReach, 
makers and engineers typically combine four layers:

- **Satellite Modem** (Proprietary Hardware): You need an off-the-shelf transceiver capable of talking to commercial satellites. The most popular maker-friendly module is the **RockBLOCK 9603**, which wraps an [Iridium 9603 SBD transceiver](https://www.iridium.com/products/iridium-9603-module) with an integrated patch antenna and simple serial pins. (Note: Swarm Technologies previously offered a popular open-source SparkFun M138 kit, though SpaceX retired Swarm's standalone SpaceBEE network in favor of Starlink Direct-to-Cell). [1] (https://www.iridium.com/products/rockblock-9603), [2] (https://learn.sparkfun.com/tutorials/satellite-transceiver-breakout---swarm-m138---hookup-guide/all)

- **Device Firmware** (Open Source): You connect the modem to an ESP32, Arduino, or Raspberry Pi alongside a standard GPS module and screen. Open-source libraries like IridiumSBD (for C++/Arduino) or Python CLI tools handle the serial AT commands to transmit up to 340 bytes per message and receive up to 270 bytes. [1] (https://github.com/Juanezm/iridium-sbd), [2] (https://www.hackster.io/nootropicdesign/iridium-satellite-communication-with-arduino-b29cfd), [3] (https://github.com/TeslaNeuro/ESP32-Iridium-9603-module-SatCommunication), [4] (https://www.iridium.com/products/rockblock-9603)

- **Satellite Network & Gateway** (Commercial Subscription): When your device transmits, the Iridium satellite network routes the packet down to a commercial ground gateway (such as Ground Control's Cloudloop), which forwards the payload to your own web server via HTTP webhooks or email. Line rental typically starts around $15–$20/month plus a few cents per message. [1] (https://www.hackster.io/nootropicdesign/iridium-satellite-communication-with-arduino-b29cfd), [2] (https://www.iridium.com/products/rockblock-9603)

- **Backend & Tracking UI** (Open Source): On your server, you can run open-source automation tools like Node-RED to bridge incoming satellite webhooks to SMS APIs (like Twilio), Telegram, or Matrix, and feed GPS coordinates into an open-source mapping platform like Traccar so family members can track your route live. [1] (https://www.hackster.io/nootropicdesign/iridium-satellite-communication-with-arduino-b29cfd), [2] (https://sourceforge.net/directory/gps/), [3] (https://www.goodfirms.co/gps-tracking-software/blog/best-free-open-source-gps-tracking-software)

### Key Limitations Compared to Garmin inReach

- **No Professional SOS Dispatch**:   
    An open-source build can send a distress text to your personal contacts, but it cannot trigger Garmin Response or international COSPAS-SARSAT search-and-rescue coordination. For life-safety emergencies, a certified commercial device or subscription-free **Personal Locator Beacon** (PLB) is still required.
- **Higher Upfront Effort & Cost**:   
    A bare RockBLOCK 9603 module alone costs roughly $250 before you add a microcontroller, GPS receiver, battery, and weatherproof enclosure—often costing more than a retail satellite communicator while being bulkier and less rugged.

### Hybrid LoRa-to-Satellite Bridges

Because of these trade-offs, many open-source enthusiasts use Meshtastic on the ground and build a single solar-powered "base station" node that bridges local LoRa mesh messages onto an Iridium modem or Starlink terminal, allowing an entire off-grid group to share one satellite connection. [1] (https://www.outdoorgearlab.com/topics/camping-and-hiking/best-personal-locator-beacon), [2] (https://www.youtube.com/watch?v=ieRzgAa1eWM), [3] (https://www.iridium.com/products/iridium-9603-module), [4] (https://www.hackster.io/nootropicdesign/iridium-satellite-communication-with-arduino-b29cfd)


---

<!-- 

… ⋮ ︙ - ● – — ™ ® © ± ° ¹ ² ³ ¼ ½ ¾ ÷ × ₽ € ¥ £ ¢ ¤ ♻ ⚐ ⚑ ✪ ❤  \ufe0f
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
