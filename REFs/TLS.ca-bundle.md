# Add Root CA(s) to a host's Trust Store

The certificate file must be:

- Must be __PEM format__ 
    ```bash
    # Convert DER to PEM
    openssl x509 -in $ca$.der -inform DER -out $ca.crt -outform PEM
    ```
- Must end with __`.pem`__ or __`.crt`__

## RHEL/Fedora : `/etc/pki/ca-trust/source/anchors/`

```bash
# Install the package
dnf install -y p11-kit-trust ca-certificates
# Create the source dir
mkdir -p /etc/pki/ca-trust/source/anchors/
# Copy the CA cert(s) to the source dir
cp -p lime-dc1-ca.crt /etc/pki/ca-trust/source/anchors/
# Add : Process source CAs by creating symlinks and hash (c_rehash)
update-ca-trust extract
# Verify
openssl x509 -subject -issuer -noout -in /etc/pki/tls/certs/ca-bundle.crt
# Validate
curl -sSIX GET https://dc1.lime.lan/
```
- Verify step presumes the desired cert is the first one, else manually parse, 
  else rely on the gold-standard validation: 
  successful TLS handshake with a client, e.g., `curl`.

## Debian/Ubuntu : `/usr/local/share/ca-certificates/`

```bash
# Install the package
apt-get install -y ca-certificates
# Copy the CA cert(s) to the source dir
cp -p lime-dc1-ca.crt /usr/local/share/ca-certificates/
# Add : Process source CAs by creating symlinks and hash (c_rehash)
update-ca-certificates
# Verify
openssl x509 -subject -issuer -noout -in /etc/ssl/certs/ca-bundle.crt
# Validate
curl -sSIX GET https://dc1.lime.lan/
```

### Symlink Creation (`c_rehash`):

The `c_rehash` command is run on the `/etc/ssl/certs/` directory.
Every `.crt` and `.pem`  file in the directory is processed.
A hash of the certificate's subject name is created 
and used to map the symlink to the source certificate; 
`f10e7a5c.0 -> lime-dc1-ca.crt`

# SSL_CERT_FILE

Setting `SSL_CERT_FILE` to point to a single file containing all your private CA certificates in PEM format is a common and often successful strategy, but it is **not a universal solution.** Its success depends entirely on whether the client library you are using respects that specific environment variable and how it implements trust.

Here’s a detailed breakdown:

### How `SSL_CERT_FILE` Works (The Theory)

The `SSL_CERT_FILE` environment variable is a convention used primarily by **OpenSSL** and software that directly uses the OpenSSL library (like many compiled programs, `curl` built with OpenSSL, Python's `requests` library when linked against OpenSSL, etc.).

*   **What it does:** When set, it tells the OpenSSL library to **bypass the system's default trust store** (e.g., `/etc/ssl/certs/` on Linux) and instead use the specified file as its sole source of trust anchors.
*   **The Requirement:** The file must be a concatenation of one or more PEM-encoded CA certificates. OpenSSL will read this file directly; it does **not** require the certificates to be in a hashed symlink directory structure.

So, for any tool that uses OpenSSL and respects this variable, your unprocessed `ca-bundle.crt` file would be sufficient.

### The Reality: A Fragmented Landscape of HTTP Clients

Not all HTTP clients or programming languages use OpenSSL or respect this variable. Here’s a categorization:

#### Category 1: Likely to Work (Uses OpenSSL & respects `SSL_CERT_FILE`)

*   **curl (compiled with OpenSSL support):** This is the classic example. `curl` will honor `SSL_CERT_FILE`.
*   **wget (compiled with OpenSSL support):** Similarly, it will often respect this variable.
*   **Many compiled languages (C, C++, Go, Rust) when using OpenSSL bindings:** If the program is explicitly linked against and configured to use OpenSSL, it will typically use this.
*   **Python:** The `requests` library (and `urllib3` underneath it) often uses the system's TLS libraries. On many systems, this is OpenSSL, so `SSL_CERT_FILE` will work. However, Python can be compiled against other backends.
*   **Git:** Often uses OpenSSL for HTTPS operations.

#### Category 2: Will NOT Work (Ignores `SSL_CERT_FILE`)

*   **Java (JVM):** The JVM has its own proprietary certificate trust store (`cacerts`). It completely ignores `SSL_CERT_FILE`. You must import your CAs into the Java keystore using `keytool`.
*   **Node.js:** Node.js does not use the system OpenSSL settings by default. It has its own compiled-in list of CAs. To add custom CAs, you must use the **`NODE_EXTRA_CA_CERTS`** environment variable, which points to a file just like the one you described. `SSL_CERT_FILE` does nothing.
*   **Google Chrome / Chromium / Microsoft Edge (on Linux):** These browsers use the **NSS** (Network Security Services) library and its own trust store (`sqlite` databases in `~/.pki/nssdb/`). They ignore `SSL_CERT_FILE`. You must use `certutil` to add certificates to the NSS DB or import them through the browser's GUI.
*   **Firefox:** Also uses NSS and manages its own trust store completely independently of the operating system. It ignores `SSL_CERT_FILE`.
*   **.NET / C#:** Uses the underlying OS's trust store on Windows and macOS. On Linux, behavior can vary but often uses a custom path. It does not respect `SSL_CERT_FILE`.
*   **Go (Programs using the native `crypto/tls` package):** The Go compiler statically bundles a set of root CAs into the binary. It ignores `SSL_CERT_FILE`. You must either (1) set `tls.Config{RootCAs: pool}` in your code, or (2) set the `SSL_CERT_DIR` environment variable to point to a directory of hashed certificates (not a single file!), or (3) use the system cert pool, which may not read `SSL_CERT_FILE`.

#### Category 3: Has Its Own Mechanism

*   **Python (with `certifi`):** Many Python packages use the `certifi` package, which provides a curated bundle of Mozilla's CA roots. You can override this by pointing `requests` to your custom bundle using the `verify` parameter or by setting the `REQUESTS_CA_BUNDLE` environment variable.

### The Critical "Hashed Symlink" Requirement for `SSL_CERT_DIR`

You might see advice to use `SSL_CERT_DIR` instead. This is even more strict. `SSL_CERT_DIR` must point to a directory (e.g., `/etc/ssl/certs`) that contains the **hashed symlinks** (`f10e7a5c.0 -> some-cert.pem`). A directory containing just the raw `.pem` files without the symlinks will **not work** for OpenSSL unless the application specifically calls `SSL_CTX_load_verify_locations` on the file directly.

### Best Practice and Recommendation

**1. For Application-Specific Control (Recommended):**
Use the environment variable *specific to your runtime* if it exists. This is the most reliable method.
*   **Node.js:** `NODE_EXTRA_CA_CERTS`
*   **Python Requests:** `REQUESTS_CA_BUNDLE`
*   **General OpenSSL:** `SSL_CERT_FILE`
*   **curl/wget:** `CURL_CA_BUNDLE` (though they also respect `SSL_CERT_FILE`)

**2. For System-Wide Control (For Containers/Images):**
The most robust and portable solution is still to **build the certificates into the system trust store** using `update-ca-certificates` (Debian) or `update-ca-trust` (RHEL). This ensures that *every* tool on the system (that respects the OS defaults) will work without any special environment variables.

**3. For your specific question:**
If you control the environment and know for a fact that every HTTP client you need to support is in **Category 1** (e.g., a container running a Python app using `requests` and some `curl` commands), then setting `SSL_CERT_FILE` to your unprocessed `ca-bundle.crt` is a perfectly valid and simple solution.

However, if there's any chance a Java app, Node.js app, or web browser might be involved, **it will not be sufficient.** You must employ additional strategies for those specific runtimes.

---

# TLS v. Other : `ca-bundle.crt` v `ca-bundle.trust.crt`

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
