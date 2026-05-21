# OSI Layers : (En/De)capsulation &amp; Data Flow

```
Application Layer (L7)   --> Data
Transport Layer (L4)     --> Segment
Network Layer (L3)       --> Packet
Data Link Layer (L2)     --> Frame
Physical Layer (L1)      --> Bits
```

>L2 protocols only know how to move data across a single physical link. 
>They have no concept of "the internet" or distant networks. 
>The reconfiguring of the frame at each hop 
>is what allows local delivery mechanisms 
>to collectively achieve global routing.


In the OSI model (and TCP/IP), ***lower levels wrap higher levels***. 

This process is called encapsulation. [1, 2, 3]  

When you send a message, it travels down the stack (Layer 7 to 1), with each lower layer adding its own "envelope" (header) to the data. [4, 9]  

**Layer-by-Layer Encapsulation**: 

The data starts at Layer 7 (Application) and is passed down to Layer 6 (Presentation), which takes the entire layer 7 data and wraps it. Then Layer 5 wraps that, and so on.  ***All layers are subject to modification in transit*** between end entities (between first and final nodes of any multi-hop path).

- **Application Layer** (**L7**): The raw **data** (e.g., HTTP request) is generated without any headers.
- **Transport Layer** (**L4**): Data is encapsulated into a **segment** (TCP) *or* **datagram** (UDP) with a *transport header* which includes source and destination  *ports*, and perhaps *sequence numbers* (if, e.g., TCP).
- **Network Layer** (**L3**): The segment is encapsulated into a **packet**, which includes an IP header (source and destination IP addresses).
- **Data Link Layer** (**L2**): The packet is encapsulated into a **frame** (Ethernet, Wi-Fi, PPP, ...), 
  which *includes MAC addresses* (source &amp; *next-hop* destination) and may have a trailer for error checking.
- **Physical Layer** (**L1**): The frame is converted into **bits** (1s and 0s) for transmission over the physical medium.

**Summary of Data Movement**:

- Encapsulation (Sending): Data travels down, 7 --> 1. 
- Decapsulation (Receiving): Data travels up, 1 --> 7, with each layer removing its envelope. [14]  

References:

- [1] https://jumpcloud.com/it-index/encapsulation-vs-decapsulation-in-networking
- [2] https://blog.domotz.com/it-security/history-of-the-osi-model/
- [3] https://sudarshan-s.medium.com/7-osi-vs-tcp-ip-model-the-networking-series-9405d3658f99
- [4] https://www.splunk.com/en_us/blog/learn/osi-model.html
- [5] https://www.youtube.com/watch?v=pLnq11EOfe4
- [6] https://ddos-guard.net/blog/osi-model
- [7] https://www.linkedin.com/posts/abhijit-mishra-05ba97157_the-open-systems-interconnection-osi-model-activity-7088109858624860160-Ns1w
- [8] https://www.cliffsnotes.com/study-notes/20885867
- [9] https://www.instagram.com/p/DUn2qWNDBv3/
- [10] https://www.sciencedirect.com/topics/computer-science/encapsulation-type
- [11] https://quizlet.com/study-guides/encapsulation-and-decapsulation-in-the-osi-model-d1968b15-8bbb-4fdd-a864-d33164a79808
- [12] https://www.rcrwireless.com/20180402/fundamentals/the-seven-layers-of-the-open-systems-interconnection-model
- [13] https://www.reddit.com/r/networking/comments/7ymbik/osi_model_question/
- [14] https://community.cisco.com/t5/switching/osi-layers-working-in-both-directions/td-p/1123959


OCI layering is (1970s) design of ARPANET by Vint Cerf and Bob Kahn of ARPA

---

# Request/Response : Reversal of L2, L3 and L4 headers 

Regarding source/destination headers of request/response, 
for any network response to successfully navigate back to the client, 
the L2 (MAC), L3 (IP) and L4 (UDP/TCP) 
***headers must precisely reverse their source and destination fields***.
This reversal allows network hardware and operating systems 
to match the response to the original request.

## The Standard Reversal (Asymmetric)

In standard network communication, the client uses a random ephemeral port as its source.

| Packet Direction | Layer | Source Field | Destination Field |
|---|---|---|---|
| Request (Client → Server) | L3 (IP) L4 (Port) | Client IP Ephemeral Port (e.g., 54321) | Server IP Listening Port (e.g., 80) |
| Response (Server → Client) | L3 (IP) L4 (Port) | Server IP Listening Port (e.g., 80) | Client IP Ephemeral Port (e.g., 54321) |

## The Windows NTP Exception (Symmetric)

In the Windows w32time behavior discussed previously, the values are still strictly reversed, but because both ports start as 123, the port fields look identical in both directions.

| Packet Direction | Layer | Source Field | Destination Field |
|---|---|---|---|
| Request (Windows → Linux) | L3 (IP) L4 (Port) | Windows IP Port 123 | Linux IP Port 123 |
| Response (Linux → Windows) | L3 (IP) L4 (Port) | Linux IP Port 123 | Windows IP Port 123 |

## Why This Reversal Is Critical

* Stateful Firewalls / NAT: Firewalls track outgoing requests by recording the Source IP : Source Port 4-tuple. When the response arrives, the firewall checks if the incoming Destination IP : Destination Port matches its table of outbound requests. If they are not reversed, the firewall drops the packet.
* OS Routing: When the client OS receives the response, it uses the reversed destination port to find the exact application socket that generated the original request.



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
