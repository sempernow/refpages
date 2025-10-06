# [Jacamar CI](https://gitlab.com/ecp-ci/jacamar-ci "gitlab.com/ecp-ci/jacamar-ci")

Jacamar CI is the HPC focused CI/CD driver using GitLab’s
custom executor model.
The core goal of this project is to establish a maintainable, yet extensively configurable
tool that will allow for the use of GitLab’s robust testing
on unique resources. Allowing code teams to integrate potentially existing
pipelines on powerful scientific development environments.

## AuthN/AuthZ 

In Jacamar CI (and in similar systems like GitLab CI with KAS, or GitHub Actions with OIDC), 
the JWT that a job gets is not just a random bearer token; 
it’s a **cryptographically-signed identity assertion** that the external service 
(HPC service in this case) can verify.

Here’s what the JWT contains and why the HPC service can trust it:

---

### 1. **Issuer and Signing**

* The JWT is issued by Jacamar CI’s identity service (often backed by its own OIDC/JWT issuer).
* It’s signed with the CI system’s private key.
* The HPC service only needs Jacamar’s **public key / JWKS endpoint** to verify the signature.

This means the HPC service never has to trust the runner VM/container directly — only Jacamar as the authority.

---

### 2. **Claims in the Job Token**

The JWT includes structured claims that prove context:

* **`iss`** – the Jacamar CI issuer identifier (trusted authority).
* **`sub`** – the subject, typically encoding the project/job identity.
* **`aud`** – audience claim, often restricted to the intended service (e.g., `hpc-service.lan`).
* **`exp`** – expiration, usually just a few minutes, preventing reuse.
* **Job metadata claims** such as:

  * project ID or repo path,
  * pipeline/job ID,
  * branch/commit hash,
  * runner info (sometimes).

---

### 3. **Why HPC Can Trust It**

* The HPC service validates the JWT’s **signature** and **audience** against its configured trust.
* It can enforce **short-lived token acceptance** (reject expired tokens).
* It can use claims (e.g., project or branch) to authorize access to certain HPC queues or resources.
* Since the job never gets long-lived secrets, compromise of a job pod/runner doesn’t expose permanent credentials.

---

### 4. **Typical Flow**

1. Jacamar CI job requests a JWT for "HPC access".
2. Jacamar signs and issues the JWT with appropriate claims.
3. Job presents the JWT to the HPC service.
4. HPC service validates:

   * Signature (via Jacamar’s public key).
   * Audience = itself.
   * Expiry not passed.
5. If valid, HPC grants job the requested resource access.

---

✅ **In short**:
The HPC service doesn’t trust the job directly — it trusts **Jacamar’s signature** on the JWT, 
and uses the **claims (sub, aud, exp, etc.)** to safely map the CI job to an HPC identity/authorization profile.

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
