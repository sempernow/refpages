# HTTP/2 v. TLS Compliance


# Q:

HTTP/2 requires one of two 128 bit ciphers. Though they may be FIPS compliant, they do not comply with security requirements of certain air-gap networks. Yet, Redhat openshift has a compliant solution.  What might it be?

# A:

## The Problem

**RFC 7540 (HTTP/2)** mandates that compliant implementations *must* support:

- `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`
- `TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256`

These are FIPS 140-2/3 approved, but certain air-gapped/classified networks (e.g., those governed by CNSSP-15, CNSA 2.0, or DoD IL5/IL6 requirements) mandate **256-bit minimum key strength** across all negotiated ciphers — making even these FIPS-approved 128-bit ciphers non-compliant with the network's ATO.

---

## Red Hat's Solution: TLS 1.3 + HTTP/2 via ALPN


### Data Plane

OpenShift's answer is to use **TLS 1.3 as the minimum protocol version**, 
configured via its **IngressController TLS security profile**.

Here's why this resolves the issue:

- **RFC 7540 Section 9.2** cipher requirements apply specifically to TLS 1.2 negotiation. When TLS 1.3 is used, the HTTP/2 mandatory cipher clause is effectively superseded.
- TLS 1.3's cipher suite model is fundamentally different — cipher suites are decoupled from key exchange, and the mandatory suites (`TLS_AES_256_GCM_SHA384`, `TLS_CHACHA20_POLY1305_SHA256`) can satisfy 256-bit requirements.
- HTTP/2 is still negotiated via **ALPN** (`h2`) within the TLS 1.3 handshake — you get HTTP/2 multiplexing without ever touching the RFC 7540-mandated 128-bit ciphers.

#### OpenShift Configuration

```yaml
apiVersion: operator.openshift.io/v1
kind: IngressController
metadata:
  name: default
  namespace: openshift-ingress-operator
spec:
  tlsSecurityProfile:
    type: Custom
    custom:
      minTLSVersion: VersionTLS13
      ciphers:
        - TLS_AES_256_GCM_SHA384
        - TLS_CHACHA20_POLY1305_SHA256
```

With `minTLSVersion: VersionTLS13`, the HAProxy-based ingress will only negotiate TLS 1.3, and the RFC 7540 §9.2.2 cipher mandate becomes a non-issue since it's scoped to TLS 1.2 behavior.

### Control Plane

#### The Core Problem

Go's `crypto/tls` package **hardcodes TLS 1.3 cipher suites** and explicitly ignores any cipher preference configuration for TLS 1.3:

```go
// From Go stdlib - you cannot influence these
var defaultCipherSuitesTLS13 = []uint16{
    tls.TLS_AES_128_GCM_SHA256,      // ← non-compliant, cannot remove
    tls.TLS_AES_256_GCM_SHA384,
    tls.TLS_CHACHA20_POLY1305_SHA256,
}
```

Setting `tls.Config.CipherSuites` **has no effect on TLS 1.3** — it's documented and intentional upstream. Every OpenShift control plane component (kube-apiserver, etcd, controller-manager, scheduler, OAuth server, etc.) is a Go binary that hits this wall.

---

#### Red Hat's Solution: `golang-fips` + RHEL Crypto Policies

Red Hat ships a **forked Go toolchain** — [`golang-fips`](https://github.com/golang-fips/go) — which replaces the standard `crypto/tls` and `crypto/internal` packages with a **CGo bridge to the system OpenSSL library**.

#### How it works:

```
Standard Go:    crypto/tls → Go native crypto (no TLS 1.3 cipher control)

Red Hat Go:     crypto/tls → golang-fips shim → CGo → libssl/libcrypto (OpenSSL)
                                                           ↑
                                              SSL_CTX_set_ciphersuites()
                                              now works for TLS 1.3
```

Because OpenSSL **does** expose TLS 1.3 cipher suite selection (`SSL_CTX_set_ciphersuites` as distinct from `SSL_CTX_set_cipher_list`), the restriction becomes possible.

---

#### The Enforcement Mechanism: RHEL System-Wide Crypto Policies

Since the Go binaries now __delegate to OpenSSL__, 
they inherit the **RHEL crypto policy** framework:

```bash
# View current policy
update-crypto-policies --show

# The relevant knob for your scenario
update-crypto-policies --set FIPS
```

But stock `FIPS` policy still permits `AES-128`. You need a **policy module** to further restrict:

```ini
# /etc/crypto-policies/policies/modules/NO-AES128-TLS13.pmod
cipher@TLS = -AES-128-GCM
```

```bash
update-crypto-policies --set FIPS:NO-AES128-TLS13
```

Because OpenShift control plane components on RHEL in FIPS mode are built with `golang-fips`, 
they **respect this policy automatically** — ***no per-component configuration needed***.

---

#### The Chain of Trust

```
RHEL crypto-policies (NO-AES128 module)
        ↓
system OpenSSL (libssl / libcrypto)
        ↓
golang-fips CGo bridge
        ↓
OpenShift control plane binaries
(kube-apiserver, etcd, oauth-server, etc.)
        ↓
TLS 1.3 negotiation excludes TLS_AES_128_GCM_SHA256
```

---

#### Key Distinction from Upstream Kubernetes

Upstream `kube-apiserver` built with standard Go toolchain: **cannot** restrict TLS 1.3 ciphers
- the `--tls-cipher-suites` flag is explicitly documented as having no effect on TLS 1.3.

Red Hat OpenShift's `kube-apiserver` binary: **can**, because it's compiled with `golang-fips` against RHEL's OpenSSL, making it a fundamentally different binary despite identical source code.

This is also why **RHEL FIPS mode must be enabled at the OS level before OpenShift installation** 
— the crypto policy and OpenSSL FIPS provider need to be active before the Go runtime initializes, 
as `golang-fips` checks FIPS mode status at startup and will refuse to run non-FIPS primitives.

---

#### Summary

| Layer | Issue | Resolution |
|---|---|---|
| RFC 7540 | Mandates 128-bit GCM cipher support | Only applies to TLS 1.2 negotiation |
| TLS 1.3 | No mandatory weak ciphers; 256-bit suites available | Used exclusively via `minTLSVersion: VersionTLS13` |
| ALPN | HTTP/2 protocol negotiation | Unaffected; `h2` still advertised and negotiated |
| Air-gap policy | 256-bit minimum cipher enforcement | Satisfied by TLS 1.3-only cipher set |

This is also why **RFC 9113** (the HTTP/2 update) ***relaxed the TLS 1.2 cipher requirements*** 
— the assumption being that TLS 1.3 adoption would render the original §9.2 constraints increasingly academic.


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
