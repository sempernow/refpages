# TLS Cipher Suites : HTTP/2 vs. Golang HTTP/2

# Q: 
Golang implementation of http/2 differs from spec?

# A 

Go's HTTP/2 implementation is generally highly compliant with RFC 9113 (which obsoleted RFC 7540), but there are specific areas where it differs in behavior, lacks certain optional features, or imposes stricter requirements than the base specification. 

**Key Differences and Implementation Choices**

- Mandatory TLS: While the HTTP/2 spec allows for cleartext communication (h2c) via an Upgrade header, Go's standard net/http package only supports HTTP/2 over TLS by default. Supporting cleartext HTTP/2 requires using the golang.org/x/net/http2 package and explicit configuration.
- Graceful Shutdown Limitations: Earlier versions of Go's HTTP/2 implementation lacked full support for graceful shutdown using GOAWAY frames as strictly suggested by the spec (which recommends sending an initial GOAWAY with a high stream ID followed by a second one after one RTT).
- Disallowed Headers: Go’s server-side implementation strictly enforces the spec's ban on certain "connection-specific" headers like Connection: close. If a handler attempts to write this header, it can result in a protocol error because HTTP/2 manages connection state through its own framing layer rather than headers.
- Fixed Frame Sizes: The Go implementation originally used a relatively small default receiver frame size (16KB), which is the spec minimum. While compliant, this caused significant performance degradation compared to HTTP/1.1 in high-throughput scenarios until manually tuned or updated in newer versions.
- HPACK Table Probing: Internal implementations of HPACK header compression in Go have historically lacked public APIs to "probe" or inspect the dynamic table contents, which made it slightly different for developers used to other stacks (like Varnish) that allow deeper introspection for testing. 
Reddit


**Managing Compliance and Features**

For developers needing to bypass standard library defaults or access lower-level HTTP/2 features (like custom write schedulers), the Go team maintains the x/net/http2 package. This package is often ahead of the standard library and allows for more granular adherence to specific RFC sub-sections. 

# Q:

The spec requires one of two TLS cipher suites, where Golang's requires both. 
Configuring a K8s control plane by declaring ciphers list in `KubeletConfiguration` t
o meet a particularly strict network requirement took down the CP, 
which logged complaints of HTTP/2 failures.

# A:

That is a classic "trap" in Go's HTTP/2 implementation. 
You've run into a situation where Go’s enforcement of the HTTP/2 specification is stricter than many other implementations, 
particularly regarding the TLS handshake.

**The Conflict: RFC 7540 vs. Go's Implementation**

The HTTP/2 specification (RFC 7540, Section 9.2.2) states that a deployment MUST support `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`.

However, Go's http2 package (which Kubernetes uses) takes this a step further. To prevent "downgrade" attacks and ensure compliance, Go internally checks the negotiated cipher suite. If you explicitly configure a cipher list in your KubeletConfiguration (or any Go-based server) and that list excludes the specific suites Go considers "safe" for HTTP/2, the server will disable HTTP/2 support entirely and fall back to HTTP/1.1 or fail the handshake.

**Why the Control Plane Crashed**

When you restricted the cipher suites in the Kubelet or API Server configuration, 
you likely removed one of the following:

- `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`
- `TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256`

**The Go Logic**:

1. Go checks the TLSConfig.CipherSuites list.
1. If it sees a list is provided but it doesn't contain the "mandatory" H2 ciphers, it assumes the connection is not secure enough for HTTP/2.
1. Because Kubernetes components (like the API server and Kubelet) often require HTTP/2 for features like long-lived streams, logs, and exec, the communication breaks.
1. If the control plane components cannot talk to each other via HTTP/2, the health checks fail and the Control Plane (CP) goes down.

**Comparison of Requirements**

|Feature|RFC 7540 (Spec)|Go Implementation|
|-------|---------------|-----------------|
|Mandatory Cipher|`TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`|Both RSA and ECDSA variants are effectively required if using a custom list.|
|Blacklisted Ciphers|Lists hundreds of "bad" ciphers.|Go will explicitly error or disable H2 if a blacklisted cipher is negotiated.|
|Automatic Fallback|Suggests falling back to HTTP/1.1.|Go often forces a protocol error if H2 was expected but the TLS handshake was "insufficient."|

**How to Fix It**

To satisfy both your strict network requirements and Go's HTTP/2 requirements, 
your cipherSuites list in the `KubeletConfiguration` or `KubeAPIServer` 
must include the H2-approved ciphers at the top of the list.

**Recommended Cipher List for K8s (Strict but H2-Compatible):**
```yaml

tlsCipherSuites:
  - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 # Mandatory for H2 (ECDSA)
  - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256   # Mandatory for H2 (RSA)
  - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 # High Strength
  - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384   # High Strength
```

Note: If you are using TLS 1.3, the cipher suites are handled differently and are not configurable in the same way. 
This issue almost exclusively haunts environments forcing TLS 1.2.

Would you like me to check if your specific "strict" cipher list has any other conflicts with Go's internal blacklist?


# Q:

Why the 128 variant when stronger variants are available ?

# A:

It feels counter-intuitive to prioritize a "128-bit" cipher when "256-bit" options are available, especially in high-security environments. However, the requirement for the 128-bit variant exists due to a mix of protocol rigidity, performance defaults, and historical standardization.

Here is why Go and the HTTP/2 spec cling to the 128-bit variant:

## 1. The "Must" vs. "Should" in RFC 7540

The HTTP/2 specification authors wanted to guarantee that any two HTTP/2 devices in the world could talk to each other without a "no shared cipher" error. To achieve this, they had to pick a Mandatory Implementable cipher.
The Choice: `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256` was chosen as the baseline because it was the most widely supported, performant, and secure-enough cipher available across all hardware (mobile, IoT, and servers) at the time the spec was written.
The Go Enforcement: Go’s http2 implementation is written to be "secure by default." If you provide a custom list and omit the one cipher the spec says MUST be there, Go’s net/http library views the configuration as "broken" or "non-compliant" and disables HTTP/2 to prevent unpredictable behavior.

## 2. Performance and AES-NI

AES-128 is significantly faster than AES-256 in software, and even with hardware acceleration (AES-NI), AES-128 is roughly 40% faster because it requires fewer "rounds" of encryption (10 rounds vs 14 rounds).
For a Kubernetes Control Plane handling thousands of small requests (etcd calls, status updates, watch events), the latency benefit of 128-bit encryption is measurable.
Go’s internal heuristics often prefer the 128-bit version to ensure the performance gains of HTTP/2 aren't immediately lost to encryption overhead.

## 3. The "Security Margin" Argument

From a cryptographic standpoint, the jump from 128-bit to 256-bit is often seen as a defense against quantum computing (Grover's algorithm), rather than classical attacks.
For standard TLS traffic today, 128-bit GCM is still considered computationally infeasible to break.
The HTTP/2 spec authors prioritized interoperability over the "overkill" security of 256-bit, and Go followed that lead strictly.

## 4. How Go Handles the "Stronger" Options

Go will use the stronger 256-bit variants if both the client and server support them, 
but its internal validation logic checks for the existence of the 128-bit variant in your config as a "safety check."

If you provide a list that only contains 256-bit ciphers, Go's logic effectively says:
"I see you didn't include the mandatory 128-bit cipher required by the RFC. 
I cannot guarantee this connection will be compliant, so I will refuse to promote this connection to HTTP/2."

**The Solution for "Strict" Requirements**

If your security policy mandates 256-bit, the standard workaround is to include both, placing the 256-bit variants at the top of the list. Go (and the TLS handshake) will generally respect the order and pick the stronger one,
 while the presence of the 128-bit cipher at the bottom of the list satisfies Go's "compliance check."

**Example**:

- `TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384` (Handshake will pick this)
- `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384`
- `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256` (Present only to keep Go/H2 happy)


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
