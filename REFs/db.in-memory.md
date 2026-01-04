# In-memory Data Store

There are several popular open-source alternatives to Redis, 
each with different strengths. 

Here's a breakdown:

---

## **🎯 Direct "Redis-like" Alternatives**

### **1. [KeyDB](https://docs.keydb.dev/)** | [OCI](https://hub.docker.com/r/eqalpha/keydb)
- **What**: Multi-threaded fork of Redis (Redis is single-threaded) | [OCI Helm](https://hub.docker.com/r/bitnamicharts/keydb)
- **Key difference**: Better multi-core utilization, same protocol
- **Best for**: Higher throughput on modern multi-core servers
- **Protocol**: Fully Redis-compatible

### **2. [Dragonfly](https://www.dragonflydb.io/)**
- **What**: Modern, high-performance drop-in replacement
- **Key difference**: Built from scratch, uses newer algorithms, better memory efficiency
- **Best for**: High performance at scale, large datasets
- **Protocol**: Redis-compatible

### **3. [Valkey](https://valkey.io/)** (The new official fork)
- **What**: Community fork of Redis (after Redis changed license)
- **Key difference**: Truly open-source (BSD), community-driven
- **Best for**: Those wanting FOSS without commercial restrictions
- **Protocol**: 100% Redis-compatible

---

## **🔄 Similar Use Cases (Different Approaches)**

### **4. Memcached**
- **What**: Original in-memory key-value store (simpler than Redis)
- **Key difference**: No persistence, simpler, multi-threaded, older but battle-tested
- **Best for**: Simple caching, when you don't need Redis's data structures
- **Protocol**: Own protocol (not Redis-compatible)

### **5. Apache Ignite**
- **What**: In-memory computing platform with SQL support
- **Key difference**: SQL queries, ACID transactions, distributed computing
- **Best for**: Applications needing SQL + caching + compute
- **Protocol**: Various (JDBC, REST, custom)

### **6. Hazelcast**
- **What**: In-memory data grid
- **Key difference**: Java-centric, distributed data structures, compute on data
- **Best for**: Java applications needing distributed caching/computation
- **Protocol**: Client libraries (Java/.NET/etc)

---

## **📊 Feature Comparison Table**

| **System** | **Redis Protocol** | **Data Structures** | **Persistence** | **Threading** | **Primary Strength** |
|------------|-------------------|-------------------|----------------|---------------|---------------------|
| **Redis** | Native | Rich (strings, hashes, lists, sets, etc) | RDB/AOF | Single-threaded | Mature, feature-rich |
| **KeyDB** | ✅ Compatible | Same as Redis | RDB/AOF | **Multi-threaded** | Performance on multi-core |
| **Valkey** | ✅ Compatible | Same as Redis | RDB/AOF | Single-threaded (for now) | Open-source future |
| **Dragonfly** | ✅ Compatible | Redis subset + more | Snapshots | Multi-threaded | Memory efficiency, scale |
| **Memcached** | ❌ | Simple key-value | ❌ None | Multi-threaded | Simplicity, speed |
| **Ignite** | ❌ | SQL tables + more | Yes (disk) | Distributed | SQL + transactions |

---

## **🔄 When to Choose What:**

### **Choose Redis (or Valkey) if:**
- You need specific Redis features (pub/sub, Lua scripting, etc.)
- Mature ecosystem and documentation matter
- You have existing Redis code/tools

### **Choose KeyDB/Dragonfly if:**
- You're CPU-bound with Redis
- Need better multi-core performance
- Willing to try newer implementations

### **Choose Memcached if:**
- You only need simple key-value caching
- Want maximum simplicity
- Have multi-threaded read-heavy workloads

### **Choose Ignite/Hazelcast if:**
- You need distributed computing capabilities
- SQL access to cached data is important
- Working mainly in Java ecosystem

---

## **🔍 Quick Decision Guide:**

```yaml
Need Redis compatibility?
├── Yes → Want multi-core?
│   ├── Yes → KeyDB or Dragonfly
│   └── No → Redis or Valkey
└── No → Need SQL/transactions?
    ├── Yes → Apache Ignite
    └── No → Simple caching only?
        ├── Yes → Memcached
        └── No → Evaluate Hazelcast
```

---

## **📈 Current Trends (2024):**
- **Valkey** is gaining traction as the community-driven Redis alternative
- **Dragonfly** showing impressive benchmarks for large datasets
- **Redis itself** remains most popular, but license changes pushed people to alternatives
- **Memcached** still widely used for simple caching

**Most common path**: Start with Redis/Valkey, migrate to KeyDB/Dragonfly if hitting single-threaded limits. Use Memcached if you truly don't need Redis's extra features.

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
