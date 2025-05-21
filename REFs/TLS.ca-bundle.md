# `ca-bundle.crt` v `ca-bundle.trust.crt`

- __`/etc/ssl/certs/ca-bundle.crt`__ -> `/etc/pki/tls/certs/ca-bundle.crt` (__270–300 KB__)
    - PEM
- __`/etc/pki/tls/certs/ca-bundle.trust.crt`__ (__500–600 KB__)
    -   PEM + trust flags

When an application requests the **CA certificate bundle**, the correct file to provide depends on:

1. **The application’s TLS library** (OpenSSL, GnuTLS, NSS, etc.)
2. **Whether it expects trust flags (i.e., "trusted for server auth")**
3. **The expected format (PEM, DER, trust-annotated PEM)**

Let’s break it down.

---

## 🔍 When to Provide Which CA Bundle

| Use Case / Application                                                 | Provide This CA Bundle                                                                      | Why?                                                               |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| **OpenSSL**, **curl**, **wget**, **git**, **dnf/yum**                  | `/etc/ssl/certs/ca-bundle.crt` <br>(on RHEL: symlink to `/etc/pki/tls/certs/ca-bundle.crt`) | OpenSSL expects plain PEM format                                   |
| **GnuTLS** (used by GNOME apps, `wget` on Fedora), **glib-networking** | `/etc/pki/tls/certs/ca-bundle.trust.crt`                                                    | GnuTLS requires trust bits, supported in `*.trust.crt`             |
| **Firefox**, **NSS-based apps**                                        | Internal NSS DB or `/etc/pki/nssdb`                                                         | Uses its own cert store; must be updated via `certutil`            |
| **Python `requests`** (via `certifi`)                                  | Use `certifi.where()` or override via `REQUESTS_CA_BUNDLE`                                  | Python uses its own vendored CA list unless overridden             |
| **Java (JVM)**                                                         | `$JAVA_HOME/lib/security/cacerts` (Java Keystore)                                           | Expects JKS or PKCS#12, not PEM — needs conversion                 |
| **Go** binaries (static)                                               | Uses system default (if dynamically linked) or may bundle its own                           | Built-in Go TLS honors `/etc/ssl/certs` on Linux unless overridden |

---

## 🧭 General Recommendation for Linux Systems

* When in doubt, **use `/etc/ssl/certs/ca-bundle.crt`**

  * This is the **most widely compatible** PEM-format bundle
  * It is what most command-line and backend applications expect
* **Only use `/etc/pki/tls/certs/ca-bundle.trust.crt`** if the application is explicitly **GnuTLS-based** and respects trust flags

---

## 🔧 Custom Environment Variable Overrides (for applications)

If an app doesn’t pick up the right bundle:

```bash
export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-bundle.crt
```

Or in systemd units:

```ini
[Service]
Environment="SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
```

---

## 🛠️ Summary Table

| Bundle Path                              | Format       | Suitable For                              |
| ---------------------------------------- | ------------ | ----------------------------------------- |
| `/etc/ssl/certs/ca-bundle.crt`           | PEM          | Most CLI tools (OpenSSL, curl, etc)       |
| `/etc/pki/tls/certs/ca-bundle.trust.crt` | PEM w/ trust | GnuTLS, glib-networking                   |
| `/etc/pki/nssdb/`, Firefox profile DBs   | NSS DB       | Firefox, Thunderbird, some security tools |
| Java keystore (`cacerts`)                | JKS          | Java applications                         |

---

### ✅ TL;DR

Most applications expect **`/etc/ssl/certs/ca-bundle.crt`** — the plain PEM file — unless you're using **GnuTLS-based tools**, **NSS (like Firefox)**, or **Java**, which have different requirements.



---
Yes — **most container images** **do include at least one CA bundle**, 
especially if the image is based on a full Linux distribution (e.g., RHEL UBI, Alpine, Debian, etc.). Here's how and why:

---

## ✅ **Why CA Bundles Are Included in Container Images**

Most containers need CA bundles for **TLS certificate validation**, including:

* `curl`, `wget`, `git`, `dnf`, `apt`, `apk`
* Internal services making HTTPS requests
* Connecting to Kubernetes APIs or artifact registries
* Validating TLS connections to internal services using public or private certs

If the CA bundle is missing:

* HTTPS connections will fail with `x509: certificate signed by unknown authority`
* `dnf`/`yum`, `git clone`, or similar operations will break

---

## 📦 **Typical CA Bundle Locations in Container Images**

| Base Image        | Trust File                           | Package Providing It                   |
| ----------------- | ------------------------------------ | -------------------------------------- |
| **RHEL / UBI**    | `/etc/pki/tls/certs/ca-bundle.crt`   | `ca-certificates`                      |
| **Debian/Ubuntu** | `/etc/ssl/certs/ca-certificates.crt` | `ca-certificates`                      |
| **Alpine**        | `/etc/ssl/certs/ca-certificates.crt` | `ca-certificates` (musl/OpenSSL-based) |

> 🔹 These are symlinks or files pointing to trusted root bundles maintained by each distro's update mechanism.

---

## 🧼 **Are They Always Included?**

Not always:

* **Slim/minimal base images** (like `ubi-micro`, `alpine:3.19`, or `scratch`) **may omit** the bundle to reduce image size.
* You may need to install `ca-certificates` manually in a Dockerfile:

  ```Dockerfile
  RUN dnf install -y ca-certificates
  # or
  RUN apt-get install -y ca-certificates
  # or
  RUN apk add ca-certificates && update-ca-certificates
  ```

---

## 🧰 **In Custom or Air-Gapped Containers**

You may:

* Inject your own **custom CA bundle** into `/etc/pki/ca-trust/source/anchors/` and rebuild with `update-ca-trust`
* Mount or copy a CA file (e.g., `ca.crt`) and use `SSL_CERT_FILE`:

  ```Dockerfile
  ENV SSL_CERT_FILE=/etc/ssl/certs/my-ca-bundle.crt
  ```

---

### ✅ TL;DR

Yes, container images **typically include CA bundles**, especially standard ones like `ca-bundle.crt` or `ca-certificates.crt`, so that tools and applications can validate HTTPS/TLS connections.

Minimal images might omit them for size, but in practice, **most working containers need them** — and you'll have to add them explicitly in custom or stripped-down images.

You're absolutely right — RHEL (and many other Linux systems) maintain **two primary CA bundle files**, and their differing sizes and contents serve distinct purposes.

Here’s what they are and **why both exist**:

---

## 📁 The Two Bundles in RHEL

### 1. **`/etc/ssl/certs/ca-bundle.crt`**

(Approx. **270–300 KB**)

* **Purpose:** The main **PEM-formatted trust store** used by:

  * `curl`
  * `git`
  * `dnf` / `yum`
  * OpenSSL, libcurl, etc.

* **Contents:**

  * A consolidated flat list of all trusted root CAs (and sometimes intermediates)
  * Produced by `update-ca-trust` by merging:

    * Red Hat’s default trust
    * Any custom CAs in `/etc/pki/ca-trust/source/anchors/` or `/usr/share/pki/ca-trust-source/`

* **Used by software that reads PEM-style CA lists.**

---

### 2. **`/etc/pki/tls/certs/ca-bundle.trust.crt`**

(Approx. **500–600 KB**)

* **Purpose:** A **more detailed version** of the trust store, including **trust flags**, used by:

  * **GnuTLS**
  * **glib-networking** (which GNOME apps use)
  * Applications using **NSS** (like Firefox or systemd with PKCS#11)

* **Contents:**

  * In **RFC 5280** format with **trust bits** (e.g., `SERVER_AUTH`, `EMAIL_PROTECTION`, `CODE_SIGNING`)
  * Derived from the same set of trusted CAs, but with richer metadata

* **Used by software that cares about certificate purpose constraints**, not just validity.

---

## 🧠 Why Two Bundles?

| Feature        | `ca-bundle.crt`          | `ca-bundle.trust.crt`                  |
| -------------- | ------------------------ | -------------------------------------- |
| Format         | PEM                      | PEM + trust flags (OpenSSL + p11-kit)  |
| Consumers      | OpenSSL, curl, git, etc. | GnuTLS, GNOME apps, systemd, Firefox\* |
| Trust metadata | ❌ No                     | ✅ Yes                                  |
| Size           | Smaller (\~300 KB)       | Larger (\~600 KB)                      |

---

## 🔄 How They’re Maintained

Both are regenerated via:

```bash
update-ca-trust extract
```

...which reads from:

* `/etc/pki/ca-trust/source/anchors/` (local trusted certs)
* `/etc/pki/ca-trust/source/blacklist/` (locally rejected certs)
* System-wide default source (RPM-provided trusted certs)

---

## 🧩 In Air-Gapped or Hardened Systems

You can:

* Replace or prune both bundles
* Rebuild them with just internal CA(s) using `update-ca-trust`
* Still serve both formats to satisfy all software

---

### ✅ TL;DR

RHEL provides **two CA bundles**:

* `ca-bundle.crt`: for OpenSSL/curl-style consumers
* `ca-bundle.trust.crt`: for GnuTLS/NSS consumers, with **purpose-specific trust flags**

You need **both** to ensure compatibility across all system libraries and tools.

<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->
